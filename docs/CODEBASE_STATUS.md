# Codebase status

**Last updated:** 2026-07-14 reset/verification token-confirm routes wired.

Honest snapshot of `Mobile-App-master` so a new chat does not rediscover problems.

For a consolidated list of local/mock seams and skipped backend work, see `DEFERRED_WORK.md`.

---

## Maturity level

**~15-20% of blueprint product scope.**
**Phase 0:** done (spine). **Phase 1:** done (tokens + shared input/button + adoption on onboarding/sign-up phone/email). **Phase 2:** done. **Phase 3:** done. Most screens are still UI sketches.

---

## What works today

| Item | Details |
|------|---------|
| App entry | `lib/main.dart` -> `CarenetApp` in `lib/app.dart` |
| Start screen | `RouteName.splash` (not notifications) |
| Splash -> session guard | 800ms then `AuthRepository.restore()` routes usable stored sessions to `dashboard`; missing, invalid, or failed restore falls back to `onboarding` |
| Named routes | **70 wired routes** in `router.dart` plus the reserved unused `login` constant (see `ROUTES.md`) |
| Onboarding UI | 3 pages, skip, next, get started -> sign up phone |
| Sign-up phone | Validates country/region + phone, then routes to `finishSignUp` |
| Sign-up email | Validates email, then routes to `finishSignUp` |
| Sign-up to sign-in links | "Already have an account? Sign in" routes to `signInPhone` / `signInEmail` from matching entry screens |
| Sign-in phone | Validates country/region, phone, and password locally, then routes to `dashboard` |
| Sign-in email | Validates email and password locally, then routes to `dashboard` |
| Password recovery | `Forgot Password?` routes to `enterEmail`; valid email requests reset through `AuthRepository.requestPasswordReset`; `resetPasswordConfirm` can complete password reset only when opened with a transient reset token, sends `{ token, newPassword }`, clears local session, and returns to email sign-in. Production app-link setup remains deferred |
| Finish sign-up | Validates required fields, date picker birthday, password strength, and confirm password match before routing to `communityAgreement` |
| Social auth rows on sign-up | Google / Facebook / Apple render as explicitly disabled until backend/provider integration exists |
| Dashboard shell | Bottom nav tabs all render real screens; Home tab keeps drawer; Notifications now opens the dedicated notifications feature screen directly |
| Search slice | The dashboard Search tab and `search` route now show real local consultant discovery with keyword filtering, category chips, specialist cards, local profile sheet, and local request state. The search lane intentionally stops here before live availability, appointment time/type selection, payment, real booking, and provider-profile APIs |
| Home inner tabs | `Feed`, `Messages`, and `Articles` all render real content; Messages preview hands off to the dedicated `messages` route |
| Messaging flow | Dedicated `messages` list now routes into the canonical seeded `chat` screen |
| Notifications screen | Dedicated page no longer embeds a fake secondary app-level bottom navigation row |
| Notification card routing | `Complete your profile` -> `medicalEdit`, `Dr. Lagbaja has replied your message.` -> `messages`, `You are missing updates` -> `dashboard`, `Your appointment is booked` -> `appointments`, `Update your reading...` -> `readings`, `Dr. Tamedu has published a new article` -> `articles`, `Your emergency request is approved.` -> `emergency`, and `Dr. Lakasegbe has published a new podcast` -> `podcast` |
| Notification categories | `All`, `Events`, `Appointment`, and `Messages` now filter the list honestly; `Payment` is explicitly disabled until that feature surface exists |
| Legacy messaging cleanup | `Chat_2.dart` and `Message.dart` removed; `RouteName.message` now reuses the shared chat page as a compatibility alias with an unavailable-notice variant |
| Readings flow | `readings` now routes into `manageReadings` via the `Add new Readings` tile, and `Done` returns to `readings` |
| Readings export state | `Download Readings` is intentionally deferred and labeled as such until add-reading/device onboarding exists |
| Guided readings lane | Selecting `Blood Sugar` in `manageReadings` now continues into `addDevice`, then into the dedicated `bloodSug` destination shell |
| Blood sugar entry | `bloodSug` now has a real local form: required numeric reading, required context selection, optional note, and a saved-state summary card |
| Readings dashboard sync | Saved blood sugar entries now update the `Blood Sugar` card on `readings` and show a latest-entry summary when the user returns |
| Health record slice | `healthRecord` is a real local health-file summary route with vitals cards and latest blood sugar state from the readings store. The lane intentionally stops here before backend health history, report export, and synced-vital support |
| Blood sugar history/trend | The `bloodSug` lane now keeps short local history and shows a simple up/down trend summary once at least two readings exist |
| Blood sugar history cleanup | Saved blood sugar rows can now be deleted, and the latest-entry/trend state recalculates from the remaining local history |
| Appointments slice | `appointments` now shows real local upcoming/recent appointment sections and a working `Book appointment` handoff into `bookAppointment` |
| Booking form | `bookAppointment` now has a real local form with validation and a saved booking draft summary |
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
| Frontend coverage audit | No remaining honest frontend-only route gaps were found in the audited docs/router surface. All non-`login` route constants have router cases, `ROUTES.md` records 68 wired routes, and remaining gaps are backend/product seams documented in `DEFERRED_WORK.md` (`DECISIONS.md` D050) |
| Backend/product readiness handoff | `DEFERRED_WORK.md` now groups deferred seams by contract group and replacement path so backend work can replace local stores/repositories without rewriting completed frontend routes (`DECISIONS.md` D051) |
| Final frontend handoff review | Frontend route coverage is ready for backend/product contract selection. Docs/router status agree on 68 wired routes, `login` remains the only reserved unwired constant, and no additional honest frontend-only route slice is selected before backend/product contracts (`DECISIONS.md` D052) |
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

## Design debt (fix in Phase 2+)

| Issue | Where |
|-------|--------|
| `finishSignUp` still uses legacy `BorderedTextInput` and wrapper button | `lib/features/Authentication/presentation/pages/sign_up_con.dart` |
| Legacy blue (`AppColors`) in theme / non-button UI | `app_colors.dart`, `theme.dart`, messaging - later phases |
| Messaging screens use iOS `#007AFF`, not app tokens | `Messages.dart`, `Notification.dart`, `Chat.dart` |
| `get_it` not registering services | `injection.dart` empty |
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

No dedicated features yet for: creator tools, subscriptions/ads, backend-backed public profile/security flows.

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
