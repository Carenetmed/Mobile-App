# Next Backend-Completed Flutter Surface Decision

Task: 52.61

Status: Accepted decision

## Context

Task `52.60` kept full scheduling staging smoke blocked on deliberate
backend/staging test data setup. The Flutter repo should not create disposable
staging users or appointments just to make scheduling appear proven.

This decision reviews the remaining backend-completed Flutter surfaces and
chooses the next narrow lane that can move forward without fake data, dummy
success, or unsupported product assumptions.

## Current Surface Review

| Candidate | Current status | Decision |
| --- | --- | --- |
| Scheduling end-to-end smoke | Locally regression-proven but staging smoke needs deliberate patient/professional/verified-professional/availability/appointment data | Keep blocked until backend/staging data setup exists |
| Verification upload/list | Backend routes exist, but staging readiness still reports `verificationStorage: disabled`; upload UX/file-picker rules are not mapped | Defer |
| Admin verification dashboard | Backend admin routes exist, but the mobile app has no admin dashboard lane and admin review should not be invented in this app milestone | Defer |
| Phone/OTP and MFA | Backend/docs explicitly defer these provider/security models | Defer |
| Public professional detail | Search list is wired, but no documented `GET /professionals/:id` detail route exists | Defer |
| More scheduling feature work | Feature expansion is frozen until staging-data blocker is handled | Defer |
| Patient self profile | Repository/API boundary exists for `GET/PUT /patients/me`; current settings/profile UI is still local/draft | Choose as next surface, with a mapping decision first |

## Decision

Choose patient self profile as the next backend-completed Flutter surface, but
do not wire runtime behavior until the existing Settings/Profile UI is mapped
to the backend patient profile contract.

The next slice should define the patient profile settings mapping:

- which existing fields can safely read from `ProfileRepository.patientMe`
- whether backend `name` maps to first/last name, one display field, or a
  constrained read-only summary
- whether `age` and `location` need new UI fields or stay out of scope
- why username, email, account role/status, security settings, phone, MFA,
  delete/deactivate, bio, and public profile data must stay separate
- whether the first runtime slice should be read-only or read plus constrained
  update

## Reasoning

Patient self profile is the best next lane because:

- its backend routes are already represented in the Flutter repository boundary
- it does not depend on public professional seed data
- it does not depend on verification storage
- it belongs to the existing account/settings surface instead of a new product
  area
- it continues the backend-completed surface plan after profile/public
  professional and scheduling work

It still needs a mapping slice because the current Settings/Profile screen was
built before backend profile persistence. It contains local fields that do not
all belong to `PUT /patients/me`. Wiring them directly would mix account
identity, auth/security, public profile, and private patient profile concerns.

## Next Slice

Queue `52.62 - Define Patient Profile Settings Mapping`.

This should be a decision/contract slice only. It should not implement runtime
behavior.

## Explicitly Out Of Scope

- runtime patient profile wiring
- profile creation/update calls
- username persistence
- email mutation
- phone/OTP
- MFA/PIN/security changes
- destructive account actions
- professional profile mutation
- verification upload/list
- admin verification dashboard
- scheduling staging data creation
- payments, notifications, reviews, calls, calendar sync, notes, prescriptions,
  medical records, or public profile detail

## Non-Claims

This decision does not claim:

- the patient settings/profile screen is backend-wired
- patient profile update UX is ready
- scheduling smoke is complete
- verification uploads are ready
- the app is production-ready or Play Store-ready
