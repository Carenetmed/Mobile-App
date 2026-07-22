# Phase 1 Marketplace Implementation Plan

Slice family: `APP-P1`

Source decision: `PHASE_1_MARKETPLACE_BOUNDARY.md`

This plan narrows the Flutter app and matures backend-supported marketplace
paths. Appointment-linked text messaging and Appointment Detail video/audio
consultation are approved Phase 1 capabilities, but this plan does not silently
invent their runtime contracts. It also does not solve payment, support, refund,
payout, dual-role, or notification-provider contracts.

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

- **Purpose:** Replace the broad dashboard navigation with the approved patient
  and professional five-destination contracts and a header notification bell.
- **Likely files:** `dashboard.dart`, `drawer.dart`, `routeName.dart`, `router.dart`,
  `onboarding_readiness_route_resolver.dart`, `ROUTES.md`, `FLOW_MAP.md`, dashboard tests.
- **Expected behavior:** Patient tabs are Home/Find Care/Appointments/Messages/Profile;
  professional tabs are Home/Schedule/Appointments/Messages/Profile; the bell opens
  Notifications; Feed/Post/Circles/content/health/emergency/generic schedule routes
  are not reachable from active navigation. Patient setup exits to its approved
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

## D. Find Care consolidation

### APP-P1-004 - Canonical Find Care And Professional Detail

- **Purpose:** Make `search` the sole discovery entry and `specialistDetails` the
  sole professional detail, with no local professionals or duplicate mentor lane.
- **Likely files:** `search_shell.dart`, `specialist_details_shell.dart`,
  `find_mentor_shell.dart` callers only, `search_local_store.dart` callers,
  search/detail tests, routes/docs.
- **Expected behavior:** Backend verified professionals drive list and detail;
  selected professional id drives real public availability; backend failure yields
  safe error/empty state, never local fallback; `findMentor` is no longer active.
- **Tests:** Real repository list/detail/availability success, empty, failure, retry,
  invalid/missing id, no local fallback, canonical navigation.
- **Risks:** Backend currently lacks a dedicated detail endpoint; list-derived detail
  fields may be incomplete. Do not fabricate ratings, price, reviews, or credentials.
- **Stop:** A required public field is not in the backend contract or identity cannot
  be resolved safely.
- **Non-goals:** Reviews, ranking/recommendation engine, location search, payment,
  creator profiles, data schema changes.

## E. Real backend booking path

### APP-P1-005 - Remove Draft Booking And Enforce Real Slot Request

- **Purpose:** Eliminate the local `BookAppointmentShellPage` path and make every
  request originate from a backend professional and generated available time option.
- **Likely files:** `appointments_shell.dart`, `search_shell.dart`,
  `specialist_details_shell.dart`, `appointment_request_time_options.dart`,
  router/route names, scheduling tests/docs.
- **Expected behavior:** A patient selects a real slot, confirms the request, receives
  the backend appointment result, and can open it in Appointments. Failure cannot
  create local success. Duplicate submit is guarded in the UI and backend remains authority.
- **Tests:** Success, unavailable/conflict, unauthorized, wrong role, duplicate tap,
  network/server failure, no `Backend request not sent`, appointment list refresh.
- **Risks:** Confusing REQUESTED with paid/confirmed; stale availability; client timezone.
- **Stop:** Product copy requires payment/confirmation guarantees not present in the
  current backend, or request needs new fields/endpoints.
- **Non-goals:** Payment, calendar sync, notification sending, refund/cancellation redesign.

## F. Real professional availability management

### APP-P1-006 - Professional Schedule From Backend Availability

- **Purpose:** Turn `selectedDates` into the professional Schedule destination and
  remove route-local prepared-hours behavior as authority.
- **Likely files:** `selected_dates_shell.dart`, `manage_profile_shell.dart`,
  dashboard shell mapping, scheduling repository tests and availability widget tests.
- **Expected behavior:** Assigned professional reads and replaces own weekly availability,
  with timezone/validation and safe conflict/error handling already supported by the
  contract. Patient/public views reflect the backend result.
- **Tests:** Read/empty/replace/error/unauthorized, invalid overlap/order, preserved
  untouched weekdays, role guard, cross-screen refresh.
- **Risks:** Accidental destructive replacement, timezone display mismatch, local state
  diverging after failed save.
- **Stop:** One-off overrides, blocked dates, external calendar sync, or unsupported
  recurrence rules become necessary.
- **Non-goals:** Google/Apple calendar, reminders, events, generic schedules, upgrades.

## G. Appointment lifecycle polish

### APP-P1-007 - Role-Aware Appointment List And Detail

- **Purpose:** Separate list/detail responsibilities and present backend appointment
  status/actions clearly for each role without changing the state machine.
- **Likely files:** `appointments_shell.dart`, optional focused appointment-detail
  page/component, route arguments/router, appointment tests/docs.
- **Expected behavior:** Patient and professional see only own appointments; each status
  exposes only backend-valid actions; details show professional/patient, schedule,
  status, and safe failure/retry state. Appointment Detail reserves the product
  ownership points for appointment Messages and Join Consultation without
  implementing either transport in this slice.
- **Tests:** Both roles; requested/accepted/declined/cancelled/completed; wrong role/owner;
  missing appointment; terminal-state action absence; list-to-detail navigation.
- **Risks:** Leaking private party fields, enabling invalid actions, duplicating server state.
- **Stop:** Detail requires medical notes, payment, messaging, call, or admin data that
  is not in the contract.
- **Non-goals:** New appointment status, notes, prescriptions, reviews, admin override.

### APP-P1-008 - Appointment Lifecycle Interaction Regression

- **Purpose:** Harden accept/decline/cancel/reschedule/complete interactions after the
  presentation cleanup.
- **Likely files:** Appointment UI and existing scheduling regression tests; no schema work.
- **Expected behavior:** Buttons disable while submitting, backend result refreshes the
  screen, terminal states remain terminal, and errors are safe and recoverable.
- **Tests:** Every allowed and denied transition, duplicate taps, stale conflict,
  premature completion, reschedule conflict, cancellation, session expiry.
- **Risks:** Old widget tests passing while cross-screen state is stale.
- **Stop:** Any fix requires a backend state-machine change; record a backend fix slice.
- **Non-goals:** New lifecycle routes/states, payment/refund logic, notifications.

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
- **Stop:** Payment, messaging, consultation, support, refund, or notification contracts
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
- **Non-goals:** Production-readiness claim, Play Store release, unresolved payment/message/
  call/support behavior, opportunistic UI redesign.

## Interlock before full Phase 1 completion

The A-J plan can fully narrow and prove the existing backend-supported core. It
cannot complete the stated revenue loop until separate project-lead decisions and
backend/frontend slices implement payment, appointment-linked messaging,
external-RTC consultation join, notification delivery, support/refund, and
possibly dual-role accounts. Messaging and consultation are approved Phase 1
scope; only their detailed implementation contracts remain unresolved.

Those lanes must be selected deliberately after the current-core narrowing. They
are not automatically inserted into this plan and are not silently treated as done.

## Exactly one next runtime slice

After `APP-P1-001A` archive refs are approved and verified, start only:

`APP-P1-002 - Role-Aware Phase 1 Navigation Shell And Active Route Pruning`

Do not start Home, Find Care, booking, profile, cleanup, or phone regression in
the same slice.
