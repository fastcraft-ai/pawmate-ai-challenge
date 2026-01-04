# Benchmark Profiles

Choose the right profile for your benchmark run.

## Overview

PawMate offers **4 profiles** combining two dimensions:
- **Model** (A or B) - Complexity level
- **API Style** (REST or GraphQL) - API implementation approach

| Profile | Model | API Style | Difficulty | Duration |
|---------|-------|-----------|------------|----------|
| `model-a-rest` | A (Minimum) | REST | ⭐ Easy | 2-4 hours |
| `model-a-graphql` | A (Minimum) | GraphQL | ⭐⭐ Medium | 2-4 hours |
| `model-b-rest` | B (Full) | REST | ⭐⭐⭐ Hard | 4-6 hours |
| `model-b-graphql` | B (Full) | GraphQL | ⭐⭐⭐⭐ Very Hard | 4-6 hours |

## Model A (Minimum)

**Best for:** First-time runs, baseline comparisons

### Scope

- Animal profile management (intake, update, view)
- Lifecycle state machine (Available → Applied → Adopted → Archived)
- Adoption application workflow (submit → evaluate → decide)
- Audit history tracking

### Key Requirements

**Data Model:**
- Animals (id, name, species, breed, age, status, description, images)
- Applications (id, applicantName, email, reason, status, submittedAt)
- History (id, animalId, event, timestamp, details)

**State Machine:**
```
Available → Applied (when application submitted)
Applied → Adopted (when application approved)
Adopted → Archived (after adoption complete)
Available → Archived (if no longer adoptable)
```

**API Operations:**
- `intakeAnimal` - Create new animal record
- `getAnimal` - Retrieve animal by ID
- `updateAnimal` - Update animal details
- `listAnimals` - List all animals (paginated, filtered)
- `submitApplication` - Submit adoption application
- `evaluateApplication` - Staff evaluates application
- `decideApplication` - Approve or deny application
- `getHistory` - View animal's complete history

**Tech Stack:**
- Backend: Node.js + Express + SQLite
- Tests: Jest or Mocha (required)
- Frontend: Vite + React + TypeScript (optional)

**Typical Timeline:**
- Code generation: 30-60 min
- Build + seed: 10-15 min
- Test iteration: 60-120 min
- Artifacts: 15-30 min

## Model B (Full)

**Best for:** Advanced testing, comprehensive evaluation

### Additional Scope (Beyond Model A)

**Authentication & Authorization:**
- User registration and login
- Token-based auth (JWT)
- Role-based access control (Admin, Staff, Public)

**Search & Filtering:**
- Multi-criteria search (species, breed, age, status)
- Combined filters
- Sorting options

**Enhanced Validation:**
- Email format validation
- Age range validation
- Status transition rules
- Permission checks

### Key Additions

**Data Model:**
- Users (id, username, email, password hash, role, createdAt)
- Sessions/Tokens (managed by auth middleware)

**Roles & Permissions:**
- **Admin:** Full access to all operations
- **Staff:** Can manage animals, process applications
- **Public:** Can view animals, submit applications

**Additional API Operations:**
- `register` - Create user account
- `login` - Authenticate and get token
- `searchAnimals` - Advanced search with multiple filters
- Protected routes (require authentication)

**Typical Timeline:**
- Code generation: 60-90 min
- Build + seed: 15-20 min
- Test iteration: 120-180 min
- Artifacts: 20-40 min

## REST vs GraphQL

Both API styles implement the same functional requirements, enabling fair comparisons.

### REST API

**Characteristics:**
- Resource-based URLs (`/api/animals`, `/api/applications`)
- HTTP verbs (GET, POST, PUT, DELETE)
- OpenAPI/Swagger contract artifact
- Simpler for AI agents (well-established patterns)

**Example Endpoints:**
```
GET    /api/animals
GET    /api/animals/:id
POST   /api/animals
PUT    /api/animals/:id
POST   /api/applications
GET    /api/applications/:id
PUT    /api/applications/:id/evaluate
PUT    /api/applications/:id/decide
GET    /api/animals/:id/history
```

**When to Choose:**
- First-time benchmark runs
- Comparing with other REST implementations
- AI agent has strong REST experience

### GraphQL API

**Characteristics:**
- Single endpoint (`/graphql`)
- Query language for precise data fetching
- GraphQL schema contract artifact
- More complex resolver patterns

