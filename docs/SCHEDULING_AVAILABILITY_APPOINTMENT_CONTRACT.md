# Scheduling, availability, and appointment frontend contract

**Task:** 52.31
**Status:** Accepted contract; repository boundary implemented in 52.32; first public availability UI read implemented in 52.33

Purpose: define how the Flutter app should consume the completed backend
availability and appointment surfaces without seeded fallback, fake booking
success, or client-owned authority.

This is a contract slice. It does not add runtime scheduling code.

---

## Sources reviewed

- `docs/SCHEDULING_AVAILABILITY_APPOINTMENT_LANE_DECISION.md`
- `docs/BACKEND_COMPLETED_SURFACE_WIRING_MAP.md`
- `docs/PROFILE_PUBLIC_PROFESSIONAL_CONTRACT.md`
- `docs/DEFERRED_WORK.md`
- `C:\Users\asd\Music\carenet-backend-lab\docs\05-api-plan.md`
- `C:\Users\asd\Music\carenet-backend-lab\docs\24-appointment-core-regression-plan.md`
- `C:\Users\asd\Music\carenet-backend-lab\docs\36-frontend-backend-staging-contract.md`
- `C:\Users\asd\Music\carenet-backend-lab\docs\45-frontend-backend-staging-integration-readiness.md`

---

## Accepted backend surfaces

| Surface | Route | Auth | Accepted frontend use |
| --- | --- | --- | --- |
| Public verified-professional availability | `GET /professionals/:professionalProfileId/availability` | Public | Read active weekly availability for a backend-verified professional selected from public listing |
| Professional own availability read | `GET /availability/me` | `PROFESSIONAL` JWT | Read current professional's own weekly availability windows |
| Professional own availability replace | `PUT /availability/me` | `PROFESSIONAL` JWT | Replace current professional's own weekly availability windows |
| Appointment request | `POST /appointments` | `PATIENT` JWT | Patient requests an appointment with a verified professional inside active availability |
| Own appointment list | `GET /appointments` | `PATIENT` or `PROFESSIONAL` JWT | Current patient/professional reads only their own appointments |
| Professional accept | `POST /appointments/:appointmentId/accept` | `PROFESSIONAL` JWT | Assigned professional accepts a `REQUESTED` appointment |
| Professional decline | `POST /appointments/:appointmentId/decline` | `PROFESSIONAL` JWT | Assigned professional declines a `REQUESTED` appointment |
| Owner cancel | `POST /appointments/:appointmentId/cancel` | `PATIENT` or `PROFESSIONAL` JWT | Appointment owner/assigned professional cancels active appointments |
| Owner reschedule | `POST /appointments/:appointmentId/reschedule` | `PATIENT` or `PROFESSIONAL` JWT | Appointment owner/assigned professional requests a new time and returns active appointments to `REQUESTED` |
| Professional complete | `POST /appointments/:appointmentId/complete` | `PROFESSIONAL` JWT | Assigned professional completes an `ACCEPTED` appointment after scheduled end time |

---

## Flutter files for the first implementation slice

Add scheduling data behind a repository boundary instead of wiring screens
directly to `Dio`.

Recommended files:

- `lib/features/Home/domain/entities/availability_window.dart`
- `lib/features/Home/domain/entities/appointment_summary.dart`
- `lib/features/Home/data/models/availability_window_model.dart`
- `lib/features/Home/data/models/appointment_summary_model.dart`
- `lib/features/Home/data/services/scheduling_api_client.dart`
- `lib/features/Home/data/repositories/scheduling_repository.dart`
- focused tests under `test/features/home/scheduling_repository_test.dart`

The first implementation slice should add the API client, repository, entities,
models, DI registration, and tests only. It should not wire UI screens yet.

Implemented in 52.32:

- `AvailabilityWindow` and `AvailabilityWindowDraft`
- `AppointmentSummary` and `AppointmentStatus`
- availability and appointment JSON models
- `SchedulingApiClient`
- `SchedulingRepository`
- DI registration
- focused repository tests for public no-auth availability, protected bearer
  calls, allowed payloads, lifecycle actions without trusted status bodies,
  missing config, missing session, and safe conflict mapping

---

## Availability contract

Availability window fields accepted by the frontend:

- `id`
- `weekday`
- `startMinute`
- `endMinute`
- `timezone`
- `active`
- `createdAt`
- `updatedAt`

Rules:

- `weekday` is backend-owned numeric weekday semantics from the backend
  contract; the frontend may format it for display but must not reinterpret it
  as authority.
- `startMinute` and `endMinute` are minutes after local midnight in the
  provided `timezone`.
- `endMinute` must be greater than `startMinute`.
- Public availability should show only active windows returned by the backend.
- Professional own availability may show active and inactive windows if the
  backend returns them.
- The frontend must not send professional profile ids for `/availability/me`.
- The frontend must not trust local selected-date drafts as saved availability
  after backend wiring.

Allowed professional replace payload:

