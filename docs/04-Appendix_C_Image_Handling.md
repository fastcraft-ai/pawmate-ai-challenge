# Appendix C — Simple Image Handling (Model A + Model B)

## Purpose
This appendix defines **simple, minimal, maintainable** image handling requirements that satisfy:
- `docs/01-Master_Functional_Spec.md`: `REQ-IMG-0001-A`..`REQ-IMG-0003-A`
- `docs/02-Appendix_A_API_Contract.md`: image contract surface and error/determinism rules
- `docs/03-Appendix_B_Seed_Data.md`: seeded images IMG-0001..IMG-0004 and deterministic per-animal ordering expectations

This appendix is **technology-agnostic** and compatible with **REST or GraphQL** implementations.

---

## Non-Goals / Out of Scope (Normative)
Image handling MUST remain simple and MUST NOT require:
- external object storage services or CDNs
- external image processing services
- malware scanning mandates
- EXIF stripping mandates
- privacy/PII rules (explicitly out of scope for this project)

---

## Image Association Models (Acceptable Options)
Implementers MUST choose **one** of the following abstract models and document the choice in the API contract artifact (Appendix A).

### Option 1 — Stored Media (Binary Stored Locally, Served via API)
**Definition:** The system stores the image binary locally (e.g., filesystem or embedded storage) and serves image content via the API.

Minimum required behaviors (high level):
- The API supports adding image content to an animal.
- The API supports retrieving image metadata and retrieving image content.
- Animal read responses include `images[]` entries that reference the stored images.

### Option 2 — Stored References (References Stored, Retrievable via API Without External Dependencies)
**Definition:** The system stores image references (logical references controlled by the system) and exposes them via the API. References MUST NOT require any external service dependency to be meaningful/usable in benchmarks.

Minimum required behaviors (high level):
- The API supports adding/removing an image reference to/from an animal.
- Animal read responses include `images[]` entries that expose those references.
- If the reference points to content, that content MUST be retrievable via the API (not via external CDN/storage).

---

## Minimum Image Metadata (Normative)
Regardless of option, an image associated with an animal MUST be representable with the following minimum metadata fields in the contract artifact.

### Required fields
- `imageId` OR a stable reference string (unique within the system)
- `animalId` (the associated animal)
- `fileName` (logical name, not necessarily a filesystem path)
- `contentType` (conceptual content type, e.g., `image/jpeg`)
- `ordinal` (or equivalent ordering field used to present `images[]` deterministically)

### Recommended fields
- `byteSize` (recommended for validation/transparency)
- `altText` (SHOULD): human-readable alternative text for accessibility and UI rendering

### Deterministic ordering rule (Normative)
Whenever an animal includes `images[]`, the order MUST be deterministic:
- primary: `ordinal` ascending
- tie-break: `imageId` (or stable reference) ascending

This supports Appendix B seed verification (e.g., ANM-0003 has IMG-0002..IMG-0004 in deterministic order).

---

## Mapping to Contract Artifact (Normative)
The API contract artifact MUST:
- declare which image model option is implemented (Option 1 or Option 2)
- define all image-related operations required by Appendix A (add/remove/associate and retrieval semantics)
- define request/response shapes and validation/error behaviors for image operations using the error categories in Appendix A

---

## Constraints (MUST unless noted otherwise)
These constraints are selected to be simple, maintainable, and consistent with the seed dataset (Appendix B uses up to **3** images per animal).

### C-01: Maximum images per animal (MUST)
- An animal MUST NOT have more than **3** associated images.
- Attempting to add a 4th image MUST result in **ValidationError**.

### C-02: Allowed content types (MUST)
- The system MUST accept only these content types for images:
  - `image/jpeg`
  - `image/png`
  - `image/webp`
- Any other content type MUST result in **ValidationError**.

### C-03: Maximum image size (Recommended default)
- Recommended default maximum size per image: **2 MiB** (2,097,152 bytes).
- If an implementation chooses a different maximum, it MUST declare the chosen limit in the contract artifact and enforce it consistently.

