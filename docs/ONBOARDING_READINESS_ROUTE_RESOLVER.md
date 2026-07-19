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

Unknown or unavailable readiness falls back by selected role:

- `PATIENT` -> `patientOnboardingSetup`
- `PROFESSIONAL` -> `medicalProfessional`
- unknown role -> `dashboard`

This prevents professional accounts from going directly to dashboard merely
because readiness could not be fetched.

## Not Changed

- no backend API changes
- no setup form redesign
- no role switching or dual-mode accounts
- no verification approval claim
- no payment, review, call, note, prescription, phone/OTP, or admin behavior

## Verification

Passed:

- `flutter test test/features/onboarding/onboarding_readiness_route_resolver_test.dart test/features/authentication/finish_sign_up_test.dart test/features/authentication/sign_up_flow_test.dart -r expanded`
- `flutter analyze lib/features/Onboarding/domain/services/onboarding_readiness_route_resolver.dart lib/features/Authentication/presentation/pages/sign_up_arguments.dart lib/features/Authentication/presentation/pages/sign_up_email.dart lib/features/Authentication/presentation/pages/sign_up_phone.dart lib/core/constants/navigators/router.dart lib/features/Authentication/presentation/pages/sign_up_role_selection.dart lib/features/Authentication/presentation/pages/sign_up_con.dart test/features/onboarding/onboarding_readiness_route_resolver_test.dart test/features/authentication/finish_sign_up_test.dart test/features/authentication/sign_up_flow_test.dart`
- `git diff --check`

## Next Slice

`APP-ID-011 - Add Onboarding Progress And Required Evidence Guidance Plan`

That should decide how to display readiness progress and professional evidence
requirements before the next UI implementation slice.
