# Next Surface After Find Mentor Regression Decision

Task: 52.74

Status: Accepted decision

## Context

Find Mentor public professional wiring is now regression-proven. The current
public-professional discovery path covers:

- Search public verified professional listing
- Search public availability read
- Search appointment request
- Specialist Details public professional and public availability path
- Find Mentor public professional listing and backend id handoff

Scheduling also has broad local regression coverage for request, own list,
cancel, accept/decline, completion, reschedule, and professional availability.
Its remaining major confidence gap is deliberate staging data, not another
Flutter runtime feature.

## Decision

Select professional verification upload/list as the next backend-completed
Flutter lane, but start with a boundary decision before runtime code.

Queue:

`52.75 - Define Professional Verification Upload/List UI Boundary`

This next slice should decide the exact Flutter repository/API surface, screen
entry point, file-picker behavior, document type list, upload-init/upload PUT,
upload-complete metadata, owner document list/status display, safe failure
states, and storage-readiness handling before implementation.

## Why this lane

| Candidate | Decision | Reason |
| --- | --- | --- |
| Verification upload/list | Selected, with boundary first | Backend docs show protected professional upload-init, upload-complete, and owner document list routes exist, but Flutter has no repository/UI boundary yet and uploaded documents are sensitive |
| Scheduling staging smoke | Defer | Existing Flutter scheduling behavior is already regression-proven; staging proof needs deliberate backend/staging test data and cleanup rules |
| Profile edit expansion | Defer | Name/category/specialty/website/address edits require field-by-field profile contracts and should not be mixed with sensitive verification upload |
| Google link/unlink/sign-up | Defer | Sign-in Google row is already scoped; link/unlink and sign-up role rules need separate auth/product decisions |
| Admin verification dashboard | Defer | Admin review is a separate role surface and should not be mixed into the professional mobile upload/list lane |
| Public professional detail endpoint | Defer | Backend public detail route remains future/deferred; do not invent it in Flutter |
| Release/staging/public access | Defer | Public/stakeholder staging and production release readiness remain separate operational lanes |

## Required boundary questions for 52.75

- Where should the professional verification entry point live in the current app
  navigation?
- Should the first runtime pass be document list/status only, upload flow only,
  or list plus upload together?
- Which document types are allowed in MVP copy?
- Which MIME types and size limits should the Flutter picker enforce before
  calling upload-init?
- How should Flutter perform the signed upload PUT without logging file names,
  paths, contents, object keys, credentials, signed URLs, or raw checksums?
- Which optional metadata, if any, should Flutter send to upload-complete?
- What safe status states should the UI show for pending, approved, rejected,
  failed upload, unavailable storage, and missing professional profile?
- How should missing backend config, unauthenticated sessions, wrong role,
  missing profile, validation errors, network errors, and storage-unavailable
  responses display?
- What tests are required before runtime upload is accepted?

## Explicit boundaries

The next slice must not implement runtime upload behavior. It must only define
the boundary and next implementation shape.

Future runtime slices must not:

- expose private storage object keys
- expose signed URLs in visible UI or logs
- store document contents in app state beyond the selected upload operation
- claim provider object verification, malware scanning, or checksum proof unless
  the backend contract explicitly supports it
- add admin approval/rejection UI
- add public professional detail behavior
- add payments, reviews, calls, calendar sync, notes, prescriptions, or release
  readiness claims

## Next

Run `52.75` as a decision-only boundary slice for professional verification
upload/list. Runtime repository and UI wiring should only follow after that
boundary is accepted.
