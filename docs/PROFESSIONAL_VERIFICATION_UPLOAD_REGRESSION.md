# Professional Verification Upload Regression

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
