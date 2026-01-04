# Running a Benchmark

Complete workflow for running a PawMate AI benchmark from initialization to submission.

## Overview

A complete benchmark run consists of:

1. **Initialize** - Generate prompts for your chosen profile
2. **Build API** - AI agent generates backend implementation
3. **Build UI** (Optional) - AI agent generates frontend
4. **Verify** - Check that all requirements are met
5. **Submit** - Send results to the leaderboard

Estimated time: 2-6 hours depending on model and AI agent performance.

## Step 1: Initialize the Run

```bash
pawmate init --profile model-a-rest --tool "YourAI" --tool-ver "1.0"
```

This creates a timestamped run directory with:
- `start_build_api_prompt.txt` - Complete API build prompt
- `start_build_ui_prompt.txt` - Complete UI build prompt (optional)
- `run.config` - Run metadata
- `PawMate/` - Workspace directory for generated code
- `benchmark/` - Directory for benchmark artifacts

## Step 2: Build the API

### 2.1 Open a New AI Session

Start a fresh chat/session in your AI coding assistant. This ensures:
- Clean context without prior conversations
- Accurate timing measurements
- Fair comparison between runs

### 2.2 Submit the Prompt

1. Open `pawmate-run-<timestamp>/start_build_api_prompt.txt`
2. Copy the **entire contents** (don't modify!)
3. Paste as the first message in your AI agent
4. Press enter and let it work

::: warning Critical Rule
**Do not modify the prompt.** The prompt is versioned and standardized. Modifications invalidate the benchmark.
:::

### 2.3 What the AI Should Do

The AI agent should autonomously:

**Phase 1: Code Generation**
- Read all specification files
- Generate backend code (API, database, models)
- Create automated tests
- Write documentation

**Phase 2: Build**
- Run `npm install` with network permissions
- Resolve any dependency issues
- Complete build successfully

**Phase 3: Seed Data**
- Load deterministic seed data
- Verify data integrity
- Confirm database state

**Phase 4: Start Application**
- Launch the API server
- Verify health check responds
- Confirm API is accessible

**Phase 5: Test Iteration**
- Run automated tests
- Fix any failures
- Iterate until 100% pass rate
- Record all test run timestamps

**Phase 6: Generate Artifacts**
- Create API contract (OpenAPI or GraphQL schema)
- Write run instructions
- Generate acceptance checklist
- Complete AI run report with all timestamps

### 2.4 Expected Timestamps

The AI should record these milestones in `PawMate/../benchmark/ai_run_report.md`:

```yaml
generation_started: 2026-01-03T14:13:20.000Z
code_complete: 2026-01-03T14:25:45.000Z
build_clean: 2026-01-03T14:27:30.000Z
seed_loaded: 2026-01-03T14:28:00.000Z
app_started: 2026-01-03T14:28:15.000Z
test_run_1_start: 2026-01-03T14:30:00.000Z
test_run_1_end: 2026-01-03T14:32:15.000Z
all_tests_pass: 2026-01-03T14:35:45.000Z
```

### 2.5 If the AI Stops Early

Some AI agents pause for confirmation or hit context limits. If this happens:

**Send a continuation message:**
```
continue
```

**Keep sending `continue` until:**
- ✅ All tests pass (100%)
- ✅ All timestamps recorded
- ✅ All artifacts generated

::: tip Track Interventions
Count how many times you send `continue` or provide error feedback. This is recorded as operator interventions in the results.
:::

## Step 3: Build the UI (Optional)

After the API is complete, you can optionally build the UI.

### 3.1 Start a New Session (or Continue)

You can either:
- **Option A:** Continue in the same AI session
- **Option B:** Start a fresh session for the UI

### 3.2 Submit the UI Prompt

1. Open `pawmate-run-<timestamp>/start_build_ui_prompt.txt`
2. Copy the entire contents
3. Paste as the next message (or first message in new session)

### 3.3 What the UI Build Includes

The AI will generate:
- Vite + React + TypeScript frontend
- Integration with existing API
- Forms for all API operations
- Display components for data
- Routing and navigation

**Expected Duration:** 1-2 hours

### 3.4 UI Completion Criteria

UI build is complete when:
- ✅ All UI code written
- ✅ `npm install` completes successfully
- ✅ UI starts without errors
- ✅ API and UI running simultaneously
- ✅ UI run summary generated with timestamps

## Step 4: Verify the Implementation {#verification}

### 4.1 Check Generated Files

Verify these key files exist:

```bash
cd pawmate-run-<timestamp>/PawMate

# API/Backend
ls backend/
# Should contain: src/, package.json, openapi.yaml (or schema.graphql)

# Tests
ls backend/tests/  # or backend/src/**/*.test.js
# Should contain test files

# Benchmark artifacts
ls ../benchmark/
# Should contain: ai_run_report.md, run_instructions.md, acceptance_checklist.md
```

### 4.2 Start the Application

Use the generated startup script:

```bash
cd pawmate-run-<timestamp>/PawMate
./startup.sh
```

This should:
1. Start the API server (port 3000)
2. Start the UI server (port 5173, if UI was built)
3. Display success messages with URLs

### 4.3 Test the API

**Health check:**
```bash
curl http://localhost:3000/health
# Should return: {"status":"ok"}
```

**List animals:**
```bash
# REST
curl http://localhost:3000/api/animals

# GraphQL
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ listAnimals { animalId name } }"}'
```

### 4.4 Check Test Results

Run the automated tests:

```bash
cd backend
npm test
```

All tests should pass (100% pass rate).

### 4.5 Review Benchmark Artifacts

Open `../benchmark/ai_run_report.md` and verify:
- All timestamps are present (not "Unknown")
- Test iterations are recorded
- LLM usage metrics are documented (if available)
- No critical errors or warnings

## Step 5: Understanding Metrics

### Timing Metrics

| Metric | Description | Calculation |
|--------|-------------|-------------|
| Time to First Code (TTFC) | Start → Code written | `code_complete` - `generation_started` |
| Time to Build | Code written → Build success | `build_clean` - `code_complete` |
| Time to Running | Start → API responding | `app_started` - `generation_started` |
| Time to All Tests Pass | Start → 100% pass rate | `all_tests_pass` - `generation_started` |

### Intervention Metrics

Track these for submission:
- **Continuation prompts** - Times you sent "continue"
- **Clarifications** - Times AI asked questions requiring input
- **Error messages** - Times you provided error feedback
- **Manual edits** - Times you edited code (should be 0)

Lower intervention counts indicate better autonomous performance.

### Build Status

Binary success/failure flags:
- `build_success` - Did `npm install` complete?
- `tests_pass` - Did all tests pass?
- `app_started` - Did the API start and respond?
- `ui_build_success` - Did the UI build (if applicable)?
- `ui_running` - Is the UI accessible (if applicable)?

## Common Scenarios

### Scenario: AI Stops After Writing Code

**Symptoms:**
- Code is generated
- No build attempt
- Missing timestamps after `code_complete`

**Solution:**
```
continue
```

The AI should proceed to run `npm install`.

### Scenario: Build Fails

**Symptoms:**
- `npm install` errors
- Dependency conflicts
- Missing packages

**Solution:**
Let the AI fix it. Send:
```
continue
```

Do NOT manually edit `package.json`. The AI should resolve build issues autonomously.

### Scenario: Tests Fail

**Symptoms:**
- Some tests pass, some fail
- AI reports test failures
- `all_tests_pass` timestamp missing

**Solution:**
```
continue
```

The AI should analyze failures and iterate until all tests pass. This is expected behavior.

### Scenario: Missing Artifacts

**Symptoms:**
- Artifacts folder incomplete
- No `ai_run_report.md`
- No acceptance checklist

**Solution:**
```
continue
```

Remind the AI to generate all required artifacts.

## Profile-Specific Notes

### Model A (Minimum)

**Scope:**
- Animal CRUD operations
- Lifecycle state machine (Available → Applied → Adopted)
- Adoption application workflow
- History tracking

**Typical Duration:** 2-4 hours

**Common Gotchas:**
- State machine validation (can't go from Adopted back to Available)
- Application workflow must enforce states
- History must be complete and ordered

### Model B (Full)

**Additional Scope:**
- User authentication (register, login, token-based)
- Role-based access control (Admin, Staff, Public)
- Search and filtering with multiple criteria
- Additional validation rules

**Typical Duration:** 4-6 hours

**Common Gotchas:**
- Auth middleware must protect appropriate routes
- Search must handle multiple filters correctly
- Roles must enforce proper permissions

## Next Steps

After verifying your implementation:

1. **[Submit your results →](/submit-results)**
2. **[View the leaderboard →](/results)**
3. **[Run another profile](#)** to compare

## Troubleshooting

### API Won't Start

Check the logs:
```bash
cd pawmate-run-<timestamp>/PawMate/backend
npm run dev
# Look for error messages
```

Common issues:
- Port 3000 already in use
- Database file locked
- Missing environment variables

### Tests Won't Run

Verify test command exists:
```bash
cd backend
cat package.json | grep '"test"'
# Should show: "test": "..."
```

If missing, the AI didn't complete test setup. Send `continue`.

### Incomplete Artifacts

List what's missing:
```bash
ls ../benchmark/
```

Required files:
- `ai_run_report.md`
- `run_instructions.md`
- `acceptance_checklist.md`
- `result_submission_instructions.md`

If any are missing, send `continue` to the AI.

## Advanced Options

### Hidden Directory

Create a hidden run directory:
```bash
pawmate init --profile model-a-rest --tool "Cursor" --hidden
# Creates: .pawmate-run-<timestamp>/
```

### Custom Run Directory

Specify a custom path:
```bash
pawmate init --profile model-a-rest --tool "Cursor" \
  --run-dir ~/benchmarks/my-custom-run
```

### Spec Version

Lock to a specific spec version:
```bash
pawmate init --profile model-a-rest --tool "Cursor" \
  --spec-ver v2.7.0
```

## Best Practices

1. **Don't modify prompts** - Invalidates the benchmark
2. **Let AI work autonomously** - Minimize interventions
3. **Track all interventions** - For accurate results
4. **Verify completion** - Check all timestamps and artifacts
5. **Test before submitting** - Run the application and tests
6. **Document issues** - Note any unexpected behavior

## Need Help?

- [FAQ](/faq) - Common questions
- [CLI Reference](/cli-reference) - All commands
- [GitHub Issues](https://github.com/rsdickerson/pawmate-ai-challenge/issues) - Report problems

