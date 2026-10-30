# Professional Verification Upload Flow

## Current Load And Selection Safety (APP-READY-087)

APP-READY-087B narrows retained-state behavior: explicit401/403 authority failure
clears cached documents and loaded-success state. Network/server refresh failure
still retains the last successful list. Denial is not rendered as backend-empty.

Each document/readiness loader joins its current request rather than racing a
second refresh. Last successful documents remain visible during refresh and on
recoverable failure, with user-safe error copy. Pull-to-refresh retries both
sections. Initial errors are not an empty-success state.

File selection, validation and upload share one serialized operation. The chosen
document type is captured before picker launch. Cancellation or disposal while
the picker is open prevents its late result from entering upload-init. Picker
exceptions are caught without exposing platform details. Successful upload waits
for pre-existing reads, then refreshes authoritative documents/readiness.

SHA-256/progress/transport cancellation were delivered before this slice; the
original historical checksum-deferred notes below no longer describe runtime.
No signed-URL renewal, durable resume, orphan cleanup or deletion is implemented
by these UI changes. The backend remains authoritative for integrity and review.

## Historical Initial Implementation

Task: 52.79
Date: 2026-07-15

## Outcome

The professional verification documents shell now supports one controlled
verification document upload flow.

Implemented:

- direct `file_picker` dependency
- injectable `VerificationDocumentPicker` boundary for tests
- document type selection: `LICENSE`, `IDENTITY`, `CERTIFICATION`
- one PDF/JPEG/PNG file selection
- 10 MB app-side max size validation
- safe unsupported-file, empty-file, cancellation, upload, and backend failure states
- `VerificationRepository.uploadDocument` call with safe metadata and bytes
- owner document reload after successful upload

## Runtime Boundary

Upload happens only inside `professionalVerificationDocuments`.

The UI sends to `VerificationRepository.uploadDocument`:

- document type
- original file name
- MIME type
- file bytes
- file size

Checksum remains deferred.

## Safety Rules

The screen does not render:

- signed upload/read URLs
- storage object keys
- local full file paths
- file previews/content
- raw checksum values
- admin review data
- rejection reasons
- public document access
- backend stack traces or raw provider errors

The picker validates the user-selected file before upload-init can be called.

## Verification

- `dart format lib/features/Home/presentation/pages/professional_verification_documents_shell.dart test/features/home/manage_profile_flow_test.dart`
- `flutter test test/features/home/manage_profile_flow_test.dart -r expanded`
- `flutter analyze lib/features/Home/presentation/pages/professional_verification_documents_shell.dart lib/features/Home/presentation/pages/manage_profile_shell.dart test/features/home/manage_profile_flow_test.dart`

## Still Deferred

- checksum computation
- file preview/read/download
- admin review queue, signed-read, approve, and reject UI
- rejection reason display
- camera capture
- multi-file batch upload
- background upload queue
- malware scanning/provider verification claims
- public document metadata
- payments, reviews, calls, calendar sync, notes, prescriptions
- staging data setup
- production release readiness

## Next Slice

`52.80` should run a focused professional verification upload regression
checkpoint before selecting another backend-completed surface.
