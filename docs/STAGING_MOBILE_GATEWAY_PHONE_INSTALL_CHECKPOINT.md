# Staging Mobile Gateway Phone Install Checkpoint

**Task:** 53.2 checkpoint
**Status:** Seed/backend proof passed; real-device UI smoke partially passed; ADB device visibility currently blocks final walkthrough
**Date:** 2026-07-16

## Purpose

Record the real-device install/launch proof, the staging seed/backend API
proof, the partial phone UI walkthrough, and the current phone-smoke blocker
for the staging mobile build without claiming that the full real-device manual
UI smoke pass is complete.

This checkpoint proves that the Android app can be built with the public
staging API Gateway URL, installed on the test phone, launched under the real
`com.carenet.app` package, and backed by staging-only patient/professional
seed data suitable for the next real-device walkthrough.

## Environment Used

- Backend target: staging API Gateway
- API base URL:
  `https://carenet-staging-mobile-gateway-2kbj9ok1.uc.gateway.dev`
- Android package/application ID: `com.carenet.app`
- Test device observed by ADB:
  - serial: `6tkvkvindaqogurk`
  - model: `22071219CI`
  - product: `rock_p_in`
- APK path:
  `build/app/outputs/flutter-apk/app-debug.apk`
- Local-only credential file created for the phone smoke:
  `C:\Users\asd\Desktop\carenet-staging-smoke-credentials-20260716092933.txt`

No passwords, API keys, OAuth client secrets, or tokens are recorded here.

## What Passed

1. Built the debug APK against the real staging gateway URL:

   ```powershell
   flutter build apk --debug `
     --dart-define=CARENET_API_BASE_URL=https://carenet-staging-mobile-gateway-2kbj9ok1.uc.gateway.dev
   ```

2. Installed the APK on the connected Android phone:

   ```powershell
   adb install -r build\app\outputs\flutter-apk\app-debug.apk
   ```

   Result: `Success`.

3. Fixed the Android native entrypoint package mismatch.

   The app uses `applicationId = "com.carenet.app"` and manifest activity
   `.MainActivity`, but the native `MainActivity` file still lived under
   `com.example.app_t`. That caused the installed app to fail to stay open.

   The native activity now lives at:

   ```text
   android/app/src/main/java/com/carenet/app/MainActivity.java
   ```

   with package:

   ```java
   package com.carenet.app;
   ```

4. Rebuilt and reinstalled the APK after the package fix.

5. Launched the installed app explicitly:

   ```powershell
   adb shell am start -W -n com.carenet.app/.MainActivity
   ```

   Observed result:

   ```text
   Status: ok
   LaunchState: COLD
   Activity: com.carenet.app/.MainActivity
   ```

6. Confirmed the app was foregrounded:

   ```text
   mCurrentFocus=... com.carenet.app/com.carenet.app.MainActivity
   mFocusedApp=... com.carenet.app/.MainActivity
   ```

7. Confirmed the app process was running:

   ```powershell
   adb shell pidof com.carenet.app
   ```

   Observed process id: `30745`.

8. Ran focused analyzer check for the moved Android entrypoint:

   ```powershell
   flutter analyze android/app/src/main/java/com/carenet/app/MainActivity.java
   ```

   Result: no issues found.

9. Created fresh staging-only smoke accounts/data through the real staging
   backend path:

   - patient email:
     `app53-2-patient-20260716092933@staging.carenet.example`
   - professional email:
     `app53-2-professional-20260716092933@staging.carenet.example`
   - patient role: `PATIENT`
   - professional role: `PROFESSIONAL`
   - patient profile created
   - professional profile created
   - professional profile id: `cmrnd9w31000701s6tse0lyf1`
   - professional verification status seeded to `VERIFIED`
   - public professional listing includes the seeded professional
   - public availability returns 3 active windows

   Passwords were written only to the local credential file listed above.
   They are not committed or recorded in docs.

10. Proved backend appointment lifecycle through the staging API Gateway using
    normal app JWTs and the seeded staging profiles:

    - health: `ok`
    - readiness: `ok`
    - database: `ok`
    - migrations: `ok`
    - appointment request created with status `REQUESTED`
    - professional accepted with status `ACCEPTED`
    - patient rescheduled with status `REQUESTED`
    - professional re-accepted with status `ACCEPTED`
    - patient cancelled with status `CANCELLED`
    - separate accepted past appointment completed with status `COMPLETED`

11. The verification seed used direct staging database access through Cloud SQL
    Auth Proxy after `gcloud auth application-default login`. This was needed
    because the mobile app cannot approve a professional profile and public
    listing requires `verificationStatus = VERIFIED`.

12. Signed into the installed phone build as the seeded patient account and
    reached the dashboard.

13. Confirmed Account showed backend current-account identity:

    - role/status: `PATIENT account - active`
    - email:
      `app53-2-patient-20260716092933@staging.carenet.example`

14. Confirmed Settings & Profile loaded the seeded backend patient profile:

    - name: `Staging Smoke Patient`
    - age: `30`
    - location: `Staging`

15. Confirmed Search loaded the seeded public professional from staging:

    - `Staging Smoke Professional`
    - `Mental Health - Stress Support`
    - `Verified`

16. Found and fixed an app-side public availability parsing issue during the
    phone smoke.

    The staging backend returns public availability as:

    ```json
    {
      "professionalProfileId": "...",
      "availabilityWindows": []
    }
    ```

    `SchedulingApiClient` previously parsed only raw lists or `{ "items": [] }`,
    so the phone UI showed `No public availability is available yet` even
    though the backend route returned windows. `AvailabilityWindowModel` also
    treated an omitted `active` field as inactive. The app now accepts the
    backend `availabilityWindows` envelope and treats omitted `active` as active
    while preserving explicit `active: false`.

17. After a fresh patient sign-in, the app showed the seeded public availability
    and generated request options on the phone. Submitting the selected option
    returned the backend validation copy:

    ```text
    Please choose an available time and try again.
    ```

    That exposed a second app-side contract issue: UTC availability windows were
    converted into local `DateTime` values and then shifted when the API client
    serialized them with `toUtc()`. `AppointmentRequestTimeOptions` now creates
    UTC instants for `timezone: "UTC"` windows so the request payload matches the
    backend availability window instead of moving earlier by the device offset.

18. Rebuilt the debug APK after the availability parsing and UTC request-time
    fixes:

    ```powershell
    flutter build apk --debug `
      --dart-define=CARENET_API_BASE_URL=https://carenet-staging-mobile-gateway-2kbj9ok1.uc.gateway.dev
    ```

    Result: build passed.

