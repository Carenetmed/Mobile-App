# Product & technical decisions

## APP-READY-082A - No Sample Identity On Failed Profile Load

Clarification of D136-D138, not a new product capability: only a successfully
loaded backend professional profile may prefill the registered name editor.
Null, unauthorized, forbidden, network, unexpected and missing-DI failures leave
the field empty with existing safe messages. The null-profile save guard and
preserved category/specialty/bio remain unchanged. Do not replace failure with
seeded identity or broaden profile creation, routes, repositories or role policy.
This is an authorized prerequisite within the still-partial APP-READY-082 task.

## APP-READY-068 Foreground Notification Ownership (2026-10-16)

Treat FCM notification IDs as opaque hints. Before a foreground local
notification is shown, resolve its ID through the authenticated notification
repository and confirm the current account/session generation still owns it.
Never display unverified FCM title/body; show generic CareNet copy only. A
session switch/logout invalidates pending display work and clears local
notifications where supported. Backend notification detail remains the owner
authority.

Firebase initialization may continue after its caller times out. Generation
checks prevent late completion from attaching listeners; already attached
subscriptions are cancelled on transport disposal. This does not claim native
Firebase initialization or OS background delivery can be cancelled.

## APP-READY-067 Authentication Ordering And Waits (2026-10-16)

One private attempt owner orders email login, registration and Google sign-in
responses. A newer attempt or logout supersedes older responses without granting
any role or authority. Check ownership before API-result persistence, inside
the queued conditional write, and around optional lifecycle completion. Cleanup
may clear only the exact generation written by that attempt; never a newer
account. Superseded, unacknowledged commits fail closed rather than reviving an
older attempt when the newer one fails.

Secure read/capture caller waits default to5seconds, including queue delay;
authentication caller waits default to60seconds. Errors are fixed, non-clearing
network failures, not fabricated401s. The underlying serialized future remains
owned until it actually completes; timeout is neither native cancellation nor
evidence that a write did not commit. Already-started I/O/notifications may finish
later. Logout/cleanup failure must never be shown as successful durable removal.
No custom Dio cancellation rewrite is justified: actual probes already verify
single-flight refresh, cancelled transport exclusion and unsafe-body rejection.

## APP-READY-066 Session Recovery Integrity (2026-10-16)

Separately stored historical token/user fields cannot prove a shared authenticated
account. Discard them and require normal sign-in rather than guessing provenance.
Retain valid single-envelope schema-v1 to schema-v2 migration and generation-bound
conditional updates. No role, readiness or ownership is inferred from navigation.
One versioned secure-storage value is a logical consistency boundary, not a claim
of platform power-loss atomicity. Fault injection/recreation must fail closed.

Initial splash restoration is bounded to five seconds and uses the existing
unauthenticated onboarding destination on timeout/error. Late results cannot
route, refresh or resume booking. Disposal cancels the startup timer and prevents
subsequent authentication work. Existing refresh timeout intentionally preserves
an already restored usable session on transient failure; this is unchanged.
Timeout does not cancel an underlying platform secure-storage operation or prove
the provider will recover. No storage queue may be released unsafely to permit
late writes over a newer account; broader cancellation remains separate work.

## APP-READY-064 English/Nigeria Presentation (2026-10-15)

Phase 1 remains English only, identified as `en_NG`, independent of device
language. The pinned intl date bundle lacks `en_NG`; explicitly use its bundled
`en_GB` day-first English date data, not invented Nigerian CLDR data. Visible
times use twelve-hour `am/pm`; preserve text scaling and accessibility media
preferences. SDK `flutter_localizations` supplies standard control translations.
NGN display, decimal-point input, UTC instants and IANA conversion are unchanged.
No ambient `Intl.defaultLocale` mutation. See `PHASE_1_LOCALE_POLICY.md`.

## APP-READY-063 Diagnostic Transport (2026-10-14)

The user selected strictly allowlisted reports through CareNet's existing backend
instead of Firebase Crashlytics. Native/raw crash uploads remain disabled; no new
diagnostics SDK or dependency is installed. Sharing is default-off, explicitly
opted in per authenticated session generation, and contains only closed technical
codes, a boolean and validated release metadata. JWT authenticates admission but
is never a report field or consent field. No raw exception, stack, route, user ID,
URL, clinical/payment/message content or arbitrary log is sent. Consent storage
failure must not appear successful. Native/process-death coverage and operational
deployment/log retention/alerts remain explicit gates. See PHASE_1_RELEASE_HEALTH.

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
| D085 | 2026-07-14 | Scheduling availability appointment frontend contract | Define the Flutter contract for public/professional availability and appointment routes before runtime wiring. The next implementation must add entities/models/API client/repository/DI/tests only, must not wire UI screens yet, and must preserve no local fallback for backend-owned scheduling data | Phase 22, task 52.31 |
| D086 | 2026-07-14 | Scheduling repository boundary | Add `SchedulingApiClient` and `SchedulingRepository` with availability and appointment entities/models, DI registration, and focused tests. Public availability sends no auth header; protected availability/appointment calls require stored session bearer auth; request/reschedule payloads send only backend-accepted fields; lifecycle actions send no trusted status body. No UI screens are wired yet | Phase 22, task 52.32 |
| D087 | 2026-07-14 | Public availability read in Search | Wire the Search public professional profile sheet to `SchedulingRepository.publicAvailability` for the selected backend public professional id. Show real loading/error/empty availability states, render only returned backend windows, keep booking disabled/deferred, and do not reintroduce local specialist or slot fallback | Phase 22, task 52.33 |
| D088 | 2026-07-14 | Appointment request UI path | Do not adapt the old free-text `bookAppointment` form directly into backend request wiring. First remove local `Confirmed locally`/fake booking success, then define a concrete request UX from backend public professional plus public availability; backend request success must mean `REQUESTED`, not booked/confirmed | Phase 22, task 52.34 |
| D089 | 2026-07-14 | Remove local booking success | Remove local `Confirmed locally`/fake booking completion from `bookAppointment`. The route may still validate and review details, but it must show `Backend request not sent` and cannot claim save/confirmation until real appointment request wiring exists | Phase 22, task 52.35 |
| D090 | 2026-07-14 | Concrete appointment request UX | Use the Search public professional profile sheet as the first real appointment request UX. Generate near-term concrete time options from backend public availability, offer fixed 30/45/60 minute durations, call `requestAppointment` only after helper logic is tested, and show backend success as `REQUESTED` only | Phase 22, task 52.36 |
| D160 | 2026-07-17 | Patient/professional onboarding UI requirements | Use `PATIENT_PROFESSIONAL_ONBOARDING_UI_REQUIREMENTS.md` as the accepted boundary for serious role-specific onboarding. Patient setup should collect backend-owned profile fields; professional setup must collect legal name, public name, category, license/council, qualifications, experience, and practice fields before profile creation. Flutter must expand profile models/repository before polished screens can save all new backend fields | APP-58 |
| D161 | 2026-07-17 | Profile contract expansion for Nigeria onboarding | Expand Flutter patient/professional profile entities, JSON models, API client payloads, and repository methods for backend `CAR-BE-119` fields before building polished onboarding screens. Public professional listing remains limited to the existing safe projection and the client still cannot send verification/admin/public-listing state | APP-59 |
| D162 | 2026-07-17 | Patient/professional onboarding setup UI | After registration, patient users must save backend patient profile setup before community agreements, and professional users must save legal/credential/practice profile fields before verification document upload. Professional public listing still depends on backend verification; no admin, payment, review, call, note, prescription, Google sign-up, or license-validation behavior is added | APP-60 |
| D165 | 2026-07-19 | Onboarding catalog/readiness repository boundary | Keep backend-owned onboarding catalogs and account readiness in a separate `OnboardingRepository` instead of expanding `ProfileRepository`; the boundary is cross-role onboarding metadata/readiness, uses no fake fallback, and the next UI slice should consume it before polishing patient/professional setup screens | APP-ID-004 |
| D166 | 2026-07-19 | Controlled onboarding setup UI before profile-code payload redesign | Wire patient/professional setup screens to backend-owned catalogs/readiness now, replacing free-text country/state/profession/health-interest choices without changing the existing profile repository payload shape in the same slice. Decide native `countryCode`/`professionCode`/`regulatorCode` profile payload alignment separately before changing backend-facing profile update fields | APP-ID-005 |
| D167 | 2026-07-19 | Onboarding profile payload code alignment | Do not invent unsupported `countryCode`, `professionCode`, or `regulatorCode` request fields from Flutter while backend profile DTOs still accept the current profile field names. The next implementation should send backend-accepted catalog values through existing DTO fields and leave explicit native code request fields for a backend-contract slice | APP-ID-006 |
| D168 | 2026-07-19 | Onboarding setup sends catalog codes through current DTO fields | Use backend-owned catalog codes for patient country/state/health-interest and professional category/practice country/practice state, plus the catalog regulator code for licensing council, while keeping the existing profile API field names until backend DTOs explicitly change | APP-ID-007 |
| D169 | 2026-07-19 | Production onboarding domain hardening boundary | Freeze broad onboarding feature expansion and harden the current Nigeria MVP lane: no in-app role switching or dual-mode accounts yet, backend owns duplicate identity/readiness/application state, professional onboarding remains strict and catalog/regulator driven, required evidence guidance comes from backend catalogs/readiness, and next work should plan readiness/resume UX hardening before runtime changes | APP-ID-008 |
| D170 | 2026-07-19 | Onboarding readiness route resolver should precede UI redesign | Before broad onboarding UI polish, add a small Flutter resolver that maps backend `AccountReadiness.nextAction` plus role to safe route destinations after signup/resume, with professional fallback never going directly to dashboard when readiness is unavailable | APP-ID-009 |
| D171 | 2026-07-19 | Post-signup routing uses backend readiness first | After successful email/password or first-time Google signup, Flutter should call `account/readiness` before choosing the destination. If readiness is unavailable, fallback by selected role and keep professionals in setup rather than routing them directly to dashboard | APP-ID-010 |
| D172 | 2026-07-19 | Onboarding destinations need backend-readiness progress guidance | After readiness routing, patient/professional setup and professional verification documents should display backend-owned progress, required profile fields, required/missing evidence, and safe status/retry copy. Flutter must not invent local readiness, verification approval, role switching, or new backend document-code contracts | APP-ID-011 |
| D173 | 2026-07-19 | Onboarding progress panels must remain backend-owned | Patient/professional setup and professional verification documents may display required profile fields and evidence guidance from `account/readiness` and onboarding catalogs, but upload success remains pending review and Flutter must not claim approval, resolve duplicate identity, or invent application state | APP-ID-012 |
| D174 | 2026-07-19 | Onboarding hardening needs a proof gate before expansion | Before more onboarding feature expansion or broad UI redesign, run a focused regression and staging Android phone-smoke gate that proves email/password signup, Google first-time signup, backend readiness routing, patient/professional setup, verification evidence guidance, safe failure states, and blocker recording | APP-ID-013 |
| D175 | 2026-07-19 | Recover auth onboarding gateway without rolling back backend readiness | Restore the first-launch gateway and role-first signup method UX from older unmerged APP-66 through APP-73 work, but do not merge those branches wholesale or roll back APP-ID backend catalog/readiness/profile/verification wiring | APP-ID-015 |
| D176 | 2026-07-22 | Narrow Phase 1 to a healthcare consultation marketplace | Keep role-specific auth/onboarding, verification, professional discovery, availability, appointments, role profiles, appointment messaging/consultation/payment/support only when approved; remove broad social/content/readings/emergency/creator modules from active navigation first and from source later after archive and retained-flow proof | APP-P1-001 |
| D177 | 2026-10-17 | Keep native iOS Google OAuth flavor-specific | Configure the iOS bundle `com.carenet.app.staging` only with its canonical-project iOS OAuth client and reversed callback scheme, and `com.carenet.app` only with its production pair. Continue using the existing Web client as `GoogleSignIn.initialize(serverClientId:)` for backend ID tokens; do not cross-use platform clients or change backend audience/provider authority | APP-READY-073 |

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

