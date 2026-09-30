# Codebase status

## Google Provider Recovery (APP-READY-038)

Google SDK initialization can retry after rejection, concurrent sign-in taps
share one operation, and initialization waits are bounded without duplicating
a timed-out SDK operation. `GOOGLE_PROVIDER_RECOVERY.md` records the contract
and 19 focused regression assertions. Signed-device OAuth/provider proof is
still a separate release requirement; no backend/session authority changed.

## Protected Release Signing (APP-READY-037)

Release packaging no longer falls back to the Android debug key. The protected
environment contract, certificate validation, and remaining upload/Play proof
are documented in `ANDROID_RELEASE_SIGNING.md`. CI uses disposable signing
fixtures only. Local analyzer, all 527 unchanged Flutter tests, staging debug
APK, and executable signing regressions pass. Separate upload keys, protected
backups, and Firebase upload-certificate registration are verified. Signed
distribution artifacts, Play certificate registration, release configuration,
physical acceptance, and production promotion remain explicit open gates.

**Last updated:** 2026-09-29 APP-P1-021 shared UX/accessibility foundation.

## Android Release Lint Gate

- Staging release lint now runs in Flutter PR/push CI after the debug APK build.
  Jetifier remains enabled; only the Byte Buddy test artifact is excluded from
  transformation because Jetifier cannot parse its newer class-file version.
- Local `lintStagingRelease` completed with zero errors and five warnings.
  The warnings include Android app-link data-tag structure and backup-policy
  configuration; a passing lint task is not a release-security sign-off.
- Android uses AGP 8.11.1 with Gradle 8.13 and Java 17, a toolchain supporting
  compileSdk 36. The staging debug APK and analyzer pass with this pair, and
  the full Flutter suite remains at 527 passing tests with no test changes.
- Release lint passes with zero errors and six warnings. Local Windows SDK
  paths in ignored `local.properties` require escaped drive-letter colons;
  Flutter may regenerate that file, so check its paths before local lint.
  Signed release artifacts still require separate signing and release proof.

## APP-P1-021 shared UX/accessibility foundation

- Shared marketplace tokens and active Material color schemes use the CareNet
  healthcare-green palette with tested text contrast for primary and semantic
  status pairs.
- `CarenetButton` provides one labelled, tappable button semantic, a minimum
  48-logical-pixel hit target, and a content-driven height that accommodates
  enlarged text.
- Professional Schedule no longer describes requestable times with
  engineering-facing "backend-generated" wording.
- Current route inventory is 79 named identifiers and 78 router registrations;
  `login` is the only reserved unwired constant. The three later routes now have
  explicit rows in the classification table.
- This is a shared foundation only, not an accessibility sign-off for every
  active route. Per-screen contrast, focus order, TalkBack, keyboard, and largest
  text checks remain in the APP-P1-021 follow-up sweep.

## Verification upload integrity

- Verification files are SHA-256 hashed off the UI isolate before upload
  completion; completion always sends the file byte count and digest required by
  the backend integrity contract.
- The signed GCS transfer exposes bounded progress and an explicit cancel action.
  Cancellation aborts the active Dio request and never reports review success.
- Signed URLs, object keys, checksums, local paths, and provider internals remain
  absent from the UI and logs.
- Malware scanning, retention/orphan cleanup, background uploads, admin review,
  production bucket IAM proof, and physical-device acceptance remain separate.

## Legal and authentication links

- Canonical Firebase Hosting serves Terms, Privacy, Support, account deletion,
  email-verification fallback, and password-reset fallback pages.
- Signup and Account open the canonical HTTPS legal/support pages.
- Android verified links enter the existing token-confirmation screens only for
  the canonical Hosting host. Production certificate and iOS proof remain
  release gates.

## Authentication and onboarding authority

- Direct phone sign-in/signup routes resolve to the supported email surfaces;
  retained phone, Facebook, and Apple source is not active product UI.
- Legacy community, notification-agreement, and medical-agreement routes resolve
  to the role-appropriate backend-owned setup forms rather than reviving the
  obsolete onboarding chain.
- Patient and professional setup load existing backend profiles before edits.
  Stored catalog codes are restored only when they match the current backend
  catalog; new users must make explicit country, state, health-interest, and
  profession selections instead of accepting a client-chosen first option.

## Account lifecycle

- Account deletion uses the protected backend contract and requires explicit
  `DELETE` confirmation plus a current password or a freshly verified linked
  Google identity.
- A successful request clears the secure session and pending booking/payment
  intents, reports that every session was revoked, and states truthfully that
  required records remain under the applicable retention policy.
- Local account state never grants deletion authority and no hard-erasure or
  restoration behavior is claimed.

## Environment separation

- Canonical Firebase apps are registered for Android and iOS staging/production in `project-a96784ee-811c-46ab-a7b`.
- Android staging (`com.carenet.app.staging`) and production (`com.carenet.app`) are explicit Gradle flavors with distinct labels.
- Runtime environment validation rejects wrong-project Firebase configuration and insecure production API URLs.
- iOS remains registered only; Apple signing, schemes, APNs, and device proof are unresolved release gates.

## Authentication readiness

- Active email sign-in and signup use the green marketplace presentation and scroll under constrained layouts.
- Phone, Facebook, and Apple identity choices are not advertised before supported provider contracts exist.
- Password signup collects only backend-owned registration fields: email, password, and selected role. Profile identity and date of birth remain in the role-specific backend profile flow.
- Mobile password validation matches the backend 15-128 character passphrase policy and known-weak-password baseline.

Honest snapshot of `Mobile-App-master` so a new chat does not rediscover problems.

For a consolidated list of local/mock seams and skipped backend work, see `DEFERRED_WORK.md`.

For the approved Phase 1 product boundary and route/dependency disposition, see
`PHASE_1_MARKETPLACE_BOUNDARY.md`, `PHASE_1_ROUTE_SCREEN_CLASSIFICATION.md`, and
`PHASE_1_DEPENDENCY_IMPACT_MAP.md`.

---

## Maturity level

The broad Figma product is no longer the Phase 1 target. The active target is a
focused patient/professional consultation marketplace. Auth/onboarding,
profile/verification, public professional discovery, availability, and the
appointment lifecycle have real backend boundaries. APP-P1-002 replaces the broad
dashboard with backend-session-owned patient/professional navigation, header bell
and account access, honest messaging/notification empty states, and no active drawer.
APP-P1-003 replaces the static Home wireframe with backend-composed patient and
professional identity, readiness, appointment, and professional availability
states. Home selection is deterministic, section failures remain retryable, and
no payment, messaging, call, recommendation, earnings, or demand state is invented.
APP-P1-004 makes `RouteName.search`/`SearchShellPage` the canonical patient Find
Care experience. It loads the verified public directory once, filters only by
name/category/specialty, keeps refresh failures separate from empty results, and
hands the exact backend professional id to the existing Specialist Details route.
The legacy `findMentor` route aliases Find Care instead of opening a competing
marketplace. APP-P1-005 makes `specialistDetails` a fail-closed single-profile
boundary, renders backend-generated requestable times with IANA timezone rules,
persists a 24-hour account-bound booking intent through auth/onboarding, and submits
patient-only appointment requests with a durable idempotency key. Legacy local
detail and booking routes no longer expose seeded booking behavior.
PAY-P1-008 adds backend-authoritative consultation pricing, hosted Paystack
checkout, payment-state refresh, and a professional finance surface for held
earnings, balances, bank setup, payout cooling, ledger, and payout history.
Flutter never confirms payment from browser return and never handles card data.
APP-P1-011 establishes one bounded Dio transport for active API clients,
serializes one refresh and one authenticated retry after an HTTP 401, stores the
complete authenticated session as one versioned secure record with fail-closed
legacy migration, and moves optional notification initialization after the first
app frame with a bounded provider timeout. A 403 is never treated as an expired
session, and public requests remain unauthenticated.
NOTIF-P1-010 adds a backend-owned durable transactional inbox, channel
preferences, FCM installation lifecycle, contextual permission UX, unread header
badge, privacy-safe foreground/background/terminated handling, and owner-checked
allowlisted routing. Push and email remain transport rather than product authority.
Many retained routes and local account/profile seams still require the ordered
Phase 1 narrowing plan before release claims.

Historical numbered phases remain useful implementation records, but they do
not override the `APP-P1` product boundary.

---

## What works today

