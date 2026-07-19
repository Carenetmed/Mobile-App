# CareNet — user flows

Implementation order: **A → B → C → D → E+**

**When is a screen done?** Every control in the documented scope must have a
real outcome or an explicit disabled/deferred state. Navigation changes must
agree with `ROUTES.md`, and backend-dependent gaps must be recorded in
`DEFERRED_WORK.md`.

---

## Flow A — First launch (sign up) — Phase 2 target

```
splash
  │  (auto 800ms)
  ▼
onboarding gateway (Browse verified care / Create account / Sign in)
  ▼
Create account -> signUpRole
  |
signUpPhone <-> signUpEmail (entry screens still validate first)
  | Continue -> signUpRole with passwordSignUp
  ▼
signUpRole  (Patient → finishSignUp as PATIENT; Professional → finishSignUp as PROFESSIONAL)
  ▼
finishSignUp  (Agree & continue; APP-60 routes patient to patientOnboardingSetup and professional to medicalProfessional setup)
  ▼ Patient
communityAgreement  (Agree → notificationAgreement)
  ▼
notificationAgreement  (→ medicalAgreement)
  ▼
medicalAgreement  (→ medicalProfessional OR skip path TBD)
  ▼
medicalProfessional  (→ medicalEdit)
  ▼
medicalEdit  (Continue → dashboard)
  ▼
dashboard
```

### Phase 0 status (navigation wired?)

| Step | Wired | Notes |
|------|-------|-------|
| splash → onboarding | Yes | 800ms timer |
| onboarding → signUpPhone | Yes | Get started on last page |
| signUp → signUpRole → finishSignUp | Yes | Entry validation gates navigation; role selection controls backend registration role |
| finishSignUp → community / professional onboarding | Yes | Agree button; patient goes to community agreement, professional goes to professional onboarding |
| community → notification | Yes | |
| notification → medical | Yes | |
| medical → professional | Yes | |
| professional → medicalEdit | Yes | |
| medicalEdit → dashboard | Yes | Continue |

---

## Flow B — Returning user (sign in) — Phase 3

```
splash → onboarding OR sign-in entry (TBD)
signInPhone ←→ signInEmail
  Continue → dashboard
  Forgot Password? → enterEmail → reset email sent → resetPasswordConfirm(token) → signInEmail
  Legacy local review screen: enterEmail → enterPassword (explains token requirement when no token is present)
```

---

## Flow C — Main shell — Phase 4

```
dashboard
  ├─ Tab 0: Home (Feed | Messages preview → messages route | Articles preview)
  ├─ Tab 1: Search shell
  ├─ Tab 2: Post shell
  ├─ Tab 3: Circles shell
  └─ Tab 4: Notifications feature screen
```

Drawer: open from Home avatar — Phase 4.

---

## Flow D — Messaging — Phase 5

```
messages -> chat (canonical seeded conversation page)
notification (standalone route and current dashboard notifications tab target)
```

Reachable via `Navigator.pushNamed(context, RouteName.messages)` from Home previews.
Notifications no longer embed their own fake app-level bottom navigation inside the page. Category tabs now filter the visible list for `All`, `Events`, `Appointment`, and `Messages`; `Payment` is explicitly disabled until payment notifications exist. Actionable cards currently route to `medicalEdit`, `messages`, `dashboard`, `appointments`, `readings`, `articles`, `emergency`, and `podcast`.

---

## Flow E — Health readings — Phase 6

```
readings -> manageReadings -> addDevice -> bloodSug
```

Current scope: `Add new Readings` opens `manageReadings`; selecting `Blood Sugar` continues into `addDevice`, which then routes to `bloodSug`. The `bloodSug` screen now supports a real local entry flow with validation, saved-state summary, short local history, simple trend summary, and delete actions for saved history rows; saved values flow back into the main `readings` dashboard card. `Download Readings` is explicitly deferred until the add-reading/device flow exists (see `DECISIONS.md` D005); menu affordances remain disabled until a later readings task.

---

## Flow E+ - Later

Health readings, appointments, emergency, feed content, communities, Q&A, profile, ads, subscriptions - see blueprint `routes.json`; add sections here before coding.

## Flow F - Appointments - Phase 7

```
appointments -> bookAppointment
```

Current scope: appointment notifications land on a real appointments screen with local upcoming/recent sections, and `Book appointment` now opens a real local booking form with clinician, visit type, preferred date, reason, validation, and a saved booking draft. That draft can now be confirmed locally or cancelled cleanly inside the same slice.

