# APP-P1-021 Active-Route UX And Accessibility

## Goal

Close visual consistency and accessibility gaps across the active Phase 1
patient and professional experience without changing backend authority, adding
product scope, or reviving deferred community/content surfaces.

The active navigation remains:

- Patient: Home, Find Care, Appointments, Messages.
- Professional: Home, Schedule, Appointments, Messages.
- Header: Notifications and Account/Profile.

## Work Status

APP-P1-021A merged in PR #172. It aligns the shared `CarenetColors`
healthcare-green scale and active Material color schemes, improves the shared
`CarenetButton` semantic tap target and enlarged-text behavior, corrects
Schedule wording, and reconciles the live route inventory. APP-P1-021B merged
in PR #201 with 619 passing tests and green GitHub analyze/test/debug-APK/
release-lint checks. APP-P1-021C merged in PR #202, routing obsolete
`medicalEdit` to the deferred page; its CI passed 620 tests, analysis, debug
APK, and Android release checks. APP-P1-021D merged in PR #203 at
`5be33cbec2ebdb9a2b0036ad879a68cacd6395ba`, adding accessible Back semantics
to the active professional profile editors. APP-P1-021E merged in PR #204 at
`010547811430a80bc15e72c6c34d2ae223457106`; its 622-test suite, analyzer,
Ubuntu debug APK, Android release lint, and release configuration regressions
passed in CI. It covers the professional Schedule editor at compact width and
2x text. APP-P1-021F added accessible announcements for changing Account
feedback and regression coverage for Account actions; PR #205 merged at
`ebe50184dcd3063ec9c138e2b6b127cc08bab8a0`, with 623 CI-passing tests. These
bounded changes are not a whole-app accessibility sign-off.

This foundation does not certify every screen. Active screens still need
route-by-route checks for contrast, semantics, focus order, keyboard operation,
tap targets, narrow layouts, and largest supported text. The route inventory is
79 constants and 78 router cases; `login` remains reserved and unwired.

## Shared Foundations

APP-READY-058 follow-up evidence (2026-10-10): compact 320x568 / 2x-text
tests reproduced a 299px horizontal overflow in active consultation controls
and a 380px vertical overflow in unsupported-role recovery. The controls now
wrap, expose one actionable semantic button each, and remain operable in
video/audio modes; unsupported-role recovery scrolls when enlarged text needs
more height. User-facing copy was clarified for Find Care configuration,
booking-readiness retry, Schedule timezone validation, verification-document
metadata, finance, and appointment summaries. The focused follow-up group
passes 115 tests and analyzer is clean. Route audits also found that Account
had no retry after `/account/me` failed, onboarding catalog load errors were
not announced as live regions, and appointment, verification, and consultation
copy exposed implementation terminology. Account now retries without
discarding authoritative identity, onboarding errors are announced, and the
affected copy is user-facing. Payment failure copy has a regression that
rejects raw/internal error text. The consultation prejoin test uses 320x568
and 2x text and proves the backend-authorized waiting action remains reachable
without overflow. The local full-suite process stalled before its first test
with no Dart CPU progress and the local Gradle build also stalled. Exact-head
CI for APP-READY-058 PR #224 passed analysis, 733 tests, debug APK, Android
release lint, signing, and environment checks. The integration base had 732
tests; one payment-error regression was added and none were removed, skipped,
or disabled. Manual TalkBack, focus-order, and physical-device proof remain
open.

- Primary, success, error, and information text/surface pairs are checked at
  WCAG normal-text contrast of at least 4.5:1.
- `CarenetButton` has one labelled button semantic with a real tap action, a
  minimum 48 logical-pixel hit target, and content-driven height under enlarged
  text.
- New shared components use `CarenetColors`; legacy screen-specific
  `AppColors` usage is migrated only when that screen is audited.
- User-facing Schedule copy describes recurring availability plainly and does
  not expose implementation details.

## Per-Route Audit Record