### C-04: File naming and metadata (MUST/SHOULD)
- `fileName` MUST be treated as a logical label (not a filesystem path).
- `fileName` MUST be validated to prevent path traversal semantics (exact rules are implementer-defined but MUST be explicit in the contract).
- `altText` SHOULD be supported; if supported, validation rules (e.g., max length) MUST be defined in the contract.

---

## Required Flows and Observable Error States (Normative)
This section defines required behaviors for add/remove/retrieve flows. Concrete REST endpoints or GraphQL operations MUST be defined in the contract artifact (Appendix A).

### F-01: Add image to animal
**Inputs (conceptual):**
- `animalId` (required)
- `fileName` (required)
- `contentType` (required)
- `ordinal` (optional; if omitted, implementation MUST assign a deterministic ordinal)
- `altText` (optional)
- Option 1 only: binary image content (required)
- Option 2 only: reference payload (required) as defined by the contract

**Behavior:**
- If `animalId` does not exist → **NotFound**
- If `contentType` is not allowed → **ValidationError**
- If image size exceeds configured max → **ValidationError**
- If the animal already has 3 images → **ValidationError**
- On success, the operation MUST make the image association visible on subsequent animal reads and MUST return either:
  - the created image metadata record, and/or
  - the updated animal representation including `images[]`

### F-02: Remove image from animal
**Inputs (conceptual):**
- `animalId` (required)
- image selector: `imageId` or stable reference (required)

**Behavior (explicit):**
- If `animalId` does not exist → **NotFound**
- If the specified image is not associated with the animal → **NotFound** (not a no-op)
- On success, the removed image MUST no longer appear in the animal’s `images[]`.

### F-03: Retrieve animal includes `images[]` in deterministic order
For any animal read response that includes `images[]`:
- `images[]` MUST be present (may be empty).
- Ordering MUST be deterministic per this appendix:
  - primary: `ordinal` ascending
  - tie-break: `imageId` (or stable reference) ascending

### F-04: Retrieve image metadata and/or content
The contract MUST define how clients retrieve images depending on the chosen option:

- **Option 1 (Stored Media)**:
  - The API MUST support retrieving image metadata by `imageId`.
  - The API MUST support retrieving image content by `imageId` as a binary response with correct `contentType`.

- **Option 2 (Stored References)**:
  - The API MUST support retrieving image metadata by `imageId` (or stable reference).
  - If the implementation supports retrieval of image content, it MUST be retrievable via the API and MUST NOT depend on any external service.

---

## Seed + Reset Interaction (Normative)

### Canonical Seeded Images
The implementation MUST represent the following canonical seeded images and associations (from Appendix B):
- ANM-0002 has exactly 1 image: IMG-0001 (`fileName: milo-1.jpg`, `contentType: image/jpeg`, `ordinal: 1`)
- ANM-0003 has exactly 3 images in deterministic order:
  - IMG-0002 (`bella-1.jpg`, `image/jpeg`, `ordinal: 1`)
  - IMG-0003 (`bella-2.jpg`, `image/jpeg`, `ordinal: 2`)
  - IMG-0004 (`bella-3.jpg`, `image/jpeg`, `ordinal: 3`)
- At least 3 animals have zero images (Appendix B provides examples).

### Reset-to-Seed Semantics for Images
On reset-to-seed, the system MUST:
- Restore the canonical seeded image records/associations exactly as defined above.
- Remove any non-seed images and associations created after the baseline was established.

If Option 1 (Stored Media) is used:
- Reset-to-seed MUST also restore the canonical **image content** for seeded images (or equivalent deterministic content) so that retrieval is functional after reset.
- Reset-to-seed MUST delete any non-seed stored image content created after seed.

If Option 2 (Stored References) is used:
- Reset-to-seed MUST restore the canonical reference records such that the seeded references remain valid and retrievable via the API without external dependencies.


