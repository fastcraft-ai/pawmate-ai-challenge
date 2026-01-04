# Frequently Asked Questions

Common questions about the PawMate AI Challenge.

## General Questions

### What is PawMate?

PawMate is a benchmarking framework for evaluating AI coding assistants by having them build a complete application (pet adoption management system) from a frozen specification. It measures objective metrics like time-to-code, build success, and test pass rates.

### Why should I participate?

**For Users:** Make informed decisions about which AI coding tools work best for real-world tasks.

**For Tool Developers:** Get objective performance data to improve your products.

**For Researchers:** Access standardized benchmarks and public datasets.

### Is it free?

Yes, completely free. The CLI is open source, and hosting/submission are free.

### Do I need to clone a GitHub repo?

No! Install the CLI with npm and run benchmarks from any directory:

```bash
npm install -g pawmate-ai-challenge
```

## Getting Started

### What do I need to run a benchmark?

- Node.js 18 or higher
- npm (comes with Node.js)
- An AI coding assistant (Cursor, GitHub Copilot, etc.)
- 10-20 GB free disk space

### Which profile should I start with?

Start with `model-a-rest`:

```bash
pawmate init --profile model-a-rest --tool "YourAI"
```

It's the simplest and fastest to complete (~2-4 hours).

### Can I run multiple benchmarks?

Yes! Create separate directories for each run:

```bash
mkdir cursor-run1 && cd cursor-run1
pawmate init --profile model-a-rest --tool "Cursor"

mkdir cursor-run2 && cd cursor-run2
pawmate init --profile model-b-rest --tool "Cursor"
```

## Running Benchmarks

### How long does a benchmark take?

- **Model A:** 2-4 hours
- **Model B:** 4-6 hours

Time varies based on AI agent performance and operator intervention needs.

### Can I modify the prompt?

**No.** The prompt is standardized and versioned. Modifications invalidate the benchmark and make results incomparable.

### What if my AI stops before finishing?

Send a continuation message:

```
continue
```

Keep sending `continue` until all work is complete (tests passing, artifacts generated).

### Can I manually fix errors?

You can, but **it counts as operator intervention** and is tracked in the results. The goal is to measure autonomous completion, so minimize manual edits.

### Does the UI have to be built?

No, the UI is optional. API-only submissions are perfectly valid.

### What if my tests don't all pass?

The AI should iterate until all tests pass. If it can't achieve 100% pass rate, you can still submit, but the results will show incomplete status.

## Submission

### How do I submit results?

```bash
pawmate submit pawmate-run-*/benchmark/result.json
```

This opens your email client with pre-filled content. Click "Send" to complete submission.

### Do I need a GitHub token?

No, email submission works without any tokens. GitHub issue creation is optional and requires a token.

### Can I submit anonymously?

Yes. When prompted for attribution, just press Enter to submit anonymously.

### Can I submit partial results?

Yes, but they'll show as incomplete in the leaderboard. Ideal submissions have all tests passing and all artifacts generated.

### How do I create a GitHub token?

