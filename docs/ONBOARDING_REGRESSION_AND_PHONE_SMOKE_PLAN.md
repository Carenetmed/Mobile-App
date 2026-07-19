# Onboarding Regression And Phone Smoke Plan

**Slice:** APP-ID-013
**Date:** 2026-07-19
**Status:** Accepted plan and local regression checkpoint; phone execution remains manual.

## Purpose

Freeze the hardened onboarding/auth setup long enough to prove it before more
onboarding feature expansion. The goal is not to add another feature. The goal
is to make sure the current path is understandable, backend-owned, and not
quietly relying on dummy state.

## Current Covered Surface

- email/password sign-up with explicit patient/professional role selection
- Google first-time sign-up with explicit patient/professional role selection
- backend readiness route resolution after account creation
- patient setup using backend catalogs/readiness
- professional setup using backend catalogs/readiness
- professional verification documents with backend owner list/upload
- verification readiness/evidence guidance from backend readiness/catalog data

## Local Regression Commands

Run this group before phone smoke or before another onboarding runtime slice:

```powershell
flutter test `
  test/features/authentication/sign_up_flow_test.dart `
  test/features/authentication/finish_sign_up_test.dart `
  test/features/onboarding/onboarding_readiness_route_resolver_test.dart `
  test/features/onboarding/profile_setup_test.dart `
  test/features/home/manage_profile_flow_test.dart `
  -r expanded
```

Focused analyze:

```powershell
flutter analyze `
  lib/features/Authentication/presentation/pages/sign_up_arguments.dart `
  lib/features/Authentication/presentation/pages/sign_up_email.dart `
  lib/features/Authentication/presentation/pages/sign_up_phone.dart `
  lib/features/Authentication/presentation/pages/sign_up_role_selection.dart `
  lib/features/Authentication/presentation/pages/sign_up_con.dart `
  lib/features/Onboarding/domain/services/onboarding_readiness_route_resolver.dart `
  lib/features/Onboarding/presentation/pages/profile_setup.dart `
  lib/features/Home/presentation/pages/professional_verification_documents_shell.dart `
  test/features/authentication/sign_up_flow_test.dart `
  test/features/authentication/finish_sign_up_test.dart `
  test/features/onboarding/onboarding_readiness_route_resolver_test.dart `
  test/features/onboarding/profile_setup_test.dart `
  test/features/home/manage_profile_flow_test.dart
```

## Required Phone Smoke

Use a staging-configured Android build. Do not use production data. Do not
commit passwords, tokens, or screenshots with private data.

### Patient Signup

- fresh email/password patient signup reaches patient setup through readiness
- fresh Google patient signup reaches patient setup or dashboard only when
  backend readiness says the account is ready
- patient setup shows `Patient readiness`
- patient setup shows backend-required fields when backend returns them
- patient setup blocks save if catalog options cannot load
- successful patient setup does not claim clinical diagnosis or verification

### Professional Signup

- fresh email/password professional signup reaches professional setup through
  readiness
- fresh Google professional signup reaches professional setup, upload, or
  status screen according to backend readiness
- professional setup shows `Professional readiness`
- required profile fields are visible when backend returns them
- profession, practice country/state, and regulator are controlled by backend
  catalog values
- professional setup success goes to verification documents, not dashboard

### Verification Documents

- verification screen shows `Verification readiness`
- required evidence labels come from backend catalog when available
- missing evidence shows as missing
- already uploaded required evidence shows as received
- upload accepts one PDF/JPEG/PNG under 10 MB if staging upload-init is healthy
- upload failure shows safe user copy and does not expose storage internals
- upload success says pending review and does not claim verified status

### Resume And Failure

- returning incomplete patient resumes to patient setup
- returning incomplete professional resumes to profile, evidence upload, or
  status according to backend `nextAction`
- readiness failure after successful signup uses role-safe fallback and does
  not send professionals directly to dashboard
- sign out/sign in does not create duplicate local completion state

## Known Blockers To Record Honestly

- Staging verification upload was previously blocked by backend
  `upload-init` HTTP 500. If still present, record it as backend/storage
  blocker, not mobile success.
- iOS Google/OAuth proof remains deferred unless explicitly scoped.
- Release/Play signing fingerprints and production OAuth consent/app
  verification remain deferred.
- Rejection reasons can only be shown if backend provides safe reason data.

## Out Of Scope

- no new runtime routes
- no UI redesign beyond current implemented panels
- no backend API changes
- no dummy success paths
- no role switching or dual-mode accounts
- no live regulator lookup
- no license expiry/good-standing checks
- no city/LGA catalog
- no phone/OTP
- no Google unlink/recovery linking
- no admin dashboard
- no payments, reviews, calls, calendar sync, notes, prescriptions, or
  emergency flows

## Adversarial Review

Result: **PASS WITH FOLLOW-UP**.

Checks:

- Does the plan let local tests replace phone smoke? No; local regression and
  phone smoke are separate proof levels.
- Does it allow dummy upload success if staging upload-init fails? No.
- Does it let Google profile names become trusted medical identity? No.
- Does it allow professional dashboard entry without backend readiness? No.
- Does it treat document upload as verification approval? No.

Follow-up:

- Execute this phone smoke when the phone and staging accounts are available.
- If a blocker appears, record exact route, account role, backend/staging
  status, and whether it is mobile, backend, config, or seed-data.

## Verification

Passed locally for this planning checkpoint:

- `flutter test test/features/authentication/sign_up_flow_test.dart test/features/authentication/finish_sign_up_test.dart test/features/onboarding/onboarding_readiness_route_resolver_test.dart test/features/onboarding/profile_setup_test.dart test/features/home/manage_profile_flow_test.dart -r expanded`
- `flutter analyze lib/features/Authentication/presentation/pages/sign_up_arguments.dart lib/features/Authentication/presentation/pages/sign_up_email.dart lib/features/Authentication/presentation/pages/sign_up_phone.dart lib/features/Authentication/presentation/pages/sign_up_role_selection.dart lib/features/Authentication/presentation/pages/sign_up_con.dart lib/features/Onboarding/domain/services/onboarding_readiness_route_resolver.dart lib/features/Onboarding/presentation/pages/profile_setup.dart lib/features/Home/presentation/pages/professional_verification_documents_shell.dart test/features/authentication/sign_up_flow_test.dart test/features/authentication/finish_sign_up_test.dart test/features/onboarding/onboarding_readiness_route_resolver_test.dart test/features/onboarding/profile_setup_test.dart test/features/home/manage_profile_flow_test.dart`
- `git diff --check`

## Next Slice

`APP-ID-014 - Onboarding Phone Smoke Execution`

Run the checklist above against a staging-configured Android build. Do not add
new onboarding features in that slice.