For each active route, record narrow and large-text layout, contrast, semantics,
focus order, keyboard behavior where relevant, minimum tap target, loading/error
states, and one end-to-end task path. Do not mark a route passed without a test,
inspection artifact, or explicit device limitation.

Routes to audit include the auth/onboarding gateway and forms, Home, Find Care,
professional detail and booking, Appointments and detail, professional Schedule,
Messages, Notifications, Account/Profile, professional verification/finance,
and the appointment-linked consultation.

Deferred source screens are not part of the active-route acceptance sweep unless
they remain reachable through a visible or direct route. Keep their sources
recoverable and record any disconnection separately.

### Evidence Map

The 79 route constants are not 79 distinct active screens: aliases share
widgets, and deferred identifiers resolve to `DeferredFeaturePage`. Existing
automated evidence is organized by flow rather than one test file per route.
The table records that evidence without treating a flow test as proof of visual
or accessibility conformance.

| Active flow family | Existing automated evidence | Accessibility evidence and open limit |
| --- | --- | --- |
| Authentication, recovery, signup, session restore | `sign_in_flow_test.dart`, `sign_up_flow_test.dart`, `booking_signup_boundary_test.dart`, `finish_sign_up_test.dart`, `password_recovery_flow_test.dart`, `session_restore_guard_test.dart`, and `session_resilience_test.dart` | Sign-in, email signup, role selection, and finish-signup form have 320x568 / 2x-text flow coverage; password visibility, recovery action sizing, and recovery back controls are labelled. Screen-reader/keyboard and physical-device proof remain open. |
| Patient onboarding and readiness | `onboarding_gateway_test.dart`, `profile_setup_test.dart`, `onboarding_readiness_route_resolver_test.dart` | Welcome choices and patient/professional profile setup have 320x568 / 2x-text coverage; setup flows include required catalogs and save handoffs. Screen-reader/keyboard and physical-device proof remain open. |
| Dashboard, role navigation, Home, Find Care, profile detail, booking | `dashboard_shell_test.dart`, `home_tab_shell_test.dart`, `search_flow_test.dart`, `specialist_details_flow_test.dart`, and `booking_intent_and_controller_test.dart` | Patient dashboard destinations, Find Care query/profile handoff, and professional-detail booking confirmation/success are exercised at 320x568 / 2x text. Find Care category chips and booking date chips have at least 48dp targets; selected requestable times expose radio-group and selected semantics. Keyboard, TalkBack, and remaining booking states are not certified. |
| Appointments and professional Schedule | `appointments_flow_test.dart`, `appointment_experience_flow_test.dart`, `appointment_experience_policy_test.dart`, `professional_schedule_test.dart`, and `scheduling_repository_test.dart` | Patient and professional appointment list/detail behavior includes a 320x568 / 2x-text flow through an authorized professional action. Schedule availability rows distinguish Active and Inactive from backend state; the editor's weekday and start/end controls remain operable at 320dp / 2x text. Appointment detail uses user-facing action copy. Physical keyboard/TalkBack and device proof remain open. The appointment-list back control has a tooltip. |
| Account, profile management, verification, finance | `account_flow_test.dart`, `manage_profile_flow_test.dart`, `financial_flow_test.dart`, and `financial_contract_test.dart` | Finance has 320x568 / 2x-text coverage through populated financial activity and payout-bank/account entry. Manage Profile and verification documents have compact 2x-text scroll coverage with responsive metadata and 48dp actions. Account profile copy avoids implementation details. APP-P1-021F covers Account feedback live regions, 48dp Back action, and a scrollable deletion confirmation at compact width / 2x text; keyboard-focus and device acceptance remain open. |
| Messages, notifications, consultation | `messaging_flow_test.dart`, `chat_route_structure_test.dart`, `notification_inbox_test.dart`, `notification_coordinator_test.dart`, and consultation controller tests | Populated Messages and Chat participant names and populated notification title/body have compact 320x568 / 2x-text widget coverage, semantics/tap checks, and no-layout-exception assertions. Existing honest-state, routing, and provider/controller behavior remains covered. Real screen-reader, focus-order, and hardware permission behavior are not established by these tests. |
| Deferred route aliases | `auth_route_authority_test.dart`, `account_flow_test.dart`, and route registration tests | Several old identifiers intentionally render `DeferredFeaturePage` or a canonical screen. Their legacy source screens are not represented as active routes in this accessibility sweep. |

