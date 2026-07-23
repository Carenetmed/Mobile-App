# Phase 1 Find Care Contract

Slice: `APP-P1-004 - Canonical Find Care Discovery`

## Canonical path

The patient discovery path is:

`Patient Home or Find Care tab -> RouteName.search -> SearchShellPage -> RouteName.specialistDetails`

Patient Home selects the existing persistent Find Care tab. The bottom destination
already owns `SearchShellPage` through the dashboard `IndexedStack`, so query and
loaded results survive normal tab changes. `RouteName.findMentor` is retained only
as a compatibility alias and resolves to `SearchShellPage`. The legacy mentor source
is preserved for later cleanup but is not a competing routed marketplace.

## Backend authority

Find Care calls:

```dart
Future<List<PublicProfessional>> publicProfessionals()
```

exactly once on initial load. The repository performs `GET /professionals` without
query parameters. The server returns verified professionals ordered by display name
and id. The Flutter client does not change this API contract.

Accepted public fields are:

- `id`
- `displayName`
- `category`
- optional `specialty`
- optional `bio`
- `verified`

Find Care omits entries unless `verified == true` and id, display name, and category
are non-empty. It does not infer verification from completeness, category, or route.

## Supported discovery

The loaded list can be filtered locally, case-insensitively, by:

- display name
- category/professional type
- specialty

The query is trimmed. Bio does not participate in matching. Clearing the query
restores the full accepted listing. Category/specialty chips also filter only the
already loaded list and do not pretend to be backend parameters.

The current backend does not support discovery parameters for:

- symptoms, conditions, diseases, or health concerns
- location
- language
- consultation mode
- fee
- availability
- verification
- ratings or reviews
- pagination

CareNet must not diagnose users or create a client-only medical mapping. A future
symptom/condition experience requires a reviewed backend-owned clinical catalog and
professional-category mapping.

## UI state contract

- Initial load shows a dedicated loading state.
- Initial failure shows a safe error and Retry; no professional fallback is shown.
- A successful empty backend list shows a dedicated directory-empty state.
- A non-empty list with no query matches shows a separate filtered-empty state.
- Refresh preserves the current query.
- Refresh failure keeps the last successful list visible, reports the failure, and
  offers Retry.
- Repeated load actions share the active request rather than starting duplicates.
- A generation guard prevents an older completion replacing a newer accepted load.
- Disposal invalidates pending completions before any state update.

Raw backend exceptions are not displayed.

## Result cards and selection

Cards show only backend-supported identity fields: display name, category, optional
specialty, optional bio, and verified presentation when `verified == true`. When bio
is absent the layout omits it. The generic icon is presentation, not a fabricated
profile image.

Cards do not fabricate image, fee, rating, reviews, location, experience,
consultation mode, availability, response time, or patient count.

Selecting a card pushes `RouteName.specialistDetails` with the exact backend
professional id. Find Care does not load availability, build request times, submit
appointments, or open a duplicate booking sheet.

## APP-P1-005 handoff

APP-P1-005 completed the canonical detail and request boundary. Specialist Details:

- calls `GET /professionals/:professionalProfileId` directly;
- loads backend-generated requestable times without client recurrence generation;
- preserves the exact backend professional ID;
- fails closed without local or seeded fallback;
- resumes an account-bound booking intent through authentication and patient setup;
- submits with `Idempotency-Key` and preserves backend `REQUESTED` semantics.

The full contract is in `PHASE_1_PROFESSIONAL_DETAIL_BOOKING.md`. Payments, calls,
messaging, ratings/reviews, and broader appointment presentation remain separate.

## Cleanup boundary

`FindMentorShellPage`, `SearchLocalStore`, `BookAppointmentShellPage`, and legacy
local profile sources remain recoverable, but their route constants resolve to
canonical Find Care or fail closed. Delete source only in the later cleanup
milestone after retained Phase 1 regression proof.
