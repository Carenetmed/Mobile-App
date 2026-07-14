# Professional Verification Upload Picker Boundary

Task: 52.78
Date: 2026-07-15

## Decision

Use a PDF-capable file picker boundary for the first professional verification
upload implementation.

The next runtime upload slice should add a direct file-picker dependency that
can select PDF, JPEG, and PNG files. The current direct dependency set only has
`image_picker`, which is not enough for a verification-document flow because the
accepted MVP document set includes PDF.

## Current Evidence

Existing direct dependency:

- `image_picker: ^1.1.2`

No direct dependency currently exists for:

- `file_picker`
- `file_selector`

Existing repository boundary:

- `VerificationUploadRequest.documentType`
- `VerificationUploadRequest.originalFileName`
- `VerificationUploadRequest.mimeType`
- `VerificationUploadRequest.fileBytes`
- optional `VerificationUploadRequest.fileSizeBytes`
- optional `VerificationUploadRequest.checksumSha256`

Existing upload sequence:

1. upload-init with safe metadata
2. signed upload PUT using the returned signed URL internally
3. upload-complete with file size and optional checksum
4. owner document list reload

## Accepted Upload UX Boundary

The first runtime upload implementation should support:

- one selected document type per upload
- document types: `LICENSE`, `IDENTITY`, `CERTIFICATION`
- one selected file per upload
- accepted file types: PDF, JPEG, PNG
- app-side max size: 10 MB unless backend exposes a stricter value
- safe validation errors before upload-init when extension/MIME/size is clearly invalid
- upload progress/in-progress state
- upload failure without claiming success
- upload-complete success followed by document list reload

## Dependency Direction

Prefer `file_picker` for the next upload implementation because it directly
supports selecting PDF and image files and returning file bytes/name/size from a
single user action.

Do not use `image_picker` for the first verification upload flow because it
would silently drop PDF support and make the implementation incompatible with
the accepted verification boundary.

## Data Rules

The UI may pass to `VerificationRepository.uploadDocument`:

- selected document type
- original file name
- MIME type
- file bytes
- file size

Checksum remains deferred for the first runtime upload UI unless it can be added
without logging or exposing raw checksum values.

The UI must not pass or render:

- professional profile id
- patient profile id
- document status
- storage object key
- signed upload/read URL
- local full file path
- raw checksum value
- backend credentials
- file contents/previews
- admin notes
- rejection reasons

## Safe States

The upload UI must handle:

- picker cancelled
- unsupported file type
- file too large
- missing backend config
- unauthenticated/expired session
- validation failure
- storage unavailable
- upload PUT failure
- upload-complete failure
- list reload failure after upload

Safe copy should not expose signed URLs, object keys, provider details, local
paths, stack traces, or raw backend error bodies.

## Out Of Scope

- admin review queue, signed-read, approve, or reject UI
- rejection reason display
- private file preview/download
- camera capture
- multi-file batch upload
- background upload queue
- malware scanning/provider verification claims
- public document metadata
- payments, reviews, calls, calendar sync, notes, prescriptions
- staging data setup
- production release readiness

## Next Slice

Queue `52.79 - Wire Professional Verification Upload Flow`.

Scope for 52.79:

- add the selected PDF-capable file picker dependency
- add document type selection
- select one PDF/JPEG/PNG file
- validate file type and 10 MB size cap
- call `VerificationRepository.uploadDocument`
- show loading/success/safe-error states
- reload owner documents after success
- keep checksum, previews, admin review, public exposure, and unrelated modules deferred
