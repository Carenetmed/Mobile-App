# Google Account Linking Wiring

**Task:** 52.91
**Status:** Done
**Date:** 2026-07-15

## Scope

The Account screen now exposes a constrained `Google account` entry below
`Authentication` and before `Settings & Profile`.

When a `GoogleIdTokenProvider` is configured, tapping the entry obtains a real
Google ID token through `GoogleIdTokenProvider.signInIdToken()` and sends it to
`AuthRepository.googleLink`.

## Runtime Behavior

- Missing Google provider config keeps the row disabled and shows
  `Google account linking is not configured yet.`
- Configured provider success calls `AuthRepository.googleLink`.
- Success appears only after the repository call completes.
- Provider failures show safe provider copy and do not call `googleLink`.
- Backend validation/collision failures show
  `This Google account cannot be linked here.`
- Backend unauthorized failures show `Please sign in again.`
- Network/server/unknown backend failures show a generic retry message.

## Non-Behavior

This slice does not mutate the local session, account email, role, status, or
profile after linking. Those fields remain backend-owned and should be refreshed
only through an explicit future account refresh path.

This slice does not add Google sign-up role selection, unlinking, cross-email
linking, recovery linking, recent re-authentication, phone/OTP, MFA, production
OAuth, release signing, iOS proof, profile creation, admin verification,
payments, notifications, reviews, calls, calendar sync, notes, prescriptions,
staging data, or production claims.

## Verification

- `flutter test test\features\home\account_flow_test.dart -r expanded`
- `flutter analyze lib\features\Home\presentation\pages\account_shell.dart test\features\home\account_flow_test.dart`

## Next

Run `52.92` as a regression checkpoint before choosing any broader
account/provider surface.
