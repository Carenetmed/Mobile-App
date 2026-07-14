# Professional Display Name Update Wiring

Task: 52.83

Status: Implemented

## Outcome

The existing `editYourName` route now updates the authenticated
professional's backend `displayName` only.

## Runtime Behavior

The screen now:

- reads the existing professional profile through
  `ProfileRepository.professionalMe`
- pre-fills the backend `displayName`
- validates the submitted display name before saving
- calls `ProfileRepository.updateProfessionalMe` with the new `displayName`
- preserves existing `category`, `specialty`, and `bio`
- blocks save when no professional profile exists
- shows safe loading, validation, empty-profile, success, and backend-failure
  states

## Explicit Non-Behavior

This slice does not:

- create a professional profile
- edit category or specialty
- send website or address fields
- change account email, phone, role, or status
- change verification status or documents
- change availability or appointment state
- add payments, reviews, calls, calendar sync, notes, or prescriptions
- claim staging or production readiness

## Evidence

Focused verification:

- `flutter test test/features/home/manage_profile_flow_test.dart -r expanded`
  passed with 26 tests
- `flutter analyze lib/features/Home/presentation/pages/edit_your_name_shell.dart lib/features/Home/presentation/pages/manage_profile_shell.dart test/features/home/manage_profile_flow_test.dart`
  reported no issues

The focused tests prove:

- backend `displayName` prefill
- display-name-only save
- preservation of `category`, `specialty`, and `bio`
- empty-profile save blocking without partial profile creation
- safe backend save failure without false success
- validation failure without repository update

## Next

Run `52.84 - Professional Display Name Update Regression Checkpoint` before
choosing any broader profile-editing surface.

