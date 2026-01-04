# Getting Started

Get up and running with PawMate in under 5 minutes.

## Prerequisites

Before you begin, make sure you have:

- **Node.js** version 18.0 or higher
- **npm** (comes with Node.js)
- An **AI coding assistant** to test (Cursor, GitHub Copilot, etc.)
- **10-15 GB free disk space** (for Node modules and generated code)

### Check Your Node Version

```bash
node --version
# Should show v18.0.0 or higher
```

### Need to Install Node.js?

Download from [nodejs.org](https://nodejs.org/) or use a version manager:

**macOS/Linux (nvm):**
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 20
nvm use 20
```

**Windows (nvm-windows):**
Download from [github.com/coreybutler/nvm-windows](https://github.com/coreybutler/nvm-windows/releases)

## Step 1: Install the CLI

Install PawMate globally so the `pawmate` command is available everywhere:

```bash
npm install -g pawmate-ai-challenge
```

### Verify Installation

```bash
pawmate --version
# Should show version number like 1.0.0

pawmate --help
# Shows available commands
```

## Step 2: Create a Project Directory

Create a dedicated directory for your benchmark run:

```bash
mkdir my-pawmate-benchmark
cd my-pawmate-benchmark
```

::: tip
Use a descriptive name like `cursor-model-a-run1` to track multiple runs easily.
:::

## Step 3: Initialize a Benchmark Run

Choose a [profile](/profiles) and initialize:

```bash
pawmate init --profile model-a-rest --tool "Cursor" --tool-ver "v0.43"
```

### Profile Options

| Profile | Model | API Style | Description |
|---------|-------|-----------|-------------|
| `model-a-rest` | A (Minimum) | REST | Best for first-time runs |
| `model-a-graphql` | A (Minimum) | GraphQL | Model A with GraphQL |
| `model-b-rest` | B (Full) | REST | Advanced with auth |
| `model-b-graphql` | B (Full) | GraphQL | Advanced with GraphQL |

::: tip Start with Model A
If this is your first run, start with `model-a-rest`. It's simpler and faster (~2-4 hours vs 4-6 hours for Model B).
:::

### What Gets Created?

The `init` command creates a run directory:

```
pawmate-run-20260103T141320/
├── start_build_api_prompt.txt    # API build prompt
├── start_build_ui_prompt.txt     # UI build prompt (optional)
├── run.config                    # Run metadata
├── PawMate/                      # Workspace for generated code
└── benchmark/                    # Benchmark artifacts
    └── result_submission_instructions.md
```

## Step 4: Copy the Prompt

Find your generated prompt file:

```bash
ls pawmate-run-*/

cat pawmate-run-*/start_build_api_prompt.txt
```

The prompt file contains:
- Your tool name and version
- Selected model (A or B)
- Selected API style (REST or GraphQL)
- Complete specification reference
- Detailed build instructions
- Automated testing requirements

## Step 5: Submit to Your AI Agent

1. **Open a new chat/session** in your AI coding assistant
2. **Copy the entire contents** of `start_build_api_prompt.txt`
3. **Paste it as the first message** (don't modify it!)
4. **Let the AI work** - Do not interrupt or provide additional context

::: warning Do Not Modify the Prompt
The prompt is carefully crafted to ensure fair, comparable benchmarks. Modifying it will invalidate your results.
:::

## What Happens Next?

Your AI agent will:

1. ✅ Record the `generation_started` timestamp
2. ✅ Generate all code files (API, database, tests)
3. ✅ Run `npm install` to build the project
4. ✅ Load seed data into the database
5. ✅ Start the API server
6. ✅ Run automated tests (iterate until all pass)
7. ✅ Generate benchmark artifacts

**Expected Duration:**
- Model A: 2-4 hours
- Model B: 4-6 hours

::: tip Autonomous Completion
The AI should work autonomously from start to finish. If it stops before completing all steps, send `continue` to prompt it to resume.
:::

## Monitoring Progress

Watch for these completion indicators:

```
✓ All code written
✓ Build successful (npm install completed)
✓ Seed data loaded and verified
✓ API server started and responsive
✓ All tests passing (100% pass rate)
✓ Benchmark artifacts generated
```

## Common Issues

### "Cannot find module" errors

The AI needs to request network permissions for `npm install`:

```
required_permissions: ['network']
```

Most modern AI agents handle this automatically.

### AI stops before completion

Send a simple message:

```
continue
```

Keep sending `continue` until all completion criteria are met.

### Tests failing

The AI should iterate and fix test failures automatically. If it stops with failing tests, send `continue` to prompt it to keep working.

## Hidden Directory Option

By default, `pawmate init` creates a **visible directory** (`pawmate-run-<timestamp>/`).

Power users can use the `--hidden` flag for a cleaner directory listing:

```bash
pawmate init --profile model-a-rest --tool "Cursor" --hidden
# Creates: .pawmate-run-<timestamp>/
```

## Next Steps

Once your AI agent completes the build:

- **[Learn how to verify and test your implementation →](/run-benchmark#verification)**
- **[Submit your results →](/submit-results)**
- **[Understand the workflow in detail →](/run-benchmark)**

## Quick Reference

```bash
# Install CLI
npm install -g pawmate-ai-challenge

# Initialize a run
pawmate init --profile model-a-rest --tool "YourAI"

# Submit results
pawmate submit pawmate-run-*/benchmark/result.json
```

## Need Help?

- [FAQ](/faq) - Common questions and answers
- [CLI Reference](/cli-reference) - All commands and options
- [GitHub Issues](https://github.com/rsdickerson/pawmate-ai-challenge/issues) - Report problems or ask questions

