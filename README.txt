PAWMATE AI CHALLENGE — OPERATOR GUIDE (DOCS-ONLY REPO)
=====================================================

WHAT THIS IS
------------
This repository contains a documentation-first, tool-agnostic benchmarking spec and
operator templates for evaluating AI coding tools in a repeatable, evidence-based way.

This repo does NOT ship an application implementation. It provides:
- the "frozen spec" inputs (what to build),
- strict scope guardrails (what NOT to build),
- and the operator templates used to run, record, score, and compare benchmark runs.

PAWMATE DOMAIN (WHY IT’S DIFFERENT)
----------------------------------
PawMate is a pet adoption management domain:
Helping animals find homes—and people find friends.

This benchmark increases difficulty via:
- explicit animal lifecycle state machines
- adoption application evaluation + decisions
- policy enforcement + override logging
- decision transparency / explainability

KEY CONSTRAINTS (SUMMARY)
-------------------------
- Two selectable models: Model A (Minimum) or Model B (Full).
- API-first: the API is the system of record; UI is optional.
- Choose exactly ONE API style: REST OR GraphQL (do not implement both).
- Exactly ONE contract artifact is required:
  - REST: machine-readable REST contract (e.g., OpenAPI)
  - GraphQL: GraphQL schema
- Determinism is required: deterministic seed data + a non-interactive reset-to-seed mechanism.
- No external integrations (no third-party services).
- No overreach: do not add features beyond explicit REQ-*; out-of-scope items are NOR-*.
- Privacy requirements are out of scope.

ARTIFACT OVERVIEW (WHERE THINGS LIVE)
-------------------------------------
1) Canonical spec + appendices (source of truth)
   - docs/01-Master_Functional_Spec.md
       Functional requirements, REQ-* IDs, NOR-* guardrails, Model A/B definition.
   - docs/02-Appendix_A_API_Contract.md
       Contract artifact requirements (REST/GraphQL), errors, pagination, ordering determinism.
   - docs/03-Appendix_B_Seed_Data.md
       Deterministic seed dataset + reset-to-seed requirements and golden checks.
   - docs/04-Appendix_C_Image_Handling.md
       Image handling constraints (if images apply to the selected model).
   - docs/05-Appendix_D_Acceptance_Criteria.md
       Acceptance criteria (how "feature complete" is determined).
   - docs/06-Appendix_E_Benchmarking_Method.md
       End-to-end benchmark procedure, required artifacts, metrics (M-01..M-11), evidence rules.

2) Operator templates (copy/paste)
   - docs/07-Appendix_F_Prompt_Wrapper.md
       Standardized prompt wrapper used to start each run (pins model, API style, spec ref, guardrails).
   - docs/08-Appendix_G_Run_Log_Template.md
       Run record template (per tool, per run) including metrics M-01..M-11 and evidence pointers.
   - docs/09-Appendix_H_Scoring_Rubric.md
       How to score runs (evidence-first; Unknown handling; overreach penalties).
   - docs/10-Appendix_I_Comparison_Report_Template.md
       How to compare multiple tools for the same spec ref + model, including a standard table schema.

3) Root readmes (roles)
   - README.md
       High-level repository overview, constraints, and links-first quickstart.
   - README.txt (this file)
       Plain-text, step-by-step operator guide for distributing or printing.


RUN A BENCHMARK (END-TO-END CHECKLIST)
-------------------------------------
This is a tool-agnostic checklist. Use the canonical templates in docs/07..docs/10 for
copy/paste content and recordkeeping.

1) Select the benchmark target (before you start any tool)
   a) Choose ONE model: Model A (Minimum) OR Model B (Full).
      - Source of truth: docs/01-Master_Functional_Spec.md
   b) Choose ONE API style: REST OR GraphQL (do not implement both).
   c) Freeze and record the spec reference you are benchmarking (commit/tag/hash or other
      immutable identifier) and the in-scope file list (at minimum docs/01..docs/06).

2) Prepare a clean starting state
   a) Start from a clean workspace for the frozen spec reference.
   b) Ensure no leftover generated artifacts from prior runs/tools.

3) Run the tool twice (reproducibility requirement)
   You will perform two independent runs for the same tool + model + spec reference:
   - Run 1: ToolX-Model[ A|B ]-Run1
   - Run 2: ToolX-Model[ A|B ]-Run2

4) For each run (Run 1 and Run 2)
   a) Create a run record file using docs/08-Appendix_G_Run_Log_Template.md.
   b) Copy/paste the standardized prompt wrapper from docs/07-Appendix_F_Prompt_Wrapper.md,
      fill only the bracketed fields, and submit it to the tool under test.
   c) Start timing at prompt submission (TTFR/TTFC are measured from this point).
   d) As the run proceeds:
      - Record clarifications the tool asks that require your input (M-03).
      - Record any reruns/regenerations you trigger (M-05) and why.
      - Record any manual edits you make beyond copy/paste execution (M-04).
      - If required evidence is missing, record values as Unknown and note what evidence
        is missing (do not guess).
   e) Collect the required artifacts for the run (store in a run folder):
      - Prompt wrapper text used (exact)
      - Full tool transcript
      - Generated run instructions (run / reset-to-seed / verify acceptance)
      - Contract artifact (OpenAPI for REST OR GraphQL schema for GraphQL)
      - Acceptance evidence (mapped to Appendix D)
      - Determinism evidence (reset-to-seed + golden checks)
      - Overreach notes/evidence (NOR-* violations or features beyond REQ-*)

5) Fill the required run metrics (M-01..M-11) in the run record template
   Use docs/08-Appendix_G_Run_Log_Template.md and ensure all metrics are recorded:
   - M-01 TTFR (time to first runnable)
   - M-02 TTFC (time to feature complete)
   - M-03 Clarifications requested
   - M-04 Operator interventions (manual edits)
   - M-05 Reruns/regeneration attempts
   - M-06 Acceptance pass rate (Model A or B)
   - M-07 Overreach incidents
   - M-08 Reproducibility notes (Run 1 vs Run 2)
   - M-09 Determinism compliance (seed + reset)
   - M-10 Contract artifact completeness
   - M-11 Run instructions quality

6) Evidence rule (do not guess)
   If you cannot produce the required evidence for a metric, record the value as Unknown
   and write down what evidence is missing. Scoring is evidence-first.


NOTE ON LEGACY CONTENT
----------------------
This PawMate spec was derived from a prior Pet Store benchmarking harness.
The PawMate source of truth is the root docs/ folder.