## Flow G - Emergency - Phase 8

```
emergency -> distressCall
```

Current scope: emergency notifications land on a real emergency screen with current status and update cards, and `Open distress call` now routes into a real local distress form with validation, saved update summary, and a local dispatch/clear step. Later backend escalation should replace that local dispatch confirmation without changing the screen flow.

## Flow H - Articles - Phase 9

```
articles (list) <-> article detail (same route state)
```

Current scope: article notifications land on a real articles reader. The route now supports local article list content, in-page detail view, and local read/saved state, while later content APIs and account sync should replace the data source without changing the list/detail flow.

## Flow I - Communities - Phase 10

```
circles -> discoverCommunities
circles -> communityProfile
circles -> createCommunity -> communityProfile
```

Current scope: the Circles tab now supports a real local communities screen with a working handoff into `discoverCommunities`, a blueprint-backed local `communityProfile` detail view, and a blueprint-backed local `createCommunity` form. Joining a discovered community updates shared local membership state and reflects back under `My communities` when the user returns. Creating a community now validates local form state, creates an owned local community, and hands off into an owner profile note. Community profiles expose local description, member previews, articles, and event sections. The communities lane intentionally stops here: invitation acceptance, delivery, media upload, posting, and moderation should wait for backend-backed workflows so the route flow can stay honest (see `DECISIONS.md` D007).

## Flow J - Q&A - Phase 11

```
dashboard Post tab -> qAAsk -> dashboard Post tab
dashboard Post tab -> qAAnswerRequests -> qAAnswerForYou -> commentAnswer
```

Current scope: the Post tab now hosts the first real Q&A slice instead of a shell. Users can see a local Q&A feed, follow authors locally, and open a real `qAAsk` form. The ask form validates required text plus a `What` / `How` / `Why` / `Where` question prefix, then returns the saved question to the feed as a local draft entry. The answer lane is now also real and local: `Answer requests` shows saved local answer drafts or an empty state, `Tagged questions` lists local tagged questions, and `Comment` lets the user submit a local answer back into that queue. The Q&A lane intentionally stops here: the blueprint `q-a-post` composer is deferred until a later phase defines real feed distribution, audience, and mixed post-vs-question rules, so we do not blur Q&A into a fake general posting system (see `DECISIONS.md` D008).

## Flow K - Account - Phase 12

```
dashboard drawer -> account -> deleteAccount
dashboard drawer -> account -> settings
dashboard drawer -> account -> changeAuthentication
dashboard drawer -> account -> changeAuthentication -> turnOnAuthentication
dashboard drawer -> account -> changeAuthentication -> turnOnAuthentication -> createPin
dashboard drawer -> account -> changeAuthentication -> turnOnAuthentication -> createPin -> confirmPinSave
dashboard drawer -> account -> addPhoneNumber
dashboard drawer -> account -> addEmail
dashboard drawer -> account -> addEmail -> editEmail
dashboard drawer -> account -> addEmail -> editEmail -> emailVerificationConfirm(token)
dashboard drawer -> account -> addEmail -> editEmail -> enterPasswordToSave
dashboard drawer -> account -> addEmail -> changeEmail
dashboard drawer -> account -> password
```

Current scope: the dashboard drawer now routes `Profile` into a real local `Account` screen based on the blueprint account route. The account screen exposes local account rows for authentication, settings/profile editing, email, phone, password, and help, plus a real handoff into `Delete account`. `Settings & Profile` now opens a real local edit form with validation and local save for first name, last name, username, email, and bio. The delete flow validates local confirmation fields and offers a local `Deactivate your instead?` fallback modal. `Authentication` now opens `changeAuthentication`, a local two-step verification information screen with backend-gated security actions. `Email address` now opens `addEmail`, a local email-entry draft with validation and a verification-preparation seam that does not mutate the stored account email. The account lane still avoids real auth changes until backend/session contracts exist.

## Flow U - Change Authentication - Phase 22

```
account -> changeAuthentication
```

Current scope: `changeAuthentication` is now a registered route based on the blueprint `/change-authentication` screen. It shows two-step verification copy and keeps `Change PIN`, `Turn off`, and `Learn more` visibly locked/deferred because PIN changes, disabling two-step verification, and account safety help need backend re-authentication, session/audit rules, secure storage, and product-approved security copy.

This lane intentionally stops here: adjacent blueprint screens (`/create-pin`, `/confirm-pin-save`, `/turn-on-authentication`, `/enter-password-to-save`, and related phone/email/code verification routes) require real auth backend, re-authentication, secure PIN storage, device/session checks, audit logs, and product-approved account-security copy before they can be implemented honestly (see `DECISIONS.md` D019).

