# Phase 1 Marketplace Home

Slice: `APP-P1-003`

The authenticated Home is a role-aware summary of backend-owned marketplace
state. It is not a feed, feature directory, analytics dashboard, or source of
appointment authority.

## Data contract

| Home concern | Authoritative source |
|---|---|
| Role | Persisted authenticated `SessionStore` user role in `Dashboard` |
| Patient identity | `ProfileRepository.patientMe()` |
| Professional identity | `ProfileRepository.professionalMe()` |
| Profile/application/verification readiness | `OnboardingRepository.accountReadiness()` |
| Own appointment summaries | `SchedulingRepository.ownAppointments()` |
| Professional availability presence | `SchedulingRepository.ownAvailability()` |

The Home coordinator loads these independent sources concurrently. A failed
optional section does not discard successful sections. Errors are represented
with safe retry states and never expose raw exceptions.

## Patient contract

- Show the backend patient name when available.
- Keep Find Care as the primary action and reuse the existing dashboard tab.
- Show profile setup only when backend readiness reports incomplete patient
  setup.
- Surface the earliest pending request and nearest future accepted appointment.
- When appointment loading succeeds with no relevant results, show an honest
  no-appointments state and Find Care action.
- Never show invented recommendations, payments, calls, messages, or unread
  counts.

## Professional contract

- Show the backend professional display name when available.
- Derive profile and verification guidance from account readiness, with the
  professional self-profile verification status used only as a safe display
  fallback.
- Surface the earliest pending appointment request and nearest future accepted
  appointment.
- Show missing availability only after the owner availability request succeeds
  and contains no active windows.
- Keep Schedule and Appointments as existing dashboard destinations.
- Never show invented demand, earnings, payouts, messages, calls, or payment
  state.

## Deterministic selection

1. Pending appointment: `REQUESTED`, sorted by `requestedStartAt`, then `id`.
2. Upcoming appointment: future `ACCEPTED`, sorted by `requestedStartAt`, then
   `id`.
3. Patient action priority: incomplete profile, pending request, upcoming
   appointment, Find Care.
4. Professional action priority: incomplete profile, verification submission or
   review state, pending request, no active availability, upcoming appointment.
5. `PENDING` or `UNDER_REVIEW` verification is informational and does not create
   a false action.

Declined, cancelled, completed, unknown, and past accepted appointments do not
become Home priority cards.

## Known limitations

- Appointment summaries do not contain participant display names, consultation
  type, payment state, messaging eligibility, or call eligibility. Home therefore
  shows only truthful schedule and status information.
- Home does not fetch an aggregate endpoint; it composes existing owner endpoints.
- Availability is used only to determine whether an active owner window exists.
  It does not duplicate schedule editing.
- Messaging, calls, payments, notification delivery, and appointment detail
  remain separate slices.

## Next slice

`APP-P1-004 - Canonical Find Care And Professional Detail`
