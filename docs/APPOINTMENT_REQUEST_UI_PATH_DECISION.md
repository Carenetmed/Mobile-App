# Appointment request UI path decision

**Task:** 52.34
**Status:** Accepted decision; local booking success removed in 52.35

Purpose: decide how the frontend should move from public availability display to
real appointment request without preserving local/dummy booking success.

This is a decision slice. It does not implement appointment request runtime
behavior.

---

## Sources reviewed

- `docs/SCHEDULING_AVAILABILITY_APPOINTMENT_CONTRACT.md`
- `docs/DEFERRED_WORK.md`
- `lib/features/Home/presentation/pages/search_shell.dart`
- `lib/features/Home/presentation/pages/appointments_shell.dart`
- `lib/features/Home/presentation/pages/find_mentor_shell.dart`
- `lib/features/Home/presentation/pages/specialist_details_shell.dart`
- `lib/features/Home/presentation/pages/public_profile_shell.dart`

---

## Decision

Do not adapt the existing `bookAppointment` free-text local form directly into
the backend appointment request path.

The first safe appointment request path should be:

1. Start from a backend public professional selected in Search.
2. Read public availability through `SchedulingRepository.publicAvailability`.
3. Let the patient choose a concrete date/time derived from a returned
   availability window.
4. Call `SchedulingRepository.requestAppointment` with only:
   - `professionalProfileId`
   - `requestedStartAt`
   - `durationMinutes`
5. Treat success as backend `REQUESTED`, not booked/confirmed.

Before real request wiring, remove or neutralize the old local booking success
path so it cannot be mistaken for backend booking.

---

## Why not the old form directly

The current `bookAppointment` route accepts:

- free-text clinician
- free-text preferred date
- free-text reason
- visit type
- local draft confirmation

Those fields do not match the accepted backend request contract. The backend
does not accept clinician text, patient owner id, status, visit type, reason,
medical notes, payment state, notification state, or calendar state for the
first appointment request route.

Keeping local `Confirmed locally` behavior while wiring real availability would
create a fake success path. That violates the current no-dummy/no-fallback
policy.

---

## Next slice

`52.35 - Remove Local Booking Success`

Scope:

- Keep the route available if existing navigation depends on it.
- Remove local `Confirmed locally` / fake booking completion behavior.
- Replace local confirmation with an honest deferred/backend-required state.
- Keep validation only if it is clearly labeled as not submitted.
- Do not call appointment request API yet.
- Do not invent date/time conversion rules.
- Update tests and docs to remove fake booking success expectations.

Implemented in 52.35:

- `bookAppointment` no longer exposes `Confirm request`.
- `Confirmed locally` and fake booking completion behavior were removed.
- Valid details show `Backend request not sent`.
- The route does not call the appointment request API yet.

Then:

`52.36 - Define Concrete Appointment Request UX`

Likely scope:

- choose the exact UI for selecting a concrete date/time from public
  availability
- decide duration options
- decide whether the request action stays inside Search sheet or navigates to a
  rewritten booking route with typed arguments
- keep free-text medical reason/notes out of the first request

---

## Explicitly out of scope

- no runtime appointment request
- no appointment confirmation/accepted claim
- no payments, refunds, payouts
- no notifications/reminders
- no reviews/ratings
- no calls/video/audio
- no calendar sync
- no admin override
- no patient completion
- no no-show/dispute states
- no consultation notes, prescriptions, or medical records
- no public professional detail invention
- no Find Mentor or Specialist Details replacement
