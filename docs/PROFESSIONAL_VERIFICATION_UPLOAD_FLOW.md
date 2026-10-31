# Professional Verification Upload Flow

## APP-READY-088 Recovery Contract (In Progress)

The upload client now consumes BE077 signed headers when supplied: exact MIME,
actual byte length and create-only generation precondition. Metadata is typed,
normalized and immutable; malformed explicit new metadata cannot silently become
a legacy upload. Older responses without either new field remain compatible.
Only HTTPS signed URLs without userinfo/fragments are accepted, and only the
three approved headers may be forwarded. Account bearer headers stay on API
requests, not storage PUTs. A renewal response must retain the requested document
ID; the renewal request carries no client-supplied owner/profile authority.

Storage bytes are Uint8List rather than an ordinary integer list. The new
transport test observed the prior JSON encoding and incorrect length, then
proved the exact raw stream after repair. This is local transport proof, not
real GCS enforcement or PDF acceptance. Renewal/retry orchestration and complete
rollout remain in progress; the backend draft is audit-blocked and undeployed.

Within one upload operation, an explicitly expired new-contract capability is
renewed for the same document ID. An expiry-related storage401/403 can cause at
most one renewal and one repeated PUT; ordinary denial and legacy responses do
not enter that path. The injected clock decides whether to request renewal,
never whether storage/backend must authorize it. Completion may replay the same
ID, computed checksum and actual byte size once on an uncertain transport/server
result, only when the new replay-capable contract was received. Definite client
errors are not immediate retries. No second upload-init is used for recovery.

The current account is rechecked between phases and after successful completion,
so a late response after logout, account change or cancellation is not returned
as upload success. Cancellation prevents later phases. Storage redirects are
disabled and storage errors are not presented as
CareNet account authorization failures. A matching completion can report an
already-approved/rejected document: the success copy preserves that status
instead of incorrectly claiming that review is still pending.

This recovery is bounded and memory-only. It does not persist sensitive file
bytes or signed URLs, resume after process death, prove a timed-out PUT did not
arrive, or authorize abandoned-object deletion. A fresh user-initiated upload
after an exhausted operation remains a new attempt; cleanup safety and actual
provider acceptance stay explicit gates.

Local repaired-source results:1309 full tests, analyzer and staging debug APK
pass. Review-found late-success and definite HTTP405/413/415/429 retry defects
have failing-before/passing-after regressions. Fresh staging/production lint
passes with zero errors/four warnings each, without suppression. CI and live-provider
proof remain separate gates; no dependency or native source change is included.

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
