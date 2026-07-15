# Google Account Linking Regression

**Task:** 52.92
**Status:** Passed
**Date:** 2026-07-15

## Scope

This checkpoint proves the constrained Google account linking path added in
52.91 before choosing any broader account/provider surface.

No runtime behavior was added in this slice.

## Evidence

- `flutter test test\features\home\account_flow_test.dart -r expanded`
  - 32 tests passed.
- `flutter analyze lib\features\Home\presentation\pages\account_shell.dart test\features\home\account_flow_test.dart`
  - No issues found.
- Source/test inspection confirmed the Account tile placement, configured
  provider token handoff, safe error mapping, and no local account mutation.

## Covered Behaviors

- Account exposes `Google account` below `Authentication` and before
  `Settings & Profile`.
- Missing provider config leaves the Google account row disabled and does not
  call either `GoogleIdTokenProvider.signInIdToken` or
  `AuthRepository.googleLink`.
- Configured provider success sends the provider-returned token to
  `AuthRepository.googleLink`.
- Success copy appears only after repository success.
- Provider failure shows provider-safe copy and does not call the backend link
  method.
- Backend validation/collision failure shows
  `This Google account cannot be linked here.`
- Backend unauthorized failure shows `Please sign in again.`
- Raw backend failure copy is not rendered.
- The linked account success path keeps backend email, role, and status visible
  from `AccountRepository.currentAccount`; it does not fake local session/user
  mutation.

## Negative Coverage

The regression confirms no UI exposure for:

- Google ID tokens
- raw provider payloads
- raw backend validation/unauthorized messages
- Google unlinking
- Google sign-up role selection
- production OAuth claims

## Still Deferred

- Google sign-up role selection
- Google unlinking
- cross-email linking
- recovery linking
- recent re-authentication policy
- phone/OTP
- MFA/PIN enablement
- production OAuth consent/app verification
- release/Play signing fingerprints
- iOS Google proof
- profile creation
- admin verification dashboard
- payments
- notifications
- reviews
- calls
- calendar sync
- notes
- prescriptions
- staging data
- production readiness claims

## Next

Select the next backend-completed Flutter surface deliberately. Do not expand
Google/provider/account behavior without a separate decision slice.
