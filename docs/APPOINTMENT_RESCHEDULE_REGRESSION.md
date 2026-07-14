# Appointment Reschedule Regression

Task: 52.57

Date: 2026-07-15

## Scope

This regression pass verifies the constrained reschedule path added in task
52.56 without adding new runtime features.

Covered behavior:

- patient-owned reschedule entry from an upcoming accepted appointment
- professional-owned reschedule entry from an upcoming requested appointment
- public availability lookup for the appointment professional
- generated request-option selection
- narrow backend payload: `requestedStartAt` and `durationMinutes`
- backend response authority, including visible return to `REQUESTED`
- safe availability and reschedule failure messages
- empty generated-option handling
- non-patient/non-professional role hiding
- recent appointment hiding
- terminal status hiding
- continued absence of broader deferred controls

## Regression Proof

Focused tests in `test/features/home/appointments_flow_test.dart` prove:

- patient sessions can reschedule upcoming `ACCEPTED` appointments through
  backend public availability options
- professional sessions can reschedule upcoming `REQUESTED` appointments through
  the same bounded option flow
- the UI loads public availability with the appointment's
  `professionalProfileId`
- reschedule submits the selected generated start time and duration only
- successful reschedule replaces the visible card with backend `REQUESTED`
  status
- non-patient/non-professional sessions do not expose `Reschedule`
- recent active appointments do not expose `Reschedule`
- `CANCELLED`, `DECLINED`, and `COMPLETED` appointments do not expose
  `Reschedule`
- empty generated availability shows an honest no-option message and does not
  call `rescheduleAppointment`
- availability and reschedule failures show safe copy without raw backend
  messages
- payment, notification, calendar, review, notes, prescription, call, and admin
  controls remain absent from appointment lifecycle cards

Focused repository and helper tests still prove:

- `AppointmentRequestTimeOptions` generates bounded near-term options from
  backend availability windows
- protected scheduling repository calls require bearer auth
- repository reschedule payload stays narrow and does not send trusted
  client-side status or owner fields

## Decision

The constrained appointment reschedule path is covered enough to pause
reschedule-specific implementation and move to a scheduling pause/checkpoint
decision next.

## Remaining Deferred Work

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
- real-device/staging end-to-end scheduling smoke

## Next

Task 52.58 should decide whether the scheduling/appointment core can pause for a
broader checkpoint, needs a real-device/staging smoke, or needs a small QA/fix
slice from regression findings. It should not add new product features.
