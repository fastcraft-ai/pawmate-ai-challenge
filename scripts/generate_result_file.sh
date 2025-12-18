#!/usr/bin/env bash
#
# generate_result_file.sh — Generate standardized result file from run directory
#
# Usage:
#   ./scripts/generate_result_file.sh --run-dir <run-directory> [--output-dir <output-dir>]
#
# Options:
#   --run-dir <path>      Required. Path to run directory (e.g., runs/20241218T1430)
#   --output-dir <path>   Optional. Output directory (default: results/submitted/)
#   --help                Show this help message
#

set -euo pipefail

# Resolve script and repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Defaults
RUN_DIR=""
OUTPUT_DIR="$REPO_ROOT/results/submitted"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --run-dir)
            RUN_DIR="$2"
            shift 2
            ;;
        --output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            sed -n '2,/^$/p' "$0" | grep '^#' | sed 's/^# \?//'
            exit 0
            ;;
        *)
            echo "Error: Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$RUN_DIR" ]]; then
    echo "Error: --run-dir is required" >&2
    exit 1
fi

# Resolve absolute paths
RUN_DIR="$(cd "$RUN_DIR" && pwd)"
OUTPUT_DIR="$(mkdir -p "$OUTPUT_DIR" && cd "$OUTPUT_DIR" && pwd)"

# Check run directory exists
if [[ ! -d "$RUN_DIR" ]]; then
    echo "Error: Run directory does not exist: $RUN_DIR" >&2
    exit 1
fi

# Check run.config exists
RUN_CONFIG="$RUN_DIR/run.config"
if [[ ! -f "$RUN_CONFIG" ]]; then
    echo "Error: run.config not found in run directory: $RUN_CONFIG" >&2
    exit 1
fi

# Source run.config
# shellcheck disable=SC1090
source "$RUN_CONFIG"

# Validate required config values
REQUIRED_VARS=("spec_version" "tool" "model" "api_type" "workspace")
for var in "${REQUIRED_VARS[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        echo "Error: Required config value missing: $var" >&2
        exit 1
    fi
done

# Generate tool slug (lowercase, alphanumeric + hyphens)
TOOL_SLUG=$(echo "$tool" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')

# Determine run number from run_id or default to 1
RUN_NUMBER=1
if [[ -n "${run_id:-}" ]]; then
    if echo "$run_id" | grep -qi "run2\|run-2"; then
        RUN_NUMBER=2
    fi
fi

# Generate timestamp from run directory name or current time
RUN_DIR_NAME=$(basename "$RUN_DIR")
TIMESTAMP=""
if [[ "$RUN_DIR_NAME" =~ ^[0-9]{8}T[0-9]{4}$ ]]; then
    TIMESTAMP="$RUN_DIR_NAME"
else
    TIMESTAMP=$(date +%Y%m%dT%H%M)
fi

# Generate output filename
MODEL_STR="model${model}"
API_STR="$api_type"
RUN_STR="run${RUN_NUMBER}"
OUTPUT_FILENAME="${TOOL_SLUG}_${MODEL_STR}_${API_STR}_${RUN_STR}_${TIMESTAMP}.json"
OUTPUT_PATH="$OUTPUT_DIR/$OUTPUT_FILENAME"

# Get current timestamp for submission
SUBMITTED_TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%S.000Z)

# Try to detect submission method (check if AI run report exists)
SUBMISSION_METHOD="manual"
AI_RUN_REPORT="$workspace/benchmark/ai_run_report.md"
if [[ -f "$AI_RUN_REPORT" ]]; then
    SUBMISSION_METHOD="automated"
fi

# Try to get submitter info
SUBMITTED_BY="${USER:-unknown}"
if command -v git &> /dev/null && git -C "$REPO_ROOT" rev-parse --git-dir &> /dev/null; then
    GIT_USER=$(git -C "$REPO_ROOT" config user.name 2>/dev/null || echo "")
    if [[ -n "$GIT_USER" ]]; then
        SUBMITTED_BY="$GIT_USER"
    fi
fi

