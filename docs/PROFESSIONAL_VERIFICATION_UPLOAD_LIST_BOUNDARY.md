# Professional Verification Upload/List UI Boundary

Task: 52.75

Status: Accepted boundary

## Context

Professional verification upload/list is the next selected backend-completed
Flutter lane. Backend documentation exposes these professional-owned routes:

- `POST /verification/documents/upload-init`
- `POST /verification/documents/:documentId/upload-complete`
- `GET /verification/documents`

The backend rules are sensitive:

- verification documents are private by default
- professional routes require authenticated `PROFESSIONAL`
- documents belong to the backend-authenticated professional profile
- upload-init returns a short-lived signed upload URL
- upload-init/upload-complete/list responses must not expose private storage
  object keys, file contents, public URLs, provider credentials, or raw checksum
  values
- upload-complete keeps document status `PENDING`
- public professional APIs must never expose verification document records

## Decision

Start with a professional-owned verification surface under Manage Profile.

The first runtime pass should include both:

1. owner document list/status read
2. one controlled upload flow using upload-init, signed upload PUT, and
   upload-complete

Reason: upload without list/status gives the user no honest result state, while
list-only leaves the selected backend surface half-consumed. The first runtime
slice may still split repository boundary and UI wiring if implementation size
requires it.

## Entry Point

Use `manageProfile` as the first entry point.

Recommended UI:

- add a visible `Verification` section to Manage Profile for professional users
  or when a professional profile is loaded
- show the current backend-owned verification status from
  `ProfessionalProfile.verificationStatus` when available
- route to a dedicated verification documents screen only after the boundary
  repository/screen slice exists

Do not place this first under Account because Account already mixes patient
settings/auth-security concerns. Do not place it under public profile because
verification documents are private and owner-only.

## Accepted Flutter Boundary

Recommended files for the next implementation sequence:

- `lib/features/Home/domain/entities/verification_document.dart`
- `lib/features/Home/domain/entities/verification_upload_request.dart`
- `lib/features/Home/data/services/verification_api_client.dart`
- `lib/features/Home/data/repositories/verification_repository.dart`
- `lib/features/Home/presentation/pages/professional_verification_shell.dart`
- focused tests under `test/features/home/`

The repository must use the existing session/bearer-token pattern.

The UI must not trust client-supplied owner ids, professional profile ids,
verification status, document status, storage object keys, or signed URLs from
visible state.

## Document Types

Use a small MVP document type set for copy and tests:

- `LICENSE`
- `IDENTITY`
- `CERTIFICATION`

Do not claim these are the final compliance requirements. They are UI labels
for the first upload/list surface until product/legal requirements are accepted.

## File Picker Rules

The first runtime upload flow should accept only:

- PDF
- JPEG
- PNG

Use a conservative app-side max size of 10 MB unless backend docs expose a
stricter value through the upload-init validation contract. If upload-init
rejects the file as too large or unsupported, show a safe validation message.

Do not add camera capture, multi-file batch upload, background upload queues, or
document editing in the first runtime pass.

## Upload Flow

Accepted sequence:

1. User selects one document type.
2. User selects one local file.
3. Flutter validates extension/MIME shape and approximate size before calling
   upload-init.
4. Flutter calls `POST /verification/documents/upload-init` with only safe
   metadata required by the backend contract.
5. Flutter uploads the file bytes to the returned signed upload URL.
6. Flutter calls
   `POST /verification/documents/:documentId/upload-complete`.
7. Flutter reloads `GET /verification/documents`.
8. UI shows the backend document status, normally `PENDING`.

The upload PUT helper must keep signed URL handling internal to the repository
or service layer.

## Upload-Complete Metadata

Send only metadata the backend accepts safely:

- file size, if available
- checksum only if Flutter computes it locally without logging it and the
  backend contract accepts it

If checksum calculation adds implementation risk, defer checksum and rely on
file size/MIME metadata for the first runtime pass.

Do not claim malware scanning, provider-object verification, medical review, or
final verification has happened.

## Owner Document List UI

Document list/status should show only owner-visible safe metadata:

- document type
- status
- MIME type, if returned
- file size, if returned
- created/submitted timestamps, if returned
- updated/decision timestamp, if returned

Do not show:

- signed upload/read URLs
- private object keys
- storage bucket/provider credentials
- raw checksum values
- local full file paths
- file contents/previews
- admin notes
- rejection reason unless backend later supports it

## Safe States

The UI must handle:

- loading documents
- no documents submitted yet
- upload ready
- upload in progress
- upload completed and pending review
- approved document/status
- rejected document/status without detailed reason unless backend supports it
- missing backend configuration
- unauthenticated/expired session
- wrong role
- missing professional profile
- validation failure
- storage unavailable
- network/server failure

Use safe copy. Do not expose raw signed URLs, object keys, backend stack traces,
local file paths, or private document details.

## Tests Required Before Runtime Acceptance

Repository/API tests should prove:

- protected routes send bearer auth
- upload-init sends only allowed metadata
- upload-complete sends only allowed completion metadata
- owner document list parses only safe projection fields
- missing config, unauthorized, validation, and server/storage failures map to
  safe errors
- signed upload URL is used only for the upload request and is not surfaced in
  public entities

Widget/flow tests should prove:

- Manage Profile exposes a verification entry only in the scoped professional
  path
- documents loading/empty/success/failure states render safely
- successful upload reloads the owner document list and shows pending status
- upload failure does not claim success
- no signed URL/object key/local path is rendered
- admin review, public detail, payments, reviews, calls, calendar sync, notes,
  prescriptions, and staging/prod claims do not appear

## Explicitly Deferred

- admin verification queue, signed-read, approve, and reject UI
- rejection reason persistence/display
- file preview/read/download inside Flutter
- camera capture
- multi-file batch upload
- background upload/retry queue
- malware scanning, provider object verification, and checksum proof claims
- public professional detail endpoint
- public display of document metadata
- payments, reviews, calls, calendar sync, notes, prescriptions, medical
  records
- staging data setup and production release readiness

## Next

Queue `52.76 - Add Professional Verification Repository Boundary`.

Scope for 52.76:

- add verification entities, API client, repository, and focused tests
- include owner document list, upload-init, signed upload PUT helper, and
  upload-complete boundaries
- do not wire runtime screens yet
- do not add admin review UI
- do not expose signed URLs/object keys in public domain entities