| Item | Details |
|------|---------|
| App entry | `lib/main.dart` -> `CarenetApp` in `lib/app.dart` |
| Start screen | `RouteName.splash` (not notifications) |
| Splash -> session guard | 800ms then `AuthRepository.restore()` routes usable stored sessions to `dashboard`; missing or invalid restore falls back to `onboarding`. Auth refresh and booking-resume readiness calls are bounded to five seconds so an unavailable dependency cannot leave startup hanging, and pending notification routing begins only after the replacement frame is ready |
| Named routes | Current inventory has **79 constants and 78 router cases**; `login` is the reserved unused constant. Final Phase 1 disposition is in `PHASE_1_ROUTE_SCREEN_CLASSIFICATION.md` |
| Onboarding UI | First launch shows a care gateway with `Browse verified care`, `Create account`, and `Already have an account? Sign in`. Create account opens role-first signup instead of direct phone signup |
| Role-based onboarding boundary | `ROLE_BASED_ONBOARDING_AUTH_BOUNDARY.md` records the PRD-backed product decision that CareNet sign-up must branch into patient and professional onboarding before Google sign-up or broader auth expansion. Professional accounts must proceed through profile, credential upload, and manual verification before public listing |
| Role-registration backend contract | `ROLE_REGISTRATION_BACKEND_CONTRACT.md` records the exact frontend/backend boundary: email/password and Google-created accounts must use explicit `PATIENT`/`PROFESSIONAL` role selection before account creation is treated as complete. Existing linked Google sign-in and authenticated Google linking remain valid, but first-time Google sign-up stays disabled until role-selection onboarding exists |
| Role-selection signup | `signUpRole` now sits between signup entry and account creation. Email/password registration sends only `email`, `password`, and the selected backend role. Configured Google signup also requires patient/professional role selection, sends a real Google `idToken` plus selected role, then routes into the matching setup surface. Patient registration continues to `patientOnboardingSetup`; professional registration continues to `medicalProfessional` |
| Patient/professional onboarding requirements | `PATIENT_PROFESSIONAL_ONBOARDING_UI_REQUIREMENTS.md` defines the serious next onboarding flow against backend `CAR-BE-119` fields. Profile entity/model/repository expansion is now complete; polished patient/professional setup screens remain the next runtime slice |
| Profile contract expansion | `PROFILE_NIGERIA_ONBOARDING_CONTRACT_EXPANSION.md` records that patient/professional profile entities, models, API payloads, and repository methods now support the backend `CAR-BE-119` onboarding fields. Runtime polished setup screens are still the next slice |
| Patient/professional setup UI | `patientOnboardingSetup` and `medicalProfessional` load backend-owned onboarding catalogs, existing profiles, and account readiness. Matching persisted catalog codes are restored for edits; otherwise country/state/interest/profession choices remain empty until explicitly selected. Professional listing still waits for backend verification |
| Backend-owned onboarding catalog/readiness repository | `OnboardingApiClient` and `OnboardingRepository` consume backend `APP-ID-003` contracts for public `GET /catalogs/onboarding` and protected `GET /account/readiness`. Setup screens now consume this repository without fake local fallback, block save when catalog options are unavailable, and send catalog-owned codes through the currently accepted profile DTO fields |
| Onboarding profile payload code alignment | `ONBOARDING_PROFILE_PAYLOAD_CODE_ALIGNMENT_DECISION.md` decides not to invent unsupported Flutter request fields for `countryCode`, `professionCode`, or `regulatorCode` yet. `ONBOARDING_SETUP_PAYLOAD_VALUE_ALIGNMENT.md` records that patient setup now sends `country`, `state`, and `healthInterests` as backend-accepted catalog codes, while professional setup sends `category`, `licensingCouncil`, `practiceCountry`, and `practiceState` as backend-accepted catalog/regulator codes through current DTO fields |
| Production onboarding domain boundary | `PRODUCTION_ONBOARDING_DOMAIN_HARDENING_BOUNDARY.md` accepts the serious MVP boundary for onboarding: no in-app role switching or dual-mode accounts yet, duplicate identity/application state remains backend-owned, partial professional applications resume through readiness, professional setup stays Nigeria-catalog/regulator driven, required evidence guidance comes from backend catalogs/readiness, and the next slice should plan readiness/resume UX hardening before runtime edits |
| Onboarding readiness route resolver | `ONBOARDING_READINESS_ROUTE_RESOLVER.md` records the runtime resolver. After successful email/password or first-time Google signup, Flutter calls backend `account/readiness` and routes by `nextAction`; readiness failure falls back by selected role so professionals do not go straight to dashboard |
| Onboarding progress/evidence guidance plan | `ONBOARDING_PROGRESS_EVIDENCE_GUIDANCE_PLAN.md` records the next runtime boundary: patient/professional setup and professional verification documents should show backend readiness, required profile fields, required/missing evidence, status/retry copy, and no dummy local approval/readiness state |
| Onboarding readiness progress panel | Patient setup, professional setup, and professional verification documents now show backend-owned readiness guidance. Setup screens display required profile fields returned by `account/readiness`; verification documents displays required/missing evidence with catalog labels plus safe retry copy when requirements cannot load |
| Onboarding regression and phone-smoke plan | `ONBOARDING_REGRESSION_AND_PHONE_SMOKE_PLAN.md` defines the focused proof gate for the hardened onboarding/auth setup: local regression, staging Android patient/professional signup, Google first-time signup, readiness routing, setup progress panels, verification evidence guidance, safe failure states, and exact blocker recording |
| Onboarding phone-smoke execution | `ONBOARDING_PHONE_SMOKE_EXECUTION.md` records that the staging Android debug APK builds with staging gateway and Google config, but real phone smoke is blocked because no Android device is visible to Flutter/ADB |
| Auth onboarding UX recovery | `AUTH_ONBOARDING_UX_RECOVERY.md` records APP-ID-015: the gateway and role-first signup UX from older unmerged APP-66 through APP-73 work was recovered without rolling back newer backend catalog/readiness/profile/verification contracts |
| Recovered onboarding device checkpoint | APP-ID-016 rebuilt the staging APK with the corrected Google Web OAuth client, installed it on Android device `6tkvkvindaqogurk`, confirmed Google login on device, and proved the public staging gateway returns the backend-owned Nigeria catalog at `GET /catalogs/onboarding` after backend redeploy. Controlled onboarding selectors are unblocked without dummy fallback. Public gateway `GET /health/ready` was restored to `200` after applying committed staging migration `20260719090000_identity_catalog_alignment` |
| Onboarding setup regression | `ONBOARDING_SETUP_REGRESSION_AND_PHONE_SMOKE.md` records APP-61 grouped regression proof: 116 auth/onboarding/profile/account tests passed, focused analyze passed, and the staging-configured debug APK built. Phone install/manual smoke is still pending because ADB reported no connected device during APP-61 |
| Sign-up phone | Validates country/region + phone, then routes to `finishSignUp` |
| Sign-up email | Validates email, then routes to `finishSignUp` |
| Sign-up to sign-in links | "Already have an account? Sign in" routes to `signInPhone` / `signInEmail` from matching entry screens |
| Sign-in phone | Validates country/region, phone, and password locally, then routes to `dashboard`; configured Google sign-in obtains a real Google ID token and calls `AuthRepository.googleSignIn` |
| Sign-in email | Validates email and password locally, then routes to `dashboard`; configured Google sign-in obtains a real Google ID token and calls `AuthRepository.googleSignIn` |
| Password recovery | `Forgot Password?` routes to `enterEmail`; valid email requests reset through `AuthRepository.requestPasswordReset`; `resetPasswordConfirm` can complete password reset only when opened with a transient reset token, sends `{ token, newPassword }`, clears local session, and returns to email sign-in. Production app-link setup remains deferred |
| Finish sign-up | Validates required fields, date picker birthday, 15-character password policy, and confirm password match before calling backend registration and routing into the selected role's next setup step |
| Social auth rows on sign-up | Google signup is enabled only when the Google provider is configured and runs through explicit patient/professional role selection before backend account creation. Facebook and Apple remain disabled. Sign-in Google remains separate for existing/linked accounts |
| Dashboard shell | Backend session role resolves a four-tab shell. Patient: Home/Find Care/Appointments/Messages. Professional: Home/Schedule/Appointments/Messages. Notifications and Account/Profile open from header actions; unknown roles fail closed; no drawer is active |
| Find Care discovery | Patient Home and the persistent Find Care tab use `RouteName.search` / `SearchShellPage`. One `ProfileRepository.publicProfessionals()` call loads the backend verified directory; local filtering supports display name, category, and specialty only. Loading, backend-empty, filtered-empty, initial failure, retry, refresh, and refresh-failure-with-preserved-data are distinct. Cards show only supported backend identity fields, and selection passes the exact backend id to `specialistDetails`. No seeded/local professional fallback or duplicate availability/request sheet remains in Search |
| Canonical professional detail | `specialistDetails` requires the exact backend `ProfessionalProfile.id` and calls `GET /professionals/:id`. It renders only approved public fields, omits missing biography, and fails closed for missing/malformed/unavailable IDs without directory scans, `SearchLocalStore`, or seeded identity data |
| Real appointment request handoff | Detail calls the public requestable-times endpoint and renders backend UTC intervals in the professional IANA timezone. A structured 24-hour secure booking intent survives authentication and patient setup, binds to account identity, reuses one idempotency key for safe retry, revalidates the selected time, and sends `POST /appointments` as a patient. Success remains backend `REQUESTED`, not confirmed |
| Role-aware appointment experience | `appointments` loads only the authenticated account's backend-owned list, groups it deterministically, and opens `appointmentDetail` by exact appointment ID. Patient and professional action visibility is centralized by role/status/time, every mutation waits for backend confirmation and reloads authority, 409 and uncertain outcomes never apply a false local status, and reschedule uses backend requestable times at the fixed 30-minute Phase 1 duration |
| Professional Schedule | The professional Schedule reads and atomically replaces `/availability/me` using backend `availabilityWindows`/`isActive` fields, weekday `0..6`, and valid IANA timezones. Add/edit/remove operations are serialized and reconciled with a backend reload. Patients fail closed, and recurring windows are never presented as guaranteed requestable slots |
| Paid consultation experience | Public detail displays the exact backend NGN consultation price and fails closed when not bookable. Appointment Detail renders backend payment state, serializes hosted Paystack initialization with one persisted account/appointment idempotency key, opens only the exact HTTPS Paystack checkout host, and refreshes backend authority on app resume. Professional Account exposes price, held/eligible/available/processing/paid balances, masked payout profile, bank resolution/confirmation, ledger, and payout history. No card data, recipient code, or local payment success is stored or shown |
| Home inner tabs | `Feed`, `Messages`, and `Articles` all render real content; Messages preview hands off to the dedicated `messages` route |
| Messaging flow | Primary Messages destination shows an honest appointment-conversation empty state; seeded social conversations and arbitrary new-chat behavior are not presented as production data |
| Notifications screen | Header bell opens the authenticated backend inbox with loading, empty, error, retained refresh, pagination, unread styling, read-one/read-all, and no seeded fallback. The account area and inbox settings action open backend notification preferences |
| Notification routing | FCM taps carry an opaque notification ID. Flutter retains cold-start taps until navigation and the authenticated session are ready, fetches that owner-scoped notification, marks it read, then resolves only appointment/consultation, conversation, professional verification, professional finance, or account-security route codes. Recoverable session/network/server failures preserve the pending tap for retry; unknown/stale/foreign items fail closed to the inbox. Physical Android staging proof opened the exact appointment conversation from a terminated-app message notification |
| Notification categories | Backend categories are Appointments, Messages, Consultations, Payments, Earnings and payouts, Account and security, and Professional verification. The in-app inbox remains durable while push/email preferences are changed per category |
| Legacy messaging cleanup | `Chat_2.dart` and `Message.dart` are removed; `RouteName.message` is a fail-closed compatibility alias and cannot expose a seeded conversation |
| Readings flow | `readings` now routes into `manageReadings` via the `Add new Readings` tile, and `Done` returns to `readings` |
| Readings export state | `Download Readings` is intentionally deferred and labeled as such until add-reading/device onboarding exists |
| Guided readings lane | Selecting `Blood Sugar` in `manageReadings` now continues into `addDevice`, then into the dedicated `bloodSug` destination shell |
| Blood sugar entry | `bloodSug` now has a real local form: required numeric reading, required context selection, optional note, and a saved-state summary card |
| Readings dashboard sync | Saved blood sugar entries now update the `Blood Sugar` card on `readings` and show a latest-entry summary when the user returns |
| Health record slice | `healthRecord` is a real local health-file summary route with vitals cards and latest blood sugar state from the readings store. The lane intentionally stops here before backend health history, report export, and synced-vital support |
| Blood sugar history/trend | The `bloodSug` lane now keeps short local history and shows a simple up/down trend summary once at least two readings exist |
| Blood sugar history cleanup | Saved blood sugar rows can now be deleted, and the latest-entry/trend state recalculates from the remaining local history |
| Appointments slice | `appointments` now shows real local upcoming/recent appointment sections and a working `Book appointment` handoff into `bookAppointment` |
| Booking form | `bookAppointment` keeps validation and route availability, but local booking confirmation/success has been removed. The form can review typed details only and shows `Backend request not sent`; real appointment request wiring remains deferred |
| Booking draft lifecycle | Appointment drafts can now be locally confirmed or cancelled instead of sitting as inert summaries |
| Emergency slice | `emergency` now shows real local status/update content and hands off into a working `distressCall` form |
| Emergency dispatch seam | Distress updates can now be queued or cleared locally; this is the explicit seam to replace with real backend dispatch/escalation later |
| Articles reader | `articles` now supports a real local list/detail reader flow on the same route instead of only a static preview shell |
| Article saved/read state | Opening an article now marks it read locally, and users can save an article locally from the detail view; later account/content sync should replace that local store |
| Saved articles slice | `savedArticles` now shows an honest empty state, routes back to the article reader, lists locally saved articles from the shared article store, opens saved article details, and removes saved articles locally. Account sync, drafts, and creator/content APIs remain deferred |
| Saved/content-library scope boundary | The saved/content lane intentionally stops after the local `savedArticles` route. `subscribers`, `article-story`, drafts, creator publishing, author/publication analytics, comments, account sync, and content APIs remain deferred until creator/content backend rules exist |
| Published articles slice | `publishedArticles` is now a registered route based on blueprint `/published-articles`, opened from `managePortfolio -> Articles`. It shows `For you` / `Request` / `Drafts`, lists locally known portfolio articles, opens in-page article detail, and keeps edit/publish/delete/comments/analytics/subscriber/draft behavior locked or deferred |
| Case studies slice | `caseStudies` now has a real local case-study library with `All` / `Case studies` / `Best` filters, in-page detail reading, and local read state. Content APIs, verified clinical review, author/publication records, comments, sharing, account sync, and moderation remain deferred |
| Case studies scope boundary | The case-studies lane intentionally stops after local list/filter/detail/read-state behavior. Content APIs, verified clinical review, author/publication records, comments, sharing, saved-to-account sync, and moderation remain deferred until content/backend rules exist |
| Articles scope boundary | Articles intentionally stop here for now; deeper content/account sync is deferred while we move to the next blueprint-backed route |
| Communities slice | `circles` now shows real local community content, routes into `discoverCommunities`, syncs joined communities back into `My communities`, opens a blueprint-backed local `communityProfile`, and supports a real local `createCommunity` flow that hands off into an owner profile note; the communities lane intentionally stops here before invitation acceptance and moderation workflows |
| Q&A slice | The Post tab now hosts a real local Q&A feed with seeded questions, local follow toggles, and a working `qAAsk` form that validates question-style prompts and returns saved local questions back into the feed; the blueprint-backed answer lane now works locally through `qAAnswerRequests` -> `qAAnswerForYou` -> `commentAnswer`, with saved local answers feeding back into answer drafts. The Q&A lane intentionally stops here before the mixed `q-a-post` composer/distribution flow |
| Account slice | The dashboard drawer `Profile` row now routes into a real local `account` screen with account rows and working `deleteAccount` plus `settings` handoffs. `Settings & Profile` now supports local validation and local save for core profile fields, while delete/deactivate remains an explicit local seam until real auth-change and destructive account APIs exist. The account lane intentionally stops here before public profile, scheduling, and auth-security flows |
| Account current read | Account can read `AccountRepository.currentAccount` for safe display-only identity fields. Backend account email/status can replace local display when available; failures show a safe message and keep local display. Profile editing, delete/deactivate, phone/email drafts, password, and security mutations remain local/deferred |
| Email verification request/confirm | The current email review screen can call `AccountRepository.requestEmailVerification` for the signed-in account. `emailVerificationConfirm` can complete verification only when opened with a transient verification token, then attempts current-account refresh if a session exists. Production app-link setup remains deferred |
| Auth/session/account regression | The current backend-ready auth/account frontend boundary has a focused regression pass covering auth infrastructure, email sign-in, email sign-up completion, session restore, logout/session clear, password reset request boundary, current account read, and email verification request. Remaining auth/account gaps stay deferred instead of being faked |
| Next integration lane | After the auth/session/account regression pass, the next selected lane is workflow guardrail restoration. `WORKING_AGREEMENT.md`, `TASK_TEMPLATE.md`, and `DEFINITION_OF_DONE.md` are referenced by authoritative docs but missing from this checkout, so restore those before more auth/account wiring or another backend contract group |
| Workflow guardrails | `WORKING_AGREEMENT.md`, `TASK_TEMPLATE.md`, and `DEFINITION_OF_DONE.md` are restored and match the current one-slice, honest-backend-ready workflow. Future work should read those docs before implementation |
| Next frontend integration step | Do not add more runtime backend wiring immediately. The next selected slice is a frontend/backend integration checkpoint that summarizes what auth/session/account wiring is complete and what backend/deep-link contracts are needed before password reset confirmation, email verification confirmation, or another contract group is wired |
| Frontend/backend checkpoint | `FRONTEND_BACKEND_INTEGRATION_CHECKPOINT.md` records the completed auth/session/account frontend wiring, remaining blockers, and backend/deep-link questions needed before more runtime wiring |
| Reset/verification token wiring | `PASSWORD_RESET_EMAIL_VERIFICATION_CONTRACT.md` defines the frontend boundary for reset and verification confirmation. Runtime Flutter token-confirm routes are wired behind `resetPasswordConfirm` and `emailVerificationConfirm`; tokens are passed as transient route arguments and are not persisted or logged. Platform deep-link production setup remains out of scope |
| Completed backend surface wiring map | `BACKEND_COMPLETED_SURFACE_WIRING_MAP.md` records the backend-completed surfaces that remain to be consumed by the Flutter app. The safe order is auth/account staging checkpoint first, then professional/profile/verification, then public professionals/availability, then appointment lifecycle. Phone/OTP, MFA, payments, notifications, reviews, calls, calendar sync, medical notes, prescriptions, admin dashboard behavior, public staging access, and production readiness remain out of scope |
| Auth/account staging checkpoint | `AUTH_ACCOUNT_STAGING_CHECKPOINT.md` records that the developer-private proxy reached staging through `http://127.0.0.1:8080`; `/health` returned `ok`, `/health/ready` returned database/migrations/email `ok`, and readiness reported `googleAuth: disabled` plus `verificationStorage: disabled`. Flutter config key remains `CARENET_API_BASE_URL`. No runtime Flutter code changed |
| App identifiers | Android namespace/application ID and iOS bundle ID now use `com.carenet.app`; iOS test bundle uses `com.carenet.app.RunnerTests`. `GOOGLE_SIGN_IN_FOUNDATION.md` records the remaining OAuth/client/fingerprint/provider prerequisites before Google UI can be enabled |
| Google OAuth prerequisites | `GOOGLE_SIGN_IN_SETUP_PREREQUISITES.md` records Android package `com.carenet.app`, iOS bundle `com.carenet.app`, local debug SHA-1/SHA-256 fingerprints, release fingerprint blocker, current staging `googleAuth: disabled`, and the need to configure backend `GOOGLE_OAUTH_CLIENT_ID` before Flutter Google UI wiring |
| Google sign-in/signup wiring | `google_sign_in` is added behind `GoogleIdTokenProvider`; sign-in phone/email Google rows are enabled only when `GOOGLE_SIGN_IN_SERVER_CLIENT_ID` is configured, then call `AuthRepository.googleSignIn` without a role for existing/linked accounts. Sign-up Google uses the same real provider token but requires explicit `PATIENT`/`PROFESSIONAL` role selection before sending the role to backend auth and routing into patient/professional setup. Google unlink, iOS proof, release signing, production OAuth, phone/OTP, MFA, and broader profile trust rules remain deferred |
| Google account linking | Account now exposes a constrained `Google account` entry below `Authentication`. When `GoogleIdTokenProvider` is configured, it obtains a real Google ID token and calls `AuthRepository.googleLink`; missing config, provider failure, backend validation, and unauthorized failures show safe copy. Account/session email, role, and status remain backend-owned and are not locally mutated after linking. Google sign-up role selection, unlinking, cross-email/recovery linking, recent re-auth, production OAuth, release signing, iOS proof, phone/OTP, MFA, profile creation, admin verification, payments, notifications, reviews, calls, calendar sync, notes, prescriptions, staging data, and production claims remain deferred |
| Google account linking regression | `GOOGLE_ACCOUNT_LINKING_REGRESSION.md` records focused proof for Account placement, disabled missing-config behavior, configured provider token handoff to `AuthRepository.googleLink`, provider failure without backend call, backend validation/unauthorized safe copy, no raw token/error exposure, and no local account/session mutation |
| Next backend-completed surface after Google linking | `NEXT_SURFACE_AFTER_GOOGLE_LINKING_REGRESSION_DECISION.md` selects an admin verification review boundary decision as the next lane. Runtime admin UI is not selected yet; 52.94 must decide whether admin queue, signed-read, and approve/reject belong in this Flutter app, a separate admin dashboard, or another frontend surface |
| Admin verification review boundary | `ADMIN_VERIFICATION_REVIEW_SURFACE_BOUNDARY.md` accepts a separate admin dashboard/web console for admin verification queue, signed-read, and approve/reject behavior. This patient/professional Flutter app should not add admin routes, hidden admin mode, signed-read handling, approve/reject controls, or admin document previews |
| Final backend-completed mobile surface checkpoint | `FINAL_BACKEND_COMPLETED_MOBILE_SURFACE_CHECKPOINT.md` and the updated `BACKEND_COMPLETED_SURFACE_WIRING_MAP.md` found no remaining backend-completed surface that clearly belongs in this patient/professional mobile app and is still waiting for first-pass runtime wiring. Next mobile-app work should plan stabilization/regression for the already-wired backend milestone |
| Mobile backend integration stabilization plan | `MOBILE_BACKEND_INTEGRATION_STABILIZATION_PLAN.md` defines grouped regression suites, focused analyze/docs checks, manual smoke checklist, known blockers, and the next execution slice for the already-wired backend mobile milestone. The next slice should execute the regression pass and record evidence before new product surfaces are added |
| Mobile backend integration regression pass | `MOBILE_BACKEND_INTEGRATION_REGRESSION_PASS.md` records green grouped regression evidence for auth/session/account, profile/verification, discovery/booking, and scheduling lifecycle after one password-recovery widget-test harness fixture fix. Focused analyze reports no issues. This is not a production, public staging, store, admin dashboard, or deferred-module completion claim |
| Mobile milestone handoff/staging boundary | `MOBILE_MILESTONE_HANDOFF_STAGING_BOUNDARY.md` selects a frontend milestone handoff package as the next lane. Staging seed-data/smoke setup, release-signing/app-link readiness, admin dashboard, and deferred product modules remain separate future lanes |
| Mobile backend milestone handoff package | `MOBILE_BACKEND_MILESTONE_HANDOFF_PACKAGE.md` is the current presentation package for the regression-passed frontend/backend mobile milestone. It lists wired surfaces, regression evidence, staging smoke inputs, admin/release/deferred boundaries, and safe wording. Next work should define staging seed data and smoke execution |
| Staging seed data and smoke plan | `STAGING_SEED_DATA_SMOKE_EXECUTION_PLAN.md` defines the staging environment, accounts, verified professional data, availability, appointment lifecycle data, verification upload access, cleanup/reset rules, build commands, manual smoke checklist, evidence requirements, and blocker rules needed before public staging/demo proof can be claimed |
| Staging phone install checkpoint | `STAGING_MOBILE_GATEWAY_PHONE_INSTALL_CHECKPOINT.md` records task 53.2 progress: the Android debug APK builds against the public staging API Gateway URL, installs on the connected Android phone, launches under `com.carenet.app`, and required an Android `MainActivity` package fix. Staging-only patient/professional accounts, verified professional seed, public availability, and backend appointment lifecycle proof now exist. Patient phone sign-in, Account current-account display, Settings/Profile patient profile read, Search public professional listing, public availability display, a real phone UI appointment request, and Notifications -> Appointments own-list rendering passed on the phone with backend `REQUESTED` rows for `cmrnd9w31000701s6tse0lyf1`. Professional phone sign-in also passed; Account showed `PROFESSIONAL account - active`, Appointments exposed role-aware Accept/Decline/Reschedule actions, accept/decline/reschedule returned backend status updates, and terminal recent rows did not expose duplicate completion. Professional Account now exposes Manage Profile and Verification documents, and both routes were proved on the phone. Public availability parsing, UTC request-time generation, Android backup/restore auth-storage issues, the protected `appointments` response envelope, and immediate post-login secure-session writes found during phone smoke are fixed locally and verified. Full real-device phone UI smoke remains open until separate appointment-detail, successful verification upload after staging upload-init HTTP 500 is fixed, optional fresh completion, and cleanup/reset proof are completed or explicitly deferred |
| Profile/public professional contract | `PROFILE_PUBLIC_PROFESSIONAL_CONTRACT.md` defines the backend-backed profile lane. `ProfileRepository` now covers patient self profile, professional self profile, and public verified professional listing. Manage Profile reads the current professional profile for allowed display fields only, and Add Description can update existing professional profile `bio` only. Profile creation, name/category/specialty editing, patient profile UI, public listing UI, verification upload, admin dashboard, availability, appointment lifecycle, payments, notifications, reviews, calls, calendar sync, notes, prescriptions, and public professional detail remain deferred |
| Profile repository boundary | `ProfileApiClient` and `ProfileRepository` now cover `GET/PUT /patients/me`, `GET/PUT /professionals/me`, and public `GET /professionals` behind safe models/entities and focused tests. Protected calls require a stored session and bearer headers; `404` self-profile reads become empty-profile states; public listing sends no auth header. Manage Profile now uses the professional self-read path only |
| Profile bio update | `addDescription` now reads an existing professional profile, preserves `displayName`, `category`, and `specialty`, and updates only `bio` through `ProfileRepository.updateProfessionalMe`. Missing professional profile disables save with an honest empty-profile state. Profile creation, name/category/specialty editing, website, address, patient profile, public listing, verification, availability, appointments, payments, reviews, calls, calendar sync, notes, and prescriptions remain deferred |
| Search public professional listing | `SearchShellPage` reads public verified professionals through `ProfileRepository.publicProfessionals` and does not fall back to seeded local specialists when the backend fails. It maps only public display/category/specialty/bio fields, shows real loading/error/empty states, and passes the exact backend profile ID to canonical Specialist Details. Search itself owns no availability or booking behavior |
| Scheduling/appointment next lane | `SCHEDULING_AVAILABILITY_APPOINTMENT_LANE_DECISION.md` selects scheduling as the next backend-integration lane, but requires a contract slice before runtime wiring. Availability and appointment repository/entities/screen boundaries must be defined before booking, business-hours, own-list, or lifecycle actions are wired. Public detail invention, local fallback booking, payments, notifications, reviews, calls, calendar sync, admin override, notes, and prescriptions remain deferred |
| Scheduling frontend contract | `SCHEDULING_AVAILABILITY_APPOINTMENT_CONTRACT.md` defines accepted availability and appointment routes, allowed payloads, screen mapping, safe errors, and no-local-fallback rules. The next implementation is repository/API boundary only: entities, models, client, repository, DI, and tests; no UI screen wiring yet |
| Scheduling repository boundary | `SchedulingApiClient` and `SchedulingRepository` now cover public availability, professional own availability read/replace, appointment request/list, and appointment accept/decline/cancel/reschedule/complete behind typed entities/models and focused tests. Public availability sends no auth header; protected calls require stored session bearer auth. No UI screens are wired yet, so booking, Specialist Details availability, selected dates persistence, and appointment list/lifecycle screens remain deferred |
| Public requestable times | Specialist Details calls `SchedulingRepository.publicRequestableTimes` for the exact backend professional profile ID and an initial half-open 14-day UTC range. Explicit `Load later times` requests contiguous bounded pages, validates the echoed range and policy, deduplicates UTC starts, and preserves prior results on later-page failure. Flutter renders backend intervals in the professional IANA timezone and does not generate times from recurring windows, weekdays, lead time, horizon, or conflicts |
| Appointment request UI path | `specialistDetails` is the sole active patient request path. The old free-text `bookAppointment` route resolves to Find Care and cannot claim local success. A ready patient explicitly confirms one backend-returned time; success is shown as backend `REQUESTED`, not booked or confirmed |
| Local booking success removal | `bookAppointment`, `publicProfile`, and `findMentor` route constants resolve to canonical Find Care. Retained legacy source remains recoverable but cannot create the appearance of a real booking through normal or direct route resolution |
| Concrete appointment request UX | Specialist Details loads one backend profile and backend-generated requestable times, resumes a secure 24-hour account-bound intent through authentication and patient setup, and calls `requestAppointment` with a persistent idempotency key |
| Appointment request time options | `AppointmentRequestTimeOptions` remains historical/deferred source and is not used by canonical detail. Backend `requestable-times` owns fixed duration, cadence, timezone conversion, lead time, horizon, availability, and accepted-conflict rules |
| Appointment request handoff | Find Care passes only the exact backend professional profile ID to Specialist Details. Detail, time loading, and submission fail closed without seeded profiles, local availability, or draft-booking fallback |
| Own appointment list read | `appointments` now reads `SchedulingRepository.ownAppointments` and renders backend appointment statuses as upcoming/recent cards with safe loading, empty, and error states. Seeded local appointment cards are no longer used as fallback. Accept/decline/cancel/reschedule/complete UI remains deferred |
| Scheduling next UI lane | `SCHEDULING_NEXT_UI_LANE_DECISION.md` selects patient appointment cancellation as the next narrow runtime lane after request/list visibility. Professional availability management, professional accept/decline, reschedule, complete, payments, notifications, calls, calendar sync, notes, and prescriptions remain deferred |
| Patient appointment cancellation | `appointments` now exposes `Cancel appointment` only for eligible upcoming `REQUESTED`/`ACCEPTED` backend cards, calls `SchedulingRepository.cancelAppointment`, and updates the visible card from the backend response. Terminal/recent cards do not expose cancellation; failures show safe errors without local fallback |
| Scheduling regression decision | `SCHEDULING_REGRESSION_DECISION.md` selects a patient-path regression checkpoint before professional availability management or professional lifecycle UI. The next slice should prove Search listing/availability/request and Appointments own-list/cancel behavior before expanding the scheduling surface |
| Scheduling patient-path regression | `SCHEDULING_PATIENT_PATH_REGRESSION.md` records focused proof for the backend-backed patient scheduling path: Search public listing/availability/request, generated time options, Appointments own-list status rendering, requested/accepted cancellation, terminal/recent hidden actions, and safe failure states |
| Professional availability boundary | `PROFESSIONAL_AVAILABILITY_UI_BOUNDARY_DECISION.md` selects `selectedDates` as the professional own-availability management surface. `manageProfile` remains the entry point/summary surface; availability persistence is separate from profile mutation and appointment lifecycle UI |
| Professional availability management | `selectedDates` now reads backend own availability through `SchedulingRepository.ownAvailability`, renders backend empty/error/window states, and saves via `replaceOwnAvailability` while preserving other existing backend weekdays. Success appears only after repository success; raw backend errors and local saved-draft claims are not shown |
| Professional appointment lifecycle boundary | `PROFESSIONAL_APPOINTMENT_LIFECYCLE_UI_BOUNDARY_DECISION.md` selects role-aware professional accept/decline as the next narrow lifecycle UI. The Appointments screen must read authenticated session role before showing professional actions; reschedule/complete remain separate decisions |
| Professional appointment accept/decline | `appointments` now reads authenticated session role via `SessionStore` before showing role-specific actions. Professional users see `Accept`/`Decline` only on eligible upcoming `REQUESTED` appointments; patient users keep cancellation and do not see professional actions. Success replaces visible status from backend response; failures use safe errors |
| Professional appointment lifecycle regression | `PROFESSIONAL_APPOINTMENT_LIFECYCLE_REGRESSION.md` records focused proof for patient cancel, professional accept/decline, role separation, state separation, safe failure behavior, and the absence of reschedule/complete/payment/calendar/notes UI |
| Appointment reschedule/completion boundary | `APPOINTMENT_RESCHEDULE_COMPLETION_BOUNDARY_DECISION.md` selects professional completion before reschedule. Completion should be professional-only, accepted-only, after scheduled end time, and should send no trusted request body; reschedule remains deferred until availability/time-selection UX is decided |
| Professional appointment completion | `appointments` now shows `Complete` only to professional sessions for accepted backend appointments whose scheduled end time has passed. The action calls `SchedulingRepository.completeAppointment`, replaces visible status from the backend response, and keeps safe error handling. Reschedule, patient completion, payments, notifications, calendar sync, reviews, notes, prescriptions, admin override, no-show/disputes, and calls remain deferred |
| Appointment completion regression | `APPOINTMENT_COMPLETION_REGRESSION.md` records focused proof for exact scheduled-end completion, patient denial, cancelled/declined/completed denial, safe failure behavior, and absence of reschedule/payment/calendar/review/notes/prescription controls on completion-eligible cards |
| Post-completion scheduling lane | `POST_COMPLETION_SCHEDULING_LANE_DECISION.md` selects a broader scheduling core regression checkpoint before any reschedule UX/runtime work. Reschedule remains deferred until actor rules, eligible statuses, time/duration selection, availability re-checks, conflict handling, audit, notification, calendar, and payment boundaries are decided |
| Scheduling core regression checkpoint | `SCHEDULING_CORE_REGRESSION_CHECKPOINT.md` records focused proof across Search public listing/availability/request, Appointments own-list/cancel/accept/decline/complete, selectedDates availability management, scheduling repository payload boundaries, safe error/no-fallback behavior, and absence of reschedule/payment/notification/calendar/review/notes/prescription/call/admin UI |
| Post-regression scheduling lane | `POST_REGRESSION_SCHEDULING_LANE_DECISION.md` selects a dedicated appointment reschedule UX/product boundary decision before any runtime reschedule wiring. Reschedule remains blocked until actor, status, time-selection, duration, conflict, payload, success/error, and deferred notification/payment/calendar/review/notes/call/admin boundaries are defined |
| Appointment reschedule UX boundary | `APPOINTMENT_RESCHEDULE_UX_BOUNDARY_DECISION.md` allows a constrained next runtime slice for patient/professional reschedule of upcoming `REQUESTED`/`ACCEPTED` appointments using existing public availability and generated request options. Success must replace the card from backend response, expected status returns to `REQUESTED`, and payments, notifications, calendar sync, reviews, calls, admin override, notes, prescriptions, medical records, free-text datetime entry, and reschedule reasons remain deferred |
| Appointment reschedule wiring | `appointments` now exposes `Reschedule` only for patient/professional sessions on upcoming `REQUESTED`/`ACCEPTED` backend appointment cards. It loads public availability for the appointment professional, generates bounded request options, submits `requestedStartAt` and `durationMinutes` through `SchedulingRepository.rescheduleAppointment`, replaces visible status from the backend response, and keeps safe errors/no raw backend messages. Non-patient/non-professional roles, recent cards, and terminal states do not expose reschedule |
| Appointment reschedule regression | `APPOINTMENT_RESCHEDULE_REGRESSION.md` records focused proof for patient/professional reschedule success, backend `REQUESTED` response handling, non-patient/non-professional hiding, recent/terminal hiding, empty generated-option handling, safe failure messages, narrow payload behavior, and continued absence of payments, notifications, calendar, reviews, calls, admin, notes, and prescriptions UI |
| Scheduling smoke checkpoint decision | `SCHEDULING_CORE_PAUSE_OR_SMOKE_DECISION.md` pauses scheduling feature expansion and selects a staging smoke checkpoint next. The current local regression evidence is strong enough for the scoped core, but app-build/staging proof is still missing before claiming the scheduling core is externally proven |
| Scheduling staging smoke checkpoint | `SCHEDULING_CORE_STAGING_SMOKE_CHECKPOINT.md` records that the developer-private staging proxy reaches `/health` and `/health/ready`, database/migrations/email/googleAuth report `ok`, verification storage remains disabled, public professionals endpoint is reachable but empty, unauthenticated protected scheduling routes return `401`, and a staging-configured debug APK builds. End-to-end appointment smoke remains blocked by missing staging patient/professional/verified-professional/availability/appointment data |
| Scheduling smoke data decision | `SCHEDULING_SMOKE_DATA_OR_NEXT_SURFACE_DECISION.md` rejects ad hoc Flutter-created staging scheduling users/data. Full scheduling smoke remains blocked until deliberate backend/staging test data exists: patient/professional accounts, a verified public professional, availability windows, appointment path, and cleanup/reset guidance |
| Next backend-completed surface | `NEXT_BACKEND_COMPLETED_FLUTTER_SURFACE_DECISION.md` selects patient self profile as the next Flutter surface because `ProfileRepository.patientMe/updatePatientMe` already exist and do not depend on scheduling seed data or verification storage. Runtime wiring is blocked until Settings/Profile maps backend `name`, `age`, and `location` separately from username, email, auth/security, public profile, and destructive account behavior |
| Patient profile settings mapping | `PATIENT_PROFILE_SETTINGS_MAPPING_DECISION.md` maps Settings/Profile to patient `name`, `age`, and `location` only. The next runtime slice should read `ProfileRepository.patientMe`, show safe loading/error/empty-profile states, display backend name and read-only age/location when available, and avoid `updatePatientMe` until a separate mutation slice |
| Patient profile read wiring | Settings/Profile now reads `ProfileRepository.patientMe`, shows safe loading/error/empty-profile states, displays backend patient `name`, `age`, and `location` read-only when available, and keeps local save behavior local. It does not call `updatePatientMe` or create profile data |
| Patient profile read regression | `PATIENT_PROFILE_READ_REGRESSION.md` records focused proof for patient profile read success, empty-profile, safe failure, local save preservation, and absence of `updatePatientMe` mutation |
| Patient profile update boundary | `PATIENT_PROFILE_UPDATE_BOUNDARY_DECISION.md` selects a constrained next runtime slice: Settings/Profile may update backend patient `name` only from combined first/last name. Age/location mutation, username/email/bio persistence, auth/security, verification, scheduling, and destructive account actions remain deferred |
| Patient profile name update | Settings/Profile now calls `ProfileRepository.updatePatientMe` with combined first/last name only, shows safe loading/error behavior, preserves local username/email/bio save behavior, and blocks false success on backend name-save failure. Age/location mutation and account/security fields remain deferred |
| Patient profile name update regression | `PATIENT_PROFILE_NAME_UPDATE_REGRESSION.md` records focused proof for name-only payload, no age/location mutation, safe failure/no false success, local username/email/bio preservation, and deferred-work accuracy |
| Next backend-completed surface after patient profile | `NEXT_SURFACE_AFTER_PATIENT_PROFILE_DECISION.md` selects Specialist Details public professional/availability wiring as the next narrow Flutter lane. The next runtime slice should use existing public professional and public availability repository surfaces without inventing a public detail endpoint, verification/admin behavior, payments, reviews, calls, calendar sync, notes, prescriptions, staging data, or production claims |
| Specialist Details public availability | Historical implementation used the public directory, recurring availability, and Flutter-generated request options. APP-P1-005 supersedes that path with one public detail request plus backend-generated requestable times; the old generator and local compatibility path are not active |
| Specialist Details public availability regression | `SPECIALIST_DETAILS_PUBLIC_AVAILABILITY_REGRESSION.md` records focused proof for backend id resolution, Search handoff, dashboard local compatibility, no local slot fallback, generated request payload, safe request/availability failures, and absence of public-detail endpoint invention or deferred feature leakage |
| Next surface after Specialist Details | `NEXT_SURFACE_AFTER_SPECIALIST_DETAILS_DECISION.md` selects Find Mentor public professional replacement as the next narrow Flutter lane. The next runtime slice should replace local mentor cards with public verified professionals where a repository is available and pass backend ids into Specialist Details without local slot fallback, verification/admin behavior, payments, reviews, calls, calendar sync, staging data, or production claims |
| Find Mentor compatibility | `RouteName.findMentor` now resolves to canonical `SearchShellPage`; normal route resolution cannot open the legacy mentor marketplace. `FindMentorShellPage` remains only as recoverable deferred source pending later dead-code cleanup |
| Find Mentor public professionals regression | `FIND_MENTOR_PUBLIC_PROFESSIONALS_REGRESSION.md` records focused proof for loading, empty, success, category filtering, backend id handoff, safe failure, no local fallback/direct fake booking, dashboard local compatibility, Specialist Details compatibility, and deferred-work accuracy |
| Next surface after Find Mentor | `NEXT_SURFACE_AFTER_FIND_MENTOR_DECISION.md` selects professional verification upload/list as the next backend-completed Flutter lane. The next slice must define the private-document/file-picker/upload/list/status boundary before runtime implementation |
| Professional verification repository boundary | `PROFESSIONAL_VERIFICATION_UPLOAD_LIST_BOUNDARY.md` accepts Manage Profile as the professional-owned entry point, and `VerificationRepository` now covers owner document list, upload-init, internal signed upload PUT, and upload-complete behind safe entities and focused tests. Runtime screen wiring, file picker UI, visible upload flow, admin review, private previews/downloads, public document access, staging data, and production claims remain deferred |
| Professional verification documents shell | Manage Profile now has a `Verification` entry that opens `professionalVerificationDocuments`. The shell reads owner verification documents through `VerificationRepository.documents`, shows loading/empty/safe-error states, displays safe status metadata only, and keeps upload locked until the file-picker/upload UX boundary is decided |
| Professional verification upload picker boundary | `PROFESSIONAL_VERIFICATION_UPLOAD_PICKER_BOUNDARY.md` selects a PDF-capable picker path for the next runtime upload slice. Do not use the existing `image_picker` dependency for verification upload because PDF support is required. Runtime upload and package changes remain queued for 52.79 |
| Professional verification upload flow | `professionalVerificationDocuments` supports one controlled upload flow with `file_picker`, document type selection, PDF/JPEG/PNG validation, a 10 MB app-side size guard, off-UI-isolate SHA-256, bounded transfer progress, active cancellation, integrity completion, safe states, and owner document reload. Previews/downloads, admin review, rejection reasons, malware scanning, public exposure, and production claims remain deferred |
| Professional verification upload regression | `PROFESSIONAL_VERIFICATION_UPLOAD_REGRESSION.md` records focused proof for owner list success/empty/error, upload success with reload, picker cancellation, invalid type, 10 MB guard, safe backend failure, dependency presence, and private-data non-exposure |
| Next surface after verification regression | `NEXT_SURFACE_AFTER_VERIFICATION_UPLOAD_REGRESSION_DECISION.md` selects professional basic profile field editing as the next backend-completed Flutter surface, with a boundary decision before runtime `displayName`/`category`/`specialty` wiring. Website/address, verification expansion, admin review, scheduling staging data, payments, reviews, calls, calendar sync, notes, prescriptions, staging, and production claims remain deferred |
| Professional basic profile edit boundary | `PROFESSIONAL_BASIC_PROFILE_EDIT_BOUNDARY.md` selects `editYourName` as a display-name-only runtime update. The next implementation must read an existing professional profile, preserve category/specialty/bio, block empty-profile creation, and keep website/address/account/verification/availability/appointment/payment/review/call/calendar/note/prescription data out |
| Professional display name update | `editYourName` now reads an existing professional profile, pre-fills backend `displayName`, saves only a changed `displayName` through `ProfileRepository.updateProfessionalMe`, preserves existing category/specialty/bio, blocks empty-profile creation, and shows safe validation/error/success states. Category/specialty editing, profile creation, website/address persistence, verification, availability, appointments, account identity, payments, reviews, calls, calendar sync, notes, prescriptions, staging, and production claims remain deferred |
| Professional display name update regression | `PROFESSIONAL_DISPLAY_NAME_UPDATE_REGRESSION.md` proves the current display-name-only profile update boundary with focused tests, analyzer, targeted preservation checks, empty-profile blocking, safe failure handling, and deferred-work accuracy. No broader profile editing is selected until the next decision slice |
| Next surface after display-name regression | `NEXT_SURFACE_AFTER_DISPLAY_NAME_REGRESSION_DECISION.md` selects professional category/specialty editing as the next backend-completed Flutter surface, with a boundary decision before runtime wiring. Profile creation, website/address persistence, verification/admin, scheduling staging data, account identity, payments, reviews, calls, calendar sync, notes, prescriptions, staging, and production claims remain deferred |
| Professional category/specialty edit boundary | `PROFESSIONAL_CATEGORY_SPECIALTY_EDIT_BOUNDARY.md` selects a new constrained category/specialty edit surface. The next implementation must require category, allow optional/cleared specialty as null, preserve existing displayName/bio, block profile creation, and keep website/address/account/verification/availability/appointment/payment/review/call/calendar/note/prescription data out |
| Professional category/specialty update | Manage Profile Basic now exposes `Edit category`, opening `editProfessionalDetails`. The route reads the existing professional profile, prefills category/specialty, requires category, sends cleared specialty as `null`, preserves existing displayName/bio in `ProfileRepository.updateProfessionalMe`, blocks empty-profile creation, and shows safe loading/error/success states. Website/address, account identity, verification, availability, appointments, payments, reviews, calls, calendar sync, notes, prescriptions, staging data, and production claims remain deferred |
| Professional category/specialty update regression | `PROFESSIONAL_CATEGORY_SPECIALTY_UPDATE_REGRESSION.md` records focused proof for entry separation from display-name edit, backend category/specialty prefill, category-required validation, displayName/bio preservation, specialty clearing as `null`, empty-profile blocking, safe backend failure, and absence of broader profile/module behavior |
| Next surface after category/specialty regression | `NEXT_SURFACE_AFTER_CATEGORY_SPECIALTY_REGRESSION_DECISION.md` selects protected Google account linking as the next backend-completed Flutter surface. The next slice must define the UI boundary before runtime wiring; Google sign-up role selection, unlinking, cross-email/recovery linking, recent re-auth, phone/OTP, MFA, production OAuth, release signing, iOS proof, profile creation, admin dashboard, payments, reviews, calls, calendar sync, notes, prescriptions, staging data, and production claims remain deferred |
| Google account linking UI boundary | `GOOGLE_ACCOUNT_LINKING_UI_BOUNDARY.md` accepts Account as the host surface for protected Google linking: add a Google account entry below Authentication, require configured `GoogleIdTokenProvider`, call `AuthRepository.googleLink`, show safe loading/success/error states, and keep account/session fields backend-owned. Google sign-up role selection, unlinking, cross-email/recovery linking, recent re-auth, phone/OTP, MFA, production OAuth, release signing, iOS proof, profile creation, admin dashboard, payments, reviews, calls, calendar sync, notes, prescriptions, staging data, and production claims remain deferred |
| Logout/session clear | Account has a real `Log out` action that calls `AuthRepository.logout`; success clears the navigation stack back to onboarding, while failure shows a safe inline error. Destructive account deletion, MFA/PIN, phone auth, social auth, and password reset remain separately scoped |
| Change authentication slice | `changeAuthentication` is now a registered route from Account -> Authentication. It shows local two-step verification copy and keeps Change PIN, Turn off, and Learn more visibly locked/deferred until auth backend, re-authentication, secure storage, audit, and product security copy exist |
| Turn on authentication slice | `turnOnAuthentication` is now a registered route from Change Authentication -> Review turn-on setup. It shows blueprint two-step verification copy and keeps Turn on disabled until PIN/session/audit backend rules exist |
| Turn on authentication scope boundary | The turn-on-authentication lane intentionally stops after the local two-step verification review route. PIN creation, secure PIN storage, session/device checks, audit/security notifications, recovery rules, and account persistence remain deferred until auth backend/provider contracts exist (`DECISIONS.md` D027) |
| Create PIN slice | `createPin` is now a registered route from Turn On Authentication -> Review PIN setup. It validates local 6-digit PIN format and can hand a valid route-local draft into `confirmPinSave` without storing PIN or enabling 2FA |
| Create PIN scope boundary | The create-pin lane intentionally stops after local PIN format validation and route-local confirmation handoff. Secure PIN storage, session/device checks, audit/security notifications, account persistence, and recovery rules remain deferred until auth backend/provider contracts exist (`DECISIONS.md` D028) |
| Confirm PIN Save slice | `confirmPinSave` is now a registered route from Create PIN -> Review confirmation step. It validates a local 6-digit confirmation, compares against the route-local draft when provided, and shows a ready-for-secure-backend-storage summary without saving PIN or enabling 2FA |
| Confirm PIN Save scope boundary | The confirm-pin-save lane intentionally stops after route-local confirmation. Secure PIN storage, session/device checks, audit/security notifications, recovery rules, account persistence, and enabling two-step verification remain deferred until auth backend/provider contracts exist (`DECISIONS.md` D029) |
| Reminder slice | `reminder` is now a registered route from the Notifications app-bar calendar action. It provides a selectable calendar, updates the selected-date heading, and shows an honest date-specific empty state without creating fake reminders or scheduling notifications |
| Reminder scope boundary | The reminder lane intentionally stops before reminder records, persistence/API ownership, recurrence/timezone rules, notification delivery, permission behavior, edit/delete rules, and failure states (`DECISIONS.md` D030) |
| Schedules slice | `schedules` is now a registered route from the dashboard drawer Schedule row. It provides a selectable calendar, expandable seeded event details for the current date, and an honest empty state for dates without local schedule data; Add/Edit/Share/Delete stay visibly disabled |
| Schedules scope boundary | The schedules lane intentionally stops before schedule CRUD, recurrence/timezone calculations, live countdowns, persistence/API ownership, sharing/deep links, reminder delivery, permissions, and failure states (`DECISIONS.md` D031) |
| Selected dates slice | `selectedDates` is now a registered route from Manage Profile -> Business -> Edit hours. It supports date selection, all-day/time-range drafts, end-after-start validation, and a prepared local summary without mutating profile schedule state |
| Selected dates scope boundary | The selected-dates lane intentionally stops before profile/business-hours persistence, timezone and overlap rules, multiple hour sets, upgrade entitlements, server conflicts, and availability APIs (`DECISIONS.md` D032) |
| Community invitations/discover slice | `discoverCommunities` now covers the blueprint `/community-invitations-discover` tabs. For you keeps local discover/join, Requests accepts a seeded invitation into joined-community state, and Drafts shows an honest empty state |
| Community invitations/discover scope boundary | The community-invitations-discover lane intentionally stops before invitation delivery, rejection/approval workflows, draft persistence, invite permissions, moderation, and backend membership sync (`DECISIONS.md` D033) |
| Find mentor slice | `findMentor` is now a registered route from the dashboard drawer Providers row. It reuses the local specialist store, shows mentor cards with available times, supports category filtering, and hands Book Appointment to the existing local booking form |
| Find mentor scope boundary | The find-mentor lane intentionally stops before live availability, mentor/profile APIs, detailed reviews, pricing/payment rules, booking confirmation, provider calendar sync, and cancellation policy (`DECISIONS.md` D034) |
| Specialist details slice | `specialistDetails` is now a registered route from Find Mentor -> View details. It renders local provider info, day/time chip selection, selected-slot summary, and hands Book appointment to the existing local booking form |
| Specialist details scope boundary | The specialist-details lane intentionally stops before live availability, review details, payment/pricing enforcement, provider profile APIs, confirmed booking slots, calendar sync, and cancellation/error states (`DECISIONS.md` D035) |
| Remaining route triage | After `specialistDetails`, the remaining `routes.json` tail is component/demo/grid/marketing routes. Product work resumes at the earlier unresolved creator/content route `/published-articles` before touching payment, subscriptions, ads, or media upload (`DECISIONS.md` D036) |
| Published articles boundary | `/published-articles` is a frontend-ready read/list/detail surface only. Subscribers, article-story, add-new-article, persisted drafts, requests, subscriber access, comments, analytics, moderation, edit/delete, account sync, and content persistence remain backend/product replacement work (`DECISIONS.md` D038) |
| Route triage after creator content | After `publishedArticles`, backend-heavy creator/payment/media routes are skipped until contracts exist. Product work resumes at `/edit-your-name` as the next Manage Profile basic-info draft route (`DECISIONS.md` D039) |
| Edit your name slice | `editYourName` is now a registered route from Manage Profile `Edit`. It validates a local name draft, shows inline errors, and displays a prepared-name summary that explicitly does not save profile state |
| Edit your name boundary | `editYourName` stops after local validation and draft summary. Profile name persistence, account identity sync, verification status changes, audit/security records, conflict handling, and backend profile APIs remain deferred (`DECISIONS.md` D041) |
| Edit your website slice | `editYourWebsite` is now a registered route from Manage Profile Basic `Edit website`. It validates a local website draft, shows inline errors, and displays a prepared-website summary that explicitly does not save profile state |
| Edit your website boundary | `editYourWebsite` stops after local validation and draft preparation. Profile website persistence, verification changes, account identity sync, audit/security records, conflict handling, and backend profile APIs remain deferred (`DECISIONS.md` D043) |
| Add description slice | `addDescription` is now a registered route from Manage Profile About `Edit description`. It reuses the shared multiline text field, validates local profile copy, and shows a prepared-description summary that explicitly does not save profile state |
| Add description boundary | `addDescription` stops after local validation and draft preparation. Profile-copy persistence, moderation/compliance review, public profile publishing, account identity sync, audit/security records, conflict handling, and backend profile APIs remain deferred (`DECISIONS.md` D045) |
| Manage Profile route triage after description | After `/add-desicription`, `/edit-your-email` is skipped because account/security email routes already own email review/change/verification drafts, `/add-time-and-day` is skipped because `selectedDates` already owns local business-hours drafting, and `/set-address` is selected as the next honest profile draft route (`DECISIONS.md` D046) |
| Set address slice | `setAddress` is now a registered route from Manage Profile Basic `Edit address`. It validates local location/address text and shows a prepared-address summary that explicitly does not save profile state or use location services |
| Set address boundary | `setAddress` stops after local validation and draft preparation. Profile-address persistence, location/geocoding/map services, device-location permissions, verification changes, account identity sync, audit/security records, conflict handling, and backend profile APIs remain deferred (`DECISIONS.md` D048) |
| Remaining blueprint tail triage | After Manage Profile basics, no new honest frontend-only route is selected from the remaining blueprint tail. Ads/payments/audience, media upload/recording, backend account verification, duplicate feed/Q&A/schedule/reminder routes, and component/demo frames are deferred or already covered (`DECISIONS.md` D049) |
| Historical frontend coverage audit | At that earlier audit, the route inventory was reported as 68 wired routes. Later appointment detail, consultation, finance, and other routes superseded that count; current inventory is 79 constants / 78 cases. Backend/product seams remain in `DEFERRED_WORK.md` (`DECISIONS.md` D050) |
| Backend/product readiness handoff | `DEFERRED_WORK.md` now groups deferred seams by contract group and replacement path so backend work can replace local stores/repositories without rewriting completed frontend routes (`DECISIONS.md` D051) |
| Historical frontend handoff review | At that review, 68 wired routes were reported and `login` was the only reserved unwired constant. The live count has since advanced to 78 cases / 79 constants; route-specific UX/accessibility review continues under APP-P1-021 (`DECISIONS.md` D052) |
| First backend contract selection | Backend/product integration starts with `Auth/session/account persistence`. The next slice must define the API/session/provider/repository contract before implementation; no locked controls are enabled by this decision (`DECISIONS.md` D053) |
| Auth/session/account contract | `docs/AUTH_SESSION_ACCOUNT_CONTRACT.md` defines the Flutter-side backend contract: environment/base URL rules, REST API style, bearer-token auth, secure refresh-token storage, auth/account models, validation/error behavior, provider boundaries, and repository replacement plan. Runtime screens remain local/client-only until the next infrastructure slice (`DECISIONS.md` D054) |
| Auth/session/account infrastructure | The app now has a backend-ready auth boundary without screen wiring: `CareNetApiConfig`, `AuthApiClient`, secure/in-memory session stores, auth/session/user models, `AuthRepository`, `AccountRepository`, DI registration, and focused tests. Existing auth screens still use local/client-only behavior until a later wiring slice (`DECISIONS.md` D055) |
| Email sign-in backend wiring | `signInEmail` now preserves local validation, calls `AuthRepository.login` for valid credentials, shows a loading state while pending, navigates only after repository success, and shows safe backend/config errors without navigating. Phone sign-in, sign-up, social auth, password reset, and account-security flows remain unchanged/deferred (`DECISIONS.md` D056) |
| Email sign-up backend wiring | `signUpEmail` still validates email before opening `finishSignUp`; `finishSignUp` now accepts the validated email, preserves full local form validation, calls `AuthRepository.register` with patient role/profile data, shows loading/error states, and navigates only after repository success. Phone sign-up, social auth, password reset, and account-security flows remain unchanged/deferred (`DECISIONS.md` D057) |
| Change authentication scope boundary | The change-authentication lane intentionally stops after the local two-step verification information route. PIN creation/confirmation, disabling two-step verification, password re-authentication, secure PIN storage, device/session checks, audit logs, phone/email verification, and security help copy remain deferred until auth backend/product contracts exist (`DECISIONS.md` D019) |
| Add phone number slice | `addPhoneNumber` is now a registered route from Account -> Phone number. It validates a local phone-entry draft and shows a ready-for-SMS-verification summary without changing the account phone number or pretending to send an OTP |
| Add phone number scope boundary | The add-phone lane intentionally stops after the local phone-entry draft. OTP/SMS delivery, code verification, phone uniqueness checks, password re-authentication, rate limiting, account-session updates, recovery rules, and account persistence remain deferred until auth backend/provider contracts exist (`DECISIONS.md` D020) |
| Confirm phone number slice | `confirmPhoneNumber` is now a registered route from Add Phone Number -> Open confirmation step. It validates a local phone confirmation draft and shows a ready-for-backend-OTP-verification summary without sending OTP or changing account phone state |
| Confirm phone number scope boundary | The confirm-phone-number lane intentionally stops after the local confirmation draft. OTP/SMS delivery, code confirmation, phone uniqueness checks, session updates, rate limiting, audit/security notifications, and account persistence remain deferred until auth backend/provider contracts exist (`DECISIONS.md` D026) |
| Add email slice | `addEmail` is now a registered route from Account -> Email address. It validates a local email-entry draft and shows a ready-for-email-verification summary without changing the account email address or pretending to send a verification email |
| Add email scope boundary | The add-email lane intentionally stops after the local email-entry draft. Verification email delivery, code confirmation, email uniqueness checks, password re-authentication, rate limiting, account-session updates, recovery/security notifications, and account persistence remain deferred until auth backend/provider contracts exist (`DECISIONS.md` D022) |
| Edit email slice | `editEmail` is now a registered route from Add Email -> Review current email. It shows the current email as verified, hands Edit email to `changeEmail`, and keeps Remove email locked/deferred until account-security backend rules exist |
| Edit email scope boundary | The edit-email lane intentionally stops after the local current-email management route. Email removal, password re-authentication, recovery rules, account-session updates, audit/security notifications, and account persistence remain deferred until auth backend/provider contracts exist (`DECISIONS.md` D024) |
| Enter password to save slice | `enterPasswordToSave` is now a registered route from Edit Email -> Review password step. It validates a local password entry and shows a ready-for-backend-reauthentication summary without verifying the password, saving account changes, or mutating account state |
| Enter password to save scope boundary | The enter-password-to-save lane intentionally stops after the local password-entry validation route. Real password verification, session/device checks, rate limiting, audit/security notifications, account mutation unlocks, and account persistence remain deferred until auth backend/provider contracts exist (`DECISIONS.md` D025) |
| Change email slice | `changeEmail` is now a registered route from Add Email -> Change existing email. It validates a local change-email draft, rejects the current email, and shows a ready-for-code-verification summary without changing the account email address or pretending to send a code |
| Change email scope boundary | The change-email lane intentionally stops after the local change-email draft. Verification-code delivery, code confirmation, email uniqueness checks, password re-authentication, rate limiting, account-session updates, recovery/security notifications, and account persistence remain deferred until auth backend/provider contracts exist (`DECISIONS.md` D023) |
| Password slice | `password` is now a registered route from Account -> Password. It shows local password security information and the current local password hint; Edit password remains visibly locked/deferred until auth backend and password-change contracts exist |
| Password scope boundary | The password lane intentionally stops after the local password security information route. Password editing, current-password verification, password policy enforcement, code confirmation, session invalidation, recovery/security notifications, and account persistence remain deferred until auth backend/provider contracts exist (`DECISIONS.md` D021) |
| Public profile slice | `publicProfile` now shows a read-only local professional profile with article previews, specializations, contact details, about text, and section summaries. `Message` opens messages, `Schedule` opens the local booking form, and portfolio/podcast/share are explicitly disabled until creator/media/sharing workflows exist |
| Public profile scope boundary | The public-profile lane intentionally stops after local read-only profile content plus real message/schedule handoffs. Profile APIs, creator portfolio, media/podcast profile content, product-approved sharing, provider scheduling, verified public identity, public reviews/testimonies, and subscription/upgrade behavior remain deferred |
| Owner circle profile slice | `ownerCircleProfile` is now a registered local route based on blueprint `/owner-circle-profile`. It shows the owner circle content, member previews, articles, events, and owner-only settings actions that are visibly locked/deferred until community-management APIs exist |
| Owner circle scope boundary | The owner-circle lane intentionally stops after the local owner profile and locked settings surface. Permissions, member invitations, role changes, moderation, editing circle details, sharing, favourites sync, reporting, exiting, and destructive circle deletion remain deferred until backend/community-management and product safety rules exist |
| Manage profile slice | `manageProfile` is now a registered local route based on blueprint `/manage-profile`. It shows local Basic, About, Business schedule, and Articles sections, with real handoffs to `editYourName`, `editYourWebsite`, `setAddress`, `addDescription`, `messages`, `selectedDates`, and `managePortfolio`; Events, Boost, Podcast, Share, member management, and group-detail edits remain visibly disabled/deferred |
| Manage profile scope boundary | The manage-profile lane intentionally stops after local profile summary plus settings/messages handoffs. Profile update APIs, schedule persistence, events, ads/payment review, media, sharing, member management, group persistence, and creator verification remain deferred until backend/product contracts exist. Replacement contract is documented in `DEFERRED_WORK.md` |
| Manage portfolio slice | `managePortfolio` is now a registered local route based on blueprint `/manage-portfolio`. `Manage Profile` hands off from `Articles -> Manage`; the route shows local Page/Circles portfolio content behind `ManagePortfolioLocalStore`, with real `Edit -> settings` and `Message -> messages` handoffs. Add new article, Upload new podcast, Upgrade, Events, Boost, Podcast, and Share remain visibly disabled/deferred |
| Manage portfolio scope boundary | The manage-portfolio lane intentionally stops after the local Page/Circles portfolio surface. `/add-new-article`, `/add-new-podcast`, `/recording`, ads/boosting, subscription upgrades, payment setup, moderation, analytics, and sharing remain deferred until backend/product contracts exist (`DECISIONS.md` D018) |
| Podcast slice | Podcast notifications now route to a real local `podcast` screen with local episode content, image-backed episode cards, and local `Watch` state. The podcast lane intentionally stops here before streaming, episode APIs, comments, uploads/recording, account sync, and search filtering so those backend/media workflows are not faked |
| Focused verification | Shared widget tests plus auth, dashboard, messaging, notifications, and readings flow tests pass; focused analyze is clean |