```json
{
  "windows": [
    {
      "weekday": 1,
      "startMinute": 540,
      "endMinute": 1020,
      "timezone": "Africa/Lagos",
      "active": true
    }
  ]
}
```

Out of scope for the first availability implementation:

- blocked dates
- one-off overrides
- recurring exceptions
- breaks and buffers
- capacity, waitlists, appointment types
- provider calendar sync
- payment or entitlement gates

---

## Appointment contract

Appointment summary fields accepted by the frontend:

- `id`
- `patientProfileId`
- `professionalProfileId`
- `requestedStartAt`
- `durationMinutes`
- `status`
- `createdAt`
- `updatedAt`

Accepted statuses:

- `REQUESTED`
- `ACCEPTED`
- `DECLINED`
- `CANCELLED`
- `COMPLETED`

Allowed appointment request payload:

```json
{
  "professionalProfileId": "professional_profile_id_from_public_listing",
  "requestedStartAt": "2026-07-14T10:30:00.000Z",
  "durationMinutes": 30
}
```

Allowed reschedule payload:

```json
{
  "requestedStartAt": "2026-07-15T11:00:00.000Z",
  "durationMinutes": 30
}
```

Lifecycle actions have no trusted request body:

- `accept`
- `decline`
- `cancel`
- `complete`

Rules:

- Appointment request requires a signed-in `PATIENT`.
- Professional lifecycle actions require a signed-in `PROFESSIONAL`.
- The frontend must not send patient profile id, professional owner id, role,
  status, payment state, call state, notification state, calendar state,
  medical notes, or verification state.
- The backend decides whether a professional is verified.
- The backend decides whether a requested time fits active availability.
- The backend decides ownership and terminal state behavior.
- A frontend success state must come only from repository success, never from a
  locally confirmed draft.

---

## Screen mapping

| Existing screen | First allowed backend use | Not allowed yet |
| --- | --- | --- |
| `search` | May pass a selected public professional id into later availability/booking flows after repository contract exists | Must not reintroduce local specialist fallback or enable booking before availability/request wiring |
| `specialistDetails` | May become the first public availability read surface for a selected public professional | Must not invent public detail data, ratings, prices, reviews, meeting location, phone, or local slot success |
| `findMentor` | Keep local/deferred until a dedicated replacement slice; do not use it as a fallback for Search | Must not duplicate partially wired Search behavior |
| `bookAppointment` | May become patient appointment request UI only after public availability read is wired | Must not confirm locally or send free-text medical notes |
| `appointments` | May become own appointment list after repository boundary exists | Must not show seeded booked/completed appointments once backend-wired |
| `selectedDates` | May become professional own availability read/replace after repository boundary exists | Must not claim route-local prepared hours were saved |
| `manageProfile` business hours | May route into backend-backed `selectedDates` after availability management wiring | Must not mix profile mutation and availability persistence in one slice |

---

## Error and state rules

Use safe user-facing messages:

- missing backend config: `Backend is not configured yet.`
- unauthenticated/expired session: `Please sign in again.`
- wrong role or forbidden: `This action is not available for this account.`
- validation/unavailable slot: `Please choose an available time and try again.`
- conflict: `That time is no longer available. Please choose another time.`
- server unavailable: `Service is unavailable. Please try again.`
- network/unknown: `Something went wrong. Please try again.`

No backend-wired scheduling screen may hide failures behind:

- seeded local specialists
- local booking drafts
- local confirmed appointments
- local weekly availability summaries
- fake ratings/prices/reviews
- fake call/calendar/payment states

If the backend returns an empty list, show an empty state. If it returns an
error, show a safe error. If config is missing, say it is missing.

---

## Recommended next slices

`52.32 - Add Scheduling Repository Boundary`

Scope:

- add availability and appointment entities/models
- add `SchedulingApiClient`
- add `SchedulingRepository`
- register dependency injection
- add focused repository/API tests for headers, payloads, parsing, safe errors,
  and no client-owned authority fields
- no UI wiring

Implemented in 52.32.

Then:

`52.33 - Wire Public Availability Read`

Likely first runtime target: selected public professional -> availability read
surface. This should still keep appointment request disabled until a separate
booking request slice.

Implemented in 52.33:

- Search public professional profile sheet calls
  `SchedulingRepository.publicAvailability` for the selected backend public
  professional id.
- The sheet shows loading, safe error, empty, and real availability-window
  states.
- Booking remains disabled/deferred.
- Specialist Details, Find Mentor, appointment request, professional own
  availability management, own appointment list, and lifecycle actions remain
  deferred.

Next:

`52.34 - Decide First Appointment Request UI Path`

---

## Deferred work

- public professional detail route invention
- full Find Mentor replacement
- Specialist Details profile expansion beyond public listing plus availability
- appointment payment, refund, payout, and invoice state
- notifications/reminders
- reviews/ratings
- calls/video/audio
- calendar provider sync
- admin appointment override
- patient completion
- no-show/dispute workflows
- consultation notes, prescriptions, and medical records
- production/stakeholder staging access
