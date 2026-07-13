# Documentation sync index

**Last audited:** 2026-05-27
**Purpose:** Single place to see which doc is authoritative for what, and known cross-doc rules.

---

## Authority (if two docs seem to conflict)

| Topic | Authoritative doc |
|-------|-------------------|
| What to do **right now** | `AI_HANDOFF.md` (task marked **NEXT**) |
| Strict completion rules | `WORKING_AGREEMENT.md` + `DEFINITION_OF_DONE.md` |
| Navigation between screens | `FLOW_MAP.md` |
| Route name to Dart file | `ROUTES.md` + `lib/.../router.dart` |
| What code **actually** does today | `CODEBASE_STATUS.md` |
| Deferred backend/local replacement seams | `DEFERRED_WORK.md` |
| Architecture, folder, state, and testing rules | `ARCHITECTURE_RULES.md` |
| Required implementation task shape | `TASK_TEMPLATE.md` |
| Your answers (auth, API, etc.) | `DECISIONS.md` |
| Figma export facts | `BLUEPRINT_OVERVIEW.md` |
| Phase order (big picture) | `PROJECT_PLAN.md` |
| Reusable widgets / tokens | `COMPONENTS.md` |

**Rule:** `WORKING_AGREEMENT` wins over older lenient wording elsewhere.

---

## Current project state (synced)

| Item | Value |
|------|--------|
| Process guardrails | **0.5 complete** - `ARCHITECTURE_RULES.md` and `TASK_TEMPLATE.md` added |
| Phase 0 | **Complete** |
| Phase 1 | **Complete** |
| Phase 2 | **Complete** |
| Phase 3 | **Complete** |
| Phase 4 | **Complete** |
| Phase 5 | **Complete** |
| Phase 6 | **Complete** |
| Phase 10 | **Complete** |
| Phase 11 | **Complete** |
| Phase 12 | **Complete** |
| Phase 13 | **Complete** |
| Phase 14 | **Complete** |
| Phase 15 | **Complete** |
| Phase 16 | **Complete** |
| Phase 17 | **Complete** |
| Phase 18 | **Complete** |
| Phase 19 | **Complete** |
| Phase 20 | **Complete** |
| Phase 21 | **Complete** |
| Phase 22 | **In progress** |
| NEXT task | **52.24** - add profile repository boundary before runtime screen wiring |
| Last completed | **52.23** - profile/public professional wiring contract defined |
| Registered routes | **70 wired routes** plus the reserved unused `login` constant (see `ROUTES.md`) |
| Pre-existing stubs | `CODEBASE_STATUS.md` - fix only in the phase column listed |

---

## Intentional "not contradictions"

| Looks like a conflict | Resolution |
|------------------------|------------|
| Code has `Placeholder()` but WORKING_AGREEMENT forbids it | Stubs are **allowed in repo** until their phase task; a **new** task must not mark DONE while adding placeholders in its scope |
| Sign-up entry screens use shared components, but `finishSignUp` still uses legacy input/button wrappers | Phase 2 fixed behavior first; shared-component adoption on `finishSignUp` is design debt, not a broken flow |
| Phase 1 is done but Flow A is not | Phase 1 was design-system + screen adoption; Flow A logic belongs to Phase 2 |
| UI "close enough" vs exact Figma | `WORKING_AGREEMENT` priority #4 - function first |

---

## Paste block (canonical - all docs should match this)

```text
Project: C:\Users\asd\Music\Mobile-App-master
Blueprint: C:\Users\asd\Music\project-blueprint\project-blueprint\

Read docs/WORKING_AGREEMENT.md (mandatory).
Read docs/ARCHITECTURE_RULES.md and docs/TASK_TEMPLATE.md before coding.
Read docs/README.md, then docs/AI_HANDOFF.md - complete ONLY the task marked NEXT.
Follow docs/FLOW_MAP.md, docs/ROUTES.md, docs/DEFINITION_OF_DONE.md.
Context: docs/BLUEPRINT_OVERVIEW.md, docs/CODEBASE_STATUS.md, docs/DECISIONS.md.
Do not use old chat history. Do not start the next task without my approval.
```

---

## When you change the project, update these

