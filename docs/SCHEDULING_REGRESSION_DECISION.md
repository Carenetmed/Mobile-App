# Scheduling regression decision

**Task:** 52.42
**Status:** Accepted decision before more scheduling feature expansion

Purpose: decide whether to continue immediately into professional availability
management or pause for a focused regression/checkpoint after request, list, and
cancel wiring.

This is a decision slice. It does not implement runtime behavior.

---

## Current completed patient scheduling path

The frontend now has a coherent backend-backed patient path:

1. Search reads public verified professionals.
2. Search profile sheet reads public availability for the selected backend
   professional id.
3. The sheet generates near-term requestable options.
4. The patient can send a backend appointment request.
5. The request success displays backend `REQUESTED` status.
6. The Appointments screen reads own backend appointments.
7. Eligible upcoming `REQUESTED`/`ACCEPTED` cards can cancel through the
   backend and update the visible card from the backend response.

This path is still intentionally limited. It does not include payments,
notifications, calls, calendar sync, reviews, notes, prescriptions, professional
accept/decline, reschedule, completion, or professional availability editing.

---

## Options considered

### Option A - Continue to professional availability management

Wire `selectedDates` / Manage Profile business hours to
`SchedulingRepository.ownAvailability` and `replaceOwnAvailability`.

Pros:

- Important professional setup surface.
- Backend routes already exist.

Risks:

- Requires careful full-set replacement behavior.
- Needs clear timezone/window UX.
- Could create confusing professional-facing scheduling authority before the
  existing patient path has a regression checkpoint.

### Option B - Continue to professional lifecycle

Add accept/decline/cancel/reschedule/complete controls for professional users.

Pros:

- Moves closer to a two-sided appointment workflow.

Risks:

- The app does not yet have a clean professional workspace distinction.
- Role-specific behavior and visibility need more deliberate product shape.

### Option C - Pause for scheduling regression/checkpoint

Run a focused regression slice over the backend-backed scheduling path and
document any fix slices before expanding.

Pros:

- Confirms no local fallback or fake success re-entered the path.
- Protects the newly wired request/list/cancel chain.
- Gives a clean base before professional availability management.

Risks:

- Delays professional availability UI by one slice.

---

## Decision

Choose **Option C: pause for scheduling regression/checkpoint**.

Next slice:

`52.43 - Scheduling Patient Path Regression`

Scope:

- Add/strengthen focused tests for:
  - Search public listing backend failure without local fallback
  - Search public availability empty/error states
  - generated request option selection
  - backend request success and safe failure
  - Appointments backend empty/error states
  - Appointments own-list status rendering
  - eligible cancellation success
  - cancellation hidden for terminal/recent cards
  - cancellation safe failure
- Update docs with any gaps discovered.
- Do not add professional availability management yet.
- Do not add professional lifecycle UI yet.

Out of scope:

- new runtime product behavior
- professional availability management
- professional accept/decline/reschedule/complete UI
- payments, refunds, payouts
- notifications/reminders
- calls
- calendar sync
- reviews
- notes, prescriptions, medical records
- admin override

---

## After regression

If regression passes without material gaps, the likely next lane is:

`52.44 - Decide Professional Availability Management UI Boundary`

That decision should inspect `selectedDates`, Manage Profile business hours,
the scheduling contract, and any available blueprint references before replacing
local business-hours drafts with backend availability read/replace behavior.
