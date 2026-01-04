# Rules & Specification

Benchmark rules and specification summary.

## Core Principles

The PawMate AI Challenge is built on three principles:

1. **Reproducibility** - Same spec, same results across all runs
2. **Objectivity** - Automated metrics, no subjective scoring
3. **Fairness** - Equal requirements for all participants

## Golden Rules

### 1. Do Not Modify the Prompt

The prompt is standardized and versioned. Any modifications invalidate the benchmark.

**Why:** Modified prompts make results incomparable and defeat the purpose of standardized benchmarking.

### 2. Let the AI Work Autonomously

Minimize operator intervention. Let the AI complete all work from the prompt.

**Track interventions:**
- Continuation prompts ("continue")
- Clarification answers
- Error messages provided
- Manual code edits

**Why:** The benchmark measures autonomous completion capability.

### 3. Use the Required Tech Stack

**Backend:** Node.js + Express + SQLite  
**Frontend:** Vite + React + TypeScript (optional)

**Why:** Ensures reproducibility and fair comparisons.

### 4. Complete All Steps

Don't stop at code generation. The AI must:
- ✅ Generate all code
- ✅ Build successfully
- ✅ Load seed data
- ✅ Start the application
- ✅ Run tests (iterate to 100% pass rate)
- ✅ Generate all artifacts

### 5. Submit Honest Results

Report all metrics accurately:
- Actual timestamps (not modified)
- Real intervention counts
- True build/test status
- Accurate LLM usage

## Specification Overview

### What Gets Built

A **pet adoption management system** with:

**Core Features (Model A):**
- Animal profile management
- Lifecycle state machine
- Adoption application workflow
- Audit history tracking

**Additional Features (Model B):**
- User authentication & authorization
- Role-based access control
- Advanced search & filtering

### Data Model

**Animals:**
- Basic info (name, species, breed, age)
- Status (Available, Applied, Adopted, Archived)
- Description and images (max 3)

**Applications:**
- Applicant information
- Application reason
- Status tracking (Submitted, UnderReview, Approved, Denied)
- Evaluation and decision records

**History:**
- Complete audit trail
- All state transitions
- Deterministic ordering

**Users (Model B only):**
- Authentication credentials
- Roles (Admin, Staff, Public)

### State Machine

Strict state transitions:

```
Available → Applied (when application submitted)
Applied → Adopted (when application approved)
Adopted → Archived (when adoption complete)
Available → Archived (if no longer adoptable)
```

**Invalid transitions:**
- Cannot go from Adopted back to Available
- Cannot skip states (Available → Adopted without Applied)
- All transitions must be logged in history

### API Contract

**REST Endpoints:**
```
POST   /api/animals              # Intake animal
GET    /api/animals/:id          # Get animal
PUT    /api/animals/:id          # Update animal
GET    /api/animals              # List animals (paginated)
POST   /api/applications         # Submit application
PUT    /api/applications/:id/evaluate    # Evaluate
PUT    /api/applications/:id/decide      # Decide
GET    /api/animals/:id/history  # Get history
```

**GraphQL Operations:**
```graphql
# Queries
getAnimal(animalId: ID!): Animal
listAnimals(status: String, limit: Int, offset: Int): [Animal!]!
getHistory(animalId: ID!): [HistoryEvent!]!

# Mutations
intakeAnimal(input: AnimalInput!): Animal!
updateAnimal(animalId: ID!, input: AnimalUpdateInput!): Animal!
submitApplication(input: ApplicationInput!): Application!
evaluateApplication(applicationId: ID!, evaluation: String!): Application!
decideApplication(applicationId: ID!, approved: Boolean!, explanation: String!): Application!
```

### Error Handling

Required error responses:

| Status | Error Type | When |
|--------|------------|------|
| 400 | ValidationError | Invalid input data |
| 404 | NotFound | Resource doesn't exist |
| 409 | Conflict | Business rule violation |
| 401 | AuthRequired | Not authenticated (Model B) |
| 403 | Forbidden | Insufficient permissions (Model B) |

### Deterministic Behavior

**Seed Data:**
- Loads identically every time
- 20 animals with specific IDs
- Deterministic ordering

**List Operations:**
- Consistent sort order (createdAt DESC, then animalId ASC)
- Predictable pagination
- Reproducible queries

**Timestamps:**
- ISO-8601 UTC with milliseconds
- Example: `2026-01-03T14:13:20.000Z`

### Testing Requirements

