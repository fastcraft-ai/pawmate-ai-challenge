# Changelog

All notable changes to the PawMate AI Challenge specification will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v2.0.0] - 2025-12-18

### Breaking Changes
- **Mandatory tech stack requirements added for benchmark consistency**
  - Backend: Node.js + Express required (previously: any backend framework)
  - Database: SQLite required (previously: any database)
  - Frontend: Vite + React + TypeScript required (previously: any frontend framework)
  - Project structure: Separate frontend/backend projects required
  - No Docker or containerization allowed
  - Cross-platform compatibility (macOS/Windows) with `npm install && npm run dev` required

### Added
- 9 new normative requirements (REQ-BENCH-0001-A through REQ-BENCH-0009-A) enforcing tech stack
- New "Required Tech Stack" section in README.md
- Tech stack constraints in section 3.0 of both API and UI prompt templates

### Changed
- `docs/Master_Functional_Spec.md`: Replaced "technology-agnostic" with prescribed tech stack
- `README.md`: Replaced "technology-agnostic" claim with "Required tech stack" section
- `prompts/api_start_prompt_template.md`: Added tech stack constraints in new section 3.0
- `prompts/ui_start_prompt_template.md`: Added frontend tech stack constraints in new section 3.0
- `docs/Benchmarking_Method.md`: Updated scope to reflect prescribed tech stack instead of technology-agnostic

### Rationale
This change ensures reliable, comparable benchmarking results across all AI tools by eliminating variability from framework and database differences.

## [v1.0.2] - 2024-12-17

### Changed
- Revised `docs/UI_Requirements.md` to be principles-based (not implementation-specific)
  - Removed hardcoded endpoint assumptions (API chooses patterns)
  - Changed to contract-driven discovery approach
  - Maintains same 14 normative requirements (REQ-UI-0001-A through REQ-UI-0014-A)
  - Now technology-agnostic and works before API is built

## [v1.0.1] - 2024-12-16

### Added
- `docs/UI_Requirements.md` - Principles-based guidance for UI-API integration

### Changed
- Updated prompts to reference UI_Requirements.md for contract-driven UI development

### Note
No changes to core functional requirements (Master_Functional_Spec.md, API_Contract.md)

## [v1.0.0] - 2024-12-15

### Added
- Initial release of PawMate AI Challenge specification
- Master Functional Specification with Model A and Model B
- API Contract requirements for REST and GraphQL
- Seed Data specification with deterministic reset-to-seed
- Image Handling constraints
- Acceptance Criteria for verification
- Benchmarking Method and procedure
- Scoring Rubric
- Run initialization scripts
- API and UI start prompt templates