---

## What was wrong before Phase 0 (fixed)

| Issue | Fix |
|-------|-----|
| `home: NotificationsPage()` bypassed all flows | Removed; `initialRoute` + `onGenerateRoute` |
| `Messages.dart` had its own `main()` | Removed |
| Splash 5 second delay | 800ms |
| `pushNamed` without router | Router enabled |
| Home drawer `Scaffold.of` crash risk | `Builder` wrapper |

---

## Intentional stubs (not bugs)

| Location | What's missing | Phase |
|----------|----------------|-------|
| Google / Facebook / Apple auth | Backend/provider integration; UI now intentionally disabled instead of no-op | 2b |
| API / auth backend | `ApiService` unused by features | 2b+ |

---

## Design tokens & components (Phase 1)

| Item | Status |
|------|--------|
| `CarenetColors` (primary + neutral) | **Done** - `lib/core/tokens/carenet_colors.dart` |
| Semantic text-field colors (`success`, `error`, `info`) | **Done** - added to `CarenetColors` from blueprint palette |
| `CarenetButton` (primary, outline, disabled, large) | **Done** - `lib/shared/widgets/carenet_button.dart` |
| `CarenetTextField` | **Done** - `lib/shared/widgets/carenet_text_field.dart` |
| Onboarding uses shared button | **Done** |
| Sign-up phone/email use shared text field/button | **Done** |
| Other UI still on `AppColors` | Messaging, theme, and additional auth screens - later phases |

