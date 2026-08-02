# Phase 1 Consultation Marketplace Boundary

Slice: `APP-P1-001`

Status: decision and implementation planning only

Baseline inspected: `3e04d6e22b17c5ff195085153a1d9cf842cb8d24`

This document is the product-scope authority for the CareNet Flutter Phase 1
mainline. Existing Flutter screens and Figma frames are implementation
references, not evidence that a feature belongs in Phase 1.

## Git safety report

The repository was inspected before this slice made any change.

| Checkout | Branch/state | Existing changes observed before this slice | Action in this slice |
|---|---|---|---|
| `C:\Users\asd\Music\Mobile-App-master` | `slice/APP-ID-016-recovered-auth-onboarding-phone-smoke` at `3e04d6e` | Modified: `lib/features/Authentication/data/services/auth_api_client.dart`, `lib/features/Authentication/data/services/google_sign_in_provider.dart`, `macos/Flutter/GeneratedPluginRegistrant.swift`; no untracked files reported | Untouched |
| `C:\Users\asd\.codex\worktrees\39b5\Mobile-App-master` | Detached at `a32e720` | Modified: `docs/AI_HANDOFF.md`, `docs/CODEBASE_STATUS.md`, `docs/DOC_SYNC.md`, `docs/README.md`; no untracked files reported | Untouched |
| `C:\Users\asd\.codex\worktrees\phase1-scope-mobile` | `slice/APP-P1-001-phase-1-marketplace-scope` at `3e04d6e` | Clean at slice start | Docs-only slice written here |

The modified files above predate `APP-P1-001`: they were present in the first
status inspection and were not created, staged, stashed, reset, discarded, or
overwritten by this slice. Git reports the three files in the original checkout
as modified even though the normalized `git diff` is empty; they remain dirty
and must not be normalized or refreshed as part of this work.

### Broad-UI baseline and archive proposal

The last safe committed baseline that contains both the broad UI and the latest
recovered auth/onboarding work is:

```text
commit: 3e04d6e22b17c5ff195085153a1d9cf842cb8d24
date:   2026-07-22 15:22:37 +0530
title:  APP-ID-016: Record staging readiness recovery
parent: 65cf91e2460bdf08ece72c68c066a259d9925eef
```

`feature/frontend-milestone` at `9385235` is an ancestor of this baseline, but
the baseline is not yet contained in that milestone branch. Therefore an
archive created from `9385235` would omit `APP-ID-016` and would not preserve
the latest committed onboarding state.

Created immutable preservation references, both pointing exactly to `3e04d6e`:

- Archive branch: `archive/pre-phase1-broad-ui-2026-07-22`
- Annotated tag: `pre-phase1-broad-ui-2026-07-22`

These references were pushed to `allcarenet/Mobile-App` after the APP-P1-001
documentation commit. They preserve committed content only, deliberately point
to the older baseline rather than the documentation commit, and do not claim to
preserve the unrelated uncommitted files listed above.

## Product goal

Phase 1 proves one complete healthcare-consultation and revenue loop:

```text
verified professional becomes available
-> patient discovers and reviews the professional
-> patient selects a real available slot
-> appointment is requested or booked
-> payment is completed when the approved rule requires it
-> professional manages the request
-> both parties communicate in the appointment context
-> both parties join the consultation
-> appointment is completed
-> support, cancellation, refund, and follow-up paths remain available
```

The currently implemented backend-supported core ends at appointment completion.
Appointment-linked text messaging and video/audio consultation are approved
Phase 1 capabilities, but their runtime contracts are not implemented. Payment,
refunds, payouts, support ownership, and follow-up rules are also not yet
resolved and must not be represented as complete.

## Approved Phase 1 surface

### Shared

- Splash and session restoration
- Email/password and Google authentication, account recovery, and verification
- Role-specific patient and professional onboarding
- Account readiness and professional verification status
- Notifications through a header bell
- Support entry point
- Privacy, security, and account settings

### Patient

- Patient Home
- Find Care and search results
- Public professional profile
- Real professional availability and slot selection
- Appointment request or booking
- Payment when a later approved payment contract requires it
- Appointments list and appointment detail
- Appointment-linked messages after a messaging contract exists
- Patient Profile

### Professional

- Professional Home
- Verification and readiness
- Public profile management
- Schedule and real availability management
- Appointment requests, list, and detail
- Accept, decline, cancel, reschedule, and complete where backend rules permit
- Appointment-linked messages after a messaging contract exists
- Professional Profile
- Earnings/payout information only after an approved payments contract exists

## Explicitly deferred

The following do not belong in the active Phase 1 route or navigation surface:

