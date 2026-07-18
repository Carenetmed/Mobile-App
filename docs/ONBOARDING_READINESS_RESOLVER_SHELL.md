# Onboarding Readiness Resolver Shell

**Slice:** APP-68  
**Date:** 2026-07-18  
**Status:** Runtime slice complete. Stacked after APP-64 through APP-67.  
**Contract:** `AUTH_ONBOARDING_EXPERIENCE_CONTRACT.md`

## Outcome

Auth session routing now goes through a shared readiness resolver instead of
each entry point deciding its own dashboard route.

The resolver is deliberately conservative:

```text
missing or invalid session -> onboarding
PATIENT session -> dashboard
PROFESSIONAL session -> medicalProfessional
```

This prevents restored professional sessions and existing Google/email
professional sign-ins from going straight to the dashboard before the app has a
real backend readiness snapshot for professional profile/application,
verification, licence, and status state.

## Runtime Scope

Changed:

- splash session restore now uses `OnboardingReadinessResolver`
- email sign-in success now routes through the resolver
- email Google sign-in success now routes through the resolver
- phone Google sign-in success now routes through the resolver
- tests prove professional sessions route to the professional readiness/setup
  surface instead of dashboard

The legacy local phone/password continue action is not a backend session path
and remains out of scope for this resolver slice.

## Product Boundary

This slice does not claim profile completeness or verification readiness.

The current Flutter app does not yet have a backend readiness endpoint with:

- email verification requirement state
- patient profile completeness
- professional application draft/submission state
- verification document status
- licence expiry/suspension state
- required next action
- safe return intent

Until that exists, professional sessions should land on the professional
setup/status surface instead of a full operational dashboard.

## Out Of Scope

- no backend readiness endpoint
- no profile/application status API
- no email-verification gate change
- no patient setup redesign
- no professional application redesign
- no server-side drafts
- no licence lifecycle
- no duplicate regulator checks
- no admin/support recovery flow
- no dashboard redesign
- no phone OTP
- no production readiness claim

## Verification

- `dart format` on changed Dart/test files
- `flutter test test\features\authentication\session_restore_guard_test.dart test\features\authentication\sign_in_flow_test.dart test\widget_test.dart`
- `flutter test`
- `flutter analyze`
- `git diff --check`

Focused auth/session resolver tests passed. Full Flutter tests passed with 292
tests, and analyzer reported no issues after import cleanup.

## Next Slice

APP-69: Patient setup and booking gate contract UI.

Recommended scope:

- make patient setup feel like a modern, lightweight healthcare profile step
- keep browsing low-friction
- keep booking-required fields separate from generic auth
- do not add backend readiness endpoint, professional application redesign,
  phone OTP, payments, calls, notes, or prescriptions in the patient setup slice
