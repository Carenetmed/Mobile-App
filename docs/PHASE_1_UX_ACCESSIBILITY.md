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
Schedule wording, and reconciles the live route inventory. APP-P1-021B is now
auditing the active routes individually.

This foundation does not certify every screen. Active screens still need
route-by-route checks for contrast, semantics, focus order, keyboard operation,
tap targets, narrow layouts, and largest supported text. The route inventory is
79 constants and 78 router cases; `login` remains reserved and unwired.

## Shared Foundations

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
| Dashboard, role navigation, Home, Find Care, profile detail, booking | `dashboard_shell_test.dart`, `home_tab_shell_test.dart`, `search_flow_test.dart`, `specialist_details_flow_test.dart`, and `booking_intent_and_controller_test.dart` | Patient dashboard destinations and header actions, plus Find Care query and profile handoff, are exercised at 320x568 / 2x text; detail and booking large-text coverage is not universal. |
| Appointments and professional Schedule | `appointments_flow_test.dart`, `appointment_experience_flow_test.dart`, `appointment_experience_policy_test.dart`, `professional_schedule_test.dart`, and `scheduling_repository_test.dart` | Lifecycle, ownership, and availability behavior are covered; physical keyboard/TalkBack and all enlarged-text states remain open. The active appointment-list back control now has a tooltip. |
| Account, profile management, verification, finance | `account_flow_test.dart`, `manage_profile_flow_test.dart`, `financial_flow_test.dart`, and `financial_contract_test.dart` | Finance now has 320x568 / 2x-text coverage through populated financial activity and payout-bank/account entry. Account/Profile/Settings/Delete back controls are labelled; screen-reader, focus-order, and device acceptance remain open. |
| Messages, notifications, consultation | `messaging_flow_test.dart`, `messaging_controller_test.dart`, `notification_inbox_test.dart`, `notification_coordinator_test.dart`, and consultation controller tests | Honest-state, routing, and provider/controller behavior are covered. Real screen-reader, focus-order, and hardware permission behavior are not established by these tests. |
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
| `enterEmail`, `enterPassword` | Password recovery forms | `password_recovery_flow_test.dart` | Email entry and new-password validation are exercised at 320x568 / 2x text, including scroll access to the primary action; labelled Back remains covered. Token confirmation is a separate route and large-text coverage remains open there. |
| `resetPasswordConfirm`, `emailVerificationConfirm` | Token confirmation pages | `password_recovery_flow_test.dart`, `auth_route_authority_test.dart`, `account_flow_test.dart` | Password-reset and email-verification success flows are exercised at 320x568 / 2x text, with confirmation actions scroll-accessible and no layout exceptions. Screen-reader/device proof remains open. |
| `medicalEdit` | UserEdit | No focused route widget test identified | Accessibility/task-flow evidence gap. |
| `dashboard` | Dashboard | `dashboard_shell_test.dart` | Role destinations, header actions, tab persistence and Android back covered; patient destination switching is checked at 320x568 / 2x text. Professional large-text layout and physical accessibility remain open. |
| `search`, `findMentor`, `bookAppointment`, `publicProfile` | SearchShellPage | `search_flow_test.dart`, `find_mentor_flow_test.dart`, `public_profile_flow_test.dart` | Canonical discovery and legacy alias behavior covered; patient name query, clear, scroll, and profile handoff are checked at 320x568 / 2x text. Keyboard, TalkBack, and wider discovery states remain uncertified. |
| `specialistDetails` | SpecialistDetailsShellPage | `specialist_details_flow_test.dart` | Detail, booking intent and failure flows covered; large-text layout not checked. |
| `appointments` | AppointmentsShellPage | `appointments_flow_test.dart` | Role/status/list behavior covered; labelled Back added; large-text layout not checked. |
| `appointmentDetail` | AppointmentDetailShellPage | `appointment_experience_flow_test.dart`, `appointment_experience_policy_test.dart` | Detail/actions/conflicts covered; large-text and screen-reader sequence not certified. |
| `consultation` | ConsultationShellPage | `consultation_controller_test.dart` | Controller/authorization behavior covered; physical permission/accessibility proof open. |
| `account`, `deleteAccount` | AccountShellPage | `account_flow_test.dart` | Authority, legal, account and deletion paths covered; back controls labelled; large-text layout not checked. |
| `professionalVerificationDocuments` | ProfessionalVerificationDocumentsShellPage | `manage_profile_flow_test.dart` | Upload/list states covered; accessibility layout not certified. |
| `professionalFinance` | ProfessionalFinanceShellPage | `financial_flow_test.dart`, `financial_contract_test.dart` | 320x568 / 2x-text populated full-scroll and payout-account entry are covered; platform screen-reader, focus-order, and device acceptance remain open. |
| `editYourName`, `editProfessionalDetails`, `addDescription` | Professional profile editor shells | `manage_profile_flow_test.dart` | Backend-field behavior covered; accessibility layout not certified. |
| `messages` | MessagesPage | `messaging_flow_test.dart`, `messaging_controller_test.dart` | Honest inbox/route states covered; keyboard/screen-reader conversation task open. |
| `chat`, `message` | ChatPage | `chat_route_structure_test.dart`, `messaging_flow_test.dart` | Authority and composer states covered; keyboard focus order not certified. |
| `notification` | NotificationsPage | `notification_inbox_test.dart`, `dashboard_shell_test.dart` | Inbox/header path covered; large-text and screen-reader announcement order open. |
| `notificationPreferences` | NotificationPreferencesPage | `account_flow_test.dart`, `notification_coordinator_test.dart` | Preference/provider behavior covered; accessibility layout not certified. |
| `reminder`, `schedules`, `selectedDates` | ReminderShellPage, SchedulesShellPage, SelectedDatesShellPage | `professional_schedule_test.dart`, `manage_profile_flow_test.dart` | Professional recurring availability behavior covered; reminder/schedules direct-route accessibility evidence is incomplete. |
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

Continue APP-P1-021 with a route-by-route active-screen audit and focused
regressions. Track issues by route and severity; repair only findings that fit
the approved accessibility/UX boundary, otherwise record them for an explicitly
scoped slice.
