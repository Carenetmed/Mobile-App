# Product & technical decisions

**Purpose:** Preserve accepted product and technical decisions so future work
does not silently reinterpret established boundaries.

| ID | Date | Topic | Decision | Affects |
|----|------|-------|----------|---------|
| D001 | 2026-05-15 | Sign-up Continue validation | Use basic client-side validation on sign-up phone/email before navigation; only valid input may proceed to `finishSignUp` | Flow A, task 2.1 |
| D002 | 2026-05-15 | Social auth availability | Google, Facebook, and Apple sign-up options stay explicitly disabled until backend/auth provider integration exists; do not add placeholder navigation or fake success flows | Flow A, task 2.3 |
| D003 | 2026-05-19 | Password recovery flow | Use the blueprint `enter-email` and `enter-password` screens for `Forgot Password?`; successful password reset returns the user to `signInEmail` until backend auth exists | Flow B, task 3.2 |
| D004 | 2026-05-19 | Podcast notification handling | Keep podcast notifications read-only until the later content phase instead of adding a shallow shell during Phase 5 messaging/notification cleanup | Flow D, task 5.9 |
| D005 | 2026-05-19 | Readings export sequencing | Keep `Download Readings` explicitly deferred until the add-reading/device flow exists; Phase 6 should build readings capture/onboarding before export | Flow E, task 6.2 |
| D006 | 2026-05-23 | Articles scope boundary | Stop the articles lane after local list/detail plus saved/read state; move to the next blueprint-backed route before inventing deeper content/account logic | Flow H, task 9.3 |
| D007 | 2026-05-27 | Communities scope boundary | Stop the communities lane after local discover/join, profile, and create flows; defer invitation acceptance, delivery, media upload, posting, and moderation until backend-backed community workflows exist | Flow I, task 10.5 |
| D008 | 2026-05-27 | Q&A scope boundary | Stop the Q&A lane after local ask plus answer-request/tagged-question/comment flows; defer the blueprint `q-a-post` composer until a later phase defines real feed distribution, audience, and mixed post-vs-question rules | Flow J, task 11.3 |
| D009 | 2026-05-27 | Account scope boundary | Stop the account lane after local account, delete/deactivate, and settings/profile edit flows; defer public profile surfaces, change-authentication security flows, scheduling, support, and creator/public identity screens until those domains get their own backend-backed decisions | Flow K, task 12.3 |
| D010 | 2026-05-27 | Podcast scope boundary | Stop the podcast lane after local list and watch-state behavior; defer streaming playback, episode APIs, comments, uploads/recording, saved-to-account sync, and search filtering until backend/media/content rules exist | Flow L, task 13.2 |
| D011 | 2026-05-27 | Search scope boundary | Stop the search lane after local consultant discovery, profile sheet, and local request state; defer live availability, appointment time/type selection, payment, real booking, and provider-profile APIs until backend/product rules exist | Flow M, task 14.2 |
| D012 | 2026-05-27 | Health record scope boundary | Stop the health-record lane after local vitals summary and readings-store blood sugar sync; defer backend health history, report export/download, and additional synced vital types until backend/API rules exist | Flow N, task 15.2 |
| D013 | 2026-05-30 | Saved/content-library scope boundary | Stop the saved/content-library lane after the local saved articles route; defer `published-articles`, `subscribers`, `article-story`, drafts, creator publishing, author/publication analytics, account sync, comments, and content APIs until creator/content backend rules exist | Flow O, task 16.2 |
| D014 | 2026-05-30 | Case studies scope boundary | Stop the case-studies lane after local list/filter/detail/read-state behavior; defer content APIs, verified clinical review, author/publication records, comments, sharing, saved-to-account sync, and moderation until content/backend rules exist | Flow P, task 17.2 |
| D015 | 2026-05-30 | Public profile scope boundary | Stop the public-profile lane after local read-only profile content plus real message/schedule handoffs; defer profile APIs, creator portfolio, media/podcast profile content, product-approved sharing, provider scheduling, verified public identity, public reviews/testimonies, and subscription/upgrade behavior until backend/product rules exist | Flow Q, task 18.2 |
| D016 | 2026-05-30 | Owner circle scope boundary | Stop the owner-circle lane after the local owner profile and locked settings surface; defer permissions, member invitations, role changes, moderation, editing circle details, sharing, favourites sync, reporting, exiting, and destructive circle deletion until backend/community-management and product safety rules exist | Flow R, task 19.2 |
| D017 | 2026-05-30 | Manage profile scope boundary | Stop the manage-profile lane after the local profile-management summary plus settings/messages handoffs; defer profile update APIs, business schedule persistence, event management, ads/boosting, payment/ad-review rules, media/podcast management, sharing rules, member management, group-detail persistence, and creator verification until backend/product contracts exist | Flow S, task 20.2 |
| D018 | 2026-06-03 | Manage portfolio scope boundary | Stop the manage-portfolio lane after the local Page/Circles portfolio surface plus settings/messages handoffs; defer article publishing, podcast upload/recording, media processing, creator portfolio APIs, ads/boosting, subscription upgrades, payment setup, moderation, analytics, and product-approved sharing until backend/product contracts exist | Flow T, task 21.2 |
| D019 | 2026-06-03 | Change authentication scope boundary | Stop the change-authentication lane after the local two-step verification information route; defer PIN creation/confirmation, disabling two-step verification, password re-authentication, secure PIN storage, device/session checks, audit logs, phone/email verification, and product-approved security help until auth backend/product contracts exist | Flow U, task 22.2 |
| D020 | 2026-06-03 | Add phone number scope boundary | Stop the add-phone-number lane after the local phone-entry draft and validation surface; defer OTP/SMS delivery, code verification, phone uniqueness checks, password re-authentication, rate limiting, account-session updates, recovery rules, and account persistence until auth backend/provider contracts exist | Flow V, task 23.2 |
| D021 | 2026-06-03 | Password scope boundary | Stop the password lane after the local password security information route; defer password editing, current-password verification, password policy enforcement, code confirmation, session invalidation, recovery/security notifications, and account persistence until auth backend/provider contracts exist | Flow W, task 24.2 |
| D022 | 2026-06-03 | Add email scope boundary | Stop the add-email lane after the local email-entry draft and validation surface; defer verification email delivery, code confirmation, email uniqueness checks, password re-authentication, rate limiting, account-session updates, recovery/security notifications, and account persistence until auth backend/provider contracts exist | Flow X, task 25.2 |
| D023 | 2026-06-03 | Change email scope boundary | Stop the change-email lane after the local change-email draft and validation surface; defer verification-code delivery, code confirmation, email uniqueness checks, password re-authentication, rate limiting, account-session updates, recovery/security notifications, and account persistence until auth backend/provider contracts exist | Flow Y, task 26.2 |
| D024 | 2026-06-03 | Edit email scope boundary | Stop the edit-email lane after the local current-email management route; defer email removal, password re-authentication, recovery rules, account-session updates, audit/security notifications, and account persistence until auth backend/provider contracts exist | Flow Z, task 27.2 |
| D025 | 2026-06-03 | Enter password to save scope boundary | Stop the enter-password-to-save lane after the local password-entry validation route; defer real password verification, session/device checks, rate limiting, audit/security notifications, account mutation unlocks, and account persistence until auth backend/provider contracts exist | Flow AA, task 28.2 |
| D026 | 2026-06-03 | Confirm phone number scope boundary | Stop the confirm-phone-number lane after the local phone confirmation draft; defer OTP/SMS delivery, code confirmation, phone uniqueness checks, session updates, rate limiting, audit/security notifications, and account persistence until auth backend/provider contracts exist | Flow AB, task 29.2 |
| D027 | 2026-06-03 | Turn on authentication scope boundary | Stop the turn-on-authentication lane after the local two-step verification review route; defer PIN creation, secure PIN storage, session/device checks, audit/security notifications, recovery rules, and account persistence until auth backend/provider contracts exist | Flow AC, task 30.2 |
| D028 | 2026-06-03 | Create PIN scope boundary | Stop the create-pin lane after local 6-digit PIN format validation; defer PIN confirmation, secure PIN storage, session/device checks, audit/security notifications, account persistence, and recovery rules until auth backend/provider contracts exist | Flow AD, task 31.2 |
| D029 | 2026-06-08 | Confirm PIN Save scope boundary | Stop the confirm-pin-save lane after route-local PIN confirmation; defer secure PIN storage, session/device checks, audit/security notifications, recovery rules, account persistence, and enabling two-step verification until auth backend/provider contracts exist | Flow AE, task 32.2 |
| D030 | 2026-06-08 | Reminder scope boundary | Stop the reminder lane after the selectable calendar and date-specific empty state; defer reminder records, persistence/API ownership, recurrence/timezone rules, notification delivery, permission behavior, edit/delete rules, and failure states until backend/provider/product contracts exist | Flow AF, task 33.2 |
| D031 | 2026-06-08 | Schedules scope boundary | Stop the schedules lane after the selectable calendar and read-only expandable task-reminder card; defer schedule CRUD, recurrence/timezone calculations, live countdowns, persistence/API ownership, sharing/deep links, reminder delivery, permission behavior, and failure states until backend/provider/product contracts exist | Flow AG, task 34.2 |
| D032 | 2026-06-08 | Selected dates scope boundary | Stop the selected-dates lane after the validated route-local business-hours draft; defer profile/business-hours persistence, timezone rules, overlapping-hours validation, multiple hour sets, upgrade entitlements, server conflict handling, and availability APIs until backend/product contracts exist | Flow AH, task 35.2 |
| D033 | 2026-06-08 | Community invitations/discover scope boundary | Stop the community-invitations-discover lane after local For you, Requests, and Drafts tab behavior plus seeded invitation acceptance into joined-community state; defer invitation delivery, rejection, approval workflows, draft persistence, invite permissions, moderation, and backend membership sync until community-management contracts exist | Flow 36, task 36.2 |
| D034 | 2026-06-08 | Find mentor scope boundary | Stop the find-mentor lane after local mentor discovery and handoff to the existing booking form; defer live availability, mentor/profile APIs, detailed reviews, pricing/payment rules, booking confirmation, provider calendar sync, and cancellation policy until backend/product contracts exist | Flow AJ, task 37.2 |
| D035 | 2026-06-08 | Specialist details scope boundary | Stop the specialist-details lane after local provider info, day/time chip selection, selected-slot summary, and booking-form handoff; defer live availability, review details, payment/pricing enforcement, provider profile APIs, confirmed booking slots, calendar sync, and cancellation/error states until backend/product contracts exist | Flow AK, task 38.2 |
| D036 | 2026-06-08 | Remaining route triage after specialist details | After `/specialist-details`, skip component/demo/grid/marketing routes in the tail of `routes.json`; resume product work at `/published-articles` as the next honest creator/content surface, before payment/subscription/ad/media-upload routes | Flow AL, task 39.1 |
| D037 | 2026-06-08 | Published articles frontend scope | Implement `/published-articles` as a local creator/content review surface only: list locally known portfolio articles, open in-page detail, and show deferred Request/Drafts states; do not fake edit, publish, delete, comments, analytics, subscriber access, draft persistence, moderation, or content APIs | Flow AM, task 40.1 |
| D038 | 2026-06-08 | Published articles scope boundary | Stop the published-articles lane after local list/detail review and deferred Request/Drafts states; defer subscribers, article-story, add-new-article, persisted drafts, edit/publish/delete, comments, analytics, moderation, subscriber access, account sync, and creator content APIs until backend/product contracts exist | Flow AM, task 40.2 |
| D039 | 2026-06-08 | Route triage after creator/content cluster | After `/published-articles`, skip subscribers, article-story, add-new-article, subscription, ad, payment, media upload/recording, component, grid, and marketing/web routes unless contracts exist; resume product work at `/edit-your-name` as the first Manage Profile basic-info draft route that can stay honest locally | Flow AN, task 41.1 |
| D040 | 2026-06-08 | Edit your name frontend scope | Implement `/edit-your-name` as a Manage Profile basic-info draft route only: validate a local name entry and show a prepared draft summary; do not mutate profile state, account identity, verification status, or backend profile records | Flow AO, task 42.1 |
| D041 | 2026-06-08 | Edit your name scope boundary | Stop the edit-your-name lane after local validation and draft summary; defer profile name persistence, account identity sync, verification status changes, audit/security records, conflict handling, and backend profile APIs until product/backend contracts exist | Flow AO, task 42.2 |
| D042 | 2026-06-08 | Edit your website frontend scope | Implement `/edit-your-website` as a Manage Profile basic-info draft route only: validate a local website/domain entry and show a prepared draft summary; do not mutate profile state, verification status, account sync, or backend profile records | Flow AP, task 43.1 |
| D043 | 2026-06-08 | Edit your website scope boundary | Stop the edit-your-website lane after local validation and draft summary; defer profile website persistence, verification status changes, account identity sync, audit/security records, conflict handling, and backend profile APIs until product/backend contracts exist | Flow AP, task 43.2 |
| D044 | 2026-06-08 | Add description frontend scope | Implement blueprint `/add-desicription` as a Manage Profile About draft route only: reuse the shared multiline text field, validate local profile copy, and show a prepared draft summary; do not mutate profile state, publish public claims, run moderation, or call backend profile APIs | Flow AQ, task 44.1 |
| D045 | 2026-06-09 | Add description scope boundary | Stop the add-description lane after local validation and draft summary; defer profile-copy persistence, moderation/compliance review for public medical claims, public profile publishing, account identity sync, audit/security records, conflict handling, and backend profile APIs until product/backend contracts exist | Flow AQ, task 44.2 |
| D046 | 2026-06-09 | Manage Profile route triage after add description | After `/add-desicription`, skip `/edit-your-email` because account/security email routes already cover email review/change/verification drafts, skip `/add-time-and-day` because `selectedDates` already covers local business-hours drafting, and resume frontend-ready profile work at `/set-address` as a local address draft route | Flow AR, task 45.1 |
| D047 | 2026-06-09 | Set address frontend scope | Implement blueprint `/set-address` as a Manage Profile Basic draft route only: validate a local address/location text value and show a prepared draft summary; do not mutate profile state, save an address, geocode/map the location, request device location, or call backend profile APIs | Flow AS, task 46.1 |
| D048 | 2026-06-09 | Set address scope boundary | Stop the set-address lane after local validation and draft summary; defer profile-address persistence, location/geocoding/map services, device-location permissions, verification status changes, account identity sync, audit/security records, conflict handling, and backend profile APIs until product/backend contracts exist | Flow AS, task 46.2 |
| D049 | 2026-06-09 | Remaining blueprint tail triage after Manage Profile basics | After the Manage Profile basic-info cluster, do not start ads/payments/audience, podcast upload/recording, backend account verification/password/phone/email duplicates, feed/Q&A duplicates, schedule/reminder duplicates, or component/demo frames as new routes; existing honest frontend slices already cover the local equivalents, and the remaining routes need backend/product contracts before implementation | Flow AT, task 47.1 |
| D050 | 2026-06-09 | Frontend coverage audit | The current frontend has no remaining honest frontend-only route gaps in the audited docs/router surface: all non-`login` route constants have `generateRoute` cases, `ROUTES.md` records 68 wired routes, and the remaining blueprint/product gaps are deferred backend, payment, media, auth, moderation, sync, or provider-contract seams documented in `DEFERRED_WORK.md` | Flow AU, task 48.1 |
| D051 | 2026-06-09 | Backend/product readiness handoff | Group deferred seams by required contract before backend implementation: auth/account, profile/public identity, scheduling/provider availability, content/community/moderation, health/readings/export, messaging/notifications, payments/ads/subscriptions, media/podcast/upload, emergency/location, and sharing/deep links; backend work should replace local stores/repositories without rewriting completed routes | Flow AV, task 49.1 |
| D052 | 2026-06-09 | Final frontend handoff review | Frontend route coverage is ready for backend/product contract selection: docs and route status still agree on 68 wired routes, `login` remains the only reserved unwired constant, deferred seams are grouped in `DEFERRED_WORK.md`, and no additional honest frontend-only route slice is selected before backend/product contracts | Flow AW, task 50.1 |
| D053 | 2026-06-09 | First backend contract group | Start backend/product integration with `Auth/session/account persistence` before profile, readings, scheduling, messaging, content, payments, media, emergency, or sharing. The next task must define API style, environment/base URL rules, session storage, auth/account models, validation/error states, OTP/email-code provider boundaries, and repository replacement plan before any backend implementation starts | Flow AX, task 51.1 |
| D054 | 2026-07-13 | Auth/session/account backend contract | Use the CareNet REST backend as the auth/session/account authority with environment-specific API base URL config, bearer access tokens only, secure refresh-token storage, safe auth/account repositories, generic auth errors, and explicit deferral of phone OTP, MFA/PIN enablement, provider unlink, destructive account APIs, production email, and profile/payment modules | Phase 22, task 51.2 |
| D055 | 2026-07-13 | Auth infrastructure boundary | Add the auth/session/account infrastructure boundary before screen wiring: `CareNetApiConfig`, `AuthApiClient`, `SessionStore`, auth/session/user models, `AuthRepository`, and `AccountRepository`; use bearer-only headers, secure refresh-token storage, safe generic failures, and keep existing screens local until a dedicated wiring slice | Phase 22, task 52.1 |
| D056 | 2026-07-13 | Email sign-in repository wiring | Wire only email sign-in to `AuthRepository.login` after existing local validation; navigate only after repository success, show safe loading/error states on pending/failure, and keep phone sign-in, sign-up, social auth, password reset, and account-security flows unchanged until their own slices | Phase 22, task 52.2 |
| D057 | 2026-07-13 | Email sign-up repository wiring | Wire only email sign-up completion to `AuthRepository.register` after existing local form validation; pass the validated email from the email-entry step, submit patient role/profile data, navigate only after repository success, show safe loading/error states, and keep phone sign-up, social auth, password reset, and account-security flows unchanged until their own slices | Phase 22, task 52.3 |
| D058 | 2026-07-13 | Session restore launch guard | Keep `RouteName.splash` as the app entry, then after the existing splash delay call `AuthRepository.restore`; route usable stored sessions to `dashboard`, route missing/invalid/failed restore to `onboarding`, and defer refresh validation, staging smoke, logout UI, password reset, phone/social auth, MFA/PIN, and account-security expansion to separate slices | Phase 22, task 52.4 |
| D059 | 2026-07-13 | Logout session clearing | Add logout as a separate Account action that calls `AuthRepository.logout`, returns to onboarding with the previous authenticated navigation stack cleared on success, and shows a safe inline error on failure; destructive account deletion/deactivation, password reset, phone/social auth, MFA/PIN, and account-security mutation remain separately scoped | Phase 22, task 52.5 |
| D060 | 2026-07-13 | Password reset request boundary | Wire the reset email step to `AuthRepository.requestPasswordReset` with safe loading/error states, but do not call `confirmPasswordReset` from the existing password-entry screen because it has no secure reset token; final password reset needs a deep-link or token-entry boundary before it can honestly complete | Phase 22, task 52.6 |
| D061 | 2026-07-13 | Current-account read boundary | Account may call `AccountRepository.currentAccount` to replace safe display-only identity fields such as email and auth status when available; failures show safe copy and keep local display, while profile editing, delete/deactivate, phone/email drafts, password, MFA/PIN, and security mutations remain local/deferred until their own backend contracts exist | Phase 22, task 52.7 |
| D062 | 2026-07-13 | Email verification request boundary | Wire current-email verification request to `AccountRepository.requestEmailVerification` with safe loading/error states, but do not call `confirmEmailVerification` without a secure token/deep-link/code-entry path; email removal/change persistence and account-security mutation remain separate deferred work | Phase 22, task 52.8 |
| D063 | 2026-07-13 | Auth/session/account regression gate | Treat the current email auth/session/account frontend wiring as regression-proven for its scoped boundary after focused tests cover infrastructure, email sign-in, email sign-up completion, session restore, logout, password reset request, current account read, and email verification request; do not start more auth/account wiring or another contract group until a follow-up decision slice chooses the next lane | Phase 22, task 52.9 |
| D064 | 2026-07-13 | Next integration lane after auth regression | Restore missing workflow guardrail docs before more auth/account runtime wiring or another backend contract group: `WORKING_AGREEMENT.md`, `TASK_TEMPLATE.md`, and `DEFINITION_OF_DONE.md` are referenced as authoritative but absent, so `52.11` should recreate them from active project rules without changing runtime behavior | Phase 22, task 52.10 |
| D065 | 2026-07-14 | Workflow guardrail restoration | Keep `WORKING_AGREEMENT.md`, `TASK_TEMPLATE.md`, and `DEFINITION_OF_DONE.md` as required source-of-truth docs for future slices; they define one-task scope control, honest backend-ready behavior, completion gates, and the required task shape without changing runtime product behavior | Phase 22, task 52.11 |
| D066 | 2026-07-14 | Next frontend backend-integration step | Pause additional runtime frontend wiring and create a frontend/backend integration checkpoint next; password reset confirmation, email verification confirmation, phone/social auth, MFA/PIN, profile persistence, and any new contract group should not be wired until the checkpoint states the exact backend/deep-link contracts and blockers | Phase 22, task 52.12 |
| D067 | 2026-07-14 | Frontend/backend integration checkpoint | Use `FRONTEND_BACKEND_INTEGRATION_CHECKPOINT.md` as the handoff for completed auth/session/account frontend wiring and blocked runtime work; the next slice should choose a concrete runtime target or pause, but should not wire token confirmation, phone/social auth, MFA/PIN, profile persistence, destructive account APIs, or another contract group without an explicit backend/deep-link contract | Phase 22, task 52.13 |
| D068 | 2026-07-14 | Next runtime target after checkpoint | User selected password reset confirmation and email verification confirmation as the next target; define the deep-link/code contract first, including route ownership, token/code source, backend request/response fields, expired-token behavior, current-account refresh, and out-of-scope items, before any runtime wiring | Phase 22, task 52.14 |
| D069 | 2026-07-14 | Reset and verification token-confirm contract | Use the backend bridge contract for password reset and email verification confirmation: public confirm routes accept opaque `token` values, password reset confirm also sends `newPassword`, request routes return generic `{ "success": true }`, reset confirmation revokes refresh sessions and does not issue a new session, and email verification confirmation requires current-account refresh if the app still has a session. Tokens stay transient and are never persisted or logged; production app-link setup remains deferred | Phase 22, task 52.15 |
| D070 | 2026-07-14 | Reset and verification token-confirm wiring | Wire `resetPasswordConfirm` and `emailVerificationConfirm` as token-confirm landing routes that require transient token arguments. Password reset confirmation sends backend `newPassword`, clears local session after success, and returns to sign-in. Email verification confirmation sends only `token` and refreshes current account state when a session is still available. Do not claim production app-link setup, phone OTP, social auth, MFA/PIN, or profile persistence from this slice | Phase 22, task 52.16 |
| D071 | 2026-07-14 | Completed backend surface wiring order | Use `BACKEND_COMPLETED_SURFACE_WIRING_MAP.md` to consume already-completed backend surfaces in a stable order: auth/account staging checkpoint first, then professional/profile/verification, then public professionals/availability, then appointment lifecycle. Do not start phone/OTP, MFA, production app links, payments, notifications, reviews, calls, calendar sync, prescriptions, medical notes, admin dashboard behavior, public staging access, or production-readiness work as the next runtime lane | Phase 22, task 52.17 |
| D072 | 2026-07-14 | Auth account staging checkpoint | Developer-private staging proxy reached `/health` and `/health/ready`; database, migrations, and email are ready, while `googleAuth` and `verificationStorage` are disabled. Keep Google UI and verification upload deferred, keep `CARENET_API_BASE_URL` as the Flutter config key, and select profile/public professional contract work as the next frontend lane | Phase 22, task 52.18 |
| D073 | 2026-07-14 | App identifiers for Google foundation | Use `com.carenet.app` for Android namespace/application ID and iOS bundle ID before creating or wiring Google OAuth credentials. Do not create OAuth clients against placeholder `com.example` IDs; Google UI remains disabled until OAuth clients, fingerprints, Flutter provider config, and backend `GOOGLE_OAUTH_CLIENT_ID` are ready | Phase 22, task 52.19 |
| D074 | 2026-07-14 | Google OAuth prerequisite boundary | Collect Google OAuth prerequisites before runtime UI wiring: Android package `com.carenet.app`, iOS bundle `com.carenet.app`, debug SHA fingerprints, release fingerprint blocker, and backend readiness status. Do not add `google_sign_in` or enable Google buttons until OAuth client IDs are configured and backend readiness reports `googleAuth: ok` | Phase 22, task 52.20 |
| D075 | 2026-07-14 | Google staging readiness enabled | Backend staging now has Google OAuth client configuration through Secret Manager/Cloud Run; `/health/ready` reports `googleAuth: ok`. The next safe step is Flutter Google provider wiring for Android debug/staging only, while link/unlink, iOS proof, release signing, production OAuth, phone/OTP, and MFA stay deferred | Phase 22, task 52.21 |
| D076 | 2026-07-14 | Flutter Google sign-in wiring | Use `google_sign_in` with `GOOGLE_SIGN_IN_SERVER_CLIENT_ID` as the server client ID, obtain a real Google ID token, and call `AuthRepository.googleSignIn` only from sign-in phone/email rows when configured. Keep Google sign-up role selection, link/unlink, iOS proof, release signing, production OAuth, phone/OTP, MFA, and profile wiring deferred | Phase 22, task 52.22 |
| D077 | 2026-07-14 | Profile/public professional wiring contract | Define patient self profile, professional self profile, and public verified professional listing as the next profile lane. Add a repository/API boundary before screen wiring, keep public professional detail deferred until `GET /professionals/:id` exists, and keep verification upload, availability, appointments, payments, reviews, calls, calendar sync, notes, and prescriptions out of scope | Phase 22, task 52.23 |
| D078 | 2026-07-14 | Profile repository boundary | Add `ProfileApiClient` and `ProfileRepository` for patient self profile, professional self profile, and public verified professional listing before screen wiring. Protected calls use stored-session bearer auth, self-profile 404 maps to an empty profile state, and public listing sends no auth header | Phase 22, task 52.24 |
| D079 | 2026-07-14 | Manage Profile professional self read | Wire Manage Profile to `ProfileRepository.professionalMe` for professional self-profile read only. Replace only `displayName`, `category`, `specialty`, and `bio`; keep safe loading/error/empty states; leave profile mutations, patient profile UI, public listing UI, verification, availability, appointments, payments, reviews, calls, calendar sync, notes, and prescriptions deferred | Phase 22, task 52.25 |
| D080 | 2026-07-14 | First safe profile mutation UI | Select existing professional bio update from `addDescription` as the first safe profile mutation path. The next implementation must read an existing professional profile, preserve required `displayName` and `category` plus existing `specialty`, update only `bio`, and keep profile creation, name/category/specialty editing, website, address, patient profile, public listing, verification, availability, appointments, payments, reviews, calls, calendar sync, notes, and prescriptions deferred | Phase 22, task 52.26 |
| D081 | 2026-07-14 | Professional bio update wiring | Wire `addDescription` to update only the current professional profile `bio` after reading an existing professional profile. The update preserves existing `displayName`, `category`, and `specialty`; safe loading/error/empty states are shown; profile creation and wider profile/public-professional work remain deferred | Phase 22, task 52.27 |
| D082 | 2026-07-14 | Next profile public listing lane | Select public verified professional listing into `SearchShellPage` as the next runtime lane. Replace only list-card name/category/specialty/bio data through `ProfileRepository.publicProfessionals`; keep public detail, Find Mentor, Specialist Details, availability, appointments, booking, reviews, ratings, prices, payments, calls, calendar sync, verification, patient profile, profile creation, and profile edit expansion deferred | Phase 22, task 52.28 |
| D083 | 2026-07-14 | Search public listing wiring without fallback | Wire `SearchShellPage` to `ProfileRepository.publicProfessionals` and remove local specialist fallback for backend listing failures. Search now shows real loading/error/empty states, maps only public display/category/specialty/bio fields, keeps booking disabled, and keeps public detail, Find Mentor, Specialist Details, availability, appointments, ratings, prices, payments, reviews, calls, calendar sync, verification, and profile edit expansion deferred | Phase 22, task 52.29 |
| D084 | 2026-07-14 | Scheduling availability appointment next lane | Select scheduling as the next backend-integration lane, but start with a frontend contract slice before runtime wiring. The next slice must map completed backend availability and appointment routes into Flutter repository/entities/screen boundaries, preserve no local fallback behavior, and keep public detail invention, direct booking, payments, notifications, reviews, calls, calendar sync, admin override, notes, and prescriptions deferred | Phase 22, task 52.30 |

