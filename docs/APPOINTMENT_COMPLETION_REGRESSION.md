# Appointment Completion Regression

Task: 52.51

Date: 2026-07-14

## Scope

This checkpoint verifies the professional appointment completion frontend wiring
added in task 52.50. It does not add new lifecycle behavior.

## Verified behavior

- Professional users can complete an `ACCEPTED` appointment only when the
  scheduled end time has passed or is exactly equal to the current time.
- Patient users do not see completion actions.
- `REQUESTED`, `CANCELLED`, `DECLINED`, and `COMPLETED` appointments do not
  expose completion.
- Completion success updates visible status only from the backend response.
- Completion failure shows safe frontend copy and does not expose raw backend
  messages.
- Completion-eligible cards do not expose reschedule, payment, calendar,
  review, notes, or prescription controls.

## Decision

The current appointment lifecycle UI should pause feature expansion after
request/list/cancel, professional accept/decline, availability management, and
professional completion. Reschedule should not be implemented until a separate
UX/product decision defines time selection, availability re-checks, owner rules,
and conflict behavior.

## Still Deferred

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

## Next

Task 52.52 should decide whether the scheduling lane pauses for a broader
frontend/backend regression checkpoint or starts a dedicated reschedule UX
decision. Do not add reschedule runtime behavior without that decision.
