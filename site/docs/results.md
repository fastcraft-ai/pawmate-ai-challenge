# View Results

Explore benchmark results and leaderboards.

## Results Repository

All submitted results are published in the public results repository:

**GitHub:** [github.com/fastcraft-ai/pawmate-ai-results](https://github.com/fastcraft-ai/pawmate-ai-results)

## What's Available

### Individual Result Files

Every submitted benchmark result as JSON:

```
results/submitted/
├── cursor-v0-43_modelA_REST_run1_20260103T1413.json
├── copilot_modelA_REST_run1_20260103T1520.json
├── codeium_modelB_GraphQL_run1_20260103T1630.json
└── ...
```

Each file contains:
- Tool name and version
- Complete timing metrics
- Build and test status
- LLM usage data
- Intervention counts

### Aggregated Reports

Comparison reports showing:
- Performance across tools
- Model A vs Model B completion rates
- REST vs GraphQL comparisons
- Trending data over time

### Leaderboards

Rankings by:
- Fastest time to completion
- Highest test pass rates
- Lowest intervention counts
- Most autonomous completions

## Result File Format

Example result file structure:

```json
{
  "schema_version": "3.0",
  "result_data": {
    "run_identity": {
      "tool_name": "Cursor",
      "tool_version": "v0.43",
      "target_model": "A",
      "api_style": "REST",
      "run_number": 1,
      "timestamp": "2026-01-03T14:13:20Z",
      "operator_name": "anonymous"
    },
    "timing_metrics": {
      "generation_started": "2026-01-03T14:13:20.000Z",
      "code_complete": "2026-01-03T14:25:45.000Z",
      "build_clean": "2026-01-03T14:27:30.000Z",
      "seed_loaded": "2026-01-03T14:28:00.000Z",
      "app_started": "2026-01-03T14:28:15.000Z",
      "all_tests_pass": "2026-01-03T14:35:45.000Z"
    },
    "build_status": {
      "build_success": true,
      "tests_pass": true,
      "app_started": true
    },
    "intervention_metrics": {
      "clarifications_count": 0,
      "interventions_count": 2,
      "reruns_count": 0
    },
    "llm_usage": {
      "model_used": "claude-sonnet-4.5",
      "total_tokens": 125000,
      "input_tokens": 80000,
      "output_tokens": 45000,
      "requests_count": 45,
      "estimated_cost_usd": 1.25
    }
  }
}
```

## Key Metrics Explained

### Timing Metrics

**Time to First Code (TTFC):**
```
code_complete - generation_started
```
How long until all code files are written.

**Time to Build:**
```
build_clean - code_complete
```
How long to resolve dependencies and build successfully.

**Time to Running:**
```
app_started - generation_started
```
Total time from start to API responding.

**Time to Tests Pass:**
```
all_tests_pass - generation_started
```
Total time to achieve 100% test pass rate.

### Intervention Metrics

**Clarifications:**
Number of times the AI asked questions requiring operator input.
- Ideal: 0
- Good: 1-2
- Needs improvement: 3+

**Interventions:**
Number of times operator sent "continue", provided error messages, or manually edited code.
- Ideal: 0
- Good: 1-5
- Needs improvement: 6+

**Reruns:**
Number of times the entire prompt was re-issued.
- Ideal: 0
- Acceptable: 1
- Problematic: 2+

### Build Status

Binary success indicators:
- `build_success` - Did `npm install` complete?
- `tests_pass` - Did all tests pass?
- `app_started` - Did the API start and respond?
- `ui_build_success` - Did the UI build (if attempted)?
- `ui_running` - Is the UI accessible (if attempted)?

### LLM Usage

Token consumption and costs:
- `total_tokens` - Sum of input and output tokens
- `requests_count` - Number of API calls made
- `estimated_cost_usd` - Approximate cost (if available)

**Note:** LLM usage varies significantly based on:
- Tool's model selection
- Context window usage
- Retry strategies
- Code generation approach

## Leaderboards

### Fastest Completion (Model A - REST)

| Rank | Tool | Version | Time to Tests Pass | Date |
|------|------|---------|-------------------|------|
| 1 | TBD | - | - | - |
| 2 | TBD | - | - | - |
| 3 | TBD | - | - | - |

### Most Autonomous (Model A - REST)

| Rank | Tool | Version | Intervention Count | Date |
|------|------|---------|-------------------|------|
| 1 | TBD | - | - | - |
| 2 | TBD | - | - | - |
| 3 | TBD | - | - | - |

### Highest Success Rate

| Tool | Version | Runs | Success Rate | Avg Time |
|------|---------|------|--------------|----------|
| TBD | - | - | - | - |

*Leaderboards updated as results are submitted*

## Comparative Analysis

### Model A vs Model B

Performance comparison across complexity levels:

| Metric | Model A Avg | Model B Avg | Increase |
|--------|-------------|-------------|----------|
| Completion Time | TBD | TBD | TBD |
| Test Iterations | TBD | TBD | TBD |
| Intervention Count | TBD | TBD | TBD |
| Success Rate | TBD | TBD | TBD |

### REST vs GraphQL

API style comparison:

| Metric | REST Avg | GraphQL Avg | Difference |
|--------|----------|-------------|------------|
| Completion Time | TBD | TBD | TBD |
| Build Success | TBD | TBD | TBD |
| Test Pass Rate | TBD | TBD | TBD |

### Tool Comparison

Cross-tool performance:

| Tool | Avg Time | Success Rate | Avg Interventions |
|------|----------|--------------|-------------------|
| TBD | - | - | - |

## Submission Timeline

Results typically appear within:

- **GitHub Issues:** Immediate (pending review)
- **Email Submissions:** 24-48 hours
- **Leaderboard Updates:** Weekly
- **Aggregated Reports:** Monthly

## Data Quality

All results undergo validation:

1. **Schema Validation** - Correct format and required fields
2. **Timestamp Verification** - Logical ordering and format
3. **Metadata Check** - Tool, version, profile consistency
4. **Manual Review** - Spot checks for anomalies

Invalid or suspicious submissions may be flagged for review.

## Privacy

**Public Data:**
- Tool name and version
- Timing and performance metrics
- Build/test status
- Intervention counts
- Attribution (if provided)

**Private Data:**
- Email addresses
- Implementation source code
- Personal information

## Contributing Results

Help build the dataset:

1. **Run benchmarks** with different tools
2. **Submit all results** (successes and failures)
3. **Use multiple profiles** for comprehensive data
4. **Update tools** and rerun for version comparisons

[Get started running benchmarks →](/getting-started)

## Viewing Raw Data

Browse all results:

```bash
# Clone the results repository
git clone https://github.com/fastcraft-ai/pawmate-ai-results.git
cd pawmate-ai-results

# View submitted results
ls results/submitted/

# Read a result file
cat results/submitted/cursor_modelA_REST_run1_20260103T1413.json | jq
```

## Aggregation Scripts

The results repository includes scripts for analyzing data:

```bash
# Aggregate results
python scripts/aggregate_results.py

# Generate dashboard
python scripts/generate_dashboard.py

# Validate a result
python scripts/validate-result-v3.py results/submitted/your-result.json
```

## API Access (Future)

Planned features:
- REST API for querying results
- JSON export of leaderboards
- Webhook notifications for new submissions
- Grafana/dashboard integration

## Questions About Results?

- [Submit your own results](/submit-results)
- [View the repository](https://github.com/fastcraft-ai/pawmate-ai-results)
- [Open an issue](https://github.com/fastcraft-ai/pawmate-ai-results/issues)
- Email: pawmate.ai.challenge@gmail.com

