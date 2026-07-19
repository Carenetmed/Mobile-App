# Backend Identity And Catalog Contract

**Slice:** APP-ID-002
**Date:** 2026-07-19
**Status:** Contract proposal; no runtime behavior changed.
**Depends on:** `APP-ID-001 - Identity, Role, Onboarding, And Verification Foundation`

## Purpose

Define the backend contract needed before CareNet rebuilds patient onboarding,
professional application, and verification UI into production-grade controlled
flows.

This slice answers the product gap raised during phone smoke:

- if launch is Nigeria-only, country cannot be an arbitrary text box
- if the selected country is Nigeria, state/city must follow Nigeria-aware rules
- if the selected profession is Nigerian medical doctor, dentist, nurse,
  pharmacist, medical laboratory scientist, or radiographer, the regulator and
  required evidence must follow that profession
- unsupported professions must not slip through as free text and become public
  medical claims

This is a backend contract. It does not implement schema or UI.

## Current Backend Reality

The backend currently has useful foundations:

- `User.role` with `PATIENT`, `PROFESSIONAL`, `ADMIN`, `SUPER_ADMIN`
- one optional `PatientProfile` per user
- one optional `ProfessionalProfile` per user
- `ProfessionalProfile.verificationStatus`
- private `VerificationDocument` metadata and upload flow
- admin verification decision routes
- public verified professional listing

Current fields are still too loose for production identity:

| Area | Current shape | Production gap |
|------|---------------|----------------|
| Patient location | `city`, `state`, `country` strings | no Nigeria-only or state/city catalog validation |
| Patient health interests | string | no controlled interests, no consented health-intake model |
| Profession | `category` string | no supported-profession catalog |
| Regulator | `licensingCouncil` string | no profession-to-regulator constraint |
| Licence | `licenseNumber` string | no normalization, duplicate guard, expiry, regulator-specific validation |
| Specialty | `specialty` string | no profession-scoped specialty catalog |
| Qualifications | `qualifications` string | no structured qualification entries or evidence mapping |
| Verification document type | `documentType` string | no backend enum/catalog or profession-required checklist |
| Professional application | profile update + documents | no draft/submission/readiness state machine |

Backend files inspected:

- backend `prisma/schema.prisma`
- backend `src/professionals/dto/update-professional-profile.dto.ts`
- backend `src/users/dto/update-patient-profile.dto.ts`
- backend `src/verification/dto/init-verification-document-upload.dto.ts`

## Launch Country Decision

MVP launch country is:

```text
NG - Nigeria
```

Backend behavior:

- patient and professional onboarding should default to Nigeria
- non-Nigeria professional onboarding must be unavailable for MVP unless a
  later country-expansion decision activates it
- non-Nigeria patient browse may remain possible only if the product accepts it,
  but booking/service eligibility must be decided separately
- professional regulator and evidence rules are country-scoped

Recommended backend catalog endpoint:

```http
GET /catalogs/onboarding
```

Safe response shape:

```json
{
  "launchCountry": "NG",
  "countries": [{ "code": "NG", "name": "Nigeria", "status": "SUPPORTED" }],
  "nigeriaStates": [{ "code": "LA", "name": "Lagos" }],
  "professionalCatalog": [],
  "patientHealthInterestCatalog": []
}
```

The exact state/LGA data source should be a backend-owned catalog file/table,
not hand-typed inside Flutter screens.

## Supported Nigeria Professional Catalog

The first production catalog should be deliberately narrow.

| Profession code | Label | Regulator code | Regulator name | MVP status |
|-----------------|-------|----------------|----------------|------------|
| `MEDICAL_DOCTOR` | Medical doctor | `MDCN` | Medical and Dental Council of Nigeria | Supported |
| `DENTIST` | Dentist | `MDCN` | Medical and Dental Council of Nigeria | Supported |
| `NURSE` | Nurse | `NMCN` | Nursing and Midwifery Council of Nigeria | Supported |
| `MIDWIFE` | Midwife | `NMCN` | Nursing and Midwifery Council of Nigeria | Supported |
| `PHARMACIST` | Pharmacist | `PCN` | Pharmacy Council of Nigeria | Supported |
| `MEDICAL_LAB_SCIENTIST` | Medical laboratory scientist | `MLSCN` | Medical Laboratory Science Council of Nigeria | Supported |
| `RADIOGRAPHER` | Radiographer | `RRBN` | Radiographers Registration Board of Nigeria | Supported pending final regulator check |

