# Scheduling patient-path regression

**Task:** 52.43
**Status:** Regression checkpoint after request/list/cancel wiring

Purpose: prove the current backend-backed patient scheduling path before adding
professional availability management or professional lifecycle controls.

This slice does not add runtime product behavior.

---

## Regression surface

The current patient scheduling path is:

1. Search reads backend public verified professionals.
2. Public profile sheet reads backend public availability for the selected
   professional profile.
3. The frontend generates requestable time options from backend availability.
4. The patient submits a backend appointment request for the selected option.
5. Request success displays the backend `REQUESTED` status.
6. Appointments reads backend own appointments.
7. Eligible upcoming `REQUESTED` and `ACCEPTED` appointments can be cancelled
   through the backend.

---

## Proof added or rechecked

| Area | Proof |
|------|-------|
| Public listing failure | `search_flow_test.dart` verifies a backend error shows a safe message and no seeded doctors |
| Public listing success | `search_flow_test.dart` verifies backend professionals render and seeded doctors do not |
| Public availability empty | `search_flow_test.dart` verifies empty availability stays honest |
| Public availability error | `search_flow_test.dart` verifies safe error text and no local slot fallback |
| Generated request option | `appointment_request_time_options_test.dart` verifies generated options, durations, timezone, invalid/inactive/past windows |
| Request success | `search_flow_test.dart` verifies selected option calls `requestAppointment` and displays backend `REQUESTED` |
| Request failure | `search_flow_test.dart` verifies safe failure text and no fake success |
| Own appointments empty/error | `appointments_flow_test.dart` verifies backend empty/error states without local appointment fallback |
| Own appointment status rendering | `appointments_flow_test.dart` verifies upcoming/recent backend statuses render |
| Requested cancellation | `appointments_flow_test.dart` verifies upcoming `REQUESTED` appointment cancellation calls backend and updates status |
| Accepted cancellation | `appointments_flow_test.dart` verifies upcoming `ACCEPTED` appointment cancellation calls backend and updates status |
| Terminal/recent hidden actions | `appointments_flow_test.dart` verifies terminal and recent active-status cards do not expose cancellation |
| Cancellation failure | `appointments_flow_test.dart` verifies safe failure text and no optimistic status update |

---

## Gaps not fixed in this slice

These are intentionally not part of the patient-path regression:

- professional availability management UI
- professional accept/decline/reschedule/complete UI
- patient reschedule
- payments, refunds, payouts
- notifications and reminders
- calls or video visits
- calendar sync
- reviews
- notes, prescriptions, medical records
- admin override

---

## Next lane

Next slice:

`52.44 - Decide Professional Availability Management UI Boundary`

That decision should inspect Manage Profile business-hour UI, any selected-date
state, the scheduling repository contract, and blueprint evidence before
replacing local professional availability drafts with backend read/replace
behavior.