| Change | Update |
|--------|--------|
| Finished a task | `AI_HANDOFF.md`, `DOC_SYNC.md`, `CODEBASE_STATUS.md`, `DEFERRED_WORK.md` (if backend/local seams changed), `COMPONENTS.md` (as needed) |
| Starting an implementation task | Use `TASK_TEMPLATE.md` fields in `AI_HANDOFF.md` |
| New route | `ROUTES.md`, `router.dart`, `FLOW_MAP.md` if flow changed |
| User decided auth/API | `DECISIONS.md` |
| New phase complete | `PROJECT_PLAN.md`, `AI_HANDOFF.md`, this file's "Current project state" |

---

## Audit log

| Date | Fixes |
|------|--------|
| 2026-05-19 | Task 4.3 DONE - notifications icon + messages handoff; DOC_SYNC NEXT -> 5.1 |
| 2026-05-19 | Task 5.1 DONE - dashboard notifications tab now uses the dedicated notifications feature screen; DOC_SYNC NEXT -> 5.2 |
| 2026-05-19 | Task 5.2 DONE - messages list routes into chat; fake notifications bottom nav removed; DOC_SYNC NEXT -> 5.3 |
| 2026-05-19 | Task 5.3 DONE - actionable notification cards route only to real destinations; DOC_SYNC NEXT -> 5.4 |
| 2026-05-19 | Task 5.4 DONE - notification category tabs now use real filters and disabled Payment state; DOC_SYNC NEXT -> 5.5 |
| 2026-05-19 | Task 5.5 DONE - duplicate chat/message screens consolidated into one canonical route structure; DOC_SYNC NEXT -> 5.6 |
| 2026-05-19 | Task 5.6 DONE - appointments/readings notification cards now route to honest destinations; DOC_SYNC NEXT -> 5.7 |
| 2026-05-19 | Task 5.7 DONE - article notifications now route to an articles destination shell; DOC_SYNC NEXT -> 5.8 |
| 2026-05-19 | Task 5.8 DONE - emergency notifications now route to an emergency destination shell; DOC_SYNC NEXT -> 5.9 |
| 2026-05-19 | Task 5.9 DONE - podcast notifications intentionally deferred; DOC_SYNC NEXT -> 6.1 |
| 2026-05-19 | Task 6.1 DONE - readings now routes to manageReadings; DOC_SYNC NEXT -> 6.2 |
| 2026-05-19 | Task 6.2 DONE - readings export explicitly deferred; DOC_SYNC NEXT -> 6.3 |
| 2026-05-19 | Task 6.3 DONE - first guided readings lane wired through addDevice -> bloodSug; DOC_SYNC NEXT -> 6.4 |
| 2026-05-19 | Task 6.4 DONE - bloodSug local entry form + saved-state summary; DOC_SYNC NEXT -> 6.5 |
| 2026-05-23 | Task 6.5 DONE - saved blood sugar entry now syncs back to readings dashboard; DOC_SYNC NEXT -> 6.6 |
| 2026-05-23 | Task 6.6 DONE - bloodSug history + trend summary; DOC_SYNC NEXT -> 6.7 |
| 2026-05-23 | Task 6.7 DONE - bloodSug history delete behavior; DOC_SYNC NEXT -> 7.1 |
| 2026-05-23 | Task 7.1 DONE - appointments real slice + bookAppointment handoff; DOC_SYNC NEXT -> 7.2 |
| 2026-05-23 | Task 7.2 DONE - bookAppointment local form + saved draft summary; DOC_SYNC NEXT -> 7.3 |
| 2026-05-23 | Task 7.3 DONE - bookAppointment draft confirm/cancel behavior; DOC_SYNC NEXT -> 8.1 |
| 2026-05-23 | Task 8.1 DONE - emergency real slice + distressCall form; DOC_SYNC NEXT -> 8.2 |
| 2026-05-23 | Task 8.2 DONE - distress local dispatch/clear step; DOC_SYNC NEXT -> 9.1 |
| 2026-05-23 | Task 9.1 DONE - articles local list/detail reader flow; DOC_SYNC NEXT -> 9.2 |
| 2026-05-23 | Task 9.2 DONE - articles local read/saved state; DOC_SYNC NEXT -> 9.3 |
| 2026-05-23 | Task 9.3 DONE - articles scope boundary documented; DOC_SYNC NEXT -> 10.1 |
| 2026-05-23 | Task 10.1 DONE - communities local circles/discover/join slice; DOC_SYNC NEXT -> 10.2 |
| 2026-05-27 | Task 10.2 DONE - communities joined-state sync back to Circles; DOC_SYNC NEXT -> 10.3 |
| 2026-05-27 | Task 10.3 DONE - communities local profile route added from Circles; DOC_SYNC NEXT -> 10.4 |
| 2026-05-27 | Task 10.4 DONE - communities local create flow added with owner-profile handoff; DOC_SYNC NEXT -> 10.5 |
| 2026-05-27 | Task 10.5 DONE - communities scope boundary documented; DOC_SYNC NEXT -> 11.1 |
| 2026-05-27 | Task 11.1 DONE - Post tab now hosts the first real local Q&A feed and ask flow; DOC_SYNC NEXT -> 11.2 |
| 2026-05-27 | Task 11.2 DONE - Q&A answer requests, tagged questions, and comment/answer flow added; DOC_SYNC NEXT -> 11.3 |
| 2026-05-27 | Task 11.3 DONE - Q&A scope boundary documented before `q-a-post`; DOC_SYNC NEXT -> 12.1 |
| 2026-05-27 | Task 12.1 DONE - drawer Profile now routes into a real local Account slice; DOC_SYNC NEXT -> 12.2 |
| 2026-05-27 | Task 12.2 DONE - Settings & Profile local edit form added under Account; DOC_SYNC NEXT -> 12.3 |
| 2026-05-27 | Task 12.3 DONE - account scope boundary documented; DOC_SYNC NEXT -> 13.1 |
| 2026-05-27 | Task 13.1 DONE - podcast notification now routes to a real local podcast list with watch state; DOC_SYNC NEXT -> 13.2 |
| 2026-05-27 | Task 13.2 DONE - podcast scope boundary documented before media/upload/comment/backend workflows; DOC_SYNC NEXT -> 14.1 |
| 2026-05-27 | Task 14.1 DONE - Search tab now has local consultant discovery with filters, profile sheet, and local request state; DOC_SYNC NEXT -> 14.2 |
| 2026-05-27 | Task 14.2 DONE - search scope boundary documented before live availability/payment/booking/provider-profile workflows; DOC_SYNC NEXT -> 15.1 |
| 2026-05-27 | Task 15.1 DONE - Health Record route added with local vitals summary and readings-store blood sugar value; DOC_SYNC NEXT -> 15.2 |
| 2026-05-27 | Task 15.2 DONE - health record scope boundary documented before backend history/export/synced-vital workflows; DOC_SYNC NEXT -> 16.1 |
| 2026-05-27 | Task 16.1 DONE - Saved Articles route added with shared local article store empty/list/detail/remove behavior; DOC_SYNC NEXT -> 16.2 |
| 2026-05-30 | Task 16.2 DONE - saved/content-library scope boundary documented before creator/content backend workflows; DOC_SYNC NEXT -> 17.1 |
| 2026-05-30 | Task 17.1 DONE - Case Studies route added with local list/filter/detail/read-state behavior; DOC_SYNC NEXT -> 17.2 |
| 2026-05-30 | Task 17.2 DONE - case studies scope boundary documented before content API/comment/sharing/account-sync workflows; DOC_SYNC NEXT -> 18.1 |
| 2026-05-30 | Task 18.1 DONE - Public Profile route added with local read-only profile content and real message/schedule handoffs; DOC_SYNC NEXT -> 18.2 |
| 2026-05-30 | Task 18.2 DONE - public profile scope boundary documented before profile API/portfolio/media/share/scheduling workflows; DOC_SYNC NEXT -> 19.1 |
| 2026-05-30 | Task 19.1 DONE - Owner Circle Profile route added with local owner content and locked/deferred owner settings; DOC_SYNC NEXT -> 19.2 |
| 2026-05-30 | Task 19.2 DONE - owner-circle scope boundary documented before permissions/invites/moderation/destructive community APIs; DOC_SYNC NEXT -> 20.1 |
| 2026-05-30 | Task 20.1 DONE - Manage Profile route added with profile-management sections and settings/messages handoffs; DOC_SYNC NEXT -> 20.2 |
| 2026-05-30 | Task 20.2 DONE - manage-profile scope boundary and backend replacement contract documented; DOC_SYNC NEXT -> 21.1 |
| 2026-06-03 | Task 21.1 DONE - Manage Portfolio route added with local Page/Circles portfolio content, settings/messages handoffs, and disabled creator/media/payment controls; DOC_SYNC NEXT -> 21.2 |
| 2026-06-03 | Task 21.2 DONE - manage-portfolio scope boundary documented before creator publishing/media/payment/subscription workflows; DOC_SYNC NEXT -> 22.1 |
| 2026-06-03 | Task 22.1 DONE - Change Authentication route added with local two-step verification copy and locked/deferred security actions; DOC_SYNC NEXT -> 22.2 |
| 2026-06-03 | Task 22.2 DONE - change-authentication scope boundary documented before PIN/security/auth-backend workflows; DOC_SYNC NEXT -> 23.1 |
| 2026-06-03 | Task 23.1 DONE - Add Phone Number route added with local validation and ready-for-SMS-verification draft; DOC_SYNC NEXT -> 23.2 |
| 2026-06-03 | Task 23.2 DONE - add-phone-number scope boundary documented before OTP/SMS/code/auth-session workflows; DOC_SYNC NEXT -> 24.1 |
| 2026-06-03 | Task 24.1 DONE - Password route added with local security copy and locked/deferred Edit password action; DOC_SYNC NEXT -> 24.2 |
| 2026-06-03 | Task 24.2 DONE - password scope boundary documented before password-change/auth-backend workflows; DOC_SYNC NEXT -> 25.1 |
| 2026-06-03 | Task 25.1 DONE - Add Email route added with local validation and ready-for-email-verification draft; DOC_SYNC NEXT -> 25.2 |
| 2026-06-03 | Task 25.2 DONE - add-email scope boundary documented before verification/code/auth-session workflows; DOC_SYNC NEXT -> 26.1 |
| 2026-06-03 | Task 26.1 DONE - Change Email route added with local validation and ready-for-code-verification draft; DOC_SYNC NEXT -> 26.2 |
| 2026-06-03 | Task 26.2 DONE - change-email scope boundary documented before verification-code/auth-session workflows; DOC_SYNC NEXT -> 27.1 |
| 2026-06-03 | Task 27.1 DONE - Edit Email route added with verified current email, change-email handoff, and locked remove-email action; DOC_SYNC NEXT -> 27.2 |
| 2026-06-03 | Task 27.2 DONE - edit-email scope boundary documented before email removal/re-auth/account-persistence workflows; DOC_SYNC NEXT -> 28.1 |
| 2026-06-03 | Task 28.1 DONE - Enter Password To Save route added with local password validation and ready-for-backend-reauthentication draft; DOC_SYNC NEXT -> 28.2 |
| 2026-06-03 | Task 28.2 DONE - enter-password-to-save scope boundary documented before real password verification/session/audit/account-persistence workflows; DOC_SYNC NEXT -> 29.1 |
| 2026-06-03 | Task 29.1 DONE - Confirm Phone Number route added with local validation and ready-for-backend-OTP-verification state; DOC_SYNC NEXT -> 29.2 |
| 2026-06-03 | Task 29.2 DONE - confirm-phone-number scope boundary documented before OTP/code/session/account-persistence workflows; DOC_SYNC NEXT -> 30.1 |
| 2026-06-03 | Task 30.1 DONE - Turn On Authentication route added with local review copy and disabled backend-gated Turn on action; DOC_SYNC NEXT -> 30.2 |
| 2026-06-03 | Task 30.2 DONE - turn-on-authentication scope boundary documented before PIN/session/audit/account-persistence workflows; DOC_SYNC NEXT -> 31.1 |
| 2026-06-03 | Task 31.1 DONE - Create PIN route added with local PIN-format validation and no secure-storage/session mutation; DOC_SYNC NEXT -> 31.2 |
| 2026-06-03 | Task 31.2 DONE - create-pin scope boundary documented before PIN confirmation/storage/session/account-persistence workflows; DOC_SYNC NEXT -> 32.1 |
| 2026-06-08 | Task 32.1 DONE - Confirm PIN Save route added with route-local confirmation validation and no secure-storage/session mutation; DOC_SYNC NEXT -> 32.2 |
| 2026-06-08 | Task 32.2 DONE - confirm-pin-save scope boundary documented before secure storage/session/audit/account-persistence workflows; DOC_SYNC NEXT -> 33.1 |
| 2026-06-08 | Task 33.1 DONE - Reminder route added from Notifications with selectable calendar and honest date-specific empty state; DOC_SYNC NEXT -> 33.2 |
| 2026-06-08 | Task 33.2 DONE - reminder scope boundary documented before persistence/delivery/provider workflows; DOC_SYNC NEXT -> 34.1 |
| 2026-06-08 | Task 34.1 DONE - Schedules route added from the dashboard drawer with selectable calendar and expandable read-only task reminder; DOC_SYNC NEXT -> 34.2 |
| 2026-06-08 | Task 34.2 DONE - schedules scope boundary documented before CRUD/persistence/delivery/provider workflows; DOC_SYNC NEXT -> 35.1 |
| 2026-06-08 | Task 35.1 DONE - Selected Dates business-hours draft route added from Manage Profile with date/time validation and no fake persistence; DOC_SYNC NEXT -> 35.2 |
| 2026-06-08 | Task 35.2 DONE - selected-dates scope boundary documented before profile-hours persistence/product workflows; DOC_SYNC NEXT -> 36.1 |
| 2026-06-08 | Task 36.1 DONE - community invitations/discover tabs added to the existing discover route without duplicating community state; DOC_SYNC NEXT -> 36.2 |
| 2026-06-08 | Task 36.2 DONE - community-invitations-discover scope boundary documented before delivery/approval/moderation/backend workflows; DOC_SYNC NEXT -> 37.1 |
| 2026-06-08 | Task 37.1 DONE - Find Mentor route added from drawer Providers with local mentor cards and booking handoff; DOC_SYNC NEXT -> 37.2 |
| 2026-06-08 | Task 37.2 DONE - find-mentor scope boundary documented before live availability/profile/payment/booking-confirmation workflows; DOC_SYNC NEXT -> 38.1 |
| 2026-06-08 | Task 38.1 DONE - Specialist Details route added from Find Mentor with local provider info, day/time selection, and booking handoff; DOC_SYNC NEXT -> 38.2 |
| 2026-06-08 | Task 38.2 DONE - specialist-details scope boundary documented before live availability/reviews/payment/booking-confirmation workflows; DOC_SYNC NEXT -> 39.1 |
| 2026-06-08 | Task 39.1 DONE - remaining routes after specialist-details triaged; component/demo/marketing tail skipped and `/published-articles` selected next; DOC_SYNC NEXT -> 40.1 |
| 2026-06-08 | Task 40.1 DONE - Published Articles route added from Manage Portfolio with local article list/detail review and locked creator controls; DOC_SYNC NEXT -> 40.2 |
| 2026-06-08 | Task 40.2 DONE - published-articles scope documented before subscribers/article-story/add-new-article/drafts/analytics/comments/content APIs; DOC_SYNC NEXT -> 41.1 |
| 2026-06-08 | Task 41.1 DONE - remaining routes after creator/content cluster triaged; backend-heavy creator/payment/media routes skipped and `/edit-your-name` selected next; DOC_SYNC NEXT -> 42.1 |
| 2026-06-08 | Task 42.1 DONE - Edit Your Name route added from Manage Profile with local validation and draft-only no-persistence summary; DOC_SYNC NEXT -> 42.2 |
| 2026-06-08 | Task 42.2 DONE - edit-your-name scope documented before profile persistence/account sync/verification/audit/backend APIs; DOC_SYNC NEXT -> 43.1 |
| 2026-06-08 | Task 43.1 DONE - Edit Your Website route added from Manage Profile Basic with local URL validation and draft-only no-persistence summary; DOC_SYNC NEXT -> 43.2 |
| 2026-06-08 | Task 43.2 DONE - edit-your-website scope documented before profile persistence/verification/account sync/audit/backend APIs; DOC_SYNC NEXT -> 44.1 |
| 2026-06-08 | Task 44.1 DONE - Add Description route added from Manage Profile About with reusable multiline input, local validation, and draft-only no-persistence summary; DOC_SYNC NEXT -> 44.2 |
| 2026-06-09 | Task 44.2 DONE - add-description scope documented before profile-copy persistence/moderation/publishing/account-sync/backend APIs; DOC_SYNC NEXT -> 45.1 |
| 2026-06-09 | Task 45.1 DONE - remaining Manage Profile routes triaged; account/email and scheduling duplicates skipped, `/set-address` selected next; DOC_SYNC NEXT -> 46.1 |
| 2026-06-09 | Task 46.1 DONE - Set Address route added from Manage Profile Basic with local address validation and draft-only no-persistence summary; DOC_SYNC NEXT -> 46.2 |
| 2026-06-09 | Task 46.2 DONE - set-address scope documented before profile-address persistence/location services/maps/account-sync/backend APIs; DOC_SYNC NEXT -> 47.1 |
| 2026-06-09 | Task 47.1 DONE - remaining blueprint tail triaged; backend-heavy/duplicate/design routes skipped and frontend coverage audit queued; DOC_SYNC NEXT -> 48.1 |
| 2026-06-09 | Task 48.1 DONE - frontend coverage audit found no remaining honest frontend-only route gaps; DOC_SYNC NEXT -> 49.1 |
| 2026-06-09 | Task 49.1 DONE - backend/product readiness handoff grouped deferred seams by contract and replacement path; DOC_SYNC NEXT -> 50.1 |
| 2026-06-09 | Task 50.1 DONE - final frontend handoff review completed; route coverage ready for backend/product contract selection; DOC_SYNC NEXT -> 51.1 |
| 2026-06-09 | Task 51.1 DONE - first backend/product contract group selected: auth/session/account persistence; DOC_SYNC NEXT -> 51.2 |
| 2026-07-13 | Task 51.2 DONE - auth/session/account backend contract defined in `AUTH_SESSION_ACCOUNT_CONTRACT.md`; DOC_SYNC NEXT -> 52.1 |
| 2026-07-13 | Task 52.1 DONE - auth/session/account infrastructure boundary added with config, safe API client, session store, models, repositories, and focused tests; DOC_SYNC NEXT -> 52.2 |
| 2026-07-13 | Task 52.2 DONE - email sign-in now calls `AuthRepository.login` after local validation and keeps failure/loading states honest; DOC_SYNC NEXT -> 52.3 |
| 2026-07-13 | Task 52.3 DONE - email sign-up completion now calls `AuthRepository.register` after local validation and keeps failure/loading states honest; DOC_SYNC NEXT -> 52.4 |
| 2026-07-13 | Task 52.4 DONE - splash now restores stored sessions through `AuthRepository.restore` and routes usable sessions to dashboard while missing/invalid restore falls back to onboarding; DOC_SYNC NEXT -> 52.5 |
| 2026-07-13 | Task 52.5 DONE - Account logout now calls `AuthRepository.logout`, clears navigation to onboarding on success, and keeps delete/security/password flows deferred; DOC_SYNC NEXT -> 52.6 |
| 2026-07-13 | Task 52.6 DONE - password reset request now calls `AuthRepository.requestPasswordReset`; confirmation stops before fake success until a secure token/deep-link boundary exists; DOC_SYNC NEXT -> 52.7 |
| 2026-07-13 | Task 52.7 DONE - Account now reads `AccountRepository.currentAccount` for safe email/status display while keeping profile edits, deletion, and security mutations local/deferred; DOC_SYNC NEXT -> 52.8 |
| 2026-07-13 | Task 52.8 DONE - current-email verification request now calls `AccountRepository.requestEmailVerification`; confirmation remains blocked until secure token/deep-link/code handling exists; DOC_SYNC NEXT -> 52.9 |
| 2026-07-13 | Task 52.9 DONE - auth/session/account regression pass covered sign-in, sign-up, restore, logout, password reset request, current account read, and email verification request; DOC_SYNC NEXT -> 52.10 |
| 2026-07-13 | Task 52.10 DONE - selected workflow guardrail restoration as the next lane before more backend/account runtime wiring; DOC_SYNC NEXT -> 52.11 |
| 2026-07-14 | Task 52.11 DONE - restored `WORKING_AGREEMENT.md`, `TASK_TEMPLATE.md`, and `DEFINITION_OF_DONE.md`; DOC_SYNC NEXT -> 52.12 |
| 2026-07-14 | Task 52.12 DONE - selected a frontend/backend integration checkpoint before more runtime wiring; DOC_SYNC NEXT -> 52.13 |
| 2026-07-14 | Task 52.13 DONE - created frontend/backend integration checkpoint with completed wiring, blockers, and contract questions; DOC_SYNC NEXT -> 52.14 |
| 2026-07-14 | Task 52.14 DONE - selected password reset and email verification deep-link/code contract as the next target; DOC_SYNC NEXT -> 52.15 |
| 2026-07-14 | Task 52.15 DONE - defined password reset and email verification token-confirm contract from backend bridge docs; DOC_SYNC NEXT -> 52.16 |
| 2026-07-14 | Task 52.16 DONE - wired reset and email verification token-confirm routes; DOC_SYNC NEXT -> 52.17 |
| 2026-07-14 | Task 52.17 DONE - added completed backend surface wiring map and selected auth/account staging smoke/checkpoint as the next lane; DOC_SYNC NEXT -> 52.18 |
| 2026-07-14 | Task 52.18 DONE - recorded auth/account staging checkpoint with proxy health/readiness evidence and deferred Google/verification upload until provider readiness; DOC_SYNC NEXT -> 52.19 |
| 2026-07-14 | Task 52.19 DONE - replaced placeholder Android/iOS app identifiers with `com.carenet.app` and documented Google OAuth prerequisites; DOC_SYNC NEXT -> 52.20 |
| 2026-07-14 | Task 52.20 DONE - collected Google OAuth prerequisites and debug SHA fingerprints for `com.carenet.app`; DOC_SYNC NEXT -> 52.21 |
| 2026-07-14 | Task 52.21 DONE - enabled backend staging Google readiness through Secret Manager/Cloud Run and verified `googleAuth: ok`; DOC_SYNC NEXT -> 52.22 |
| 2026-07-14 | Task 52.22 DONE - wired Flutter Google Sign-In provider and sign-in Google rows with safe config/error/loading behavior; DOC_SYNC NEXT -> 52.23 |
| 2026-07-14 | Task 52.23 DONE - defined profile/public professional contract and queued repository boundary before screen wiring; DOC_SYNC NEXT -> 52.24 |
| 2026-05-19 | Task 4.2 DONE - Home inner tab content replaces placeholders; DOC_SYNC NEXT -> 4.3 |
| 2026-05-19 | Task 4.1 DONE - dashboard bottom-nav shell screens; DOC_SYNC NEXT -> 4.2 |
| 2026-05-19 | Task 3.2 DONE - password recovery flow + new auth routes; DOC_SYNC NEXT -> 4.1 |
| 2026-05-16 | Task 3.1 DONE - sign-in local validation + dashboard routing; DOC_SYNC NEXT -> 3.2 |
| 2026-05-15 | Task 2.4 DONE - sign-up "Already have an account? Sign in" routes to sign-in entry screens; DOC_SYNC NEXT -> 3.1 |
| 2026-05-15 | Task 2.3 DONE - sign-up social auth explicit disabled state; DOC_SYNC NEXT -> 2.4 |
| 2026-05-15 | Task 2.2 DONE - `finishSignUp` validation + route to `communityAgreement`; DOC_SYNC NEXT -> 2.3 |
| 2026-05-15 | Task 2.1 DONE - sign-up phone/email validation + route to `finishSignUp`; DOC_SYNC NEXT -> 2.2 |
| 2026-05-15 | Task 1.4 DONE - onboarding + sign-up phone/email now use shared button/text field components; DOC_SYNC NEXT -> 2.1 |
| 2026-05-15 | Task 1.3 DONE - `CarenetTextField`; DOC_SYNC NEXT -> 1.4 |
| 2026-05-15 | Reliability hardening docs added: `ARCHITECTURE_RULES.md`, `TASK_TEMPLATE.md`; paste block updated |
| 2026-05-15 | Route count 18->17; FLOW_MAP stub wording; PROJECT_PLAN Phase 4 clarified; WORKING_AGREEMENT paste aligned with README; COMPONENTS tokens section |
| 2026-05-15 | Task 1.1 DONE verified; DOC_SYNC NEXT -> 1.2 |
| 2026-05-15 | Task 1.2 DONE - `CarenetButton`; DOC_SYNC NEXT -> 1.3 |
