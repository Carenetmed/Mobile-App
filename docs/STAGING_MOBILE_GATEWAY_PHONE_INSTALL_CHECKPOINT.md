# Staging Mobile Gateway Phone Install Checkpoint

**Task:** 53.2 checkpoint
**Status:** Seed/backend proof passed; real-device patient request/list smoke and professional lifecycle smoke passed; remaining verification/detail/cleanup phone smoke still open
**Date:** 2026-07-17

## Purpose

Record the real-device install/launch proof, the staging seed/backend API
proof, the patient phone UI walkthrough through a real appointment request,
the patient own appointment-list proof, professional appointment lifecycle
proof, and the remaining phone-smoke gaps for the staging mobile build without
claiming that the full real-device manual UI smoke pass is complete.

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

20. Found and fixed an Android auth-storage reliability issue during the phone
    smoke.

    After reinstalling the UTC-fixed APK and signing in as the seeded patient,
    the phone UI still returned:

    ```text
    Please sign in again.
    ```

    A direct staging API Gateway replay with the same seeded patient credentials,
    same professional profile, and same `2026-07-18T08:30:00.000Z` slot
    succeeded with status `REQUESTED`, proving the staging backend, seed data,
    and request payload were valid.

    The app now disables Android app backup/restore:

    ```xml
    android:allowBackup="false"
    android:fullBackupContent="false"
    ```

    This prevents stale restored secure-storage/auth state from surviving app
    reinstall/test cycles and is also the safer production posture for an auth
    app.

21. Rebuilt, uninstalled the old app, installed the backup-disabled APK,
    cleared app data, launched the app, signed in as the seeded patient, and
    submitted the first generated appointment option from the real phone UI.

    Observed phone UI result:

    ```text
    Request sent. Backend status: REQUESTED.
    ```

    The phone UI showed:

    - `Staging Smoke Professional`
    - `Public availability`
    - `Day 0: 08:30 - 12:00 (UTC)`
    - `Day 2: 09:30 - 13:00 (UTC)`
    - `Day 6: 08:30 - 12:00 (UTC)`
    - generated request options for `07/18 08:30`

22. Found and fixed a protected appointment-list parsing issue during the
    phone smoke.

    The staging backend returns own appointments as:

    ```json
    {
      "appointments": []
    }
    ```

    `SchedulingApiClient` previously parsed only raw lists, `{ "items": [] }`,
    and the public availability `{ "availabilityWindows": [] }` envelope. The
    phone UI therefore showed no backend appointments even though the same
    seeded patient had appointments through the staging API Gateway. The app
    now accepts the backend `appointments` envelope for own appointment list
    reads.

23. Found and fixed a fresh sign-in/session persistence reliability issue
    during the phone smoke.

    After the appointment-list envelope fix, installing over the existing app
    could still leave the appointment screen at:

    ```text
    Please sign in again.
    ```

    A clean app-data reset plus rebuilt APK confirmed the app could sign in
    again, but the session store also now writes auth/session fields in an
    ordered sequence before protected routes reread them. This avoids a
    half-written secure-storage session during immediate post-login navigation.

24. Rebuilt and installed the corrected APK, cleared app data, signed in fresh
    as the seeded patient, opened Notifications -> `Your appointment is
    booked`, and proved the phone UI renders real backend appointment rows.

    Observed phone UI result:

    ```text
    Upcoming
    Appointment with cmrnd9w31000701s6tse0lyf1
    REQUESTED
    2026-07-21 - 09:30
    Backend appointment request
    Cancel appointment
    Reschedule
    ```

    Additional rendered rows from the same backend response showed the same
    seeded professional profile id with `REQUESTED` status for `2026-07-18 -
    08:30`.

