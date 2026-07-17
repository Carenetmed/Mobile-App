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
| NEXT task | **53.2** - execute staging seed data and mobile smoke pass |
| Last completed | **53.1** - staging seed data and smoke execution plan |
| Current checkpoint | **53.2 partial** - staging gateway Android APK builds, installs on phone, launches after native entrypoint package fix, has backend seed/lifecycle proof, patient-device proof through real Search/public availability/appointment request plus own-list rendering, and professional-device proof through role-aware appointment accept/decline/reschedule plus terminal-row behavior; Android backup is disabled, own-list parses the backend `appointments` envelope, secure session writes are ordered, and professional Account now exposes Manage Profile/Verification documents. Verification upload route access is proven, but upload-init returns staging HTTP 500; separate appointment-detail, optional fresh completion, successful upload after backend fix, and cleanup phone smoke remain open |
| Product interruption | **APP-58** - patient/professional onboarding UI requirements accepted against backend `CAR-BE-119`; next runtime work should expand Flutter profile models/repository before building polished setup screens |
| Registered routes | **73 wired routes** plus the reserved unused `login` constant (see `ROUTES.md`) |
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
| 2026-07-15 | Task 52.75 DONE - accepted the professional verification upload/list boundary with Manage Profile entry, owner list/status plus controlled upload flow, private-document rules, and repository-boundary next; DOC_SYNC NEXT -> 52.76 |
| 2026-07-15 | Task 52.76 DONE - added the professional verification repository/API boundary for owner document list, upload-init, internal signed upload PUT, upload-complete, safe metadata, bearer auth, and focused tests; DOC_SYNC NEXT -> 52.77 |
| 2026-07-15 | Task 52.77 DONE - Manage Profile now opens a backend-backed professional verification documents shell with safe owner list/status, empty/error states, private-data non-exposure, and upload deferred pending file-picker boundary; DOC_SYNC NEXT -> 52.78 |
| 2026-07-15 | Task 52.78 DONE - selected a PDF-capable file picker boundary for the professional verification upload flow, keeping runtime upload/package changes deferred to 52.79; DOC_SYNC NEXT -> 52.79 |
| 2026-07-15 | Task 52.79 DONE - wired professional verification upload with file picker, document type selection, PDF/JPEG/PNG plus 10 MB validation, safe states, repository upload call, and list reload; DOC_SYNC NEXT -> 52.80 |
| 2026-07-15 | Task 52.80 DONE - professional verification upload regression passed for owner list states, upload success/reload, picker cancellation, invalid file type, 10 MB guard, safe backend failure, and private-data non-exposure; DOC_SYNC NEXT -> 52.81 |
| 2026-07-15 | Task 52.81 DONE - selected professional basic profile field editing as the next backend-completed Flutter surface and required a boundary decision before runtime displayName/category/specialty wiring; DOC_SYNC NEXT -> 52.82 |
| 2026-07-15 | Task 52.82 DONE - accepted a display-name-only professional edit boundary for `editYourName`, preserving existing category/specialty/bio and deferring profile creation plus broader profile fields; DOC_SYNC NEXT -> 52.83 |
| 2026-07-15 | Task 52.83 DONE - wired `editYourName` to update backend professional displayName only, preserve existing category/specialty/bio, block empty-profile creation, and avoid broader profile fields; DOC_SYNC NEXT -> 52.84 |
| 2026-07-15 | Task 52.84 DONE - professional display-name update regression passed for backend prefill, display-name-only save, category/specialty/bio preservation, empty-profile blocking, validation, safe failure, and deferred-work accuracy; DOC_SYNC NEXT -> 52.85 |
| 2026-07-15 | Task 52.85 DONE - selected professional category/specialty editing as the next backend-completed Flutter surface and required a boundary decision before runtime wiring; DOC_SYNC NEXT -> 52.86 |
| 2026-07-15 | Task 52.86 DONE - accepted a new constrained category/specialty edit surface with required category, optional specialty, displayName/bio preservation, and no profile creation; DOC_SYNC NEXT -> 52.87 |
| 2026-07-15 | Task 52.87 DONE - wired Manage Profile category/specialty update through a new constrained route with backend prefill, displayName/bio preservation, null-cleared specialty, empty-profile blocking, and focused tests; DOC_SYNC NEXT -> 52.88 |
| 2026-07-15 | Task 52.88 DONE - category/specialty update regression passed for entry separation, backend prefill, required category, displayName/bio preservation, null-cleared specialty, empty-profile blocking, safe failure, and deferred-work accuracy; DOC_SYNC NEXT -> 52.89 |
| 2026-07-15 | Task 52.89 DONE - selected protected Google account linking as the next backend-completed Flutter surface and required a UI boundary decision before runtime wiring; DOC_SYNC NEXT -> 52.90 |
| 2026-07-15 | Task 52.90 DONE - accepted Google account linking UI boundary for Account placement, configured provider gate, `AuthRepository.googleLink`, safe states, backend-owned account/session data, and explicit deferrals; DOC_SYNC NEXT -> 52.91 |
| 2026-07-15 | Task 52.91 DONE - Account now exposes configured Google account linking below Authentication, obtains a real provider ID token, calls `AuthRepository.googleLink`, shows safe states, and keeps account/session fields backend-owned; DOC_SYNC NEXT -> 52.92 |
| 2026-07-15 | Task 52.92 DONE - Google account linking regression passed for placement, config gate, provider token handoff, safe provider/backend failures, no raw text/token exposure, and no local session/user mutation; DOC_SYNC NEXT -> 52.93 |
| 2026-07-15 | Task 52.93 DONE - selected admin verification review boundary as the next backend-completed surface decision; runtime admin UI remains deferred until placement/access/signed-read/approve-reject boundaries are accepted; DOC_SYNC NEXT -> 52.94 |
| 2026-07-15 | Task 52.94 DONE - accepted separate admin dashboard/web console as the admin verification review target and kept runtime admin UI out of the patient/professional Flutter app; DOC_SYNC NEXT -> 52.95 |
| 2026-07-15 | Task 52.95 DONE - updated the completed backend surface map, found no remaining first-pass mobile-facing backend-completed surface, and selected stabilization/regression planning next; DOC_SYNC NEXT -> 52.96 |
| 2026-07-15 | Task 52.96 DONE - defined the mobile backend integration stabilization plan with grouped regression suites, focused analyze/docs checks, manual smoke checklist, known blockers, and regression execution next; DOC_SYNC NEXT -> 52.97 |
| 2026-07-15 | Task 52.97 DONE - executed the grouped mobile backend integration regression pass, fixed a password-recovery test-harness Google-provider fixture gap, and recorded green auth/account, profile/verification, discovery/booking, scheduling, analyze, and docs-check evidence; DOC_SYNC NEXT -> 52.98 |
| 2026-07-15 | Task 52.98 DONE - accepted frontend milestone handoff package as the next lane, with staging seed-data/smoke, release-signing/app-link readiness, admin dashboard, and deferred product modules kept separate; DOC_SYNC NEXT -> 52.99 |
| 2026-07-15 | Task 52.99 DONE - created the mobile backend milestone handoff package with wired surfaces, regression evidence, manual smoke inputs, admin/release/deferred boundaries, and presentation wording; DOC_SYNC NEXT -> 53.1 |
| 2026-07-15 | Task 53.1 DONE - defined staging seed-data and smoke execution plan with required accounts/data/config, build and verification commands, manual smoke checklist, evidence requirements, blocker rules, and execution next; DOC_SYNC NEXT -> 53.2 |
| 2026-07-16 | Task 53.2 checkpoint - fixed Android native `MainActivity` package path for `com.carenet.app`, built the APK with the public staging API Gateway URL, installed it on the connected phone, and verified launch/process evidence; full staging seed-data/manual smoke remains NEXT |
| 2026-07-16 | Task 53.2 checkpoint update - created staging-only patient/professional seed data, seeded professional verification through Cloud SQL Auth Proxy, proved public listing, public availability, and backend appointment request/accept/reschedule/cancel/complete through the staging API Gateway; real-device phone UI smoke remains NEXT |
| 2026-07-16 | Task 53.2 checkpoint update - patient phone login, Account current-account display, Settings/Profile patient profile read, and Search public professional listing passed on device; fixed public availability parsing for the backend `availabilityWindows` envelope and omitted `active` flag; rebuilt APK passes focused tests/analyze/build, but final reinstall/device smoke is blocked until `adb devices -l` lists the phone again |
| 2026-07-16 | Task 53.2 checkpoint update - fixed UTC request-time generation for backend `timezone: "UTC"` availability windows after phone request returned backend validation; focused tests/analyze/build pass, but reinstall/final phone smoke is blocked again because ADB dropped the phone during install |
| 2026-07-17 | Task 53.2 checkpoint update - disabled Android backup/restore for safer auth storage, rebuilt/reinstalled the staging APK, completed fresh patient phone sign-in, and proved Search -> public availability -> appointment request on the real Android phone with `Request sent. Backend status: REQUESTED`; professional-role/details/verification/cleanup phone smoke remains open |
| 2026-07-17 | Task 53.2 checkpoint update - fixed own appointment list parsing for the backend `appointments` envelope and ordered secure-session writes; rebuilt/reinstalled the staging APK, completed fresh patient sign-in, and proved Notifications -> Appointments renders real backend `REQUESTED` rows on the phone; separate detail/professional/verification/cleanup smoke remains open |
| 2026-07-17 | Task 53.2 checkpoint update - completed fresh professional phone sign-in, proved Account shows `PROFESSIONAL account - active`, proved Notifications -> Appointments exposes backend role-aware Accept/Decline/Reschedule actions, accepted one request, declined a separate request, rescheduled the accepted row back to `REQUESTED`, and confirmed terminal recent rows do not expose duplicate completion; verification upload remains blocked by missing reliable phone navigation to Manage Profile/Verification documents |
| 2026-07-17 | Task 53.2 checkpoint update - added professional-only Account entries for Manage Profile and Verification documents, proved both routes on the phone, and located the remaining verification upload blocker at staging `POST /verification/documents/upload-init` returning HTTP 500 before signed PUT/upload-complete |
| 2026-07-17 | APP-55 DONE - accepted PRD-backed role-based onboarding/auth boundary: patient/professional sign-up must branch before Google sign-up expansion, professional public listing requires profile/credential upload/manual verification, and backend role-registration contracts must be defined before runtime onboarding work |
| 2026-07-17 | APP-56 DONE - accepted role-registration backend contract: email/password and first-time Google-created accounts require explicit `PATIENT`/`PROFESSIONAL` role selection, existing linked Google sign-in/linking remain valid, and next runtime work should add role-selection onboarding before account creation |
| 2026-07-17 | APP-57 DONE - added `signUpRole` before `finishSignUp`, passed selected `PATIENT`/`PROFESSIONAL` role into backend registration, routed professionals to the existing professional onboarding surface after success, and kept Google signup disabled |
| 2026-07-15 | Task 52.74 DONE - selected professional verification upload/list as the next backend-completed Flutter lane, with a required boundary decision before runtime wiring; DOC_SYNC NEXT -> 52.75 |
| 2026-07-15 | Task 52.73 DONE - Find Mentor public professionals regression passed for loading, empty, success, filtering, backend id handoff, no local fallback/direct fake booking, dashboard compatibility, and Specialist Details compatibility; DOC_SYNC NEXT -> 52.74 |
| 2026-07-15 | Task 52.72 DONE - Find Mentor now reads backend public professionals where available, routes backend ids to Specialist Details, and avoids local fallback/direct fake booking in the backend path; DOC_SYNC NEXT -> 52.73 |
| 2026-07-15 | Task 52.71 DONE - selected Find Mentor public professional replacement as the next narrow surface; DOC_SYNC NEXT -> 52.72 |
| 2026-07-15 | Task 52.70 DONE - Specialist Details public availability regression passed for backend id resolution, Search handoff, dashboard compatibility, no local slot fallback, generated request payload, safe failure behavior, and deferred-work accuracy; DOC_SYNC NEXT -> 52.71 |
| 2026-07-15 | Task 52.69 DONE - Specialist Details now uses backend public professional, public availability, generated request options, and backend appointment request results when a backend id is available; DOC_SYNC NEXT -> 52.70 |
| 2026-07-15 | Task 52.68 DONE - selected Specialist Details public professional/availability wiring as the next narrow backend-completed Flutter surface; DOC_SYNC NEXT -> 52.69 |
| 2026-07-15 | Task 52.67 DONE - patient profile name update regression passed for name-only payload, safe failure/no false success, local-field preservation, and deferred-work accuracy; DOC_SYNC NEXT -> 52.68 |
| 2026-07-15 | Task 52.66 DONE - Settings/Profile now updates backend patient profile name only, preserves local username/email/bio behavior, and blocks false success on backend name-save failure; DOC_SYNC NEXT -> 52.67 |
| 2026-07-15 | Task 52.65 DONE - selected constrained patient profile name update as the next runtime slice, with username/email/bio/security/verification/scheduling data excluded from `/patients/me`; DOC_SYNC NEXT -> 52.66 |
| 2026-07-15 | Task 52.64 DONE - patient profile read regression passed for success, empty-profile, safe failure, local save preservation, and no `updatePatientMe` mutation; DOC_SYNC NEXT -> 52.65 |
| 2026-07-15 | Task 52.63 DONE - Settings/Profile now reads patient profile through `ProfileRepository.patientMe`, displays backend name/age/location read-only, and preserves local save/no-mutation behavior; DOC_SYNC NEXT -> 52.64 |
| 2026-07-15 | Task 52.62 DONE - defined read-first patient profile mapping for Settings/Profile using backend `name`, `age`, and `location` only; DOC_SYNC NEXT -> 52.63 |
| 2026-07-15 | Task 52.61 DONE - selected patient self profile as the next backend-completed Flutter surface and required a Settings/Profile mapping decision before runtime wiring; DOC_SYNC NEXT -> 52.62 |
| 2026-07-15 | Task 52.60 DONE - rejected ad hoc Flutter-created scheduling staging data and kept full scheduling smoke blocked on deliberate backend/staging test data setup; DOC_SYNC NEXT -> 52.61 |
| 2026-07-15 | Task 52.59 DONE - Scheduling staging smoke checkpoint recorded backend readiness, staging-configured APK build, protected-route guards, and missing data blockers; DOC_SYNC NEXT -> 52.60 |
| 2026-07-15 | Task 52.58 DONE - Scheduling feature expansion paused; staging smoke checkpoint selected next; DOC_SYNC NEXT -> 52.59 |
| 2026-07-15 | Task 52.57 DONE - Appointment reschedule regression proof added; DOC_SYNC NEXT -> 52.58 |
| 2026-07-15 | Task 52.56 DONE - Appointments now wires constrained patient/professional reschedule from backend public availability options; DOC_SYNC NEXT -> 52.57 |
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
| 2026-07-14 | Task 52.24 DONE - added profile repository/API boundary for patient self, professional self, and public professional listing; DOC_SYNC NEXT -> 52.25 |
| 2026-07-14 | Task 52.25 DONE - wired professional self profile read to Manage Profile with safe loading/error/empty states and allowed-field replacement only; DOC_SYNC NEXT -> 52.26 |
| 2026-07-14 | Task 52.26 DONE - selected existing professional bio update from Add Description as the first safe profile mutation path; DOC_SYNC NEXT -> 52.27 |
| 2026-07-14 | Task 52.27 DONE - wired Add Description to update existing professional profile bio only, preserving backend-required profile fields; DOC_SYNC NEXT -> 52.28 |
| 2026-07-14 | Task 52.28 DONE - selected public verified professional listing into Search as the next runtime lane; DOC_SYNC NEXT -> 52.29 |
| 2026-07-14 | Task 52.29 DONE - wired Search to public verified professionals without local fallback and kept booking/detail expansion deferred; DOC_SYNC NEXT -> 52.30 |
| 2026-07-14 | Task 52.30 DONE - selected scheduling/availability/appointment contract definition as the next backend-integration lane; DOC_SYNC NEXT -> 52.31 |
| 2026-07-14 | Task 52.31 DONE - defined scheduling/availability/appointment frontend contract and queued repository boundary; DOC_SYNC NEXT -> 52.32 |
| 2026-07-14 | Task 52.32 DONE - added scheduling repository/API boundary and focused tests without UI wiring; DOC_SYNC NEXT -> 52.33 |
| 2026-07-14 | Task 52.33 DONE - wired Search profile sheet to public availability read without local slot fallback and kept booking deferred; DOC_SYNC NEXT -> 52.34 |
| 2026-07-14 | Task 52.34 DONE - decided to remove local booking success before real appointment request wiring; DOC_SYNC NEXT -> 52.35 |
| 2026-07-14 | Task 52.35 DONE - removed local booking confirmation/success from bookAppointment; DOC_SYNC NEXT -> 52.36 |
| 2026-07-14 | Task 52.36 DONE - selected Search availability sheet request UX and queued time-option helper before runtime request; DOC_SYNC NEXT -> 52.37 |
| 2026-07-14 | Task 52.37 DONE - added appointment request time-option helper and focused tests without UI wiring or request API calls; DOC_SYNC NEXT -> 52.38 |
| 2026-07-14 | Task 52.38 DONE - wired Search availability sheet to request selected generated appointment times through the backend repository; DOC_SYNC NEXT -> 52.39 |
| 2026-07-14 | Task 52.39 DONE - wired appointments screen to backend own appointment list read with safe empty/error states; DOC_SYNC NEXT -> 52.40 |
| 2026-07-14 | Task 52.40 DONE - selected patient appointment cancellation as the next narrow scheduling UI lane; DOC_SYNC NEXT -> 52.41 |
| 2026-07-14 | Task 52.41 DONE - wired eligible own appointment cancellation through the scheduling repository; DOC_SYNC NEXT -> 52.42 |
| 2026-07-14 | Task 52.42 DONE - selected scheduling patient-path regression before professional availability management; DOC_SYNC NEXT -> 52.43 |
| 2026-07-14 | Task 52.43 DONE - added scheduling patient-path regression proof and documented request/list/cancel coverage; DOC_SYNC NEXT -> 52.44 |
| 2026-07-14 | Task 52.44 DONE - selected selectedDates as the professional availability management surface; DOC_SYNC NEXT -> 52.45 |
| 2026-07-14 | Task 52.45 DONE - wired selectedDates to backend own-availability read/replace while preserving other backend weekdays; DOC_SYNC NEXT -> 52.46 |
| 2026-07-14 | Task 52.46 DONE - selected role-aware professional accept/decline as the first lifecycle UI slice; DOC_SYNC NEXT -> 52.47 |
| 2026-07-14 | Task 52.47 DONE - wired role-aware professional appointment accept/decline in Appointments; DOC_SYNC NEXT -> 52.48 |
| 2026-07-14 | Task 52.48 DONE - added professional appointment lifecycle regression proof; DOC_SYNC NEXT -> 52.49 |
| 2026-07-14 | Task 52.49 DONE - selected professional completion before reschedule; DOC_SYNC NEXT -> 52.50 |
| 2026-07-14 | Task 52.50 DONE - wired professional appointment completion for accepted appointments after scheduled end; DOC_SYNC NEXT -> 52.51 |
| 2026-07-14 | Task 52.51 DONE - added appointment completion regression proof and post-completion checkpoint; DOC_SYNC NEXT -> 52.52 |
| 2026-07-15 | Task 52.52 DONE - selected scheduling core regression before any reschedule UX/runtime work; DOC_SYNC NEXT -> 52.53 |
| 2026-07-15 | Task 52.53 DONE - strengthened scheduling core regression proof across Search, Appointments, selectedDates, and repository boundaries; DOC_SYNC NEXT -> 52.54 |
| 2026-07-15 | Task 52.54 DONE - selected reschedule UX/product boundary decision before runtime reschedule wiring; DOC_SYNC NEXT -> 52.55 |
| 2026-07-15 | Task 52.55 DONE - defined constrained appointment reschedule UX boundary; DOC_SYNC NEXT -> 52.56 |
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
