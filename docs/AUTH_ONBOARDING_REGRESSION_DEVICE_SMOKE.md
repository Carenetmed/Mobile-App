# Auth Onboarding Regression And Device Smoke

**Slice:** APP-72
**Date:** 2026-07-18
**Status:** Regression passed; device install smoke blocked by no attached ADB device.

## Purpose

Prove the APP-66 through APP-71 auth/onboarding redesign before adding more
product surface area.

This slice did not add runtime behavior.

## Regression Coverage

Focused auth/onboarding regression passed:

- welcome gateway
- role-first sign-up
- email sign-up completion
- Google sign-up role path through configured provider test doubles
- email sign-in
- Google sign-in
- session restore resolver
- patient setup save and skip
- professional application setup
- professional verification evidence list/upload/status
- safe backend/provider error behavior
- no fake phone OTP
- no fake booking readiness
- no fake professional approval or public listing

Command:

```powershell
flutter test test\features\onboarding\onboarding_gateway_test.dart test\features\authentication\sign_up_flow_test.dart test\features\authentication\finish_sign_up_test.dart test\features\authentication\sign_in_flow_test.dart test\features\authentication\session_restore_guard_test.dart test\features\onboarding\profile_setup_test.dart test\features\home\manage_profile_flow_test.dart
```

Result:

```text
70 tests passed
```

## Full Local Verification

Passed:

```powershell
flutter test
flutter analyze
git diff --check
flutter build apk --debug --dart-define=CARENET_API_BASE_URL=https://carenet-staging-mobile-gateway-2kbj9ok1.uc.gateway.dev
```

Results:

- full Flutter test suite passed with 293 tests
- analyzer reported no issues
- whitespace check passed
- staging-configured debug APK built at
  `build\app\outputs\flutter-apk\app-debug.apk`

## Device Smoke

ADB device check:

```powershell
adb devices -l
```

Result:

```text
List of devices attached
```

No Android device was attached/authorized, so install/manual device smoke was
not claimed in this slice.

## Product Verdict

The redesigned auth/onboarding path is locally regression-green.

The following remain deferred and must not be treated as complete from this
slice:

- backend readiness endpoint
- return-to-intent booking gate
- phone OTP
- production app links
- server-side professional drafts/resume
- licence expiry/renewal lifecycle
- duplicate regulator identity checks
- rejection reasons and admin review
- public listing activation from mobile UI
- production Google release/iOS proof
- final real-device smoke

## Follow-Up

Next slice:

`APP-73 - Auth onboarding PR review and merge readiness`

APP-73 should review the stacked auth/onboarding PR chain, confirm CI/merge
state, decide whether any PRs can be marked ready, and avoid new runtime feature
work until the project lead approves the handoff/merge order.