## D085 - Scheduling availability appointment frontend contract

Task: 52.31

Decision: Use `SCHEDULING_AVAILABILITY_APPOINTMENT_CONTRACT.md` as the source
of truth for Flutter availability and appointment integration. Add repository
and API boundaries before screen wiring.

Reason: Current appointment, booking, Specialist Details, Find Mentor, and
Selected Dates screens still contain local draft/seeded behavior. Once a
scheduling surface is backend-wired, local drafts must not be used as backup
success. A repository-first slice lets tests prove headers, payloads, parsing,
safe errors, and authority boundaries before user-facing screens change.

Next: 52.32 should add the scheduling repository boundary only.

## D086 - Scheduling repository boundary

Task: 52.32

Decision: Add the scheduling repository/API boundary before UI wiring.

Reason: Scheduling screens still contain local draft/seeded behavior. The
repository boundary proves the backend route shape, bearer-token behavior,
safe public availability access, allowed request payloads, and lifecycle
actions before any visible booking or availability surface can claim backend
success.

Next: 52.33 should wire public availability read as the first scheduling UI
surface while keeping appointment request disabled/deferred.

## D087 - Public availability read in Search

Task: 52.33

Decision: Use the Search public professional profile sheet as the first
scheduling UI surface. It already starts from a backend public professional id,
so it can read public availability without inventing a public detail route or
using local `SearchLocalStore` slots.

Reason: Specialist Details and Find Mentor still depend on local seeded
specialist data. Wiring availability there first would risk making local data a
fallback for backend scheduling. Search can show availability from the real
selected public professional and keep appointment request disabled until a
separate booking-path decision.

Next: 52.34 should decide the first appointment request UI path before runtime
booking is wired.

## D088 - Appointment request UI path

Task: 52.34

Decision: Do not wire the existing `bookAppointment` free-text local form
directly to `SchedulingRepository.requestAppointment`. First remove local
booking success, then define a concrete request UX from backend professional
and backend availability data.

Reason: The backend request contract accepts only `professionalProfileId`,
`requestedStartAt`, and `durationMinutes`. The old form stores clinician text,
preferred date text, visit type, reason, and a local confirmation status. That
shape would either send unsupported fields or preserve fake booking success.

Next: 52.35 should remove local booking success before real appointment request
wiring.

## D089 - Remove local booking success

Task: 52.35

Decision: Keep the `bookAppointment` route available, but remove local booking
confirmation/success behavior. The route can review typed details only and must
state that no backend appointment request has been sent.

Reason: This removes a fake success path before real appointment request wiring.
Future request work can now build from backend public professional plus public
availability without competing with an older local confirmation state.

Next: 52.36 should define the concrete appointment request UX before runtime
booking is wired.

## D090 - Concrete appointment request UX

Task: 52.36

Decision: The first real appointment request UX should live in the Search public
professional profile sheet because that sheet already has a backend public
professional id and real public availability. Do not start from the standalone
old `bookAppointment` route.

Reason: Runtime request needs a concrete backend professional id, concrete
start time, and duration. A helper/test slice should generate requestable time
options from returned availability before UI calls `requestAppointment`.

Next: 52.37 should add the time-option helper and focused tests without calling
the appointment request API.

## D091 - Appointment request time-option helper

Task: 52.37

Decision: Add a small domain helper that converts active backend
`AvailabilityWindow` records into concrete near-term appointment request options
for the next seven days. Generate options at the window start time only, include
only durations that fit inside the returned window, preserve the backend
timezone string, and skip inactive, invalid, and past options.

Reason: The first real request UI needs concrete `requestedStartAt` plus
`durationMinutes` values before it can call `SchedulingRepository.requestAppointment`.
Keeping this as a helper/test slice avoids mixing date generation, UI selection,
and backend request behavior in one change. Backend validation remains the final
authority for availability and conflicts.

Next: 52.38 should wire the Search public availability sheet to generated
options and call `requestAppointment` only after user selection, showing backend
`REQUESTED` success without local fallback.

## D092 - Search appointment request wiring

Task: 52.38

Decision: Wire the first real appointment request action inside the Search
public professional profile sheet. The sheet uses generated time options from
backend public availability, calls `SchedulingRepository.requestAppointment`
only after user selection, and displays the backend-returned appointment status.

Reason: This path starts from a real backend public professional id and returned
availability windows, so it avoids adapting the old free-text local
`bookAppointment` form. Success remains backend-owned: no local confirmation,
no fake booked state, and no fallback request when the backend fails.

Next: 52.39 should wire the patient's own appointment list read so submitted
requests become visible before any lifecycle mutation UI is added.

## D093 - Own appointment list read

Task: 52.39

Decision: Wire the `appointments` screen to `SchedulingRepository.ownAppointments`
for backend-owned appointment visibility. Render backend appointment statuses
as read-only upcoming/recent cards and show safe loading, empty, and error
states without falling back to seeded local appointment cards.

Reason: After Search can submit a real request, the user needs a backend-owned
place to see requested/accepted/completed state before cancellation,
rescheduling, professional lifecycle actions, payments, notifications, or
calendar behavior are added.

Next: 52.40 should decide the next scheduling UI lane deliberately: patient
cancellation, professional availability management, professional lifecycle UI,
or a regression checkpoint.

## D094 - Scheduling next UI lane

Task: 52.40

Decision: Select patient appointment cancellation as the next runtime
scheduling UI lane. Do not jump directly to professional availability
management, professional accept/decline, reschedule, completion, or regression
before adding the smallest patient-side reversal path.

Reason: Request and own-list visibility are now backend-backed. Patient
cancellation is the narrowest useful follow-up because it closes the obvious
user gap after a request is created while avoiding payment, notification,
calendar, provider workspace, and professional scheduling complexity.

Next: 52.41 should add a cancel action only for eligible own appointment cards
and update the visible status from the backend response.

## D095 - Patient appointment cancellation

Task: 52.41

Decision: Add patient-side cancellation from the backend-backed Appointments
screen only for eligible upcoming `REQUESTED` and `ACCEPTED` cards. Call
`SchedulingRepository.cancelAppointment`, then replace the visible card state
with the backend response.

Reason: This closes the smallest user-facing gap after appointment request and
own-list visibility. The frontend uses current status and section placement to
decide whether to show the action, but the backend remains authority for
ownership, role, and valid transitions.