**Automated tests must:**
- Cover all API operations
- Test happy paths and error paths
- Validate state machine transitions
- Verify error responses
- Check pagination and filtering
- Achieve 100% pass rate

**Test organization:**
- Clearly named test files
- Grouped by feature/endpoint
- Runnable with single command (`npm test`)

## Acceptance Criteria

The specification includes explicit acceptance criteria (AC-*) for:

- Animal management (AC-001 through AC-010)
- Application workflow (AC-011 through AC-020)
- History tracking (AC-021 through AC-025)
- Authentication (AC-026 through AC-030) - Model B
- Search & filtering (AC-031 through AC-040) - Model B

Each criterion is testable and verifiable through the automated test suite.

## Out of Scope

These are explicitly **NOT** required:

- ❌ Payment processing
- ❌ External integrations (email, SMS, etc.)
- ❌ Promotions or marketing features
- ❌ Chat/messaging systems
- ❌ Privacy compliance features (GDPR, etc.)
- ❌ Multiple backend implementations
- ❌ Both REST and GraphQL (choose one)

## Benchmark Artifacts

Required deliverables:

**1. Working Implementation**
- Runnable from clean state
- Non-interactive commands only
- Cross-platform (macOS, Windows, Linux)

**2. API Contract**
- OpenAPI spec (REST) or GraphQL schema
- Complete operation definitions
- Error response documentation

**3. Automated Tests**
- Full test suite
- 100% pass rate
- Mapped to acceptance criteria

**4. Seed Data Mechanism**
- Deterministic seed loading
- Idempotent (safe to run multiple times)
- Verification support

**5. Run Management Scripts**
- `startup.sh` - Start all services
- `shutdown.sh` - Stop all services
- Non-interactive execution

**6. Documentation**
- `run_instructions.md` - How to run
- `ai_run_report.md` - Complete run report
- `acceptance_checklist.md` - Verification checklist

## Timing Measurements

Key timestamps to record:

| Milestone | Description |
|-----------|-------------|
| `generation_started` | First action by AI |
| `code_complete` | All files written |
| `build_clean` | npm install succeeds |
| `seed_loaded` | Seed data verified |
| `app_started` | API responds to health check |
| `test_run_N_start` | Test iteration N begins |
| `test_run_N_end` | Test iteration N completes |
| `all_tests_pass` | 100% pass rate achieved |

All timestamps must be ISO-8601 UTC with milliseconds.

## Prohibited Actions

These invalidate the benchmark:

- ❌ Modifying the prompt
- ❌ Using different tech stack
- ❌ Manually completing steps the AI should do
- ❌ Skipping required steps
- ❌ Falsifying timestamps or metrics
- ❌ Cherry-picking results (must submit all runs)

## Fair Play

**Do:**
- ✅ Report all metrics accurately
- ✅ Track all interventions
- ✅ Submit both successful and unsuccessful runs
- ✅ Document issues encountered
- ✅ Follow the specification exactly

**Don't:**
- ❌ Modify prompts to help your preferred tool
- ❌ Skip difficult requirements
- ❌ Edit generated code without tracking it
- ❌ Rerun to get better times (use run numbers)
- ❌ Omit intervention counts

## Version Control

The specification uses semantic versioning:

- **Major (v3.0):** Breaking changes to requirements
- **Minor (v2.7):** Additive changes, backwards compatible
- **Patch (v2.7.1):** Bug fixes, clarifications

Always specify the spec version in your run:

```bash
pawmate init --profile model-a-rest --tool "Cursor" --spec-ver v2.7.0
```

## Dispute Resolution

If you believe:
- The spec is ambiguous
- An implementation violates rules
- Results are incorrectly scored

**Open a GitHub issue:**
[github.com/fastcraft-ai/pawmate-ai-challenge/issues](https://github.com/fastcraft-ai/pawmate-ai-challenge/issues)

All disputes are resolved publicly and transparently.

## Spec Documents

Full specification available in the GitHub repository:

- **Master Functional Spec** - Complete requirements
- **API Contract** - Endpoint/operation details
- **Acceptance Criteria** - Testable requirements
- **Seed Data** - Deterministic dataset
- **Benchmarking Method** - Measurement procedures

[View full spec on GitHub →](https://github.com/fastcraft-ai/pawmate-ai-challenge/tree/main/docs)

## Questions About Rules?

- [FAQ](/faq) - Common questions
- [GitHub Issues](https://github.com/fastcraft-ai/pawmate-ai-challenge/issues) - Ask questions
- Email: pawmate.ai.challenge@gmail.com

