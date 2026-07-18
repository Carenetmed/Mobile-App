# Identity, Role, Onboarding, And Verification Foundation

**Slice:** APP-ID-001
**Date:** 2026-07-18
**Status:** Accepted foundation proposal; runtime behavior not changed.
**Source:** `C:\Users\asd\Downloads\Carenet_PRD_v1.0.pdf`, current Flutter docs/code, and staging backend contract docs referenced by this repo.

## Purpose

CareNet cannot treat auth, patient setup, professional application, location,
and verification as independent form screens. They are one product boundary:

```text
real person identity
-> CareNet account
-> role profile
-> onboarding readiness
-> professional verification where applicable
-> public/booking access only after backend proof
```

This document freezes the decision model before more frontend or backend
feature expansion. It exists so future slices do not guess at duplicate
accounts, role switching, free-text professions, unverified licence claims,
half-completed professional applications, or patient medical-intake boundaries.

## PRD Constraints

The PRD defines CareNet as a dual-sided healthcare marketplace with:

- licensed medical professionals
- regular users/patients
- guest browse before booking
- optional patient profile setup
- professional multi-step registration
- medical licence and council-registration evidence upload
- manual admin verification before public listing
- valid/current professional registration with the appropriate Nigerian
  regulatory body
- public trust through verified badges and reviews
- privacy, data-protection, and legal/compliance review before launch

Therefore, the MVP cannot rely on loose free-text onboarding as the final
production design.

## Current Implementation Reality

Already good:

- role is selected before email/password and Google first-time signup
- Google uses a real ID token and does not provide trusted profile identity
- patient setup saves backend-owned patient profile fields
- professional setup saves backend-owned legal, credential, and practice fields
- professional evidence upload uses real backend verification-document routes
- public professionals come from backend verified listing surfaces
- appointment/availability flows avoid fake local fallback in backend paths

Not production-grade yet:

- profession/category is free text
- licensing council is free text
- city/state/country are free text
- specialty and qualifications are free text
- patient health interests are free text
- licence number validation is generic
- duplicate regulator identity is not a visible product rule in the app
- professional application draft/resume is not server-owned
- role/profile readiness is still incomplete and partly route-inferred
- support/recovery paths for rejected, duplicate, expired, wrong-role, and
  half-completed accounts are not finished

## Core Identity Decision

CareNet should use one authenticated **User Account** as the login identity.

The user account owns exactly one MVP role through normal self-service:

```text
PATIENT
or
PROFESSIONAL
```

Admin/reviewer accounts stay outside the mobile patient/professional app.

### Why Not Free Dual-Role Switching Now

A real person can be both a patient and a professional, but casual role
switching creates risky ambiguity:

- patient health data can mix with professional application state
- professional verification can be treated like normal profile editing
- support and audit rules become unclear
- duplicate account collisions become harder to explain
- a pending professional could appear to have operational access

MVP rule:

- role is selected at account creation
- role is immutable through normal mobile self-service
- wrong-role correction requires a support/admin path or an explicitly approved
  fresh-account path
- dual-role linked identities are deferred until a dedicated backend model and
  privacy/audit decision exists

## Account Collision Rules

The app must not create duplicate identities silently.

| Collision | MVP behavior |
|-----------|--------------|
| Email already registered | Show sign-in/password recovery direction; do not reveal sensitive account details |
| Phone already registered after OTP exists | Show sign-in/recovery direction; do not auto-link |
| Google email matches existing email/password account | Require sign-in with existing method, then link Google from Account when supported |
| Google subject already linked | Sign in to the linked backend account |
| Same Google account tries different role | Backend rejects or routes to existing account; app does not create a second role |
| Patient wants to become professional | Dedicated "apply as professional" decision later; not casual switch in MVP |
| Professional wants normal patient use | Use public browse; full patient profile under the same login is deferred |
| Same regulator and registration number already exists | Block or manual review; never silently create a second public professional |

The frontend never decides these from local state. Backend must own the final
uniqueness and collision result.

## Role Profile Model

### Patient Profile

