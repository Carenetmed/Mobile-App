# Professional availability UI boundary decision

**Task:** 52.44
**Status:** Accepted boundary before runtime availability management

Purpose: decide where professional availability management belongs and how the
next runtime slice should replace local business-hour drafts without mixing
profile mutation, appointment lifecycle, payments, or calendar behavior.

This is a decision slice. It does not implement runtime behavior.

---

## Evidence reviewed

- `manageProfile` Business section currently links `Edit hours` to
  `selectedDates`.
- `selectedDates` currently prepares a route-local business-hours draft and
  explicitly says no profile schedule has been saved.
- `SchedulingRepository` already exposes `ownAvailability()` and
  `replaceOwnAvailability(windows:)`.
- `SchedulingApiClient` maps those methods to `GET /availability/me` and
  `PUT /availability/me` with bearer auth.
- `scheduling_repository_test.dart` already proves protected auth, allowed
  replace payload fields, missing config, and safe scheduling failures.
- `SCHEDULING_AVAILABILITY_APPOINTMENT_CONTRACT.md` says `selectedDates` may
  become professional own availability read/replace and must not claim local
  drafts are saved.
- `SCHEDULING_PATIENT_PATH_REGRESSION.md` records that the patient path has a
  focused regression checkpoint before this expansion.

---

## Decision

Choose `selectedDates` as the professional availability management surface.

`manageProfile` should remain the entry point and summary surface. It should
not perform profile mutation and availability persistence in the same slice.

Next runtime slice:

`52.45 - Wire Professional Availability Management`

---

## Runtime boundary for 52.45

The next slice should:

- inject/use `SchedulingRepository` in `SelectedDatesShellPage`
- read current professional availability with `ownAvailability()`
- show loading, safe error, and empty states
- render backend weekly windows without seeded "Closed" or "Available 24 hours"
  claims after the backend read completes
- allow the professional to prepare a simple single-window weekly replacement
  from the selected date, all-day/start/end controls, and timezone default
- call `replaceOwnAvailability(windows:)` only from an explicit save action
- replace visible state from the backend response
- show success only after repository success
- keep safe error messages and hide raw backend text
- add focused tests for read success, read empty, read failure, save success,
  save failure, payload boundary, and no local saved claim

The first runtime implementation may stay deliberately simple: one selected
weekday window plus any returned backend windows. It should be clear that the
backend `PUT /availability/me` is a full replacement operation, so the UI must
not silently drop existing windows without an intentional rule.

---

## Required guardrails

- Do not send a professional profile id, user id, verification state, payment
  state, appointment state, calendar state, or profile fields in availability
  payloads.
- Do not mix profile bio/name/category/address/website mutation with
  availability persistence.
- Do not add appointment accept/decline/reschedule/complete UI.
- Do not add patient reschedule.
- Do not add payments, refunds, payouts, notifications, calls, calendar sync,
  reviews, notes, prescriptions, or admin override.
- Do not claim production calendar sync or real-time conflict prevention from
  the frontend. The backend remains authority for appointment requests and
  conflicts.

---

## Open implementation choice for 52.45

The only implementation choice left for 52.45 is the safest full-replacement UX:

1. **Conservative replace:** save only the selected weekday window and clearly
   label that it replaces the weekly availability set.
2. **Preserve other windows:** merge the edited weekday into the current backend
   list and replace the full set.

Preferred direction: **preserve other windows**. It avoids accidental data loss
when a professional edits one day. If merging becomes too complex, stop and
record a smaller decision/fix slice instead of silently dropping windows.

---

## Next lane

After 52.45, run a focused regression or decision slice before professional
appointment lifecycle UI. Professional accept/decline/reschedule/complete
controls should not start until availability management has its own proof.