---

## Process guardrails

| Item | Status |
|------|--------|
| `ARCHITECTURE_RULES.md` | **Done** - folder ownership, routing, reusable UI, state, testing, and handoff rules |
| `TASK_TEMPLATE.md` | **Done** - required task spec and acceptance checklist for implementation tasks |

## Latest verification note

| Check | Result |
|-------|--------|
| 2026-06-12 pre-push milestone audit | Passed: `flutter analyze` reports no issues, all 132 tests pass, and `flutter build apk --debug` produces `build/app/outputs/flutter-apk/app-debug.apk`. Android now uses Kotlin 2.1.0. Route coverage remains 68 wired routes plus the intentionally reserved `login` constant. Local archives and credentials are ignored, and the legacy API helper no longer logs request bodies, credentials, cookies, or server responses. iOS still requires macOS/Xcode verification. Play Store/App Store release identifiers, signing, provider credentials, backend contracts, and compliance remain team-owned launch work rather than completed frontend behavior. |
| `flutter test` after docs-only reliability hardening | Timed out after 5 minutes; no Flutter/Dart process remained afterward. Treat as baseline issue for full-suite runs. |
| Focused task 10.5 test/analyze | Passed: focused `flutter analyze` and `communities_flow_test` after the named-route cleanup; communities now has an explicit scope stop before invitation/approval workflows |
| Focused task 11.1 test/analyze | Passed: focused `flutter analyze` and `qa_flow_test`; Post tab now hosts the first real Q&A feed + ask flow |
| Focused task 11.2 test/analyze | Passed: focused `flutter analyze` and `qa_flow_test`; Q&A answer requests, tagged questions, and local comment/answer flow now work end to end |
| Focused task 11.3 test/analyze | Not needed beyond task 11.2 verification: this task is a documented scope boundary decision to stop Q&A before `q-a-post` invents mixed feed logic |
| Focused task 12.1 test/analyze | Passed: focused `flutter analyze` and `account_flow_test`; drawer Profile now opens a real account flow with delete/deactivate behavior |
| Focused task 12.2 test/analyze | Passed: focused `flutter analyze` and `account_flow_test`; settings/profile local validation and save now work end to end |
| Focused task 12.3 test/analyze | Not needed beyond task 12.2 verification: this task is a documented scope boundary decision to stop the account lane before public profile/auth-security dependencies |
| Focused task 13.1 test/analyze | Passed: focused `flutter analyze`, `podcast_flow_test`, and `messaging_flow_test`; podcast notification routing and local watch state work end to end |
| Focused task 13.2 test/analyze | Not needed beyond task 13.1 verification: this task is a documented scope boundary decision to stop podcast before media/upload/comment/backend content workflows |
| Focused task 14.1 test/analyze | Passed: focused `flutter analyze`, `search_flow_test`, and `dashboard_shell_test`; Search tab now has local specialist search/filter/profile/request behavior |
| Focused task 14.2 test/analyze | Not needed beyond task 14.1 verification: this task is a documented scope boundary decision to stop search before live availability/payment/booking/provider-profile workflows |
| Focused task 15.1 test/analyze | Passed: focused `flutter analyze` and `health_record_flow_test`; Health Record shows local vitals and latest blood sugar values |
| Focused task 15.2 test/analyze | Not needed beyond task 15.1 verification: this task is a documented scope boundary decision to stop health record before backend history/export/synced-vital workflows |
| Focused task 16.1 test/analyze | Passed: focused `flutter analyze`, `articles_flow_test`, and `saved_articles_flow_test`; saved articles now has empty/list/detail/remove behavior backed by the shared local article store |
| Focused task 16.2 test/analyze | Not needed beyond task 16.1 verification: this task is a documented scope boundary decision to stop saved/content-library work before creator publishing, subscribers, article-story, analytics, account sync, comments, and content APIs |
| Focused task 17.1 test/analyze | Passed: focused `flutter analyze` and `case_studies_flow_test`; case studies now has list/filter/detail/read-state behavior backed by a local content store |
| Focused task 17.2 test/analyze | Not needed beyond task 17.1 verification: this task is a documented scope boundary decision to stop case studies before content API, verified review, author/publication, comments, sharing, account sync, and moderation dependencies |
| Focused task 18.1 test/analyze | Passed: focused `flutter analyze` and `public_profile_flow_test`; public profile route now has local profile content, real message/schedule handoffs, and disabled deferred creator/media/share actions |
| Focused task 18.2 test/analyze | Not needed beyond task 18.1 verification: this task is a documented scope boundary decision to stop public profile before profile APIs, creator portfolio, media, sharing, provider scheduling, reviews, verified identity, and subscription/upgrade dependencies |
| Focused task 19.1 test/analyze | Passed: focused `flutter analyze` and `communities_flow_test`; owner circle profile route shows local owner content and locked/deferred owner settings |
| Focused task 19.2 test/analyze | Not needed beyond task 19.1 verification: this task is a documented scope boundary decision to stop owner-circle work before permissions, invites, moderation, editing, sharing, reporting, exiting, and destructive community APIs |
| Focused task 20.1 test/analyze | Passed: focused `flutter analyze` and `manage_profile_flow_test`; manage profile route shows local profile-management content, settings/messages handoffs, and disabled backend-dependent controls |
| Focused task 20.2 test/analyze | Not needed beyond task 20.1 verification: this task is a documented scope boundary and backend replacement contract for manage-profile work |
| Focused task 21.1 test/analyze | Added `manage_portfolio_flow_test`; tool-side Flutter/Dart commands froze/timed out in this session, so run `flutter test test/features/home/manage_portfolio_flow_test.dart` and focused analyze from PowerShell before treating verification as device-proven |
| Focused task 21.2 test/analyze | Not needed beyond task 21.1 verification: this task is a documented scope boundary decision to stop manage portfolio before creator publishing, media upload/recording, ads/payment/subscription workflows, moderation, analytics, and sharing |
| Focused task 22.1 test/analyze | Added Account -> Authentication -> `changeAuthentication` coverage to `account_flow_test`; tool-side Dart/Flutter commands timed out in this session, so run `dart format`, `flutter test test/features/home/account_flow_test.dart`, and focused analyze from PowerShell before treating verification as device-proven |
| Focused task 22.2 test/analyze | Not needed beyond task 22.1 verification: this task is a documented scope boundary decision to stop change-authentication before PIN/security/auth-backend workflows |
| Focused task 23.1 test/analyze | Passed from PowerShell: `account_flow_test` covers Account -> Phone number -> addPhoneNumber validation, ready-for-SMS-verification draft, and unchanged account phone |
| Focused task 23.2 test/analyze | Not needed beyond task 23.1 verification: this task is a documented scope boundary decision to stop add-phone-number before OTP/SMS/code/auth-session workflows |
| Focused task 24.1 test/analyze | Passed from PowerShell: `account_flow_test` covers Account -> Password -> password route and locked Edit password action |
| Focused task 24.2 test/analyze | Not needed beyond task 24.1 verification: this task is a documented scope boundary decision to stop password before password-change/auth-backend workflows |
| Focused task 25.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `account_flow_test`; Account -> Email address -> addEmail required/invalid/valid states and unchanged account email all verify cleanly |
| Focused task 25.2 test/analyze | Not needed beyond task 25.1 verification: this task is a documented scope boundary decision to stop add-email before verification/code/auth-session workflows |
| Focused task 26.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `account_flow_test`; Add Email -> Change existing email -> changeEmail required/invalid/same/valid states and unchanged account email all verify cleanly |
| Focused task 26.2 test/analyze | Not needed beyond task 26.1 verification: this task is a documented scope boundary decision to stop change-email before verification-code/auth-session workflows |
| Focused task 27.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `account_flow_test`; Add Email -> Review current email -> editEmail verified display, locked Remove email, and Edit email handoff to `changeEmail` all verify cleanly |
| Focused task 27.2 test/analyze | Not needed beyond task 27.1 verification: this task is a documented scope boundary decision to stop edit-email before email removal/re-auth/account-persistence workflows |
| Focused task 28.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `account_flow_test`; Edit Email -> Review password step -> enterPasswordToSave required/short/valid-length states and unchanged account email all verify cleanly |
| Focused task 28.2 test/analyze | Not needed beyond task 28.1 verification: this task is a documented scope boundary decision to stop enter-password-to-save before real password verification/session/audit/account-persistence workflows |
| Focused task 29.1 test/analyze | Passed: focused `flutter analyze` and `account_flow_test`; confirm phone number route validates locally, prepares backend OTP verification, and does not mutate account phone state |
| Focused task 29.2 test/analyze | Not needed beyond task 29.1 verification: this task is a documented scope boundary decision to stop confirm-phone-number before OTP/code/session/account-persistence workflows |
| Focused task 30.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `account_flow_test`; Authentication -> Review turn-on setup -> turnOnAuthentication copy and disabled Turn on action all verify cleanly |
| Focused task 30.2 test/analyze | Not needed beyond task 30.1 verification: this task is a documented scope boundary decision to stop turn-on-authentication before PIN/session/audit/account-persistence workflows |
| Focused task 31.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `account_flow_test`; Authentication -> Review turn-on setup -> Review PIN setup -> createPin required/invalid/valid PIN states verify cleanly |
| Focused task 31.2 test/analyze | Not needed beyond task 31.1 verification: this task is a documented scope boundary decision to stop create-pin before PIN confirmation/storage/session/account-persistence workflows |
| Focused task 32.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `account_flow_test`; Authentication -> turn-on -> createPin -> confirmPinSave required/invalid/mismatch/match states verify cleanly |
| Focused task 32.2 test/analyze | Not needed beyond task 32.1 verification: this task is a documented scope boundary decision to stop confirm-pin-save before secure storage/session/audit/account-persistence workflows |
| Focused task 33.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `messaging_flow_test`; Notifications -> reminder navigation, calendar rendering, date selection, and empty state verify cleanly |
| Focused task 33.2 test/analyze | Not needed beyond task 33.1 verification: this task is a documented scope boundary decision to stop reminders before persistence/delivery/provider workflows |
| Focused task 34.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `dashboard_shell_test`; drawer Schedule navigation, event details, active status, disabled Add reminder, and detail collapse verify cleanly |
| Focused task 34.2 test/analyze | Not needed beyond task 34.1 verification: this task is a documented scope boundary decision to stop schedules before CRUD/persistence/delivery/provider workflows |
| Focused task 35.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `manage_profile_flow_test`; Business Edit hours navigation, calendar, all-day draft preparation, and no-save summary verify cleanly |
| Focused task 35.2 test/analyze | Not needed beyond task 35.1 verification: this task is a documented scope boundary decision to stop selected dates before profile-hours persistence/product workflows |
| Focused task 36.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `communities_flow_test`; For you, Requests acceptance into joined communities, and Drafts empty state verify cleanly |
| Focused task 36.2 test/analyze | Not needed beyond task 36.1 verification: this task is a documented scope boundary decision to stop community invitations before delivery/approval/moderation/backend sync workflows |
| Focused task 37.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `dashboard_shell_test`; drawer Providers -> findMentor and Book Appointment -> local booking form verify cleanly |
| Focused task 37.2 test/analyze | Not needed beyond task 37.1 verification: this task is a documented scope boundary decision to stop find-mentor before live availability/profile/payment/booking-confirmation workflows |
| Focused task 38.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `dashboard_shell_test`; Find Mentor -> Specialist Details -> local day/time selection -> booking form handoff verify cleanly |
| Focused task 38.2 test/analyze | Not needed beyond task 38.1 verification: this task is a documented scope boundary decision to stop specialist-details before live availability/reviews/payment/booking-confirmation workflows |
| Focused task 39.1 test/analyze | Not needed: route triage/documentation-only decision after inspecting `routes.json`; next implementation target is `/published-articles` |
| Focused task 40.1 test/analyze | `flutter test test/features/home/manage_portfolio_flow_test.dart` passes; `flutter analyze lib/core/constants/navigators/routeName.dart lib/core/constants/navigators/router.dart lib/features/Home/presentation/pages/manage_portfolio_shell.dart lib/features/Home/presentation/pages/published_articles_shell.dart test/features/home/manage_portfolio_flow_test.dart` reports no issues |
| Focused task 40.2 test/analyze | Not needed beyond task 40.1 verification: this task is a documented scope boundary decision to stop published articles before subscribers/article-story/add-new-article/drafts/analytics/comments/content APIs |
| Focused task 41.1 test/analyze | Not needed: route triage/documentation-only decision after inspecting remaining blueprint routes; next implementation target is `/edit-your-name` |
| Focused task 42.1 test/analyze | `flutter test test/features/home/manage_profile_flow_test.dart` passes; `flutter analyze lib/core/constants/navigators/routeName.dart lib/core/constants/navigators/router.dart lib/features/Home/presentation/pages/manage_profile_shell.dart lib/features/Home/presentation/pages/edit_your_name_shell.dart test/features/home/manage_profile_flow_test.dart` reports no issues |
| Focused task 42.2 test/analyze | Not needed beyond task 42.1 verification: this task is a documented scope boundary decision to stop edit-your-name before profile persistence/account sync/verification/audit/backend APIs |
| Focused task 43.1 test/analyze | `flutter test test/features/home/manage_profile_flow_test.dart` passes; `flutter analyze lib/core/constants/navigators/routeName.dart lib/core/constants/navigators/router.dart lib/features/Home/presentation/pages/manage_profile_shell.dart lib/features/Home/presentation/pages/edit_your_website_shell.dart test/features/home/manage_profile_flow_test.dart` reports no issues |
| Focused task 43.2 test/analyze | Not needed beyond task 43.1 verification: this task is a documented scope boundary decision to stop edit-your-website before profile persistence/verification/account sync/audit/backend APIs |
| Focused task 44.1 test/analyze | `flutter test test/features/home/manage_profile_flow_test.dart` passes all 7 tests; focused `flutter analyze` on the shared text field, route wiring, Manage Profile, Add Description page, and flow test reports no issues |
| Focused task 44.2 test/analyze | Not needed beyond task 44.1 verification: this task is a documented scope boundary decision to stop add-description before profile-copy persistence/moderation/publishing/account-sync/backend APIs |
| Focused task 45.1 test/analyze | Not needed: route triage/documentation-only decision after inspecting remaining Manage Profile blueprint routes; next implementation target is `/set-address` |
| Focused task 46.1 test/analyze | `flutter test test/features/home/manage_profile_flow_test.dart` passes all 8 tests; `flutter analyze lib/core/constants/navigators/routeName.dart lib/core/constants/navigators/router.dart lib/features/Home/presentation/pages/manage_profile_shell.dart lib/features/Home/presentation/pages/set_address_shell.dart test/features/home/manage_profile_flow_test.dart` reports no issues |
| Focused task 46.2 test/analyze | Not needed beyond task 46.1 verification: this task is a documented scope boundary decision to stop set-address before profile-address persistence/location services/maps/account-sync/backend APIs |
| Focused task 47.1 test/analyze | Not needed: route triage/documentation-only decision after inspecting the remaining blueprint tail; no new runtime route selected |
| Focused task 48.1 test/analyze | Not needed: documentation/router coverage audit only; checked route constants vs router cases and docs/deferred-work consistency without runtime code changes |
| Focused task 49.1 test/analyze | Not needed: documentation-only backend/product readiness handoff; no runtime code changed |
| Focused task 50.1 test/analyze | Not needed: documentation-only final handoff review; checked docs/router status and deferred-work readiness without runtime code changes |
| Focused task 52.1 test/analyze | Passed: `flutter test test/features/authentication/auth_infrastructure_test.dart`; focused `flutter analyze` on the auth config/client/session/model/repository files and auth infrastructure test reports no issues |
| Focused task 52.2 test/analyze | Passed: `flutter test test/features/authentication/sign_in_flow_test.dart test/features/authentication/auth_infrastructure_test.dart`; focused `flutter analyze` on email sign-in, auth repository/failure, and sign-in tests reports no issues |
| Focused task 52.3 test/analyze | Passed: `flutter test test/features/authentication/sign_up_flow_test.dart test/features/authentication/finish_sign_up_test.dart test/features/authentication/auth_infrastructure_test.dart`; focused `flutter analyze` on email sign-up, finish sign-up, router, and sign-up tests reports no issues |
| Focused task 52.4 test/analyze | Passed: `flutter test test/features/authentication/session_restore_guard_test.dart test/features/authentication/sign_in_flow_test.dart test/features/authentication/finish_sign_up_test.dart test/features/authentication/auth_infrastructure_test.dart`; focused `flutter analyze` on splash guard, session restore test, and auth repository reports no issues |
| Focused task 52.5 test/analyze | Passed: `flutter test test/features/home/account_flow_test.dart`; focused `flutter analyze` on Account and account-flow tests reports no issues |
| Focused task 52.6 test/analyze | Passed: `flutter test test/features/authentication/password_recovery_flow_test.dart test/features/authentication/auth_infrastructure_test.dart`; focused `flutter analyze` on password reset screens and password recovery tests reports no issues |
| Focused task 52.7 test/analyze | Passed: `flutter test test/features/home/account_flow_test.dart`; focused `flutter analyze` on Account and account-flow tests reports no issues |
| Focused task 52.8 test/analyze | Passed: `flutter test test/features/home/account_flow_test.dart`; focused `flutter analyze` on current-email review and account-flow tests reports no issues |
| Focused task 52.9 test/analyze | Passed: `flutter test test/features/authentication/auth_infrastructure_test.dart test/features/authentication/sign_in_flow_test.dart test/features/authentication/sign_up_flow_test.dart test/features/authentication/finish_sign_up_test.dart test/features/authentication/password_recovery_flow_test.dart test/features/authentication/session_restore_guard_test.dart test/features/home/account_flow_test.dart`; focused `flutter analyze` on auth data, auth screens, splash guard, Account/Edit Email, and related tests reports no issues |
| Focused task 52.10 test/analyze | Not needed: decision-only docs slice. Checked current docs and selected guardrail-doc restoration as `52.11`; no runtime code changed |
| Focused task 52.11 test/analyze | Not needed: docs-only guardrail restoration. `git diff --check` passes for changed docs; no runtime code changed |
| Focused task 52.12 test/analyze | Not needed: decision-only docs slice. Checked `DEFERRED_WORK.md` and selected a frontend/backend checkpoint as `52.13`; no runtime code changed |
| Focused task 52.13 test/analyze | Not needed: docs-only checkpoint. `git diff --check` passes for changed docs; no runtime code changed |
| Focused task 52.14 test/analyze | Not needed: decision-only docs slice. User selected password reset + email verification deep-link/code contract as the next target; no runtime code changed |
| Focused task 52.15 test/analyze | Not needed: contract-only docs slice. `git diff --check` passes for changed docs; no runtime code changed |
| Focused task 52.16 test/analyze | Passed: `flutter test test/features/authentication/auth_infrastructure_test.dart test/features/authentication/password_recovery_flow_test.dart test/features/home/account_flow_test.dart`; focused `flutter analyze` on reset/verification routes, auth client/repository, router, and related tests reports no issues |
| Focused task 52.17 test/analyze | Not needed: decision/map docs slice. `git diff --check` covers formatting; no runtime code changed |
| Focused task 52.18 test/analyze | Not needed beyond proxy smoke: docs/checkpoint slice. Verified `GET /health` and `GET /health/ready` through the developer-private proxy; `git diff --check` covers formatting; no runtime Flutter code changed |
| Focused task 52.19 test/analyze | Run `flutter analyze android/app/build.gradle.kts ios/Runner.xcodeproj/project.pbxproj` is not applicable because those are platform config files; use `rg "com\\.example\\.(app_t|appt)" android ios` to verify old app IDs are gone and `flutter test test/features/authentication/auth_infrastructure_test.dart` for a focused Dart sanity check |
| Focused task 52.20 test/analyze | Not needed beyond prerequisite evidence: docs/setup slice. Verified `/health/ready` still reports `googleAuth: disabled`, listed staging secrets, collected debug SHA fingerprints with `keytool`, and `git diff --check` covers formatting |
| Focused task 52.21 test/analyze | Not needed beyond staging readiness evidence: backend/config checkpoint. Verified Cloud Run revision `carenet-backend-staging-00006-ph6` at 100 percent traffic and `/health/ready` through Cloud Run Proxy reports `googleAuth: ok` |
| Focused task 52.22 test/analyze | Passed: `flutter test test/features/authentication/sign_in_flow_test.dart test/features/authentication/auth_infrastructure_test.dart`; focused `flutter analyze` on Google provider DI, sign-in pages, and sign-in tests reports no issues; `flutter build apk --debug --dart-define=CARENET_API_BASE_URL=http://127.0.0.1:8080 --dart-define=GOOGLE_SIGN_IN_SERVER_CLIENT_ID=<web-client-id>` passes after transient Maven/DNS recovery |
| Focused task 52.23 test/analyze | Not needed: contract-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.24 test/analyze | Passed: `flutter test test/features/home/profile_repository_test.dart`; focused `flutter analyze` on profile API client, repository, entities/models, DI, and test reports no issues |
| Focused task 52.25 test/analyze | Passed: `flutter test test/features/home/manage_profile_flow_test.dart test/features/home/profile_repository_test.dart`; focused `flutter analyze` on Manage Profile read wiring and tests reports no issues |
| Focused task 52.26 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.27 test/analyze | Passed: `flutter test test/features/home/manage_profile_flow_test.dart test/features/home/profile_repository_test.dart`; focused `flutter analyze` on Add Description bio update, Manage Profile read wiring, profile repository/API client, professional entity, and related tests reports no issues |
| Focused task 52.28 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.29 test/analyze | Passed: `flutter test test/features/home/search_flow_test.dart test/features/home/manage_profile_flow_test.dart test/features/home/profile_repository_test.dart`; focused `flutter analyze` on Search public listing, Manage Profile, Add Description, profile repository/API client, public/professional entities, and related tests reports no issues |
| Focused task 52.30 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.31 test/analyze | Not needed: contract-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.32 test/analyze | Passed: `flutter test test/features/home/scheduling_repository_test.dart`; focused `flutter analyze` on scheduling entities/models/API client/repository, DI, and related test reports no issues |
| Focused task 52.33 test/analyze | Passed: `flutter test test/features/home/scheduling_repository_test.dart test/features/home/search_flow_test.dart`; focused `flutter analyze` on Search public availability read, scheduling repository/entity, and related tests reports no issues |
| Focused task 52.34 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.35 test/analyze | Passed: `flutter test test/features/home/appointments_flow_test.dart test/features/home/public_profile_flow_test.dart`; focused `flutter analyze` on booking route and related tests reports no issues |
| Focused task 52.36 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.37 test/analyze | Passed: `flutter test test/features/home/appointment_request_time_options_test.dart`; focused `flutter analyze` on the appointment request time-option entity/helper/test reports no issues |
| Focused task 52.38 test/analyze | Passed: `flutter test test/features/home/appointment_request_time_options_test.dart test/features/home/search_flow_test.dart`; focused `flutter analyze` on Search request wiring, appointment option helper/entity, and related tests reports no issues |
| Focused task 52.39 test/analyze | Passed: `flutter test test/features/home/appointments_flow_test.dart test/features/home/search_flow_test.dart`; focused `flutter analyze` on appointments list read wiring and related Search regression tests reports no issues |
| Focused task 52.40 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.41 test/analyze | Passed: `flutter test test/features/home/appointments_flow_test.dart test/features/home/search_flow_test.dart`; focused `flutter analyze` on appointments cancellation wiring and related Search regression tests reports no issues |
| Focused task 52.42 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.43 test/analyze | Passed: `flutter test test/features/home/appointment_request_time_options_test.dart test/features/home/search_flow_test.dart test/features/home/appointments_flow_test.dart`; focused `flutter analyze` on appointment option generation, Search request wiring, Appointments cancellation/listing, and related tests reports no issues |
| Focused task 52.44 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.45 test/analyze | Passed: `flutter test test/features/home/manage_profile_flow_test.dart test/features/home/scheduling_repository_test.dart`; focused `flutter analyze` on selectedDates availability management, Manage Profile flow test, scheduling repository/API client, and repository test reports no issues |
| Focused task 52.46 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.47 test/analyze | Passed: `flutter test test/features/home/appointments_flow_test.dart test/features/home/scheduling_repository_test.dart`; focused `flutter analyze` on Appointments role-aware lifecycle UI, appointment flow tests, scheduling repository/API client, and repository tests reports no issues |
| Focused task 52.48 test/analyze | Passed: `flutter test test/features/home/appointments_flow_test.dart test/features/home/scheduling_repository_test.dart`; focused `flutter analyze` on Appointments lifecycle regression, appointment flow tests, scheduling repository/API client, and repository tests reports no issues |
| Focused task 52.49 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.50 test/analyze | Passed: `flutter test test/features/home/appointments_flow_test.dart test/features/home/scheduling_repository_test.dart`; focused `flutter analyze` on Appointments completion wiring, scheduling repository/API client, and related tests reports no issues |
| Focused task 52.51 test/analyze | Passed: `flutter test test/features/home/appointments_flow_test.dart test/features/home/scheduling_repository_test.dart`; focused `flutter analyze` on Appointments completion regression and related scheduling files reports no issues |
| Focused task 52.52 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.53 test/analyze | Passed: focused scheduling core regression tests across appointment request options, Search, Appointments, selectedDates, manage profile, and scheduling repository; focused analyze reports no issues |
| Focused task 52.54 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.55 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.56 test/analyze | Passed: `flutter test test/features/home/appointment_request_time_options_test.dart test/features/home/appointments_flow_test.dart test/features/home/scheduling_repository_test.dart -r compact`; focused `flutter analyze` on Appointments reschedule wiring, scheduling repository/API client, and related tests reports no issues |
| Focused task 52.57 test/analyze | Passed: `flutter test test/features/home/appointment_request_time_options_test.dart test/features/home/appointments_flow_test.dart test/features/home/scheduling_repository_test.dart -r compact`; focused `flutter analyze` on Appointments reschedule regression, scheduling repository/API client, and related tests reports no issues |
| Focused task 52.58 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.59 test/analyze | Passed: `flutter build apk --debug --dart-define=CARENET_API_BASE_URL=http://127.0.0.1:8080`; `flutter test test/features/home/appointment_request_time_options_test.dart test/features/home/appointments_flow_test.dart test/features/home/scheduling_repository_test.dart -r compact`; focused `flutter analyze` on scheduling config/API/repository/Search/Appointments/selectedDates and related tests reports no issues |
| Focused task 52.87 test/analyze | Passed: `flutter test test/features/home/manage_profile_flow_test.dart -r expanded`; focused `flutter analyze` on route constants/router, Manage Profile, editProfessionalDetails, and manage-profile tests reports no issues |
| Focused task 52.88 test/analyze | Passed: `flutter test test/features/home/manage_profile_flow_test.dart -r expanded`; focused regression searches confirmed update/preservation/null-clearing coverage and no new category/specialty runtime behavior for broader modules |
| Focused task 52.91 test/analyze | Passed: `flutter test test/features/home/account_flow_test.dart -r expanded`; focused `flutter analyze` on Account Google account linking and account-flow tests reports no issues |
| Focused task 52.92 test/analyze | Passed: `flutter test test/features/home/account_flow_test.dart -r expanded`; focused `flutter analyze` on Account Google account linking and account-flow tests reports no issues; source/test inspection confirmed regression requirements and no broader provider/account behavior |
| Focused task 52.93 test/analyze | Not needed: decision-only docs slice. Reviewed Google linking regression, backend-completed map, codebase status, deferred-work register, and backend API plan; selected admin verification review boundary as the next lane without runtime code changes |
| Focused task 52.94 test/analyze | Not needed: decision-only docs slice. Reviewed backend admin verification API rules and accepted a separate admin dashboard/web console boundary; no runtime Flutter code changed |
| Focused task 52.95 test/analyze | Not needed: checkpoint/docs slice. Updated completed backend surface map, reviewed backend API plan and current Flutter repository boundaries, and selected stabilization/regression planning; no runtime Flutter code changed |
| Focused task 52.96 test/analyze | Not needed: planning/docs slice. `MOBILE_BACKEND_INTEGRATION_STABILIZATION_PLAN.md` defines grouped regression suites, focused analyze/docs checks, manual smoke checklist, known blockers, and 52.97 regression execution; no runtime Flutter code changed |
| Focused task 52.97 test/analyze | Passed after one test-harness fix: auth/session/account suite `72 tests passed`; profile/verification suite `42 tests passed`; discovery/booking suite `27 tests passed`; scheduling lifecycle suite `42 tests passed`; focused analyze reports no issues; `git diff --check` reports no whitespace errors |
| Focused task 52.98 test/analyze | Not needed: decision/docs slice. `MOBILE_MILESTONE_HANDOFF_STAGING_BOUNDARY.md` selects a handoff package as the next lane and keeps staging seed-data/smoke, release readiness, admin dashboard, and deferred product modules separate; no runtime Flutter code changed |
| Focused task 52.99 test/analyze | Not needed: handoff/docs slice. `MOBILE_BACKEND_MILESTONE_HANDOFF_PACKAGE.md` summarizes the regression-passed milestone and selects staging seed-data/smoke planning next; no runtime Flutter code changed |
| Focused task 53.1 test/analyze | Not needed: planning/docs slice. `STAGING_SEED_DATA_SMOKE_EXECUTION_PLAN.md` defines required staging data/config and smoke evidence rules; no runtime Flutter code changed |
| Focused APP-ID-004 test/analyze | Passed: `flutter test test/features/home/onboarding_repository_test.dart`; focused `flutter analyze` on onboarding catalog/readiness entities, models, API client, repository, DI, and tests reports no issues |
| Focused APP-ID-005 test/analyze | Passed: `flutter test test/features/onboarding/profile_setup_test.dart -r expanded`; focused `flutter analyze` on patient/professional setup UI and tests reports no issues |
| Focused APP-ID-006 verification | Not needed beyond docs/source inspection: decision-only slice. Backend profile DTOs/service normalization were checked, and `git diff --check` passes |
| Focused APP-ID-007 test/analyze | Passed: `flutter test test/features/onboarding/profile_setup_test.dart -r expanded`; focused `flutter analyze` on patient/professional setup catalog-code payload wiring and tests reports no issues |
| Focused APP-ID-008 verification | Not needed beyond docs/source inspection: decision-only slice. Checked PRD, role/onboarding decision docs, backend API plan, and APP-ID-007 payload alignment before recording the production onboarding domain boundary |
| Focused APP-ID-009 verification | Not needed beyond docs/source inspection: planning-only slice. Checked Flutter readiness models, signup routes, verification shell, and backend `AccountReadinessService`; `git diff --check` passes |
| Focused APP-ID-010 test/analyze | Passed: `flutter test test/features/onboarding/onboarding_readiness_route_resolver_test.dart test/features/authentication/finish_sign_up_test.dart test/features/authentication/sign_up_flow_test.dart -r expanded`; focused `flutter analyze` on resolver, signup pages/arguments/router, and related tests reports no issues |
| Focused APP-ID-011 verification | Not needed beyond docs/source inspection: planning-only slice. Checked setup screens, verification documents shell, readiness docs, and backend `AccountReadinessService`; `git diff --check` passes |
| Focused APP-ID-012 test/analyze | Passed: `flutter test test/features/onboarding/profile_setup_test.dart test/features/home/manage_profile_flow_test.dart -r expanded`; focused `flutter analyze` on onboarding setup, verification documents shell, and related tests reports no issues |
| Focused APP-ID-013 test/analyze | Passed: onboarding/auth regression group covering sign-up flow, finish sign-up, readiness resolver, profile setup, and manage profile/verification documents; focused analyze on related auth/onboarding/verification files reports no issues |
| Focused APP-ID-014 build/device check | Build passed: staging Android debug APK at `build/app/outputs/flutter-apk/app-debug.apk`; phone smoke blocked because `flutter devices` lists only Windows/Chrome/Edge and `adb devices` lists no Android serial |
| Focused APP-P1-004 verification | Passed: 29 targeted Find Care/dashboard route tests, full `flutter test` with 308 tests, full `flutter analyze` with no issues, Android debug APK build, `git diff --check`, and unchanged `pubspec.lock`. No Specialist Details, Schedule, appointment lifecycle, dependency, asset, native, or backend source changed |

