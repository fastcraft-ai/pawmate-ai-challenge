## Appendix F — Prompt Wrapper (Copy/Paste Template)

> **Operator instructions:** Copy/paste this entire template into the Tool Under Test (TUT) as the first message for a benchmark run. Fill only the bracketed fields. Do not add additional requirements not present in the frozen spec.

---

### 0) Benchmark Header (Operator fills)
- **Tool Under Test (TUT)**: [Tool name + version/build id]
- **Run ID**: [e.g., ToolX-ModelA-Run1]
- **Frozen Spec Reference**: [commit/tag/hash or immutable archive id]
- **Workspace Path**: [path]
- **Target Model (choose exactly one)**:
  - [ ] **Model A (Minimum)**
  - [ ] **Model B (Full)**
- **API Style (choose exactly one; DO NOT implement both)**:
  - [ ] **REST** (produce an OpenAPI contract artifact)
  - [ ] **GraphQL** (produce a GraphQL schema contract artifact)

---

### 1) Role + Objective (Tool must follow)
You are an implementation agent for a reproducible benchmarking run. Your objective is to produce a complete implementation that satisfies the frozen spec **for the selected Target Model** and to generate a benchmark-ready artifact bundle (run instructions, contract artifact, acceptance and determinism evidence pointers).

You MUST work strictly within scope and MUST NOT invent requirements. If something is ambiguous, you MUST either ask a clarification question or record the smallest compliant assumption as an explicit `ASM-####`.

---

### 2) In-Scope Inputs (Frozen Spec Files)
You MUST treat the following files as the sole source of truth and keep them consistent:
- `docs/01-Master_Functional_Spec.md`
- `docs/02-Appendix_A_API_Contract.md`
- `docs/03-Appendix_B_Seed_Data.md`
- `docs/04-Appendix_C_Image_Handling.md`
- `docs/05-Appendix_D_Acceptance_Criteria.md`
- `docs/06-Appendix_E_Benchmarking_Method.md`

If any behavior is not required by a `REQ-*` item, it is out of scope unless explicitly allowed by `MAY`.

---

### 3) Hard Guardrails (MUST)

#### 3.1 Overreach guardrails (`NOR-*`)
You MUST comply with all `NOR-*` items in the Master Spec. In particular:
- You MUST NOT require any external integrations (`NOR-0001`).
- You MUST NOT implement commerce flows (`NOR-0002`), promotions (`NOR-0003`), or messaging/chat (`NOR-0004`).
- Privacy requirements are out of scope (`NOR-0005`).
- You MUST choose **one** API style (REST or GraphQL) and produce **one** corresponding contract artifact (`NOR-0006`).
- You MUST NOT add features not required by `REQ-*` items (`NOR-0007`).

#### 3.2 Assumptions (`ASM-*`)
- Any assumption MUST be explicitly labeled `ASM-####` and listed in an “Assumptions” section.
- Assumptions MUST be the smallest reasonable interpretation that remains compliant.
- If you need operator input, ask a clarification question and wait.

---

### 4) Required Outputs (MUST)
Your deliverable MUST include all of the following:

#### 4.1 Implementation (code + configs)
- A working implementation for the selected Target Model.
- Must be runnable from a clean workspace using non-interactive commands.

#### 4.2 API Contract Artifact (Appendix A compliant) (MUST)
Produce exactly one contract artifact based on the selected API style:
- If **REST**: OpenAPI (or equivalent machine-readable REST contract) that satisfies Appendix A.
- If **GraphQL**: GraphQL schema that satisfies Appendix A.

The contract artifact MUST explicitly define:
- operations required for the selected model (animals, lifecycle transitions, applications/evaluation/decision, history; plus Model B deltas if selected)
- request/response shapes
- error categories (`ValidationError`, `NotFound`, `Conflict`, `AuthRequired`, `Forbidden` where applicable)
- pagination rules for collection operations
- deterministic ordering + tie-break rules for collection operations

#### 4.3 Deterministic Seed + Reset-to-Seed (Appendix B compliant) (MUST)
You MUST implement and document a **non-interactive reset-to-seed** mechanism that:
- restores the canonical seed dataset for the selected model
- is idempotent (safe to run twice)
- supports verification of Appendix B golden records and determinism checks

#### 4.4 Image handling constraints (Appendix C compliant) (MUST)
If the selected Target Model includes images, your implementation and contract MUST enforce Appendix C constraints, including:
- max 3 images per animal
- allowed content types (`image/jpeg`, `image/png`, `image/webp`)
- deterministic image ordering (primary `ordinal` asc, tie-break `imageId` asc)

#### 4.5 Acceptance verification (Appendix D) (MUST)
You MUST provide a benchmark-operator-friendly way to verify the implementation against Appendix D:
- Provide an “Acceptance Checklist” mapped to the relevant `AC-*` IDs for the selected model.
- Provide commands or steps to produce observable evidence (logs/output) for each acceptance item.

#### 4.6 Benchmark artifact bundle (Appendix E) (MUST)
You MUST produce operator-ready artifacts aligned to Appendix E:
- The exact prompt wrapper text (this message) saved into the run folder
- A run record skeleton capturing M-01..M-11 inputs (TTFR/TTFC, clarifications, reruns, interventions, etc.)
- Run instructions that are copy/paste friendly (run, reset-to-seed, verify acceptance)
- Evidence pointers for determinism checks and contract completeness checks

---

### 5) Run Instructions Requirements (Non-interactive) (MUST)
Provide a single “Run Instructions” section that includes:
- prerequisites (runtime versions if needed)
- install/build commands (non-interactive; no prompts)
- start commands (API and UI if applicable)
- reset-to-seed command/mutation
- verification commands/steps for:
  - seed invariants (Appendix B)
  - acceptance checks (Appendix D)

If you cannot make instructions fully non-interactive, record a clearly labeled `ASM-####` and explain why, but avoid this unless strictly necessary.

---

### 6) Reporting Format (MUST)
At completion, output a final “Run Summary” with:
- Selected Target Model and API Style
- List of all assumptions (`ASM-*`)
- Paths to:
  - contract artifact
  - run instructions
  - reset-to-seed mechanism
  - acceptance checklist / evidence
  - run folder bundle contents (Appendix E artifacts)

Do NOT claim completion without providing these paths.

---

### 7) Start Now
Confirm you understand the constraints above and begin implementation for the selected Target Model and API Style.


