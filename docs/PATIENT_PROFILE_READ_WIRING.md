# Patient Profile Read Wiring

Task: 52.63

Status: Implemented

## Scope

Settings/Profile now reads the backend-backed patient self profile through
`ProfileRepository.patientMe`.

This slice is read-only for patient profile data. It does not create or update
patient profiles.

## Runtime Behavior

`SettingsProfilePage` now:

- accepts an optional `ProfileRepository` for tests and scoped injection
- uses the registered `ProfileRepository` when available
- skips backend loading safely if no repository is registered
- calls `patientMe`
- shows a patient profile read panel
- shows loading, error, and empty-profile states
- displays backend `name`, `age`, and `location` as read-only patient profile
  information when returned
- uses backend `name` for the header display when available
- splits backend `name` into first/last form fields only when the name has at
  least two tokens
- leaves username, email, bio, security, and destructive account behavior in
  the existing local/account flows

## Explicit Non-Mutation Boundary

This slice does not call:

- `ProfileRepository.updatePatientMe`
- `PUT /patients/me`

The local `Save Changes` button still writes only to `AccountLocalStore`.

## Safe States

| State | UI behavior |
| --- | --- |
| Loading | Shows `Loading patient profile...` |
| Empty profile / 404 mapped to null | Shows `No backend patient profile yet. Local settings remain editable.` |
| Auth/server/network failure | Shows the safe repository failure message or a generic safe message |
| Profile with name/age/location | Shows read-only backend summary values |

## Out Of Scope

- patient profile creation
- patient profile update
- editable age/location fields
- username persistence
- email mutation
- phone/OTP
- MFA/PIN/security changes
- logout/delete/deactivate behavior changes
- professional profile mutation
- verification upload/list
- admin verification dashboard
- scheduling smoke data
- public profile detail
- payments, notifications, reviews, calls, calendar sync, notes, prescriptions,
  or medical records

## Verification

Focused tests cover:

- backend patient profile read success
- empty backend profile state
- safe failure display
- local save does not call patient profile update
- existing local settings save behavior remains intact

Commands:

```powershell
flutter test test\features\home\account_flow_test.dart -r compact
flutter analyze lib\features\Home\presentation\pages\account_shell.dart test\features\home\account_flow_test.dart
```