25. Ran focused local verification after the appointment-list and session-store
    fixes:

    ```powershell
    flutter test test\features\authentication\auth_infrastructure_test.dart test\features\authentication\session_restore_guard_test.dart test\features\home\scheduling_repository_test.dart test\features\home\appointments_flow_test.dart
    flutter analyze lib\features\Authentication\data\storage\session_store.dart lib\features\Home\data\services\scheduling_api_client.dart test\features\home\scheduling_repository_test.dart lib\features\Home\presentation\pages\appointments_shell.dart test\features\home\appointments_flow_test.dart
    flutter build apk --debug --dart-define=CARENET_API_BASE_URL=https://carenet-staging-mobile-gateway-2kbj9ok1.uc.gateway.dev
    ```

    Result: all passed / no issues found / APK built.

26. Cleared app data, launched the rebuilt APK, and signed into the phone build
    as the seeded professional account.

    Observed phone UI result:

    ```text
    PROFESSIONAL account - active
    app53-2-professional-20260716092933@staging.carenet.example
    ```

27. Opened Notifications -> `Your appointment is booked` while signed in as
    the seeded professional and proved role-aware backend appointment actions.

    Observed phone UI result:

    ```text
    Upcoming
    Appointment with cmrnd9w31000701s6tse0lyf1
    REQUESTED
    Accept
    Decline
    Reschedule
    ```

28. Performed a professional accept action on one requested appointment.

    Observed phone UI result:

    ```text
    ACCEPTED
    Appointment updated. Backend status: ACCEPTED.
    ```

29. Performed a professional decline action on a separate requested
    appointment.

    Observed phone UI result:

    ```text
    DECLINED
    Appointment updated. Backend status: DECLINED.
    ```

30. Opened the reschedule flow for the accepted appointment, confirmed a
    generated backend availability option, and observed the backend response.

    Observed phone UI result:

    ```text
    Appointment rescheduled. Backend status: REQUESTED.
    ```

31. Scrolled to the recent section while signed in as the professional and
    confirmed terminal appointment rows render without duplicate lifecycle
    actions.

    Observed phone UI result:

    ```text
    Recent
    CANCELLED
    COMPLETED
    ```

    The completed row did not expose `Complete`, so duplicate professional
    completion was not available from the phone UI.

32. Checked professional profile/verification navigation from the phone.

    The drawer `Profile` entry routed to `Account`, where the seeded
    professional account was correctly shown as active. `Settings & Profile` is
    currently a patient-profile surface and showed:

    ```text
    Patient profile
    Please sign in again.
    ```

    The existing `Manage Profile` and `Verification documents` routes are still
    present in the app code, but this checkpoint did not find a reliable phone
    navigation path from the authenticated professional shell to those routes.
    Verification upload smoke therefore remains open as a route-access blocker,
    not as a backend/upload failure.

## Current Blocker

There is no current blocker for the patient Search -> public availability ->
appointment request path, the patient Notifications -> Appointments own-list
path, or the professional Notifications -> Appointments lifecycle path. These
passed on the real Android phone after fresh app-data resets and fresh sign-ins.

The appointment row tap did not navigate to a separate detail screen in this
checkpoint, so a separate appointment-detail screen proof remains open instead
of being claimed.

Verification upload phone smoke is blocked by app navigation, not by a proven
backend upload failure: the professional `Manage Profile`/`Verification
documents` routes exist in code, but a reliable authenticated phone navigation
path was not found in this checkpoint.

## What This Does Not Prove

This checkpoint does not prove the full real-device manual UI smoke pass.

The following remain open under task 53.2:

- checking any separate appointment-detail screen if product keeps or adds one
- running a fresh professional completion action, if a non-terminal accepted
  past appointment is available on the phone UI
- verification upload smoke through the phone UI
- cleanup/reset execution after the walkthrough

Do not present this checkpoint as public demo readiness, production readiness,
Play Store readiness, or full frontend/backend staging completion.

## Next Required Step

Continue task 53.2 from the remaining real Android phone UI checklist in
`STAGING_SEED_DATA_SMOKE_EXECUTION_PLAN.md`, starting with verification upload
route access, any separate appointment-detail proof, optional fresh
professional completion proof if suitable data exists, and cleanup/reset proof.
If a separate appointment-detail screen is required later, prove it as its own
step instead of treating the appointment list as detail proof.

If any phone UI smoke step cannot be completed, stop and record the exact
screen, role, route, and failure category instead of inventing fake success.
