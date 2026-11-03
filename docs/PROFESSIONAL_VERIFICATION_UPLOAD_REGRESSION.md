# Professional Verification Upload Regression

## APP-READY-090 Task Spec - Confirmed Provider Expiry

Status: IN PROGRESS within APP-READY-082. Base `7da0d68`.
Goal: consume actual storage expiry from backend
[PR191](https://github.com/ridwanmullick/carenet-backend-lab/pull/191), without
confusing signed-capability expiry with account authority or uncertain PUTs.

Allowed: verification API/repository, typed storage failure, focused tests,
explicit existing XML dependency and canonical docs. Not allowed: shared auth,
widgets/routes, native, backend, cloud/provider changes or cleanup.

Require bad-response400 + ExpiredToken + explicit expired-token message, or403
+ AccessDenied + explicit expired-request message; XML MIME, at most16KiB UTF8,
one unqualified Error root and one plain Code/Message. Reject DTD/entities,
duplicates, namespaces, malformed XML and ambiguous top-level text/CDATA. Retain
only safe reason/status; never expose raw XML, capabilities or provider internals.

One owner-rechecked same-document renewal for new-contract responses only;
same bytes/headers, at most two PUTs, no second upload-init. Confirmed expiry
does not require device-clock agreement and never grants backend authority.
Generic400/403,401,412,timeout and malformed responses do not authorize retry.
Proactive renewal and bounded matching completion replay remain unchanged.

Tests: real raw-XML Dio classification and adapter/repository pipeline; both
confirmed forms, wrong status/code, permission/signature denial, malformed and
oversized XML, one-renewal bound, legacy, owner/logout/cancel, no false completion.
All104 focused and1359 full tests pass, zero skipped; analyzer is clean and
staging debug APK passes. The three top-level ambiguity cases fail before repair
and pass afterward. Independent re-review is clear. Fresh staging/production
release lint passes all652 tasks; protected signing,30 environment probes,
backup privacy and iOS source configuration pass. Ignored Windows SDK paths
needed escaping; no native source change or lint suppression. Signed artifacts
and PR/merged CI remain gates.

Inventory: retained1312 plus31 storage classification/boundary/pipeline tests
and16 recovery tests =1359. The two retained403 cases are renamed to require
confirmed expiry, preserving their once-only/repeated-error coverage. No test
removed, skipped or disabled. Initial validation caught a zero-filled new test
file and an analyzer style issue; both were repaired, then all gates rerun.

Later-device steps: owned professional fixture, expired signed capability,
same-document renewal and one submitted document; interrupt upload and require
no false success/session loss. Do not execute physical acceptance or approve
real evidence here. Cross-attempt uncertain-PUT settlement remains open.

## APP-READY-082E - In-Flight Cancellation

The added `cancelling an in-flight storage upload prevents completion` test
uses the real repository, API client and Dio dispatch with a controlled adapter.
It waits until the signed PUT enters `fetch`, cancels twice, requires the
adapter's cancellation future to resolve and expects
`VerificationUploadCancelled`. Only upload-init may reach the API; no
upload-complete request may occur, including after the pending response is
released during cleanup. Both synchronization and cleanup waits are bounded.

The test fails with a five-second cancellation timeout when the production
controller-to-Dio binding is temporarily removed. Restoring the unchanged
production source passes all nine repository and 45 combined repository/profile
tests. No existing test was removed or weakened. This proves the cancellation
transport boundary, not real socket teardown, remote object deletion or cloud
acceptance. Full analysis, all 968 tests (967 retained plus one added), staging
debug APK and fresh 623-task release lint pass. The initial local lint failure
was ignored Windows SDK path escaping, repaired without tracked build changes.
Independent bounded review passes; reviewed-change and merged-result CI remain
delivery gates. Physical/provider proof remains a separate approved fixture gate.
The historical regression checkpoint below retains its original scope.

Task: 52.80
Date: 2026-07-15

## Outcome

The professional verification upload/list lane is regression-checked for the
current frontend milestone boundary.

## Evidence

Commands run:

- `flutter test test/features/home/manage_profile_flow_test.dart -r expanded`
- `flutter analyze lib/features/Home/presentation/pages/professional_verification_documents_shell.dart lib/features/Home/presentation/pages/manage_profile_shell.dart test/features/home/manage_profile_flow_test.dart`
- `Select-String -Path pubspec.yaml -Pattern 'file_picker|image_picker'`
- `rg -n "signedUrl|storageObjectKey|raw-secret-checksum|private/object|Admin|Payment|Review|Prescription|Calendar sync|staging|production" lib/features/Home/presentation/pages/professional_verification_documents_shell.dart test/features/home/manage_profile_flow_test.dart`

Results:

- 24 focused Manage Profile / verification tests passed.
- Focused analyzer reported no issues.
- `pubspec.yaml` now has `file_picker` for the PDF-capable upload path.
- Privacy-surface search found only negative test assertions for private terms,
  not exposed UI strings in the verification documents screen.

## Proven Behaviors

The focused test suite covers:

- Manage Profile opens the verification documents shell.
- Owner document list success renders safe status metadata.
- Owner document list empty state is honest.
- Owner document list backend failure shows safe copy.
- Upload sends selected document type, original filename, MIME type, bytes, and
  file size to `VerificationRepository.uploadDocument`.
- Upload supports changing the document type to `IDENTITY`.
- Unsupported file type is rejected before repository upload.
- Files over 10 MB are rejected before repository upload.
- Picker cancellation does not call repository upload.
- Backend upload failure shows safe copy and no success state.

## Privacy Boundary

The current screen does not render:

- signed upload/read URLs
- storage object keys
- local full file paths
- file previews/content
- raw checksum values
- admin review data
- rejection reasons
- public document access
- staging or production-readiness claims

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

`52.81` should decide the next backend-completed Flutter surface after the
professional verification upload/list regression.
