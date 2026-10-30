# Deferred work and backend replacement map

## APP-READY-087 Upload Recovery Boundary

APP087B restores cache clearing on explicit authority denial while preserving
recoverable refresh data. RC7 is held for the corrected candidate; its valid
signature is not approval for physical acceptance.

Serialized section loads and file selection do not add signed-URL renewal,
durable upload resume, abandoned-object cleanup or a retention policy. A cancelled
upload may already have an incomplete backend record; the UI does not claim it
was deleted. Do not retry upload-init or upload-complete blindly after an
uncertain result. Backend-owned recovery/cleanup and valid-file/admin/provider
acceptance remain required; no broad source deletion or cloud mutation here.

## APP-READY-082H Permission And Routing Acceptance (IN PROGRESS)

Host channel tests and patient/professional widget tests cover permission mapping,
truthful audio preference and enlarged-text geometry, not Android OS dialogs or
physical audio routes. Keep API-level denial/settings, headset insertion/removal,
Bluetooth and interrupted-call proof for the approved final device session.
Future protected Bluetooth operations need contextual permission before use;
do not restore an unconditional join-time prompt. Native declarations remain.
All1,169 tests, analyzer, debug APK, fresh release lint and local release guards
pass; signed artifacts and CI gates stay open. No cloud,
provider, payment or device operation is authorized by these source results.
Prior082G delivered through PR254, all applicable PR/integration CI green.

## APP-READY-082G Recovery Acceptance (IN PROGRESS)

The confirmed lost-expiry-hint source gap is being repaired with bounded,
foreground, owner-aware HTTP recovery after failed pre-ACK authentication.
157 messaging tests pass; the real401 regression fails without the signal and
passes restored. Full1,153 tests, analyzer, debug APK, fresh623-task lint and
signing/environment/backup/flavor gates pass. Signed artifacts and CI remain
delivery gates; the independent source review is clear.
Do not infer full operational acceptance from these fakes/adapters. Legitimate
session/message delivery, poor-network/process restoration and later physical
device proof remain required. No permission to reset accounts or forge tokens.
No backend/protocol, persistence, dependencies, native, payment, RTC or provider
change; payments remain last/test-only with final separate explicit approval.
082F source delivered in PR253, all PR/integration lanes green; its pending
source-delivery wording below is historical, not a reason to duplicate that work.

## APP-READY-082F Messaging Transport Acceptance (IN PROGRESS)

Source transport-readiness work follows `PHASE_1_MESSAGING_REALTIME.md` within
the sole NEXT task APP-READY-082. It is not delivered and does not complete the
readiness program. Final-source analysis, staging debug APK and all 1,126 tests
(968 retained plus 158 additions) pass after the inbox catch-up repair.
Diff checks pass. Repaired-source release environment
checks pass all 30 probes and eight packaging graphs. Fresh release lint
(623 executed tasks) and signing regressions pass. Signed staging artifacts and
CI remain delivery gates.

The standalone staging ingress has negative-boundary evidence only: health,
unrelated HTTP rejection and missing/malformed/invalid authentication rejection.
Valid patient/professional sessions, ACK-only status in a legitimate session,
message delivery, token-expiry recovery, reconnect catch-up, logout/account
switch, poor network and process restoration still need approved acceptance.
Legitimate session/fixture consent and the approved final physical-device
session remain separate gates. No production WSS host is approved; absent
configuration retains honest HTTP/resume/manual-refresh fallback.

Do not reset existing accounts or forge tokens to manufacture acceptance.
Backend scan success does not mean zero findings: the documented unfixed HIGH
finding remains governed by backend scan policy. Broader operational/provider
gates remain open; payments are last, test-only and require separate explicit
confirmation. This prerequisite does not expand attachments, rich chat,
notifications, calls, routes, persistence, backend or native/dependency scope.

## APP-READY-082E Verification Cancellation Boundary

Add evidence for the existing in-flight Dio cancellation connection and absence
of upload-complete after cancellation. Do not infer actual socket teardown,
server-side rollback, object deletion or provider/device acceptance from the
controlled adapter test. No production code or upload protocol is changed.
The broader readiness task and approved fixture/device gates remain open.

## APP-READY-082D Finance Feedback

Add source-level success/error announcement semantics only. Real screen-reader
acceptance, provider/payment activation, account/payout rules and broader
operational readiness remain separate. Seven focused tests, full analysis,
967 full tests, independent review, staging debug APK and fresh 623-task release
lint pass. Exact-head/integration CI remain pending.
No consent for payments or live money is implied by finance widget tests.

## APP-READY-082C Public Link Boundary

Contain failed platform launches in Account and signup without changing public
destinations. Browser/device acceptance, monitored support-contact confirmation,
legal operational ownership and all wider readiness gates remain separate.
Local verification passes: 69 focused tests, 965 full tests (953 retained plus
12 added), analysis, staging debug APK and fresh 623-task release lint. Initial
local path-escaping lint failures were repaired without tracked build changes.
Independent source review passes; exact-head/integration CI remain pending.
No provider or cloud configuration is changed.

## APP-READY-082B Permission Boundary

Correct only Profile/Onboarding 403 classification and prove readiness does not
refresh/replay or clear the session for that denial. Do not redesign shared
authentication, alter backend role decisions or broaden API schemas. Existing
401 recovery and retained flows remain green. Local verification passes 17
focused and 953 full tests, analysis, staging debug APK and release lint.
Exact-head/integration CI and delivery remain pending; operational, provider,
release-candidate and physical gates remain separate.

## APP-READY-082A Profile Editor Prerequisite

Remove only the registered name editor's seeded identity fallbacks. Retained
legacy stores/screens are not deleted or enabled. Backend profile creation,
role-policy changes, broader account cleanup, new retry UX, and operational/
provider/device acceptance remain out of scope. APP-READY-082 remains the sole
next task and partial. Focused source verification passes 51 tests and targeted
analysis. Full analysis, all 949 tests, staging debug APK and local Android
release lint pass; initial source-head CI `39773149140` also passes. Final-head/
integration evidence remains a merge gate on PR #248; physical acceptance and
the remaining operational program are separate and not claimed complete.

## Current Auth-Link And Admin Gates (APP-READY-080/081)

APP-READY-081 is merged through PR #245 at `1ab1075` and deployed as Hosting
version `3eed605e5b2bc4cc`. Exact-head CI, all 942 tests and live association/
unchanged-page checks pass. Integration CI `39288540689` also passed.
APP-READY-082 owns cost-conscious operational alerts and remains partial:
nine policies are applied, no uptime probes exist, and a controlled sanitized
release-health alert has an OPEN incident and matching email-receipt proof.
All three schedules are paused. Full operational/provider acceptance is not
proved; see `PHASE_1_OPERATIONAL_READINESS.md`. One regular RTC tick completed
with an empty-work result; useful cleanup, cadence reliability, RTC failure-mail
delivery and queue age remain open. Approved temporary organization review
resolved inherited deny-policy visibility for this proof and was removed
afterward. Future unknown authorization results must still fail closed.

Hosted auth links now name the separate approved Android upload certificates
instead of the shared debug key. Automatic signed-device verification and Play
distribution certificate registration remain explicit release gates. Do not
count a manual Android link-selection override as automatic verification.

Admin hosting, first-operator setup, IAP login, application login and queue
access are complete. Web PR #11 adds authenticated Download, now deployed.
The tiny smoke PDF did not preview; its validity and actual operator download
have not been proved. Keep valid-document preview/recovery acceptance open;
do not approve/reject it merely to clear a gate. Earlier provisioning-pending
notes below are historical.

## Verification Authorization Presentation (APP-READY-071)

The mobile verification client now preserves the HTTP distinction: 401 is
unauthenticated and 403 is forbidden. The verification UI gives separate safe
messages and does not clear or challenge a valid session for a permission
denial. PR #236 is merged at `d25c810` with green PR and integration CI (928
tests). This does not change backend role policy, document upload/storage,
verification readiness, or admin review authority. APP-READY-072 audited the
backend review contract and Web console; staging hosting/perimeter, explicit
first-operator approval/provisioning, and a controlled admin smoke remain open.
Do not start Cloud SQL or deploy the console before the explicit identity,
perimeter, and time-boxed operation decisions are recorded.

## Auth And Onboarding Integrity (APP-READY-069; Merged)

PR #234 is merged with 926 passing tests and green post-merge CI. Missing
email-verification links return to canonical sign-in; booking-intent storage
failure during role selection is recoverable and fail-closed; successful auth
fallback clears obsolete auth forms; patient required fields match backend
readiness (`name` and `country`); retry prefill restores backend values without
replacing non-empty typed input. This repairs form/navigation behavior only and
does not complete Google provider acceptance.

## Google OAuth iOS Callback Configuration (APP-READY-073; Merged, Device Gates Open)

The canonical Firebase SDK config confirms separate iOS OAuth client IDs and
reversed callback schemes for staging `com.carenet.app.staging` and production
`com.carenet.app`. Flavor-specific Xcode configs feed those values to the
native `Info.plist`; do not cross-use clients. Dart retains the Web client as
`serverClientId` for backend ID-token verification. PR #239 and post-merge
integration CI passed; both iOS flavor simulator builds passed. This does not
prove Apple signing or physical-device Google sign-in. Android production's
certificate-bound client also remains a separate release gate. Never install
the old-project Firebase files or change the backend audience without a separate
decision.

## Notification Provider Late Work And Native Delivery (APP-READY-068)

Mobile bounds provider callers and cancels Dart Firebase stream subscriptions,
but cannot cancel native Firebase initialization already in progress. Generic
foreground copy is shown only after an owner-scoped backend lookup. This does
not revoke OS notifications already delivered while backgrounded, prove provider
delivery/retry, or replace backend notification authority. Physical shared-device
account-switch and push acceptance remain gates.

## Auth Commit And Native Fault Boundary (APP-READY-067)

Caller deadlines do not cancel native secure-storage I/O or release its queue.
Conditional queued writes and generation-specific cleanup protect newer sessions,
but native failure can leave commit/removal uncertain. Do not promise physical
power-loss atomicity, successful logout after storage failure, multiprocess
coordination or recall of already-dispatched provider callbacks. Device/native
fault acceptance and optional provider late-initialization ownership remain gates.
No backend authority, payment activation, RTC or messaging redesign is included.

## Session Recovery Boundary (APP-READY-066)

Legacy multi-key sessions require fresh sign-in because cross-field account
provenance cannot be established. Valid versioned envelopes remain supported.
Fault/recreation tests demonstrate logical failure handling, not physical native
secure-storage crash/power-loss guarantees. A bounded splash timeout ignores late
results; it does not cancel or repair an underlying hung platform operation.
Shared account/disposal request cancellation, actual interrupted-device writes,
optional Firebase late-initialization ownership and interceptor-driven concurrent
401 coverage remain readiness work. Keep provider, signed RC, operational alert,
payment-final-confirmation and physical-device gates open; no new feature scope.

## Locale And Release Validation Boundary (APP-READY-064)

