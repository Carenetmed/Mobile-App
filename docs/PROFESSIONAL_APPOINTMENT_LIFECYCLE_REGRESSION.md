# Professional appointment lifecycle regression

**Task:** 52.48
**Status:** Regression checkpoint after professional accept/decline wiring

Purpose: prove the current Appointments lifecycle surface is role-aware and
narrow before deciding any broader lifecycle action.

This slice does not add runtime product behavior.

---

## Regression surface

The current Appointments lifecycle surface is:

1. Appointments reads backend-owned own appointments.
2. Appointments reads authenticated session role through `SessionStore`.
3. Patient sessions may cancel eligible upcoming `REQUESTED`/`ACCEPTED`
   appointments.
4. Professional sessions may accept or decline eligible upcoming `REQUESTED`
   appointments.
5. Success states replace the visible appointment card from backend repository
   responses.
6. Failure states show safe text and do not leak raw backend messages.

---

## Proof added or rechecked

| Area | Proof |
|------|-------|
| Patient cancel | `appointments_flow_test.dart` verifies patient cancellation calls backend and updates visible `CANCELLED` status |
| Accepted patient cancel | `appointments_flow_test.dart` verifies upcoming `ACCEPTED` cancellation remains backend-backed |
| Professional accept | `appointments_flow_test.dart` verifies professional role sees `Accept`, calls `acceptAppointment`, and updates to backend `ACCEPTED` |
| Professional decline | `appointments_flow_test.dart` verifies professional role sees `Decline`, calls `declineAppointment`, and updates to backend `DECLINED` |
| Role separation | `appointments_flow_test.dart` verifies patient sessions do not see professional actions and professional sessions do not show patient cancellation |
| State separation | `appointments_flow_test.dart` verifies professional actions only appear for `REQUESTED`, not `ACCEPTED` |
| Safe failure | `appointments_flow_test.dart` verifies accept failure shows safe error and keeps `REQUESTED` status |
| Broader lifecycle deferred | `appointments_flow_test.dart` verifies reschedule, complete, payment, calendar, and notes UI are not present |
| Repository boundary | `scheduling_repository_test.dart` verifies lifecycle actions send no trusted status body |

---

## Deferred after regression

These remain intentionally out of scope:

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

---

## Next lane

Next slice:

`52.49 - Decide Appointment Reschedule Or Completion Boundary`

That decision should choose whether the next safe lifecycle lane is reschedule,
completion, or another regression/fix pass. It should not implement runtime
behavior.
