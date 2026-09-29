# Phase 1 Marketplace Implementation Plan

Slice family: `APP-P1`

Source decision: `PHASE_1_MARKETPLACE_BOUNDARY.md`

This plan narrows the Flutter app and matures backend-supported marketplace
paths. Appointment-linked text messaging and Appointment Detail video/audio
consultation are approved Phase 1 capabilities, but this plan does not silently
invent their runtime contracts. It also does not solve payment, support, refund,
payout, dual-role, or notification-provider contracts.

## APP-P1-017 - Legal pages and authentication app links

Canonical Firebase Hosting serves versioned Terms, Privacy, Support, and
account-deletion information. Active signup and Account surfaces open those
pages. Android email-verification and password-reset HTTPS links are associated
with the canonical staging and production package IDs and resolve into the
existing Flutter confirmation screens. Deployment must also update the backend
`PUBLIC_APP_BASE_URL`; production signing and iOS association remain later
release gates. See `PHASE_1_LEGAL_AUTH_LINKS.md`.

## APP-P1-020 - Verification upload integrity

Status: implemented; verification pending PR CI.

- Computes SHA-256 from the selected bytes off the UI isolate and always sends
  digest plus byte count to the backend upload-complete contract.
- Surfaces actual signed-upload transfer progress and supports explicit Dio
  cancellation without claiming the document entered review.
- Keeps signed URLs, private object keys, digests, local paths, and provider
  errors out of user-visible state and logs.
- Uses the backend as authority for object integrity and review eligibility.
- Defers malware scanning, retention/cleanup, background upload, admin review,
  cloud IAM proof, and physical-device acceptance.

## APP-P1-021 - Active-route UX and accessibility closure

Status: in progress; shared foundation and route-inventory reconciliation are
the first focused slice. The canonical checklist is
`PHASE_1_UX_ACCESSIBILITY.md`.

The milestone audits active patient and professional routes for truthful copy,
contrast, semantics, focus order, keyboard use where applicable, tap targets,
responsive layouts, and enlarged text. Shared theme/button changes are a
foundation, not a declaration that all screens are ready. Physical-device
accessibility acceptance remains a later gate. Content publishing or short-form
video is not part of this accessibility milestone and requires a separate
product, moderation, storage, and cost decision.

## Global gates for every runtime slice

- Start from the approved frontend integration branch on a dedicated slice branch.
- Preserve the original dirty checkout files; do not carry them into slice commits.
- Keep changes within the named slice and update canonical docs.
- Use real repositories where a backend contract exists; no local success fallback.
- Add loading, empty, error, unauthorized, and retry behavior proportional to the slice.
- Run focused tests, `flutter analyze lib test`, and an Android debug build when
  routing, dependency, or platform configuration changes.
- Open a PR into `feature/frontend-milestone`; do not merge to `main`/`master`
  without explicit project-lead approval.
- Stop after each slice for review. Do not start the next row automatically.

## Production-readiness foundation

### APP-P1-011 - Network, Session And Startup Foundation

Status: implemented on dedicated slice branch; verification pending PR CI.

- **Purpose:** Prevent indefinite feature requests, mixed secure-session records,
  avoidable sign-outs after access-token expiry, and optional notification work
  delaying the first usable frame.
- **Behavior:** Active API clients use bounded shared transport defaults;
  authenticated HTTP 401 responses share one token refresh and retry once with
  the rotated token; 403 remains an authorization failure; the secure session is
  one versioned record with fail-closed migration; notification initialization
  runs after `runApp` and times out safely.
- **Tests:** Atomic save/read/corrupt/migration, serialized refresh, retry header
  rotation, provider timeout, complete Flutter suite, analyzer and Android build.
- **Non-goals:** Product UI redesign, provider activation, account mutations,
  Firebase environment migration, Paystack activation or physical-device proof.

## A. Archive and Phase 1 scope lock

### APP-P1-001 - Phase 1 Marketplace Scope Decision

- **Purpose:** Lock the product boundary, route classification, dependency map,
  archive proposal, and implementation order.
- **Files:** Phase 1 docs plus canonical handoff/status/decision/deferred docs.
- **Expected behavior:** No runtime behavior changes.
- **Tests:** `git diff --check`; verify no `lib/`, platform, asset, or `pubspec`
  files changed; verify exactly one next task.
- **Risks:** Falsely claiming dirty files are archived; letting Figma define scope.
- **Stop:** Any need to modify runtime code or resolve payment/messaging/call rules.
- **Non-goals:** Archive-ref creation, route edits, code deletion, UI redesign.