Next: 52.42 should decide whether to pause for scheduling regression or move to
professional availability management before adding more runtime behavior.

## D096 - Scheduling patient-path regression before expansion

Task: 52.42

Decision: Pause scheduling feature expansion for a focused patient-path
regression checkpoint before professional availability management or
professional lifecycle UI.

Reason: Search public listing, public availability, request submission, own
appointment list, and patient cancellation are now backend-backed. Before adding
larger professional-facing scheduling authority, the project should prove this
new path did not reintroduce seeded fallback, fake success, raw backend errors,
or hidden local state.

Next: 52.43 should strengthen focused tests/docs for the scheduling patient
path without adding new runtime product behavior.

## D097 - Scheduling patient-path regression passed

Task: 52.43

Decision: Keep scheduling feature expansion frozen until the focused patient
path regression is recorded, then move to a decision-only professional
availability boundary slice.

Reason: The current patient path has focused proof for public listing,
availability, generated request options, backend request success/failure, own
appointment list rendering, requested/accepted cancellation, terminal/recent
hidden actions, and safe failure behavior. That gives a cleaner base before
touching professional availability management.

Next: 52.44 should decide the professional availability management UI boundary
before replacing local business-hour/selected-date drafts with backend
availability read/replace behavior.

## D098 - Professional availability management belongs in selectedDates

Task: 52.44

Decision: Use `selectedDates` as the professional own-availability management
surface. Keep `manageProfile` as the entry point/summary surface and do not mix
profile mutation with availability persistence.

Reason: The current app already routes Manage Profile -> Business -> Edit hours
to `selectedDates`, and the scheduling repository already exposes protected
`ownAvailability()` and `replaceOwnAvailability(windows:)`. Replacing the
route-local draft at that boundary is the least disruptive path and preserves
the existing Manage Profile structure.

Next: 52.45 should wire `selectedDates` to backend own-availability
read/replace with safe states, preserve existing windows where safe, and keep
appointment lifecycle, payments, notifications, calls, calendar, notes, and
prescriptions deferred.

## D099 - Professional availability management wired before lifecycle UI

Task: 52.45

Decision: Replace the selected-dates local-only business-hours draft with
backend own-availability read/replace before starting professional appointment
lifecycle controls.

Reason: Professionals need a real backend-owned availability surface before
accept/decline/reschedule/complete UI can be responsibly exposed. The
implementation preserves other existing backend weekdays during a selected-day
save, avoids profile mutation, and shows success only after repository success.

Next: 52.46 should decide the professional appointment lifecycle UI boundary
before adding accept/decline/reschedule/complete controls.

## D100 - Professional accept/decline before broader lifecycle UI

Task: 52.46

Decision: Add role-aware professional `Accept`/`Decline` as the first
professional appointment lifecycle UI, before reschedule or complete.

Reason: `AppointmentsShellPage` currently reads own backend appointments but
does not know the signed-in role. Professional lifecycle controls should be
shown only after reading authenticated session role from `SessionStore` or an
equivalent existing auth boundary. `REQUESTED -> ACCEPTED/DECLINED` is the
narrowest professional action pair; completion has scheduled-end-time rules and
reschedule has additional time/availability UX.

Next: 52.47 should wire professional accept/decline only for signed-in
`PROFESSIONAL` users on eligible `REQUESTED` appointments.

## D101 - Role-aware professional accept/decline wired

Task: 52.47

Decision: Appointments may expose professional `Accept`/`Decline` only after
reading authenticated session role, and only for eligible `REQUESTED`
appointments. Patient sessions keep patient cancellation behavior and do not
see professional actions.

Reason: This avoids guessing role from appointment ids or profile ids while
still using the backend as authority for ownership and transition validity.
Visible status updates come only from repository success.

Next: 52.48 should run a professional lifecycle regression/checkpoint before
deciding whether to add reschedule or complete UI.

## D102 - Professional lifecycle regression before reschedule or complete

Task: 52.48

Decision: Pause broader appointment lifecycle expansion after accept/decline
for a focused regression checkpoint.

Reason: Patient cancel and professional accept/decline now share the
Appointments surface. Before choosing reschedule or completion, the project
should prove role separation, state separation, safe error handling, backend
status replacement, and absence of accidental broader lifecycle UI.

Next: 52.49 should decide whether reschedule, completion, or another fix pass
is the next safe lifecycle lane.

## D103 - Professional completion before reschedule

Task: 52.49

Decision: Add professional appointment completion before reschedule.

Reason: Completion is the narrower next lifecycle action because it is
professional-only, requires no trusted request body, and lets the backend
enforce assigned professional, `ACCEPTED` status, and scheduled-end timing.
Reschedule needs new time/duration selection and availability UX, so it should
remain a separate decision/runtime lane.

Next: 52.50 should wire professional completion for accepted appointments after
scheduled end time and keep reschedule, payments, notifications, calendar,
reviews, notes, and prescriptions deferred.

## D104 - Professional appointment completion wired

Task: 52.50

Decision: Appointments may expose `Complete` only to authenticated
`PROFESSIONAL` sessions for accepted appointments whose scheduled end time has
passed. The screen calls `SchedulingRepository.completeAppointment` and replaces
the visible status only from the backend response.

Reason: This keeps the frontend aligned with the backend lifecycle boundary
without trusting client-supplied ownership, status, payment, notification,
calendar, review, note, or prescription state. Patients do not see completion,
premature accepted appointments do not expose completion, and completed
appointments do not expose duplicate completion.

Next: 52.51 should run an appointment completion regression pass before any
reschedule decision or broader scheduling feature expansion.

## D105 - Completion regression before reschedule decision

Task: 52.51

Decision: Pause runtime appointment lifecycle expansion after professional
completion and run a focused completion regression checkpoint before deciding
reschedule.

Reason: Completion now works through the backend for professional users, but
reschedule has a larger UX and product surface: time selection, availability
re-checking, owner rules, conflict behavior, and terminal-state behavior. The
regression pass proves completion edge cases and confirms broader controls did
not slip into the Appointments screen.

Next: 52.52 should decide whether scheduling pauses for a broader regression
checkpoint or starts a dedicated reschedule UX decision. Do not add runtime
reschedule behavior in 52.52.

## D106 - Scheduling core regression before reschedule

Task: 52.52

Decision: Pause scheduling feature expansion after professional completion and
run a broader scheduling core regression checkpoint next.

Reason: The current scheduling core now spans Search public professionals,
public availability, generated request options, backend appointment requests,
own appointment list, patient cancellation, professional availability
management, professional accept/decline, and professional completion. Before
adding reschedule, the project should prove the combined surface and confirm no
local fallback, fake success, or broader deferred UI has slipped in.

Reschedule remains deferred because it needs a separate UX/product decision for
actor rules, eligible statuses, new time/duration selection, availability
re-checks, conflict handling, audit, notifications, calendar, and payment
boundaries.

Next: 52.53 should run the scheduling core regression checkpoint. Do not add
runtime reschedule behavior in 52.53.

## D107 - Scheduling core regression checkpoint complete

Task: 52.53

Decision: The scheduling core has enough focused regression proof to move to a
post-regression lane decision rather than adding more runtime behavior in this
slice.

Reason: Search public listing/availability/request, Appointments own-list and
lifecycle actions, selectedDates availability management, and scheduling
repository payload boundaries now have explicit focused coverage. Tests also
guard against seeded fallback, raw backend error exposure, fake success, and
accidental reschedule/payment/notification/calendar/review/notes/prescription/
call/admin UI.

Next: 52.54 should decide whether to define reschedule UX, move to another
backend-completed surface, or run a real-device/staging smoke checkpoint.

## D108 - Reschedule UX boundary before runtime wiring

Task: 52.54

Decision: Continue the scheduling lane with a dedicated appointment reschedule
UX/product boundary decision before any runtime reschedule UI or repository
call is wired.

Reason: The scheduling core regression checkpoint proves the current path, and
reschedule is the remaining backend-completed appointment lifecycle method
present in the Flutter repository boundary. However, reschedule affects actor
rules, eligible statuses, time/duration selection, availability re-checks,
conflicts, audit expectations, and future notification/calendar/payment
boundaries. Those rules should be made explicit before implementation.

Next: 52.55 should decide the appointment reschedule UX boundary. It should not
call `SchedulingRepository.rescheduleAppointment` or add runtime reschedule UI.

## D109 - Constrained reschedule UX boundary accepted

Task: 52.55

Decision: Add appointment reschedule to the scheduling milestone as a narrow
runtime slice after this decision. The first UI should expose reschedule only to
known patient/professional sessions on upcoming `REQUESTED` or `ACCEPTED`
appointments, reuse existing public availability and generated request options,
send only `requestedStartAt` and `durationMinutes`, and replace the visible
appointment from the backend response.

Reason: Backend ADR 0024 already supports patient/professional owner
reschedule for `REQUESTED` and `ACCEPTED`, returns status to `REQUESTED`, and
re-enforces active availability. Reusing the proven request-option generator
keeps the UI bounded and avoids free-text date/time invention.

Next: 52.56 may wire this constrained reschedule path. It must keep payments,
notifications, calendar sync, reviews, calls, admin override, notes,
prescriptions, medical records, free-text datetime entry, and reschedule reasons
deferred.

## D110 - Constrained appointment reschedule wired

