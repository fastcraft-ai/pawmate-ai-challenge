#!/usr/bin/env python3
"""
aggregate_results.py — Aggregate and compare benchmark results

Usage:
    python3 scripts/aggregate_results.py [--input-dir <dir>] [--output-dir <dir>] [--spec-version <version>]

Options:
    --input-dir <dir>      Directory containing result files (default: results/submitted/)
    --output-dir <dir>     Output directory for compiled reports (default: results/compiled/)
    --spec-version <ver>   Filter by spec version (optional)
"""

import argparse
import json
import os
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import json

try:
    from jsonschema import validate, ValidationError
except ImportError:
    print("Error: jsonschema not installed. Run: pip install -r scripts/requirements.txt", file=sys.stderr)
    sys.exit(1)


def load_schema(schema_path: Path) -> dict:
    """Load JSON schema for validation."""
    with open(schema_path, 'r') as f:
        return json.load(f)


def parse_result_file(file_path: Path, schema: Optional[dict] = None) -> Optional[dict]:
    """Parse a result file and return structured data."""
    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
        
        # Validate against schema if provided
        if schema:
            try:
                validate(instance=data, schema=schema)
            except ValidationError as e:
                print(f"Warning: Schema validation failed for {file_path}: {e.message}", file=sys.stderr)
                return None
        
        # Add filename for reference
        data['_filename'] = file_path.name
        data['_filepath'] = str(file_path)
        
        return data
    
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in {file_path}: {e}", file=sys.stderr)
        return None
    except Exception as e:
        print(f"Error parsing {file_path}: {e}", file=sys.stderr)
        return None


def calculate_scores(metrics: dict) -> dict:
    """Calculate dimension scores from metrics."""
    scores = {}
    
    # C - Correctness (from acceptance passrate)
    if metrics.get('acceptance', {}).get('passrate') not in [None, "Unknown", ""]:
        passrate = metrics['acceptance']['passrate']
        if isinstance(passrate, (int, float)):
            scores['correctness_C'] = round(100 * passrate, 1)
        else:
            scores['correctness_C'] = "Unknown"
    else:
        scores['correctness_C'] = "Unknown"
    
    # R - Reproducibility (requires Run 2 comparison, placeholder)
    repro_rating = metrics.get('reproducibility_rating', "Unknown")
    if repro_rating == "None":
        scores['reproducibility_R'] = 100
    elif repro_rating == "Minor":
        scores['reproducibility_R'] = 80
    elif repro_rating == "Major":
        scores['reproducibility_R'] = 40
    else:
        scores['reproducibility_R'] = "Unknown"
    
    # D - Determinism (starts at 100, deducts for failures)
    determinism = metrics.get('determinism_compliance', "Unknown")
    if determinism == "Pass":
        scores['determinism_D'] = 100
    elif determinism == "Fail":
        # Could be more nuanced, but for now assume major failure
        scores['determinism_D'] = 0
    else:
        scores['determinism_D'] = "Unknown"
    
    # E - Operator Effort (starts at 100, deducts)
    effort = 100
    clarifications = metrics.get('clarifications_count', 0)
    interventions = metrics.get('interventions_count', 0)
    reruns = metrics.get('reruns_count', 0)
    
    if clarifications != "Unknown" and isinstance(clarifications, (int, float)):
        effort -= 3 * clarifications
    if interventions != "Unknown" and isinstance(interventions, (int, float)):
        effort -= 10 * interventions
    if reruns != "Unknown" and isinstance(reruns, (int, float)):
        effort -= 5 * reruns
    
    scores['effort_E'] = max(0, round(effort, 1)) if effort != "Unknown" else "Unknown"
    
    # S - Speed (requires cohort comparison, placeholder)
    scores['speed_S'] = "Unknown"
    
    # K - Contract/Docs
    contract_passrate = metrics.get('contract_completeness_passrate', "Unknown")
    instructions_quality = metrics.get('instructions_quality_rating', "Unknown")
    
    if contract_passrate not in [None, "Unknown", ""] and isinstance(contract_passrate, (int, float)):
        contract_score = 100 * contract_passrate
    else:
        contract_score = "Unknown"
    
    if instructions_quality not in [None, "Unknown", ""] and isinstance(instructions_quality, (int, float)):
        docs_score = instructions_quality
    else:
        docs_score = "Unknown"
    
    if contract_score != "Unknown" and docs_score != "Unknown":
        scores['contract_docs_K'] = round(0.7 * contract_score + 0.3 * docs_score, 1)
    else:
        scores['contract_docs_K'] = "Unknown"
    
    # P_O - Overreach penalty
    overreach_count = metrics.get('overreach_incidents_count', 0)
    if overreach_count != "Unknown" and isinstance(overreach_count, (int, float)):
        scores['penalty_overreach_PO'] = min(40, round(8 * overreach_count, 1))
    else:
        scores['penalty_overreach_PO'] = "Unknown"
    
    # Overall score (weighted sum minus penalty)
    # Weights from Benchmarking_Method.md (if available)
    # For now, simple average of known scores minus penalty
    known_scores = [v for v in scores.values() if isinstance(v, (int, float)) and v != "Unknown"]
    penalty = scores.get('penalty_overreach_PO', 0)
    if isinstance(penalty, str):
        penalty = 0
    
    if len(known_scores) >= 4:  # Require at least 4 known dimensions
        overall = (sum(known_scores) / len(known_scores)) - penalty
        scores['overall_score'] = max(0, min(100, round(overall, 1)))
    else:
        scores['overall_score'] = "Unknown"
    
    return scores