## How to add a row

Example:

| D001 | 2026-05-15 | Auth backend | Use REST API at `https://api.example.com`; mock until backend ready | Flow A, Phase 2 |

## Open questions

| ID | Question | Blocks task |
|----|----------|-------------|
| - | - | - |

When a decision is confirmed, move the answer into the table above and clear
the open question.
## D071 - Completed backend surface wiring order

Task: 52.17

Decision: After reset/password and email-verification token-confirm wiring, do
not jump directly into phone/OTP, MFA, production app links, payments,
notifications, reviews, calls, calendar sync, prescriptions, medical notes,
admin dashboard behavior, public staging access, or production-readiness work.
Use `BACKEND_COMPLETED_SURFACE_WIRING_MAP.md` as the frontend map for consuming
already-completed backend surfaces.

Reason: The backend has completed more than auth, including professional/profile
verification, public professional/availability surfaces, and appointment
lifecycle routes. The frontend should consume them in a stable order rather than
starting random screens. Auth/session/account and staging/proxy configuration
remain the shared base for every protected route.

Next: 52.18 should run an auth/account staging smoke and remaining-backend
checkpoint, then queue broader professional/profile/verification,
availability, and appointment wiring.

## D072 - Auth account staging checkpoint

Task: 52.18

Decision: Use the developer-private Cloud Run Proxy path for frontend staging
integration. The app already has the `CARENET_API_BASE_URL` compile-time config
key. Current proxy evidence proves `/health` and `/health/ready` are reachable,
with database, migrations, and email ready. Google UI and verification upload
remain deferred because readiness reports `googleAuth: disabled` and
`verificationStorage: disabled`.