## APP-P1-019 appointment participant identity

- Appointment responses now parse the backend viewer-scoped counterpart profile
  id, role, and display name.
- Active Home, appointment list, and appointment detail surfaces display the
  persisted counterpart name when its role matches the authenticated viewer.
- Missing, malformed, or role-mismatched identity falls back to a neutral role
  label and cannot alter appointment ownership or action authority.
- Messaging keeps its existing conversation-owned counterpart contract;
  notification presentation remains server-authored.

## MSG-P1-007 appointment messaging

- Backend authority is merged at
  `4e3e49df6490798374b245d6061f849ca02e6b4f`.
- The authenticated Messages destination loads backend conversation pages with
  stable activity ordering, unread badges, exact counterpart identity, and
  honest lifecycle state.
- `RouteName.chat` requires typed conversation or appointment authority and
  renders backend history through Flyer Chat. The legacy `message` alias fails
  closed and no seeded conversation remains active.
- WebSocket protocol-version-1 frames are hints only; reconnect, app resume,
  and disconnected polling recover through HTTP.
- Message bodies remain private in memory and are cleared with route disposal
  or account change.
- Verification passes with 41 focused messaging tests, 393 complete Flutter
  tests, clean `flutter analyze`, a debug Android APK, and `git diff --check`.
- Canonical contract: `PHASE_1_APPOINTMENT_MESSAGING.md`.

