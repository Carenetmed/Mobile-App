# Appointment reschedule or completion boundary decision

**Task:** 52.49
**Status:** Accepted decision before broader lifecycle UI

Purpose: decide whether the next appointment lifecycle lane should be
reschedule, completion, or another fix/regression pass.

This is a decision slice. It does not implement runtime behavior.

---

## Evidence reviewed

- Patient request/list/cancel is backend-backed and regression-covered.
- Professional availability management is backend-backed.
- Professional accept/decline is role-aware and regression-covered.
- `SchedulingRepository` already exposes `rescheduleAppointment` and
  `completeAppointment`.
- Backend contract allows owner reschedule with `requestedStartAt` and
  `durationMinutes`.
- Backend contract allows professional complete with no trusted request body
  for assigned professional `ACCEPTED` appointments after scheduled end time.
- Current Appointments UI separates upcoming and recent appointments. Accepted
  appointments in the past currently render in Recent without lifecycle actions.

---

## Options considered

### Option A - Add reschedule next

Pros:

- Useful for both patient and professional owners.
- Backend route already exists.

Risks:

- Needs concrete time selection from availability.
- Needs conflict/availability UX.
- Needs ownership-specific wording.
- Can accidentally reintroduce free-text booking or local time drafts.

### Option B - Add completion next

Pros:

- Narrow professional-only lifecycle action.
- No trusted request body.
- Backend remains authority for assigned professional, `ACCEPTED` status, and
  scheduled-end timing.
- Fits the current Recent section because past accepted appointments already
  land there.

Risks:

- UI must not expose completion before the appointment end time.
- UI must not expose completion to patients.
- UI must not add notes, prescriptions, reviews, payments, payouts, or calls.

### Option C - Run another fix/regression pass

Pros:

- Lowest risk.

Risks:

- Current lifecycle regression is already adequate for the next narrow action.

---

## Decision

Choose **Option B: professional completion next**.

Next runtime slice:

`52.50 - Wire Professional Appointment Completion`

Scope:

- read authenticated session role before showing completion
- show `Complete` only for professional users on `ACCEPTED` appointments whose
  scheduled end time is at or before `now`
- allow completion from Recent cards where accepted appointments have passed
- call `SchedulingRepository.completeAppointment`
- update visible status from backend response
- show safe failure text without raw backend messages
- keep backend authority for ownership, status, and scheduled-end validation

---

## Explicitly out of scope for 52.50

- patient completion
- professional or patient reschedule
- no-show/dispute states
- admin override
- notes, prescriptions, medical records
- reviews/ratings
- payments, refunds, payouts
- notifications/reminders
- calls/video/audio
- calendar sync

---

## Why not reschedule yet?

Reschedule should be a separate decision/runtime lane because it requires a
new requested time and duration. Doing it responsibly means deciding whether to
reuse the Search availability option generator, how to show availability for an
already-owned appointment, and how to avoid local time drafts pretending to be
backend availability.

Completion is smaller and safer because the frontend can send only the
appointment id and let the backend enforce assignment, status, and timing.