Reason: Profile/public professional reads can build on the existing auth/session
base without requiring disabled providers. Google sign-in and verification
document upload need separate provider/config decisions before runtime wiring.

Next: 52.19 should define the profile and public professional wiring contract
before runtime profile/discovery implementation.

## D073 - App identifiers for Google foundation

Task: 52.19

Decision: Replace placeholder Android/iOS identifiers with `com.carenet.app`
before Google OAuth setup. Android namespace and application ID should be
`com.carenet.app`; iOS app bundle ID should be `com.carenet.app`; iOS tests
should use `com.carenet.app.RunnerTests`.

Reason: Creating Google OAuth clients against `com.example.app_t` or
`com.example.appt` would create avoidable rework and stale provider setup.

Next: 52.20 should define or collect Google OAuth prerequisites for
`com.carenet.app` before runtime Google UI wiring.

## D074 - Google OAuth prerequisite boundary

Task: 52.20

Decision: Collect the Google OAuth prerequisite package before runtime Google UI
wiring. The app target is Android package `com.carenet.app` and iOS bundle
`com.carenet.app`. The local Android debug SHA fingerprints are recorded in
`GOOGLE_SIGN_IN_SETUP_PREREQUISITES.md`. Release fingerprints remain blocked
until the release keystore password is intentionally available.