def calculate_speed_scores(results: List[dict]) -> None:
    """Calculate speed scores based on cohort comparison."""
    # Group by spec_version, model, api_type
    cohorts = defaultdict(list)
    
    for result in results:
        ri = result['result_data']['run_identity']
        key = (ri['spec_reference'], ri['target_model'], ri['api_style'])
        cohorts[key].append(result)
    
    # For each cohort, calculate speed scores
    for cohort_key, cohort_results in cohorts.items():
        # Collect TTFR and TTFC times
        ttfr_times = []
        ttfc_times = []
        
        for result in cohort_results:
            ttfr = result['result_data']['metrics']['ttfr'].get('minutes')
            ttfc = result['result_data']['metrics']['ttfc'].get('minutes')
            
            if ttfr not in [None, "Unknown"] and isinstance(ttfr, (int, float)):
                ttfr_times.append((result, ttfr))
            if ttfc not in [None, "Unknown"] and isinstance(ttfc, (int, float)):
                ttfc_times.append((result, ttfc))
        
        # Calculate scores (best = 100, worst = 0, linear interpolation)
        if len(ttfr_times) > 1:
            ttfr_values = [t[1] for t in ttfr_times]
            ttfr_min, ttfr_max = min(ttfr_values), max(ttfr_values)
            
            for result, ttfr in ttfr_times:
                if ttfr_max > ttfr_min:
                    ttfr_score = 100 * (1 - (ttfr - ttfr_min) / (ttfr_max - ttfr_min))
                else:
                    ttfr_score = 100
                
                # Store in result (we'll update scores later)
                result['_ttfr_score'] = round(ttfr_score, 1)
        
        if len(ttfc_times) > 1:
            ttfc_values = [t[1] for t in ttfc_times]
            ttfc_min, ttfc_max = min(ttfc_values), max(ttfc_values)
            
            for result, ttfc in ttfc_times:
                if ttfc_max > ttfc_min:
                    ttfc_score = 100 * (1 - (ttfc - ttfc_min) / (ttfc_max - ttfc_min))
                else:
                    ttfc_score = 100
                
                result['_ttfc_score'] = round(ttfc_score, 1)
        
        # Calculate combined speed score: S = 0.4 * TTFR + 0.6 * TTFC
        for result in cohort_results:
            if '_ttfr_score' in result and '_ttfc_score' in result:
                speed_score = 0.4 * result['_ttfr_score'] + 0.6 * result['_ttfc_score']
                result['result_data']['scores']['speed_S'] = round(speed_score, 1)


def group_results(results: List[dict]) -> Dict[Tuple[str, str, str], List[dict]]:
    """Group results by (spec_version, model, api_type)."""
    grouped = defaultdict(list)
    
    for result in results:
        ri = result['result_data']['run_identity']
        key = (ri['spec_reference'], ri['target_model'], ri['api_style'])
        grouped[key].append(result)
    
    return grouped


