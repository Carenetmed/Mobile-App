# Post-Completion Scheduling Lane Decision

Task: 52.52

Date: 2026-07-15

## Decision

Pause appointment lifecycle feature expansion and run a broader scheduling
regression checkpoint next.

The next slice should be:

`52.53 - Run Scheduling Core Regression Checkpoint`

## Why

The current scheduling core now covers the main backend-backed appointment and
availability path:

- public verified professional listing
- public professional availability read
- generated appointment request options
- backend appointment request from Search
- own appointment list read
- patient cancellation
- professional own availability management
- professional accept/decline
- professional completion

This is now enough behavior that adding another lifecycle feature before a
broader regression pass would increase the chance of hidden drift. The safer
move is to prove the current core across Search, Appointments, selectedDates,
and repository boundaries before adding reschedule.

## Why not reschedule now

Reschedule is not just another button. It needs a dedicated UX/product decision
before runtime wiring because it must answer:

- who can reschedule: patient, professional, or both
- which statuses can be rescheduled
- whether reschedule is allowed after scheduled start or near scheduled start
- how the user chooses a new time and duration
- whether public/professional availability must be rechecked before submit
- how accepted appointment conflicts are presented
- whether reschedule returns to `REQUESTED`, stays `ACCEPTED`, or has another
  status
- whether audit, notifications, payment/refund, calendar, and reminder behavior
  are involved

Those rules should not be invented inside a runtime implementation slice.

## Current Core To Prove

The regression checkpoint should cover:

- Search public professional listing without seeded fallback on backend failure
- Search public availability loading, empty, error, and returned-window states
- generated appointment request options from availability
- appointment request success showing backend `REQUESTED`
- appointment request safe failure without raw backend text
- own appointment list loading, empty, error, upcoming/recent grouping
- patient cancellation for eligible requested/accepted appointments
- terminal/recent appointment actions hidden
- professional accept/decline role and state gates
- professional completion role, state, timing, and terminal gates
- selectedDates own availability read/replace behavior
- no reschedule, payment, notification, calendar, review, notes, prescription,
  call, or admin override UI appearing accidentally

## Deferred Until Separate Decision

- Professional reschedule
- Patient reschedule
- Patient completion
- No-show/dispute states
- Admin override
- Payments, refunds, and payouts
- Notifications and reminders
- Reviews
- Calls
- Calendar sync
- Notes, prescriptions, and medical records

## Next Slice

`52.53 - Run Scheduling Core Regression Checkpoint`

Scope should be regression-only: strengthen/organize focused tests and docs
around the existing scheduling core. Do not add runtime reschedule, payment,
notification, calendar, review, notes, prescription, call, or admin behavior in
that slice.