Reason: Google UI wiring cannot be proven while staging readiness reports
`googleAuth: disabled` and no Google OAuth client configuration is present.
Adding a Flutter provider package before OAuth clients exist would create a
mocked success path rather than real sign-in.

Next: 52.21 should create or collect OAuth client IDs and configure backend
staging `GOOGLE_OAUTH_CLIENT_ID`, then verify `/health/ready` reports
`googleAuth: ok`.

## D075 - Google staging readiness enabled

Task: 52.21

Decision: Treat backend staging Google auth as ready for the Android debug
frontend wiring path after Secret Manager/Cloud Run configuration and readiness
verification. `/health/ready` now reports `googleAuth: ok`.

Reason: The backend can now verify Google ID tokens against the configured
client ID. Flutter can proceed to real provider-token acquisition and backend
handoff without faking Google success.

Next: 52.22 should add the Flutter Google Sign-In provider and wire the Google
button to `AuthRepository.googleSignIn` with safe loading/error handling.

## D076 - Flutter Google sign-in wiring

Task: 52.22

Decision: Add the Flutter `google_sign_in` provider boundary and wire only the
sign-in phone/email Google rows. The provider initializes with
`GOOGLE_SIGN_IN_SERVER_CLIENT_ID`, obtains a Google ID token, and sends that
token through the existing `AuthRepository.googleSignIn` backend boundary.
The Google row remains disabled when the server client ID is not configured.

