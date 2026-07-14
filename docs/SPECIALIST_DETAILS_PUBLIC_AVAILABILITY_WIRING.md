# Specialist Details Public Availability Wiring

Task: 52.69

Status: Implemented

## Scope

The existing `specialistDetails` route can now render a backend-backed public
professional detail surface when a backend public professional id is available.

This slice uses existing repository capabilities only:

- `ProfileRepository.publicProfessionals`
- `SchedulingRepository.publicAvailability`
- `SchedulingRepository.requestAppointment`

No public professional detail endpoint was invented.

## Runtime Behavior

When `specialistDetails` receives a backend public professional id and profile
plus scheduling repositories are available, the route:

- loads the public professional from `ProfileRepository.publicProfessionals`
- matches the passed route id to a returned public professional id
- displays backend public name, category, specialty, bio, and verification state
- loads public availability from `SchedulingRepository.publicAvailability`
- generates requestable appointment options from backend availability windows
- submits selected request time through `SchedulingRepository.requestAppointment`
- shows safe loading, empty, error, and success states

When the route is opened in old local-only test/dev navigation without
registered repositories, the previous local Specialist Details behavior remains
available for compatibility.

## Boundary

This slice does not:

- call a public detail endpoint
- use local availability slots after a backend professional id is being handled
- persist local booking success
- send payment, review, call, calendar, notes, prescription, admin, or
  verification data
- upload verification documents
- seed staging data
- claim production readiness

## Failure Behavior

Backend/public-professional failure:

- shows a safe message
- does not fall back to local specialists

Unresolved backend professional id:

- shows `Backend professional could not be found.`
- does not fall back to local specialists

Availability failure:

- shows safe availability error text
- does not show seeded local day/time chips

Appointment request failure:

- shows safe request error text
- does not claim local confirmation or backend success

## Verification

Focused tests cover:

- backend public professional detail render
- backend public availability render
- generated request option render
- selected appointment request payload
- safe availability failure
- safe appointment request failure
- unresolved backend professional id
- no local slot fallback in backend path
- no payment/review/calendar/admin surfaces

Commands:

```powershell
dart format lib\features\Home\presentation\pages\search_shell.dart lib\features\Home\presentation\pages\specialist_details_shell.dart test\features\home\specialist_details_flow_test.dart
flutter test test\features\home\specialist_details_flow_test.dart -r compact
flutter test test\features\home\search_flow_test.dart -r compact
flutter test test\features\home\dashboard_shell_test.dart -r compact
flutter analyze lib\features\Home\presentation\pages\search_shell.dart lib\features\Home\presentation\pages\specialist_details_shell.dart test\features\home\specialist_details_flow_test.dart test\features\home\search_flow_test.dart test\features\home\dashboard_shell_test.dart
```

## Still Deferred

- dedicated public professional detail endpoint
- Find Mentor replacement
- broader Specialist Details reviews/ratings/pricing
- verification upload/list
- admin verification dashboard
- payments
- notifications
- calls/video
- calendar sync
- notes, prescriptions, or medical records
- staging data seeding
- production release readiness