## Flow AC - Turn On Authentication - Phase 30

```
account -> changeAuthentication -> turnOnAuthentication
```

Current scope: `turnOnAuthentication` is now a registered route based on the blueprint `/turn-on-authentication` screen. The Change Authentication route exposes a `Review turn-on setup` handoff. The screen shows the two-step verification copy and keeps `Turn on` disabled because enabling 2FA requires PIN creation, secure storage, session/device checks, audit rules, and account persistence.

This lane intentionally stops here: enabling two-step verification requires PIN creation, secure PIN storage, session/device checks, audit/security notifications, recovery rules, and account persistence before it can be implemented honestly (see `DECISIONS.md` D027).

## Flow AD - Create PIN - Phase 31

```
account -> changeAuthentication -> turnOnAuthentication -> createPin
```

Current scope: `createPin` is now a registered route based on the blueprint `/create-pin` screen. The Turn On Authentication route exposes a `Review PIN setup` handoff. The screen validates empty and non-6-digit PIN values, then shows a local ready-for-secure-backend-storage summary for a valid 6-digit PIN without storing the PIN, enabling 2FA, or mutating account state. A valid draft can continue to the route-local `confirmPinSave` review step.

This lane intentionally stops here: creating a real two-step PIN requires PIN confirmation, secure PIN storage, session/device checks, audit/security notifications, account persistence, and recovery rules before it can be implemented honestly (see `DECISIONS.md` D028).

## Flow AE - Confirm PIN Save - Phase 32

```
account -> changeAuthentication -> turnOnAuthentication -> createPin -> confirmPinSave
```

Current scope: `confirmPinSave` is now a registered route based on the blueprint `/confirm-pin-save` screen. The Create PIN route exposes a `Review confirmation step` handoff after a valid local 6-digit draft. The confirmation screen validates empty/non-6-digit values, compares against the route-local draft when one is provided, and shows a ready-for-secure-backend-storage summary without saving the PIN, enabling 2FA, or mutating account/session state.

This lane intentionally stops here: saving a confirmed PIN requires secure PIN storage, session/device checks, audit/security notifications, recovery rules, and account persistence before it can be implemented honestly (see `DECISIONS.md` D029).

## Flow V - Add Phone Number - Phase 23

```
account -> addPhoneNumber
```

Current scope: `addPhoneNumber` is now a registered route based on the blueprint `/add-phone-number` screen. The Account `Phone number` row opens a local phone-entry draft. Empty/invalid phone values are blocked with inline validation, and a valid phone shows a local "ready for SMS verification" summary without changing the account phone number or pretending an OTP was sent. Real save, OTP delivery, code verification, phone uniqueness, rate limiting, and auth-session updates are deferred until backend/auth provider rules exist.

This lane intentionally stops here: adjacent blueprint screens (`/confirm-phone-number`, `/enter-code`, `/enter-code-to-save`, `/enter-password-to-save`, and `/change-phone-number`) require OTP/SMS delivery, code verification, password re-authentication, rate limiting, account-session updates, and account persistence before they can be implemented honestly (see `DECISIONS.md` D020).

## Flow W - Password - Phase 24

```
account -> password
```

Current scope: `password` is now a registered route based on the blueprint `/password` screen. The Account `Password` row opens a local password security information screen with the current local password hint. `Edit password` stays visibly locked/deferred because real password changes require backend re-authentication, current-password verification, password policy enforcement, session invalidation, recovery rules, and account persistence.

This lane intentionally stops here: adjacent blueprint screens (`/enter-password`, `/enter-password-to-save`, and `/enter-code-to-save`) require current-password verification, password policy enforcement, code confirmation, session invalidation, recovery/security notifications, and account persistence before they can be implemented honestly (see `DECISIONS.md` D021).

## Flow X - Add Email - Phase 25

```
account -> addEmail
```

Current scope: `addEmail` is now a registered route based on the blueprint `/add-email` screen. The Account `Email address` row opens a local email-entry draft. Empty/invalid email values are blocked with inline validation, and a valid email shows a local "ready for email verification" summary without changing the account email address or pretending a verification email was sent. Real save, verification delivery, uniqueness checks, auth-session updates, and account persistence are deferred until backend/auth provider rules exist.