Task: 52.56

Decision: The Appointments screen now wires the narrow patient/professional
reschedule path from existing scheduling surfaces. It shows `Reschedule` only
for patient or professional sessions on upcoming `REQUESTED` or `ACCEPTED`
backend appointment cards, loads public availability for that appointment's
professional, reuses generated request options, sends only `requestedStartAt`
and `durationMinutes`, and replaces visible status from the backend response.

Reason: Backend and frontend contracts already define owner-only reschedule,
backend availability enforcement, and `REQUESTED` response authority. Reusing
the existing public availability and request-option helper keeps the behavior
bounded and avoids fake free-text datetime, local fallback, or invented
reschedule-policy features.

Next: 52.57 should run an appointment reschedule regression pass. Do not add
payments, notifications, calendar sync, reviews, calls, admin override, notes,
prescriptions, medical records, patient completion, no-show/disputes, free-text
datetime entry, or reschedule reasons in that regression slice.

## D111 - Appointment reschedule regression complete

Task: 52.57

Decision: The constrained appointment reschedule path has enough focused
regression proof to stop reschedule-specific implementation for now and move to
a scheduling pause/smoke/checkpoint decision.

Reason: Tests now cover patient and professional success paths, backend
`REQUESTED` response handling, narrow generated-option payload behavior,
non-patient/non-professional hiding, recent and terminal hiding, empty generated
availability handling, safe availability/reschedule failures, and absence of
broader deferred payment/notification/calendar/review/call/admin/notes/
prescription UI.

Next: 52.58 should decide whether the scheduling/appointment core can pause for
a broader checkpoint, needs a real-device/staging smoke, or needs a small QA/fix
slice from regression findings. It should not add runtime behavior.

## D112 - Scheduling core should smoke before more features

Task: 52.58

Decision: Pause scheduling feature expansion and run a staging smoke checkpoint
next.

Reason: The scoped scheduling core now has local regression proof for public
listing, public availability, appointment request, own appointment list,
patient cancellation, professional accept/decline, professional completion,
patient/professional reschedule, professional availability management, safe
errors, no local fallback, and absence of broader deferred controls. The
remaining confidence gap is not another local feature; it is app-build/staging
proof against configured backend data.

Next: 52.59 should run a scheduling core staging smoke checkpoint. It should
prove only what available staging accounts/data can honestly prove, document any
blocked paths exactly, and avoid runtime feature work or fake seed data.

## D113 - Scheduling staging smoke partially proven

Task: 52.59

Decision: Treat scheduling staging smoke as partially proven, not complete
end-to-end proof.

Reason: The developer-private staging proxy now reaches `/health` and
`/health/ready`; database, migrations, email, and Google auth report `ok`; the
Flutter app builds as a staging-configured debug APK; unauthenticated protected
scheduling routes return `401`; and the public professionals route is reachable.
However, the public professionals list is empty, and the repo does not contain
staging patient/professional accounts, verified professional data, availability
windows, or appointment seed data. Therefore public availability, appointment
request/list/lifecycle, professional availability management, completion, and
reschedule are not end-to-end staging-proven.

Next: 52.60 should decide whether to create deliberate scheduling staging test
data/accounts or move to another backend-completed surface while keeping
scheduling smoke blocked on data.

## D114 - Scheduling smoke requires deliberate staging data

Task: 52.60

Decision: Do not create ad hoc scheduling staging data from the Flutter repo.
Keep full scheduling end-to-end staging smoke blocked until a deliberate
backend/staging data setup exists, and choose the next Flutter lane in a
separate decision slice.

Reason: Task 52.59 proved backend reachability, provider readiness, protected
route guards, and the staging-configured APK build, but the missing proof is
owned staging state: patient/professional accounts, a verified public
professional, availability windows, and an appointment path. Creating one-off
users or appointments from the Flutter repo would hide data ownership and make
the smoke hard to reproduce.

Next: 52.61 should decide the next backend-completed Flutter surface after
reviewing the completed surface map, deferred-work register, current
profile/verification/auth/account status, and the scheduling staging-data
blocker. It should not implement runtime behavior.

## D115 - Patient self profile is next backend-completed Flutter surface

Task: 52.61

Decision: Choose patient self profile as the next backend-completed Flutter
surface, but require a Settings/Profile mapping decision before runtime wiring.

Reason: Scheduling end-to-end smoke is blocked on deliberate staging data;
verification upload/list is not ready while staging reports
`verificationStorage: disabled`; admin verification dashboard is outside the
mobile milestone; phone/OTP and MFA remain backend-deferred; and public
professional detail lacks a documented detail route. Patient self profile has
`GET/PUT /patients/me` already represented in the Flutter repository boundary
and belongs to the existing account/settings surface, but the current UI fields
do not map cleanly to the backend contract.

Next: 52.62 should define how Settings/Profile maps to patient profile fields
before any runtime read/update. It should separate patient profile data from
username, email, auth/security, public profile, verification, scheduling, and
destructive account actions.

## D116 - Patient profile Settings/Profile mapping is read-first

Task: 52.62

Decision: The first patient profile runtime slice should read
`ProfileRepository.patientMe` in Settings/Profile, display backend `name` where
safe, show `age` and `location` as read-only summary values when returned, and
leave the existing local save flow unchanged. It should not call
`updatePatientMe` or create patient profile data.

Reason: The backend patient profile contract owns only `name`, `age`, and
`location`, while the current Settings/Profile UI contains first name, last
name, username, email, and bio. Username, email, auth/security state, public
profile data, verification, scheduling, and destructive account actions must
not be sent to `/patients/me`. A read-first slice proves session ownership,
404 empty-profile handling, safe errors, and display integration before any
mutation contract is attempted.

Next: 52.63 should wire patient profile read to Settings/Profile with safe
loading/error/empty-profile states and no patient profile mutation.

## D117 - Patient profile read wired without mutation

Task: 52.63

Decision: Settings/Profile now reads patient self profile through
`ProfileRepository.patientMe`, displays backend patient `name`, `age`, and
`location` as read-only profile data, and preserves the existing local save
flow for local-only fields. It does not call `updatePatientMe` or create patient
profile data.

Reason: This proves the authenticated patient profile read boundary without
mixing patient profile data with username, email, bio, auth/security,
verification, scheduling, or destructive account behavior. Mutation remains
too broad until a focused update contract and UI are defined.

Next: 52.64 should run a patient profile read regression checkpoint before any
patient profile update slice is considered.

## D118 - Patient profile read regression passed

Task: 52.64

Decision: Treat patient profile read as regression-proven and pause
read-specific work.

Reason: Focused tests and analyzer prove Settings/Profile reads patient profile
successfully, handles empty and failure states safely, preserves the local save
flow, and does not call `updatePatientMe`. The remaining question is not read
stability; it is whether a constrained patient profile update UX is safe given
the current Settings/Profile field mismatch.

Next: 52.65 should decide whether to define patient profile update behavior or
move to another backend-completed surface. It should not implement runtime
mutation.

## D119 - Patient profile update boundary is name-only

Task: 52.65

Decision: Proceed with a constrained patient profile name update as the next
runtime slice. The update may combine Settings/Profile first name and last name
into backend `name` and call `ProfileRepository.updatePatientMe`; it must not
send age, location, username, email, bio, user id, role, phone, password,
auth/security data, verification data, scheduling data, public profile data, or
destructive account data.

Reason: Patient profile read is regression-proven and the backend update route
exists, but the current Settings/Profile UI only has editable name fields that
map to the backend patient profile contract. Age and location are currently
read-only summaries, while username, email, bio, and account/security controls
belong to separate contracts.

Next: 52.66 should wire patient profile name update from Settings/Profile with
safe loading/success/error states and focused tests proving the payload remains
name-only.

## D120 - Patient profile name update wired

Task: 52.66

Decision: Settings/Profile now updates backend patient profile `name` through
`ProfileRepository.updatePatientMe` using combined first and last name only.
The existing local save behavior remains responsible for username, email, and
bio, and backend failure blocks a false success claim.

Reason: This implements the constrained update boundary from D119 without
mixing age, location, username, email, bio, auth/security, verification,
scheduling, public profile, or destructive account data into `/patients/me`.

Next: 52.67 should run a patient profile name update regression checkpoint
before any broader profile/account surface is selected.

## D121 - Patient profile name update regression passed

Task: 52.67

Decision: Treat the current patient profile name update as regression-proven
for the scoped frontend/backend milestone boundary.

Reason: Focused evidence proves Settings/Profile sends only backend patient
`name`, does not send age/location, blocks false local success on backend
failure, preserves username/email/bio as local/deferred fields, and keeps
auth/security, verification, scheduling, public profile, and destructive
account behavior out of `/patients/me`.

Next: 52.68 should decide the next backend-completed Flutter surface from the
completed-surface map and deferred-work register before any new runtime wiring.

## D122 - Specialist Details selected as next public-professional surface

Task: 52.68

Decision: Select Specialist Details public professional/availability wiring as
the next narrow backend-completed Flutter surface.

Reason: Patient profile name update is regression-proven, scheduling staging
smoke remains blocked on deliberate staging data, verification upload/list
requires larger file/storage/document-state UX decisions, and admin dashboard
work is a separate role surface. Search already consumes public verified
professionals, public availability, and appointment request repository
boundaries, while Specialist Details remains a visible local provider-detail
surface that can be moved toward the same backend-backed public data without
inventing a new backend route.

