# Mobile Backend Integration Stabilization Plan

**Task:** 52.96
**Status:** Accepted plan
**Date:** 2026-07-15

## Purpose

Stabilize the already-wired backend mobile integration milestone before making
broader completion claims or adding more product surfaces.

This plan follows the final backend-completed mobile surface checkpoint from
task 52.95. No new mobile-facing backend-completed surface was found waiting
for first-pass wiring, so the next useful work is regression proof, smoke
evidence, and targeted cleanup if the proof exposes real failures.

## Scope

This is a planning and verification-scope slice only.

In scope:

- define grouped regression suites for the wired backend mobile milestone
- define focused analyze/docs checks
- define manual smoke checks for app/backend confidence
- name blockers that are not solved by this milestone
- choose the next execution slice

Out of scope:

- no new runtime routes
- no new UI surfaces
- no backend feature expansion
- no admin dashboard implementation
- no payment, notification, review, call, calendar, note, prescription,
  messaging, community, or content backend wiring
- no production release or store-readiness claim

## Grouped Regression Suites

### Auth, Session, And Account

```powershell
flutter test `
  test/features/authentication/auth_infrastructure_test.dart `
  test/features/authentication/sign_in_flow_test.dart `
  test/features/authentication/sign_up_flow_test.dart `
  test/features/authentication/finish_sign_up_test.dart `
  test/features/authentication/password_recovery_flow_test.dart `
  test/features/authentication/session_restore_guard_test.dart `
  test/features/home/account_flow_test.dart `
  -r expanded
```

Purpose:

- prove login/register/session restore/logout/current account behavior
- prove password reset and email verification request/confirm boundaries
- prove Google sign-in/linking configured and failure states
- prove account profile display/update boundaries stay honest

### Profile And Verification

```powershell
flutter test `
  test/features/home/profile_repository_test.dart `
  test/features/home/verification_repository_test.dart `
  test/features/home/manage_profile_flow_test.dart `
  -r expanded
```

Purpose:

- prove patient and professional profile repository boundaries
- prove professional profile read/edit surfaces
- prove verification document list/upload boundary
- prove professional availability entry points covered by Manage Profile tests

### Discovery And Booking

```powershell
flutter test `
  test/features/home/find_mentor_flow_test.dart `
  test/features/home/search_flow_test.dart `
  test/features/home/specialist_details_flow_test.dart `
  test/features/home/appointment_request_time_options_test.dart `
  -r expanded
```

Purpose:

- prove public professional listing and handoff behavior
- prove public availability read behavior
- prove generated request options
- prove appointment request wiring without local slot fallback

### Scheduling Lifecycle

```powershell
flutter test `
  test/features/home/scheduling_repository_test.dart `
  test/features/home/appointments_flow_test.dart `
  -r expanded
```

Purpose:

- prove own appointment list
- prove cancel, accept, decline, complete, and reschedule boundaries
- prove repository request/response mapping and safe failure behavior

## Focused Analyze

```powershell
flutter analyze `
  lib/features/Authentication `
  lib/features/Home/data `
  lib/features/Home/domain `
  lib/features/Home/presentation/pages/account_shell.dart `
  lib/features/Home/presentation/pages/manage_profile_shell.dart `
  lib/features/Home/presentation/pages/professional_verification_documents_shell.dart `
  lib/features/Home/presentation/pages/search_shell.dart `
  lib/features/Home/presentation/pages/find_mentor_shell.dart `
  lib/features/Home/presentation/pages/specialist_details_shell.dart `
  lib/features/Home/presentation/pages/selected_dates_shell.dart `
  lib/features/Home/presentation/pages/appointments_shell.dart `
  test/features/authentication `
  test/features/home
```

If this command is too broad or slow in one terminal session, the next slice may
split it by the same suite groups above. Any split must record the exact
commands and results.

## Docs Consistency Checks

```powershell
git diff --check
Select-String -Path docs/AI_HANDOFF.md -Pattern '\| .*\*\*NEXT\*\* \|'
```

Manual docs checks:

- `docs/AI_HANDOFF.md` has exactly one NEXT row
- `docs/BACKEND_COMPLETED_SURFACE_WIRING_MAP.md` does not describe completed
  Google/account surfaces as still disabled
- admin verification review remains assigned to a separate admin dashboard or
  web console
- deferred modules are not described as completed mobile app features

## Manual Smoke Checklist

Run this only when a configured API base URL and usable test accounts/data are
available.

- app starts with the intended API base URL
- email sign-in works for a seeded user
- current account loads after session restore
- Google sign-in and Google account linking show configured states
- patient Settings/Profile reads backend profile and can save name only
- professional Manage Profile reads profile and can edit allowed fields
- professional verification documents list/upload path works with a real file
- Search/Find Mentor/Specialist Details show public verified professionals
- Specialist Details can load availability and request an appointment
- Appointments list shows own appointments
- eligible appointment cancel/accept/decline/complete/reschedule actions behave
  honestly
- selectedDates can read and save professional availability

## Known Blockers Outside This Plan

These are not hidden failures in the wired mobile milestone. They are separate
release, staging, backend, or product lanes:

- public staging data and demo access
- seeded patient/professional/verified-professional/availability/appointment
  records
- production app links for reset and email verification
- release signing and store-readiness
- separate admin dashboard or admin web console
- phone/OTP
- MFA/PIN persistence
- Google unlinking and cross-email/recovery policy
- payments, refunds, and payouts
- notifications and reminders
- reviews and ratings
- calls, video, and audio
- calendar provider sync
- consultation notes and prescriptions
- messaging backend
- community backend
- content/publishing backend

## Next Slice

`52.97 - Execute Mobile Backend Integration Regression Pass`

Expected scope:

- run the grouped regression suites above
- run focused analyze or split analyze by documented suite groups if needed
- run docs consistency checks
- record exact pass/fail evidence
- create targeted cleanup slices for verified regressions
- do not add new product surfaces

## Definition Of Done For 52.97

- auth/session/account suite result recorded
- profile/verification suite result recorded
- discovery/booking suite result recorded
- scheduling lifecycle suite result recorded
- focused analyze result recorded or split result recorded with reason
- docs consistency checks recorded
- any failures turned into named targeted cleanup slices
- no new runtime feature behavior added outside a verified regression fix