Unsupported for first production path:

- dietitian/nutritionist
- mental-health practitioner
- psychologist/therapist/counsellor
- wellness coach
- alternative medicine practitioner
- clinic/organization/staff account
- any other profession without an approved regulator/evidence rule

Unsupported professions should return a safe `UNSUPPORTED_PROFESSION` or
`MANUAL_REVIEW_UNAVAILABLE` outcome, not create a public professional profile
from free text.

## Regulator Evidence Matrix

Selected country + profession determines the required evidence checklist.

Baseline document types should become backend-owned enum/catalog values:

```text
GOVERNMENT_IDENTITY
PROFESSIONAL_REGISTRATION_OR_LICENSE
QUALIFICATION_CERTIFICATE
GOOD_STANDING_OR_RENEWAL_EVIDENCE
PRACTICE_OR_FACILITY_EVIDENCE
```

The current backend `IDENTITY`, `LICENSE`, and `CERTIFICATION` document types
can map to the first three, but the new contract should avoid keeping
`documentType` as arbitrary text.

| Profession | Required evidence for submission | Deferred / conditional evidence |
|------------|----------------------------------|---------------------------------|
| Medical doctor | government identity, MDCN registration/licence evidence, medical qualification evidence | good standing/current-renewal evidence, additional qualifications |
| Dentist | government identity, MDCN registration/licence evidence, dental qualification evidence | good standing/current-renewal evidence, additional qualifications |
| Nurse | government identity, NMCN registration/licence evidence, nursing qualification evidence | licence renewal/current-practice evidence |
| Midwife | government identity, NMCN registration/licence evidence, midwifery qualification evidence | licence renewal/current-practice evidence |
| Pharmacist | government identity, PCN registration/licence evidence, pharmacy qualification evidence | annual licence/current-practice evidence |
| Medical laboratory scientist | government identity, MLSCN registration/licence evidence, qualification evidence | current-practice/renewal evidence |
| Radiographer | government identity, RRBN registration/licence evidence, qualification evidence | current-practice/renewal evidence |

Evidence rules should be served by backend catalog/readiness responses so the
Flutter app asks for the right documents after profession selection.

## Official-Source Boundary

Current official-source checks support the regulator-aware direction:

- MDCN describes itself as regulating medical and dental practice in Nigeria.
- NMCN licensing pages describe licensing/updating and verification services
  for registered nurses.
- PCN registration/licensing pages expose pharmacist registration and licensing
  services, and a public pharmacist licence-status verification surface.
- MLSCN exposes practitioner registration/licensure portal surfaces.

These sources support mapping profession to regulator and asking for evidence.
They do not justify hardcoding exact registration-number formats yet.

Backend rule:

- normalize licence numbers for comparison
- enforce basic safe character/length rules
- require regulator + normalized registration number uniqueness or manual
  review
- defer strict regulator-specific format validation until format evidence is
  verified for each regulator

## Licence Normalization And Duplicate Guard

Backend should store both display and normalized values:

```text
registrationNumberRaw
registrationNumberNormalized
regulatorCode
professionCode
countryCode
```

Normalization:

- trim
- uppercase
- remove spaces and separators used only for presentation
- reject empty values
- reject values outside safe length limits
- reject unsafe characters

Duplicate rule:

```text
countryCode + regulatorCode + registrationNumberNormalized
```

must be unique for approved public professionals, or must create a manual
duplicate-review state before any public listing.

Do not let a mobile client bypass duplicate checks by changing display name,
specialty, or document uploads.

## Professional Application State Contract

Current `VerificationStatus` is not enough by itself for application readiness.

Recommended backend-owned application status:

```text
NOT_STARTED
DRAFT
READY_TO_SUBMIT
SUBMITTED
PENDING_REVIEW
VERIFIED
REJECTED
EXPIRED
SUSPENDED
SUPPORT_REQUIRED
```

