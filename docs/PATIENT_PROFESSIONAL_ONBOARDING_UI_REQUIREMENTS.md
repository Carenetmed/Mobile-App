# Patient And Professional Onboarding UI Requirements

**Slice:** APP-58
**Date:** 2026-07-17
**Status:** Accepted requirements/design boundary; no runtime behavior changed.

## Purpose

Define the next patient/professional onboarding screens before implementation.
The UI must be rebuilt as a serious medical-product flow, but it must submit
only fields that the backend owns.

This follows:

- `ROLE_BASED_ONBOARDING_AUTH_BOUNDARY.md`
- `ROLE_REGISTRATION_BACKEND_CONTRACT.md`
- backend `CAR-BE-119 - Nigeria Onboarding Profile Schema`

## Product Decision

CareNet onboarding is no longer a simple "name and enter app" path.

After explicit role selection:

```text
Patient
-> account registration
-> patient profile setup
-> app access with profile prompts

Professional
-> account registration
-> professional credential/profile setup
-> verification document upload
-> manual/admin verification
-> public listing only after backend VERIFIED status
```

Google sign-up must follow the same role/profile boundary later. Google display
name/photo must not be treated as trusted CareNet patient or professional
profile data.

## Patient Onboarding Fields

Patient onboarding should feel light, safe, and privacy-aware.

Backend-owned fields available after `CAR-BE-119`:

| Field | UI label | Requirement for first UI pass |
|-------|----------|-------------------------------|
| `name` | Full legal or preferred name | Required |
| `dateOfBirth` | Date of birth | Optional in first UI pass unless product/legal later requires it |
| `city` | City | Optional |
| `state` | State | Optional |
| `country` | Country | Default Nigeria when appropriate, editable |
| `healthInterests` | Health interests | Optional free text or chips in later pass |

Older frontend `age` and `location` are still supported by the current
repository, but the new onboarding UI should prefer `dateOfBirth`, `city`,
`state`, and `country` once the frontend model/repository is expanded.

## Professional Onboarding Fields

Professional onboarding must be stricter because this is a healthcare
marketplace and public listing depends on verification.

Backend-owned fields available after `CAR-BE-119`:

| Field | UI label | Requirement |
|-------|----------|-------------|
| `legalName` | Legal name | Required |
| `displayName` | Public professional name | Required |
| `category` | Profession/category | Required |
| `specialty` | Specialty | Optional |
| `bio` | Professional bio | Optional, can be completed later |
| `licenseNumber` | License or registration number | Required |
| `licensingCouncil` | Licensing council/body | Required |
| `qualifications` | Qualifications | Required |
| `yearsOfExperience` | Years of experience | Required, numeric, 0-80 |
| `practiceName` | Practice or facility name | Required |
| `practiceAddress` | Practice address | Optional in first UI pass |
| `practiceCity` | Practice city | Required |
| `practiceState` | Practice state | Required |
| `practiceCountry` | Practice country | Default Nigeria when appropriate, editable |

The first serious professional form should not allow a professional profile to
be created without the backend-required fields. It should not let the user edit
`verificationStatus`, document status, public listing state, admin decision
fields, ratings, pricing, payouts, availability, notes, prescriptions, or
medical records.

## Suggested Screen Flow

### Patient Flow

1. Role selection: Patient selected.
2. Account details: email/password or future provider branch.
3. Patient profile setup:
   - full name
   - date of birth
   - city/state/country
   - optional health interests
4. Agreement/terms screen when product/legal copy is available.
5. Dashboard, with profile completion prompts if optional fields are missing.

### Professional Flow

1. Role selection: Professional selected.
2. Account details: email/password or future provider branch.
3. Professional identity:
   - legal name
   - public professional name
   - profession/category
   - specialty
4. Credentials:
   - license number
   - licensing council/body
   - qualifications
   - years of experience
5. Practice:
   - practice/facility name
   - practice city/state/country
   - optional practice address
6. Verification documents:
   - use existing `professionalVerificationDocuments` upload/list flow
7. Verification pending state:
   - explain that public listing waits for manual review
   - do not claim approval, listing, earnings, calls, prescriptions, or booking
     readiness until backend state supports it

## UI Quality Direction

The implementation should replace the current weak onboarding/professional
surface with a more mature app flow:

- clear stepper/progress indication
- grouped sections instead of one long unstructured form
- professional labels and helper copy
- strong validation messages near the field
- disabled submit while required fields are incomplete
- safe loading and error states
- review/confirmation state before submission if the form is long
- no hidden dummy data, fake success, or local-only professional completion

Use existing shared tokens and widgets first. Add new shared components only if
two or more onboarding screens need them.

## Frontend Repository Gap

Before these screens can save the new fields, Flutter must expand the profile
entities/models/API client/repository payloads.

Current Flutter profile boundary is still shallow:

- patient: `name`, `age`, `location`
- professional: `displayName`, `category`, `specialty`, `bio`

Next implementation should therefore either:

1. expand the profile repository/model boundary first, or
2. implement the new UI with a disabled/blocked save state until the repository
   expansion slice is complete.

`APP-59` expanded the frontend profile contract/repository for the new backend
fields. The next runtime slice can build the polished multi-step UI against that
contract.

## Explicitly Deferred

- Google first-time sign-up runtime
- phone/OTP completion
- Facebook/Apple providers
- Nigeria council option catalogs and authoritative regulator validation
- automatic license verification
- admin verification dashboard inside the mobile app
- professional approval/rejection reasons UI
- payments, payouts, subscriptions, reviews, calls, prescriptions, medical
  notes, calendar sync, no-show/dispute states, and emergency escalation
- public professional detail expansion beyond existing safe listing fields

## Stop Conditions

Stop before implementation if a future slice tries to:

- create a professional profile without the backend-required credential fields
- save new onboarding fields without repository/API support
- treat Google display name as trusted profile identity
- self-set professional verification/public listing state
- expose professional legal/license/practice-address fields in public listing
- add payments, calls, reviews, notes, prescriptions, or admin behavior into
  onboarding

## Decision Summary

Build onboarding as a real patient/professional medical-product flow. Flutter's
profile repository/models now support the backend fields, so the next runtime
work should build polished patient and professional setup screens against those
fields.