## CALL-P1-009 appointment consultations

- Backend consultation authority is merged at
  `42c595b5a34c8e203f411180fb76ef4ce25f4036`.
- Appointment Detail now consumes backend-owned consultation projection and
  opens one appointment-linked VIDEO/AUDIO consultation route.
- Flutter uses the official LiveKit SDK behind `RtcRoomAdapter`; CareNet
  retains waiting, admission, timing, participant, payment, incident,
  attendance, and completion authority.
- Prejoin, permission recovery, patient waiting, professional admission,
  active media controls, reconnect/rejoin, leave/end, incident reporting, and
  disposal/account-change cleanup are implemented without a Calls tab.
- Local verification passes with 14 focused consultation tests, 431 complete
  Flutter tests, clean `flutter analyze`, standard and staging-configured debug
  Android APK builds, stable dependency resolution, and `git diff --check`.
- Canonical contract: `PHASE_1_APPOINTMENT_CONSULTATIONS.md`.

## NOTIF-P1-010 transactional notifications

- Backend `NOTIF-P1-010A` owns durable domain events, recipient resolution,
  inbox projection, preferences, reminders, provider delivery state, retry and
  signed Resend webhook processing.
- Flutter `APP-P1-010B` owns authenticated inbox presentation, read/unread,
  preference controls, secure installation lifecycle, contextual FCM permission,
  foreground display, pending cold-start taps, and owner-checked route resolution.
