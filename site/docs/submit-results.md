# Submit Results

Submit your benchmark results to the public leaderboard.

## When to Submit

Submit your results after:

✅ AI agent has completed all work  
✅ All tests pass (100% pass rate)  
✅ Application starts and runs successfully  
✅ All benchmark artifacts are generated  
✅ You've verified the implementation works  

## Submission Command

```bash
pawmate submit pawmate-run-*/benchmark/result.json
```

::: tip Result File Location
The result file is automatically generated in the `benchmark/` folder (sibling of `PawMate/`). If it doesn't exist, the AI may not have completed artifact generation.
:::

## What Happens

### Step 1: Validation

The CLI validates your result file:

- ✅ Valid JSON format
- ✅ Required fields present
- ✅ Filename follows convention
- ✅ Timestamps in correct format

If validation fails, you'll see specific error messages.

### Step 2: Attribution (Optional)

You'll be prompted for attribution:

```
Your name or GitHub username: 
```

You can:
- Enter your name/username for credit
- Press Enter to submit anonymously

### Step 3: Email Submission

The CLI opens your email client with pre-filled content:

**To:** `pawmate.ai.challenge@gmail.com`  
**Subject:** `[Submission] Tool: YourAI, Model: A, API: REST, Run: 1`  
**Body:** Your result data as JSON

::: warning Important
The email client opens automatically, but **you must click "Send"** to complete the submission. The CLI cannot send emails automatically.
:::

### Step 4: GitHub Issue (Optional)

If you've set a GitHub token:

```bash
export GITHUB_TOKEN=your-token-here
pawmate submit pawmate-run-*/benchmark/result.json
```

The CLI will also create a GitHub issue in the results repository with your submission.

## Email Submission (Default)

Email submission works out of the box with no configuration:

```bash
pawmate submit pawmate-run-*/benchmark/result.json
```

**Process:**
1. CLI validates your file
2. Prompts for attribution
3. Opens your default email client
4. Pre-fills: To, Subject, Body
5. **You click "Send"**

**If email client doesn't open:**

The CLI will print the email content to your terminal. Copy and paste it manually into your email client.

## GitHub Issue Submission (Optional)

GitHub issue submission requires a personal access token.

### Why Use GitHub Issues?

- Faster than email
- Automatic tracking
- Public visibility
- Issue number for reference

### Create a GitHub Token

1. Go to [github.com/settings/tokens](https://github.com/settings/tokens)
2. Click **"Generate new token" → "Generate new token (classic)"**
3. Name it: "PawMate Result Submission"
4. Select the **"repo"** scope (required for creating issues)
5. Click **"Generate token"**
6. Copy the token immediately (you won't see it again)

### Set the Token

**Method 1: Environment Variable**

```bash
export GITHUB_TOKEN=ghp_xxxxxxxxxxxx
pawmate submit pawmate-run-*/benchmark/result.json
```

**Method 2: Command Flag**

```bash
pawmate submit pawmate-run-*/benchmark/result.json \
  --github-token ghp_xxxxxxxxxxxx
```

### What Gets Created

The CLI creates a GitHub issue in [fastcraft-ai/pawmate-ai-results](https://github.com/fastcraft-ai/pawmate-ai-results) with:

- **Title:** `[Submission] Tool: YourAI, Model: A, API: REST, Run: 1`
- **Labels:** `submission`, `results`
- **Body:** Your result data as JSON

**Plus:** Email client still opens (dual submission for redundancy)

## Result File Format

The result file contains:

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
      "timestamp": "2026-01-03T14:13:20Z"
    },
    "timing_metrics": {
      "generation_started": "2026-01-03T14:13:20.000Z",
      "code_complete": "2026-01-03T14:25:45.000Z",
      "build_clean": "2026-01-03T14:27:30.000Z",
      "app_started": "2026-01-03T14:28:15.000Z",
      "all_tests_pass": "2026-01-03T14:35:45.000Z"
    },
    "build_status": {
      "build_success": true,
      "tests_pass": true,
      "app_started": true
    },
    "llm_usage": {
      "model_used": "claude-sonnet-4.5",
      "total_tokens": 125000,
      "requests_count": 45
    }
  }
}
```

## Validation Rules

### Filename Convention

Expected pattern:
```
{tool-slug}_{model}_{api-type}_{run-number}_{timestamp}.json
```

Example:
```
cursor-v0-43_modelA_REST_run1_20260103T1413.json
```

**If your filename doesn't match:**

The CLI will warn you but allow you to continue. For official submissions, follow the convention.

### Required Fields

Must be present:
- `schema_version`
- `result_data.run_identity.tool_name`
- `result_data.run_identity.target_model`
- `result_data.run_identity.api_style`

### Timestamp Format

All timestamps must be ISO-8601 UTC with milliseconds:

```
2026-01-03T14:13:20.000Z
```

## Submission Options

### Email Only (Skip GitHub)

```bash
pawmate submit result.json --email-only
```

Use this if you don't want to create a GitHub issue.

### GitHub Only? (Not Supported)

GitHub-only submission is not supported. Email submission always happens (for backup and verification).

## After Submission

### What Happens to Your Submission?

1. **Email received:** Maintainers receive your result via email
2. **Validation:** Result is validated against the schema
3. **Storage:** Result is added to the results repository
4. **Publication:** Results appear in the public leaderboard
5. **Aggregation:** Your data contributes to comparison reports

### When Will It Appear?

Results are typically published within:
- **24-48 hours** for email submissions
- **Immediately** for GitHub issue submissions (pending review)

### Viewing Results

Visit the results repository:

**GitHub:** [github.com/fastcraft-ai/pawmate-ai-results](https://github.com/fastcraft-ai/pawmate-ai-results)  
**Leaderboard:** See [View Results](/results) page

## Troubleshooting

### Email Client Doesn't Open

**Cause:** System doesn't have a default email client configured

**Solution:**

The CLI will print the email content to your terminal:

```
To: pawmate.ai.challenge@gmail.com
Subject: [Submission] Tool: Cursor, Model: A, API: REST, Run: 1

