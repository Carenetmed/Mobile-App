# Backend completed surface wiring map

Owner task: `52.17`

Status: Accepted decision map

Purpose: show which already-completed backend surfaces are ready for frontend
wiring, which app surfaces already consume them, and which wiring slices should
come next. This is a frontend planning document, not a backend production
readiness claim.

Backend source reviewed:

- `C:\Users\asd\Music\carenet-backend-lab\docs\05-api-plan.md`
- `C:\Users\asd\Music\carenet-backend-lab\docs\24-appointment-core-regression-plan.md`
- `C:\Users\asd\Music\carenet-backend-lab\docs\25-auth-frontend-integration-contract.md`
- `C:\Users\asd\Music\carenet-backend-lab\docs\36-frontend-backend-staging-contract.md`
- `C:\Users\asd\Music\carenet-backend-lab\docs\45-frontend-backend-staging-integration-readiness.md`
- `C:\Users\asd\Music\carenet-backend-lab\docs\48-auth-session-frontend-bridge-package.md`
- `C:\Users\asd\Music\carenet-backend-lab\docs\49-frontend-auth-integration-handoff-to-app-repo.md`

## Decision

Do not start phone OTP, MFA, payments, notifications, reviews, calls,
prescriptions, medical notes, public demo access, or production app-link work as
the next runtime lane.

The next frontend integration lane should consume already-completed backend
surfaces in this order:

1. Finish the auth/account frontend checkpoint against the staging bridge.
2. Wire professional/public profile and verification-readable surfaces.
3. Wire availability and appointment lifecycle surfaces in small batches.
4. Keep admin verification dashboard, phone/OTP, MFA, and production/public
   access as separate later lanes.

This order reduces rework because auth/session and API configuration are the
shared base for every protected backend route.

## Current backend-completed surface

| Backend surface | Backend status from reviewed docs | Frontend status | Wiring estimate |
| --- | --- | --- | --- |
| Health/readiness | `GET /health` and `GET /health/ready` exist for liveness/readiness proof | Not wired in app UI; useful for developer smoke only | 1 small smoke/checkpoint slice |
| Email/password auth | Register, login, refresh, logout, and `GET /auth/me` exist | Email sign-in, email sign-up, restore, logout, and current account read are wired | Mostly complete; keep regression and staging smoke |
| Email verification and password reset | Request and token-confirm routes exist; staging email can deliver internal links | Request and transient-token confirm routes are wired; production app-link entry is deferred | 1-2 slices for app-link/manual staging smoke if needed |
| Google auth | `POST /auth/google/sign-in` and `POST /auth/google/link` exist | Social buttons remain disabled | 2-4 slices if Google frontend package/config is ready; otherwise defer |
| Phone/OTP and MFA | Explicitly unsupported/deferred in backend docs | Local draft screens only | Do not wire now |
| Patient self profile | Patient self read/update routes are listed in backend API plan | App account/profile screens are still mostly local/draft | 2-3 slices after auth checkpoint |
| Professional self profile | Professional self read/update routes are listed in backend API plan | Manage Profile/Public Profile are local/draft | 3-5 slices with profile repository boundary |
| Professional verification documents | Professional upload-init, upload-complete, and document list routes exist | No mobile upload/list wiring yet | 3-5 slices; needs file picker/storage UX decisions |
| Public professionals | Public verified professional listing exists | Search/find mentor/specialist pages use local stores | 2-4 slices to replace discovery list/detail reads |
| Public availability | Public verified-professional availability read exists | Specialist details uses local day/time chips | 2-3 slices after public professionals |
| Professional availability management | `GET /availability/me` and `PUT /availability/me` exist | Selected Dates/Manage Profile business hours remain local drafts | 3-5 slices |
| Appointment request/list | Protected patient request and own list routes exist | Appointment/booking screens are local draft state | 3-5 slices |
| Appointment accept/decline/cancel/reschedule/complete | Protected lifecycle routes exist with state rules and audit behavior | No live lifecycle wiring yet | 5-8 slices after list/request wiring |
| Admin verification review | Admin queue, signed-read, approve/reject routes exist | Mobile app has no admin dashboard wiring | Later separate admin-dashboard lane |
| Public/stakeholder staging access | Backend supports developer-private Cloud Run Proxy only | App can be configured for local/proxy development, not public demo | Separate access/release decision |

## Remaining frontend wiring from completed backend only

This excludes new backend product modules and excludes production release work.

| Scope | Approximate frontend slices remaining |
| --- | --- |
| Auth/account only | 3-6 |
| Professional profile, verification, and public professional discovery | 7-12 |
| Availability and appointment lifecycle | 8-14 |
| Regression/staging smoke/docs around those lanes | 4-6 |
| Total to consume completed backend surfaces in the mobile app | 22-38 |

The earlier 18-30 estimate is still plausible if some UI slices are combined,
but the safer planning range is 22-38 because verification upload and
appointment lifecycle should not be rushed into oversized slices.

## Next frontend slice

Queue:

`52.18 - Auth/account staging smoke and remaining-backend checkpoint`

Goal:

- verify the already-wired auth/session/account frontend boundary still matches
  the backend staging bridge
- document exact environment/base URL setup for developer-private Cloud Run
  Proxy
- identify whether Google sign-in/link is ready for frontend runtime wiring or
  should stay deferred
- do not start profile, verification, availability, or appointment wiring until
  this shared base is stable

## Stop conditions

Stop and ask before implementation if:

- a real-device/public staging access model is required
- production app links or custom domains are required
- Google frontend package/config decisions are missing
- a route contract is not present in backend docs
- wiring would require phone/OTP, MFA, payments, notifications, reviews, calls,
  calendar sync, medical notes, prescriptions, or admin dashboard behavior

## Non-claims

This document does not claim:

- full frontend/backend wiring is complete
- the backend is production-ready
- public/stakeholder staging access is ready
- phone/OTP, MFA, Google unlinking, payments, notifications, reviews, calls,
  calendar sync, prescriptions, or medical records are ready
- admin verification dashboard wiring belongs in the mobile app
