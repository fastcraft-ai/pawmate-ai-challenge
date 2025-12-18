# Results Directory

This directory contains benchmark results submitted by developers and AI tools, along with automatically generated comparison reports.

## Structure

```
results/
├── submitted/          # Submitted result files (one per run)
├── compiled/          # Auto-generated comparison reports
└── schemas/           # JSON schemas for validation
```

## Submitted Results

The `submitted/` directory contains standardized result files from completed benchmark runs.

**Naming Convention**: `{tool-slug}_{model}_{api-type}_{run-number}_{timestamp}.json`

Example: `cursor-v0-43_modelA_REST_run1_20241218T1430.json`

Each result file:
- Contains structured JSON data
- Must be valid JSON that passes schema validation
- Must pass validation before being accepted
- See `docs/Result_File_Spec.md` for complete specification

## Compiled Reports

The `compiled/` directory contains automatically generated comparison reports that aggregate results by:
- Spec version
- Target model (A or B)
- API style (REST or GraphQL)

Reports are generated automatically when new results are merged to the main branch.

## Submission Process

1. **Generate result file**: `./scripts/generate_result_file.sh --run-dir runs/YYYYMMDDTHHmm`
2. **Complete metrics**: Fill in acceptance results, scores, etc.
3. **Validate**: `./scripts/validate_result.sh results/submitted/your-file.md`
4. **Submit**: Commit and create a pull request

See `docs/Submitting_Results.md` for detailed instructions.

## Validation

All result files are automatically validated:
- **On PR**: GitHub Actions validates file format and schema
- **Before merge**: Validation must pass
- **After merge**: Results are automatically compiled into comparison reports

## Dashboard

Generate an interactive HTML dashboard:

```bash
python3 scripts/generate_dashboard.py
```

Output: `results/compiled/dashboard.html`

The dashboard can be hosted via GitHub Pages or any static file server.

## Related Documentation

- `docs/Result_File_Spec.md` - Result file specification
- `docs/Submitting_Results.md` - Submission guide
- `docs/Scoring_Rubric.md` - Score calculation rules
- `docs/Comparison_Report_Template.md` - Comparison report format

