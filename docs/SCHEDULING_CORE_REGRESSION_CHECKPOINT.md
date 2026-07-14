# Scheduling Core Regression Checkpoint

Task: 52.53

Date: 2026-07-15

## Scope

This checkpoint verifies the current backend-backed scheduling core without
adding runtime features.

Covered surfaces:

- Search public professional listing
- Search public availability read
- Search appointment request
- Appointments own-list read
- Patient cancellation
- Professional accept/decline
- Professional completion
- selectedDates professional availability management
- Scheduling repository payload boundaries

## Regression Proof

Focused tests cover the current core:

- `test/features/home/search_flow_test.dart`
  - public professional listing reads backend public professionals
  - backend listing errors do not fall back to seeded local specialists
  - public availability reads backend availability for the selected professional
  - public availability errors do not fall back to local slots
  - generated time options drive appointment request
  - request success shows backend `REQUESTED`
  - request failures show safe errors without raw backend copy or fake success
  - payment, notification, calendar, review, notes, prescription, call, and
    admin controls are absent from the availability/request sheet

- `test/features/home/appointments_flow_test.dart`
  - own appointment list reads backend appointments and renders
    upcoming/recent sections
  - backend list errors do not fall back to seeded local appointments
  - patient cancellation works only for eligible requested/accepted appointments
  - terminal/recent cancellation actions stay hidden
  - professional accept/decline appears only for professional users on
    `REQUESTED` appointments
  - professional completion appears only for professional users on accepted
    appointments whose scheduled end time has passed
  - exact scheduled-end completion is allowed
  - patient, cancelled, declined, and completed appointments cannot complete
  - completion failure shows safe errors without raw backend copy
  - reschedule, payment, notification, calendar, review, notes, prescription,
    call, and admin controls remain absent

- `test/features/home/manage_profile_flow_test.dart`
  - selectedDates reads backend own availability
  - availability save uses `replaceOwnAvailability`
  - availability read/save failures show safe errors without local fallback
  - payment, notification, calendar-sync, review, prescription, call, and admin
    controls remain absent from the availability management surface

- `test/features/home/scheduling_repository_test.dart`
  - public availability sends no auth header
  - protected scheduling calls require bearer auth
  - appointment request payload sends only backend-accepted fields
  - availability replacement sends only allowed window fields
  - lifecycle actions do not send trusted status bodies
  - reschedule repository payload stays narrow, but runtime reschedule UI remains
    deferred

## Decision

The current scheduling core is ready for a post-regression lane decision. Do not
add runtime reschedule, payment, notification, calendar, review, notes,
prescription, call, or admin behavior without a new decision slice.

## Remaining Risks

- Reschedule UX/product rules are not defined.
- Public professional detail replacement is still deferred.
- Find Mentor and Specialist Details still use older local scheduling handoffs.
- Real staging end-to-end smoke for the full scheduling path is not recorded in
  this Flutter repo.
- Payments, notifications, reviews, calls, calendar sync, notes, prescriptions,
  admin override, no-show/disputes, and medical records remain out of scope.

## Next

Task 52.54 should decide the next post-regression scheduling lane:

- Option A: define reschedule UX/product boundary before runtime wiring.
- Option B: pause scheduling and move to another backend-completed surface.
- Option C: run a real-device/staging smoke checkpoint if credentials and test
  data are available.