- General feed and public post creation
- Circles, communities, community invitations, and community profiles
- Articles, saved/published articles, article subscriptions, and case studies
- Podcasts and media publishing
- Social Q&A
- Events and public live sessions
- Professional-development marketplace
- Health readings, connected devices, and health-record dashboards
- Emergency, distress, ambulance, and location-dispatch workflows
- Generic social messaging unrelated to an appointment
- Creator portfolios and creator promotion tools
- Birthday activity
- Promotional subscriptions, boosts, ads, and upgrade surfaces
- Generic reminders and event schedules unrelated to an appointment

Deferred features are preserved through Git history and the proposed archive
refs. They must first disappear from active navigation and routing. Their
exclusive dead code and dependencies are removed only after retained Phase 1
paths pass regression.

## Navigation contract

### Baseline navigation being replaced

At `3e04d6e`, `Dashboard` uses one non-role-aware bottom bar:

```text
Home | Search | Post | Circles | Notifications
```

`Home` then adds another tab layer:

```text
Feed | Messages | Articles
```

The drawer exposes Dashboard, Profile, Readings, Reminders, Schedule, Providers,
Switch to professional, Articles, Messages, Events, Settings & Privacy, Rate the
App, Need help, and Mode. Several entries have no action, use static identity and
follower data, or lead to local/deferred modules. This baseline is not the Phase 1
navigation contract.

### Patient primary destinations

| Position | Label | Purpose | Current source to adapt |
|---:|---|---|---|
| 1 | Home | Upcoming care, next appointment, readiness/support summaries | `Dashboard` + `Home`, without Feed/Articles tabs |
| 2 | Find Care | Verified professional search and discovery | `search` + `specialistDetails`; remove `findMentor` duplication |
| 3 | Appointments | Patient appointment list and lifecycle actions | `appointments` in patient mode |
| 4 | Messages | Appointment-linked conversations only | `messages`/`chat`, after seeded data is removed and a contract exists |
| 5 | Profile | Patient identity, account, privacy, security, and support | `account` + adapted `settings` |

### Professional primary destinations

| Position | Label | Purpose | Current source to adapt |
|---:|---|---|---|
| 1 | Home | Verification/readiness, today's work, next appointment | New role state inside adapted `Dashboard`/`Home` shell |
| 2 | Schedule | Real own availability management | `selectedDates`, renamed/reframed for availability |
| 3 | Appointments | Requests and professional lifecycle actions | `appointments` in professional mode |
| 4 | Messages | Appointment-linked conversations only | `messages`/`chat`, after seeded data is removed and a contract exists |
| 5 | Profile | Professional public profile, verification, account, and support | `manageProfile`, verification documents, and account settings |

### Shared shell rules

- The authenticated account role and backend readiness are authoritative.
- The shell must not infer role from a tapped tab or client-supplied profile id.
- A header bell opens `notification`; notifications are not a bottom-nav tab.
- Direct access to a role-incompatible primary destination must fail closed and
  return to the correct role Home. It must not create a client-side role switch.
- The current drawer is not a Phase 1 primary navigation surface. Any retained
  account/support entries must move into Profile or a small secondary menu.
- `Switch to professional` remains removed until dual-role ownership is decided.
- Messages may appear in the shell contract, but seeded conversations must not
  be exposed as real appointment communication.

## Approved communication and consultation boundary

### Appointment-linked text messaging

- Text messaging is part of Phase 1.
- It is not generic social messaging and must not support unrelated user-to-user
  conversations.
- A conversation belongs to an eligible appointment and to that appointment's
  patient and assigned professional.
- CareNet must authorize conversation access from the authenticated account,
  appointment ownership, and eligible appointment state; the client must not
  grant access from a supplied participant or profile id.
- Conversations appear through the primary Messages destination and from
  Appointment Detail where appropriate.
- Seeded `MessagesPage`/`ChatPage` data is not an acceptable runtime fallback.

### Video/audio consultation

- Video/audio consultation is part of Phase 1.
- Calls are entered from Appointment Detail through **Join Consultation**. There
  is no separate calls bottom-navigation destination.
- CareNet owns appointment authorization, participant eligibility, consultation
  timing, session state, and audit boundaries.
- An external real-time-communications provider handles audio/video media
  transport. Provider selection, token exchange, room lifecycle, privacy, failure,
  and reconnect contracts require separate decisions before implementation.
- This decision slice defines the product boundary only. It does not implement
  messaging, calls, media transport, or new backend modules.

## Retained backend and architecture boundaries

The following are protected from broad cleanup:

- `AuthRepository`, `AccountRepository`, `SessionStore`, and Google ID-token provider
- Auth, account, reset, verification, session restore, and logout API paths
- `OnboardingRepository`, backend catalogs, account readiness, and readiness resolver
- `ProfileRepository`, patient/professional self profiles, and public professionals
- `VerificationRepository` and verification upload/list/status behavior
- `SchedulingRepository`, public/own availability, and all implemented appointment actions
- Auth, profile, onboarding, scheduling, verification models/entities/API clients
- `CareNetApiConfig`, dependency injection, named routing foundation, and safe errors
- `CarenetButton`, `CarenetTextField`, design tokens, theme, and shared loading/error patterns
- `appointment_request_time_options.dart`

## Known honesty gaps in retained areas

These are removal or replacement requirements, not acceptable production data:

- `BookAppointmentShellPage` is a local draft and says `Backend request not sent`.
- `SpecialistDetailsShellPage` still has a local compatibility branch.
- `FindMentorShellPage` uses `SearchLocalStore` and duplicates Find Care.
- `MessagesPage`, `ChatPage`, and the old Home messages tab use seeded conversations.
- `NotificationsPage` contains a static list, including deferred social content.
- `AccountLocalStore` still owns profile/security/deactivation behavior mixed with real reads.
- `PublicProfileLocalStore` mixes health-professional identity with creator content.
- Patient setup still exits into the obsolete `communityAgreement` chain.
- The old `communityAgreement -> notificationAgreement -> medicalAgreement -> medicalEdit`
  path coexists with the newer catalog/readiness onboarding and is not part of the
  approved Phase 1 journey.

## Preservation plan

1. The archive branch and annotated tag were created and verified at `3e04d6e`,
   never from a dirty working tree snapshot.
2. Keep this repository's route/screen inventory in
   `PHASE_1_ROUTE_SCREEN_CLASSIFICATION.md`.
3. Keep local Figma mapping through `ROUTES.md`, `BLUEPRINT_OVERVIEW.md`, and the
   exported `routes.json` at
   `C:\Users\asd\Music\project-blueprint\project-blueprint\routes.json`.
4. Record the final removal commit for every cleanup slice. Recovery later uses
   the archive ref plus those removal commits; it does not blindly merge the
   archived broad app into the Phase 1 mainline.
5. Preserve shared code before deleting a deferred feature directory. Move a
   shared widget/model only when import evidence proves it has retained consumers.
6. Delete exclusive deferred code only after navigation pruning, retained-flow
   tests, and package/asset usage checks pass.

## APP-P1-001 unresolved decisions and later resolutions

This table records what was intentionally unanswered in APP-P1-001. Later
canonical milestone contracts supersede rows marked implemented; remaining
support, dual-role, and follow-up policy still require deliberate decisions.

| Area | Decision still required | Blocks |
|---|---|---|
| Payment | Provider, payer, charge timing, authorization/capture, fees, cancellation, refunds, receipts, webhook authority | Paid booking and revenue proof |
| Dual role | Whether one account can own patient and professional profiles, mode switching, permissions, incomplete application behavior | Role switching and duplicate account handling |
| Consultation implementation | External RTC vendor, server-side room/token lifecycle, join window, reconnect/failure behavior, consent/privacy, session completion, and audit event details. The Phase 1 placement and CareNet authorization ownership are approved | Join Consultation runtime behavior |
| Messaging implementation | Appointment eligibility states, send/read model, realtime transport, attachments, retention, moderation, notification interaction, and audit details. Appointment ownership and placement are approved | Messages data and appointment chat runtime behavior |
| Support | Support channel, ticket ownership, escalation, dispute intake, operating hours, emergency disclaimer | Support and post-booking recovery |
| Notifications | Implemented by `NOTIF-P1-010`: durable event catalogue/inbox, preferences, backend reminders, FCM, critical Resend email, contextual permission, read state, unread badge, and owner-checked allowlisted routes. Quiet hours and marketing communication remain deferred | `PHASE_1_TRANSACTIONAL_NOTIFICATIONS.md` |
| Refund/follow-up | Eligibility, actor authority, timelines, payout reversal, follow-up booking rules | Refund and post-consultation paths |

No runtime slice may invent these answers. Affected work must stop at the existing
backend boundary and record the blocker.

## Decision outcome

CareNet Phase 1 is a role-aware healthcare consultation marketplace. The broad
social/content/health-tracking product is archived and removed from the active
mainline in stages. The Figma export remains a visual reference only.

The exactly one recommended next runtime slice is:

`APP-P1-002 - Role-Aware Phase 1 Navigation Shell And Active Route Pruning`

The archive precondition is complete at `3e04d6e`. The slice changes navigation
exposure and route registration only; it does not delete deferred source files
or implement payment, messaging, calls, or new backend behavior.