This lane intentionally stops here: adjacent blueprint screens (`/change-email`, `/confirm-code-in-email`, `/enter-code`, and `/enter-code-to-save`) require verification email delivery, code confirmation, password re-authentication, rate limiting, account-session updates, recovery/security notifications, and account persistence before they can be implemented honestly (see `DECISIONS.md` D022).

## Flow Y - Change Email - Phase 26

```
account -> addEmail -> changeEmail
```

Current scope: `changeEmail` is now a registered route based on the blueprint `/change-email` screen. The Add Email route exposes a `Change existing email` handoff. The screen blocks empty, invalid, and unchanged email values, then shows a local "ready for code verification" summary for a different valid email without sending a code or changing the stored account email. Real verification delivery, code confirmation, auth-session updates, and account persistence remain deferred.

This lane intentionally stops here: adjacent blueprint screens (`/confirm-code-in-email`, `/enter-code`, `/enter-code-to-save`, and `/enter-password-to-save`) require verification-code delivery, code confirmation, password re-authentication, rate limiting, account-session updates, recovery/security notifications, and account persistence before they can be implemented honestly (see `DECISIONS.md` D023).

## Flow Z - Edit Email - Phase 27

```
account -> addEmail -> editEmail -> changeEmail
```

Current scope: `editEmail` is now a registered route based on the blueprint `/edit-email` screen. The Add Email route exposes a `Review current email` handoff. The screen shows the current local email as verified, hands `Edit email` to the existing `changeEmail` draft route, and keeps `Remove email` locked because removing an account email needs re-authentication, recovery rules, account-session updates, and account persistence.

This lane intentionally stops here: removing an email from an account can affect sign-in, recovery, auditability, and session safety. It requires password re-authentication, recovery rules, account-session updates, audit/security notifications, and account persistence before it can be implemented honestly (see `DECISIONS.md` D024).

## Flow AA - Enter Password To Save - Phase 28

```
account -> addEmail -> editEmail -> enterPasswordToSave
```

Current scope: `enterPasswordToSave` is now a registered route based on the blueprint `/enter-password-to-save` screen. The Edit Email route exposes a `Review password step` handoff. The screen validates empty and short password values, then shows a local "ready for backend re-authentication" summary for a valid-length password without verifying the password, unlocking removal, saving account changes, or mutating local account state.

This lane intentionally stops here: confirming a password for account changes requires real password verification, session/device checks, rate limiting, audit/security notifications, account mutation unlocks, and account persistence before it can be implemented honestly (see `DECISIONS.md` D025).

## Flow AB - Confirm Phone Number - Phase 29

```
account -> addPhoneNumber -> confirmPhoneNumber
```

Current scope: `confirmPhoneNumber` is now a registered route based on the blueprint `/confirm-phone-number` screen. The Add Phone Number route hands off to it only after local phone validation. The screen accepts or pre-fills a phone number, validates empty/short values, and shows a local ready-for-backend-OTP-verification summary. It does not send an OTP, verify a code, or mutate the stored account phone number. Real OTP delivery, code confirmation, phone uniqueness, session updates, rate limiting, audit/security notifications, and account persistence remain backend/provider replacement points.

This lane intentionally stops here: confirming a phone number requires OTP/SMS delivery, code confirmation, phone uniqueness checks, session updates, rate limiting, audit/security notifications, and account persistence before it can be implemented honestly (see `DECISIONS.md` D026).

## Flow L - Podcast - Phase 13

```
notification -> podcast
```

Current scope: podcast notifications now route to a real local podcast list based on the blueprint `/podcast` screen. The route shows local episode content, search/tab affordances, real app image assets, and a local `Watch` state that changes to `Watched locally`. The podcast lane intentionally stops here: streaming playback, episode APIs, comments, uploads/recording, saved-to-account sync, and search filtering are deferred backend/content integrations and should replace the local episode source without changing the notification-to-podcast route (see `DECISIONS.md` D010).

## Flow AF - Reminder - Phase 33

```
notification -> reminder
```

Current scope: the Notifications app bar exposes a reminder calendar action that opens the registered blueprint-backed `/reminder` route. The screen provides a real selectable calendar, updates its selected-date heading, and shows an honest date-specific empty state. It does not create fake reminder records, schedule local alarms, request notification permission, or pretend reminders are persisted.

This lane intentionally stops here: creating reminders requires the reminder data model, persistence/API ownership, recurrence/timezone rules, notification delivery provider, permission behavior, edit/delete rules, and failure states (see `DECISIONS.md` D030).

## Flow AG - Schedules - Phase 34

```
dashboard drawer -> schedules
```

