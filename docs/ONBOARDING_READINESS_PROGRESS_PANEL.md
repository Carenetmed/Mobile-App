# Onboarding Readiness Progress Panel

**Slice:** APP-ID-012
**Date:** 2026-07-19
**Status:** Implemented.

## What Changed

Patient and professional onboarding destinations now show backend-owned
readiness guidance instead of only generic copy.

Patient setup now displays:

- patient readiness heading
- backend-required patient profile field count
- field-level required items returned by `GET /account/readiness`

Professional setup now displays:

- professional readiness heading
- backend-required professional profile field count
- field-level required items returned by `GET /account/readiness`

Professional verification documents now loads onboarding catalog/readiness in
addition to owner document status and displays:

- verification readiness heading
- backend status copy
- required evidence from readiness
- missing/received evidence state
- catalog labels for known evidence codes
- safe retry copy when readiness requirements cannot be loaded

The existing upload/list behavior remains backend-backed. This slice does not
create local verification state and does not treat upload as approval.

## Important Runtime Boundaries

- Backend `account/readiness` remains the authority for required fields,
  evidence requirements, application status, and next action.
- Flutter does not invent approval, rejection reasons, duplicate-account
  policy, or role-switching behavior.
- Verification upload still sends existing backend upload document type codes:
  `LICENSE`, `IDENTITY`, and `CERTIFICATION`.
- Readiness evidence codes such as `GOVERNMENT_IDENTITY` are displayed through
  catalog labels where available.
- Unknown evidence codes remain visible through safe formatted fallback labels.

## Still Deferred

- visual redesign of the full onboarding journey
- role switching or dual-mode accounts
- patient-to-professional upgrade
- rejection reason detail if backend does not provide it
- regulator-specific helper text beyond current catalog labels
- live regulator lookup
- license expiry or good-standing checks
- city/LGA authoritative catalog
- phone/OTP
- Google unlink or recovery linking
- admin dashboard
- payments, payouts, refunds, reviews, calls, calendar sync, medical notes,
  prescriptions, no-show/disputes, or emergency escalation

## Adversarial Review

Result: **PASS WITH FOLLOW-UP**.

Checks:

- Can Flutter mark a professional verified? No.
- Can upload success be mistaken for approval? The upload copy still says
  pending review, and readiness status is backend-owned.
- Can backend readiness failure be hidden behind dummy state? No, the
  verification screen shows safe retry copy.
- Can client-supplied role/status affect readiness display? No, display uses
  backend readiness response.
- Does the slice change backend API payload contracts? No.

Follow-up:

- APP-ID-013 should run a focused onboarding regression and phone smoke pass,
  including Google first-time signup, email/password signup, professional setup,
  verification guidance display, and backend failure states.

## Verification

Passed:

- `flutter test test/features/onboarding/profile_setup_test.dart test/features/home/manage_profile_flow_test.dart -r expanded`
- `flutter analyze lib/features/Onboarding/presentation/pages/profile_setup.dart lib/features/Home/presentation/pages/professional_verification_documents_shell.dart test/features/onboarding/profile_setup_test.dart test/features/home/manage_profile_flow_test.dart`
- `git diff --check`