Patient setup stays lightweight until a care action requires more.

Controlled fields needed for production:

| Field | Rule |
|-------|------|
| Full name | Required before booking; not trusted from Google display name |
| Date of birth | Required before first consultation unless legal/product changes this |
| Country | Controlled select; Nigeria-first for MVP |
| State | Controlled select when country is Nigeria |
| City/LGA | Controlled or catalog-backed where supported; otherwise limited manual review field |
| Health interests | Controlled chips plus optional notes later; not raw medical diagnosis authority |
| Conditions/diseases | Do not ask as casual free text in onboarding; move to a consented health-intake slice |
| Consultation consent | Separate legal/consent record before relevant booking/consultation |

Patient onboarding must not create a fake medical record. Health conditions,
medications, allergies, emergency contacts, dependents/minors, and consultation
history need their own privacy and consent contracts.

### Professional Profile

Professional setup is an application, not just profile editing.

Controlled fields needed for production:

| Field | Rule |
|-------|------|
| Legal name | Required, private/admin-reviewed |
| Public display name | Required, public after verification, not copied from Google as trusted data |
| Profession | Controlled catalog; no free text for launch |
| Regulator/council | Derived or constrained by profession/country |
| Registration/licence number | Required; normalized; duplicate-sensitive |
| Licence expiry/renewal date | Required when regulator/document type has expiry |
| Specialty | Controlled catalog or profession-scoped approved list |
| Qualifications | Structured entries later; first pass may use controlled common qualifications plus manual review notes |
| Years of experience | Numeric range; cannot be negative or implausible |
| Practice/facility | Required for application review |
| Practice country/state/city | Controlled Nigeria-first selects |
| Practice address | Optional for MVP; private/public behavior must be explicit |

The user must not self-set verification status, public listing status, ratings,
pricing trust, document approval, admin notes, or booking eligibility.

## Nigeria-First Catalog Boundary

MVP should ship with a deliberately small, controlled Nigeria catalog.

Minimum supported professional catalog:

| Profession | Regulator direction | Status |
|------------|---------------------|--------|
| Medical doctor | MDCN | Supported after backend/catalog implementation |
| Dentist | MDCN | Supported after backend/catalog implementation |
| Nurse | NMCN | Supported after backend/catalog implementation |
| Midwife | NMCN | Supported after backend/catalog implementation |
| Pharmacist | PCN | Supported after backend/catalog implementation |
| Medical laboratory scientist | MLSCN | Supported after backend/catalog implementation |
| Radiographer | RRBN | Supported after backend/catalog implementation |

Other PRD categories such as dietitians, mental-health practitioners, therapists,
nutrition, or broader wellness professionals must not be guessed into a
regulator. They should be unavailable, waitlisted, or routed into manual-review
only after product/compliance approves their regulator and document rules.

Location catalog:

- country select defaults to Nigeria
- Nigeria state select should be controlled
- city/LGA should use a controlled list where practical, with an "Other" path
  only if backend marks the application for manual review
- do not accept arbitrary country/state text as production-clean data

## Verification Evidence Rules

Current backend document types are:

```text
IDENTITY
LICENSE
CERTIFICATION
```

Production application readiness should require evidence based on profession:

| Evidence | MVP rule |
|----------|----------|
| Government identity | Required for all professionals |
| Licence or registration evidence | Required for all supported regulated professions |
| Qualification/certification evidence | Required where claimed qualification affects professional listing |
| Practice/facility evidence | Deferred unless compliance/product requires it |

Uploading evidence does not submit, approve, verify, or list the professional
unless the backend state machine says so.

## Professional Application State Machine

Recommended backend-owned states:

```text
NOT_STARTED
-> DRAFT
-> READY_TO_SUBMIT
-> SUBMITTED
-> PENDING_REVIEW
-> VERIFIED

PENDING_REVIEW -> REJECTED
VERIFIED -> EXPIRED
VERIFIED -> SUSPENDED
EXPIRED -> PENDING_REVIEW
REJECTED -> DRAFT or SUPPORT_REQUIRED
```