### APP-P1-001A - Preserve Committed Broad UI Baseline

Status: completed; branch and annotated tag were pushed at exact commit
`3e04d6e22b17c5ff195085153a1d9cf842cb8d24`.

- **Purpose:** Create `archive/pre-phase1-broad-ui-2026-07-22` and annotated tag
  `pre-phase1-broad-ui-2026-07-22` at exact commit `3e04d6e`.
- **Files:** No source files; Git refs and a short preservation record only.
- **Expected behavior:** Existing app remains unchanged; archive refs resolve to
  the same committed tree and are pushed to the approved remote.
- **Tests:** `git rev-parse` both refs; `git diff 3e04d6e <ref> --exit-code`;
  remote ref verification.
- **Risks:** Tagging a dirty snapshot or the older `9385235` milestone and losing
  the recovered onboarding commits.
- **Stop:** Ref already exists at another commit, remote permission failure, or
  project lead has not approved ref creation.
- **Non-goals:** Commit/stash/reset dirty files, archive uncommitted work, merge branches.

## B. Role-aware navigation and active route pruning

### APP-P1-002 - Role-Aware Phase 1 Navigation Shell And Active Route Pruning

Status: merged through PR #151.

- **Purpose:** Replace the broad dashboard navigation with the approved patient
  and professional four-destination contracts plus header notification/account actions.
- **Likely files:** `dashboard.dart`, `drawer.dart`, `routeName.dart`, `router.dart`,
  `onboarding_readiness_route_resolver.dart`, `ROUTES.md`, `FLOW_MAP.md`, dashboard tests.
- **Expected behavior:** Patient tabs are Home/Find Care/Appointments/Messages;
  professional tabs are Home/Schedule/Appointments/Messages; the bell opens
  Notifications; Feed/Post/Circles/content/health/emergency/generic schedule routes
  are not reachable from active navigation; the header avatar opens Account/Profile.
  Patient setup exits to its approved
  readiness destination instead of `communityAgreement`.
- **Tests:** Patient/professional shell widget tests, tab order/destination tests,
  bell test, session/readiness route tests, legacy onboarding-chain absence test,
  router coverage, analyze, Android build.
- **Risks:** Client-side role spoofing, losing profile/logout access, exposing seeded
  Messages as real, breaking direct routes still needed by retained screens.
- **Stop:** Dual-role switching is required; role cannot be obtained from authenticated
  account/readiness; navigation would need new backend behavior.
- **Non-goals:** Delete deferred files, redesign visual language, implement messaging,
  payments, calls, or notification delivery.

## C. Patient and professional Home adaptation

### APP-P1-003 - Role-Aware Marketplace Home

Status: merged through PR #153.

- **Purpose:** Replace Feed/Messages/Articles Home tabs with useful patient and
  professional marketplace summaries using already available backend data.
- **Likely files:** `home.dart`, new small role Home widgets if justified,
  `appointments_shell.dart` shared presentation helpers only if extracted safely,
  Home/dashboard tests.
- **Expected behavior:** Patient Home shows honest upcoming-appointment and Find Care
  entry states. Professional Home shows verification/readiness, availability, and
  appointment-request summaries that can be supported by current repositories.
- **Tests:** Both role variants; loading/empty/error/session states; navigation actions;
  no Feed/Articles/seeded-message content; analyze.
- **Risks:** Duplicating appointment state logic, expensive repeated API calls, or
  implying payment/message/call readiness.
- **Stop:** Required summary data has no existing endpoint/repository or would need
  aggregate backend work; show a smaller honest Home instead and record the gap.
- **Non-goals:** Social/content widgets, analytics dashboard, earnings, new backend endpoint,
  broad visual redesign.

Implementation contract: `PHASE_1_MARKETPLACE_HOME.md`.

## D. Find Care consolidation

### APP-P1-004 - Canonical Find Care Discovery

Status: implemented on the dedicated APP-P1-004 slice branch; awaiting PR review.

- **Purpose:** Make `search` the sole patient discovery entry, remove Search-local
  and mentor-route competition, and keep detail/availability/request ownership separate.
- **Files:** `search_shell.dart`, router alias, Search/Find Mentor route tests, canonical docs.
- **Expected behavior:** One backend verified-professional listing drives cards and
  client-side name/category/specialty filtering. Empty, failure, retry, refresh and
  refresh failure are honest; result selection passes the exact backend id directly
  to `specialistDetails`; `findMentor` aliases Find Care.