Next: 52.69 should wire Specialist Details to public professional and public
availability data only where a backend professional id can be resolved
honestly. It must not invent a public detail endpoint or include verification,
admin, payments, reviews, calls, calendar sync, notes, prescriptions, staging
data, or production claims.

## D123 - Specialist Details public availability wired

Task: 52.69

Decision: Specialist Details now uses existing public professional and public
availability repository surfaces when a backend public professional id is
available.

Reason: This moves a visible provider-detail surface away from seeded local
slots while staying inside the accepted backend contract. The route resolves
the passed id from `ProfileRepository.publicProfessionals`, renders public
profile fields, reads `SchedulingRepository.publicAvailability`, generates
bounded appointment request options, and submits selected requests through
`SchedulingRepository.requestAppointment`. No public detail endpoint,
verification/admin behavior, payment, review, call, calendar, note,
prescription, staging-data, or production-release behavior was added.

Next: 52.70 should run a Specialist Details public availability regression
checkpoint before another runtime surface is selected.

## D124 - Specialist Details public availability regression passed

Task: 52.70

Decision: Treat Specialist Details public professional/availability wiring as
regression-proven for the current frontend/backend milestone boundary.

Reason: Focused evidence proves backend id resolution from public listing data,
Search handoff into `specialistDetails`, public availability reads, generated
appointment request payloads, safe availability/request failures, unresolved-id
handling, no local slot fallback in the backend path, and dashboard local
compatibility for older local-only navigation. Deferred work remains explicit:
no public detail endpoint, Find Mentor replacement, verification/admin,
payments, reviews, calls, calendar sync, notes, prescriptions, staging data, or
production claims were added.

Next: 52.71 should decide the next surface after Specialist Details regression
before any new runtime wiring.

## D125 - Find Mentor selected as next public-provider surface

Task: 52.71

Decision: Select Find Mentor public professional replacement as the next narrow
backend-completed Flutter surface.

Reason: Specialist Details is regression-proven, and Find Mentor remains the
other visible provider-discovery entry point still backed by local mentor cards
and local slot chips. It can use existing `ProfileRepository.publicProfessionals`
and route selected backend ids into the already-proven Specialist Details
backend path. Verification upload/list, admin dashboard, scheduling staging
data, Google link/unlink, payments, reviews, calls, calendar sync, notes,
prescriptions, and production release work remain larger separate lanes.

Next: 52.72 should wire Find Mentor to public professionals, preserving
local-only compatibility only when no repository is available and avoiding
local slot fallback in the backend path.

## D126 - Find Mentor public professionals wired

Task: 52.72

Decision: Find Mentor now uses the existing public professional repository
boundary when available.

Reason: This removes the last visible provider-discovery local-card seam in the
current public-professional lane without inventing backend behavior. The
backend-capable path reads `ProfileRepository.publicProfessionals`, renders
safe loading/error/empty states, filters public professionals by category or
specialty, and routes `View details` to `specialistDetails` with the backend
public professional id. It does not fall back to seeded local mentors after
backend failure, does not expose local slot chips in the backend path, and does
not claim direct booking from Find Mentor.

Next: 52.73 should run a focused Find Mentor public professionals regression
checkpoint before selecting another surface.

## D127 - Find Mentor public professionals regression passed

Task: 52.73

Decision: Treat Find Mentor public professional wiring as regression-proven for
the current frontend/backend milestone boundary.

Reason: Focused evidence now covers backend public listing success, loading,
empty, safe failure, category filtering, backend id handoff to Specialist
Details, absence of seeded local slot fallback/direct fake booking in the
backend path, dashboard local compatibility, Specialist Details compatibility,
and deferred-work accuracy. No public detail endpoint, verification/admin
behavior, payment, review, call, calendar, note, prescription, staging-data, or
production-release behavior was added.

Next: 52.74 should decide the next backend-completed Flutter surface before any
new runtime wiring.

## D128 - Professional verification upload/list selected next

Task: 52.74

Decision: Select professional verification upload/list as the next
backend-completed Flutter lane, but require a decision-only UI/API boundary
slice before runtime implementation.

Reason: Search, Specialist Details, Find Mentor, patient profile name update,
professional profile read/bio update, availability, and appointment lifecycle
paths have focused proof for the current milestone boundary. Scheduling staging
smoke remains blocked on deliberate backend/staging data rather than Flutter
feature expansion. Professional verification upload/list is a completed backend
surface, but it handles private documents and signed upload URLs, so Flutter
must define file picker constraints, document type/status UX, upload-init/PUT
upload/upload-complete boundaries, safe failures, and storage-readiness handling
before code.

Next: 52.75 should define the professional verification upload/list UI boundary
without implementing runtime behavior.

## D129 - Professional verification upload/list boundary accepted

Task: 52.75

Decision: The first professional verification Flutter implementation should
start with a repository/API boundary, then a Manage Profile-owned verification
screen that can list owner document statuses and perform one controlled upload
flow.

Reason: Verification documents are private and sensitive. The app must handle
upload-init, signed upload PUT, upload-complete, and owner document list/status
without surfacing signed URLs, object keys, local file paths, file contents,
provider credentials, or raw checksums. Manage Profile is the correct first
entry point because it is the professional-owned profile surface; Account mixes
patient/auth settings and Public Profile must not expose private verification
documents.

Next: 52.76 should add verification entities, API client, repository, signed
upload PUT helper, and focused tests without runtime screen wiring or admin
review UI.

## D130 - Professional verification repository boundary added

Task: 52.76

Decision: Add the Flutter repository/API boundary for professional-owned
verification documents before wiring the Manage Profile runtime screen.

Reason: Verification uploads involve private documents and short-lived signed
storage URLs. The app now has safe `VerificationDocument` and
`VerificationUploadRequest` entities, a `VerificationApiClient`, and a
`VerificationRepository` that requires a stored session, sends bearer auth to
protected backend routes, performs upload-init, uses the signed upload URL only
inside the data boundary, and completes uploads with allowed metadata. Focused
tests prove owner document list parsing, allowed upload-init metadata, internal
signed PUT without bearer auth, upload-complete metadata, missing-session and
missing-config failures, and safe server-error mapping. Runtime screen wiring,
file-picker UI, admin review, previews/downloads, rejection reasons, public
document exposure, staging data, and production claims remain deferred.

Next: 52.77 should wire a Manage Profile-owned verification documents shell
against `VerificationRepository.documents` and keep upload UI scoped safely if
file-picker/runtime upload UX needs a follow-up slice.

## D131 - Professional verification documents shell wired

Task: 52.77

Decision: Wire the first runtime professional verification screen as a
Manage Profile-owned owner-document list/status shell.

Reason: The repository/API boundary is now available, and the safest first
runtime step is read-only visibility of the current professional's own
verification document statuses. The new route reads
`VerificationRepository.documents`, shows loading, empty, and safe backend
error states, displays only safe metadata, and avoids signed URL, object key,
local path, file preview, raw checksum, admin review, rejection reason, public
document, staging-data, or production-release claims. Upload remains locked
because the app has `image_picker` as a direct dependency but no direct
PDF-capable file picker/file selector dependency.

Next: 52.78 should decide the upload UI and file-picker dependency boundary
before adding runtime upload behavior.

## D132 - Professional verification upload picker boundary accepted

Task: 52.78

Decision: The professional verification upload UI should use a PDF-capable
file picker boundary in the next runtime implementation slice.

Reason: The accepted verification upload boundary supports PDF, JPEG, and PNG
documents, while the current direct dependency set only has `image_picker`.
Using `image_picker` would silently exclude PDFs and create an incomplete
verification upload flow. The existing repository already accepts the required
metadata and bytes through `VerificationUploadRequest`, so the next runtime
slice should add a suitable picker dependency, validate one selected PDF/JPEG/PNG
file under a 10 MB app-side cap, call `VerificationRepository.uploadDocument`,
show upload/success/safe-error states, and reload owner documents. Checksum,
previews, admin review, public document exposure, staging data, and production
claims stay deferred.

Next: 52.79 should wire the professional verification upload flow with the
selected PDF-capable picker dependency and focused widget tests.

## D133 - Professional verification upload flow wired

Task: 52.79

Decision: Wire the first controlled professional verification upload flow in
the owner verification documents screen.

Reason: The repository/API boundary and picker decision are complete. The app
now uses `file_picker` for PDF/JPEG/PNG selection, lets the professional choose
one MVP document type, applies app-side file type and 10 MB validation, calls
`VerificationRepository.uploadDocument` with safe metadata and bytes, shows
safe cancel/error/success states, and reloads owner documents after success.
The screen still does not expose signed URLs, object keys, local full paths,
file previews, raw checksum values, admin review data, public document access,
staging data, or production claims. Checksum, previews, admin review, rejection
reasons, scanning claims, and broader upload management remain deferred.

Next: 52.80 should run a focused professional verification upload regression
checkpoint before selecting another backend-completed surface.

## D134 - Professional verification upload regression passed

Task: 52.80

Decision: Treat the professional verification upload/list Flutter lane as
regression-proven for the current frontend milestone boundary.