Reason: The current Google Sign-In package requires a server-side Web OAuth
client ID for backend-verifiable ID tokens. Backend staging was updated to trust
that Web client ID, so Flutter can perform a real provider-token handoff
without committing secrets or faking success.

Deferred: Google sign-up role-selection behavior, Google link/unlink UI, iOS
OAuth proof, release/Play signing fingerprints, production OAuth consent/app
verification, phone/OTP, MFA, and profile wiring.

Next: 52.23 should define the profile and public professional wiring contract
before runtime profile/listing work.

## D077 - Profile/public professional wiring contract

Task: 52.23

Decision: Use `PROFILE_PUBLIC_PROFESSIONAL_CONTRACT.md` as the source of truth
for the next profile lane. The first implementation should add a repository/API
boundary for `GET/PUT /patients/me`, `GET/PUT /professionals/me`, and public
`GET /professionals`, with focused tests and no screen wiring.

Reason: The backend supports patient/professional self profile routes and public
verified professional listing, but public professional detail, verification
upload UX, availability, and appointments each need separate boundaries. Adding
the repository first lets later screen slices replace local stores without
rewriting the UI or leaking private fields.

Next: 52.24 should add the profile repository boundary only.

## D078 - Profile repository boundary

Task: 52.24

Decision: Add a profile repository/API boundary before screen wiring. The
boundary covers patient self read/update, professional self read/update, and
public verified professional listing only.