- **Tests:** Initial/refresh loading, serialization, stale completion, disposal, empty
  versus filtered-empty, supported filtering, truthful fields, verification fail-closed,
  exact-id handoff, no local fallback, canonical legacy alias.
- **Risks:** Treating client filters as server features, showing malformed/unverified
  results, or letting stale requests replace newer state.
- **Stop:** Discovery requires a repository contract change or Specialist Details edits.
- **Non-goals:** Professional detail repair, availability, booking, symptom mapping,
  server-side filters/pagination, reviews, ratings, payment, backend changes.

Implementation contract: `PHASE_1_FIND_CARE.md`.

## E. Real backend booking path

### APP-P1-005 - Canonical Professional Detail And Real Booking - DONE

- **Purpose:** Make `specialistDetails` the canonical backend-owned professional detail,
  requestable-time, auth-resume, and idempotent appointment-request handoff.
- **Implemented behavior:** Exact backend ID uses single-detail and requestable-times
  endpoints; IANA timezone rendering is backend-instant based; missing IDs and failures
  never activate local identity or slots; a secure 24-hour account-bound intent survives
  auth and patient setup; patient-only requests send one persistent idempotency key;
  success remains `REQUESTED`; legacy booking routes resolve to Find Care.
- **Tests:** API contracts, ID propagation, missing/unknown detail, truthful fields,
  independent load failures, IANA/DST rendering, intent expiry/account binding,
  auth/onboarding resume, role denial, stale-time invalidation, duplicate submission,
  network retry key reuse, and no seeded fallback.
- **Risks carried forward:** Appointment list/detail presentation, messaging, calls,
  payments, cancellation policy copy, advanced schedule exceptions, and source deletion.
- **Contract:** `PHASE_1_PROFESSIONAL_DETAIL_BOOKING.md`.
- **Non-goals:** Payment, calls, messaging, ratings/reviews, calendar sync,
  notification sending, refund/cancellation redesign, backend changes.

### APP-P1-018 - Bounded Requestable-Time Loading - DONE

- **Purpose:** Adopt the backend bounded-range contract so Specialist Details does not
  transfer the complete 60-day requestable-time set on initial load.
- **Implemented behavior:** The initial request covers 14 UTC days. Patients can load
  later contiguous ranges explicitly; responses are policy/range validated, merged,
  deduplicated and ordered. Empty ranges can advance, repeated loads serialize, and
  later-page failures retain prior valid times.
- **Non-goals:** Recurrence generation, booking policy changes, appointment lifecycle,
  Schedule behavior, payment, messaging, calls, or backend changes.

## F. Real professional availability management

### APP-P1-006 - Complete Appointment Experience And Professional Schedule - DONE

- **Purpose:** Complete the role-aware appointment list/detail lifecycle and mature
  `selectedDates` into the backend-owned professional Schedule in one coherent milestone.
- **Implemented behavior:** The authenticated own-list is grouped deterministically;
  exact IDs open canonical detail; patient/professional action visibility is centralized;
  mutations serialize, wait for backend confirmation, and reload authority; reschedule
  uses backend-generated requestable times at 30 minutes. Professional Schedule reads and
  atomically replaces recurring `/availability/me` windows with weekday `0..6`, IANA
  timezone, interval, overlap, role, refresh, and mutation safeguards.
- **Tests:** Role/status/time action mapping; exact-ID detail; list ordering; unknown-role
  closure; refresh retention; 409 conflict; backend-only reschedule; Home handoff;
  Sunday mapping; availability validation/replacement/reconciliation; navigation,
  booking, and prior lifecycle regressions.
- **Risks carried forward:** No single appointment-detail endpoint or participant display
  names; no reason/audit-history presentation; advanced availability exceptions remain
  absent.
- **Contract:** `PHASE_1_APPOINTMENT_EXPERIENCE.md`.
- **Non-goals:** Messaging, calls, payment/refund/payout, notification delivery,
  no-show/dispute, notes, prescriptions, blocked dates, calendar sync.

## G. Appointment lifecycle polish

### MSG-P1-007 - Mature Appointment-Linked Messaging - COMPLETE

- **Purpose:** Deliver backend-authoritative appointment conversations for both roles.
- **Behavior:** Messages lists stable activity ordering and unread data; typed threads use
  HTTP history plus body-free WebSocket hints; optimistic retries retain one client ID;
  Seen/read state, lifecycle read-only behavior, app-resume recovery, and account-change
  privacy are enforced.
