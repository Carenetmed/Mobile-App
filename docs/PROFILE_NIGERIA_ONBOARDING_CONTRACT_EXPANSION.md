# Profile Nigeria Onboarding Contract Expansion

**Slice:** APP-59
**Date:** 2026-07-17
**Status:** Implemented contract boundary; runtime onboarding screens not changed.

## Purpose

Expand the Flutter profile contract so future onboarding screens can save the
real backend-owned `CAR-BE-119` patient and professional fields.

This slice deliberately updates the data/domain/repository boundary before
building the new UI. That keeps the next screen work from becoming a polished
form that cannot persist the important data.

## Patient Profile Fields Now Supported

`PatientProfile`, `PatientProfileModel`, `ProfileApiClient.updatePatientMe`,
and `ProfileRepository.updatePatientMe` now support:

- `name`
- `age`
- `location`
- `dateOfBirth`
- `city`
- `state`
- `country`
- `healthInterests`

Existing Settings/Profile callers can keep using the older scoped
`name`/`age`/`location` path. New onboarding UI can pass the expanded fields.

## Professional Profile Fields Now Supported

`ProfessionalProfile`, `ProfessionalProfileModel`,
`ProfileApiClient.updateProfessionalMe`, and
`ProfileRepository.updateProfessionalMe` now support:

- `legalName`
- `displayName`
- `category`
- `specialty`
- `bio`
- `verificationStatus` read-only from backend responses
- `licenseNumber`
- `licensingCouncil`
- `qualifications`
- `yearsOfExperience`
- `practiceName`
- `practiceAddress`
- `practiceCity`
- `practiceState`
- `practiceCountry`

The client still does not send `verificationStatus`, document status, admin
decision fields, public listing state, ratings, payments, calls, reviews,
medical notes, prescriptions, or any trusted ownership identifiers.

## Public Listing Boundary

Public professional list parsing remains unchanged and still reads only the
safe public projection:

- `id`
- `displayName`
- `category`
- `specialty`
- `bio`
- `verified`

Private professional onboarding fields must not be surfaced through the public
listing unless a later public-detail contract explicitly accepts that.

## Verification

Passed:

- `dart format` on changed profile contract files and focused test
- `flutter test test/features/home/profile_repository_test.dart`
- `flutter analyze` on changed profile contract files and focused test

## Next Slice

Recommended next slice:

`APP-60 - Build Patient And Professional Onboarding Setup UI`

That slice should replace the weak existing post-registration professional
surface with a polished multi-step patient/professional setup flow using this
expanded contract.

## Explicitly Deferred

- Runtime onboarding UI changes
- Google first-time sign-up
- phone/OTP completion
- council option catalogs and authoritative regulator validation
- automatic license verification
- admin verification dashboard inside the mobile app
- professional approval/rejection reasons
- payments, payouts, subscriptions, reviews, calls, prescriptions, medical
  notes, calendar sync, and public professional detail expansion
