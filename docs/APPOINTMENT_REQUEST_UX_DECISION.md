# Concrete appointment request UX decision

**Task:** 52.36
**Status:** Accepted decision; time-option helper implemented in 52.37 before runtime request wiring

Purpose: define the first real appointment request UX after public availability
read and removal of local booking success.

This is a decision slice. It does not implement runtime appointment request.

---

## Sources reviewed

- `docs/SCHEDULING_AVAILABILITY_APPOINTMENT_CONTRACT.md`
- `docs/APPOINTMENT_REQUEST_UI_PATH_DECISION.md`
- `lib/features/Home/presentation/pages/search_shell.dart`
- `lib/features/Home/presentation/pages/appointments_shell.dart`
- `lib/features/Home/data/repositories/scheduling_repository.dart`

---

## Decision

The first runtime appointment request UI should start from the Search public
professional profile sheet, not from the standalone old `bookAppointment` form.

Accepted UX:

1. User opens Search.
2. Search loads public verified professionals from the backend.
3. User opens a public professional profile sheet.
4. The sheet loads public availability for that backend professional id.
5. User selects a concrete availability window shown by the backend.
6. User chooses a duration from a small fixed set.
7. User taps a request action.
8. The app calls `SchedulingRepository.requestAppointment`.
9. On success, the UI says the appointment is `REQUESTED`, not booked or
   confirmed.

The backend remains responsible for checking that the requested time still fits
availability and that the professional is verified.

---

## First duration options

Use fixed duration options:

- 30 minutes
- 45 minutes
- 60 minutes

Default to 30 minutes.

Do not add free-text reason, medical notes, visit type, payment state,
notification state, calendar state, or call state to the first request payload.

---

## Date/time selection rule

For the first implementation, do not invent a broad calendar picker.

Use the returned weekly availability windows to generate a small near-term list
of concrete UTC start times. The initial safe range should be the next seven
days from the user's current date.

The generated options are only UI suggestions. The backend still validates
availability during `POST /appointments`.

If this date-generation step becomes too large or fragile during
implementation, stop and split it into a helper/test slice before calling the
request API.

---

## Request payload

The UI may send only:

```json
{
  "professionalProfileId": "selected_public_professional_id",
  "requestedStartAt": "selected_concrete_start_time",
  "durationMinutes": 30
}
```

Do not send:

- patient profile id
- professional owner id
- role
- status
- payment state
- notification state
- calendar state
- call state
- visit type
- clinician text
- reason for visit
- medical notes
- verification state

---

## Success and failure behavior

Success:

- show safe confirmation that a request was sent
- display backend status as `REQUESTED`
- do not say booked, confirmed, accepted, paid, scheduled call, or calendar
  synced

Failure:

- missing backend config: `Backend is not configured yet.`
- unauthenticated/expired session: `Please sign in again.`
- validation/unavailable slot: `Please choose an available time and try again.`
- conflict: `That time is no longer available. Please choose another time.`
- server unavailable: `Service is unavailable. Please try again.`
- unknown/network: `Something went wrong. Please try again.`

Do not fall back to local request success.

---

## Next slice

`52.37 - Add Appointment Request Time Option Helper`

Scope:

- add a small helper that turns returned `AvailabilityWindow` values into
  near-term concrete request options for the next seven days
- include focused tests for weekday matching, start/end minute formatting,
  timezone preservation, duration fit, and empty windows
- do not call `requestAppointment`
- do not wire runtime booking UI yet

Implementation status:

- Done in 52.37 through `AppointmentRequestTimeOptions`
- The helper generates options at returned availability window start times only
- The helper preserves the backend timezone string but does not pretend to do
  full IANA timezone conversion on the client
- Runtime request UI remains deferred to 52.38

Then:

`52.38 - Wire Appointment Request From Search Availability`

Likely scope:

- add selectable generated time options and duration options in the Search
  profile sheet
- call `SchedulingRepository.requestAppointment`
- show `REQUESTED` success only from backend success
- keep own appointment list, professional lifecycle, payments, notifications,
  reviews, calls, calendar sync, notes, and prescriptions deferred

---

## Out of scope

- standalone `bookAppointment` request wiring
- broad calendar picker
- free-text medical reason or notes
- public professional detail expansion
- Find Mentor replacement
- Specialist Details replacement
- own appointment list refresh
- professional accept/decline/cancel/reschedule/complete UI
- payments, refunds, payouts
- notifications/reminders
- calls/video/audio
- reviews/ratings
- calendar provider sync
- admin override
- patient completion
- no-show/dispute workflow
- consultation notes, prescriptions, and medical records