- **Contract:** `PHASE_1_APPOINTMENT_MESSAGING.md`.
- **Non-goals retained:** Push, attachments, calls/RTC, payments, rich chat, retention
  automation, medical-record classification, and broad source cleanup.

### PAY-P1-008 - Paid Consultation Financial Authority And Experience - COMPLETE

- **Purpose:** Close the patient-payment-to-held-earning-to-payout loop without
  moving money authority into Flutter.
- **Behavior:** Backend owns immutable NGN pricing, 15 percent commission, Paystack
  verification, refunds/reversals, ledger, 72-hour earning hold, bank cooling, and
  payout execution/reconciliation. Flutter displays exact price/payment state,
  opens strict hosted checkout with durable retry identity, refreshes backend
  authority on resume, and gives professionals price, bank, balance, ledger, and
  payout-history controls.
- **Contract:** `PHASE_1_FINANCIAL_EXPERIENCE.md`.
- **Non-goals retained:** Stored cards, instant withdrawal, split settlement,
  partial or patient-initiated refunds, second live provider, calls/RTC,
  notification delivery, and unrelated product cleanup.

## H. Patient and professional profile cleanup

### APP-P1-009 - Patient Profile And Account Authority Cleanup

- **Purpose:** Make patient Profile/account use backend identity/profile data and hide
  unsupported local-only security/account mutations.
- **Likely files:** `account_shell.dart`, `account_local_store.dart` consumers,
  settings/security route callers, profile/account tests/docs.
- **Expected behavior:** Real patient/account reads and supported updates work; logout and
  recovery remain; unsupported email/phone/PIN/password/deactivation drafts are not exposed.
- **Tests:** Read/update/logout, loading/empty/error/session, unsupported action absence,
  local store not treated as server truth.
- **Risks:** Removing a real recovery route, mixing auth user and patient profile fields.
- **Stop:** Destructive account behavior lacks backend authority/audit confirmation.
- **Non-goals:** Add MFA/OTP/change-email APIs, dual role, new backend modules.

### APP-P1-010 - Professional Profile And Verification Cleanup

- **Purpose:** Keep professional public identity, practice details, verification, and
  availability handoffs while removing creator portfolio/content concepts.
- **Likely files:** `manage_profile_shell.dart`, supported edit screens,
  `public_profile_local_store.dart` consumers, verification shell, profile tests/docs.
- **Expected behavior:** Backend professional data is authoritative; bio/category/specialty/
  supported practice fields update honestly; verification status/documents remain; no
  Articles/Circles/Boost/Podcast/Upgrade portfolio controls.
- **Tests:** Profile read/update, required backend fields preserved, verification status,
  rejected/pending/verified states, no creator/local profile authority.
- **Risks:** Overwriting required professional fields during partial updates, exposing
  unverified professionals, deleting shared profile widgets too early.
- **Stop:** A desired field is absent from the approved backend profile DTO or needs
  regulator/compliance rules not already defined.
- **Non-goals:** Portfolio, articles, reviews, earnings/payouts, website unless approved.

## I. Deferred-feature dead-code and dependency cleanup

### APP-P1-011 - Remove Deferred Routes And Exclusive Feature Code

- **Purpose:** After retained paths pass, delete no-longer-routed deferred/obsolete
  pages, local stores, exclusive models/widgets, and their exclusive tests.
- **Likely files:** Router/route names, deferred Home/Onboarding pages/state/widgets,
  deferred tests, docs.
- **Expected behavior:** Phase 1 retained paths are unchanged; no hidden speculative modules
  remain in the active mainline; archive/history remains the recovery source.
- **Tests:** `rg` no retained imports/callers, router parity, full retained test suite,
  analyze, Android debug build.
- **Risks:** Shared widget/model deletion, route string left in a notification/caller,
  removing newer onboarding instead of obsolete chain.
- **Stop:** Any candidate has a retained consumer or ambiguous ownership; move/classify it
  in a separate slice before deletion.
- **Non-goals:** Visual redesign, backend changes, payment/messaging/call implementation.

### APP-P1-012 - Remove Unused Assets Packages And Retired Tests

- **Purpose:** Remove only dependencies proven exclusive or unused after source cleanup.
- **Likely files:** `pubspec.yaml`, lockfile, assets, generated plugin registrants when
  regenerated by Flutter, test inventory, dependency docs.
- **Expected behavior:** Smaller dependency/asset surface with identical retained behavior.
- **Tests:** `flutter pub get`, asset/package usage scan, full retained tests,
  `flutter analyze lib test`, Android debug build; inspect generated platform diff.
