# Patient Setup Booking Gate UI

**Slice:** APP-69
**Date:** 2026-07-18
**Status:** Implemented runtime UI.

## What Changed

`patientOnboardingSetup` now presents patient setup as a lightweight care
profile step instead of a plain required form.

The screen now:

- explains that patient setup is optional for browsing
- keeps `Save and continue` on the real `ProfileRepository.updatePatientMe`
  backend path
- adds `Skip for now` without calling profile mutation
- clearly states that skipping does not mark the patient profile ready for
  booking
- keeps booking readiness, consultation consent, verified contact, payments,
  calls, notes, prescriptions, and medical-record behavior out of this slice

## Product Boundary

Patient setup can be skipped for browsing, but booking readiness is not claimed
from this screen. A later booking gate must require the backend-owned profile
and contact/consent checks defined in `AUTH_ONBOARDING_EXPERIENCE_CONTRACT.md`.

This slice does not add a readiness endpoint, a booking gate service, fake local
profile completion, local appointment success, or any backend fallback.

## Verification

Passed:

- `flutter test test\features\onboarding\profile_setup_test.dart`

Full-suite verification is recorded in the APP-69 PR before merge.

## Follow-Up

Next slice:

`APP-70 - Professional application shell and visual system`

APP-70 should redesign the professional setup into an application-grade shell
without faking server-side drafts, verification approval, licence lifecycle,
public listing, payouts, calls, notes, prescriptions, or admin decisions.