Current scope: the dashboard drawer `Schedule` row opens the registered blueprint-backed `/schedules` route. The screen provides a selectable calendar, an expandable seeded task-reminder card for the current date, and an honest empty state for dates without local schedule data. The card shows active status, frequency, start, and end details. Add, Edit, Share, and Delete remain visibly disabled instead of creating fake schedule mutations.

This lane intentionally stops here: schedule CRUD, recurrence/timezone calculations, live countdowns, persistence/API ownership, sharing/deep links, reminder delivery, permission behavior, and failure states require backend/provider/product contracts (see `DECISIONS.md` D031).

## Flow 36 - Community Invitations Discover - Phase 36

```
circles -> discoverCommunities
discoverCommunities -> requests -> accept invitation -> circles joined state
```

Current scope: the existing `discoverCommunities` route now covers the blueprint `/community-invitations-discover` tabs without adding a duplicate route. `For you` keeps the existing local discover/join behavior, `Requests` shows a local pending invitation and accepts it through the shared joined-community store, and `Drafts` shows an honest empty state.

This lane intentionally stops here: invitation delivery, membership approval workflows, request rejection, draft persistence, invite permissions, moderation, and backend membership sync require backend/community-management contracts (see `DECISIONS.md` D033).

## Flow AJ - Find Mentor - Phase 37

```
dashboard drawer -> findMentor -> specialistDetails -> bookAppointment
dashboard drawer -> findMentor -> bookAppointment
```

Current scope: the dashboard drawer `Providers` row opens the registered blueprint-backed `/find-mentor` route. The screen reuses the existing local specialist store, shows mentor cards with rating and available-time chips, supports category filtering, opens the registered blueprint-backed `specialistDetails` route, and hands `Book Appointment` to the existing local booking form instead of inventing a second scheduling path.

This lane intentionally stops here: live availability, mentor/profile APIs, detailed reviews, pricing/payment rules, booking confirmation, provider calendar sync, and cancellation policies require backend/product contracts (see `DECISIONS.md` D034).

## Flow AK - Specialist Details - Phase 38

```
findMentor -> specialistDetails -> bookAppointment
```

Current scope: `specialistDetails` is a registered route based on `/specialist-details`. It accepts an optional specialist id, renders provider information from the shared local specialist store, supports local day/time chip selection, shows a clear local selected-slot summary, and hands booking to the existing local appointment form.

This lane intentionally stops here: live availability, review details, payment/pricing enforcement, provider profile APIs, confirmed booking slots, calendar sync, and cancellation/error states require backend/product contracts (see `DECISIONS.md` D035).

## Flow AL - Remaining Route Triage - Phase 39

```
specialistDetails -> route triage -> publishedArticles
```

Current scope: after `/specialist-details`, the remaining tail of `routes.json` is component, demo, grid, and marketing/web routes rather than mobile app feature flows. Product work should resume at the earlier unresolved creator/content route `/published-articles`, before payment/subscription/ad/media-upload routes.

This is a documentation-only routing decision; there is no runtime screen for this phase (see `DECISIONS.md` D036).

## Flow AM - Published Articles - Phase 40

```
managePortfolio -> publishedArticles
publishedArticles -> local article detail (same route state)
publishedArticles -> request/drafts deferred states
```

Current scope: `publishedArticles` is now a registered route based on the blueprint `/published-articles` screen. Manage Portfolio exposes an `Articles` handoff into a creator/content library surface with `For you` / `Request` / `Drafts` tabs. The `For you` tab lists locally known portfolio articles and opens an in-page detail view. Request and Drafts show honest deferred states instead of fake backend workflows.

This lane intentionally stops here: subscribers, article-story, add-new-article, edit, publish, delete, comments, analytics, subscriber access, drafts, requests, moderation, account sync, and content persistence remain backend/product contract work (see `DECISIONS.md` D038).

## Flow AN - Route Triage After Creator Content - Phase 41

```
publishedArticles -> route triage -> editYourName (next)
```

Current scope: after the creator/content cluster, the remaining blueprint routes include subscribers, article-story, add-new-article, subscription, ad, payment, media upload/recording, component, grid, and marketing/web routes. Those are not honest frontend-only slices without backend/product contracts. Product work should resume at `/edit-your-name`, the first Manage Profile basic-info draft route that can be built with local validation and no fake profile persistence.

This is a documentation-only routing decision; there is no runtime screen for this phase (see `DECISIONS.md` D039).

## Flow AO - Edit Your Name - Phase 42

