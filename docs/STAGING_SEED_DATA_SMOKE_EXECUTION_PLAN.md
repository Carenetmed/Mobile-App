# Staging Seed Data And Smoke Execution Plan

**Task:** 53.1
**Status:** Accepted plan
**Date:** 2026-07-15

## Purpose

Define the staging data and smoke execution needed to prove the
regression-passed mobile backend milestone against a real backend environment.

This slice does not create staging data, change runtime app behavior, or claim
public staging/demo readiness.

## Decision

Do staging proof in two steps:

1. Define the exact staging seed data and smoke script now.
2. Execute it in the next slice only after the required accounts/data/config are
   confirmed.

Recommended next slice:

`53.2 - Execute Staging Seed Data And Mobile Smoke Pass`

## Required Staging Inputs

### Environment

- staging API base URL
- Flutter build command using that API base URL
- Google sign-in server client ID if Google smoke is included
- clear note whether smoke runs on emulator, Android phone, or both
- confirmed backend staging is the target, not production

### Accounts

Patient account:

- email
- password or approved test login method
- email verification state
- account role: `PATIENT`
- cleanup/reset expectation

Professional account:

- email
- password or approved test login method
- email verification state
- account role: `PROFESSIONAL`
- professional profile exists
- professional verification state is approved/verified where public listing
  requires it
- cleanup/reset expectation

Admin/reviewer account:

- not required for the mobile app smoke
- only needed later for the separate admin dashboard/web-console lane

### Seeded Domain Data

Professional profile:

- display name
- category
- specialty
- bio
- public-listing visibility state
- verified status required for public professional list

Availability:

- at least one future public availability window
- timezone
- duration behavior expected by backend
- cleanup/reset expectation after appointment request/reschedule tests

Appointments:

- one path where patient can request an appointment
- one path where own appointment list shows the request
- one accepted future appointment for cancel/reschedule smoke, if available
- one accepted past appointment for professional completion smoke, if available
- clear reset/cleanup rule if lifecycle actions mutate shared data

Verification upload:

- storage path/provider is enabled for staging
- one safe test PDF/JPEG/PNG under 10 MB
- cleanup/reset expectation for uploaded test documents

## Smoke Build Commands

Use exact values only in local terminal or secret storage, not in committed docs.

Android debug build:

```powershell
flutter build apk --debug `
  --dart-define=CARENET_API_BASE_URL=<staging-api-base-url> `
  --dart-define=GOOGLE_SIGN_IN_SERVER_CLIENT_ID=<web-client-id-if-used>
```

For Google phone smoke, prefer the helper so the app is built with the Web
OAuth client ID instead of accidentally using an Android client ID:

```powershell
.\scripts\build-staging-google-apk.ps1 `
  -GoogleWebClientJson "C:\path\to\web-client-secret.json"
```

Focused static check before smoke:

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

Optional grouped regression rerun before staging smoke:

```powershell
flutter test test/features/authentication/auth_infrastructure_test.dart test/features/authentication/sign_in_flow_test.dart test/features/authentication/sign_up_flow_test.dart test/features/authentication/finish_sign_up_test.dart test/features/authentication/password_recovery_flow_test.dart test/features/authentication/session_restore_guard_test.dart test/features/home/account_flow_test.dart -r expanded
flutter test test/features/home/profile_repository_test.dart test/features/home/verification_repository_test.dart test/features/home/manage_profile_flow_test.dart -r expanded
flutter test test/features/home/find_mentor_flow_test.dart test/features/home/search_flow_test.dart test/features/home/specialist_details_flow_test.dart test/features/home/appointment_request_time_options_test.dart -r expanded
flutter test test/features/home/scheduling_repository_test.dart test/features/home/appointments_flow_test.dart -r expanded
```

## Manual Smoke Checklist

Run this checklist on a real app build pointed at staging.

### Auth And Account

- app opens with staging API config
- patient can sign in
- session restores after app restart
- current account display loads backend email/status
- logout clears session and returns to onboarding/sign-in
- password reset request shows safe success/failure behavior
- email verification request shows safe success/failure behavior
- Google sign-in works if staging OAuth is configured
- Google account linking works if staging OAuth is configured

### Patient Profile

- Settings/Profile reads patient name/age/location when available
- name-only save updates backend patient name
- username/email/bio remain local/deferred as documented
- backend failure does not show false success

### Professional Profile And Verification

- professional can sign in
- Manage Profile reads backend professional profile
- display name update works
- category/specialty update works
- bio update works
- verification document list loads
- upload accepts one valid test file
- upload rejects unsupported/oversized file locally
- upload failure shows safe error

### Discovery And Booking

- Search shows public verified professional list
- Find Mentor shows public verified professional list
- selected professional opens Specialist Details with backend id
- Specialist Details loads public professional fields
- public availability loads without local fallback
- patient submits appointment request
- request failure shows safe error without fake success

### Scheduling Lifecycle

- own appointment list loads
- eligible appointment can be cancelled
- professional can accept a requested appointment
- professional can decline a requested appointment
- eligible accepted appointment can be rescheduled
- accepted past appointment can be completed by professional
- patient cannot see professional-only lifecycle actions
- terminal appointments do not expose duplicate actions

## Evidence To Record In 53.2

For each smoke section, record:

- pass/fail status
- account used by role, without committing passwords or secrets
- API base URL label, without committing secret tokens
- app build command shape, with secrets redacted
- screenshots or short notes only if useful
- exact failing route/screen/error if failed
- whether failure is app wiring, backend behavior, missing seed data, or config
- cleanup performed or cleanup still needed

## Blocker Rules

Stop and ask if any of these are missing:

- no staging API base URL
- no usable patient login
- no usable professional login
- no verified public professional seed
- no availability window for public booking
- no clear cleanup/reset rule for mutating appointment actions
- verification upload storage is disabled but upload smoke is required
- OAuth is not configured but Google smoke is expected

Do not invent fake staging success.

Do not create production data for smoke.

Do not store passwords, client secrets, or tokens in committed docs.

## Out Of Scope

- no runtime app changes
- no backend seed implementation in this mobile repo
- no production release setup
- no admin dashboard implementation
- no phone/OTP, MFA, payments, notifications, reviews, calls, calendar sync,
  notes, prescriptions, messaging, community, or content backend work

## Next Slice

`53.2 - Execute Staging Seed Data And Mobile Smoke Pass`

Start 53.2 only after the required staging inputs are available or after the
project lead confirms which unavailable items should be marked blocked.
