# Patient And Professional Onboarding Setup UI

**Slice:** APP-60
**Date:** 2026-07-17
**Status:** Implemented runtime UI.

## What Changed

The post-registration onboarding flow now saves real backend profile data before
continuing.

Patient registration now routes to `patientOnboardingSetup`, where the user can
save full name, date of birth, city, state, country, and health interests.

Professional registration now routes to the existing `medicalProfessional`
route, which has been replaced with a credential/profile setup form. The form
saves legal name, public professional name, profession/category, specialty,
license or registration number, licensing council/body, qualifications, years
of experience, and practice details.

After successful professional profile save, the app routes to
`professionalVerificationDocuments` so the professional can upload documents.
Public listing still waits for backend verification.

## Product Boundaries

This slice does not enable Google first-time sign-up, automatic license
verification, admin approval, public exposure of private credential fields,
payments, reviews, calls, notes, prescriptions, calendar sync, or public
professional detail expansion.

## Verification

Passed:

- `dart format` on changed Dart files and tests
- `flutter test test/features/authentication/finish_sign_up_test.dart test/features/onboarding/profile_setup_test.dart`
- `flutter analyze` on changed onboarding/auth route files and focused tests

## Next Slice

Recommended next slice:

`APP-61 - Onboarding Setup Regression And Phone Smoke`

That slice should run broader auth/onboarding/profile tests, rebuild the staging
APK, and manually smoke patient/professional setup on the phone before adding
more product modules.
