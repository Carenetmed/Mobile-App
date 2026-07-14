# Professional Verification Documents Shell

Task: 52.77
Date: 2026-07-15

## Outcome

The app now exposes a Manage Profile entry for professional verification
documents.

Runtime route:

- `RouteName.professionalVerificationDocuments`
- `ProfessionalVerificationDocumentsShellPage`

The screen reads `VerificationRepository.documents()` and shows:

- safe loading state
- safe backend error state
- empty document state
- owner document status cards
- refresh action
- upload action as a clearly deferred locked card

## Safe Display Fields

The document cards display only the safe owner-list projection:

- document id
- document type
- status
- MIME type
- file size
- checksum-provided state
- uploaded date

The screen does not display signed URLs, storage object keys, local file paths,
file contents/previews, raw checksum values, admin notes, rejection reasons, or
public document access.

## Upload Status

Upload remains deferred in this slice.

Reason: the app has `image_picker` as a direct dependency, but no direct
PDF-capable file picker/file selector dependency. The backend boundary supports
PDF/JPEG/PNG style metadata, so the upload UI should not be implemented with an
image-only dependency.

## Verification

- `dart format lib/core/constants/navigators/routeName.dart lib/core/constants/navigators/router.dart lib/features/Home/presentation/pages/manage_profile_shell.dart lib/features/Home/presentation/pages/professional_verification_documents_shell.dart test/features/home/manage_profile_flow_test.dart`
- `flutter test test/features/home/manage_profile_flow_test.dart -r expanded`
- `flutter analyze lib/core/constants/navigators/routeName.dart lib/core/constants/navigators/router.dart lib/features/Home/presentation/pages/manage_profile_shell.dart lib/features/Home/presentation/pages/professional_verification_documents_shell.dart test/features/home/manage_profile_flow_test.dart`

## Next Slice

`52.78` should decide the upload UI and file-picker dependency boundary before
adding runtime upload behavior.