Reason: Focused evidence now covers owner document list success, empty, and
safe failure states; upload success with repository metadata and list reload;
document type selection; picker cancellation; unsupported file rejection; 10 MB
size guard; safe backend upload failure; direct `file_picker` dependency
presence; focused analyzer cleanliness; and absence of private verification
storage data or unrelated module claims in the runtime screen. Checksum,
previews/downloads, admin review, rejection reasons, scanning claims, public
document exposure, staging data, and production claims remain deferred.

Next: 52.81 should decide the next backend-completed Flutter surface before any
new runtime wiring.

## D135 - Professional basic profile field editing selected next

Task: 52.81

Decision: Select professional basic profile field editing as the next
backend-completed Flutter surface, but require a boundary decision before any
runtime code.

Reason: The verification upload/list lane is now regression-proven, while
scheduling staging smoke remains blocked on deliberate backend-owned staging
data and admin verification remains a separate role surface. The existing
professional profile backend contract accepts `displayName`, `category`,
`specialty`, and `bio`; bio is already wired, but name/category/specialty edit
behavior still needs a safe UI boundary. Website and address are not accepted
professional profile fields in the current contract and must remain deferred.

Next: 52.82 should define the professional basic profile edit boundary before
runtime name/category/specialty wiring.

## D136 - Professional display name update boundary accepted

Task: 52.82

Decision: Wire the next professional profile runtime slice as a display-name-only
update from the existing `editYourName` route.

Reason: `editYourName` has a single name field, while the backend professional
profile update route requires the existing `category` and can preserve
`specialty` and `bio`. Updating category or specialty from that screen would
require new UI or hidden assumptions. The safe runtime shape is to read the
existing professional profile, block empty-profile creation, save only the new
`displayName`, and preserve existing `category`, `specialty`, and `bio`.
Website, address, account identity, verification, availability, appointment,
payment, review, call, calendar, note, prescription, staging, and production
claims remain out of scope.

Next: 52.83 should wire professional display name update from `editYourName`
with focused Manage Profile tests.

## D137 - Professional display name update wired

Task: 52.83

Decision: `editYourName` now updates backend professional `displayName` only.

Reason: The screen reads the current professional profile, pre-fills backend
`displayName`, validates the submitted name, then calls
`ProfileRepository.updateProfessionalMe` with the new `displayName` while
preserving the existing `category`, `specialty`, and `bio`. Empty professional
profiles block save instead of creating partial profiles. Save success appears
only after repository success, and backend failures show safe copy.
Category/specialty editing, profile creation, website/address persistence,
account identity, verification, availability, appointment, payment, review,
call, calendar, note, prescription, staging, and production behavior remain
out of scope.

Next: 52.84 should run a focused professional display name update regression
checkpoint before selecting any broader profile-editing surface.

## D138 - Professional display name update regression passed

Task: 52.84

Decision: Treat the professional display-name-only update path as
regression-proven for the current frontend milestone boundary.

Reason: Focused tests and analyzer prove backend `displayName` prefill,
display-name-only save, preservation of existing `category`, `specialty`, and
`bio`, validation failure without repository update, empty-profile blocking
without partial profile creation, and safe backend save failure without false
success or raw error text. Broader field searches confirm no new runtime
website/address, verification, payment, review, call, calendar, prescription,
staging, or production behavior was added in this lane.

Next: 52.85 should decide the next backend-completed Flutter surface before
any broader profile editing or another product area is wired.

## D139 - Professional category/specialty editing selected next

Task: 52.85

Decision: Select professional category/specialty editing as the next
backend-completed Flutter surface, but require a boundary decision before any
runtime code.

Reason: The professional display-name-only update is regression-proven. The
current backend professional profile contract also accepts `category` and
`specialty`, but the current app has no safe category/specialty edit UI.
Runtime wiring needs a field and validation boundary first. Professional
profile creation, website/address persistence, account identity, verification,
availability, appointment, payment, review, call, calendar, note, prescription,
staging, and production behavior remain out of scope.

Next: 52.86 should define the professional category/specialty edit boundary
before runtime wiring.

## D140 - Professional category/specialty edit boundary accepted

Task: 52.86

Decision: Add a new constrained professional details edit surface for
`category` and optional `specialty`; do not overload the display-name-only
`editYourName` route.

Reason: Manage Profile displays category and specialty together, and the backend
profile update route accepts both fields. The app does not have an
authoritative category taxonomy, so the first runtime slice should use a
free-text required category field and optional specialty field while preserving
existing `displayName` and `bio`. Empty professional profiles must block save
instead of creating partial profiles. Profile creation, website/address
persistence, account identity, verification, availability, appointment,
payment, review, call, calendar, note, prescription, staging, and production
behavior remain out of scope.

Next: 52.87 should wire the constrained category/specialty update with focused
Manage Profile tests.

## D141 - Professional category/specialty update wired

Task: 52.87

Decision: Add `editProfessionalDetails` as the constrained runtime surface for
professional `category` and optional `specialty`, reachable from Manage Profile
Basic without changing the display-name-only `editYourName` route.

Reason: The boundary from D140 required category/specialty editing to stay
separate from display-name editing and broader profile modules. The new route
reads the existing professional profile, pre-fills category/specialty, requires
category, sends cleared specialty as `null`, preserves existing `displayName`
and `bio`, blocks empty-profile creation, and shows safe failure states.
Website/address persistence, account identity, verification, availability,
appointments, payments, reviews, calls, calendar sync, notes, prescriptions,
staging data, and production claims remain out of scope.

Next: 52.88 should run a focused regression checkpoint before selecting any
broader profile surface.

## D142 - Professional category/specialty update regression passed

Task: 52.88

Decision: Treat the constrained professional category/specialty update path as
regression-checked for the current frontend milestone boundary.

Reason: Focused tests prove Manage Profile entry separation from the
display-name edit path, backend category/specialty prefill, category-required
validation, preservation of existing `displayName` and `bio`, cleared specialty
as `null`, empty-profile blocking without partial profile creation, and safe
backend save failure without raw error text. Targeted searches found no new
runtime behavior for website/address, account identity, verification,
availability, appointments, payments, reviews, calls, calendar sync, notes,
prescriptions, staging data, production claims, or profile creation.

Next: 52.89 should decide the next backend-completed Flutter surface before any
additional runtime wiring.

## D143 - Google account linking selected next

Task: 52.89

Decision: Select protected Google account linking as the next
backend-completed Flutter surface, but require a UI boundary decision before
runtime wiring.

Reason: The backend has `POST /auth/google/link`, and the Flutter
`AuthRepository` already exposes `googleLink`. Google ID-token acquisition is
already wired for sign-in when `GOOGLE_SIGN_IN_SERVER_CLIENT_ID` is configured.
This makes linking a narrow account/security lane that can move without
scheduling staging seed data or verification storage. Profile creation,
patient age/location mutation, website/address persistence, public detail,
admin dashboard behavior, phone/OTP, MFA, payments, notifications, reviews,
calls, calendar sync, notes, prescriptions, production OAuth, release signing,
iOS proof, and production claims remain out of scope.

Next: 52.90 should define the Google account linking UI boundary before any
runtime UI is implemented.

## D144 - Google account linking UI boundary accepted

Task: 52.90

Decision: Place protected Google account linking in Account as a dedicated
Google account entry below Authentication and before Settings & Profile. The
next runtime slice may use configured `GoogleIdTokenProvider` to obtain a real
ID token and call `AuthRepository.googleLink`, with safe loading, success, and
error states.

Reason: Linking modifies the authenticated account's provider identity, so
Account is the correct host surface. The app already has Google ID-token
acquisition and a repository method for protected linking. The UI must stay
disabled when Google provider config is missing, must not mutate local
session/user role/status/email after linking, and must not expose raw provider
tokens, provider payloads, raw backend errors, or internal identifiers. Google
sign-up role selection, unlinking, cross-email/recovery linking, recent re-auth,
phone/OTP, MFA, production OAuth, release signing, iOS proof, profile creation,
admin verification, payments, notifications, reviews, calls, calendar sync,
notes, prescriptions, staging data, and production claims remain deferred.

Next: 52.91 should wire the constrained Google account linking action with
focused Account tests.

## D145 - Google account linking wired

Task: 52.91

Decision: Wire protected Google account linking from Account as a constrained
configured-provider action. The Account screen now shows `Google account` below
Authentication, uses `GoogleIdTokenProvider.signInIdToken()` for the real ID
token, calls `AuthRepository.googleLink`, and shows safe loading, success, and
error states.

Reason: The UI boundary in D144 was narrow enough to implement without adding
new provider policy or account mutation behavior. Success is tied to the
repository call, provider failures do not call the backend link endpoint, and
backend validation/unauthorized failures are mapped to safe user-facing copy.
The frontend does not mutate session, email, role, status, or profile fields
after linking; those remain backend-owned. Google sign-up role selection,
unlinking, cross-email/recovery linking, recent re-authentication, phone/OTP,
MFA, production OAuth, release signing, iOS proof, profile creation, admin
verification, payments, notifications, reviews, calls, calendar sync, notes,
prescriptions, staging data, and production claims remain deferred.

Next: 52.92 should run a Google account linking regression checkpoint before
choosing any broader account/provider surface.

