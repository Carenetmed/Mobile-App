# Professional Evidence Status Experience

**Slice:** APP-71
**Date:** 2026-07-18
**Status:** Implemented runtime UI.

## What Changed

`professionalVerificationDocuments` now frames verification evidence as a
status experience, not only a file list.

The screen now:

- explains that public professional listing waits for backend approval
- summarizes evidence status from returned backend document statuses
- shows an evidence checklist for licence, identity, and certification
- counts submitted evidence types without inventing approval
- keeps upload/list behavior on the existing `VerificationRepository`
- keeps signed URLs, object keys, raw private storage data, reviewer notes, and
  admin controls out of the mobile UI

## Product Boundary

This slice does not add admin review, document preview/download, signed-read,
rejection reasons, regulator validation, licence expiry/renewal, duplicate
licence checks, public listing activation, payments, calls, notes,
prescriptions, or medical-record behavior.

An `APPROVED` document status may be displayed as returned by the backend, but
the app still does not claim the full professional profile is verified unless a
future backend readiness/profile-verification state says so.

## Verification

Passed:

- `flutter test test\features\home\manage_profile_flow_test.dart`

Full-suite verification is recorded in the APP-71 PR before merge.

## Follow-Up

Next slice:

`APP-72 - Auth/onboarding regression and device smoke`

APP-72 should prove the redesigned auth/onboarding journey end-to-end before
more product expansion.
