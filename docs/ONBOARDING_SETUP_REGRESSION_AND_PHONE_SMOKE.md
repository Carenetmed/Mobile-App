# Onboarding Setup Regression And Phone Smoke

**Slice:** APP-61
**Date:** 2026-07-17
**Status:** Automated regression and staging APK build passed; phone install/manual smoke blocked by no connected ADB device.

## Purpose

APP-61 verifies that the role-based signup and patient/professional onboarding
setup work from APP-57 through APP-60 did not regress the existing auth,
profile, account, and verification surfaces.

This slice does not add runtime behavior.

## Verified Locally

Passed:

- `flutter test test\features\authentication test\features\onboarding test\features\home\profile_repository_test.dart test\features\home\manage_profile_flow_test.dart test\features\home\account_flow_test.dart`
- `flutter analyze lib\features\Authentication lib\features\Onboarding lib\features\Home\data\repositories\profile_repository.dart lib\features\Home\data\services\profile_api_client.dart test\features\authentication test\features\onboarding test\features\home\profile_repository_test.dart test\features\home\manage_profile_flow_test.dart test\features\home\account_flow_test.dart`
- `flutter build apk --debug --dart-define=CARENET_API_BASE_URL=https://carenet-staging-mobile-gateway-2kbj9ok1.uc.gateway.dev`

The grouped test run passed 116 tests.

The debug APK was built at:

`build\app\outputs\flutter-apk\app-debug.apk`

## Phone Smoke Status

`adb devices` returned no connected Android device during this slice, so the
staging APK was not installed and patient/professional setup was not manually
smoked on a phone in APP-61.

Do not treat this slice as proof that the phone flow passed. It proves the
automated grouped regression and that the staging-configured APK can build.

## Product Boundaries

This checkpoint does not enable Google first-time signup, phone OTP,
production OAuth release signing, admin verification review, regulator license
validation, payments, reviews, calls, notes, prescriptions, calendar sync, or
public professional listing before backend verification.

## Next Required Manual Proof

When a device is connected, run:

```powershell
adb devices
adb install -r build\app\outputs\flutter-apk\app-debug.apk
adb shell am start -W -n com.carenet.app/.MainActivity
```

Then manually smoke:

- patient email sign-up -> role selection -> finish sign-up -> patient setup
  save -> community agreement
- professional email sign-up -> role selection -> finish sign-up ->
  professional setup save -> verification documents
- safe failure behavior if staging rejects profile setup

Record that result in the next staging/manual smoke checkpoint instead of
backfilling APP-61.
