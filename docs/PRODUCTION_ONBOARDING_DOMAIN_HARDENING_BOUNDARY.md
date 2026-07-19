# Production Onboarding Domain Hardening Boundary

**Slice:** APP-ID-008
**Date:** 2026-07-19
**Status:** Accepted decision; no runtime behavior changed.

## Context

The PRD defines CareNet as a dual-sided healthcare marketplace for regular
users and licensed medical professionals. Professional onboarding is not a
simple profile form: it must collect personal/professional details, credential
evidence, and then wait for admin/manual verification before public listing.

Current Flutter and backend work now supports:

- explicit patient/professional role selection before account creation
- email/password and first-time Google signup with selected role
- patient/professional profile setup screens
- backend-owned Nigeria onboarding catalogs
- account readiness read
- professional verification document upload/list
- public professional listing only after backend verification

APP-ID-007 fixed an immediate contract issue by sending catalog codes through
the current backend profile DTO fields. This does not make onboarding fully
production-grade by itself.

## Decision

Freeze broad onboarding feature expansion and harden the current onboarding
lane in a deliberate order. Do not add payments, reviews, calls, prescriptions,
clinical notes, public detail expansion, or admin dashboard behavior into
onboarding.

The next runtime work should focus on making the existing patient/professional
onboarding path reliable, abuse-resistant, and understandable before adding new
product modules.

## Accepted MVP Onboarding Model

### Account Role

An account has one backend role at registration:

- `PATIENT`
- `PROFESSIONAL`

For MVP, do not support in-app role switching or dual-mode accounts.

If a patient later wants to become a professional, that requires a backend
product decision for account upgrade/application flow. Until then, the user
should create/support-request the correct account path rather than silently
switching roles inside Flutter.

If a professional wants to use patient-side features, the app may show only
role-allowed surfaces until backend/product policy defines dual-mode access.

### Duplicate Identity

Do not allow Flutter to resolve duplicate identity cases locally.

Backend remains responsible for:

- duplicate email
- linked/unlinked Google identity collisions
- duplicate professional regulator registration
- account status and role authority

Flutter should show safe user-facing copy and never claim a second account,
link, or role conversion succeeded unless the backend returns success.

### Partial Applications

Partial professional onboarding is allowed only as backend-owned state.

Flutter should:

- read `GET /account/readiness`
- send the user to the next required setup step
- resume incomplete profile/document work when the account already exists
- avoid fake local completion markers

Flutter should not invent local application status, verification status, or
public listing readiness.

### Patient Profile

Patient onboarding is intentionally lighter than professional onboarding.

Required now:

- full name for first patient profile creation
- controlled Nigeria country/state when supplied
- controlled health-interest option when supplied by the setup form

Deferred:

- disease/diagnosis intake
- emergency/contact preferences
- dependent/family profiles
- clinical risk triage
- insurance/payment information
- phone/OTP completion

Patient health interests are discovery/preferences, not medical diagnosis.

### Professional Profile

Professional onboarding is strict because public trust depends on verification.

Required profile fields for first creation:

- legal name
- public professional name
- supported profession/category
- license or registration number
- matching regulator/council
- qualifications
- years of experience
- practice/facility name
- practice city
- practice state

Nigeria launch rules:

- country is Nigeria-only
- profession must come from backend catalog
- regulator/council is derived from selected profession
- practice state must be a backend Nigerian state code
- license number must remain backend validated and normalized

Flutter should improve the UI around these fields, but backend remains the
authority.

## Required Professional Evidence

For the current Nigeria MVP, professional verification should guide users to
upload the evidence required by the backend catalog:

- government identity
- professional registration or license
- qualification certificate

The mobile app may display required evidence guidance from
`GET /catalogs/onboarding` and `GET /account/readiness`, but it must not claim a
document is clinically/regulator-verified until backend/admin review marks it
accepted.

## UX Hardening Direction

The next implementation should improve the existing setup flow without changing
the product scope:

- role-specific entry and resume state from backend readiness
- clear progress sections for patient/professional setup
- controlled selectors for country, state, profession, and health interest
- helper text for professional regulator and required evidence
- field-level validation before submit
- backend error display that is safe but actionable
- no dummy fallback when catalogs/readiness fail
- no fake success if profile save, Google signup, or verification upload fails

The UI can be visually upgraded, but the main product requirement is correctness
and trust.

## Explicitly Deferred

- in-app patient/professional role switching
- dual-mode accounts
- account upgrade from patient to professional
- automatic regulator lookup
- live license good-standing/expiry checks
- LGA/city authoritative catalog
- address geocoding/location proof
- professional rejection/appeal UX
- admin review dashboard in mobile
- Google unlink and cross-email recovery linking
- phone/OTP
- MFA/recent re-auth
- payments, payouts, refunds, reviews, calls, calendar sync, medical notes,
  prescriptions, no-show/disputes, and emergency escalation
- production healthcare/legal/compliance certification claims

## Next Slice

`APP-ID-009 - Onboarding Readiness Resume And UX Hardening Plan`

Scope:

- inspect current patient/professional setup screens and readiness data
- decide the exact runtime UX changes for resume/progress/error handling
- map current screens to backend readiness next actions
- decide what can be implemented without backend changes
- queue one narrow runtime slice after the plan

Do not implement runtime behavior in APP-ID-009.

## Adversarial Review

Result: **PASS WITH FOLLOW-UP**.

Questions checked:

- Can Flutter self-set professional verification? No, must remain backend-owned.
- Can Google profile data become trusted medical identity? No.
- Can duplicate account/provider conflicts be solved locally? No.
- Can a patient silently become a professional? No, deferred to backend/product.
- Can unsupported country/state/profession values be submitted? The current
  UI uses backend catalogs and backend still validates.
- Can professional upload be treated as approval? No, document upload and admin
  approval remain separate.

Follow-up:

- APP-ID-009 must convert this decision into a concrete runtime hardening plan.
- Later runtime slices should improve resume/progress/error UX one piece at a
  time and prove with tests plus phone smoke.

## Verification

Decision-only slice. Checked:

- PRD `C:\Users\asd\Downloads\Carenet_PRD_v1.0.pdf`
- existing role/onboarding decision docs
- backend onboarding catalog/readiness/profile API plan
- APP-ID-007 payload alignment docs

No runtime code changed.
