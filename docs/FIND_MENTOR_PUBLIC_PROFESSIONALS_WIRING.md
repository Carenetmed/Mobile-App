# Find Mentor Public Professionals Wiring

Task: 52.72

Status: Done

## Scope

`findMentor` now uses `ProfileRepository.publicProfessionals` when a profile
repository is available. The backend-capable path renders public verified
professionals, supports category/specialty filtering, and passes the selected
backend public professional id into `specialistDetails`.

The old local mentor cards remain only for local-only test/dev navigation when
no `ProfileRepository` is registered or injected.

## Runtime behavior

- Shows a safe loading state while public professionals load.
- Shows a safe empty state when the backend returns no public professionals.
- Shows safe generic errors for backend/network/server failures without raw
  backend text.
- Does not fall back to seeded local mentors after a backend failure.
- Does not show seeded local slot chips in the backend path.
- `View details` navigates to `specialistDetails` with the backend public
  professional id.
- Direct booking is disabled in the backend path and remains routed through
  Specialist Details, where public availability and appointment request behavior
  are already scoped.

## Explicitly not added

- No invented public professional detail endpoint.
- No local slot fallback in the backend path.
- No fake direct booking success from Find Mentor.
- No verification upload/list behavior.
- No admin dashboard behavior.
- No payments, refunds, reviews, calls, calendar sync, notes, prescriptions, or
  staging seed data.
- No production readiness claim.

## Verification

- `flutter test test/features/home/find_mentor_flow_test.dart -r compact`
- `flutter test test/features/home/dashboard_shell_test.dart test/features/home/specialist_details_flow_test.dart -r compact`
- `flutter analyze lib/features/Home/presentation/pages/find_mentor_shell.dart test/features/home/find_mentor_flow_test.dart test/features/home/dashboard_shell_test.dart test/features/home/specialist_details_flow_test.dart`

## Next

Run `52.73` as a focused regression checkpoint before selecting another
backend-completed Flutter surface.