## D146 - Google account linking regression passed

Task: 52.92

Decision: Treat the constrained Google account linking path as
regression-checked for the current frontend milestone boundary.

Reason: Focused Account tests prove the accepted placement below
Authentication, disabled missing-config behavior, configured provider token
handoff to `AuthRepository.googleLink`, success only after repository success,
provider failure without backend link call, backend validation/unauthorized
safe copy without raw text, and no fake local session/user email/role/status
mutation. Source inspection also confirms no Google token, provider payload,
Google unlinking, Google sign-up role selection, production OAuth claim, or
broader account/provider behavior is exposed by this slice.

Next: 52.93 should decide the next backend-completed Flutter surface before any
additional runtime wiring.

## D147 - Admin verification review boundary selected next

Task: 52.93

Decision: Select an admin verification review surface boundary decision as the
next backend-completed Flutter lane. The next slice should decide whether the
admin verification queue, private signed-read, and approve/reject routes belong
in this Flutter app, a separate admin dashboard, or another frontend surface
before any runtime admin UI is implemented.

Reason: The major patient/professional mobile surfaces from completed backend
work are already wired or regression-checked: auth/session/account, Google
sign-in/link, patient and professional profile, professional verification
upload/list, public professionals, public availability, professional
availability, and appointment lifecycle. The remaining backend-completed
surface with meaningful product impact is reviewer-side verification. Because
that surface is sensitive and may not belong in the patient/professional app,
it needs an explicit placement/access/signed-read/approve-reject boundary before
runtime implementation. Payments, notifications, reviews, calls, calendar sync,
notes, prescriptions, phone/OTP, MFA, staging data, production release, and
runtime admin UI remain deferred.

Next: 52.94 should define the admin verification review surface boundary.

## D148 - Admin verification review belongs outside mobile app

Task: 52.94

Decision: Do not implement admin verification review inside the current
patient/professional Flutter mobile app. The accepted target surface for admin
verification queue, signed-read document review, and approve/reject decisions
is a separate admin dashboard or admin web console.

Reason: The backend admin verification routes require `ADMIN` or
`SUPER_ADMIN`, expose short-lived signed-read document access, and can change
professional verification status. That is a sensitive reviewer operations
workflow and should not be mixed into the patient/professional mobile shell by
default. A separate admin surface keeps route exposure, role complexity, signed
URL handling, document review ergonomics, and audit posture cleaner. The mobile
app should continue to own professional upload/list behavior only. Runtime
admin routes, hidden admin mode, signed-read handling, approve/reject controls,
rejection reasons, admin audit display, staging claims, production readiness,
payments, notifications, reviews, calls, calendar sync, notes, prescriptions,
phone/OTP, and MFA remain deferred.

Next: 52.95 should run a final backend-completed mobile surface checkpoint
before choosing mobile milestone stabilization or another scoped mobile-facing
backend surface.

## D149 - Mobile-facing completed backend surfaces checkpoint passed

Task: 52.95

Decision: Treat the currently completed backend surfaces that clearly belong in
the patient/professional mobile app as first-pass wired or intentionally
excluded. Move the mobile app into a stabilization/regression planning lane
rather than selecting another runtime feature.

Reason: The updated completed-surface map and checkpoint found coverage for
auth/session/account, Google sign-in/link, patient profile, professional
profile, professional verification upload/list, public professionals, public
availability, professional availability, and appointment request/list/lifecycle.
Admin verification review is intentionally assigned to a separate admin
dashboard/web console. Remaining items such as phone/OTP, MFA, Google unlinking,
payments, notifications, reviews, calls, calendar sync, notes, prescriptions,
messaging backend, community backend, content backend, public staging access,
production app links, release signing, and store readiness are deferred modules
or release/infrastructure work, not missed first-pass wiring for completed
mobile-facing backend routes.

Next: 52.96 should define a mobile backend integration stabilization plan.

## D150 - Move to grouped mobile backend integration regression

Task: 52.96

Decision: Accept `MOBILE_BACKEND_INTEGRATION_STABILIZATION_PLAN.md` as the
stabilization plan for the already-wired backend mobile milestone. The next
slice should execute grouped regression suites for auth/session/account,
profile/verification, discovery/booking, and scheduling lifecycle before adding
new mobile product surfaces.

Reason: Task 52.95 found no remaining backend-completed surface that clearly
belongs in the patient/professional Flutter app and is still waiting for
first-pass wiring. The responsible next step is evidence: run the grouped
tests, focused analyze, docs checks, and manual smoke checklist where data is
available. Any failures should become targeted cleanup slices instead of
opening broad new feature lanes.

Next: 52.97 should execute the mobile backend integration regression pass.

## D151 - Mobile backend integration regression passed

Task: 52.97

Decision: Treat the already-wired backend mobile milestone as regression-passed
at the grouped Flutter test/analyze level. The next slice should define the
handoff and staging-data boundary before any additional product or release lane
starts.

Reason: The regression pass proved the scoped auth/session/account,
profile/verification, discovery/booking, and scheduling lifecycle suites after
fixing one isolated password-recovery widget-test harness gap. Focused analyze
reported no issues. This is enough to move from "is the wired mobile surface
internally coherent?" to "what exact handoff/staging/release lane comes next?"
It is not enough to claim production release, public staging demo, app-link
readiness, store readiness, admin dashboard completion, or deferred product
modules.

Next: 52.98 should define the mobile milestone handoff and staging data
boundary.

## D152 - Handoff package before staging or release lanes

Task: 52.98

Decision: Proceed next with a mobile backend milestone handoff package. Treat
staging seed-data/smoke setup, release-signing/app-link readiness, admin
dashboard work, and deferred product modules as separate future lanes.

Reason: Task 52.97 proves the already-wired mobile/backend integration at the
grouped Flutter regression/analyze level, but it does not prove public staging
demo readiness, production release readiness, store readiness, admin dashboard
completion, or deferred product module completion. A handoff package is the
lowest-risk next step because it lets the milestone be presented accurately:
wired and regression-passed for scoped mobile surfaces, with exact remaining
inputs and blockers named.

Next: 52.99 should create the mobile backend milestone handoff package.

## D153 - Mobile backend milestone handoff package ready

Task: 52.99

Decision: Treat `MOBILE_BACKEND_MILESTONE_HANDOFF_PACKAGE.md` as the current
presentation package for the regression-passed mobile backend integration
milestone. Move next to staging seed-data and smoke execution planning.

Reason: The handoff package summarizes wired surfaces, grouped regression
evidence, manual smoke inputs, admin/release/deferred boundaries, and safe
presentation wording. The next missing proof is not more app wiring; it is
staging data and smoke execution against a real backend environment.

Next: 53.1 should define the staging seed data and smoke execution plan.

## D154 - Staging seed data and smoke plan accepted

Task: 53.1

Decision: Accept `STAGING_SEED_DATA_SMOKE_EXECUTION_PLAN.md` as the staging
proof plan for the regression-passed mobile backend milestone. The next slice
should execute the smoke pass only after required staging accounts, seeded data,
API/build config, verification upload access, and cleanup/reset expectations are
confirmed.

Reason: The previous milestone is regression-passed locally, but public staging
or demo confidence requires real backend environment proof. The plan defines the
environment, patient/professional accounts, verified professional data,
availability, appointment lifecycle data, verification upload access, build
commands, manual smoke checklist, evidence requirements, and blocker rules
without committing secrets or creating fake success.

Next: 53.2 should execute the staging seed data and mobile smoke pass, stopping
for project-lead input if required staging inputs are missing.

## D155 - Staging gateway phone install checkpoint accepted as partial proof

Task: 53.2 checkpoint

Decision: Treat the public-staging-gateway Android phone install and launch as
a real partial pass for task 53.2, but do not mark the full staging seed-data
smoke pass complete yet.

Reason: The app now builds with
`CARENET_API_BASE_URL=https://carenet-staging-mobile-gateway-2kbj9ok1.uc.gateway.dev`,
installs on the connected Android phone, and launches under
`com.carenet.app`. During the install proof, an Android native entrypoint
mismatch was found and fixed: `MainActivity` now lives under the
`com.carenet.app` package path instead of `com.example.app_t`.

This proves the app package can run against the public staging gateway, but it
does not prove patient/professional login, verified professional seed data,
availability, appointment request/list/lifecycle, verification upload, or
cleanup/reset behavior.

Next: continue 53.2 by confirming the required staging accounts, seed data, and
cleanup/reset rules from `STAGING_SEED_DATA_SMOKE_EXECUTION_PLAN.md`; stop and
record blockers if any required input is missing.

## D156 - Staging seed and backend lifecycle proof recorded

Task: 53.2 checkpoint

Decision: Treat the staging-only seed data and backend API lifecycle proof as
ready for the real-device phone UI walkthrough, but do not mark task 53.2 fully
complete until the installed app is walked through with the seeded accounts.

Reason: Fresh staging-only patient/professional accounts were created through
the real staging API Gateway. The professional profile was seeded to
`VERIFIED` through Cloud SQL Auth Proxy because the mobile app has no admin
approval path and public listing requires verified professionals. Public
professional listing, public availability, and appointment request, accept,
reschedule, cancel, and completion proof passed through the staging API
Gateway. Passwords are stored only in a local Desktop credential file and are
not committed.

