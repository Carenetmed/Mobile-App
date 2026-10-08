# Onboarding Readiness Route Resolver

**Slice:** APP-ID-010
**Date:** 2026-07-19
**Status:** Implemented.

## What Changed

Flutter now has a small `OnboardingReadinessRouteResolver` that maps backend
`AccountReadiness.nextAction` values to route names.

After successful email/password signup and first-time Google signup, Flutter
now calls `OnboardingRepository.accountReadiness()` before choosing the next
onboarding destination.

## Route Rules

| Backend `nextAction` | Flutter route |
|----------------------|---------------|
| `PATIENT_SETUP` | `patientOnboardingSetup` |
| `PATIENT_BOOKING_GATE` | `dashboard` |
| `PROFESSIONAL_RESUME_APPLICATION` | `medicalProfessional` |
| `PROFESSIONAL_UPLOAD_EVIDENCE` | `professionalVerificationDocuments` |
| `PROFESSIONAL_REVIEW` | `professionalVerificationDocuments` |
| `PROFESSIONAL_STATUS` | `professionalVerificationDocuments` |
| `DASHBOARD` | `dashboard` |

The backend-issued authenticated session role is the fallback authority. The
resolver also rejects a readiness role that disagrees with that session role,
and ignores role-specific actions that do not match it. Unknown roles fail
closed to the dashboard shell, which performs its own role guard.

Unknown or unavailable readiness falls back by authenticated role:

- `PATIENT` -> `patientOnboardingSetup`
- `PROFESSIONAL` -> `medicalProfessional`
- unknown role -> `dashboard`

This prevents the role-selection screen or a mismatched readiness response
from routing an authenticated account into another role's setup. In the
password and Google signup flows, fallback role comes from the session returned
by the backend, never from the mutable signup widget selection.

## Not Changed

- no backend API changes
- no setup form redesign
- no role switching or dual-mode accounts
- no verification approval claim
- no payment, review, call, note, prescription, phone/OTP, or admin behavior

The sign-in email screen now uses the current CareNet green token system,
persistent field labels, accessible error announcements, and compact scrolling
layout. Authentication and booking-resume behavior are unchanged.

## Verification

Passed:

- `flutter test test/features/onboarding/onboarding_readiness_route_resolver_test.dart test/features/authentication/finish_sign_up_test.dart test/features/authentication/sign_up_flow_test.dart -r expanded`
- `flutter analyze lib/features/Onboarding/domain/services/onboarding_readiness_route_resolver.dart lib/features/Authentication/presentation/pages/sign_up_arguments.dart lib/features/Authentication/presentation/pages/sign_up_email.dart lib/features/Authentication/presentation/pages/sign_up_phone.dart lib/core/constants/navigators/router.dart lib/features/Authentication/presentation/pages/sign_up_role_selection.dart lib/features/Authentication/presentation/pages/sign_up_con.dart test/features/onboarding/onboarding_readiness_route_resolver_test.dart test/features/authentication/finish_sign_up_test.dart test/features/authentication/sign_up_flow_test.dart`
- `git diff --check`

## Next Slice

`APP-ID-011 - Add Onboarding Progress And Required Evidence Guidance Plan`

That should decide how to display readiness progress and professional evidence
requirements before the next UI implementation slice.
