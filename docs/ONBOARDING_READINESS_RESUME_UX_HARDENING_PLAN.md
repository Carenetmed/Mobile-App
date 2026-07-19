# Onboarding Readiness Resume And UX Hardening Plan

**Slice:** APP-ID-009
**Date:** 2026-07-19
**Status:** Accepted plan; no runtime behavior changed.

## Purpose

Convert the APP-ID-008 production onboarding boundary into an exact runtime
plan. The goal is to make onboarding resume and progress behavior backend-owned
before polishing more UI.

This slice does not implement code. It defines the next narrow implementation
slice.

## Current Problem

The app has real role-based registration, profile setup, catalog-backed fields,
and verification upload. However, post-signup and returning-user navigation
still mostly uses fixed routes:

- patient signup routes to `patientOnboardingSetup`
- professional signup routes to `medicalProfessional`
- professional profile save routes to `professionalVerificationDocuments`

That works for a first pass, but it is not robust enough for production-style
onboarding because users can leave halfway, return later, hit backend failures,
or already have partial profile/evidence state.

The backend already exposes `GET /account/readiness`. Flutter should use that
as the authority for where onboarding resumes.

## Backend Readiness Map

Source: backend `AccountReadinessService`.

| `nextAction` | Meaning | Flutter destination |
|--------------|---------|---------------------|
| `PATIENT_SETUP` | Patient profile missing required fields | `patientOnboardingSetup` |
| `PATIENT_BOOKING_GATE` | Reserved patient booking gate | `dashboard` for now, with booking-specific gates later |
| `PROFESSIONAL_RESUME_APPLICATION` | Professional profile missing required fields or not started | `medicalProfessional` |
| `PROFESSIONAL_UPLOAD_EVIDENCE` | Professional profile exists but required evidence is missing | `professionalVerificationDocuments` |
| `PROFESSIONAL_REVIEW` | Profile/evidence present; waiting for review/submission handling | `professionalVerificationDocuments` for now with pending-review copy |
| `PROFESSIONAL_STATUS` | Professional is pending/rejected or otherwise needs status handling | `professionalVerificationDocuments` for now with status copy |
| `DASHBOARD` | Account is ready for normal entry | `dashboard` |

Unknown or blank `nextAction` should fail safely to role-aware setup when role
is known:

- `PATIENT` -> `patientOnboardingSetup`
- `PROFESSIONAL` -> `medicalProfessional`
- otherwise -> `dashboard` only if the backend session is valid

## Next Runtime Slice

`APP-ID-010 - Add Onboarding Readiness Route Resolver`

Scope:

- add a small Flutter helper/service that maps `AccountReadiness.nextAction`
  and backend role to a route name
- call `OnboardingRepository.accountReadiness()` after successful email/password
  and Google signup before choosing the destination
- keep current hardcoded route as a safe fallback only when readiness cannot be
  fetched, with visible safe error/copy where appropriate
- add focused tests for every known `nextAction`
- do not change backend APIs
- do not redesign the setup forms in this slice
- do not implement role switching, dual-mode accounts, payments, reviews, calls,
  notes, prescriptions, admin dashboard, or phone/OTP

## Later Runtime UX Hardening

After APP-ID-010, use smaller follow-up slices:

1. Add a progress/readiness panel to patient and professional setup screens.
2. Show required evidence guidance from catalog/readiness on verification
   upload.
3. Improve professional form helper text for regulator/license requirements.
4. Add real phone/staging smoke for:
   - new patient signup -> readiness -> patient setup
   - returning incomplete patient -> readiness -> patient setup
   - new professional signup -> readiness -> professional setup
   - professional with profile but missing evidence -> readiness -> upload
   - professional pending/rejected/verified -> status/dashboard behavior

## Accepted Error Behavior

Readiness fetch failure after successful signup should not claim completion.

Accepted behavior for the next runtime slice:

- show safe copy such as `Account created. We could not check the next setup
  step. Please continue setup.`
- route based on selected role only as a fallback
- do not route a professional directly to dashboard when readiness fails
- do not store local fake readiness

## Out Of Scope

- broad UI redesign
- new backend fields
- account role switching
- dual-mode accounts
- automatic regulator lookup
- license expiry/good-standing checks
- city/LGA catalog
- phone/OTP
- Google unlink/recovery linking
- admin review dashboard
- payments, reviews, calls, calendar sync, notes, prescriptions, no-show
  disputes, or emergency escalation

## Adversarial Review

Result: **PASS WITH FOLLOW-UP**.

Checks:

- Avoids trusting Flutter role/state over backend readiness.
- Avoids sending professionals to dashboard when readiness is unavailable.
- Keeps unknown readiness actions safe and explicit.
- Does not turn upload or profile save into verification approval.
- Does not add fake local state to hide backend failures.

Follow-up:

- APP-ID-010 must implement the route resolver with exhaustive tests and keep
  all unknown/failure states honest.

## Verification

Decision/planning slice only.

Checked:

- `docs/PRODUCTION_ONBOARDING_DOMAIN_HARDENING_BOUNDARY.md`
- Flutter `AccountReadiness` entity/model
- Flutter signup and onboarding route code
- backend `AccountReadinessService`
- current verification document shell

Passed:

- `git diff --check`