```
manageProfile -> editYourName
editYourName -> local name draft
```

Current scope: `editYourName` is now a registered route based on blueprint `/edit-your-name`. Manage Profile `Edit` opens this dedicated basic-info draft route. The screen validates empty and too-short names, then shows a local prepared-name summary for valid input without mutating `PublicProfileLocalStore`, account identity, verification state, or backend profile records.

This lane intentionally stops here: profile name persistence, account identity sync, verification status changes, audit/security records, conflict handling, and backend profile APIs require product/backend contracts (see `DECISIONS.md` D041). The next honest basic-info draft route is `/edit-your-website`.

## Flow AP - Edit Your Website - Phase 43

```
manageProfile -> editYourWebsite
editYourWebsite -> local website draft
```

Current scope: `editYourWebsite` is now a registered route based on blueprint `/edit-your-website`. Manage Profile Basic `Edit website` opens this dedicated basic-info draft route. The screen validates empty and malformed website values, then shows a local prepared-website summary for valid input without mutating `PublicProfileLocalStore`, verification state, account sync, or backend profile records.

This lane intentionally stops here: website persistence, profile verification, account sync, audit/security records, conflict handling, and backend profile APIs require product/backend contracts (see `DECISIONS.md` D043). The next honest Manage Profile draft route is blueprint `/add-desicription`; the blueprint spelling is preserved at the route boundary.

## Flow AQ - Add Description - Phase 44

```
manageProfile -> addDescription
addDescription -> local profile-copy draft
```

Current scope: `addDescription` is now a registered route based on blueprint `/add-desicription`; the blueprint spelling is preserved in the route mapping while the Dart identifier uses the corrected spelling. Manage Profile About `Edit description` opens a dedicated multiline draft route. The screen validates empty and too-short copy, then shows a prepared-description summary without mutating `PublicProfileLocalStore`, publishing public medical claims, running moderation, or calling backend profile APIs.

This lane intentionally stops here: profile-copy persistence, moderation/compliance review for public medical claims, public profile publishing, account sync, audit/security records, conflict handling, and backend profile APIs require product/backend contracts (see `DECISIONS.md` D045).

## Flow AR - Manage Profile Route Triage After Description - Phase 45

```
addDescription -> route triage -> setAddress
```

Current scope: after `/add-desicription`, the remaining Manage Profile-adjacent blueprint routes include `/edit-your-email`, `/add-time-and-day`, and `/set-address`. `/edit-your-email` is not started from Manage Profile because account/security email review and change drafts already exist under Account. `/add-time-and-day` is not started as a duplicate because the Manage Profile Business section already hands off to the local `selectedDates` business-hours draft. The next honest frontend-ready profile route is `/set-address`, which can be implemented as a local address draft without fake persistence or location services.

This is a documentation-only routing decision; there is no runtime screen for this phase (see `DECISIONS.md` D046).

## Flow AS - Set Address - Phase 46

```
manageProfile -> setAddress
setAddress -> local profile-address draft
```

Current scope: `setAddress` is now a registered route based on blueprint `/set-address`. Manage Profile Basic `Edit address` opens the dedicated address draft route, while the prior `Edit website` handoff remains available in the Basic section. The screen validates empty and too-short location text, then shows a prepared-address summary without mutating `PublicProfileLocalStore`, saving the address, geocoding the location, requesting device location, or calling backend profile APIs.

This lane intentionally stops here: profile-address persistence, location/geocoding/map services, device-location permissions, verification status changes, account sync, audit/security records, conflict handling, and backend profile APIs require product/backend contracts (see `DECISIONS.md` D048).

## Flow AT - Remaining Blueprint Tail Triage - Phase 47

```
setAddress -> route triage -> frontend coverage audit
```

Current scope: after the Manage Profile basic-info cluster, the remaining blueprint tail does not expose a new honest frontend-only route to implement. Ads/payments/audience routes need payment, targeting, ad-review, and subscription contracts. Podcast upload/recording needs media ownership, upload, recording, processing, and moderation contracts. Account verification/password/phone/email routes are either already covered by Account local draft routes or require auth backend/code delivery. Feed/comment/Q&A, reminder, schedules, selected dates, and community invitation screens are already represented by existing local slices. Component/demo/frame routes are design-system artifacts rather than product routes.

This is a documentation-only routing decision; the next honest task is a frontend coverage audit before starting any backend/product-dependent lane (see `DECISIONS.md` D049).

## Flow AU - Frontend Coverage Audit - Phase 48