def generate_comparison_report(group_key: Tuple[str, str, str], group_results: List[dict], output_dir: Path) -> None:
    """Generate a comparison report for a group of results."""
    spec_ref, model, api_type = group_key
    
    # Group by tool (combine Run 1 and Run 2)
    tools = defaultdict(lambda: {'run1': None, 'run2': None})
    
    for result in group_results:
        ri = result['result_data']['run_identity']
        tool_key = f"{ri['tool_name']} {ri.get('tool_version', '')}".strip()
        run_num = ri['run_number']
        
        if run_num == 1:
            tools[tool_key]['run1'] = result
        elif run_num == 2:
            tools[tool_key]['run2'] = result
    
    # Generate report
    report_id = f"{spec_ref}-Model{model}-{api_type}-Comparison"
    report_path = output_dir / f"{report_id}.md"
    
    with open(report_path, 'w') as f:
        f.write(f"# Comparison Report: {report_id}\n\n")
        f.write(f"## Report Header\n\n")
        f.write(f"- **report_id**: {report_id}\n")
        f.write(f"- **spec_reference**: {spec_ref}\n")
        f.write(f"- **target_model**: {model}\n")
        f.write(f"- **evaluation_window**: {datetime.now().isoformat()}\n")
        f.write(f"- **tools_compared**: {', '.join(sorted(tools.keys()))}\n")
        f.write(f"- **notes**: Auto-generated comparison report\n\n")
        
        f.write("## Comparison Table\n\n")
        f.write("| Tool | Version | Model | Spec | TTFR R1 | TTFR R2 | TTFC R1 | TTFC R2 | ")
        f.write("C | R | D | E | S | K | P_O | Overall |\n")
        f.write("|------|---------|-------|------|---------|---------|---------|---------|")
        f.write("---|---|---|---|---|---|---|\n")
        
        for tool_name in sorted(tools.keys()):
            tool_data = tools[tool_name]
            run1 = tool_data['run1']
            run2 = tool_data['run2']
            
            # Extract values
            if run1:
                ri1 = run1['result_data']['run_identity']
                m1 = run1['result_data']['metrics']
                s1 = run1['result_data']['scores']
                ttfr_r1 = m1['ttfr'].get('minutes', 'Unknown')
                ttfc_r1 = m1['ttfc'].get('minutes', 'Unknown')
            else:
                ri1 = None
                ttfr_r1 = "N/A"
                ttfc_r1 = "N/A"
                s1 = {}
            
            if run2:
                ri2 = run2['result_data']['run_identity']
                m2 = run2['result_data']['metrics']
                s2 = run2['result_data']['scores']
                ttfr_r2 = m2['ttfr'].get('minutes', 'Unknown')
                ttfc_r2 = m2['ttfc'].get('minutes', 'Unknown')
            else:
                ri2 = None
                ttfr_r2 = "N/A"
                ttfc_r2 = "N/A"
                s2 = {}
            
            # Use run1 for tool info, or run2 if run1 missing
            ri = ri1 or ri2
            
            # Average scores (or use available)
            c = s1.get('correctness_C', s2.get('correctness_C', 'Unknown'))
            r = s1.get('reproducibility_R', s2.get('reproducibility_R', 'Unknown'))
            d = s1.get('determinism_D', s2.get('determinism_D', 'Unknown'))
            e = s1.get('effort_E', s2.get('effort_E', 'Unknown'))
            s = s1.get('speed_S', s2.get('speed_S', 'Unknown'))
            k = s1.get('contract_docs_K', s2.get('contract_docs_K', 'Unknown'))
            po = s1.get('penalty_overreach_PO', s2.get('penalty_overreach_PO', 'Unknown'))
            overall = s1.get('overall_score', s2.get('overall_score', 'Unknown'))
            
            f.write(f"| {ri['tool_name']} | {ri.get('tool_version', '')} | {ri['target_model']} | ")
            f.write(f"{ri['spec_reference']} | {ttfr_r1} | {ttfr_r2} | {ttfc_r1} | {ttfc_r2} | ")
            f.write(f"{c} | {r} | {d} | {e} | {s} | {k} | {po} | {overall} |\n")
        
        f.write("\n## Detailed Results\n\n")
        for tool_name in sorted(tools.keys()):
            tool_data = tools[tool_name]
            f.write(f"### {tool_name}\n\n")
            
            if tool_data['run1']:
                f.write(f"**Run 1**: {tool_data['run1']['_filename']}\n")
            if tool_data['run2']:
                f.write(f"**Run 2**: {tool_data['run2']['_filename']}\n")
            f.write("\n")
    
    print(f"✓ Generated comparison report: {report_path}")


def main():
    parser = argparse.ArgumentParser(description='Aggregate and compare benchmark results')
    parser.add_argument('--input-dir', default='results/submitted', help='Input directory')
    parser.add_argument('--output-dir', default='results/compiled', help='Output directory')
    parser.add_argument('--spec-version', help='Filter by spec version')
    
    args = parser.parse_args()
    
    # Resolve paths
    script_dir = Path(__file__).parent
    repo_root = script_dir.parent
    input_dir = repo_root / args.input_dir
    output_dir = repo_root / args.output_dir
    
    if not input_dir.exists():
        print(f"Error: Input directory does not exist: {input_dir}", file=sys.stderr)
        sys.exit(1)
    
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Load schema
    schema_path = repo_root / 'results/schemas/result-schema-v1.0.json'
    schema = None
    if schema_path.exists():
        schema = load_schema(schema_path)
    else:
        print("Warning: Schema file not found, skipping validation", file=sys.stderr)
    
    # Find all result files
    result_files = list(input_dir.glob('*.json'))
    
    if not result_files:
        print(f"No result files found in {input_dir}", file=sys.stderr)
        sys.exit(0)
    
    print(f"Found {len(result_files)} result file(s)")
    
    # Parse results
    results = []
    for result_file in result_files:
        result = parse_result_file(result_file, schema)
        if result:
            # Filter by spec version if specified
            if args.spec_version:
                if result['result_data']['run_identity']['spec_reference'] != args.spec_version:
                    continue
            
            # Calculate scores
            scores = calculate_scores(result['result_data']['metrics'])
            result['result_data']['scores'].update(scores)
            results.append(result)
    
    if not results:
        print("No valid results to aggregate", file=sys.stderr)
        sys.exit(0)
    
    # Calculate speed scores (cohort-based)
    calculate_speed_scores(results)
    
    # Group results
    grouped = group_results(results)
    
    # Generate comparison reports
    for group_key, group_results_list in grouped.items():
        generate_comparison_report(group_key, group_results_list, output_dir)
    
    print(f"\n✓ Aggregation complete. Reports in: {output_dir}")


if __name__ == '__main__':
    main()

