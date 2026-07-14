# Scheduling Core Pause Or Smoke Decision

Task: 52.58

Date: 2026-07-15

## Scope

This decision reviews the current scheduling and appointment core after the
request/list/cancel/accept/decline/complete/reschedule implementation and
regression slices.

This is a decision slice only. It does not add runtime behavior.

## Evidence Reviewed

- `SCHEDULING_AVAILABILITY_APPOINTMENT_CONTRACT.md`
- `SCHEDULING_CORE_REGRESSION_CHECKPOINT.md`
- `APPOINTMENT_RESCHEDULE_REGRESSION.md`
- `DEFERRED_WORK.md`
- `CODEBASE_STATUS.md`
- focused scheduling test history recorded in `AI_HANDOFF.md`

## Current Covered Core

The current Flutter/backend scheduling core has local automated proof for:

- public verified professional listing into Search
- public availability read for selected backend professionals
- generated appointment request options
- backend appointment request success and failure
- own appointment list read
- patient cancellation
- professional accept/decline
- professional completion after scheduled end
- patient/professional reschedule through generated public availability options
- professional own availability read/replace from selectedDates
- safe error handling and no seeded local fallback for wired backend surfaces
- absence of payment, notification, calendar, review, call, admin, notes, and
  prescription controls in scheduling lifecycle cards

## Remaining Risks

The main remaining risk is not another local feature gap. It is lack of
end-to-end staging proof on a configured app build.

Known deferred product areas remain out of scope:

- patient completion
- no-show/dispute states
- reminders and policy text
- payments/refunds/payouts
- notifications
- reviews
- calls
- calendar sync
- admin override
- notes
- prescriptions
- medical records
- free-text datetime entry
- reschedule reasons
- public professional detail replacement
- Find Mentor and Specialist Details backend scheduling replacement

## Decision

Pause scheduling feature expansion and run a real-device/staging smoke
checkpoint next.

Reason: The local regression evidence is now strong enough for the current
scoped scheduling core. Adding more lifecycle or product modules now would
increase surface area without proving that the existing core works against the
staging backend on an app build with real environment configuration.

The next slice should prove the existing core, not add a new scheduling feature.

## Next Slice

Task 52.59 should run a scheduling core staging smoke checkpoint.

Allowed scope:

- build or run the Flutter app with staging `CARENET_API_BASE_URL`
- verify backend readiness is reachable from the app environment
- smoke the narrow paths that can be proven with available staging accounts/data
- document exactly which paths were proven
- document exact blockers for paths that need staging users, profiles,
  professional verification, availability, or appointment seed data
- keep all unproven paths honest as not smoke-proven

Out of scope:

- no new runtime feature work
- no payments
- no notifications
- no reviews
- no calls
- no calendar sync
- no admin override
- no notes or prescriptions
- no patient completion
- no no-show/dispute states
- no fake seed data inside Flutter
- no claim that Play Store/release readiness is complete

## Stop Conditions For 52.59

Stop and ask if smoke requires credentials, staging account creation, verified
professional data, backend seed changes, public URLs, or device/emulator access
that is not available from the repo.
