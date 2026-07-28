# Phase 1 appointment experience and professional Schedule

**Slice:** APP-P1-006
**Status:** Implemented
**Backend contract:** `620b0232cdbffb786bf70303cded2aa4835f45b7`

## Authority

The authenticated backend owns role, appointment ownership, professional
assignment, status, transition eligibility, conflicts, recurring availability,
and timestamps. Flutter uses session role only to hide obviously invalid actions.
Every mutation is still revalidated by the backend and the UI reloads the
authoritative appointment afterward.

`GET /appointments` is the only authenticated appointment read contract. It
returns appointments owned by the current patient or assigned to the current
professional. The backend does not yet provide `GET /appointments/:id`, so
canonical detail reloads the authenticated own-list and selects the exact
appointment ID. Missing IDs and appointments outside the account-owned list fail
closed without local fallback.

## List contract

The role-aware Appointments destination uses deterministic sections:

- `Action needed`: future `REQUESTED` appointments for professionals.
- `Upcoming`: future `REQUESTED` or `ACCEPTED` appointments that do not require
  professional action.
- `Past`: completed, malformed-time, or past active appointments.
- `Cancelled or declined`: terminal `CANCELLED`, `DECLINED`, and unknown states.

Future sections sort by requested time ascending, then appointment ID. Past and
closed sections sort by requested time descending, then appointment ID.
Malformed timestamps expose no action.

The API currently supplies profile IDs but no participant display names. The UI
uses the neutral role labels `Professional` and `Patient`; it does not fabricate
names, consultation mode, fee, location, messages, payment, or call readiness.

## Detail and actions

`RouteName.appointmentDetail` accepts only an appointment ID and opens
`AppointmentDetailShellPage`.

| Role | Backend status | UI actions |
|------|----------------|------------|
| Patient | `REQUESTED` | Cancel, reschedule |
| Patient | `ACCEPTED` | Cancel, reschedule |
| Professional | future `REQUESTED` | Accept, decline, cancel, reschedule |
| Professional | elapsed `REQUESTED` | Decline, cancel, reschedule |
| Professional | `ACCEPTED` | Cancel, reschedule; complete after scheduled end |
| Either | `DECLINED`, `CANCELLED`, `COMPLETED`, unknown | None |

Reschedule loads `GET /professionals/:id/requestable-times`, presents only
backend-generated instants, and sends the selected UTC instant with a fixed
30-minute duration. Flutter no longer generates active reschedule times from
recurring windows.

Actions are serialized. The UI does not apply an optimistic status. Success,
409 conflict, 404 removal, and uncertain network outcomes all trigger an
authoritative reload. A 403 is shown as an authorization failure rather than a
request to sign in again.

## Professional Schedule

The professional Schedule destination uses:

- `GET /availability/me`
- `PUT /availability/me`

The write payload is the backend contract:

```json
{
  "availabilityWindows": [
    {
      "weekday": 0,
      "startMinute": 540,
      "endMinute": 1020,
      "timezone": "Africa/Lagos",
      "isActive": true
    }
  ]
}
```

Weekday `0` is Sunday and `6` is Saturday. Start is inclusive and end is
exclusive. The editor validates bounds, end-after-start, overlap, and IANA
timezone before replacing the complete backend set. Mutations are serialized
and followed by a fresh backend read. Patients and unsupported roles fail
closed before the availability repository is called.

Schedule displays recurring availability rules only. Patient booking remains
owned by backend-generated requestable times, so a recurring window is never
described as a confirmed or currently free slot.

## Loading and failure

List, detail, and Schedule distinguish initial loading, empty, failure,
refreshing, and refresh failure with retained previous data. Repeated requests
are serialized, stale completions are rejected by generation, and disposed
controllers do not notify widgets.

## Explicit limits

- No single-appointment backend read endpoint.
- No participant display names in appointment responses.
- No dedicated audit-history read in mobile detail.
- No cancellation reason, reschedule reason, no-show, dispute, or follow-up
  contract.
- Appointment-linked plain-text messaging is implemented under
  `PHASE_1_APPOINTMENT_MESSAGING.md`; push, attachments, retention policy, and
  medical-record classification remain separate launch gates.
- No consultation join or RTC behavior.
- PAY-P1-008 now presents backend-owned payment/refund/reversal state in
  Appointment Detail and professional finance state through Account. Financial
  authority remains outside the appointment UI; see
  `PHASE_1_FINANCIAL_EXPERIENCE.md`.
- No notification-provider delivery.
- No blocked dates, holidays, breaks, buffers, variable durations, or calendar
  synchronization.

## Messaging handoff

Accepted and completed appointments expose `Open appointment messages`.
Flutter resolves the matching conversation through backend-owned appointment
data and never creates one locally. Requested or declined appointments cannot
fabricate a conversation; rescheduled history remains read-only until the
backend restores writability.