- **Risks:** Removing build-time packages/assets, generated platform churn, false unused result.
- **Stop:** Package ownership is unclear or platform build cannot be verified.
- **Non-goals:** Package upgrades, Flutter upgrade, platform redesign, release signing.

## J. Full physical-phone Phase 1 regression proof

### APP-P1-013 - Phase 1 Phone Regression Plan And Test Data Contract

- **Purpose:** Freeze exact accounts, data, routes, expected states, and evidence before
  touching a phone.
- **Likely files:** Regression plan/checklist docs and test fixture documentation only.
- **Expected behavior:** No runtime change; every test step names backend prerequisite,
  role, expected result, failure result, and privacy-safe evidence.
- **Tests:** Docs validation and staging endpoint readiness checks if authorized.
- **Risks:** Calling a partial current-core smoke a full Phase 1 revenue-loop proof.
- **Stop:** Payment, consultation, support, refund, or notification contracts
  required by the claimed proof remain unresolved.
- **Non-goals:** Create fake accounts/data without approval, staging deployment, runtime fixes.

### APP-P1-014 - Physical-Phone Phase 1 Regression Execution

- **Purpose:** Prove the approved, implemented Phase 1 path on a staging-configured Android
  build and record exact passes, failures, logs, and follow-up fix slices.
- **Likely files:** Evidence/checkpoint docs; runtime files only in separately approved fix slices.
- **Expected behavior:** Auth/session, both onboarding roles, verification/readiness, Find Care,
  availability, appointment request and lifecycle, Profile, and all implemented Phase 1
  modules work on device without fake fallback. Full revenue-loop wording is allowed only
  after the unresolved modules are implemented and included.
- **Tests:** Clean install, email and Google auth, session restore, patient/pro setup,
  verification, discovery, availability, request, professional actions, reschedule/cancel/
  complete, offline/session-expiry/server-error checks, privacy-safe log review.
- **Risks:** Using stale APK/config/data, testing only happy path, recording credentials,
  treating seeded/static data as production behavior.
- **Stop:** Any blocker appears; capture exact logs and create a focused fix slice. Do not
  patch multiple problems inside the smoke slice.
- **Non-goals:** Production-readiness claim, Play Store release, unresolved payment/
  call/support behavior, opportunistic UI redesign.

## Interlock before full Phase 1 completion

The A-J plan can fully narrow and prove the existing backend-supported core.
Appointment-linked plain-text messaging and paid-consultation financial
authority are implemented. `CALL-P1-009` implements the approved external-RTC
consultation boundary. `NOTIF-P1-010` implements durable transactional inbox,
reminder, push, and critical-email authority. Broader support operations,
dual-role accounts, marketing communication, and profile/deferred-source cleanup
remain separate.

Those lanes must be selected deliberately after the current-core narrowing. They
are not automatically inserted into this plan and are not silently treated as done.

## Next runtime selection

No later capability starts automatically after `NOTIF-P1-010`. The project lead
must select and approve the next Phase 1 launch gate. Profile cleanup,
retention/privacy policy, and deferred-source cleanup remain separate milestones.

## CALL-P1-009 - Appointment-linked consultations

Status: implementation and local verification complete pending CI, provider
staging proof, and merge.

The backend owns paid appointment eligibility, waiting/admission, timing,
one-device policy, room authority, attendance, incidents, reconciliation, and
completion evidence. Flutter owns an appointment-linked prejoin, waiting, and
active VIDEO/AUDIO experience through the official LiveKit SDK. No Calls tab,
custom WebRTC transport, recording, transcription, automatic refund, or
automatic completion was added.

Canonical contract: `PHASE_1_APPOINTMENT_CONSULTATIONS.md`.

## NOTIF-P1-010 - Durable transactional notifications

Status: backend and Flutter implementation complete on dedicated milestone
branches. Staging/provider and physical Android foreground/background/terminated
proof are complete; final CI, adversarial review, and merge remain before final
completion is claimed.

The backend owns event authority, recipient resolution, durable inbox,
preferences, reminder planning, provider-neutral delivery state, retries,
Firebase Admin push, Resend email, and signed email webhooks. Flutter owns secure
installation registration, contextual permission, inbox/read state, unread badge,
preference controls, foreground/background/terminated receipt, and owner-checked
allowlisted route resolution. Provider payloads are generic and destination
screens reload current CareNet state.

Canonical mobile contract: `PHASE_1_TRANSACTIONAL_NOTIFICATIONS.md`.

No later capability is selected automatically after this milestone.
