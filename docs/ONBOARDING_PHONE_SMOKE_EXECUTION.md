# Onboarding Phone Smoke Execution

**Slice:** APP-ID-014
**Date:** 2026-07-19
**Status:** Blocked after build; phone execution not completed.

## Purpose

Execute the APP-ID-013 onboarding phone-smoke checklist against a
staging-configured Android build. This slice must not add onboarding features
or claim phone proof without real device evidence.

## Build Evidence

Staging Android debug APK build passed.

Command shape:

```powershell
flutter build apk --debug `
  --dart-define=CARENET_API_BASE_URL=https://carenet-staging-mobile-gateway-2kbj9ok1.uc.gateway.dev `
  --dart-define=GOOGLE_SIGN_IN_SERVER_CLIENT_ID=<redacted-web-client-id>
```

Output:

```text
Built build\app\outputs\flutter-apk\app-debug.apk
```

The Google client ID was read from a local uncommitted file and is not recorded
in this repository.

## Blocker

Phone smoke is blocked because no Android device is visible to Flutter or ADB.

Evidence:

```text
flutter devices
Found 3 connected devices:
  Windows
  Chrome
  Edge
```

```text
adb devices
List of devices attached
```

No Android serial was listed, so install and interactive smoke cannot be
honestly executed yet.

## Not Proven Yet

The following APP-ID-013 checklist items remain unproven on phone:

- fresh email/password patient signup
- fresh Google patient signup
- fresh email/password professional signup
- fresh Google professional signup
- backend readiness routing on device
- patient setup readiness panel on device
- professional setup readiness panel on device
- verification readiness/evidence guidance on device
- verification upload behavior or exact staging upload-init blocker
- sign out/sign in resume behavior

## Next Action

Reconnect or authorize the Android phone until `adb devices` shows a device
serial. Then continue this same slice by installing:

```powershell
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```

After install, run the APP-ID-013 phone checklist and record pass/fail evidence
here without secrets.

## Out Of Scope

- no runtime feature changes
- no backend API changes
- no dummy phone-smoke success
- no production data
- no screenshots or logs containing private credentials

## Adversarial Review

Result: **BLOCKED HONESTLY**.

Checks:

- Did this slice claim phone smoke without a phone? No.
- Did it hide the blocker? No.
- Did it build against staging and configured Google OAuth? Yes.
- Did it commit secrets? No.
- Did it add product behavior while blocked? No.
