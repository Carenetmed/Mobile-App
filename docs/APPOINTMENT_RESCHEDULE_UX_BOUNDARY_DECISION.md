# Appointment Reschedule UX Boundary Decision

Task: 52.55

Date: 2026-07-15

## Decision

Add appointment reschedule as a narrow scheduling milestone item, but only after
one more implementation slice defines the UI from existing backend availability
data.

The next runtime slice may wire a constrained reschedule path:

`52.56 - Wire Appointment Reschedule From Existing Scheduling Surfaces`

## Backend Boundary

The accepted backend rule is the ADR 0024 request-again model:

- authenticated patients may reschedule appointments attached to their own
  patient profile
- assigned authenticated professionals may reschedule appointments attached to
  their own professional profile
- only `REQUESTED` and `ACCEPTED` appointments can be rescheduled
- successful reschedule updates `requestedStartAt` and `durationMinutes`
- successful reschedule returns the appointment to `REQUESTED`
- previously accepted appointments require professional acceptance again after
  reschedule
- backend enforces current active availability for the assigned professional
- backend rejects terminal states without rewriting state
- backend writes safe appointment mutation audit metadata

The frontend must treat the backend response as authority.

## Frontend UX Boundary

### Who sees reschedule

Show reschedule only after authenticated session role is known:

- `PATIENT`: may see reschedule on owned `REQUESTED` and `ACCEPTED`
  appointments.
- `PROFESSIONAL`: may see reschedule on assigned `REQUESTED` and `ACCEPTED`
  appointments.
- Unknown role: show no reschedule action.

The frontend does not prove ownership. It only shows the action on the user's
own appointment list and lets the backend enforce ownership.

### Which appointments are eligible

Eligible:

- `REQUESTED`
- `ACCEPTED`

Not eligible:

- `DECLINED`
- `CANCELLED`
- `COMPLETED`

Past appointment reschedule should not be exposed in the first UI slice. The
first implementation should show reschedule only on upcoming active appointment
cards.

### Time and duration selection

The first reschedule UI should not invent a free-text date/time picker.

Use the same generated appointment time-option model already proven for
appointment requests:

- read public availability for the appointment's existing
  `professionalProfileId`
- generate near-term request options from returned availability windows
- let the user select one generated option
- send that option's `requestedStartAt`
- send that option's `durationMinutes`

The first implementation may allow the generated option duration to differ from
the original appointment duration, because the backend reschedule payload accepts
`durationMinutes` and the existing request-option generator already validates
duration fit inside an availability window.

## Safe Success Behavior

On success:

- call `SchedulingRepository.rescheduleAppointment`
- replace the visible appointment card from the backend response
- show backend status from the response
- expect the visible status to become `REQUESTED` when the backend follows ADR
  0024
- hide accept/decline/complete/cancel/reschedule actions according to the
  returned status and current existing UI rules

Do not show local "rescheduled" success before repository success.

## Safe Failure Behavior

Use existing safe scheduling error copy:

- missing backend config: `Backend is not configured yet.`
- unauthenticated/expired session: `Please sign in again.`
- wrong role or forbidden: `This action is not available for this account.`
- validation/unavailable slot: `Please choose an available time and try again.`
- conflict: `That time is no longer available. Please choose another time.`
- server unavailable: `Service is unavailable. Please try again.`
- network/unknown: `Something went wrong. Please try again.`

Never expose raw backend error strings.

## Payload Boundary

The frontend may send only:

```json
{
  "requestedStartAt": "2026-07-15T11:00:00.000Z",
  "durationMinutes": 30
}
```

The frontend must not send:

- patient profile id
- professional profile id
- role
- target status
- payment state
- refund state
- notification state
- calendar state
- call state
- review state
- notes
- prescriptions
- medical records
- admin override state

## Explicitly Deferred

- free-text/manual date-time entry
- patient/professional custom reschedule messages
- reschedule reason capture
- policy copy for late reschedule windows
- notifications and reminders
- calendar sync
- payments, refunds, and payouts
- reviews
- calls
- admin override
- no-show/dispute states
- notes, prescriptions, and medical records
- real-device/staging reschedule smoke

## Stop Conditions

Stop before runtime implementation if:

- the appointment card cannot access the selected appointment's
  `professionalProfileId`
- the UI cannot reuse existing public availability/request-option generation
  without free-text time entry
- role state is unavailable
- the implementation would require notifications, payments, calendar sync,
  reviews, calls, admin override, notes, prescriptions, or medical records
- the backend response does not contain enough appointment summary data to
  replace the visible card

## Next

Task 52.56 may wire the constrained runtime reschedule path described here.
Keep it narrow and covered by focused tests. Do not add broader scheduling,
payment, notification, review, call, calendar, notes, prescription, admin, or
medical-record behavior.