- Push content is generic and privacy-safe. Destination pages reload current
  appointment, conversation, consultation, finance, verification, or account
  authority from CareNet APIs.
- Firebase configuration is compile-time and environment-specific. Provider
  secrets and Firebase Admin credentials are not present in the mobile repository.
- Staging and physical Android proof covers native high-importance channel
  creation, a valid notification drawable, foreground/background/terminated
  receipt, owner-scoped cold-start routing to the exact appointment conversation,
  and bounded splash/readiness recovery. Provider acceptance and signed email
  webhook processing are proven separately; production delivery and iOS APNs are
  not claimed.
- Canonical contract: `PHASE_1_TRANSACTIONAL_NOTIFICATIONS.md`.

## Design debt (fix in Phase 2+)

## APP-P1-014 account and route authority

- The active Account screen renders only `/account/me` identity, role, status,
  and email. It never falls back to `AccountLocalStore`.
- Patient profile access uses the existing backend patient profile setup;
  professional profile uses the backend professional setup editor, while
  verification, finance, notification preferences,
  Google linking, and logout retain their authoritative integrations.
- Unsupported local PIN, phone, email mutation, deactivation, and deletion
  controls are no longer active. Account deletion remains blocked pending a
  backend reauthentication, retention, audit, and session-revocation contract.
