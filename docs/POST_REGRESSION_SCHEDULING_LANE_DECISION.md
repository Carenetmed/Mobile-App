# Post-Regression Scheduling Lane Decision

Task: 52.54

Date: 2026-07-15

## Decision

Choose a dedicated reschedule UX/product boundary as the next scheduling slice.

The next slice should be:

`52.55 - Decide Appointment Reschedule UX Boundary`

This is not approval to implement runtime reschedule yet. The next slice should
define the rules and UI boundary first.

## Why

The scheduling core regression checkpoint now proves the current backend-backed
path across Search, Appointments, selectedDates, and the scheduling repository.
The remaining backend-completed appointment lifecycle route already represented
in the Flutter repository boundary is reschedule, but it is too risky to wire as
just another button.

Reschedule affects appointment state, availability, conflicts, user
expectations, and likely future notifications/calendar/payment behavior. Those
rules must be decided before implementation.

## Why not move to another backend surface yet

Other backend-completed surfaces remain important, especially verification
upload/list and public professional detail. However, the app is currently in the
scheduling lane and has just completed regression for that lane. Closing the
reschedule decision boundary now gives the next agent a clear either/or:

- implement a narrow reschedule path if the rules are safe, or
- explicitly defer reschedule and move to another backend-completed surface.

That is better than leaving the scheduling lane half-decided.

## Why not staging smoke next

A real-device/staging smoke checkpoint would be useful, but it needs known test
accounts, backend data, and endpoint accessibility. This repo currently has
strong focused Flutter regression coverage for scheduling. The next higher-value
local step is to decide whether reschedule belongs in this frontend milestone at
all.

## Required Questions For 52.55

- Who can reschedule: patient, professional, or both?
- Which statuses are eligible: `REQUESTED`, `ACCEPTED`, or only one of them?
- Is reschedule allowed after the scheduled start time?
- Is reschedule allowed close to the scheduled start time?
- Should the new time be selected from public availability, professional own
  availability, or a separate appointment-specific availability source?
- Should duration be editable or preserved from the existing appointment?
- What happens to status after reschedule: stays `ACCEPTED`, returns to
  `REQUESTED`, or follows backend response only?
- How should conflicts and unavailable slots be shown safely?
- Should existing appointment cards refresh from backend response only?
- Which future behaviors remain explicitly deferred: notifications, reminders,
  calendar sync, payments/refunds, reviews, calls, admin override, no-show,
  notes, prescriptions, and medical records?

## Stop Conditions For Runtime Reschedule

Do not implement runtime reschedule if the next slice cannot define:

- actor/role rules
- eligible statuses
- time and duration selection source
- backend payload fields
- safe success and failure copy
- deferred notification/payment/calendar/review/notes/call/admin boundaries

## Next

Task 52.55 should decide the appointment reschedule UX boundary. It should not
add runtime UI or call `SchedulingRepository.rescheduleAppointment` yet.
