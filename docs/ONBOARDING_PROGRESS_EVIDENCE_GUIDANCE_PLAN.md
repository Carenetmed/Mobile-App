# Onboarding Progress And Required Evidence Guidance Plan

**Slice:** APP-ID-011
**Date:** 2026-07-19
**Status:** Accepted plan; no runtime behavior changed.

## Purpose

Define the next production-onboarding UI hardening step after the readiness
route resolver. The app now asks the backend where a new user should continue,
but the destination screens still need to explain what is missing and what the
user should do next.

This slice is planning only. It does not change Flutter runtime behavior.

## Current Runtime Facts

- `patientOnboardingSetup` and `medicalProfessional` already load
  `GET /catalogs/onboarding` and protected `GET /account/readiness`.
- Setup screens use controlled catalog options instead of free text for launch
  country/state, profession, regulator, and patient health interest.
- Post-signup email/password and first-time Google signup now use
  `OnboardingReadinessRouteResolver` before choosing the next route.
- `professionalVerificationDocuments` can list owner documents and upload one
  PDF/JPEG/PNG document through `VerificationRepository`.

## Current Gaps

- Setup screens show only generic readiness copy and missing counts.
- Patient setup does not display the exact backend-required profile fields in a
  way that explains why the user is still there.
- Professional setup does not display required profile fields as a structured
  checklist.
- Verification upload still uses hardcoded document type codes:
  `LICENSE`, `IDENTITY`, and `CERTIFICATION`.
- Verification upload does not yet show backend `requiredEvidence` and
  `missingEvidence` guidance from readiness.
- Pending, rejected, and review states all land on the same documents shell
  without enough status-specific copy.
- The screens do not yet clearly separate:
  - profile fields still missing
  - evidence still missing
  - evidence uploaded and waiting for review
  - rejected/status attention needed
  - verified/ready state

## Accepted Runtime Direction

Add a small shared readiness/progress presentation layer that is fed by backend
readiness and onboarding catalog data. The UI should be clear and polished, but
the important product rule is correctness:

- display backend-owned readiness status
- display exact missing profile fields when provided
- display required and missing professional evidence when provided
- use catalog labels for evidence codes when available
- use safe fallback labels for unknown evidence codes without hiding the code
- show honest loading, unavailable, and retry states
- never claim professional verification from profile save or document upload
- never invent local readiness, application status, or approval state

## Evidence Code Mapping

The backend readiness service currently returns required evidence in catalog
codes such as:

- `GOVERNMENT_IDENTITY`
- `PROFESSIONAL_REGISTRATION_OR_LICENSE`
- `QUALIFICATION_CERTIFICATE`

The verification upload API still accepts legacy upload document type codes:

- `IDENTITY`
- `LICENSE`
- `CERTIFICATION`

The next runtime slice may map readiness evidence to the existing upload codes
for display and picker defaults, but it must not invent new backend request
fields. Any native evidence-code upload API should be a future backend contract
slice.

## Next Runtime Slice

`APP-ID-012 - Add Onboarding Readiness Progress Panel`

Scope:

- Add a reusable, small progress/status panel for onboarding readiness.
- Use it in patient setup to show patient profile status and required fields.
- Use it in professional setup to show professional application/profile field
  progress.
- Use it in professional verification documents to show required evidence,
  missing evidence, current status, and retry guidance.
- Load readiness/catalog in the verification documents shell without dummy
  local fallback.
- Keep existing upload behavior real and backend-backed.
- Add focused widget/unit tests for patient setup, professional setup, and
  verification guidance states.

If the runtime edit grows too large, split verification-specific guidance into
`APP-ID-013 - Add Professional Verification Evidence Guidance`, but do not
re-decide the product boundary.

## Explicitly Out Of Scope

- no backend API changes
- no new profile fields
- no role switching or dual-mode accounts
- no patient-to-professional upgrade
- no live regulator lookup
- no license expiry or good-standing check
- no city/LGA authoritative catalog
- no phone/OTP
- no Google unlink or recovery linking
- no professional approval claim
- no admin dashboard
- no payments, payouts, refunds, reviews, calls, calendar sync, medical notes,
  prescriptions, no-show/disputes, or emergency escalation
- no production healthcare/legal/compliance certification claim

## Adversarial Review

Result: **PASS WITH FOLLOW-UP**.

Checks:

- Does the plan trust Flutter over backend readiness? No.
- Does it hide backend failures behind dummy local state? No.
- Does upload equal verification? No.
- Does it make role switching or duplicate-account decisions in Flutter? No.
- Does it change backend document-code contracts? No.
- Does it create broad onboarding redesign scope? No; the next slice is a
  focused progress/guidance layer.

Follow-up:

- APP-ID-012 must prove the UI states with focused tests and keep backend
  failure states visible.

## Verification

Planning slice only.

Checked:

- `docs/ONBOARDING_READINESS_ROUTE_RESOLVER.md`
- `docs/ONBOARDING_READINESS_RESUME_UX_HARDENING_PLAN.md`
- `docs/PRODUCTION_ONBOARDING_DOMAIN_HARDENING_BOUNDARY.md`
- `lib/features/Onboarding/presentation/pages/profile_setup.dart`
- `lib/features/Home/presentation/pages/professional_verification_documents_shell.dart`
- backend `AccountReadinessService`

Passed:

- `git diff --check`
