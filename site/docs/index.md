---
layout: home

hero:
  name: PawMate AI Challenge
  text: Benchmark AI Coding Assistants
  tagline: A reproducible, standardized workflow for testing AI tools by building a real application
  actions:
    - theme: brand
      text: Get Started →
      link: /getting-started
    - theme: alt
      text: View on GitHub
      link: https://github.com/hstm-labs/pawmate-ai-challenge
  image:
    src: /logo.png
    alt: PawMate

features:
  - icon: 📦
    title: No Cloning Required
    details: Install the CLI globally with npm. No need to clone repositories or navigate complex folder structures.
  
  - icon: 📋
    title: Frozen Specification
    details: Consistent requirements across all benchmark runs ensure fair, comparable results between different AI tools.
  
  - icon: ⏱️
    title: Automated Metrics
    details: Track objective timing data - time to first code, build success, test pass rates, and LLM token usage.
  
  - icon: 🚀
    title: Simple Workflow
    details: Install CLI, initialize run, copy prompt to AI agent, submit results. No manual setup or configuration.
  
  - icon: 🎯
    title: Real-World Challenge
    details: Build a complete pet adoption management system with API, database, tests, and UI from a detailed spec.
  
  - icon: 📊
    title: Public Leaderboard
    details: Submit results to a public repository and compare performance across different AI coding assistants.
---

## Quick Start

Get up and running in under 2 minutes:

```bash
# Install the CLI
npm install -g pawmate-ai-challenge

# Create a project directory
mkdir my-pawmate-benchmark
cd my-pawmate-benchmark

# Initialize a benchmark run
pawmate init --profile model-a-rest --tool "YourAI" --tool-ver "1.0"

# Copy the generated prompts to your AI agent
cat pawmate-run-*/start_build_api_prompt.txt
```

That's it! Your AI agent will build the entire application from the prompt.

[Learn more about the workflow →](/run-benchmark)

## What Is PawMate?

**PawMate** is a benchmarking framework that evaluates AI coding assistants by having them build a complete, production-ready application from a frozen specification. Unlike simple coding tests, PawMate measures how well AI tools can:

- Generate complete applications (API + UI) from requirements
- Handle complex domain logic (state machines, validation)
- Write and maintain automated tests
- Follow architectural patterns and best practices
- Work autonomously with minimal operator intervention

## Two Complexity Levels

### Model A (Minimum)
Basic CRUD operations with lifecycle management:
- Animal intake and profile management
- Lifecycle state machine (Available → Applied → Adopted)
- Adoption application workflow
- Audit history tracking
- ~2-4 hours for experienced AI agents

### Model B (Full)
Everything in Model A plus:
- User authentication and authorization
- Advanced search and filtering
- Role-based access control
- Additional validation rules
- ~4-6 hours for experienced AI agents

[Learn about profiles →](/profiles)

## Two API Styles

Choose between **REST** or **GraphQL** when initializing your run:

```bash
# REST API
pawmate init --profile model-a-rest --tool "YourAI"

# GraphQL API
pawmate init --profile model-a-graphql --tool "YourAI"
```

Both styles implement the same functional requirements, allowing fair comparisons between tools regardless of API preference.

## What Gets Measured?

The benchmark captures objective, automated metrics:

- ⏱️ **Timing Metrics:** Generation start → Code complete → Build → Tests pass
- ✅ **Build Status:** Success/failure flags for build, tests, and runtime
- 🔢 **Test Iterations:** Number of cycles to reach passing state
- 🤖 **LLM Usage:** Token consumption and request counts (if available)
- 👤 **Interventions:** Continuation prompts, clarifications, manual edits

**No subjective scoring.** All metrics are automatically extracted from the AI agent's run artifacts.

## Tech Stack

The specification requires a specific, battle-tested stack:

**Backend:**
- Node.js + Express
- SQLite (file-based database)
- Automated tests (required)

**Frontend (Optional):**
- Vite + React + TypeScript

This ensures runs are comparable and reproducible across all participants.

## Why PawMate?

### For AI Tool Developers
- **Objective data:** Real timing metrics, not marketing claims
- **Reproducible:** Same spec, same environment, same rules
- **Transparent:** Open source specification and results

### For AI Tool Users
- **Make informed decisions:** Compare tools on real-world tasks
- **See actual performance:** Not cherry-picked demos
- **Understand limitations:** What works, what doesn't

### For Researchers
- **Standardized benchmark:** Consistent evaluation framework
- **Public dataset:** Submitted results available for analysis
- **Versioned specs:** Track improvements over time

## Submission Methods

Submit your results in two ways:

**Email (Default):**
```bash
pawmate submit pawmate-run-*/benchmark/result.json
# Opens email client with pre-filled content
```

**GitHub Issue (Optional):**
```bash
export GITHUB_TOKEN=your-token-here
pawmate submit pawmate-run-*/benchmark/result.json
# Creates issue + opens email client
```

[Learn about submission →](/submit-results)

## Fair & Transparent

- ✅ **Open specification:** All requirements are public and versioned
- ✅ **Reproducible:** Anyone can re-run benchmarks with the same spec
- ✅ **No hidden criteria:** Acceptance criteria explicitly defined
- ✅ **Automated validation:** Result files follow a strict schema
- ✅ **Public results:** All submissions published for community review

## Ready to Benchmark?

<div class="tip custom-block" style="padding-top: 8px">

**Start here:** [Getting Started Guide →](/getting-started)

</div>

## Questions?

Check out the [FAQ](/faq) or [view the spec on GitHub](https://github.com/hstm-labs/pawmate-ai-challenge).