### Active Widget Matrix

This matrix names the distinct router destinations and aliases. “Flow test” is
behavioral coverage, not an accessibility pass. Large-text, focus-order,
keyboard, and screen-reader checks are marked only where explicitly exercised.

| Router destination / aliases | Current screen | Evidence | Accessibility result |
| --- | --- | --- | --- |
| `splash` | SplashScreen | `widget_test.dart`, `session_restore_guard_test.dart` | At 320x568 / 2x text, brand text remains present and exposed with its text semantics, no layout exception occurs, and the onboarding handoff still completes. Screen-reader/device proof remains open. |
| `onboarding` | OnboardingView | `onboarding_gateway_test.dart` | At 320x568 / 2x text, browse, create-account, and sign-in choices remain reachable by scrolling without layout exceptions; sign-in routing is exercised. Screen-reader/keyboard and device proof remain open. |
| `finishSignUp` | FinSignUp | `finish_sign_up_test.dart` | At 320x568 / 2x text, the form, validation, legal links, and submit action remain scroll-accessible without layout exceptions; backend submission and failure are covered separately. Screen-reader/keyboard and device proof remain open. |
| `signUpRole` | SignUpRoleSelectionPage | `booking_signup_boundary_test.dart` | Normal role choice and booking-origin patient-only signup are exercised at 320x568 / 2x text, including the next signup-method step; screen-reader/keyboard and device proof remain open. |
| `communityAgreement`, `notificationAgreement`, `patientOnboardingSetup` | PatientOnboardingSetupPage | `profile_setup_test.dart` | Patient setup is exercised at 320x568 / 2x text through profile fields, explicit catalog choices, save, and readiness routing without layout exceptions. Screen-reader/keyboard and device proof remain open. |
| `medicalAgreement`, `medicalProfessional`, `manageProfile` | ProfessionalOnboardingSetupPage | `profile_setup_test.dart`, `manage_profile_flow_test.dart` | Professional setup is exercised at 320x568 / 2x text through identity, credential, and practice fields, required catalog choices, save, and verification-document handoff. Screen-reader/keyboard and device proof remain open. |
| `signUpPhone`, `signUpEmail` | SignUpEmail | `sign_up_flow_test.dart` | Email signup has 320x568 / 2x-text required-field and sign-in handoff coverage, with green heading hierarchy; physical screen-reader/keyboard proof remains open. |
| `signInPhone`, `signInEmail` | SignInEmail | `sign_in_flow_test.dart` | Password/recovery/provider semantics and 320x568 at 2x text covered. |
| `enterEmail`, `enterPassword` | Password recovery request and legacy tokenless alias | `password_recovery_flow_test.dart` | A successful reset request stays on email entry and gives generic account-enumeration-safe guidance; the legacy tokenless route fails closed to the missing-token confirmation state. Only the reset-link token route accepts a new password. Compact request and token confirmation flows are covered; physical screen-reader/keyboard proof remains open. |
| `resetPasswordConfirm`, `emailVerificationConfirm` | Token confirmation pages | `password_recovery_flow_test.dart`, `auth_route_authority_test.dart`, `account_flow_test.dart` | Password-reset and email-verification success flows are exercised at 320x568 / 2x text, with confirmation actions scroll-accessible and no layout exceptions. Screen-reader/device proof remains open. |
| `medicalEdit` | DeferredFeaturePage (legacy `UserEdit` source retained) | `auth_route_authority_test.dart` | Direct legacy route fails closed; compact 320x568 / 2x-text test checks the explanation and accessible Return home action. Authoritative broad profile editing remains deferred. |
| `dashboard` | Dashboard | `dashboard_shell_test.dart` | Role destinations, header actions, tab persistence and Android back covered. Patient navigation and professional identity/status, header/primary-action tap semantics, Schedule handoff, and scrollable appointment state are checked at 320x568 / 2x text. Physical keyboard/TalkBack and device accessibility remain open. |
| `search`, `findMentor`, `bookAppointment`, `publicProfile` | SearchShellPage | `search_flow_test.dart`, `find_mentor_flow_test.dart`, `public_profile_flow_test.dart` | Canonical discovery and legacy alias behavior covered; patient name query, clear, scroll, and profile handoff are checked at 320x568 / 2x text. Category-chip targets are at least 48dp and remain horizontally reachable at compact width. Keyboard, TalkBack, and wider discovery states remain uncertified. |
| `specialistDetails` | SpecialistDetailsShellPage | `specialist_details_flow_test.dart` | Patient detail, backend time selection, confirmation, request-sent result, and Appointments handoff are checked at 320x568 / 2x text. Date choices have 48dp targets; time options announce their professional-time label and selected radio state. Dialog content scrolls while actions remain usable; other screen-reader states remain open. |
| `appointments` | AppointmentsShellPage | `appointments_flow_test.dart`, `appointment_experience_flow_test.dart` | Cards label displayed appointment instants as viewer-local time; at 320x568 / 2x text, a professional can scroll to a card and open canonical detail. Screen-reader, keyboard, and device proof remain open. |
| `appointmentDetail` | AppointmentDetailShellPage | `appointment_experience_flow_test.dart`, `appointment_experience_policy_test.dart` | Date and requested timestamps explicitly identify viewer-local time. At 320x568 / 2x text, the status and authorized Accept action remain reachable by scrolling. Other role/status, screen-reader, and device states are not certified by that flow. |
| `consultation` | ConsultationShellPage | `consultation_controller_test.dart` | Pre-join countdown remains labelled for navigation but is not a live region, avoiding per-second screen-reader announcements; actual device permission/accessibility proof remains open. |
| `account`, `deleteAccount` | AccountShellPage | `account_flow_test.dart` | Account tiles remain scroll-reachable at 320x568 / 2x text, including the final deletion action; screen-reader, focus-order, and device acceptance remain open. |
| `professionalVerificationDocuments` | ProfessionalVerificationDocumentsShellPage | `manage_profile_flow_test.dart` | Verification readiness, upload/list states, and long metadata now have 320x568 / 2x-text scroll coverage; screen-reader and device proof remain open. |
| `professionalFinance` | ProfessionalFinanceShellPage | `financial_flow_test.dart`, `financial_contract_test.dart` | 320x568 / 2x-text populated full-scroll and payout-account entry are covered; platform screen-reader, focus-order, and device acceptance remain open. |
| `editYourName`, `editProfessionalDetails`, `addDescription` | Professional profile editor shells | `manage_profile_flow_test.dart` | At 320x568 / 2x text, the labelled Back control exposes a button/tap semantic and returns to Manage Profile from all three editors. Other screen-reader, focus-order, and device behavior remain open. |
| `messages` | MessagesPage | `messaging_flow_test.dart`, `messaging_controller_test.dart` | Honest inbox/route states covered; keyboard/screen-reader conversation task open. |
| `chat`, `message` | ChatPage | `chat_route_structure_test.dart`, `messaging_flow_test.dart` | Failed-message retry now retains a 48dp action target; keyboard focus order and physical screen-reader use remain uncertified. |
| `notification` | NotificationsPage | `notification_inbox_test.dart`, `dashboard_shell_test.dart` | Unread state is included in row semantics and removed after read; broad large-text and physical screen-reader announcement order remain open. |
| `notificationPreferences` | NotificationPreferencesPage | `account_flow_test.dart`, `notification_inbox_test.dart`, `notification_coordinator_test.dart` | At 320x568 / 2x text, all seven preference sections remain scroll-reachable, the last section's Push/Email switches remain available with at least 48dp height, and no layout exception occurs; screen-reader and device acceptance remain open. |
| `reminder`, `schedules`, `selectedDates` | ReminderShellPage, SchedulesShellPage, SelectedDatesShellPage | `professional_schedule_test.dart`, `manage_profile_flow_test.dart` | Schedule labels each backend recurring window Active or Inactive, including row semantics. Reminder/schedules direct-route accessibility evidence remains incomplete. |
| Deferred aliases | DeferredFeaturePage | `auth_route_authority_test.dart`, route classification/registration tests | Deferred screen behavior is intentionally not treated as active feature accessibility coverage. |