```
route triage -> frontend coverage audit -> backend/product readiness handoff
```

Current scope: the coverage audit compared `ROUTES.md`, `FLOW_MAP.md`,
`DEFERRED_WORK.md`, `routeName.dart`, and `router.dart`. All non-`login` route
constants have `generateRoute` cases, `ROUTES.md` records 68 wired routes, and
the remaining blueprint gaps are classified as backend/product seams rather
than frontend-only screens. The intentionally unwired `login` constant remains
reserved.

This is a documentation-only audit decision; the next honest task is a backend/product readiness handoff that groups deferred seams by required contract before any deeper integration begins (see `DECISIONS.md` D050).

## Flow AV - Backend/Product Readiness Handoff - Phase 49

```
frontend coverage audit -> backend/product readiness handoff -> final handoff review
```

Current scope: `DEFERRED_WORK.md` now groups remaining seams by backend/product contract: auth/account, profile/public identity, scheduling/provider availability, content/community/moderation, health/readings/export, messaging/notifications, payments/ads/subscriptions, media/podcast/upload, emergency/location, and sharing/deep links. The handoff preserves the frontend replacement paths: choose one contract group, define API models and failure states first, then replace the relevant local store or repository seam without rewriting the completed routes.

This is a documentation-only readiness decision; the next honest task is a final handoff review before backend/product contract selection (see `DECISIONS.md` D051).

## Flow AW - Final Frontend Handoff Review - Phase 50

```
backend/product readiness handoff -> final handoff review -> backend/product contract selection
```

Current scope: final review confirms the frontend route surface is ready for backend/product contract selection. Docs and route status still agree on 68 wired routes; `login` remains the only reserved unwired route constant; `DEFERRED_WORK.md` groups replacement paths by contract; and no additional honest frontend-only route slice is selected before backend/product contracts exist.

This is a documentation-only final handoff decision; the next honest task is choosing the first backend/product contract group to integrate while keeping locked controls disabled until real contracts exist (see `DECISIONS.md` D052).

## Flow AX - First Backend Contract Selection - Phase 51

```
final handoff review -> select first backend contract group -> auth/session/account contract definition
```

Current scope: backend/product work starts with `Auth/session/account persistence`. This group is selected first because real user identity and session ownership are prerequisites for account settings, profile persistence, readings sync, scheduling, messaging, notifications, communities, content ownership, payments, and audit/security behavior. The decision does not enable any locked controls yet.

This is a documentation-only backend selection decision. The next task must define the auth/session/account contract before implementation: API style, environment/base URL rules, session storage, auth/account models, validation/error states, OTP/email-code provider boundaries, and repository replacement plan (see `DECISIONS.md` D053).

## Flow M - Search / Consultant Discovery - Phase 14

```
dashboard Search tab -> search
search -> local profile sheet
```

Current scope: the dashboard Search tab now hosts a real local consultant discovery slice based on the blueprint `/search` and `/search-find-a-consultant` references. Users can search local specialist data, filter by category, open a local profile sheet, and mark a consultation request locally. The search lane intentionally stops here: live availability, appointment time/type selection, calendar booking, payments, provider profile APIs, and real scheduling are explicit backend replacement points and are not faked in this slice (see `DECISIONS.md` D011).

## Flow N - Health Record - Phase 15

```
healthRecord
readings/bloodSug local state -> healthRecord
```

Current scope: `healthRecord` is now a registered route with a real local health-file summary based on the blueprint `/health-record` screen. It shows local vitals cards and reflects the latest saved blood sugar reading from the readings store. The health-record lane intentionally stops here: the `Download` affordance is visible but disabled/deferred until backend health-history, report export, and synced-vital support exists (see `DECISIONS.md` D012).

## Flow O - Saved Articles - Phase 16

```
articles -> save article locally
savedArticles -> saved list -> saved article detail
savedArticles -> articles
```

Current scope: `savedArticles` is now a registered route based on the blueprint `/saved-articles` screen. It reuses the existing local article content/store, shows an honest empty state, lists locally saved articles, opens a saved article detail view, marks reads locally, and removes saved articles. This lane intentionally stops here: account sync, `subscribers`, `article-story`, drafts, creator publishing, author/publication analytics, comments, and content APIs remain backend/content integration work rather than being faked inside this route (see `DECISIONS.md` D013).

## Flow P - Case Studies - Phase 17

```
caseStudies -> case study detail (same route state)
```

