# Profile and public professional frontend contract

**Task:** 52.23
**Status:** Accepted contract before runtime wiring

Purpose: define how the Flutter app should consume the backend profile and
public professional surfaces without guessing screen behavior or exposing
private data.

This is a contract/planning slice. It does not add runtime profile wiring.

---

## Backend Sources Reviewed

- `C:\Users\asd\Music\carenet-backend-lab\docs\05-api-plan.md`
- `C:\Users\asd\Music\carenet-backend-lab\docs\45-frontend-backend-staging-integration-readiness.md`
- `docs\BACKEND_COMPLETED_SURFACE_WIRING_MAP.md`
- `docs\AUTH_ACCOUNT_STAGING_CHECKPOINT.md`
- `docs\FRONTEND_BACKEND_INTEGRATION_CHECKPOINT.md`

---

## Accepted Backend Surface

| Surface | Route | Auth | Accepted frontend use |
| --- | --- | --- | --- |
| Patient self profile read | `GET /patients/me` | `PATIENT` JWT | Read current patient's own profile after session restore/sign-in |
| Patient self profile create/update | `PUT /patients/me` | `PATIENT` JWT | Save allowed patient profile fields only |
| Professional self profile read | `GET /professionals/me` | `PROFESSIONAL` JWT | Read current professional's own profile |
| Professional self profile create/update | `PUT /professionals/me` | `PROFESSIONAL` JWT | Save allowed public-facing professional profile fields only |
| Public verified professional listing | `GET /professionals` | Public | Replace local search/find-mentor listing data with backend verified professionals |

`GET /professionals/:id` is listed as future public detail work. Do not wire a
public professional detail read until the backend route exists and is documented.

---

## Allowed Fields

Patient self update fields:

- `name`
- `age`
- `location`

Patient rules:

- requires authenticated `PATIENT`
- reads/writes only the current user's own patient profile
- first profile creation requires `name`
- no public patient profile route exists
- do not expose password, session, or audit data

Professional self update fields:

- `displayName`
- `category`
- `specialty`
- `bio`

Professional rules:

- protected self routes require authenticated `PROFESSIONAL`
- reads/writes only the current user's own professional profile
- first profile creation requires `displayName` and `category`
- professionals cannot self-set `verificationStatus`
- public listing returns only backend-verified professionals

Public professional listing fields:

- `id`
- `displayName`
- `category`
- `specialty`
- `bio`
- `verified: true`

Public professional responses must not expose account email/status, password or
refresh-session state, verification documents or metadata, file URLs, signed
URLs, audit logs, admin-only notes/actions, or private patient data.

---

## Flutter Boundaries

Add profile data behind a repository boundary instead of wiring screens
directly to `Dio`.

Recommended files for the first implementation slice:

- `lib/features/Home/data/services/profile_api_client.dart`
- `lib/features/Home/data/repositories/profile_repository.dart`
- `lib/features/Home/domain/entities/patient_profile.dart`
- `lib/features/Home/domain/entities/professional_profile.dart`
- `lib/features/Home/domain/entities/public_professional.dart`
- focused tests under `test/features/home/`

The repository should use the existing `SessionStore` and bearer-token pattern.
Do not accept client-supplied user id, patient profile id, professional profile
id, role, verification status, account email, or document metadata for self
profile mutations.

---

## Screen Mapping

| Existing Flutter surface | Contract decision |
| --- | --- |
| `account` | May read current account identity from `AccountRepository`; patient profile fields should be separate from auth account fields |
| `manageProfile` | Professional self profile is the best first screen to wire when the signed-in role is `PROFESSIONAL`; keep unavailable fields local/disabled |
| `editYourName`, `editYourWebsite`, `setAddress`, `addDescription` | Do not wire all existing local draft fields at once; only fields matching backend allowed fields can be saved |
| `publicProfile` | Keep local/read-only until public detail route exists; do not fake `GET /professionals/:id` |
| `search`, `findMentor`, `specialistDetails` | Public listing can replace list cards; specialist detail must either use selected-listing data or stay local until public detail exists |
| `selectedDates` | Availability is a separate lane; do not mix profile update with availability management |

---

## Error And State Rules

Use safe user-facing messages:

- missing backend config: `Backend is not configured yet.`
- unauthenticated/expired session: `Please sign in again.`
- validation failure: `Please check the details and try again.`
- server unavailable: `Service is unavailable. Please try again.`
- network/unknown: `Something went wrong. Please try again.`

`404` on self profile read means "profile has not been created yet", not a
broken account. The UI should show an editable empty state for the matching
role when the implementation slice reaches that screen.

---

## Deferred Work

Keep these out of the first profile runtime slice:

- verification document upload/list
- admin verification dashboard
- public professional detail route
- full search/ranking/filtering
- availability read/manage
- appointment request/lifecycle
- payments, payouts, refunds
- reviews/ratings
- calls/video/audio
- notifications/reminders
- calendar sync
- consultation notes, prescriptions, medical records
- public/stakeholder staging access
- production profile moderation/compliance workflows

---

## Recommended Next Slice

`52.24 - Add Profile Repository Boundary`

Scope:

- add API client/repository/entities for patient self, professional self, and
  public professional listing
- add focused tests for safe headers, 404 empty-profile handling, allowed field
  payloads, and safe public projection parsing
- do not wire screens yet except through tests
- keep verification upload, availability, appointment lifecycle, public detail,
  and profile moderation out of scope

Then follow with one runtime screen slice:

`52.25 - Wire Professional Self Profile Read To Manage Profile`

Only after the repository boundary is proven.
