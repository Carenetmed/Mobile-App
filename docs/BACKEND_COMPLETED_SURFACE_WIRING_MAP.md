# Backend Completed Surface Wiring Map

Owner task: `52.95`

Status: Updated checkpoint map

Purpose: show which already-completed backend surfaces are consumed by the
Flutter app, which completed backend surfaces are intentionally outside this
mobile app, and which gaps remain deferred. This is not a production-readiness
or Play Store readiness claim.

Backend source reviewed:

- `C:\Users\asd\Music\carenet-backend-lab\docs\05-api-plan.md`

Mobile source reviewed:

- auth/account repositories and tests
- profile repository and tests
- verification repository and Manage Profile tests
- scheduling repository, Search, Specialist Details, selectedDates, and
  Appointments tests
- `CODEBASE_STATUS.md`, `DEFERRED_WORK.md`, and recent decision/regression docs

## Decision

The patient/professional mobile-facing routes from the completed backend surface
are now either wired, regression-checked, or intentionally excluded from this
Flutter app.

Do not add phone/OTP, MFA, payments, notifications, reviews, calls, calendar
sync, medical notes, prescriptions, public demo access, production app links, or
admin verification review to this mobile app as the next runtime lane.

The next mobile-app lane should be milestone stabilization/regression unless a
new backend contract or product decision explicitly opens another mobile-facing
surface.

## Current Surface Status

| Backend surface | Backend status | Flutter status | Current decision |
| --- | --- | --- | --- |
| Health/readiness | `GET /health` and `GET /health/ready` exist | Used for developer smoke/checkpoints, not app UI | Keep as developer/staging proof only |
| Email/password auth | Register, login, refresh, logout, `GET /auth/me` exist | Email sign-in, email sign-up, session restore, logout, and current-account read are wired | Regression/stabilize only |
| Password reset | Request and token-confirm routes exist | Reset request and transient-token confirm route are wired | Production app-link smoke remains deferred |
| Email verification | Authenticated request and public token-confirm routes exist | Current-email request and transient-token confirm route are wired | Production app-link smoke remains deferred |
| Google sign-in | `POST /auth/google/sign-in` exists | Sign-in phone/email Google rows use configured `GoogleIdTokenProvider` and `AuthRepository.googleSignIn` | Regression/stabilize only |
| Google account linking | `POST /auth/google/link` exists | Account Google link uses configured provider and `AuthRepository.googleLink`; regression passed | Unlink/recovery/re-auth remain deferred |
| Phone/OTP and MFA | Explicitly unsupported/deferred in backend docs | Local draft/security screens only | Do not wire now |
| Patient self profile | `GET/PUT /patients/me` exist | Settings/Profile reads patient profile and updates backend patient name only | Age/location and local account fields remain deferred |
| Professional self profile | `GET/PUT /professionals/me` exist | Manage Profile reads profile; Add Description updates bio; edit name/category/specialty are wired under preservation rules | Profile creation, website, address remain deferred |
| Professional verification documents | Upload-init, upload-complete, document list exist | Manage Profile verification shell lists/upload documents with file picker and safe states | Admin review and advanced storage hardening remain deferred |
| Public professionals | `GET /professionals` exists | Search, Find Mentor, and Specialist Details consume backend public professionals | Public detail endpoint and broader ranking/filtering remain deferred |
| Public availability | Public verified-professional availability read exists | Search/Specialist Details read public availability and generate request options | Calendar/provider availability expansion remains deferred |
| Professional availability management | `GET/PUT /availability/me` exist | selectedDates reads/replaces own availability while preserving backend rules | Exceptions, blocked dates, buffers, capacity remain deferred |
| Appointment request/list | Protected request and own-list routes exist | Search/Specialist Details request appointments; Appointments reads own list | Auto-confirm booking remains deferred |
| Appointment lifecycle | Accept, decline, cancel, reschedule, complete routes exist | Appointments supports patient/professional cancellation, professional accept/decline, professional completion, and patient/professional reschedule | Payments, notifications, calls, notes, prescriptions, reviews, calendar sync, admin override remain deferred |
| Admin verification review | Admin queue, signed-read, approve/reject exist | Intentionally outside this mobile app by `ADMIN_VERIFICATION_REVIEW_SURFACE_BOUNDARY.md` | Separate admin dashboard/web-console lane |
| Public/stakeholder staging access | Backend supports developer-private proxy/access patterns | App can build with staging config; public demo path is not claimed | Separate release/access decision |

## Mobile-Facing Completed Backend Result

The current completed-backend mobile surface is functionally consumed for the
patient/professional app boundary:

- auth/session/account
- Google sign-in/link
- patient profile read/name update
- professional profile read/scoped edits
- professional verification upload/list
- public professional discovery
- public and own availability
- appointment request/list/lifecycle

This does not mean the full product is complete. It means the currently
completed backend surfaces that belong in this mobile app are no longer waiting
for first-pass runtime wiring.

## Intentionally Excluded From This Mobile App

- admin verification review queue
- admin signed-read document access
- admin approve/reject decisions
- admin audit/reviewer workflows

These belong to a separate admin dashboard or admin web console unless a future
decision explicitly accepts mobile admin risk.

## Still Deferred Product/Backend Modules

These are not missed mobile wiring from completed backend surfaces; they require
new backend/product contracts or production infrastructure:

- phone/OTP
- MFA/PIN persistence
- Google unlinking
- cross-email/recovery linking
- recent re-authentication
- payments/refunds/payouts
- notifications/reminders/push delivery
- reviews/ratings
- calls/video/audio
- calendar provider sync
- consultation notes
- prescriptions/medical records
- messaging backend/realtime transport
- community backend
- content/publishing backend
- production app links
- public/stakeholder staging access
- release signing and store readiness

## Next

Queue a mobile milestone stabilization/regression lane.

Recommended next slice:

`52.96 - Define Mobile Backend Integration Stabilization Plan`

Goal:

- select a focused regression/stabilization plan for the already-wired backend
  mobile surfaces
- choose which grouped test suites and manual smoke checks prove the milestone
- update stale status/deferred docs if needed
- do not add new runtime features

## Non-Claims

This document does not claim:

- the whole product is complete
- the app is production-ready
- Play Store/App Store readiness is complete
- public staging access is complete
- admin dashboard work is complete
- deferred modules are available