Next: use the installed phone build and the local-only credential file to run
the real-device UI checklist from `STAGING_SEED_DATA_SMOKE_EXECUTION_PLAN.md`.
Record pass/fail evidence without secrets.

## D157 - Role-based onboarding before Google sign-up expansion

Task: APP-55

Decision: CareNet onboarding must branch by role before any broader sign-up or
Google sign-up expansion. The accepted mobile app account types are `PATIENT`
and `PROFESSIONAL`; admin/reviewer accounts remain outside this
patient/professional app. Patient onboarding may collect a minimal profile,
while professional onboarding must lead into professional profile setup,
credential upload, and manual verification before public listing.

Reason: The PRD defines CareNet as a dual-sided healthcare marketplace with
regular users and licensed medical professionals. Google identity proves an
email/account identity, but it does not decide role, collect professional
credentials, or satisfy medical marketplace trust/compliance requirements.
Auto-creating every Google user as a patient or professional would create bad
accounts and later rework.

Consequences: Existing linked users may continue to use Google sign-in, and
signed-in users may link Google from Account when configured. Google sign-up
remains deferred until it can pass through role selection and the same patient
or professional onboarding rules as email/password signup. Future backend work
should define role-based registration and Google sign-up/link behavior before
runtime UI expansion.

Next: the next auth/onboarding implementation lane should define the
role-based backend contract and Flutter role-selection flow before enabling
Google sign-up.

## D158 - Role registration backend contract before runtime onboarding

Task: APP-56

Decision: Use the backend's existing role-capable auth routes, but require
Flutter role selection before any new patient/professional account creation is
treated as product-complete. Email/password registration may submit
`PATIENT` or `PROFESSIONAL` only after the user explicitly enters that role's
onboarding path. Google sign-up must remain disabled until Flutter can call the
backend with both a real Google `idToken` and the selected role, then route the
user into the correct patient or professional onboarding destination.

Reason: The backend already supports `POST /auth/register` with patient and
professional roles and `POST /auth/google/sign-in` with optional role for
first-time Google-created accounts. The current Flutter sign-up path still
hardcodes `PATIENT` and has no professional onboarding branch, so enabling
Google sign-up or broader registration from that surface would create bad
accounts and hide product work behind auth success.

Consequences: Existing linked Google sign-in and signed-in Google account
linking remain valid. First-time Google signup requires a future role-selection
runtime slice. Professional signup must lead to profile setup, credential
upload, and manual verification before public listing. No payment, call,
review, medical note, prescription, admin dashboard, or production compliance
claim is added by this contract.

Next: implement a role-selection onboarding slice before account creation, then
wire email/password registration through the selected role. Google sign-up can
follow only after the same role branch and destinations exist.

## D159 - Role selection before email/password account creation

Task: APP-57

Decision: Add a `signUpRole` route between sign-up entry and `finishSignUp`.
Phone/email sign-up Continue now routes to role selection. Patient selection
passes `PATIENT` into `finishSignUp`; professional selection passes
`PROFESSIONAL`. `finishSignUp` submits the selected backend role instead of
hardcoding `PATIENT`.

Reason: APP-56 established that account creation must not happen without an
explicit patient/professional choice. The backend already accepts both roles,
and the previous Flutter path silently created patient accounts from the shared
finish screen.

Consequences: Patient registration keeps the existing community agreement
destination. Professional registration routes to the existing professional
onboarding surface after backend success, without claiming profile setup,
credential upload, admin verification, or public listing is complete. Google
sign-up remains disabled until the same role branch can safely send `idToken`
plus selected role.

Next: add a focused role-selection regression/checkpoint or continue into
professional onboarding/profile setup only after deciding the next narrow
runtime boundary.

## D163 - Auth signup staging contract fix

Task: APP-62

Decision: Align Flutter email/password signup with the current staging backend
auth contract. `finishSignUp` must register using only `email`, `password`, and
the explicitly selected `PATIENT` or `PROFESSIONAL` role. Patient and
professional profile fields belong to the post-registration setup screens, not
the `POST /auth/register` payload. Flutter password validation must match the
backend 15-character minimum.

Reason: Professional onboarding setup failed because staging was behind the
`CAR-BE-119` Nigeria onboarding profile schema and Flutter still sent a stale
nested `profile` object during registration. The backend now accepts professional
profile setup fields after registration, and the frontend registration payload
must not send rejected fields or weaker password input.

Consequences: Email/password patient and professional signup now has the right
contract boundary for staging profile setup. Google first-time signup remains
separate and is not fixed by this decision. A future Google signup slice must
use a real Google ID token plus explicit role selection, then route into the
same patient/professional setup requirements without trusting Google display
names as professional profile data.

Next: implement `APP-63 - Google First-Time Signup With Role Selection` only if
the project lead wants to continue auth/onboarding; otherwise keep Google signup
visibly disabled and move to the next approved product lane.

## D164 - Google first-time signup requires role selection

Task: APP-63

Decision: Enable Google first-time signup only through the existing
patient/professional role selection boundary. Sign-up Google starts provider
auth only when `GoogleIdTokenProvider` is configured, then `signUpRole` sends
the real Google `idToken` plus selected backend role to `POST /auth/google/sign-in`.
Successful patient signups route to `patientOnboardingSetup`; successful
professional signups route to `medicalProfessional`.

Reason: Google identity can prove account identity, but it cannot choose a
CareNet account type or provide trusted medical professional profile data. The
PRD-backed product boundary requires patient and professional onboarding to stay
explicit, especially for professional credential and practice details in Nigeria.

Consequences: Google signup is no longer a disabled placeholder when configured,
but it still does not skip onboarding, does not trust Google display names as
professional profile authority, and does not add Facebook/Apple signup, Google
unlink, iOS/release OAuth proof, production OAuth consent/app verification,
phone/OTP, MFA, admin review, payments, calls, reviews, notes, or prescriptions.

Next: run device/staging smoke for Google first-time signup when an Android
device is visible to ADB and a suitable test Google account is available.

## D175 - Recover auth onboarding gateway without rolling back backend readiness

Task: APP-ID-015

Decision: Selectively recover the first-launch gateway and role-first signup
method UX from the older APP-66 through APP-73 work. Do not merge those branches
wholesale because they predate APP-ID backend catalog, readiness, profile setup,
and verification guidance work.

Reason: The current frontend milestone had the correct backend contracts but
still displayed the older carousel that pushed users toward phone signup. That
made the visible product feel regressed and inconsistent with the serious
patient/professional onboarding boundary.

Consequences: First launch now offers browse, create account, and sign-in
choices. Create account opens role-first signup. Gateway role selection can then
choose Google or email. Existing email/phone entry flows still validate their
entry data before role selection and finish signup. Google signup still uses a
real provider token and backend readiness routing; no dummy fallback, fake local
account creation, or fake professional approval was introduced.

Next: run APP-ID-016 real-device smoke on the recovered auth onboarding path
before claiming the UX recovery works on phone.

## D176 - Narrow Phase 1 to a healthcare consultation marketplace

Task: APP-P1-001

Decision: The active Phase 1 product is a role-aware healthcare consultation
marketplace. Patient navigation is Home, Find Care, Appointments, Messages, and
Profile. Professional navigation is Home, Schedule, Appointments, Messages, and
Profile. Notifications open from a header bell. Existing social/content,
community, readings/device, emergency, creator, generic schedule/reminder, and
promotion modules leave active navigation and routing, then their exclusive code
is removed after retained-flow regression.

Reason: The broad app contains many local/static speculative modules that do not
prove the consultation value/revenue loop and increase reasoning, testing,
security, and maintenance cost. The working backend already supports the safer
core of auth/onboarding, profile/verification, public professional discovery,
availability, and appointment lifecycle.

Preservation: Proposed archive branch
`archive/pre-phase1-broad-ui-2026-07-22` and annotated tag
`pre-phase1-broad-ui-2026-07-22` must both point exactly to committed baseline
`3e04d6e`. They do not include or claim to preserve unrelated dirty files.

Consequences: Figma and old screens remain references, not product authority.
The newer backend catalog/readiness onboarding stays. The obsolete
`communityAgreement -> notificationAgreement -> medicalAgreement -> medicalEdit`
chain is removed from the active journey later. No local fallback may represent
real booking, professional data, messages, notifications, account persistence,
verification approval, payment, calls, refunds, payouts, or support outcomes.

Communication boundary: Appointment-linked text messaging and video/audio
consultation are approved Phase 1 capabilities. A conversation belongs to an
eligible appointment, its patient, and its assigned professional, and appears in
Messages plus Appointment Detail. Join Consultation appears only in Appointment
Detail. CareNet owns appointment authorization, participant eligibility,
consultation timing, session state, and audit boundaries; an external RTC
provider owns media transport. APP-P1-001 does not implement either capability.

Unresolved: Payment, dual-role accounts, external RTC vendor/session details,
appointment messaging transport/retention details, notification delivery,
support, refunds/follow-up, and payout rules require separate decisions. Do not
invent them.

Next: after project-lead approval, create and verify the archive refs. The only
recommended next runtime slice is `APP-P1-002`, role-aware navigation and active
route pruning.