# Try to extract metrics from AI run report if it exists
TTFR_START=""
TTFR_END=""
TTFR_MINUTES="Unknown"
TTFC_START=""
TTFC_END=""
TTFC_MINUTES="Unknown"
CLARIFICATIONS_COUNT="Unknown"
INTERVENTIONS_COUNT="Unknown"
RERUNS_COUNT="Unknown"
ACCEPTANCE_PASS_COUNT="Unknown"
ACCEPTANCE_FAIL_COUNT="Unknown"
ACCEPTANCE_NOT_RUN_COUNT="Unknown"
ACCEPTANCE_PASSRATE="Unknown"
DETERMINISM_COMPLIANCE="Unknown"
OVERREACH_INCIDENTS_COUNT="Unknown"
CONTRACT_COMPLETENESS_PASSRATE="Unknown"
INSTRUCTIONS_QUALITY_RATING="Unknown"
REPRODUCIBILITY_RATING="Unknown"

if [[ -f "$AI_RUN_REPORT" ]]; then
    # Extract timestamps from AI run report
    if grep -q "generation_started:" "$AI_RUN_REPORT"; then
        TTFR_START=$(grep "generation_started:" "$AI_RUN_REPORT" | head -1 | sed 's/.*generation_started: *//' | tr -d '[:space:]')
        TTFC_START="$TTFR_START"
    fi
    
    if grep -q "first_runnable:" "$AI_RUN_REPORT"; then
        TTFR_END=$(grep "first_runnable:" "$AI_RUN_REPORT" | head -1 | sed 's/.*first_runnable: *//' | tr -d '[:space:]')
    fi
    
    if grep -q "feature_complete:" "$AI_RUN_REPORT"; then
        TTFC_END=$(grep "feature_complete:" "$AI_RUN_REPORT" | head -1 | sed 's/.*feature_complete: *//' | tr -d '[:space:]')
    fi
    
    # Calculate minutes if we have both timestamps
    if [[ -n "$TTFR_START" && -n "$TTFR_END" ]]; then
        if command -v python3 &> /dev/null; then
            TTFR_MINUTES=$(python3 -c "
from datetime import datetime
start = datetime.fromisoformat('${TTFR_START}'.replace('Z', '+00:00'))
end = datetime.fromisoformat('${TTFR_END}'.replace('Z', '+00:00'))
print(round((end - start).total_seconds() / 60, 1))
" 2>/dev/null || echo "Unknown")
        fi
    fi
    
    if [[ -n "$TTFC_START" && -n "$TTFC_END" ]]; then
        if command -v python3 &> /dev/null; then
            TTFC_MINUTES=$(python3 -c "
from datetime import datetime
start = datetime.fromisoformat('${TTFC_START}'.replace('Z', '+00:00'))
end = datetime.fromisoformat('${TTFC_END}'.replace('Z', '+00:00'))
print(round((end - start).total_seconds() / 60, 1))
" 2>/dev/null || echo "Unknown")
        fi
    fi
fi

# Get run environment
RUN_ENV="${run_environment:-$(uname -s) $(uname -r)}"

# Generate run_id if not set
RUN_ID="${run_id:-${tool// /-}-Model${model}-$(basename "$RUN_DIR")}"

# Determine artifact paths (relative to repo root)
WORKSPACE_REL=$(realpath --relative-to="$REPO_ROOT" "$workspace" 2>/dev/null || echo "$workspace")
TOOL_TRANSCRIPT_PATH=""
RUN_INSTRUCTIONS_PATH=""
CONTRACT_ARTIFACT_PATH=""
ACCEPTANCE_CHECKLIST_PATH=""
ACCEPTANCE_EVIDENCE_PATH=""
DETERMINISM_EVIDENCE_PATH=""
OVERREACH_EVIDENCE_PATH=""
AUTOMATED_TESTS_PATH=""

# Find artifacts
if [[ -f "$RUN_DIR/transcript.md" ]]; then
    TOOL_TRANSCRIPT_PATH=$(realpath --relative-to="$REPO_ROOT" "$RUN_DIR/transcript.md" 2>/dev/null || echo "$RUN_DIR/transcript.md")
fi

if [[ -f "$workspace/benchmark/run_instructions.md" ]]; then
    RUN_INSTRUCTIONS_PATH=$(realpath --relative-to="$REPO_ROOT" "$workspace/benchmark/run_instructions.md" 2>/dev/null || echo "$workspace/benchmark/run_instructions.md")
fi

if [[ "$api_type" == "REST" ]]; then
    for file in "$workspace"/*.yaml "$workspace"/*.yml "$workspace"/openapi.* "$workspace"/api.*; do
        if [[ -f "$file" ]]; then
            CONTRACT_ARTIFACT_PATH=$(realpath --relative-to="$REPO_ROOT" "$file" 2>/dev/null || echo "$file")
            break
        fi
    done
else
    for file in "$workspace"/*.graphql "$workspace"/schema.*; do
        if [[ -f "$file" ]]; then
            CONTRACT_ARTIFACT_PATH=$(realpath --relative-to="$REPO_ROOT" "$file" 2>/dev/null || echo "$file")
            break
        fi
    done
fi

if [[ -f "$workspace/benchmark/acceptance_checklist.md" ]]; then
    ACCEPTANCE_CHECKLIST_PATH=$(realpath --relative-to="$REPO_ROOT" "$workspace/benchmark/acceptance_checklist.md" 2>/dev/null || echo "$workspace/benchmark/acceptance_checklist.md")
fi

if [[ -d "$RUN_DIR/acceptance_evidence" ]]; then
    ACCEPTANCE_EVIDENCE_PATH=$(realpath --relative-to="$REPO_ROOT" "$RUN_DIR/acceptance_evidence" 2>/dev/null || echo "$RUN_DIR/acceptance_evidence")
fi

if [[ -f "$RUN_DIR/determinism_evidence.md" ]] || [[ -d "$RUN_DIR/determinism_evidence" ]]; then
    DETERMINISM_EVIDENCE_PATH=$(realpath --relative-to="$REPO_ROOT" "$RUN_DIR/determinism_evidence.md" 2>/dev/null || realpath --relative-to="$REPO_ROOT" "$RUN_DIR/determinism_evidence" 2>/dev/null || echo "$RUN_DIR/determinism_evidence")
fi

if [[ -f "$RUN_DIR/overreach_notes.md" ]]; then
    OVERREACH_EVIDENCE_PATH=$(realpath --relative-to="$REPO_ROOT" "$RUN_DIR/overreach_notes.md" 2>/dev/null || echo "$RUN_DIR/overreach_notes.md")
fi

if [[ -d "$workspace/tests" ]]; then
    AUTOMATED_TESTS_PATH=$(realpath --relative-to="$REPO_ROOT" "$workspace/tests" 2>/dev/null || echo "$workspace/tests")
fi

# Generate result file as JSON
# Create a temporary Python script to handle JSON generation properly
TEMP_SCRIPT=$(mktemp)
cat > "$TEMP_SCRIPT" <<'PYTHON_EOF'
import json
import sys

def json_value(val):
    """Convert value to appropriate JSON type, handling 'Unknown'."""
    if val == "Unknown" or val == "":
        return "Unknown"
    try:
        if '.' in str(val):
            return float(val)
        return int(val)
    except (ValueError, TypeError):
        return str(val) if val else "Unknown"

# Read values from command line args
args = sys.argv[1:]
i = 0

result = {
    "schema_version": "1.0",
    "result_data": {
        "run_identity": {
            "tool_name": args[i],
            "tool_version": args[i+1],
            "run_id": args[i+2],
            "run_number": int(args[i+3]),
            "target_model": args[i+4],
            "api_style": args[i+5],
            "spec_reference": args[i+6],
            "workspace_path": args[i+7],
            "run_environment": args[i+8]
        },
        "metrics": {
            "ttfr": {
                "start_timestamp": args[i+9] or "",
                "end_timestamp": args[i+10] or "",
                "minutes": json_value(args[i+11])
            },
            "ttfc": {
                "start_timestamp": args[i+12] or "",
                "end_timestamp": args[i+13] or "",
                "minutes": json_value(args[i+14])
            },
            "clarifications_count": json_value(args[i+15]),
            "interventions_count": json_value(args[i+16]),
            "reruns_count": json_value(args[i+17]),
            "acceptance": {
                "model": args[i+4],  # Same as target_model
                "pass_count": json_value(args[i+18]),
                "fail_count": json_value(args[i+19]),
                "not_run_count": json_value(args[i+20]),
                "passrate": json_value(args[i+21])
            },
            "determinism_compliance": args[i+22],
            "overreach_incidents_count": json_value(args[i+23]),
            "contract_completeness_passrate": json_value(args[i+24]),
            "instructions_quality_rating": json_value(args[i+25]),
            "reproducibility_rating": args[i+26]
        },
        "scores": {
            "correctness_C": "Unknown",
            "reproducibility_R": "Unknown",
            "determinism_D": "Unknown",
            "effort_E": "Unknown",
            "speed_S": "Unknown",
            "contract_docs_K": "Unknown",
            "penalty_overreach_PO": "Unknown",
            "overall_score": "Unknown"
        },
        "artifacts": {
            "tool_transcript_path": args[i+27],
            "run_instructions_path": args[i+28],
            "contract_artifact_path": args[i+29],
            "acceptance_checklist_path": args[i+30],
            "acceptance_evidence_path": args[i+31],
            "determinism_evidence_path": args[i+32],
            "overreach_evidence_path": args[i+33],
            "ai_run_report_path": args[i+34],
            "automated_tests_path": args[i+35]
        },
        "submission": {
            "submitted_timestamp": args[i+36],
            "submitted_by": args[i+37],
            "submission_method": args[i+38]
        }
    }
}

print(json.dumps(result, indent=2, ensure_ascii=False))
PYTHON_EOF

# Call Python script with all values as arguments
python3 "$TEMP_SCRIPT" \
    "$tool" \
    "${tool_ver:-}" \
    "$RUN_ID" \
    "$RUN_NUMBER" \
    "$model" \
    "$api_type" \
    "$spec_version" \
    "$WORKSPACE_REL" \
    "$RUN_ENV" \
    "${TTFR_START:-}" \
    "${TTFR_END:-}" \
    "$TTFR_MINUTES" \
    "${TTFC_START:-}" \
    "${TTFC_END:-}" \
    "$TTFC_MINUTES" \
    "$CLARIFICATIONS_COUNT" \
    "$INTERVENTIONS_COUNT" \
    "$RERUNS_COUNT" \
    "$ACCEPTANCE_PASS_COUNT" \
    "$ACCEPTANCE_FAIL_COUNT" \
    "$ACCEPTANCE_NOT_RUN_COUNT" \
    "$ACCEPTANCE_PASSRATE" \
    "$DETERMINISM_COMPLIANCE" \
    "$OVERREACH_INCIDENTS_COUNT" \
    "$CONTRACT_COMPLETENESS_PASSRATE" \
    "$INSTRUCTIONS_QUALITY_RATING" \
    "$REPRODUCIBILITY_RATING" \
    "$TOOL_TRANSCRIPT_PATH" \
    "$RUN_INSTRUCTIONS_PATH" \
    "$CONTRACT_ARTIFACT_PATH" \
    "$ACCEPTANCE_CHECKLIST_PATH" \
    "$ACCEPTANCE_EVIDENCE_PATH" \
    "$DETERMINISM_EVIDENCE_PATH" \
    "$OVERREACH_EVIDENCE_PATH" \
    "${WORKSPACE_REL}/benchmark/ai_run_report.md" \
    "$AUTOMATED_TESTS_PATH" \
    "$SUBMITTED_TIMESTAMP" \
    "$SUBMITTED_BY" \
    "$SUBMISSION_METHOD" > "$OUTPUT_PATH"

# Clean up temp script
rm -f "$TEMP_SCRIPT"

echo "✓ Result file generated: $OUTPUT_PATH"
echo ""
echo "Next steps:"
echo "  1. Review and complete any placeholder values"
echo "  2. Validate the file: ./scripts/validate_result.sh $OUTPUT_PATH"
echo "  3. Submit via git: git add $OUTPUT_PATH && git commit -m 'Add result: ${OUTPUT_FILENAME}'"

