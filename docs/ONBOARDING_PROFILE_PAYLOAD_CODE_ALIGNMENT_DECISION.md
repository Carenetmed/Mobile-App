# Onboarding Profile Payload Code Alignment Decision

**Slice:** APP-ID-006
**Date:** 2026-07-19
**Status:** Accepted decision; no runtime behavior changed.

## Context

APP-ID-003 added backend-owned onboarding catalogs and readiness. APP-ID-004
added the Flutter repository/API boundary. APP-ID-005 wired patient and
professional setup screens to those catalogs and readiness instead of allowing
free-text country, state, profession, regulator, or patient health-interest
choices.

The remaining question is whether Flutter should immediately change profile
save payloads to send native code fields such as `countryCode`,
`professionCode`, and `regulatorCode`.

## Facts Checked

Backend `PUT /patients/me` currently accepts these profile fields:

- `name`
- `age`
- `dateOfBirth`
- `location`
- `city`
- `state`
- `country`
- `healthInterests`

Backend `PUT /professionals/me` currently accepts these profile fields:

- `legalName`
- `displayName`
- `category`
- `specialty`
- `bio`
- `licenseNumber`
- `licensingCouncil`
- `qualifications`
- `yearsOfExperience`
- `practiceName`
- `practiceAddress`
- `practiceCity`
- `practiceState`
- `practiceCountry`

Backend persistence/readiness now includes normalized professional identity
fields:

- `licenseNumberNormalized`
- `countryCode`
- `professionCode`
- `regulatorCode`
- `applicationStatus`

Backend service code maps supported catalog selections into those normalized
fields and rejects unsupported country, profession, regulator, health-interest,
and duplicate regulator registration cases.

## Decision

Keep Flutter profile update methods on the currently accepted backend DTO field
names for now. Do not invent `countryCode`, `professionCode`, or
`regulatorCode` request fields from Flutter until the backend API DTO/docs
explicitly accept those fields.

For the next implementation slice, align Flutter to the backend-accepted catalog
values instead:

- patient setup should send catalog-backed `country`, `state`, and
  `healthInterests` values in the shape the current backend accepts
- professional setup should send catalog-backed `category`,
  `licensingCouncil`, `practiceCountry`, and `practiceState` values in the
  shape the current backend accepts
- Flutter should not allow arbitrary free-text values for those fields in
  onboarding setup
- Flutter should continue to treat verification/application status as
  backend-owned and read-only

## Why

Changing Flutter to send fields not accepted by the current backend DTO would
create avoidable validation failures and confuse the product lane.

The backend already owns catalog validation and normalized code persistence.
The safe frontend responsibility is to send values selected from backend
catalogs through the currently documented profile-update contract, then add
native code request fields only after the backend API contract changes.

## Next Slice

`APP-ID-007 - Align Onboarding Setup Payload Values To Backend Catalog Contract`

Scope for APP-ID-007:

- ensure patient setup sends backend-accepted catalog values, not arbitrary
  typed values
- ensure professional setup sends backend-accepted catalog values for category,
  licensing council, country, and state
- add focused repository/UI tests proving catalog-selected values are the only
  values sent from onboarding setup
- do not add new backend request fields unless backend docs/DTO already accept
  them
- do not change verification, admin review, payments, reviews, calls, notes,
  prescriptions, phone/OTP, or public listing behavior

## Explicitly Deferred

- backend DTO change to accept explicit `countryCode`, `professionCode`, or
  `regulatorCode`
- Flutter model/entity expansion for native code response fields
- public display of normalized professional identity fields
- live Nigerian regulator lookup
- license expiry and good-standing checks
- required-evidence guidance inside upload UI
- professional rejection reason UX
- admin review UI
- phone/OTP, payments, reviews, calls, notes, prescriptions, and calendar sync

## Verification

No runtime code changed in this slice.

Passed:

- backend contract/source inspection for current profile DTOs and service
  normalization behavior
- `git diff --check`