Reason: Focused repository tests prove ownership-safe payloads, bearer-only
protected calls, empty-profile handling, and public projection parsing before
any UI starts depending on the backend. This keeps the next screen slice small
and avoids mixing profile read wiring with profile mutation, verification,
availability, or appointment behavior.

Next: 52.25 should wire professional self profile read to Manage Profile only.

## D079 - Manage Profile professional self read

Task: 52.25

Decision: Wire Manage Profile to read the current professional profile through
`ProfileRepository.professionalMe`, but only replace backend-owned profile
fields: `displayName`, `category`, `specialty`, and `bio`. The page keeps safe
loading, empty-profile, and error states, and preserves local/deferred content
for fields the backend contract does not currently own.

Reason: This is the smallest real screen replacement after the repository
boundary. It proves the protected self-profile read path without mixing in
profile saves, patient profile UI, public listing replacement, verification
documents, availability, appointments, payments, reviews, calls, calendar sync,
notes, or prescriptions.

Next: 52.26 should decide the first safe profile mutation UI slice before any
runtime profile update button is wired.

## D080 - First safe profile mutation UI

Task: 52.26

Decision: Use `PROFILE_MUTATION_UI_DECISION.md` as the source of truth for the
first profile mutation UI. The next runtime slice should wire only
`addDescription` to update the professional profile `bio`, and only after
reading an existing professional profile.