1. Go to [github.com/settings/tokens](https://github.com/settings/tokens)
2. Generate new token (classic)
3. Select "repo" scope
4. Copy the token
5. Set environment variable: `export GITHUB_TOKEN=your-token`

### When will my results appear?

- **GitHub issues:** Immediately (pending review)
- **Email submissions:** 24-48 hours

## Technical Questions

### Why Node.js + Express + SQLite?

This stack ensures:
- Reproducible builds across all platforms
- No external dependencies (database servers)
- Fair comparisons between runs
- Wide AI agent familiarity

### Can I use a different tech stack?

No. The specification requires Node.js + Express + SQLite for backend. Using different technologies invalidates the benchmark.

### Why REST vs GraphQL options?

Both implement the same functional requirements, allowing fair comparisons between tools regardless of API preference. Some AI agents excel at REST, others at GraphQL.

### What if npm install fails in sandbox?

The AI should request network permissions:

```
required_permissions: ['network']
```

See the [SANDBOX_SOLUTION.md](https://github.com/fastcraft-ai/pawmate-ai-challenge/blob/main/docs/SANDBOX_SOLUTION.md) doc for details.

### Why SQLite instead of PostgreSQL?

SQLite is file-based (no server required), making benchmarks:
- Easier to set up
- More reproducible
- Platform-independent
- Faster to seed and reset

## Metrics & Scoring

### What gets measured?

**Timing Metrics:**
- Time to first code (generation → code complete)
- Time to build (code → successful build)
- Time to running (generation → API responsive)
- Time to tests passing (generation → 100% pass rate)

**Build Status:**
- Build success (boolean)
- Tests pass (boolean)
- App started (boolean)

**Intervention Metrics:**
- Continuation prompts sent
- Clarifications answered
- Error messages provided
- Manual code edits

**LLM Usage:**
- Token counts
- Request counts
- Model used

### Is there a scoring system?

Not yet. Currently, we collect objective metrics. Future versions may include scoring rubrics, but the focus is on measurable data, not subjective quality ratings.

### What's a good completion time?

**Model A:**
- Fast: < 2 hours
- Average: 2-3 hours
- Slow: > 4 hours

**Model B:**
- Fast: < 4 hours
- Average: 4-6 hours
- Slow: > 8 hours

Times vary significantly based on AI agent capabilities.

### What are operator interventions?

Any action you take beyond the initial prompt:
- Sending "continue"
- Providing error messages
- Answering AI questions
- Manually editing code

Lower intervention counts indicate better autonomous performance.

## Troubleshooting

### Email client doesn't open

The CLI will print the email content to your terminal. Copy and manually send via your email client.

### Can't find the result file

Check if the AI completed artifact generation:

```bash
ls pawmate-run-*/benchmark/
```

If missing, the AI stopped early. Send `continue`.

### Tests are failing

Let the AI fix them. Send `continue` and it should iterate until all pass.

### Build errors

Check if npm install completed:

```bash
cd pawmate-run-*/PawMate/backend
npm install
```

If it fails, the AI may not have requested network permissions.

### Port already in use

Kill any existing Node processes:

```bash
lsof -ti:3000 | xargs kill -9
```

Or use the shutdown script:

```bash
./shutdown.sh
```

## Results & Leaderboard

### Where can I see results?

Visit the results repository: [github.com/fastcraft-ai/pawmate-ai-results](https://github.com/fastcraft-ai/pawmate-ai-results)

### How are results verified?

Results are validated against a schema and reviewed by maintainers before publication.

### Can I compare my results with others?

Yes! The results repository includes aggregated comparison reports showing performance across different tools and profiles.

### What if I disagree with published results?

Open a GitHub issue in the results repository with your concerns. All submissions are reviewed transparently.

## Contributing

### Can I contribute to PawMate?

Yes! Contributions welcome:
- **Documentation:** Improve guides and examples
- **Tooling:** Enhance the CLI
- **Specification:** Propose requirement clarifications
- **Results:** Submit benchmark runs

See [Contributing](/contributing) for details.

### How do I report bugs?

Open an issue: [github.com/fastcraft-ai/pawmate-ai-challenge/issues](https://github.com/fastcraft-ai/pawmate-ai-challenge/issues)

### Can I suggest new features?

Yes! Open a GitHub issue with the "enhancement" label.

### How are spec changes handled?

The specification uses semantic versioning. Breaking changes trigger a major version bump, ensuring comparability within versions.

## Privacy & Data

### What data is collected?

**Collected:**
- Tool name and version
- Timing metrics
- Build success/failure
- Test results
- LLM token usage
- Attribution (optional)

**Not Collected:**
- Your source code
- Personal information (unless in attribution)
- IP addresses
- Usage analytics

### Is my submission data public?

Yes, submitted results are published in the public results repository. However, your implementation code stays private.

### Can I delete my submission?

Contact the maintainers via the results repository to request removal.

## Still Have Questions?

- **Check the docs:** [All documentation](/getting-started)
- **CLI Reference:** [Command details](/cli-reference)
- **GitHub Issues:** [Ask questions](https://github.com/fastcraft-ai/pawmate-ai-challenge/issues)
- **Email:** pawmate.ai.challenge@gmail.com