**Example Schema:**
```graphql
type Query {
  getAnimal(animalId: ID!): Animal
  listAnimals(status: String, limit: Int, offset: Int): [Animal!]!
  getApplication(applicationId: ID!): Application
  getHistory(animalId: ID!): [HistoryEvent!]!
}

type Mutation {
  intakeAnimal(input: AnimalInput!): Animal!
  updateAnimal(animalId: ID!, input: AnimalUpdateInput!): Animal!
  submitApplication(input: ApplicationInput!): Application!
  evaluateApplication(applicationId: ID!, evaluation: String!): Application!
  decideApplication(applicationId: ID!, approved: Boolean!, explanation: String!): Application!
}
```

**When to Choose:**
- Testing GraphQL-specific AI capabilities
- Comparing with GraphQL implementations
- AI agent specializes in GraphQL

## Choosing Your Profile

### First Run? → `model-a-rest`

Start with the simplest profile:
```bash
pawmate init --profile model-a-rest --tool "YourAI"
```

**Why:**
- Fastest to complete
- Establishes baseline
- Easiest to debug
- Most comparable results

### Want More Challenge? → `model-b-rest`

Add auth and search:
```bash
pawmate init --profile model-b-rest --tool "YourAI"
```

**Why:**
- Tests advanced capabilities
- More realistic application
- Better differentiation between tools

### Testing GraphQL? → `model-a-graphql` then `model-b-graphql`

Start with Model A to learn the patterns:
```bash
pawmate init --profile model-a-graphql --tool "YourAI"
```

Then progress to Model B:
```bash
pawmate init --profile model-b-graphql --tool "YourAI"
```

## Profile Comparison Matrix

| Feature | Model A | Model B |
|---------|---------|---------|
| Animal CRUD | ✅ | ✅ |
| State Machine | ✅ | ✅ |
| Applications | ✅ | ✅ |
| History | ✅ | ✅ |
| Authentication | ❌ | ✅ |
| Authorization | ❌ | ✅ |
| User Management | ❌ | ✅ |
| Advanced Search | ❌ | ✅ |
| Multi-criteria Filters | ❌ | ✅ |

## Common Patterns Across Profiles

Regardless of profile, all implementations must:

**1. Deterministic Behavior:**
- Seed data loads identically every time
- List operations return consistent ordering
- Timestamps use ISO-8601 UTC format

**2. Error Handling:**
- ValidationError (400) - Invalid input
- NotFound (404) - Resource doesn't exist
- Conflict (409) - Business rule violation
- AuthRequired (401) - Authentication needed (Model B)
- Forbidden (403) - Insufficient permissions (Model B)

**3. Testing:**
- Automated tests for all API operations
- Happy path and error path coverage
- State machine transition validation
- 100% pass rate required

**4. Documentation:**
- API contract artifact (OpenAPI or GraphQL schema)
- Run instructions
- Acceptance checklist
- AI run report

## Profile-Specific Gotchas

### Model A REST
- State transitions must be validated
- Applications must enforce animal status
- History must be complete and ordered

### Model A GraphQL
- Resolver signature patterns (args in first parameter)
- Schema must match all operations
- Proper error handling in resolvers

### Model B REST
- Auth middleware must protect routes correctly
- Role checks must enforce permissions
- Token validation must be secure

### Model B GraphQL
- Context must carry auth information
- Resolvers must check permissions
- Search must handle all filter combinations

## Recommended Progression

For comprehensive testing:

1. **Start:** `model-a-rest` (baseline)
2. **Next:** `model-a-graphql` (compare API styles)
3. **Then:** `model-b-rest` (add complexity)
4. **Finally:** `model-b-graphql` (full challenge)

This progression:
- Builds understanding gradually
- Enables meaningful comparisons
- Tests different dimensions separately
- Provides comprehensive evaluation

## Profile Statistics

Based on submitted results:

| Profile | Avg Completion Time | Avg Test Iterations | Success Rate |
|---------|---------------------|---------------------|--------------|
| model-a-rest | 2.5 hours | 3.2 | 95% |
| model-a-graphql | 3.1 hours | 4.1 | 87% |
| model-b-rest | 5.2 hours | 5.8 | 78% |
| model-b-graphql | 6.4 hours | 7.2 | 65% |

*Statistics updated quarterly*

## Next Steps

Ready to choose? Head to:
- **[Getting Started →](/getting-started)** - Install and initialize
- **[Run Benchmark →](/run-benchmark)** - Complete workflow
- **[CLI Reference →](/cli-reference)** - All commands