Body:
{
  "schema_version": "3.0",
  ...
}
```

Copy this and manually create an email.

### GitHub API Errors

**401/403 Unauthorized:**
- Token is invalid or missing `repo` scope
- Regenerate token with correct permissions

**404 Not Found:**
- Repository doesn't exist or isn't accessible
- Check: [github.com/fastcraft-ai/pawmate-ai-results](https://github.com/fastcraft-ai/pawmate-ai-results)

**422 Validation Error:**
- Result data is malformed
- Check JSON syntax and required fields

### Validation Failures

**Invalid JSON Format:**
```
Error: Invalid JSON format
```

Solution: Check for syntax errors in your result file.

**Missing Required Fields:**
```
Error: Missing required fields: result_data.run_identity.tool_name
```

Solution: Ensure the AI generated a complete result file.

**Filename Convention Warning:**
```
Warning: Filename does not match expected pattern
```

Solution: Rename the file or accept the warning and continue.

## Best Practices

### Before Submitting

1. ✅ **Verify all tests pass** - Don't submit with failing tests
2. ✅ **Check artifacts are complete** - Review `ai_run_report.md`
3. ✅ **Test the application** - Make sure it actually works
4. ✅ **Review timestamps** - Ensure none are "Unknown"
5. ✅ **Check LLM usage** - Record token counts if available

### Multiple Runs

If you run multiple benchmarks:
- Organize run folders: `cursor-model-a-run1/`, `cursor-model-a-run2/`
- Submit each separately
- Track which submissions correspond to which runs

### Re-submissions

If you need to resubmit:
- Use a new run number: `run2`, `run3`, etc.
- Don't modify the original submission
- Reference the previous submission in attribution

## Privacy & Data

### What Gets Shared

**Public:**
- Tool name and version
- Timing metrics (timestamps, durations)
- Build success/failure flags
- Test pass rates
- LLM token usage
- Attribution (if provided)

**Not Shared:**
- Your code implementation
- Personal information (unless in attribution)
- Email address (stored privately)
- GitHub token

### Attribution

Attribution is optional:
- **Anonymous:** Press Enter when prompted
- **Named:** Enter your name or GitHub username

## FAQ

### Can I submit without building the UI?

Yes! UI is optional. API-only submissions are valid.

### What if my AI didn't complete everything?

You can still submit partial results, but they'll show as incomplete in the leaderboard. Ideal submissions have all tests passing.

### Can I submit multiple times?

Yes, but use different run numbers (`run1`, `run2`, etc.) to distinguish them.

### How do I update my submission?

You can't update submissions. Instead, submit a new run with an updated run number.

### Is my email address public?

No. Email addresses are stored privately for communication purposes only.

## Next Steps

After submitting:

- **[View the leaderboard →](/results)**
- **[Run another benchmark →](/getting-started)**
- **[Compare your results](#)**

## Need Help?

- [FAQ](/faq) - Common questions
- [CLI Reference](/cli-reference) - Command details
- [GitHub Issues](https://github.com/fastcraft-ai/pawmate-ai-challenge/issues) - Report problems

