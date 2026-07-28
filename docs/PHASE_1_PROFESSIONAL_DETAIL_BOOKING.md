# Phase 1 Professional Detail And Booking Contract

Slice: `APP-P1-005 - Canonical Professional Detail And Real Booking`

## Canonical journey

```text
Find Care
-> RouteName.specialistDetails with ProfessionalProfile.id
-> GET /professionals/:professionalProfileId
-> GET /professionals/:professionalProfileId/requestable-times
-> patient selects one returned UTC interval
-> authentication and patient setup when required
-> explicit confirmation
-> POST /appointments with Idempotency-Key
-> backend REQUESTED result
-> Appointments destination
```

`SpecialistDetailsShellPage` never reloads the full professional directory and
never reads `SearchLocalStore`. A missing, malformed, unknown, unverified, inactive,
or removed professional fails closed without seeded profile data.

## Public detail

The detail request is public and uses the exact `ProfessionalProfile.id`.
The UI renders only:

- display name;
- category;
- optional specialty;
- optional biography;
- verified presentation when `verified == true`.

The UI does not fabricate profile images, ratings, reviews, experience,
qualifications, licence data, addresses, fees, consultation modes, response times,
meeting links, or patient counts. An absent biography is omitted.

## Requestable times

Flutter calls the public backend requestable-times endpoint. It does not interpret
recurring availability windows, weekdays, minute offsets, lead-time rules, booking
horizons, or appointment conflicts.

The accepted mobile contract is:

- `durationMinutes == 30`;
- `cadenceMinutes == 30`;
- `leadTimeMinutes == 120`;
- `bookingHorizonDays == 60`;
- `startAt` and `endAt` are UTC ISO-8601 instants;
- `timezone` is the professional IANA timezone.

The `timezone` Dart package converts each returned UTC instant into the
professional timezone using IANA rules, including daylight-saving transitions.
Device-local time may appear only as a clearly secondary label.

Profile and time loading are independent. Initial failure, empty times, refresh,
and refresh failure with retained prior data are distinct. Duplicate loads are
serialized, stale selections are cleared after refresh, and disposed controllers
do not notify UI listeners.

## Booking intent

`BookingIntentStore` persists a structured intent in the existing secure storage:

- professional profile ID;
- selected UTC start/end;
- fixed 30-minute duration;
- UUID-style idempotency key;
- canonical resume route;
- creation and 24-hour expiry timestamps;
- authenticated account ID when available.

It stores no tokens, passwords, medical notes, or unnecessary personal data.
The intent is cleared on success, explicit cancellation, expiry, logout, account
change, incompatible role, invalid professional, or stale selected time.

Changing the professional or selected time creates a new idempotency key. A retry
of the same explicit submission reuses the existing key, including after an
uncertain network result. Repeated taps share one in-flight request.

## Authentication and authority

Browsing detail and requestable times is public. Submission remains protected.
Client navigation state preserves intent only and never grants authority.

- no session: save intent and enter sign-in;
- authenticated incomplete patient: enter patient setup and resume;
- authenticated ready patient: reload detail and times, then require confirmation;
- professional or unsupported role: do not submit, keep the session, explain that
  a patient account is required, and fail closed;
- account identity changed: clear the prior intent.

Booking-origin signup offers only the Patient role. Normal signup retains both
Patient and Professional choices.

## Submission and errors

`POST /appointments` sends:

- `professionalProfileId`;
- selected UTC `requestedStartAt`;
- `durationMinutes: 30`;
- `Idempotency-Key`.

The mobile response boundary is:

- `401`: preserve intent and enter authentication;
- `403`: explain incompatible account role and do not submit again;
- `404`: clear the invalid intent and treat the professional as unavailable;
- `409`: refresh requestable times, clear stale selection, and require reselection;
- uncertain network result: preserve the same key for safe retry;
- other failures: show a safe recoverable message.

Success is displayed as **appointment request sent**, never confirmed, accepted,
paid, or booked. The backend status remains `REQUESTED`.

## Legacy reachability

The route constants remain for conservative cleanup, but normal route resolution
for `bookAppointment`, `publicProfile`, and `findMentor` now opens canonical Find
Care. `specialistDetails` without a valid backend ID fails closed. Legacy source
files remain recoverable for the later deferred-feature cleanup milestone.

## Remaining limitations

- Appointment list/detail presentation still needs a dedicated role-aware
  experience pass.
- Appointment-linked messaging and consultation calls remain unimplemented.
- PAY-P1-008 now exposes the backend-owned consultation price on detail and
  implements payment/payout presentation after appointment acceptance. Detail
  still does not calculate, collect, or confirm money locally; see
  `PHASE_1_FINANCIAL_EXPERIENCE.md`.
- Blocked dates, one-off exceptions, buffers, variable durations, and calendar
  synchronization remain backend/product follow-ups.
- Full deferred-source deletion waits for the Phase 1 cleanup milestone.