Every row without an explicit accessibility check remains **not certified**;
the matrix is a gap ledger rather than a conformance claim. Physical device
acceptance is still required before release.

### APP-P1-021B Findings Applied So Far

- The Google sign-in control previously overflowed at a 320 logical-pixel width
  with 2x text. Its label now wraps within the available width, it has a single
  named button semantic, and its hit target is at least 48 logical pixels.
- The email sign-in password toggle now announces Show/Hide password, and the
  Forgot Password action uses a padded Material button with a 48-pixel minimum
  target.
- Back controls on active sign-in/recovery/onboarding and Account/Profile,
  appointment-list screens now expose a Back label (or the more specific
  Change account type label when appropriate).
- The dashboard's selected navigation item now uses `CarenetColors.brand`.
- Patient professional-detail booking now has a 320x568 / 2x-text flow regression.
  It caught vertical overflow in the long confirmation dialog; the confirmation
  and request-sent dialogs now allow their content to scroll while preserving
  the available action buttons.
- The professional appointment card previously overflowed at 320x568 / 2x text
  because its trailing status column consumed the tile width. Status now follows
  the date in the vertically flowing subtitle; the chevron remains trailing.
  A compact large-text test scrolls from the professional appointment list into
  detail and verifies the authorized Accept action remains reachable.