Minimum state rules:

- `DRAFT` can save partial controlled fields
- `READY_TO_SUBMIT` requires all required profile/catalog fields and evidence
  checklist items
- `SUBMITTED`/`PENDING_REVIEW` prevents casual mutation of regulator identity
  unless backend returns the application to draft/correction mode
- `VERIFIED` is required for public listing and booking eligibility
- `REJECTED` requires a product-approved correction/resubmission path
- `EXPIRED` or `SUSPENDED` disables public booking
- terminal/restricted states must not be overwritten by profile edit routes

## Readiness Snapshot Contract

The frontend needs one backend-owned readiness response after auth, session
restore, profile save, document upload, and app launch.

Recommended route:

```http
GET /account/readiness
```

Safe response shape:

```json
{
  "account": {
    "role": "PROFESSIONAL",
    "status": "ACTIVE",
    "emailVerified": true
  },
  "patient": {
    "profileStatus": "NOT_APPLICABLE",
    "requiredFields": []
  },
  "professional": {
    "applicationStatus": "DRAFT",
    "verificationStatus": "NOT_SUBMITTED",
    "countryCode": "NG",
    "professionCode": "MEDICAL_DOCTOR",
    "regulatorCode": "MDCN",
    "requiredProfileFields": ["legalName", "displayName", "registrationNumber"],
    "requiredEvidence": [
      "GOVERNMENT_IDENTITY",
      "PROFESSIONAL_REGISTRATION_OR_LICENSE",
      "QUALIFICATION_CERTIFICATE"
    ],
    "missingEvidence": ["QUALIFICATION_CERTIFICATE"]
  },
  "nextAction": "PROFESSIONAL_RESUME_APPLICATION",
  "requiredActions": ["UPLOAD_QUALIFICATION_CERTIFICATE"]
}
```

Frontend must not infer readiness from local routes or cached form completion.

## Patient Health Data Boundary

Patient onboarding should not ask for diseases/conditions as loose text.

MVP patient onboarding:

- full name
- date of birth when needed
- Nigeria location controls when needed
- controlled health-interest chips if product wants personalization

Deferred to a dedicated health-intake contract:

- diseases/conditions
- allergies
- medications
- emergency contacts
- dependents/minors
- medical documents
- consultation pre-screening

Reason: those are sensitive health records and need consent, retention,
privacy, and clinical-use rules.

## Backend Implementation Requirements

APP-ID-003 should implement only the accepted contract pieces:

- catalog source for Nigeria countries/states and supported professions
- server validation for controlled catalog codes
- regulated profession to regulator mapping
- backend-owned document/evidence type enum or catalog
- required evidence checklist by profession
- registration/licence normalization
- duplicate regulator-registration guard or manual-review state
- professional application status/readiness projection
- patient readiness projection for booking gate
- safe error codes for unsupported country/profession, duplicate registration,
  missing evidence, invalid state, and pending/rejected/expired status
- service/controller/unit/e2e tests for the above

## Explicitly Out Of Scope

- automatic regulator API verification
- exact licence-number format validation without official proof
- non-Nigeria professional onboarding
- dual-role self-service
- organization/clinic staff accounts
- dependent/minor profiles
- payments, calls, reviews, notes, prescriptions, calendar sync
- production legal-policy approval
- frontend visual rebuild

## Stop Conditions

Stop and ask for product/backend review if a future implementation tries to:

- keep profession, regulator, country, or document type as arbitrary production
  free text
- let unsupported professions become public listings
- claim automatic licence verification
- allow duplicate regulator-registration identity without review
- route pending/rejected/expired/suspended professionals into live booking
- collect patient diseases/conditions inside casual onboarding
- implement Flutter-only catalogs without backend validation

## Decision Summary

For Nigeria MVP, country selection must drive profession, regulator, evidence,
readiness, and verification rules. The backend must own those catalogs and
state transitions before Flutter rebuilds the onboarding UI. The next runtime
work should happen as backend schema/API alignment, then Flutter catalog and
readiness repository support, then patient/professional UI rebuild.