19. Ran focused local verification after the availability parsing and UTC
    request-time fixes:

    ```powershell
    flutter test test\features\home\scheduling_repository_test.dart
    flutter test test\features\home\search_flow_test.dart test\features\home\specialist_details_flow_test.dart test\features\home\appointment_request_time_options_test.dart
    flutter analyze lib\features\Home\data\models\availability_window_model.dart lib\features\Home\data\services\scheduling_api_client.dart test\features\home\scheduling_repository_test.dart
    flutter analyze lib\features\Home\domain\services\appointment_request_time_options.dart test\features\home\appointment_request_time_options_test.dart
    ```

    Result: all passed / no issues found.

## Current Blocker

The rebuilt APK has not yet been reinstalled after the UTC request-time fix
because ADB dropped the phone during install:

```text
adb.exe: no devices/emulators found
```

After that, ADB did not list the phone:

```powershell
adb devices -l
```

Observed result:

```text
List of devices attached
```

No device row was listed. The next run must reconnect or re-authorize the
Android test phone, then reinstall the rebuilt APK and repeat the
availability/appointment-request portion of the real-device smoke.

## What This Does Not Prove

This checkpoint does not prove the full real-device manual UI smoke pass.

The following remain open under task 53.2:

- signing into the phone build as the seeded professional
- confirming Search/Specialist Details still show the seeded public
  availability after the UTC request-time rebuilt APK is installed
- submitting an appointment request through the phone UI after the UTC
  request-time rebuilt APK is installed
- checking own appointment list through the phone UI
- running any feasible accept/decline/cancel/reschedule/complete walkthrough
  from the phone UI
- verification upload smoke through the phone UI
- cleanup/reset execution after the walkthrough

Do not present this checkpoint as public demo readiness, production readiness,
Play Store readiness, or full frontend/backend staging completion.

## Next Required Step

Continue task 53.2 by reconnecting or re-authorizing the Android phone until
`adb devices -l` lists it, then reinstall the rebuilt APK and resume the real
Android phone UI checklist from `STAGING_SEED_DATA_SMOKE_EXECUTION_PLAN.md`.

If any phone UI smoke step cannot be completed, stop and record the exact
screen, role, route, and failure category instead of inventing fake success.