English/Nigeria presentation does not add translated languages or Nigerian
date data absent from pinned intl. Standard bundled English day-first fallback
is explicit. No financial parsing, timezone or backend policy is localized.
PR #229 is merged with final and integration CI green (811 tests and native CI);
its older pending-merge note below is superseded. Actual signed release-candidate,
local disk headroom, iOS signing/hardware, cloud operational proof and physical
device acceptance remain open. No payment activation is authorized by this slice.

## Sanitized Release-Health Operational Boundary (APP-READY-063)

The user selected backend allowlisted diagnostics instead of raw/native crash
uploads. Mobile source/consent proof is in PR #229; backend PR #141 is
merged but not deployed by this slice. Still required: reviewed image/migration
promotion, gateway admission, restricted log access and retention approval,
controlled opt-in acceptance, alert recipients/delivery and release-health
runbook proof. Counts are untrusted technical hints, not crash-free-user metrics.
Native crashes, process death and child-isolate capture remain unavailable.
Failed opt-out writes are reported as paused only in the current app session;
durable preference success must not be claimed. See PHASE_1_RELEASE_HEALTH.
Backend historical index-name drift needs separate alignment before production
promotion. No native SDK, deployment, payment activation or device test is added.
Local native validation also needs more C: disk headroom: the guarded build
stopped before exhausting the system drive, not with a passing result. Canonical
Ubuntu APK/lint/signing/environment CI must pass on the final source head before
merge; actual signed release-candidate and device proof remain separate gates.
Task-generated Kotlin cache logs remain local and are not part of the PR.

Purpose: one place to see what is intentionally local, disabled, or deferred so later work does not lose the path.

Rule: do not implement a deferred item until its product and backend contracts
are defined. Do not fake backend, payment, or media behavior to make a screen
look complete.

## Current pre-device readiness gates (APP-READY-061)

The 2026-10-13 reconciliation uses mobile merge `31ed6ae` (734 tests and both
platform CI lanes), backend main `8e5175e`, Web main `bcb7742`, and read-only
GCP control-plane responses. Full evidence is summarized in CODEBASE_STATUS.

- Repair notification-delivery claim ownership so a late provider outcome
  cannot overwrite a reclaimed delivery or invalidate an endpoint from an
  obsolete claim. Ownership must be captured at the successful claim, not
  inferred from a later row read.
- Reset Web admin decision confirmation on document-preview expiry, close,
  replacement, and session-context changes. Mock browser/iframe presence is
  not real document-rendering or production-cookie proof.
- Complete privacy-reviewed mobile crash reporting/release-health metadata
  and the explicit English/Nigerian locale policy.
- Promote the approved scanned backend digest, then prove current-schema
  migration/rollback/restore and deployed messaging/email/RTC operations.
- Monitoring currently has no alert policies or notification channels; approve
  recipients and prove required-domain alert/recovery delivery.
- Preserve enabled SQL backups/PITR/deletion protection and encrypted connector
  enforcement. Private networking and current restore/RPO/RTO proof remain open.
- Keep unused SQL and Scheduler off. Exact signed-device acceptance, Apple
  hardware/provider gates, admin hosting/access, and final Paystack test-mode
  confirmation remain separate gates.

No source deletion, test disabling, service activation, or provider mutation
was used to produce this reconciliation.

## Legal and authentication-link release gates

- Replace the launch-placeholder support availability notice with a monitored,
  approved support channel and operating hours.
- Add protected Android upload and Play App Signing SHA-256 fingerprints to
  Firebase and `assetlinks.json`, then verify the signed release candidate.
- Configure and prove iOS Universal Links only after Apple Developer signing,
  Associated Domains, a Mac, and an iPhone are available.

## Account lifecycle

- Backend-owned soft deletion and session revocation are active through the
  Account surface.
- Hard erasure, restoration/grace periods, data export, and a published
  retention duration remain deferred pending legal and product policy.
- The app must continue to describe retained records without inventing a
  deletion deadline.

## Authentication providers

- Phone OTP and Apple identity stay hidden until their backend/provider contracts and device acceptance are complete.
- Facebook identity is outside the approved Phase 1 authentication surface.
- Direct legacy phone auth route values now resolve to supported email auth;
  retained phone/provider widgets are source-recovery candidates for a later
  dependency-proven deletion slice, not active authentication paths.
- Firebase Hosting landing pages and Android app-link verification for email verification and password reset remain in the Firebase/environment slice.

## Notification installation account fencing

