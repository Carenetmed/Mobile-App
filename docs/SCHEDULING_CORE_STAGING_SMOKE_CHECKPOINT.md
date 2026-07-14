# Scheduling Core Staging Smoke Checkpoint

Task: 52.59

Date: 2026-07-15

## Scope

This checkpoint records what could be honestly proven against the staging
backend through the developer-private Cloud Run proxy and a staging-configured
Flutter build.

No runtime feature behavior was added in this slice.

## Environment

Local proxy URL:

```text
http://127.0.0.1:8080
```

Flutter staging config key:

```text
CARENET_API_BASE_URL
```

## Proven

### Backend Reachability

`GET /health` through the local proxy returned:

```json
{
  "status": "ok",
  "service": "carenet-backend"
}
```

`GET /health/ready` through the local proxy returned:

```json
{
  "status": "ok",
  "service": "carenet-backend",
  "checks": {
    "database": "ok",
    "migrations": "ok",
    "providers": {
      "email": "ok",
      "googleAuth": "ok",
      "verificationStorage": "disabled"
    }
  }
}
```

Interpretation:

- staging backend is reachable through the developer-private proxy
- database and migrations are ready
- email and Google auth providers are ready
- verification storage remains disabled

### Public Scheduling Data

`GET /professionals` through staging returned an empty list.

Interpretation:

- the public professional listing route is reachable
- there are currently no verified public professionals available for frontend
  scheduling smoke
- public availability and appointment request cannot be honestly smoked without
  a verified professional/profile/availability data setup

### Protected Scheduling Guards

Unauthenticated staging checks returned `401`:

- `GET /appointments`
- `GET /availability/me`

Interpretation:

- protected scheduling routes reject unauthenticated access
- authenticated patient/professional scheduling smoke still requires staging
  accounts and role/profile setup

### Flutter Build

The staging-configured Android debug build succeeds:

```powershell
flutter build apk --debug --dart-define=CARENET_API_BASE_URL=http://127.0.0.1:8080
```

Output artifact:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

### Local Regression Still Passes

Focused scheduling tests pass:

```powershell
flutter test test/features/home/appointment_request_time_options_test.dart test/features/home/appointments_flow_test.dart test/features/home/scheduling_repository_test.dart -r compact
```

Focused scheduling analyze passes:

```powershell
flutter analyze lib/core/config/carenet_api_config.dart lib/features/Home/data/services/scheduling_api_client.dart lib/features/Home/data/repositories/scheduling_repository.dart lib/features/Home/presentation/pages/search_shell.dart lib/features/Home/presentation/pages/appointments_shell.dart lib/features/Home/presentation/pages/selected_dates_shell.dart test/features/home/scheduling_repository_test.dart test/features/home/search_flow_test.dart test/features/home/appointments_flow_test.dart
```

## Not Proven

These paths were not staging-smoked because the required staging users/data are
not present in the repo and should not be faked inside Flutter:

- patient registration/login into a scheduling smoke account
- professional registration/login into a scheduling smoke account
- verified public professional listing with at least one approved professional
- public availability for a verified professional
- patient appointment request against staging availability
- own appointment list with real staging appointments
- patient cancellation against a real staging appointment
- professional accept/decline against a real staging appointment
- professional completion against a real staging appointment
- patient/professional reschedule against a real staging appointment
- professional own availability read/replace with a staging professional

## Blockers

To fully smoke the scheduling core end to end, staging needs deliberate test
data or test accounts:

- patient staging account credentials
- professional staging account credentials
- professional profile verified/approved for public listing
- professional availability windows
- appointment seed or a safe way to create one through the app/backend
- clear rule on whether staging smoke may create disposable users and
  appointments

## Decision

The Flutter scheduling core is locally regression-proven and the staging backend
is reachable, but the scheduling core is not yet end-to-end staging-proven.

Next work should either:

- create/approve a dedicated staging test-data setup for scheduling smoke, or
- move to another backend-completed surface while keeping scheduling smoke
  blocked on staging data.

Do not claim scheduling is production-ready or Play Store-ready from this
checkpoint alone.