Terminal or restricted states:

- suspended users cannot self-restore
- expired verification cannot remain publicly bookable without a policy
- rejected application resubmission requires product-approved correction rules
- duplicate regulator identity requires admin/support handling

Frontend must display the current state and allowed next action. It must not
infer readiness from the last route completed.

## Readiness Resolver Requirement

Every auth completion and session restore should resolve a backend-owned
readiness snapshot before entering the app:

```text
accountStatus
role
emailVerified
patientProfileStatus
professionalApplicationStatus
verificationStatus
requiredActions
nextAction
returnIntent
```

Until this backend contract exists, frontend routing may stay conservative but
must not claim production-grade onboarding completion.

## Abuse And Data-Quality Controls

The next implementation cannot rely only on field validators. It needs product
catalogs and backend enforcement.

Required controls:

- controlled profession/regulator/state/country values
- server-side validation for every controlled value
- normalized licence/registration numbers
- duplicate regulator-number review/blocking
- max lengths and allowed characters for names, display names, licence numbers,
  qualifications, facility names, and addresses
- safe error copy for duplicate, rejected, expired, pending, unsupported, and
  blocked states
- audit records for application submission, document upload, review decision,
  verification expiry/suspension, and sensitive profile changes
- no public exposure of private legal/licence/document fields

## Implementation Sequence

Do not try to perfect this in one oversized PR.

### APP-ID-002 - Backend Identity And Catalog Contract

Decide backend API/schema requirements for:

- role immutability
- account collision behavior
- readiness snapshot
- controlled country/state/city/profession/regulator catalogs
- licence normalization and duplicate review
- professional application draft/submission states
- required evidence rules per profession
- patient booking-gate fields

No Flutter UI rewrite in this slice.

### APP-ID-003 - Backend Schema/API Alignment

Implement only the backend pieces accepted by APP-ID-002.

Expected work:

- catalog model or static catalog endpoint
- readiness endpoint
- professional application status fields
- stricter validation
- duplicate regulator identity guard
- tests for collision/state/catalog rules

### APP-ID-004 - Flutter Catalog And Readiness Repository

Add frontend repository/model support for:

- catalog fetch/read
- readiness snapshot
- safe error mapping
- no local fallback catalogs in backend-enabled flows unless marked dev-only

### APP-ID-005 - Patient Onboarding And Booking Gate Rebuild

Rebuild patient setup around controlled location and booking readiness:

- country/state/city controls
- full name/date-of-birth rules
- health interests as controlled chips or deferred
- return-to-booking intent
- no casual disease intake without consent contract

### APP-ID-006 - Professional Application Rebuild

Rebuild the professional application as a multi-step controlled flow:

- profession/regulator selects
- speciality/qualification controls
- licence normalization/validation
- practice location controls
- review-and-submit
- save/resume from backend state

### APP-ID-007 - Evidence Requirements And Status Hub

Connect required evidence checklist to selected profession/regulator:

- required document types
- missing evidence states
- uploaded/pending/rejected/approved states
- resubmission/support paths
- no fake approval

### APP-ID-008 - Identity/Onboarding Regression And Phone Smoke

Prove:

- email patient signup
- Google patient signup
- email professional signup
- Google professional signup
- duplicate account behavior
- half-completed resume behavior
- unsupported profession behavior
- controlled location validation
- verification evidence requirements
- app reinstall/session restore routing

## What Remains Deferred

- dual-role self-service
- patient/professional linked identity switching
- organization/clinic staff accounts
- dependent/minor profiles
- automatic regulator API verification
- production legal text approval
- final data-retention/deletion policy
- payments, refunds, payouts, reviews, calls, chat, notes, prescriptions,
  calendar sync, content moderation, and emergency escalation

## Decision Summary

The current auth/onboarding work is a useful bridge, but not the final
production model. CareNet should now stop broad feature expansion and harden
identity, onboarding readiness, controlled catalogs, professional verification,
and patient booking readiness in the APP-ID slice series before presenting this
area as production-complete.
