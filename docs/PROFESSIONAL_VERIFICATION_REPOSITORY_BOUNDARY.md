# Professional Verification Repository Boundary

Task: 52.76
Date: 2026-07-15

## Outcome

The Flutter app now has a repository/API boundary for the backend professional
verification document routes.

Implemented files:

- `lib/features/Home/domain/entities/verification_document.dart`
- `lib/features/Home/domain/entities/verification_upload_request.dart`
- `lib/features/Home/data/models/verification_document_model.dart`
- `lib/features/Home/data/services/verification_api_client.dart`
- `lib/features/Home/data/repositories/verification_repository.dart`
- `test/features/home/verification_repository_test.dart`

`VerificationRepository` requires a stored session for protected verification
calls and sends bearer auth through `VerificationApiClient`.

## Backend Routes Consumed

- `GET /verification/documents`
- `POST /verification/documents/upload-init`
- `PUT <signed upload URL>`
- `POST /verification/documents/:documentId/upload-complete`

Upload-init sends backend contract fields:

- `documentType`
- `originalFileName`
- `mimeType`
- `fileSizeBytes`

Upload-complete sends:

- `fileSizeBytes`
- optional `checksumSha256`

## Safety Boundary

The public Flutter entity exposes only safe document metadata:

- document id
- document type
- status
- storage provider label
- MIME type
- file size
- checksum-provided boolean
- uploaded timestamp

The signed upload URL is held only inside the API-client/repository upload flow.
It is not returned as a domain entity field.

The boundary does not expose signed upload/read URLs, storage object keys,
backend credentials, local file paths, file contents/previews, raw checksum
values in list entities, admin notes, rejection reasons, or public document
access.

## Tests

`test/features/home/verification_repository_test.dart` proves:

- owner document list sends bearer auth
- owner document list parses the safe projection
- upload-init sends only allowed metadata
- signed upload PUT sends no authorization header
- upload-complete uses the backend document id from upload-init
- checksum is sent only when provided
- protected calls require a stored session
- missing backend config fails closed
- server failures map to safe user-facing failures

## Explicitly Not Done

This slice does not wire runtime screens.

Still deferred: Manage Profile verification entry/screen, file picker UI,
visible upload progress/retry/cancel UX, admin verification review dashboard,
rejection reason display, private document preview/read/download, camera
capture, batch/background upload, file scanning/provider verification claims,
public document exposure, payments, reviews, calls, calendar sync, notes,
prescriptions, staging data, and production-release claims.

## Next Slice

`52.77` should wire the first runtime Manage Profile verification document
screen against `VerificationRepository` without exposing private storage data.
