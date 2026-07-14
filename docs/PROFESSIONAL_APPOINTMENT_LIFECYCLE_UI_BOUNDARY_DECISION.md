# Professional appointment lifecycle UI boundary decision

**Task:** 52.46
**Status:** Accepted boundary before professional lifecycle controls

Purpose: decide the first safe professional appointment lifecycle UI after
patient request/list/cancel and professional availability management are wired.

This is a decision slice. It does not implement runtime behavior.

---

## Evidence reviewed

- `AppointmentsShellPage` reads `SchedulingRepository.ownAppointments()` and
  renders backend-owned appointment statuses.
- The screen currently exposes patient-style cancellation for eligible upcoming
  `REQUESTED`/`ACCEPTED` cards.
- `SchedulingRepository` already exposes `acceptAppointment`,
  `declineAppointment`, `cancelAppointment`, `rescheduleAppointment`, and
  `completeAppointment`.
- `SessionStore` persists the signed-in user's role, so the UI can gate
  professional controls from authenticated session state instead of guessing
  from appointment IDs.
- `SCHEDULING_AVAILABILITY_APPOINTMENT_CONTRACT.md` says professional lifecycle
  actions require `PROFESSIONAL` auth and send no trusted status body.
- `selectedDates` now has backend-backed professional availability management,
  so professional lifecycle work has a better base than before.

---

## Decision

Do not add every lifecycle control at once.

Next runtime slice:

`52.47 - Wire Professional Appointment Accept Decline`

The first professional lifecycle UI should be role-aware and limited to
`REQUESTED` appointments:

- signed-in `PROFESSIONAL` users may see `Accept` and `Decline`
- signed-in `PATIENT` users must not see professional lifecycle actions
- `Accept` calls `SchedulingRepository.acceptAppointment`
- `Decline` calls `SchedulingRepository.declineAppointment`
- success replaces the visible card status from the backend response
- failure shows safe user-facing text without raw backend messages

---

## Required role boundary

The next slice should read the authenticated session role from `SessionStore`
or an equivalent existing auth repository boundary. It must not infer role from:

- appointment id
- professional profile id
- patient profile id
- current screen route
- local test-only state

The backend remains the authority for ownership and valid transitions. The UI
role gate is only a visibility and ergonomics guard.

---

## Deferred lifecycle controls

Keep these out of the first professional lifecycle runtime slice:

- professional reschedule UI
- professional complete UI
- patient reschedule
- patient completion
- no-show/dispute states
- admin override
- payments, refunds, payouts
- notifications/reminders
- calls/video/audio
- calendar sync
- reviews
- notes, prescriptions, medical records

Completion should remain separate because the backend rule depends on
`ACCEPTED` status and scheduled end time. Reschedule should remain separate
because it changes requested time/duration and can affect availability/conflict
UX.

---

## Next lane after accept/decline

After accept/decline, run a focused regression or decision slice before adding
reschedule/complete. Do not bundle all appointment lifecycle actions into a
single UI pass.