Current scope: `caseStudies` is now a registered route based on the blueprint `/case-studies` and `/case-study-story` screens. It shows local case-study content, working `All` / `Case studies` / `Best` filters, in-page detail reading, and local read state. This lane intentionally stops here: content APIs, verified clinical review, author/publication records, comments, sharing, saved-to-account sync, and moderation should replace the local source without changing the list/detail flow (see `DECISIONS.md` D014).

## Flow Q - Public Profile - Phase 18

```
publicProfile -> messages
publicProfile -> bookAppointment
```

Current scope: `publicProfile` is now a registered route based on the blueprint `/profile-view-from-user` screen. It shows a read-only local professional profile with article previews, specializations, contact details, about text, and profile sections. `Message` routes to the existing messages screen and `Schedule` routes to the existing local booking form. This lane intentionally stops here: portfolio, podcast/media profile content, sharing, provider scheduling, public reviews/testimonies, verified public identity, profile APIs, and subscription/upgrade behavior are deferred until backend/product rules exist (see `DECISIONS.md` D015).

## Flow R - Owner Circle Profile - Phase 19

```
ownerCircleProfile
createCommunity -> ownerCircleProfile owner variant
```

Current scope: `ownerCircleProfile` is now a registered route based on the blueprint `/owner-circle-profile` screen. It reuses the community profile surface in owner mode with local owner-circle content, member previews, articles, coming/recent events, and an explicit owner settings section. The owner-circle lane intentionally stops here: permissions, member invitations, role changes, moderation, editing circle details, sharing, favourites sync, reporting, exiting, and destructive circle deletion need backend/community-management and product safety rules before they can be implemented honestly (see `DECISIONS.md` D016).

## Flow S - Manage Profile - Phase 20

```
manageProfile -> editYourName
manageProfile -> editYourWebsite
manageProfile -> setAddress
manageProfile -> addDescription
manageProfile -> settings
manageProfile -> messages
manageProfile -> selectedDates
```

Current scope: `manageProfile` is now a registered route based on the blueprint `/manage-profile` screen. It shows local professional profile management sections for Basic, About, Business schedule, and Articles. `Edit` opens the dedicated local `editYourName` draft route, Basic `Edit address` opens `setAddress`, Basic `Edit website` opens `editYourWebsite`, About `Edit description` opens `addDescription`, `Message` opens the existing messages route, and Business `Edit hours` opens the route-local `selectedDates` draft. The manage-profile lane still avoids pretending profile basics, profile copy, address/location data, or business hours were persisted.

Backend replacement target: keep the screen -> profile state/controller -> profile repository boundary when this lane resumes. The repository should expose a profile summary read model, profile/basic update result states, business-hours read/update operations, article/media summary reads, and explicit unavailable/error states for gated capabilities. Backend integration should replace the local source behind that boundary, not rewrite the `manageProfile` route or its existing settings/messages handoffs.

## Flow AH - Selected Dates / Business Hours - Phase 35

```
manageProfile -> selectedDates
```

Current scope: the Manage Profile Business section opens the registered blueprint-backed `/selected-dates` route. The screen supports date selection, all-day or start/end hours, end-after-start validation, a route-local prepared draft summary, and the blueprint weekly closed-day overview. It does not mutate the profile schedule.

This lane intentionally stops here: profile/business-hours persistence, timezone rules, overlapping-hours validation, multiple hour sets, upgrade entitlements, server conflict handling, and availability APIs require backend/product contracts (see `DECISIONS.md` D032).

## Flow T - Manage Portfolio - Phase 21

```
manageProfile -> managePortfolio
managePortfolio -> settings
managePortfolio -> messages
```

Current scope: `managePortfolio` is now a registered route based on the blueprint `/manage-portfolio` screen. `Manage Profile` hands off from the `Articles` section into a local managed portfolio surface with `Page` / `Circles` tabs, local portfolio content, and a replaceable local portfolio store. `Edit` opens the existing local `settings` form and `Message` opens the existing messages route. Events, Boost, Podcast, Share, Add new article, Upload new podcast, and Upgrade stay visibly disabled/deferred because publishing, media upload, subscriptions, payments, moderation, and product-approved sharing need backend/product contracts before they can be implemented honestly.

This lane intentionally stops here: the adjacent blueprint screens (`/add-new-article`, `/add-new-podcast`, `/recording`, `/adverise`, `/design-ad`, `/budget-duration`, `/payment-details`, `/select-payment-method`, and subscription plan screens) cross into creator publishing, media processing, ad review, subscriptions, and payments. Those should resume only after backend/product contracts exist (see `DECISIONS.md` D018).