- Manage Profile and verification metadata now stack labels above long values
  at compact widths or enlarged text. Profile inline actions preserve a 48dp
  target, and the verification document type field expands to keep its selected
  label readable. Compact 2x-text tests cover both flows.
- Professional Finance summary/activity rows and payout-confirmation actions
  stack at constrained widths; section headings wrap within their surfaces. A
  320x568, 2x-text widget test traverses populated activity and enters the
  payout-bank/account flow without layout exceptions.
- Active email signup now uses the CareNet green heading treatment and concise
  helper copy. A 320x568, 2x-text test covers validation feedback and the
  existing sign-in handoff without changing role-first account creation.
- Signup role cards now wrap their title and badge instead of forcing both into
  one horizontal row. Tests cover normal role selection and booking-origin
  patient-only signup at 320x568 with 2x text, including progression to the
  next signup step without layout exceptions.
- The finish-signup form has 320x568 / 2x-text coverage for reaching all fields,
  required-field feedback, legal links, and submission through its scroll view.
  The tested layout did not require a visual or behavioral change.
- Patient onboarding setup has 320x568 / 2x-text coverage through name and city
  entry, required state/country/health-interest selections, save, and the
  backend-readiness destination. The tested flow needed no visual or behavior
  change.
- Professional onboarding setup has 320x568 / 2x-text coverage through its
  identity, credential, and practice fields, profession/state/country choices,
  save, and verification-document handoff. The tested layout required no
  application change; screen-reader/keyboard and device checks remain open.
- The onboarding welcome gateway has 320x568 / 2x-text coverage confirming its
  browse, create-account, and sign-in choices remain reachable through the
  scroll view without layout exceptions. The tested layout required no
  application change; screen-reader/keyboard and device checks remain open.
- The splash screen has 320x568 / 2x-text coverage for visible and semantically
  named brand text, no layout exceptions, and the existing onboarding startup
  handoff. The tested layout required no application change; device proof
  remains open.
