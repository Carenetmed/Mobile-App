# Patient Profile Name Update Wiring

Task: 52.66

Status: Implemented

## Scope

Settings/Profile can now save the backend patient profile `name` through
`ProfileRepository.updatePatientMe`.

This slice is intentionally name-only.

## Runtime Behavior

`SettingsProfilePage` now:

- combines first name and last name into backend patient `name`
- calls `ProfileRepository.updatePatientMe(name: combinedName)`
- sends no `age`
- sends no `location`
- shows a saving label while the backend name update is pending
- shows safe backend/profile errors without claiming success
- updates the read-only patient profile summary from the backend response
- preserves the existing local save behavior for username, email, and bio

## Payload Boundary

The backend patient profile update payload is limited to:

```text
name
```

This slice does not send:

- age
- location
- username
- email
- bio
- user id
- patient profile id
- role
- phone
- password
- auth/security state
- verification state
- scheduling data
- public profile data
- destructive account data

## Failure Behavior

If the backend patient profile name update fails:

- the safe failure message is shown on Settings/Profile
- the page does not claim backend save success
- the local settings store is not updated by that failed save attempt

## Compatibility Behavior

If Settings/Profile is opened in a test/dev surface without a registered
`ProfileRepository`, the old local save path remains available. Configured app
runtime and focused tests use the repository-backed path.

## Verification

Focused tests cover:

- patient profile read success
- empty backend profile state
- safe patient profile read failure
- backend patient name update payload is name-only
- local username/email/bio save remains local
- backend update failure blocks a false local success

Commands:

```powershell
dart format lib\features\Home\presentation\pages\account_shell.dart test\features\home\account_flow_test.dart
flutter test test\features\home\account_flow_test.dart -r compact
flutter analyze lib\features\Home\presentation\pages\account_shell.dart test\features\home\account_flow_test.dart
```

## Still Deferred

- age update
- location update
- username persistence
- email mutation or verification
- bio persistence
- phone/OTP
- MFA/PIN/security changes
- logout/delete/deactivate backend behavior
- professional profile mutation
- verification upload/list
- admin verification dashboard
- scheduling smoke data
- public profile detail
- payments, notifications, reviews, calls, calendar sync, notes,
  prescriptions, or medical records