- Deferred social/content/readings/emergency/creator routes now fail closed to
  a common unavailable screen. Their source is retained for later deletion.
- Route inventory verification: 79 declared constants, including the reserved
  and unwired `login` constant.
- Verification baseline remains 481 complete Flutter tests; no test was
  skipped, disabled, or removed.

| Issue | Where |
|-------|--------|
| `finishSignUp` still uses legacy `BorderedTextInput` and wrapper button | `lib/features/Authentication/presentation/pages/sign_up_con.dart` |
| Legacy blue (`AppColors`) in theme / non-button UI | `app_colors.dart`, `theme.dart`, messaging - later phases |
| Notification visual cleanup remains | `Notification.dart` retains legacy styling while active Messages and Chat use the Phase 1 token direction |
| Feature state remains mostly page-local/static | DI now registers auth, account, profile, onboarding, scheduling, and verification services; only theme uses BLoC, while legacy feature state still relies on page state and local stores |
| Feature BLoC only for theme | No auth/home blocs |
| `RouteName.login` unused | No screen |

---

## Feature folders (what exists)

```text
lib/features/
  splash/          - splash screen
  Onboarding/      - onboarding + agreements + profession + user edit
  Authentication/  - sign in/up email & phone, sign_up_con
  Home/            - dashboard, home, feed_tab, readings, drawer, widgets
  Messaging/       - messages, chat, notification (needs Phase 1/5 styling)
```

Appointment-linked Messaging now has typed backend models, an authenticated repository,
Flyer Chat thread projection, body-free WebSocket recovery, and lifecycle-aware
read-only behavior. No dedicated features yet for: creator tools, subscriptions/ads,
or backend-backed public profile/security flows.

---

## Files that matter for routing

| File | Role |
|------|------|
| `lib/main.dart` | `configureDependencies()` + `runApp` |
| `lib/app.dart` | `MaterialApp`, theme, `initialRoute: splash` |
| `lib/core/constants/navigators/routeName.dart` | Constants |
| `lib/core/constants/navigators/router.dart` | `generateRoute` switch |
| `docs/ROUTES.md` | Human-readable table |

**Never** add `MaterialApp` or `void main()` elsewhere.

---

## Commands

```bash
cd C:\Users\asd\Music\Mobile-App-master
flutter pub get
flutter run
flutter test
flutter analyze lib test
```
