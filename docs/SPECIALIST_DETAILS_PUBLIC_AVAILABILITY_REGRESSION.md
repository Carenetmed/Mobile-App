# Specialist Details Public Availability Regression

Task: 52.70

Status: Passed

## Scope

This checkpoint verifies the Specialist Details backend public-professional and
public-availability wiring added in task 52.69.

No runtime behavior is added in this slice.

## Evidence

| Requirement | Evidence | Result |
|-------------|----------|--------|
| Backend id resolution | `SpecialistDetailsShellPage` uses the passed `specialistId` and resolves it from `ProfileRepository.publicProfessionals` when profile and scheduling repositories are available | Passed |
| No public detail endpoint invention | Runtime uses the existing public listing repository; no route-specific public detail API is added | Passed |
| Safe unresolved id behavior | Focused test verifies `Backend professional could not be found.` and no local specialist fallback | Passed |
| Public availability read | Backend path calls `SchedulingRepository.publicAvailability` with the resolved public professional id | Passed |
| No local slot fallback | Focused tests verify `Saturday` and `10:00am` local slot chips are absent in backend success, availability failure, and unresolved-id states | Passed |
| Generated request payload | Focused test verifies selected request sends `professionalProfileId`, `requestedStartAt`, and `durationMinutes` from generated backend availability options | Passed |
| Safe request failure | Focused test verifies safe request error text, no raw backend error, and no fake success/local confirmation | Passed |
| Search handoff | Search public profile sheet exposes `Open details` and passes the backend public professional id into `specialistDetails` | Passed |
| Dashboard compatibility | Existing dashboard Providers -> local Specialist Details -> local booking handoff test still passes for local-only navigation | Passed |
| Deferred-work accuracy | Docs keep public detail endpoint invention, Find Mentor replacement, verification/admin, payments, reviews, calls, calendar sync, notes, prescriptions, staging data, and production release readiness deferred | Passed |

## Verification Commands

```powershell
dart format lib\features\Home\presentation\pages\search_shell.dart lib\features\Home\presentation\pages\specialist_details_shell.dart test\features\home\specialist_details_flow_test.dart
flutter test test\features\home\specialist_details_flow_test.dart -r compact
flutter test test\features\home\search_flow_test.dart -r compact
flutter test test\features\home\dashboard_shell_test.dart -r compact
flutter analyze lib\features\Home\presentation\pages\search_shell.dart lib\features\Home\presentation\pages\specialist_details_shell.dart test\features\home\specialist_details_flow_test.dart test\features\home\search_flow_test.dart test\features\home\dashboard_shell_test.dart
git diff --check
```

## Result

The Specialist Details backend path is stable for the current
frontend/backend milestone boundary.

The implementation remains intentionally constrained:

- it uses public listing data instead of inventing a public detail endpoint
- it reads public availability only for the selected backend professional id
- it sends only generated appointment request time/duration data
- it keeps local slot data out of the backend path
- it preserves local-only compatibility for older local navigation

## Next Step

Do not broaden Specialist Details automatically.

The next slice should choose the next surface deliberately from the current
deferred-work map. Candidate lanes include Find Mentor replacement, verification
upload/list planning, or another regression/staging checkpoint, but the choice
must be made in a decision slice before runtime implementation.