- Complete across backend `NOTIF-P1-010B` (PR #134) and mobile
  `NOTIF-P1-010C` (PR #209). The backend persists an account registration epoch
  signed into access tokens and a monotonic per-installation binding generation;
  registration compares both transactionally, while logout/account deletion
  advance the epoch under the same account lock. The mobile stores and advances
  the decimal-string generation, serializes registration, and never treats the
  client counter as authorization. Stale in-flight registration is rejected
  even if its HTTP response arrives after a later account binding.
- Backend real-PostgreSQL concurrency tests and mobile session/notification
  regression tests passed in CI. Keep JWT-derived ownership authoritative.
  Remaining notification gates are provider-delivery reliability, iOS APNs,
  physical-device acceptance, and production operational readiness; these are
  not installation-binding gaps.

---

## Phase 1 product deferrals

`APP-P1-001` narrows the active product to a healthcare consultation
marketplace. General Feed/Post, Circles/communities, articles/case studies,
podcasts, social Q&A, events/live sessions, professional-development and creator
marketplaces, health readings/devices, emergency/ambulance, generic social
messaging, creator portfolios, birthday activity, promotional subscriptions,
ads/boosts, and generic reminders/schedules are not active Phase 1 modules.

Their routes are removed from active navigation first. Exclusive source, local
stores, assets, packages, and tests are removed only after retained marketplace
flows pass regression. Recovery uses Git history plus the proposed archive refs
at committed baseline `3e04d6e`; deferred code is not kept indefinitely behind
feature flags.

APP-P1-002 completes the first navigation-pruning pass: the role-aware dashboard,
active professional profile management, and communication surfaces no longer
promote Feed/Post, Circles/communities, articles/creator portfolios, podcasts,
events, boosts, health readings, emergency flows, generic messaging, reminders,
or the local draft booking route. Route constants and deferred source remain for
the later dependency-proven cleanup slices.

APP-P1-021C disconnects the legacy `medicalEdit` route from its local-only
`UserEdit` screen. The route now resolves to `DeferredFeaturePage`; the route
constant and `UserEdit`/`ProfessionScreen` sources remain recoverable. Do not
present the seeded identity or local image/field edits as persisted profile
management. Use the registered backend-backed account/profile flows instead.

The complete ownership/removal map is
`PHASE_1_DEPENDENCY_IMPACT_MAP.md`. Core payment, appointment messaging,
consultation calls, and transactional notification delivery are implemented.

APP-P1-011 closes the shared mobile transport/session foundation: active clients
have bounded timeouts, authenticated 401 responses serialize one refresh and one
retry, secure session authority is stored as one versioned record, and optional
notification startup no longer blocks the first frame. Feature-specific
cancellation/progress UX and physical poor-network acceptance remain deferred to
their owning slices.
Broader support operations, dual-role behavior, marketing communication, and
advanced profile/deferred-source cleanup remain separate and must not be invented.

APP-P1-003 uses existing profile, readiness, own-appointment, and professional
availability repositories for Home. Appointment participant names, consultation
type, payment state, message eligibility, call eligibility, recommendations,
earnings, and demand statistics are not present in the Home contract and remain
absent rather than locally fabricated. See `PHASE_1_MARKETPLACE_HOME.md`.

---

## Backend replacement seams

| Area | Current honest behavior | Deferred / backend needed later | Main files | Decision |
|------|--------------------------|----------------------------------|------------|----------|
| Auth providers | Google sign-in rows on sign-in phone/email are wired when `GOOGLE_SIGN_IN_SERVER_CLIENT_ID` is configured; Account can link Google through configured `GoogleIdTokenProvider` plus `AuthRepository.googleLink`; Google first-time signup now requires explicit patient/professional role selection and sends a real Google `idToken` plus selected backend role | Google unlink UI, cross-email/recovery linking, recent re-authentication, Facebook/Apple provider setup, iOS OAuth proof, release/Play signing fingerprints, production OAuth consent/app verification remain deferred | `lib/features/Authentication/presentation/pages/sign_in_phone.dart`, `lib/features/Authentication/presentation/pages/sign_in_email.dart`, `lib/features/Authentication/presentation/pages/sign_up_phone.dart`, `lib/features/Authentication/presentation/pages/sign_up_email.dart`, `lib/features/Authentication/presentation/pages/sign_up_role_selection.dart`, `lib/features/Home/presentation/pages/account_shell.dart`, `docs/GOOGLE_ACCOUNT_LINKING_REGRESSION.md`, `docs/AUTH_SIGNUP_STAGING_CONTRACT_FIX.md`, `docs/GOOGLE_FIRST_TIME_SIGNUP_ROLE_SELECTION.md` | D002, D076, D145, D146, D163, D164 |
| Role-based onboarding | `signUpRole` now requires patient/professional choice before email/password and Google first-time account creation. Email/password registration sends the selected backend role instead of hardcoding `PATIENT` and does not send stale nested profile data. Google signup sends a real `idToken` plus selected role. Patient setup saves backend patient profile fields before community agreement. Professional setup saves legal/credential/practice fields before verification document upload against the staging `CAR-BE-119` profile schema | Terms/privacy payload rules, council catalogs/regulator validation, admin review enrichment, safe unlinked-Google direction, rejection reason UI, and broader profile/public-detail expansion remain deferred | `docs/ROLE_BASED_ONBOARDING_AUTH_BOUNDARY.md`, `docs/ROLE_REGISTRATION_BACKEND_CONTRACT.md`, `docs/PATIENT_PROFESSIONAL_ONBOARDING_UI_REQUIREMENTS.md`, `docs/PROFILE_NIGERIA_ONBOARDING_CONTRACT_EXPANSION.md`, `docs/PATIENT_PROFESSIONAL_ONBOARDING_SETUP_UI.md`, `docs/AUTH_SIGNUP_STAGING_CONTRACT_FIX.md`, `docs/GOOGLE_FIRST_TIME_SIGNUP_ROLE_SELECTION.md`, `lib/features/Authentication/presentation/pages/sign_up_role_selection.dart`, `lib/features/Authentication/presentation/pages/sign_up_con.dart`, `lib/features/Onboarding/presentation/pages/profile_setup.dart`, backend auth/register/profile routes | D157, D158, D159, D160, D161, D162, D163, D164 |
| Backend-owned onboarding catalogs/readiness | Flutter now has `OnboardingApiClient`/`OnboardingRepository` and typed models for backend `GET /catalogs/onboarding` plus protected `GET /account/readiness`; patient/professional setup screens consume those catalogs/readiness, use controlled Nigeria country/state/profession/regulator/health-interest options, block save when catalog options are unavailable, and send catalog codes through current profile DTO fields | Regulator-specific license hints, document upload required-evidence guidance, rejection-reason UX, role switching/duplicate-account policy, half-completed application recovery, live council verification, expiry checks, phone/OTP, payments, reviews, calls, notes, prescriptions, Web admin hosting/provisioning, and rejection-note support remain deferred | `lib/features/Home/data/services/onboarding_api_client.dart`, `lib/features/Home/data/repositories/onboarding_repository.dart`, `lib/features/Onboarding/presentation/pages/profile_setup.dart`, `test/features/home/onboarding_repository_test.dart`, `test/features/onboarding/profile_setup_test.dart`, backend `APP-ID-003` contracts, Web-Developers `docs/ADMIN_VERIFICATION_CONSOLE.md` | APP-ID-004, APP-ID-005, APP-ID-007, APP-READY-057 |
| Native profile-code request fields | APP-ID-006 decides Flutter should not invent unsupported `countryCode`, `professionCode`, or `regulatorCode` request fields while backend profile DTOs still accept current profile field names and normalize catalog values internally. APP-ID-007 sends backend-accepted catalog codes through those current DTO fields instead | Backend DTO/API docs may later add explicit native code request fields. Public display of normalized identity fields, live regulator lookup, expiry/good-standing checks, required-evidence guidance, rejection UX, account-type switching policy, and partial-application recovery remain separate | `docs/ONBOARDING_PROFILE_PAYLOAD_CODE_ALIGNMENT_DECISION.md`, `docs/ONBOARDING_SETUP_PAYLOAD_VALUE_ALIGNMENT.md`, `lib/features/Home/data/services/profile_api_client.dart`, `lib/features/Onboarding/presentation/pages/profile_setup.dart`, backend profile DTO/service docs | APP-ID-006, APP-ID-007 |
| Production onboarding domain hardening | APP-ID-008 accepts the MVP boundary: one backend role per account, no in-app patient/professional switching or dual-mode accounts yet, backend owns duplicate email/provider/regulator conflicts, partial applications should resume through readiness, professional setup remains Nigeria-catalog/regulator driven, and required evidence guidance should come from backend catalogs/readiness | Account upgrade/dual-mode policy, role switching, authoritative city/LGA catalog, live regulator lookup, license expiry/good-standing checks, professional rejection/appeal UX, admin dashboard, Google unlink/recovery linking, phone/OTP, MFA/recent re-auth, payments, payouts, refunds, reviews, calls, calendar sync, notes, prescriptions, no-show/disputes, and emergency escalation remain deferred | `docs/PRODUCTION_ONBOARDING_DOMAIN_HARDENING_BOUNDARY.md`, `docs/PATIENT_PROFESSIONAL_ONBOARDING_UI_REQUIREMENTS.md`, backend onboarding catalog/readiness/profile routes | APP-ID-008 |
| Onboarding readiness route resolution | APP-ID-010 adds a resolver that maps backend `AccountReadiness.nextAction` values to Flutter destinations after email/password and first-time Google signup, with role-safe fallback on readiness failure. APP-ID-011 accepts the progress/evidence guidance plan, APP-ID-012 implements backend-readiness progress/evidence panels, APP-ID-013 defines the proof gate, and APP-ID-014 proves the staging APK build | Phone-smoke execution remains blocked until an Android phone is visible to ADB. Full visual onboarding redesign, rejection-reason detail, regulator-specific helper text beyond catalog labels, role switching, city/LGA catalog, phone/OTP, and admin review UI remain deferred | `docs/ONBOARDING_READINESS_RESUME_UX_HARDENING_PLAN.md`, `docs/ONBOARDING_READINESS_ROUTE_RESOLVER.md`, `docs/ONBOARDING_PROGRESS_EVIDENCE_GUIDANCE_PLAN.md`, `docs/ONBOARDING_READINESS_PROGRESS_PANEL.md`, `docs/ONBOARDING_REGRESSION_AND_PHONE_SMOKE_PLAN.md`, `docs/ONBOARDING_PHONE_SMOKE_EXECUTION.md`, `lib/features/Onboarding/domain/services/onboarding_readiness_route_resolver.dart`, `lib/features/Onboarding/presentation/pages/profile_setup.dart`, `lib/features/Home/presentation/pages/professional_verification_documents_shell.dart`, backend `AccountReadinessService` | APP-ID-009, APP-ID-010, APP-ID-011, APP-ID-012, APP-ID-013, APP-ID-014 |
| API/auth backend | Email sign-in is wired through `AuthRepository.login`; email sign-up completion is wired through `AuthRepository.register`; splash restores stored sessions through `AuthRepository.restore`; Account logout calls `AuthRepository.logout`; password reset request/confirmation and email verification request/confirmation are wired through auth/account repositories; Account reads `AccountRepository.currentAccount` for safe display fields; these scoped paths have focused regression coverage; phone sign-in/up and account settings still use local/client validation or draft behavior | Wire remaining auth/account screens to `AuthRepository`/`AccountRepository` one slice at a time only after a next-lane decision; keep missing-config failures honest and keep phone/social/MFA/security flows deferred until scoped | `lib/features/Authentication/data/`, auth pages, account store, `lib/features/splash/presentation/pages/splash_screen.dart`, `lib/features/Home/presentation/pages/account_shell.dart`, `lib/features/Home/presentation/pages/edit_email_shell.dart` | D054, D055, D056, D057, D058, D059, D060, D061, D062, D063, D069, D070 |
| Password reset confirmation | `resetPasswordConfirm` completes password reset only when opened with a transient reset token; it sends `{ token, newPassword }`, clears local session after success, and returns to sign-in | Production app-link/custom-scheme setup, reset-link domain validation, manual-token internal test UX if needed, and end-to-end staging link smoke | `lib/features/Authentication/presentation/pages/reset_password_confirm_page.dart`, `lib/features/Authentication/data/repositories/auth_repository.dart`, `docs/PASSWORD_RESET_EMAIL_VERIFICATION_CONTRACT.md` | D060, D069, D070 |
| Email verification request/confirmation | Account -> Email address reads backend-owned email/`emailVerified` and offers the existing request endpoint only when unverified; confirmation requires a transient token and refreshes current account state. A successful request response does not guarantee delivery | Signup/onboarding verification gating is not enforced and needs an explicit policy/backend decision if required; production app-link and end-to-end staging link/device proof remain separate | `lib/features/Home/presentation/pages/account_shell.dart`, `lib/features/Home/presentation/pages/edit_email_shell.dart`, `lib/features/Authentication/presentation/pages/email_verification_confirm_page.dart`, `lib/features/Authentication/data/repositories/account_repository.dart`, `docs/PASSWORD_RESET_EMAIL_VERIFICATION_CONTRACT.md` | D062, D069, D070, APP-READY-078 |
| Completed backend surface wiring | `BACKEND_COMPLETED_SURFACE_WIRING_MAP.md` now separates backend surfaces already completed from frontend surfaces still local/deferred. A source-only Web admin verification console now covers the review API; APP-READY-056 fixed same-origin verification reads and APP-READY-057 added mock-backed browser coverage. | Hosting/protection, explicitly authorized first-admin provisioning, hosted review smoke, professional profile/verification upload runtime wiring, public professional listing, availability, appointment request/lifecycle, and production app links remain separate readiness gates; do not start Cloud SQL or Scheduler for ordinary source work | `docs/BACKEND_COMPLETED_SURFACE_WIRING_MAP.md`, Web-Developers `docs/ADMIN_VERIFICATION_CONSOLE.md`, backend `docs/68-first-admin-provisioning-operator-runbook.md` | D071, APP-READY-057 |
| Auth/account staging checkpoint | `AUTH_ACCOUNT_STAGING_CHECKPOINT.md` records developer-private proxy health/readiness evidence and confirms the app already uses `CARENET_API_BASE_URL` for backend config | Live Flutter UI auth smoke harness, production reset/verification app links, Google sign-in/link UI, verification upload wiring, real-device/public staging access, and production release readiness remain deferred | `docs/AUTH_ACCOUNT_STAGING_CHECKPOINT.md`, `lib/core/config/carenet_api_config.dart` | D072 |
| Google sign-in foundation | Android and iOS placeholder identifiers were replaced with `com.carenet.app` so OAuth setup can target the real app identity | Google OAuth clients, Android SHA fingerprints, iOS reversed client ID, Flutter Google provider package/config, backend `GOOGLE_OAUTH_CLIENT_ID`, readiness `googleAuth: ok`, and runtime Google button wiring remain deferred | `android/app/build.gradle.kts`, `ios/Runner.xcodeproj/project.pbxproj`, `docs/GOOGLE_SIGN_IN_FOUNDATION.md` | D073 |
| Google OAuth prerequisites | Android debug SHA fingerprints are collected for `com.carenet.app`; staging still lacks Google OAuth client config and readiness reports `googleAuth: disabled` | Create/collect Android and iOS OAuth client IDs, collect release SHA fingerprints when release keystore credentials are intentionally available, configure backend `GOOGLE_OAUTH_CLIENT_ID`, verify readiness, add Flutter `google_sign_in` package/config, and wire runtime Google UI | `docs/GOOGLE_SIGN_IN_SETUP_PREREQUISITES.md` | D074 |
| Google staging readiness | Backend staging Google readiness is enabled and updated to the Web OAuth client ID required by Flutter `google_sign_in` server-client configuration; `/health/ready` reports `googleAuth: ok`; Account Google linking is wired behind configured provider setup | Google unlink UI, Google sign-up role-selection rules, cross-email/recovery linking, recent re-authentication, iOS OAuth validation, release/Play signing fingerprints, production OAuth consent/app verification, and production backend config remain deferred | `docs/GOOGLE_SIGN_IN_SETUP_PREREQUISITES.md`, `lib/features/Authentication/data/services/google_sign_in_provider.dart`, `lib/features/Home/presentation/pages/account_shell.dart` | D075, D076, D145 |
| Profile/public professional contract | Profile/public-professional backend wiring contract is defined before runtime replacement. Patient self, professional self, and public verified professional listing should be added behind repository/API boundaries before screen wiring | Verification upload/list, admin dashboard, public professional detail, full search/ranking/filtering, availability, appointment lifecycle, payments, notifications, reviews, calls, calendar sync, notes, prescriptions, public staging access, and moderation/compliance workflows remain deferred | `docs/PROFILE_PUBLIC_PROFESSIONAL_CONTRACT.md` | D077 |
| Profile repository boundary | `ProfileApiClient`/`ProfileRepository` provide patient self, professional self, and public verified professional listing boundaries with focused tests. Manage Profile now reads the professional self profile and replaces only `displayName`, `category`, `specialty`, and `bio` | Profile mutations from edit screens, patient profile UI, public listing UI replacement, verification upload/list, admin dashboard, availability, appointment lifecycle, payments, reviews, calls, calendar sync, notes, prescriptions, and public professional detail remain deferred | `lib/features/Home/data/services/profile_api_client.dart`, `lib/features/Home/data/repositories/profile_repository.dart`, `lib/features/Home/presentation/pages/manage_profile_shell.dart`, `test/features/home/profile_repository_test.dart`, `test/features/home/manage_profile_flow_test.dart` | D078, D079 |
| Patient profile next lane | `NEXT_BACKEND_COMPLETED_FLUTTER_SURFACE_DECISION.md` selects patient self profile as the next backend-completed Flutter surface; `PATIENT_PROFILE_SETTINGS_MAPPING_DECISION.md` maps Settings/Profile to backend patient `name`, `age`, and `location` only; `SettingsProfilePage` now reads `ProfileRepository.patientMe`; `PATIENT_PROFILE_READ_REGRESSION.md` proves read behavior; `PATIENT_PROFILE_UPDATE_BOUNDARY_DECISION.md` selects name-only update; Settings/Profile now updates backend patient `name` only; `PATIENT_PROFILE_NAME_UPDATE_REGRESSION.md` proves the scoped name update | Age/location mutation, username persistence, email mutation, auth/security, public profile, verification, scheduling, destructive account actions, and bio must not be mixed into `PUT /patients/me` | `docs/NEXT_BACKEND_COMPLETED_FLUTTER_SURFACE_DECISION.md`, `docs/PATIENT_PROFILE_SETTINGS_MAPPING_DECISION.md`, `docs/PATIENT_PROFILE_READ_WIRING.md`, `docs/PATIENT_PROFILE_READ_REGRESSION.md`, `docs/PATIENT_PROFILE_UPDATE_BOUNDARY_DECISION.md`, `docs/PATIENT_PROFILE_NAME_UPDATE_WIRING.md`, `docs/PATIENT_PROFILE_NAME_UPDATE_REGRESSION.md`, `lib/features/Home/data/repositories/profile_repository.dart`, `lib/features/Home/presentation/pages/account_shell.dart` | D115, D116, D117, D118, D119, D120, D121 |
| Profile mutation UI boundary | `PROFILE_MUTATION_UI_DECISION.md` selected existing-professional bio update from `addDescription` as the first safe mutation path, and that path is now implemented. It preserves existing backend-required fields and updates only `bio` | Profile creation, name/category/specialty editing, website, address, patient profile UI, public listing UI replacement, verification upload/list, availability, appointment lifecycle, payments, reviews, calls, calendar sync, notes, prescriptions, and public professional detail remain deferred | `docs/PROFILE_MUTATION_UI_DECISION.md`, `lib/features/Home/presentation/pages/add_description_shell.dart`, `test/features/home/manage_profile_flow_test.dart` | D080, D081 |
| Canonical Find Care discovery | `RouteName.search` / `SearchShellPage` is the single patient discovery experience. It reads `ProfileRepository.publicProfessionals` once, omits malformed/unverified entries, filters name/category/specialty locally, distinguishes loading/empty/error/refresh failure, never falls back to local professionals, and passes the exact backend id to Specialist Details. `findMentor` aliases the canonical route | Dedicated public detail endpoint, server-side search/filter/pagination, symptom/condition catalog mapping, location/language/mode/fee/availability filters, canonical detail reload, detail fallback removal, ratings, reviews, payments, calls, and later deletion of legacy mentor/search local source remain deferred | `docs/PHASE_1_FIND_CARE.md`, `lib/features/Home/presentation/pages/search_shell.dart`, `lib/core/constants/navigators/router.dart`, `test/features/home/search_flow_test.dart`, `test/features/home/find_mentor_flow_test.dart` | D082, D083 |
| Specialist Details next lane | `NEXT_SURFACE_AFTER_PATIENT_PROFILE_DECISION.md` selects Specialist Details public professional/availability wiring as the next narrow backend-completed Flutter surface; `specialistDetails` now resolves backend public professionals from `ProfileRepository.publicProfessionals`, reads public availability, and can submit a generated backend appointment request; `SPECIALIST_DETAILS_PUBLIC_AVAILABILITY_REGRESSION.md` proves this scoped path | Dedicated public detail endpoint, Find Mentor replacement, verification upload/list, admin dashboard, payments, notifications, review/rating expansion, calls/video, calendar sync, notes, prescriptions, staging data seeding, and production claims remain deferred | `docs/NEXT_SURFACE_AFTER_PATIENT_PROFILE_DECISION.md`, `docs/SPECIALIST_DETAILS_PUBLIC_AVAILABILITY_WIRING.md`, `docs/SPECIALIST_DETAILS_PUBLIC_AVAILABILITY_REGRESSION.md`, `lib/features/Home/presentation/pages/specialist_details_shell.dart`, `lib/features/Home/data/repositories/profile_repository.dart`, `lib/features/Home/data/repositories/scheduling_repository.dart` | D122, D123, D124 |
| Legacy Find Mentor source | Normal `findMentor` route resolution now opens canonical Find Care, so the separate mentor marketplace is not an active patient entry point | `FindMentorShellPage`, its optional local-store path, historical tests/docs, and exclusive dependencies remain recoverable until retained detail/booking paths pass and a later dead-code slice proves they are safe to delete | `docs/PHASE_1_FIND_CARE.md`, `lib/features/Home/presentation/pages/find_mentor_shell.dart`, `lib/features/Home/presentation/state/search_local_store.dart` | D125, D126, D127 |
| Professional verification documents shell | Manage Profile now opens `professionalVerificationDocuments`, which reads owner document list/status through `VerificationRepository.documents` and displays only safe metadata with loading/empty/safe-error states | File picker UI, visible upload flow, progress/retry/cancel, admin review dashboard, rejection reasons, file preview/read/download, camera capture, batch/background upload, file scanning/provider verification claims, public document exposure, payments, reviews, calls, calendar sync, notes, prescriptions, staging data, and production claims remain deferred | `docs/NEXT_SURFACE_AFTER_FIND_MENTOR_DECISION.md`, `docs/PROFESSIONAL_VERIFICATION_UPLOAD_LIST_BOUNDARY.md`, `docs/PROFESSIONAL_VERIFICATION_REPOSITORY_BOUNDARY.md`, `docs/PROFESSIONAL_VERIFICATION_DOCUMENTS_SHELL.md`, `lib/features/Home/presentation/pages/professional_verification_documents_shell.dart`, `lib/features/Home/data/repositories/verification_repository.dart`, `test/features/home/manage_profile_flow_test.dart` | D128, D129, D130, D131 |
| Professional verification upload picker boundary | `PROFESSIONAL_VERIFICATION_UPLOAD_PICKER_BOUNDARY.md` selects a PDF-capable picker dependency path for the next runtime upload flow because the current direct dependency set only has `image_picker` | Runtime upload implementation, package dependency addition, progress/retry/cancel, checksum computation, admin review dashboard, rejection reasons, file preview/read/download, camera capture, batch/background upload, file scanning/provider verification claims, public document exposure, staging data, and production claims remain deferred | `docs/PROFESSIONAL_VERIFICATION_UPLOAD_PICKER_BOUNDARY.md`, `pubspec.yaml`, `lib/features/Home/domain/entities/verification_upload_request.dart`, `lib/features/Home/data/repositories/verification_repository.dart` | D132 |
| Professional verification upload flow | `professionalVerificationDocuments` lets professionals pick one PDF/JPEG/PNG file under 10 MB, choose `LICENSE`/`IDENTITY`/`CERTIFICATION`, compute SHA-256 off the UI isolate, upload with visible bounded progress and active cancellation, complete backend integrity verification, and reload owner documents after success | Admin review dashboard, rejection reasons, file preview/read/download, camera capture, batch/background upload, malware scanning, retention/orphan cleanup, public document exposure, production IAM proof, and device acceptance remain deferred | `lib/features/Home/presentation/pages/professional_verification_documents_shell.dart`, `lib/features/Home/data/repositories/verification_repository.dart`, `test/features/home/manage_profile_flow_test.dart`, `test/features/home/verification_repository_test.dart`, `pubspec.yaml` | D133, APP-P1-020 |
| Professional verification upload regression | Focused tests prove digest submission, signed-URL privacy, progress, cancellation, validation, owner reload, and safe failures. The backend independently verifies object size, MIME type, and server-computed digest before review | Background/restart-resumable upload, malware scanning, admin review UI, retention/cleanup, production IAM evidence, and physical-device poor-network proof remain deferred | `test/features/home/manage_profile_flow_test.dart`, `test/features/home/verification_repository_test.dart` | D134, APP-P1-020 |
| Next surface after verification regression | `NEXT_SURFACE_AFTER_VERIFICATION_UPLOAD_REGRESSION_DECISION.md` selects professional basic profile field editing as the next backend-completed Flutter surface because professional self-profile `displayName`, `category`, and `specialty` are accepted by the existing backend contract while website/address are not | Runtime name/category/specialty wiring, professional profile creation, website/address persistence, verification expansion, admin review, scheduling staging data, Google link/unlink/sign-up, payments, reviews, calls, calendar sync, notes, prescriptions, staging, and production claims remain deferred | `docs/NEXT_SURFACE_AFTER_VERIFICATION_UPLOAD_REGRESSION_DECISION.md`, `docs/PROFILE_PUBLIC_PROFESSIONAL_CONTRACT.md`, `docs/PROFILE_MUTATION_UI_DECISION.md` | D135 |
| Professional basic profile edit boundary | `PROFESSIONAL_BASIC_PROFILE_EDIT_BOUNDARY.md` selects a display-name-only `editYourName` update that preserves existing `category`, `specialty`, and `bio` through `PUT /professionals/me` | Category/specialty editing UI, professional profile creation, website/address persistence, account identity changes, verification expansion, availability/business-hours changes, appointment state, public detail endpoint, payments, reviews, calls, calendar sync, notes, prescriptions, staging, and production claims remain deferred | `docs/PROFESSIONAL_BASIC_PROFILE_EDIT_BOUNDARY.md`, `lib/features/Home/presentation/pages/edit_your_name_shell.dart`, `lib/features/Home/data/repositories/profile_repository.dart` | D136 |
| Professional display name update | `editYourName` now updates backend professional `displayName` only after reading an existing professional profile, preserving existing `category`, `specialty`, and `bio`; empty profiles block save instead of creating partial profiles | Category/specialty editing UI, professional profile creation, website/address persistence, account identity changes, verification expansion, availability/business-hours changes, appointment state, public detail endpoint, payments, reviews, calls, calendar sync, notes, prescriptions, staging, and production claims remain deferred | `docs/PROFESSIONAL_DISPLAY_NAME_UPDATE_WIRING.md`, `lib/features/Home/presentation/pages/edit_your_name_shell.dart`, `test/features/home/manage_profile_flow_test.dart` | D137 |
| Professional display name update regression | `PROFESSIONAL_DISPLAY_NAME_UPDATE_REGRESSION.md` proves backend displayName prefill, display-name-only save, category/specialty/bio preservation, empty-profile blocking, validation guard, and safe backend failure for the current milestone | Category/specialty editing UI, professional profile creation, website/address persistence, account identity changes, verification expansion, availability/business-hours changes, appointment state, public detail endpoint, payments, reviews, calls, calendar sync, notes, prescriptions, staging, production claims, and next profile lane selection remain deferred | `docs/PROFESSIONAL_DISPLAY_NAME_UPDATE_REGRESSION.md`, `test/features/home/manage_profile_flow_test.dart` | D138 |
| Next surface after display-name regression | `NEXT_SURFACE_AFTER_DISPLAY_NAME_REGRESSION_DECISION.md` selects professional category/specialty editing as the next backend-completed Flutter surface because `PUT /professionals/me` accepts those fields, but requires a boundary decision before runtime wiring | Runtime category/specialty wiring, professional profile creation, website/address persistence, account identity changes, verification expansion, availability/business-hours changes, appointment state, public detail endpoint, payments, reviews, calls, calendar sync, notes, prescriptions, staging, and production claims remain deferred | `docs/NEXT_SURFACE_AFTER_DISPLAY_NAME_REGRESSION_DECISION.md`, `docs/PROFILE_PUBLIC_PROFESSIONAL_CONTRACT.md`, `docs/PROFESSIONAL_DISPLAY_NAME_UPDATE_REGRESSION.md` | D139 |
| Professional category/specialty edit boundary | `PROFESSIONAL_CATEGORY_SPECIALTY_EDIT_BOUNDARY.md` selects a new constrained category/specialty edit surface that preserves existing `displayName` and `bio`; category is required, specialty is optional, and cleared specialty should be sent as `null` | Runtime category/specialty wiring, professional profile creation, category taxonomy/dropdown rules, website/address persistence, account identity changes, verification expansion, availability/business-hours changes, appointment state, public detail endpoint, payments, reviews, calls, calendar sync, notes, prescriptions, staging, and production claims remain deferred | `docs/PROFESSIONAL_CATEGORY_SPECIALTY_EDIT_BOUNDARY.md`, `lib/features/Home/presentation/pages/manage_profile_shell.dart`, `lib/features/Home/data/repositories/profile_repository.dart` | D140 |
| Professional category/specialty update | `editProfessionalDetails` is now reachable from Manage Profile Basic and updates professional `category` plus optional `specialty` through `ProfileRepository.updateProfessionalMe`, preserving existing `displayName` and `bio`; cleared specialty is sent as `null`, category is required, and empty profiles block save instead of creating partial profiles | Professional profile creation, category taxonomy/dropdown rules, website/address persistence, account identity changes, verification expansion, availability/business-hours changes, appointment state, public detail endpoint, payments, reviews, calls, calendar sync, notes, prescriptions, staging, production claims, and broader profile surface selection remain deferred | `docs/PROFESSIONAL_CATEGORY_SPECIALTY_UPDATE_WIRING.md`, `lib/features/Home/presentation/pages/edit_professional_details_shell.dart`, `lib/features/Home/presentation/pages/manage_profile_shell.dart`, `test/features/home/manage_profile_flow_test.dart` | D141 |
| Professional category/specialty update regression | `PROFESSIONAL_CATEGORY_SPECIALTY_UPDATE_REGRESSION.md` proves entry separation, backend prefill, category-required validation, displayName/bio preservation, cleared specialty as `null`, empty-profile blocking, safe backend failure, and broader-scope non-behavior for the current milestone | Professional profile creation, category taxonomy/dropdown rules, website/address persistence, account identity changes, verification expansion, availability/business-hours changes, appointment state, public detail endpoint, payments, reviews, calls, calendar sync, notes, prescriptions, staging, production claims, and next surface selection remain deferred | `docs/PROFESSIONAL_CATEGORY_SPECIALTY_UPDATE_REGRESSION.md`, `test/features/home/manage_profile_flow_test.dart` | D142 |
| Next surface after category/specialty regression | `NEXT_SURFACE_AFTER_CATEGORY_SPECIALTY_REGRESSION_DECISION.md` selects protected Google account linking as the next backend-completed Flutter surface because backend `POST /auth/google/link`, Flutter `AuthRepository.googleLink`, and Google ID-token acquisition already exist | Runtime linking UI, Google sign-up role selection, Google unlinking, cross-email linking, recovery linking, recent re-authentication policy, phone/OTP, MFA/PIN enablement, production OAuth consent/app verification, release/Play signing fingerprints, iOS Google proof, profile creation, admin verification dashboard, payments, notifications, reviews, calls, calendar sync, notes, prescriptions, staging data, and production claims remain deferred | `docs/NEXT_SURFACE_AFTER_CATEGORY_SPECIALTY_REGRESSION_DECISION.md`, `docs/GOOGLE_SIGN_IN_SETUP_PREREQUISITES.md`, `lib/features/Authentication/data/repositories/auth_repository.dart` | D143 |
| Google account linking | `GOOGLE_ACCOUNT_LINKING_WIRING.md` records the Account-hosted protected Google linking path, and `GOOGLE_ACCOUNT_LINKING_REGRESSION.md` records proof for placement, config gate, provider token handoff, safe failures, no raw text/token exposure, and no local account mutation. Account shows `Google account` below Authentication, requires configured `GoogleIdTokenProvider`, obtains a real ID token, calls `AuthRepository.googleLink`, and keeps account/session fields backend-owned | Google sign-up role selection, Google unlinking, cross-email linking, recovery linking, recent re-authentication policy, phone/OTP, MFA/PIN enablement, production OAuth consent/app verification, release/Play signing fingerprints, iOS Google proof, profile creation, admin verification dashboard, payments, notifications, reviews, calls, calendar sync, notes, prescriptions, staging data, and production claims remain deferred | `docs/GOOGLE_ACCOUNT_LINKING_UI_BOUNDARY.md`, `docs/GOOGLE_ACCOUNT_LINKING_WIRING.md`, `docs/GOOGLE_ACCOUNT_LINKING_REGRESSION.md`, `lib/features/Home/presentation/pages/account_shell.dart`, `lib/features/Authentication/data/repositories/auth_repository.dart`, `lib/features/Authentication/data/services/google_sign_in_provider.dart` | D144, D145, D146 |
| Next surface after Google linking regression | `NEXT_SURFACE_AFTER_GOOGLE_LINKING_REGRESSION_DECISION.md` selects admin verification review boundary as the next backend-completed surface decision because professional upload/list is wired but reviewer-side queue/signed-read/approve-reject remains frontend-unconsumed | Runtime admin UI, admin queue display, private signed-read opening, approve/reject actions, rejection reasons, role/access implementation, admin audit display, document preview/download handling, production admin hardening, staging claims, and all unrelated payment/notification/review/call/calendar/notes/prescription/phone/MFA modules remain deferred until the boundary is accepted | `docs/NEXT_SURFACE_AFTER_GOOGLE_LINKING_REGRESSION_DECISION.md`, backend `docs/05-api-plan.md`, `docs/GOOGLE_ACCOUNT_LINKING_REGRESSION.md` | D147 |
| Admin verification review boundary | `ADMIN_VERIFICATION_REVIEW_SURFACE_BOUNDARY.md` keeps reviewer tooling outside Flutter. A separate Web-Developers console now provides protected admin sign-in, backend role/readiness checks, paginated queue, short-lived signed-document access, approve/reject with aggregate-status confirmation, and route-level API/session integration coverage (PRs #1-#4; main `d1a6811dde731e8a119f6e31ff1f9ee8853a9140`) | The console remains source-only: private hosting/access perimeter, matching backend configuration, explicit first-admin provisioning, and controlled staging browser review remain uncompleted. No administrator has been provisioned. This mobile app must not add admin routes, hidden admin mode, signed-read handling, approve/reject controls, or admin previews | `docs/ADMIN_VERIFICATION_REVIEW_SURFACE_BOUNDARY.md`, Web `docs/ADMIN_VERIFICATION_CONSOLE.md`, backend `docs/05-api-plan.md` | D148 |
| Final backend-completed mobile surface checkpoint | `FINAL_BACKEND_COMPLETED_MOBILE_SURFACE_CHECKPOINT.md` confirms no remaining backend-completed surface clearly belonging in the patient/professional mobile app is waiting for first-pass runtime wiring; `BACKEND_COMPLETED_SURFACE_WIRING_MAP.md` is updated to current status | Stabilization/regression plan, grouped smoke evidence, public staging access, production app links, release signing/store readiness, admin dashboard, phone/OTP, MFA, Google unlinking, payments, notifications, reviews, calls, calendar sync, notes, prescriptions, messaging backend, community backend, and content backend remain deferred or separate lanes | `docs/FINAL_BACKEND_COMPLETED_MOBILE_SURFACE_CHECKPOINT.md`, `docs/BACKEND_COMPLETED_SURFACE_WIRING_MAP.md` | D149 |
| Mobile backend integration stabilization | `MOBILE_BACKEND_INTEGRATION_STABILIZATION_PLAN.md` defines grouped regression suites, focused analyze/docs checks, manual smoke checklist, known blockers, and the next execution slice for the already-wired backend mobile milestone | Regression execution evidence, public staging data/access, production app links, release signing/store readiness, admin dashboard, phone/OTP, MFA, Google unlinking, payments, notifications, reviews, calls, calendar sync, notes, prescriptions, messaging backend, community backend, and content backend remain deferred or separate lanes | `docs/MOBILE_BACKEND_INTEGRATION_STABILIZATION_PLAN.md` | D150 |
| Mobile backend integration regression pass | `MOBILE_BACKEND_INTEGRATION_REGRESSION_PASS.md` records green grouped regression and focused analyze evidence for the already-wired backend mobile milestone after one password-recovery test-harness fixture fix | Handoff package, public staging data/access, staging smoke with seeded accounts/data, production app links, release signing/store readiness, admin dashboard, phone/OTP, MFA, Google unlinking, payments, notifications, reviews, calls, calendar sync, notes, prescriptions, messaging backend, community backend, and content backend remain deferred or separate lanes | `docs/MOBILE_BACKEND_INTEGRATION_REGRESSION_PASS.md`, `test/features/authentication/password_recovery_flow_test.dart` | D151 |
| Mobile milestone handoff/staging boundary | `MOBILE_MILESTONE_HANDOFF_STAGING_BOUNDARY.md` selects the frontend milestone handoff package as the next lane before staging seed-data/smoke setup or release readiness | Handoff package is next; staging seed data/smoke, release-signing/app-link readiness, admin dashboard, phone/OTP, MFA, Google unlinking, payments, notifications, reviews, calls, calendar sync, notes, prescriptions, messaging backend, community backend, and content backend remain separate lanes | `docs/MOBILE_MILESTONE_HANDOFF_STAGING_BOUNDARY.md` | D152 |
| Mobile backend milestone handoff package | `MOBILE_BACKEND_MILESTONE_HANDOFF_PACKAGE.md` summarizes wired backend-completed mobile surfaces, regression evidence, manual smoke inputs, admin/release/deferred boundaries, and safe presentation wording | Staging seed-data/smoke execution, release-signing/app-link readiness, admin dashboard, phone/OTP, MFA, Google unlinking, payments, notifications, reviews, calls, calendar sync, notes, prescriptions, messaging backend, community backend, and content backend remain separate lanes | `docs/MOBILE_BACKEND_MILESTONE_HANDOFF_PACKAGE.md` | D153 |
| Staging seed data and smoke plan | `STAGING_SEED_DATA_SMOKE_EXECUTION_PLAN.md` defines required staging environment, patient/professional accounts, verified professional data, availability, appointment lifecycle data, verification upload access, cleanup/reset rules, build commands, manual smoke checklist, evidence requirements, and blocker rules. `STAGING_MOBILE_GATEWAY_PHONE_INSTALL_CHECKPOINT.md` records that the gateway-configured APK builds, installs on the phone, launches after the Android `MainActivity` package mismatch was fixed, and now has staging-only patient/professional seed data plus backend public-listing/availability/appointment lifecycle proof. Patient phone login/profile/current-account/Search listing/public availability proof passed. Public availability parsing and UTC request-time bugs found during smoke were fixed | Final real-device phone appointment-request/scheduling walkthrough after reinstall, professional-role walkthrough, verification upload UI smoke, cleanup/reset proof, release-signing/app-link readiness, admin dashboard, and deferred product modules remain separate lanes. Reinstall/final phone proof is currently blocked until `adb devices -l` lists the Android test phone again | `docs/STAGING_SEED_DATA_SMOKE_EXECUTION_PLAN.md`, `docs/STAGING_MOBILE_GATEWAY_PHONE_INSTALL_CHECKPOINT.md`, `android/app/src/main/java/com/carenet/app/MainActivity.java`, `lib/features/Home/data/services/scheduling_api_client.dart`, `lib/features/Home/data/models/availability_window_model.dart`, `lib/features/Home/domain/services/appointment_request_time_options.dart` | D154, D155 |
| Scheduling/availability/appointment next lane | `SCHEDULING_AVAILABILITY_APPOINTMENT_LANE_DECISION.md` selects scheduling as the next backend-integration lane, but requires a frontend contract slice before runtime wiring | Runtime availability repository/API boundary, public availability read, professional own availability management, appointment request/list/lifecycle wiring, public detail, Find Mentor, Specialist Details, payments, notifications, reviews, calls, calendar sync, admin override, patient completion, no-show/disputes, notes, prescriptions, and medical records remain deferred until their scoped contract/runtime slices | `docs/SCHEDULING_AVAILABILITY_APPOINTMENT_LANE_DECISION.md` | D084 |
| Scheduling/availability/appointment frontend contract | APP-P1-005 consumes the backend single-detail and requestable-times contracts, renders returned UTC instants with IANA timezone rules, persists an account-bound booking intent, and sends patient-only appointment requests with `Idempotency-Key`. APP-P1-018 requests requestable times in bounded 14-day UTC pages and loads later pages explicitly without client recurrence logic. Search owns no availability or submission behavior | Server-side cursor pagination, blocked dates, payments, notifications, reviews, calls, calendar sync, admin override, patient completion, no-show/disputes, notes, prescriptions, advanced scheduling exceptions, and medical records remain deferred | `docs/PHASE_1_PROFESSIONAL_DETAIL_BOOKING.md`, `docs/PHASE_1_FIND_CARE.md`, `lib/features/Home/data/services/scheduling_api_client.dart`, `lib/features/Home/data/repositories/scheduling_repository.dart`, `lib/features/Home/presentation/pages/specialist_details_shell.dart` | D085, D086, D087 |
| Appointment request UI path | The old free-text local booking form remains retired. `bookAppointment` resolves to canonical Find Care, while Specialist Details selects only backend-returned requestable times and submits with backend `REQUESTED` semantics | Payment, calls, notifications, reviews, calendar sync, advanced scheduling, admin override, notes, prescriptions, and medical records remain deferred | `docs/APPOINTMENT_REQUEST_UI_PATH_DECISION.md`, `docs/PHASE_1_PROFESSIONAL_DETAIL_BOOKING.md`, `lib/features/Home/presentation/pages/specialist_details_shell.dart` | D088, D089 |
| Concrete appointment request UX | Specialist Details is now the sole backend detail/request owner. It uses backend-generated times, fixed 30-minute requests, patient authority, persisted auth/onboarding resume, stale-time refresh, idempotent retry, and honest `REQUESTED` success. Missing IDs and old direct booking routes fail closed or return to Find Care | Appointment list/detail polish, patient completion, no-show/dispute, payments, notifications, reviews, calls, calendar sync, admin override, notes, prescriptions, medical records, reschedule reasons, blocked dates, buffers, and variable durations remain deferred | `docs/PHASE_1_PROFESSIONAL_DETAIL_BOOKING.md`, `lib/features/Home/presentation/pages/specialist_details_shell.dart`, `lib/features/Home/presentation/state/professional_booking_controller.dart`, `lib/features/Home/data/repositories/scheduling_repository.dart` | D090, D091, D092, D093, D094, D095, D104, D110 |
| Readings export | `Download Readings` is explicitly deferred | Real report generation, file download/share, backend history query | `lib/features/Home/presentation/pages/readings.dart` | D005 |
| Blood sugar readings | Local entry/history/trend/delete state | Backend readings model, multi-device sync, additional vital types, export integration | `lib/features/Home/presentation/state/readings_local_store.dart`, `lib/features/Home/presentation/pages/blood_sug_shell.dart` | D005 |
| Health record | Local health-file summary cards reflect the readings store for blood sugar | Backend health-history API, report/export generation, additional synced vital types | `lib/features/Home/presentation/pages/health_record_shell.dart`, `lib/features/Home/presentation/state/readings_local_store.dart` | D012 |
| Appointments | `appointments` is a role-aware backend own-list with deterministic sections and viewer-scoped persisted counterpart display identity; `appointmentDetail` resolves an exact ID only from that authenticated list. Central action policy hides invalid transitions, mutations serialize and reload authority, reschedule uses backend-generated 30-minute requestable times, and eligible detail states open the exact appointment conversation | Single appointment-detail endpoint, richer participant profiles/contact details, cancellation/reschedule reasons, audit-history UI, patient completion, no-show/dispute, calls, payments/refunds, notification delivery, calendar sync, notes, prescriptions, medical records | `lib/features/Home/presentation/pages/appointment_experience_shell.dart`, `lib/features/Home/presentation/state/appointment_experience_controller.dart`, `docs/PHASE_1_APPOINTMENT_EXPERIENCE.md`, `docs/PHASE_1_APPOINTMENT_MESSAGING.md` | D011, D084, D085, D086, D088, D089, D090, D091, D092, D093, D094, D095, D096, D097, D101, D102, D103, D104, D105, D107, D109, D110, D111, APP-P1-019 |
| Scheduling staging smoke | `SCHEDULING_CORE_STAGING_SMOKE_CHECKPOINT.md` records partial staging proof: backend health/readiness reachable through developer-private proxy, staging-configured APK builds, public professionals route is reachable but empty, and protected scheduling routes reject unauthenticated access. `SCHEDULING_SMOKE_DATA_OR_NEXT_SURFACE_DECISION.md` rejects ad hoc Flutter-created staging users/data | End-to-end scheduling smoke still needs deliberate backend/staging patient and professional accounts, verified public professional data, availability windows, appointment seed or safe creation path, and cleanup/reset guidance before it can be claimed complete | `docs/SCHEDULING_CORE_PAUSE_OR_SMOKE_DECISION.md`, `docs/SCHEDULING_CORE_STAGING_SMOKE_CHECKPOINT.md`, `docs/SCHEDULING_SMOKE_DATA_OR_NEXT_SURFACE_DECISION.md`, `docs/APPOINTMENT_RESCHEDULE_REGRESSION.md`, `docs/SCHEDULING_CORE_REGRESSION_CHECKPOINT.md` | D112, D113, D114 |
| Professional availability management | Professional `selectedDates` reads and atomically replaces backend own recurring availability using `availabilityWindows`/`isActive`, weekday `0..6`, IANA timezone and overlap validation. Mutations serialize and reload authority; patients fail closed; windows are never called confirmed slots | Blocked dates, one-off overrides, holidays, recurring exceptions, breaks/buffers, capacity, waitlists, variable appointment duration, provider calendar sync, payment/entitlement gates | `lib/features/Home/presentation/pages/selected_dates_shell.dart`, `lib/features/Home/presentation/state/professional_schedule_controller.dart`, `docs/PHASE_1_APPOINTMENT_EXPERIENCE.md` | D098, D099 |
| Professional appointment lifecycle UI | `appointments` now exposes role-aware professional `Accept`/`Decline` for eligible `REQUESTED` appointments and `Complete` for eligible accepted appointments only after reading authenticated session role. Completion appears only after scheduled end time and succeeds only through `SchedulingRepository.completeAppointment`. Patient/professional reschedule now appears only on upcoming `REQUESTED`/`ACCEPTED` appointments and succeeds only through `SchedulingRepository.rescheduleAppointment` using generated availability options | Patient completion, no-show/dispute, admin override, payments/refunds/payouts, notifications/reminders, calls, calendar sync, reviews, notes, prescriptions, medical records, free-text datetime entry, reschedule reasons | `lib/features/Home/presentation/pages/appointments_shell.dart`, `lib/features/Home/data/repositories/scheduling_repository.dart`, `docs/PROFESSIONAL_APPOINTMENT_LIFECYCLE_UI_BOUNDARY_DECISION.md`, `docs/PROFESSIONAL_APPOINTMENT_LIFECYCLE_REGRESSION.md`, `docs/APPOINTMENT_RESCHEDULE_COMPLETION_BOUNDARY_DECISION.md`, `docs/APPOINTMENT_COMPLETION_REGRESSION.md`, `docs/POST_COMPLETION_SCHEDULING_LANE_DECISION.md`, `docs/SCHEDULING_CORE_REGRESSION_CHECKPOINT.md`, `docs/POST_REGRESSION_SCHEDULING_LANE_DECISION.md`, `docs/APPOINTMENT_RESCHEDULE_UX_BOUNDARY_DECISION.md`, `docs/APPOINTMENT_RESCHEDULE_REGRESSION.md` | D100, D101, D102, D103, D104, D105, D106, D107, D108, D109, D110, D111 |
| Paid consultation financial experience | PAY-P1-008 uses backend-owned NGN price snapshots and 15 percent commission, launches strict Paystack hosted checkout with a persisted retry key, refreshes backend payment authority on resume, and presents professional price, masked bank setup, held/eligible/available/processing/paid balances, ledger, cooling/review state, and payout history | Live Paystack test collection/transfer proof without credentials, stored cards, wallets, subscriptions, discounts, instalments, cash, insurance, tax invoices, partial/patient refunds, instant withdrawal, immediate split settlement, multi-currency, and a second live provider remain deferred | `docs/PHASE_1_FINANCIAL_EXPERIENCE.md`, `lib/features/Home/presentation/pages/appointment_experience_shell.dart`, `lib/features/Home/presentation/pages/professional_finance_shell.dart`, `lib/features/Home/data/repositories/financial_repository.dart` | PAY-P1-008 |
| Appointment-linked VIDEO/AUDIO consultations | CALL-P1-009 uses backend-owned paid appointment authority plus an official LiveKit Flutter adapter for prejoin, waiting/admission, active media controls, reconnect/rejoin, leave/end, incidents, and cleanup. Calls remain inside Appointment Detail. APP-READY-042 hardens room/track ownership and grant-limited controls without certifying SDK/native behavior | LiveKit Cloud credential/device certification when unavailable, SDK-internal reconnect republishing, physical camera/microphone shutdown proof, recording, transcription, native incoming calls, push delivery, automatic refund/compensation, medical notes, prescriptions, reviews, advanced analytics, audio visualizer, leave-waiting mutation, and another RTC provider remain deferred | `docs/PHASE_1_APPOINTMENT_CONSULTATIONS.md`, `docs/RTC_ADAPTER_RESOURCE_SAFETY.md`, `lib/features/Consultation/`, `lib/features/Home/presentation/pages/appointment_experience_shell.dart` | CALL-P1-009; APP-READY-042 |
| Emergency | Local distress update and dispatch/clear state | Real emergency escalation, location permissions, dispatch backend, contact center/status webhooks | `lib/features/Home/presentation/pages/emergency_shell.dart` | Backend decision needed |
| Articles / saved articles / published articles | Local article list/detail plus saved/read state; `savedArticles` lists locally saved articles and supports read/remove behavior; `publishedArticles` lists locally known portfolio articles, opens in-page detail, and shows honest deferred Request/Drafts states | Content API, saved-to-account sync, `subscribers`, `article-story`, `add-new-article`, persisted drafts, author profiles, comments/reactions, creator publishing, edit/delete flows, publication analytics, moderation, subscriber access | `lib/features/Home/presentation/pages/articles_shell.dart`, `lib/features/Home/presentation/pages/saved_articles_shell.dart`, `lib/features/Home/presentation/pages/published_articles_shell.dart`, `lib/features/Home/presentation/state/articles_local_store.dart`, `lib/features/Home/presentation/state/manage_portfolio_local_store.dart` | D006, D013, D037, D038 |
| Case studies | Local case-study list/detail, filters, and read state | Content API, verified clinical review, author/publication records, comments, sharing, saved-to-account sync, moderation | `lib/features/Home/presentation/pages/case_studies_shell.dart`, `lib/features/Home/presentation/state/case_studies_local_store.dart` | D014 |
| Communities | Local discover/join/profile/create flow plus owner-circle profile with locked owner settings | Invitations, delivery, media upload, posts, moderation, permissions, member management, role changes, editing circle details, sharing, favourites sync, reporting, exiting, destructive circle actions, membership approvals, community backend | `lib/features/Home/presentation/pages/circles_shell.dart`, `community_profile_page.dart`, `create_community_page.dart`, `communities_local_store.dart` | D007, D016 |
| Community invitations/discover | Existing discover route now includes For you, Requests, and Drafts tabs; accepting a seeded invitation reuses joined-community state | Invitation delivery, request rejection, approval workflow, draft persistence, invite permissions, moderation, backend membership sync | `lib/features/Home/presentation/pages/circles_shell.dart`, `lib/features/Home/presentation/state/communities_local_store.dart` | D033 |
| Q&A | Local Q&A feed, ask, answer requests, tagged questions, answer draft state | Feed distribution, audience rules, moderation, notifications, mixed post/question composer | `lib/features/Home/presentation/pages/qa_shell.dart`, `lib/features/Home/presentation/state/qa_local_store.dart` | D008 |
| Account | Local account/settings/delete/deactivate flows plus local account-security draft routes for phone/email/password changes; Account logout now clears the auth session through `AuthRepository.logout`; current-account read can replace safe email/status display when backend session data is available; Account can link Google through configured `GoogleIdTokenProvider` plus `AuthRepository.googleLink`; Settings/Profile now reads patient profile `name`/`age`/`location` read-only and updates backend patient `name` only through `ProfileRepository` when available | Public profile, age/location patient mutation, username/email/bio persistence, profile edit persistence, change-auth security, support, scheduling, creator/public identity, destructive account APIs, Google unlink/cross-email/recovery/re-auth policy, OTP/code delivery, account-session updates, persistence, audit/security notifications | `lib/features/Home/presentation/pages/account_shell.dart`, `lib/features/Home/presentation/pages/add_phone_number_shell.dart`, `lib/features/Home/presentation/pages/confirm_phone_number_shell.dart`, `lib/features/Home/presentation/state/account_local_store.dart` | D009, D020, D059, D061, D117, D120, D145 |
| Change authentication | Local two-step verification information route; Change PIN, Turn off, and Learn more are locked/deferred | Auth backend, re-authentication, secure PIN storage, device/session verification, audit logs, disable-2FA rules, phone/email/code verification, product-approved security help copy | `lib/features/Home/presentation/pages/change_authentication_shell.dart` | D019 |
| Turn on authentication | Local two-step verification review route; Turn on stays disabled | PIN creation, secure PIN storage, session/device checks, audit/security notifications, account persistence, recovery rules | `lib/features/Home/presentation/pages/turn_on_authentication_shell.dart` | D027 |
| Create PIN | Local PIN-format route; valid 6-digit PINs can be prepared for route-local confirmation but are not saved and do not enable 2FA | Secure PIN storage, session/device checks, audit/security notifications, account persistence, recovery rules | `lib/features/Home/presentation/pages/create_pin_shell.dart` | D028 |
| Confirm PIN Save | Local PIN confirmation route; route-local matching can prepare a confirmed PIN for secure backend storage but does not save it or enable 2FA | Secure PIN storage, session/device checks, audit/security notifications, account persistence, recovery rules | `lib/features/Home/presentation/pages/confirm_pin_save_shell.dart` | D029 |
| Add phone number | Local phone-entry draft route; valid phones can be prepared for verification but do not update the account or send OTP | SMS/OTP provider, code verification, phone uniqueness, password re-authentication, rate limiting, auth-session update, account persistence, recovery/security copy | `lib/features/Home/presentation/pages/add_phone_number_shell.dart`, `lib/features/Home/presentation/state/account_local_store.dart` | D020 |
| Confirm phone number | Local phone confirmation draft route; valid phone numbers can be prepared for backend OTP verification but no OTP is sent and no account phone changes | SMS/OTP provider, code confirmation, phone uniqueness, session updates, rate limiting, audit/security notifications, account persistence | `lib/features/Home/presentation/pages/confirm_phone_number_shell.dart`, `lib/features/Home/presentation/state/account_local_store.dart` | D026 |
| Add email | Local email-entry draft route; valid email addresses can be prepared for verification but do not update the account or send verification | Verification email provider, code confirmation, email uniqueness checks, password re-authentication, rate limiting, auth-session update, account persistence, recovery/security copy | `lib/features/Home/presentation/pages/add_email_shell.dart`, `lib/features/Home/presentation/state/account_local_store.dart` | D022 |
| Edit email | Local current-email management route; current email shows verified, edit hands off to `changeEmail`, and remove stays disabled | Email removal API, password re-authentication, recovery rules, account-session update, account persistence, audit/security notifications | `lib/features/Home/presentation/pages/edit_email_shell.dart`, `lib/features/Home/presentation/state/account_local_store.dart` | D024 |
| Enter password to save | Local password-entry route; valid-length passwords can be prepared for backend re-authentication but are not verified and do not unlock/save account changes | Auth backend password verification, session/device checks, rate limiting, audit/security notifications, account mutation unlocks, account persistence, recovery rules | `lib/features/Home/presentation/pages/enter_password_to_save_shell.dart`, `lib/features/Home/presentation/state/account_local_store.dart` | D025 |
| Change email | Local change-email draft route; different valid emails can be prepared for code verification but do not update the account or send verification | Verification email provider, code confirmation, email uniqueness checks, password re-authentication, rate limiting, auth-session update, account persistence, recovery/security copy | `lib/features/Home/presentation/pages/change_email_shell.dart`, `lib/features/Home/presentation/state/account_local_store.dart` | D023 |
| Password | Local password security information route; Edit password is locked/deferred | Auth backend, current-password verification, password policy, password reset/change API, code confirmation, session invalidation, recovery/security notifications, account persistence | `lib/features/Home/presentation/pages/password_shell.dart`, `lib/features/Home/presentation/state/account_local_store.dart` | D021 |
| Public profile | Local read-only professional profile; `Message` opens messages; `Schedule` opens local booking; portfolio/podcast/share are disabled | Profile API, creator portfolio, podcast/media profile content, product-approved sharing, provider scheduling, verified public identity, public reviews/testimonies, subscription/upgrade behavior | `lib/features/Home/presentation/pages/public_profile_shell.dart`, `lib/features/Home/presentation/state/public_profile_local_store.dart` | D015 |
| Manage profile | Profile-management summary with Basic, About, Business schedule, and Articles sections. Professional self-profile read can replace only `displayName`, `category`, `specialty`, and `bio`; empty/error states are safe. `addDescription` now updates existing professional profile `bio` only. `Edit`, address, and website routes still use local validation and draft-only preparation; `Message` opens messages; Events, Boost, Podcast, Share, member management, and group-detail edits are disabled | Profile creation, name/category/specialty editing, website/address persistence, patient profile UI, public listing/detail replacement, account identity sync, verification status changes, location/geocoding/map contracts, device-location permission rules, profile-copy moderation/compliance rules, public profile publishing, audit/security records, conflict handling, business schedule persistence, scheduling/event APIs, payment/ad-review rules, media/podcast APIs, product-approved sharing, community member management, group-detail persistence, creator verification remain deferred | `lib/features/Home/presentation/pages/manage_profile_shell.dart`, `lib/features/Home/presentation/pages/edit_your_name_shell.dart`, `lib/features/Home/presentation/pages/edit_your_website_shell.dart`, `lib/features/Home/presentation/pages/set_address_shell.dart`, `lib/features/Home/presentation/pages/add_description_shell.dart`, `lib/features/Home/presentation/state/public_profile_local_store.dart` | D017, D040, D041, D042, D043, D044, D045, D047, D048, D079, D080, D081 |
| Manage portfolio | Local managed portfolio surface with Page/Circles tabs, local portfolio content, and settings/messages handoffs; Add new article, Upload new podcast, Upgrade, Events, Boost, Podcast, and Share are disabled | Creator portfolio API, article draft/publish workflow, podcast upload/recording/processing, media ownership rules, moderation, subscription/payment/upgrade rules, ad-review rules, sharing/deep-link contracts, analytics | `lib/features/Home/presentation/pages/manage_portfolio_shell.dart`, `lib/features/Home/presentation/state/manage_portfolio_local_store.dart` | D018 |

### Manage profile backend replacement contract (for future implementation)

When `manageProfile` resumes, keep the existing route and screen flow. Replace the local source behind a profile-management state/repository boundary instead of rewriting the page.

Required backend/product contracts before enabling deeper controls:

| Capability | Required contract before enablement |
|------------|-------------------------------------|
| Basic profile editing | Authenticated profile read/update API; server validation for name, business name, category, address, website, email, and phone; conflict/error states |
| About/profile copy | Profile text update API; moderation/compliance rules for public medical claims |
| Business schedule | Business-hours read/update API; timezone, closed-day, 24-hour, appointment-only, and validation rules |
| Events | Event listing/create/update API; scheduling ownership rules and cancellation/error states |
| Boost/ads | Payment provider, ad budget rules, ad-review workflow, invoice/receipt handling, insufficient-funds states |
| Podcast/media | Media upload/processing API, ownership rules, playback/streaming contract, failure states |
| Share | Product-approved share targets, privacy rules, deep-link format, analytics rules |
| Members/group details | Community membership/role API, invite delivery, permission model, moderation rules, auditability |
| Creator verification | Verification status API, required documents/copy, review states, rejection/appeal behavior |
| Podcast | Local podcast list and local `Watch` state | Streaming playback, episode APIs, comments, uploads/recording, saved-to-account sync, search filtering | `lib/features/Home/presentation/pages/podcast_shell.dart`, `lib/features/Home/presentation/state/podcast_local_store.dart` | D010 |
| Find Care / consultants | Canonical Search reads the public verified directory, filters only name/category/specialty, and passes the exact backend ID to canonical Specialist Details. Detail loads one public profile and backend-generated requestable times without local fallback | Backend search/pagination, symptom/condition catalog, payment, broader appointment presentation, and later deletion of retained legacy source | `docs/PHASE_1_FIND_CARE.md`, `docs/PHASE_1_PROFESSIONAL_DETAIL_BOOKING.md`, `lib/features/Home/presentation/pages/search_shell.dart`, `lib/features/Home/presentation/pages/specialist_details_shell.dart` | D011, D082, D083, D087, D091, D092 |
| Find mentor | `RouteName.findMentor` is a compatibility alias to canonical Find Care. The old `FindMentorShellPage` and local store remain only as recoverable source and are not active discovery or booking surfaces | Delete retained legacy source after Phase 1 regression proves no shared dependency; ratings/reviews, payment, provider calendar sync, and advanced filtering remain deferred | `lib/core/constants/navigators/router.dart`, `lib/features/Home/presentation/pages/find_mentor_shell.dart`, `lib/features/Home/presentation/state/search_local_store.dart`, `docs/PHASE_1_FIND_CARE.md` | D034, D126, D127 |
| Specialist details | Canonical detail calls one backend profile by ID, loads backend requestable times, displays professional IANA time, resumes a secure 24-hour booking intent through auth/onboarding, and submits idempotently as a patient. No local identity, slot generation, or direct draft booking remains reachable | Ratings/reviews, payment/pricing, calls, calendar sync, cancellation policy text, notes, prescriptions, advanced scheduling, and final legacy-source deletion | `lib/features/Home/presentation/pages/specialist_details_shell.dart`, `lib/features/Home/presentation/state/professional_booking_controller.dart`, `docs/PHASE_1_PROFESSIONAL_DETAIL_BOOKING.md` | D035, D123 |
| Transactional notifications | Header bell opens the authenticated durable inbox; backend preferences control push/email by category; secure FCM installation registration, contextual permission, unread badge, read/read-all, foreground display, cold-start tap retention and owner-checked allowlisted routes are active | iOS APNs production certification, rich notification media/actions, marketing/newsletters, SMS/WhatsApp, notification analytics, and a second push/email provider remain deferred | `docs/PHASE_1_TRANSACTIONAL_NOTIFICATIONS.md`, `lib/features/Notifications/`, `lib/features/Messaging/presentation/pages/Notification.dart` | NOTIF-P1-010 |
| Reminders | Backend plans and suppresses transactional appointment/payment/consultation reminders from authoritative domain state; delivered reminders appear in the same inbox/provider pipeline | User-created reminders, arbitrary recurrence, local calendar reminder CRUD, snooze, geofencing, and generic lifestyle reminders remain deferred | Backend `NOTIF-P1-010A`, `docs/PHASE_1_TRANSACTIONAL_NOTIFICATIONS.md`; legacy `reminder_shell.dart` remains outside active navigation pending cleanup | NOTIF-P1-010; D030 |
| Schedules | Selectable calendar and read-only expandable task-reminder card from the dashboard drawer | Schedule CRUD, recurrence/timezone calculations, live countdowns, persistence/API ownership, sharing/deep links, reminder delivery, permissions, failure states | `lib/features/Home/presentation/pages/schedules_shell.dart`, `lib/features/Home/presentation/widget/drawer.dart` | D031 |
| Selected dates / business hours | The old route-local date draft is retired from the active path. `selectedDates` now edits the professional's backend recurring weekly availability and Manage Profile reaches the same authoritative Schedule | Blocked dates, one-off overrides, holidays, breaks/buffers, capacity, variable duration, upgrade entitlements, provider calendar sync | `lib/features/Home/presentation/pages/selected_dates_shell.dart`, `lib/features/Home/presentation/pages/manage_profile_shell.dart`, `docs/PHASE_1_APPOINTMENT_EXPERIENCE.md` | D032, D084, D085, D086 |
| Messaging/chat | Core appointment-linked plain-text messaging is implemented with backend-owned participants, lifecycle, unread/Seen, HTTP history, optimistic idempotent send, and body-free WebSocket recovery | Push delivery, attachments, rich chat, moderation/reporting, retention/export/erasure/anonymisation, legal hold/disputes, backup deletion, and medical-record classification | `lib/features/Messaging/`, `docs/PHASE_1_APPOINTMENT_MESSAGING.md` | Core complete; launch/privacy gates remain deferred |
| Payments/subscriptions/ads | Not built as frontend-ready flows yet | Payment provider, plan rules, invoices/receipts, ad budgets, campaign approvals | Blueprint payment/subscription/ad routes | Payment decision needed |
| Creator tools | Not built as frontend-ready flows yet | Creator profile, portfolio, article/podcast publishing, recording/upload APIs, moderation | Blueprint creator routes | Backend/product decision needed |

---

## Current rule for future slices

## APP-P1-014 authority follow-up

- Add a backend-owned account deletion/deactivation request with recent
  reauthentication, retention status, audit behavior, and full session/token
  revocation before re-enabling either control.
- Add real email-change, phone verification, password-change, and second-factor
  contracts before re-enabling the retained local account source screens.
- Delete `AccountLocalStore` and retained deferred screen sources only in a
  dedicated cleanup slice after dependency analysis. They are unreachable from
  the active router but remain recoverable today.
- Replace the common deferred route page only when a backend/product contract
  explicitly returns that capability to Phase 1 scope.

When a new slice touches one of the areas above:

1. Re-check the relevant blueprint folder and `routes.json`.
2. Build only the smallest honest local/frontend-ready behavior.
3. If the next step needs backend/payment/media/legal/provider rules, stop and add or update a `DECISIONS.md` row.
4. Update this file with any new local seam or replacement point.

---

## Backend/product readiness handoff

Task `49.1` groups the remaining deferred seams by contract so backend/product work can start without rewriting the completed frontend routes.

Task `50.1` final review status: frontend route coverage is ready for backend/product contract selection. Keep `login` reserved/unwired unless a future auth-routing task explicitly activates it.

| Contract group | Frontend seams already waiting | Required decisions before enablement | Replacement path |
|----------------|--------------------------------|--------------------------------------|------------------|
| Auth/session/account persistence | Sign-up, sign-in, password recovery, account settings, delete/deactivate, add/change/remove email, add/confirm phone, password re-auth, two-step verification, PIN setup | API base URL, auth/session storage, refresh, account persistence, server validation, OTP/email-code providers, rate limits, re-auth rules, audit/security notifications | Replace `AccountLocalStore` and local auth validation seams with auth/account repositories; keep existing route names and validation surfaces |
| Profile/public identity | `publicProfile`, `manageProfile`, `editYourName`, `editYourWebsite`, `addDescription`, `setAddress`, creator verification, public profile sections | Profile read/update API, server validation, verification states, public-claim moderation, address/location verification, conflict/error handling, audit records | Replace `PublicProfileLocalStore` behind profile read/update repository boundaries; keep Manage Profile handoffs and draft routes |
| Scheduling/provider availability | Appointments, booking draft, Search consultant request, Find Mentor, Specialist Details, selectedDates/business hours, schedules, reminders | Provider availability API, calendar slots, booking confirmation/cancel rules, business-hours persistence, timezone/overlap rules, recurrence rules, reminder delivery provider, permission behavior | Replace local booking/schedule stores with scheduling repositories; keep existing booking and selected-date routes |
| Content/publishing/moderation | Articles, saved articles, published articles, case studies, Q&A, community posts/profile content, comments/reactions, subscribers, drafts | Content APIs, saved-to-account sync, author/profile metadata, publish/edit/delete workflows, subscriber access, comments/reactions, analytics, moderation and clinical-review rules | Replace local content stores with content/community repositories; keep list/detail/draft surfaces |
| Communities/membership | Circles, discover communities, invitations requests/drafts, community profile, create community, owner circle controls | Community membership API, invite delivery, approval/rejection workflows, roles/permissions, moderation, reporting, exit/delete rules, auditability | Replace `CommunitiesLocalStore` with community repository; keep discover/create/profile routes |
| Health/readings/export | Readings, blood sugar capture/history, health record, download/export | Readings model, multi-device sync, health-history API, report generation, file download/share, additional vital types | Replace `ReadingsLocalStore`; keep readings, add-device, blood sugar, and health-record flows |
| Messaging/notifications | Appointment-linked Messages and Chat now use the authoritative conversation API, HTTP recovery, body-free realtime hints, unread, and Seen. Notifications and reminders remain honest non-operational surfaces | Attachments, rich chat, push provider, server notification payloads, notification read/sync, privacy-safe lock-screen policy, payment notification payloads | Keep core appointment messaging backend-owned; add notification delivery only after provider and privacy contracts are approved |
| Payments/ads/subscriptions | Boost, audience, budget, payment details, select payment method, low/full fund, subscription/upgrade controls | Payment provider, plan/entitlement rules, ad budget rules, ad review, invoices/receipts, insufficient-funds states, refund/cancel behavior | Start only after product/payment contract exists; keep disabled controls until real payment state can drive them |
| Media/podcast/upload/recording | Podcast list/watch state, podcast upload, recording, media in communities/profile/portfolio | Media ownership rules, picker/upload/recording APIs, processing states, playback/streaming, storage, moderation, failure/retry states | Replace `PodcastLocalStore` and media-disabled controls with media repositories once contracts exist |
| Emergency/location | Emergency/distress update, setAddress, provider/profile location display | Location permission rules, geocoding/maps provider, emergency escalation backend, contact-center/status webhooks, privacy rules | Replace local location/address/distress seams with location/emergency repositories |
| Sharing/deep links | Share controls in public/manage profile, portfolio, communities, articles | Product-approved share targets, deep-link format, privacy rules, analytics, platform behavior | Enable existing disabled share controls only after sharing/deep-link contract exists |

Rule for backend start: pick one contract group, define API models and failure states first, then replace the relevant local store/repository seam. Do not enable a locked control merely because a screen exists.
