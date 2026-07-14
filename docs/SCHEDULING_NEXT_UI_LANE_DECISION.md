# Scheduling next UI lane decision

**Task:** 52.40
**Status:** Accepted decision before more scheduling runtime wiring

Purpose: choose the next scheduling UI lane after backend-backed public
availability, appointment request, and own appointment list visibility are
wired.

This is a decision slice. It does not implement runtime behavior.

---

## Current backend-backed frontend state

Completed:

- Search reads public verified professionals from the backend.
- Search public profile sheet reads backend public availability.
- Search public profile sheet generates requestable time options.
- Search calls `SchedulingRepository.requestAppointment` after user selection.
- Search displays backend `REQUESTED` success and safe request errors.
- `appointments` reads `SchedulingRepository.ownAppointments`.
- `appointments` shows backend statuses with safe loading, empty, and error
  states.

Still deferred:

- patient cancellation UI
- professional availability management UI
- professional accept/decline UI
- reschedule UI
- completion UI
- payments, notifications, reviews, calls, calendar sync, notes, prescriptions

---

## Options considered

### Option A - Patient cancellation

Wire a constrained cancel action for eligible own appointments from the
Appointments screen.

Pros:

- Smallest useful follow-up after request/list visibility.
- Uses an already existing repository method.
- Helps users reverse an accidental request.
- Can stay narrow: only active own appointment cards, safe errors, no
  cancellation policy, refund, notification, or calendar assumptions.

Risks:

- UI must avoid showing cancel for terminal states.
- Backend remains authority for ownership and valid status transitions.

### Option B - Professional availability management

Wire professional own availability read/replace from `selectedDates` or Manage
Profile business hours.

Pros:

- Important for professionals to control availability.
- Uses existing backend availability routes.

Risks:

- Requires careful form UX for weekly windows, inactive windows, timezone
  display, validation, and replacing the entire set.
- Higher chance of product mistakes if implemented before a dedicated design
  pass.

### Option C - Professional accept/decline lifecycle

Add professional appointment actions for requested appointments.

Pros:

- Completes a direct professional response path.

Risks:

- Current app does not yet have a role-specific professional appointment
  workspace.
- Needs clear professional context, empty/error states, and role expectations.

### Option D - Regression checkpoint

Pause feature wiring and run a scheduling integration regression/checkpoint.

Pros:

- Good after a few more mutations.

Risks:

- Request/list path is still missing the basic patient-side cancellation action,
  so regression now would leave an obvious usability gap.

---

## Decision

Choose **Option A: Patient cancellation** as the next runtime slice.

Next slice:

`52.41 - Wire Patient Appointment Cancellation`

Scope:

- Add a cancel action only for eligible backend appointment cards in
  `appointments`.
- Use `SchedulingRepository.cancelAppointment`.
- Show loading/safe success/safe error states.
- On success, update the visible card from backend response.
- Do not trust client status as authority; use it only to decide whether to
  show the button.
- Do not show cancel for `CANCELLED`, `DECLINED`, or `COMPLETED`.
- Keep professional accept/decline/reschedule/complete UI deferred.

Out of scope:

- refunds, payments, payouts
- cancellation policy text
- notifications/reminders
- calendar sync
- reviews
- calls
- notes, prescriptions, medical records
- admin override
- professional lifecycle UI
- professional availability management UI
- broad appointment redesign

---

## Why not professional availability next?

Professional availability is important, but it edits weekly scheduling
authority and currently needs a more deliberate form boundary. Patient
cancellation is smaller, uses the current Appointments screen, and closes a
clear gap after request/list visibility.

---

## Stop conditions for 52.41

Stop and ask before implementation if:

- the UI needs payment/refund/cancellation-policy behavior
- cancellation must notify a provider or calendar
- backend response shape differs from `AppointmentSummary`
- the screen needs role-specific patient/professional routing beyond the
  current own appointment list
- the implementation requires broad appointment state redesign