- Password-recovery email entry and new-password validation have compact-width,
  2x-text coverage for scrolling to the primary action without layout
  exceptions. Password-reset and email-verification token success flows are
  also exercised at 320x568 / 2x text with their confirmation actions reachable.
- The Account screen now has a 320x568 / 2x-text regression that scrolls through
  the account options to the final deletion action and checks the tile retains
  a 48dp minimum height. Screen-reader, keyboard-focus, and device proof remain
  open.
- Notification preferences now have a 320x568 / 2x-text regression covering
  reachability of all seven category sections, the final Push/Email controls,
  a 48dp minimum switch-row height, and absence of layout exceptions.
  Screen-reader and device proof remain open.
- Failed Chat sends now offer a retry target with a 48dp minimum height; a
  widget regression drives an actual send failure and measures that action.
- Unread notifications now expose an explicit `Unread` semantics label on the
  row's visual indicator; the inbox regression confirms the label disappears
  after the authoritative read action.
- Consultation countdown text remains navigable but is no longer a live region,
  preventing its one-second display refresh from repeatedly interrupting a
  screen reader. A semantics regression asserts that it is not announced live.
- Password-reset requests now remain on email entry and show generic guidance
  that does not confirm whether an account exists. The legacy tokenless password
  route fails closed; only the reset-link confirmation route exposes password
  fields. Tests cover request success, pending state, and missing-token routing.
- Appointment list and detail dates are explicitly labelled "Local time" so a
  viewer does not mistake device-local rendering for a professional timezone.
  A flow regression checks both surfaces.
- Find Care category choices and professional-detail date choices retain at
  least 48 logical pixels of height at compact widths. A requestable-time option
  exposes a single-select radio group and its selected state to assistive
  technology.
- Professional Schedule labels each persisted window Active or Inactive; it
  does not infer activity from a weekday or time range. Its regression checks
  the inactive row's semantic label.
- `RouteName.manageProfile` currently opens `ProfessionalOnboardingSetupPage`;
  the legacy `ManageProfileShellPage` is not registered as the account
  destination. This pass does not reactivate that legacy social-era source.
- APP-READY-052 adds a professional Home compact-text regression covering the
  verified identity/status, header controls and their tap semantics, primary
  Schedule action semantics and route, all four professional tabs, and the
  scrollable no-appointment state. PR #216 exact-head CI passed all 718 tests,
  analysis, Android debug build/lint, and release configuration regressions.
  Source/test review found no demonstrated production layout defect, so no
  runtime widget was changed. This does not certify focus order, TalkBack
  announcement quality, or physical-device use.
- APP-READY-053 adds the corresponding patient Home check at 320x568 and 2x
  text: authenticated profile identity, four patient destinations, accessible
  Notifications/Account actions, the primary Find Care route, and the truthful
  no-appointments state with its Find Care action. The code head's CI passed
  all 719 tests and Android/analyzer gates; final documentation-head CI is
  pending before merge. No runtime widget or cloud service is changed. This
  test does not certify focus order, TalkBack announcement quality, or
  physical-device use.

These repairs are bounded findings, not a claim that all active routes have
passed every contrast, keyboard, focus-order, or largest-text criterion. The
remaining rows above need targeted follow-up where the automated evidence is
missing, followed by physical Android/iOS accessibility checks before release.

## Boundaries

- Do not add posts, short-form video, creator publishing, or community navigation
  through this accessibility task. A changed product direction requires a
  separately approved scope, moderation/safety policy, storage and delivery
  design, and cost gate.
- Do not claim full accessibility conformance from shared-token tests.
- Physical-device TalkBack, keyboard, and platform acceptance remain a later
  release gate after automated and cloud checks.
- Payments remain gated behind the production-readiness plan's final explicit
  user confirmation; this work does not activate or deploy payment credentials.

## Next Work

Continue with the single `NEXT` row in `AI_HANDOFF.md`. Track findings by route
and severity; repair only those within the approved accessibility/UX boundary,
otherwise record them for an explicitly scoped slice.
