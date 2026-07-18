# Professional Application Shell Visual System

**Slice:** APP-70
**Date:** 2026-07-18
**Status:** Implemented runtime UI.

## What Changed

`medicalProfessional` / `ProfessionalOnboardingSetupPage` now reads as a
professional application step instead of a generic profile form.

The screen now:

- introduces the application as a credential-review flow
- shows `Step 1 of 2` before evidence upload
- separates legal identity, public name, credentials, and practice details
- labels private review fields and public-after-approval fields
- keeps the submit action tied to the real `ProfileRepository.updateProfessionalMe`
  backend path
- routes to verification document upload only after the profile save succeeds
- states that approval and public listing require backend verification

## Product Boundary

This slice does not add server-side drafts, review-and-change pages,
professional application status hubs, licence expiry lifecycle, regulator
catalogs, duplicate licence checks, admin approval, public listing claims,
payouts, calls, notes, prescriptions, or medical records.

The current app still saves the complete supported professional profile in one
backend call because the backend does not yet expose draft/resume semantics for
multi-step application progress.

## Verification

Passed:

- `flutter test test\features\onboarding\profile_setup_test.dart`

Full-suite verification is recorded in the APP-70 PR before merge.

## Follow-Up

Next slice:

`APP-71 - Professional evidence/status experience`

APP-71 should integrate the existing verification document surface into a
clearer status/evidence experience without faking approval, rejection reasons,
admin decisions, licence renewal, public listing, payouts, calls, notes, or
prescriptions.
