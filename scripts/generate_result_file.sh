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

# Extract metrics from AI run report if it exists
GENERATION_STARTED=""
CODE_COMPLETE=""
BUILD_CLEAN=""
SEED_LOADED=""
APP_STARTED=""
ALL_TESTS_PASS=""
TOTAL_MINUTES=""
TEST_TOTAL=""
TEST_PASSED=""
TEST_FAILED=""
TEST_PASS_RATE=""
BACKEND_RUNTIME=""
BACKEND_FRAMEWORK=""
DATABASE=""

if [[ -f "$AI_RUN_REPORT" ]]; then
    # Extract all timestamps from AI run report (handle markdown backticks and list format)
    # Pattern: - `field_name`: timestamp (need to match first colon after field name)
    if grep -q "generation_started" "$AI_RUN_REPORT"; then
        GENERATION_STARTED=$(grep "generation_started" "$AI_RUN_REPORT" | head -1 | sed 's/.*`generation_started`: *//' | sed 's/`//g' | sed 's/ (.*//' | tr -d '[:space:]')
    fi
    
    if grep -q "code_complete" "$AI_RUN_REPORT"; then
        CODE_COMPLETE=$(grep "code_complete" "$AI_RUN_REPORT" | head -1 | sed 's/.*`code_complete`: *//' | sed 's/`//g' | sed 's/ (.*//' | tr -d '[:space:]')
    fi
    
    if grep -q "build_clean" "$AI_RUN_REPORT"; then
        BUILD_CLEAN=$(grep "build_clean" "$AI_RUN_REPORT" | head -1 | sed 's/.*`build_clean`: *//' | sed 's/`//g' | sed 's/ (.*//' | tr -d '[:space:]')
    fi
    
    if grep -q "seed_loaded" "$AI_RUN_REPORT"; then
        SEED_LOADED=$(grep "seed_loaded" "$AI_RUN_REPORT" | head -1 | sed 's/.*`seed_loaded`: *//' | sed 's/`//g' | sed 's/ (.*//' | tr -d '[:space:]')
    fi
    
    if grep -q "app_started" "$AI_RUN_REPORT"; then
        APP_STARTED=$(grep "app_started" "$AI_RUN_REPORT" | head -1 | sed 's/.*`app_started`: *//' | sed 's/`//g' | sed 's/ (.*//' | tr -d '[:space:]')
    fi
    
    if grep -q "all_tests_pass" "$AI_RUN_REPORT"; then
        ALL_TESTS_PASS=$(grep "all_tests_pass" "$AI_RUN_REPORT" | head -1 | sed 's/.*`all_tests_pass`: *//' | sed 's/`//g' | sed 's/ (.*//' | tr -d '[:space:]')
    fi
    
    # Calculate total minutes from generation_started to all_tests_pass
    if [[ -n "$GENERATION_STARTED" && -n "$ALL_TESTS_PASS" ]]; then
        if command -v python3 &> /dev/null; then
            TOTAL_MINUTES=$(python3 -c "
from datetime import datetime
start = datetime.fromisoformat('${GENERATION_STARTED}'.replace('Z', '+00:00'))
end = datetime.fromisoformat('${ALL_TESTS_PASS}'.replace('Z', '+00:00'))
print(round((end - start).total_seconds() / 60, 1))
" 2>/dev/null || echo "")
        fi
    fi
    
    # Extract test results (handle markdown formatting with **bold**)
    if grep -q "\*\*Total Tests\*\*" "$AI_RUN_REPORT"; then
        TEST_TOTAL=$(grep "\*\*Total Tests\*\*" "$AI_RUN_REPORT" | head -1 | sed 's/.*\*\*Total Tests\*\*: *//' | sed 's/\*\*//g' | tr -d '[:space:]')
    fi
    
    if grep -q "\*\*Passed\*\*" "$AI_RUN_REPORT"; then
        TEST_PASSED=$(grep "\*\*Passed\*\*" "$AI_RUN_REPORT" | head -1 | sed 's/.*\*\*Passed\*\*: *//' | sed 's/\*\*//g' | tr -d '[:space:]')
    fi
    
    if grep -q "\*\*Failed\*\*" "$AI_RUN_REPORT"; then
        TEST_FAILED=$(grep "\*\*Failed\*\*" "$AI_RUN_REPORT" | head -1 | sed 's/.*\*\*Failed\*\*: *//' | sed 's/\*\*//g' | tr -d '[:space:]')
    fi
    
    if grep -q "\*\*Pass Rate\*\*" "$AI_RUN_REPORT"; then
        TEST_PASS_RATE=$(grep "\*\*Pass Rate\*\*" "$AI_RUN_REPORT" | head -1 | sed 's/.*\*\*Pass Rate\*\*: *//' | sed 's/%//' | sed 's/\*\*//g' | tr -d '[:space:]')
    fi
    
    # Extract tech stack
    if grep -q "Backend Runtime" "$AI_RUN_REPORT"; then
        BACKEND_RUNTIME=$(grep "Backend Runtime" "$AI_RUN_REPORT" | head -1 | sed 's/.*Backend Runtime.*: *//' | sed 's/\*\*//g' | tr -d '[:space:]')
    fi
    
    if grep -q "Backend Framework" "$AI_RUN_REPORT"; then
        BACKEND_FRAMEWORK=$(grep "Backend Framework" "$AI_RUN_REPORT" | head -1 | sed 's/.*Backend Framework.*: *//' | sed 's/\*\*//g' | tr -d '[:space:]')
    fi
    
    if grep -q "Database:" "$AI_RUN_REPORT"; then
        DATABASE=$(grep "Database:" "$AI_RUN_REPORT" | head -1 | sed 's/.*Database: *//' | sed 's/\*\*//g' | tr -d '[:space:]')
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
    # Check backend directory first, then workspace root
    for file in "$workspace/backend/openapi.yaml" "$workspace/backend/openapi.yml" "$workspace"/*.yaml "$workspace"/*.yml "$workspace"/openapi.* "$workspace"/api.*; do
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

# Check for tests in backend/src/tests or workspace/tests
if [[ -d "$workspace/backend/src/tests" ]]; then
    AUTOMATED_TESTS_PATH=$(realpath --relative-to="$REPO_ROOT" "$workspace/backend/src/tests" 2>/dev/null || echo "$workspace/backend/src/tests")
elif [[ -d "$workspace/tests" ]]; then
    AUTOMATED_TESTS_PATH=$(realpath --relative-to="$REPO_ROOT" "$workspace/tests" 2>/dev/null || echo "$workspace/tests")
fi

# Generate result file as JSON - simplified minimal format
TEMP_SCRIPT=$(mktemp)
cat > "$TEMP_SCRIPT" <<'PYTHON_EOF'
import json
import sys
from datetime import datetime

def to_num(val):
    """Convert value to number if possible, else return as string."""
    if not val or val == "":
        return None
    try:
        if '.' in str(val):
            return float(val)
        return int(val)
    except (ValueError, TypeError):
        return val

# Read values from command line args
args = sys.argv[1:]
i = 0

# Build minimal result structure
result = {
    "run_info": {
        "tool": args[i],
        "version": args[i+1] or "",
        "run_id": args[i+2],
        "model": args[i+3],
        "api_style": args[i+4],
        "spec_version": args[i+5]
    },
    "timings": {},
    "test_results": {},
    "environment": {
        "os": args[i+6]
    },
    "artifacts": {}
}

# Add timings (only if they exist)
if args[i+7]: result["timings"]["generation_started"] = args[i+7]
if args[i+8]: result["timings"]["code_complete"] = args[i+8]
if args[i+9]: result["timings"]["build_clean"] = args[i+9]
if args[i+10]: result["timings"]["seed_loaded"] = args[i+10]
if args[i+11]: result["timings"]["app_started"] = args[i+11]
if args[i+12]: result["timings"]["all_tests_pass"] = args[i+12]
if args[i+13]: result["timings"]["total_minutes"] = to_num(args[i+13])

# Add test results (only if they exist)
if args[i+14]: result["test_results"]["total"] = to_num(args[i+14])
if args[i+15]: result["test_results"]["passed"] = to_num(args[i+15])
if args[i+16]: result["test_results"]["failed"] = to_num(args[i+16])
if args[i+17]: result["test_results"]["pass_rate"] = to_num(args[i+17])

# Add tech stack to environment (only if they exist)
if args[i+18]: result["environment"]["backend_runtime"] = args[i+18]
if args[i+19]: result["environment"]["backend_framework"] = args[i+19]
if args[i+20]: result["environment"]["database"] = args[i+20]

# Add artifacts (only if they exist)
if args[i+21]: result["artifacts"]["ai_run_report"] = args[i+21]
if args[i+22]: result["artifacts"]["openapi_contract"] = args[i+22]
if args[i+23]: result["artifacts"]["run_instructions"] = args[i+23]
if args[i+24]: result["artifacts"]["acceptance_checklist"] = args[i+24]

# Remove empty sections
if not result["timings"]:
    del result["timings"]
if not result["test_results"]:
    del result["test_results"]
if not result["artifacts"]:
    del result["artifacts"]

print(json.dumps(result, indent=2, ensure_ascii=False))
PYTHON_EOF

# Call Python script with simplified arguments
python3 "$TEMP_SCRIPT" \
    "$tool" \
    "${tool_ver:-}" \
    "$RUN_ID" \
    "$model" \
    "$api_type" \
    "$spec_version" \
    "$RUN_ENV" \
    "${GENERATION_STARTED:-}" \
    "${CODE_COMPLETE:-}" \
    "${BUILD_CLEAN:-}" \
    "${SEED_LOADED:-}" \
    "${APP_STARTED:-}" \
    "${ALL_TESTS_PASS:-}" \
    "${TOTAL_MINUTES:-}" \
    "${TEST_TOTAL:-}" \
    "${TEST_PASSED:-}" \
    "${TEST_FAILED:-}" \
    "${TEST_PASS_RATE:-}" \
    "${BACKEND_RUNTIME:-}" \
    "${BACKEND_FRAMEWORK:-}" \
    "${DATABASE:-}" \
    "${WORKSPACE_REL}/benchmark/ai_run_report.md" \
    "${CONTRACT_ARTIFACT_PATH:-}" \
    "${RUN_INSTRUCTIONS_PATH:-}" \
    "${ACCEPTANCE_CHECKLIST_PATH:-}" > "$OUTPUT_PATH"

# Clean up temp script
rm -f "$TEMP_SCRIPT"

echo "✓ Result file generated: $OUTPUT_PATH"
echo ""
echo "Generated minimal result file with:"
if [[ -n "$GENERATION_STARTED" ]]; then
    echo "  - All timestamps extracted from AI run report"
fi
if [[ -n "$TEST_TOTAL" ]]; then
    echo "  - Test results: ${TEST_PASSED:-0}/${TEST_TOTAL} passed (${TEST_PASS_RATE:-0}%)"
fi
if [[ -n "$TOTAL_MINUTES" ]]; then
    echo "  - Total time: ${TOTAL_MINUTES} minutes"
fi
echo ""
echo "Next steps:"
echo "  1. Review the generated file"
echo "  2. Validate: ./scripts/validate_result.sh $OUTPUT_PATH"
echo "  3. Submit via git: git add $OUTPUT_PATH && git commit -m 'Add result: ${OUTPUT_FILENAME}'"