Reason: `PUT /professionals/me` requires `displayName` and `category`, while
the existing edit screens do not all map to backend fields. The description
screen is the narrowest safe mutation because it can preserve existing
`displayName`, `category`, and `specialty` and change only `bio`. Website and
address are not accepted by the current professional profile contract, and
category/specialty editing has no current UI.

Next: 52.27 should wire professional bio update from `addDescription` only.

## D081 - Professional bio update wiring

Task: 52.27

Decision: Wire `AddDescriptionShellPage` to read the current professional
profile through `ProfileRepository.professionalMe` and update only `bio` through
`updateProfessionalMe`. The page preserves existing backend-required
`displayName` and `category` plus existing `specialty`, and it refuses to create
a partial professional profile when the self profile is missing.

Reason: This completes the narrow mutation path selected by D080 without
inventing profile creation, category editing, address/website persistence, or
public listing behavior. Focused tests prove successful save, no-profile
non-creation, and safe save-error messaging.

Next: 52.28 should decide the next profile/public-professional runtime lane
before any further runtime wiring.

## D082 - Next profile public listing lane

Task: 52.28

Decision: Use `PROFILE_PUBLIC_LISTING_NEXT_LANE_DECISION.md` as the source of
truth for the next runtime lane. The next implementation should wire
`ProfileRepository.publicProfessionals` into `SearchShellPage` list cards only.

Reason: Public verified professional listing is already supported by the
repository and backend route, and it maps cleanly to public list fields:
`displayName`, `category`, `specialty`, and `bio`. The current Find Mentor and
Specialist Details surfaces include availability, booking, ratings, prices, and
detail data that are not provided by the public listing contract.

Next: 52.29 should wire public verified professional listing to Search only.

## D083 - Search public listing wiring without fallback

Task: 52.29

Decision: Wire `SearchShellPage` directly to
`ProfileRepository.publicProfessionals` for public verified professional list
cards. Do not fall back to `SearchLocalStore` when the backend listing fails.
Backend errors and empty results must stay visible so integration failures can
be debugged instead of hidden behind seeded data.

Reason: Once a screen is backend-wired, seeded local backup data creates false
confidence and can hide real configuration/API failures. The Search slice now
uses only public backend fields for displayed provider data and keeps booking
disabled because availability/appointment contracts are separate.

Next: 52.30 should decide the next backend-integration lane before more runtime
wiring.

## D084 - Scheduling availability appointment next lane

Task: 52.30

Decision: Select scheduling as the next backend-integration lane, starting with
a contract slice for availability and appointment surfaces. Do not wire booking
directly next.

Reason: The backend has completed availability and appointment core routes, but
appointment request depends on verified professionals, backend-owned
availability policy, authenticated patient/professional roles, and safe status
transitions. Wiring booking before defining the Flutter contract would invite
local fallback and fake success states.

Next: 52.31 should define the scheduling/availability/appointment frontend
contract, then queue the first repository/runtime slice from that contract.
