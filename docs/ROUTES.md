# CareNet — canonical routes

Live inventory at APP-READY-086: `RouteName.values` defines 79 identifiers; 78
are registered in `generateRoute`, with `login` intentionally reserved and
unwired. An executable route contract partitions every identifier into an exact
active widget, approved compatibility alias, fail-closed deferred destination,
or the reserved route.
The detailed KEEP/ADAPT/DEFER/DELETE table is maintained separately below.

> Phase 1 note: this table records current named-route resolution. The approved
> patient/professional navigation contract and final KEEP/ADAPT/DEFER/DELETE
> disposition are authoritative in `PHASE_1_MARKETPLACE_BOUNDARY.md` and
> `PHASE_1_ROUTE_SCREEN_CLASSIFICATION.md`. APP-P1-002 keeps route registration
> conservative while removing deferred routes from normal visible reachability.
> `dashboard` resolves the authenticated backend session role into patient
> Home/Find Care/Appointments/Messages or professional
> Home/Schedule/Appointments/Messages. `notification` opens the backend-owned
> transactional inbox from the header bell; `notificationPreferences` opens
> from the inbox or Account,
> and the Home destination composes owner profile, account readiness, own
> appointments, and professional availability through existing repositories.
> Home actions switch to the retained Find Care, Schedule, or Appointments tabs;
> readiness actions use the existing onboarding readiness route resolver.
> `account` opens from the header avatar, and no drawer is active. Its identity,
> role, status, and email come only from the authenticated account endpoint;
> seeded `AccountLocalStore` values are not rendered or used as fallback.
> The Account `Email address` row opens the registered `editEmail` verification
> screen, which displays backend-owned email/verification state and can request
> a verification link when unverified. Email change/removal remain deferred.
> Patients edit the existing backend patient profile and professionals enter
> backend professional management. Local PIN, phone, email mutation,
> deactivation drafts fail closed. `deleteAccount` now resolves to the canonical
> Account surface, where backend-owned deletion requires recent password or
> linked-Google reauthentication, explicit confirmation, and ends all sessions.
> Patient setup
> follows backend readiness instead of entering `communityAgreement`.
> Legacy `signInPhone`/`signUpPhone` values resolve to email authentication.
> Canonical HTTPS `/verify-email?token=...` and `/reset-password?token=...`
> links from `project-a96784ee-811c-46ab-a7b.web.app` resolve to the existing
> confirmation pages. Absolute links from unrelated hosts are rejected.
> Legacy community/notification agreement values resolve to patient setup, and
> `medicalAgreement` resolves to professional setup; their old broad-product
> widgets are not active routes.
> `search` is the canonical Find Care route. Patient Home and the persistent
> Find Care tab enter the same `SearchShellPage`; legacy `findMentor` is a
> compatibility alias to that screen and no longer opens a separate marketplace.
> `specialistDetails` requires a valid backend `ProfessionalProfile.id` and is the
> only active public detail/request path. Legacy `bookAppointment` and
> `publicProfile` constants resolve to canonical Find Care and no longer expose
> local booking behavior. `appointments` is the role-aware authenticated list;
> `appointmentDetail` requires an exact appointment ID and resolves it only from
> the backend-owned list for the current account. Professional `selectedDates`
> manages recurring `/availability/me` rules and never generates patient slots.

APP-READY-086 routes `reminder` and `schedules` to `DeferredFeaturePage`;
their retained local screens are not active product surfaces. `selectedDates`
remains the unchanged backend-owned professional Schedule destination.

All navigation uses **`RouteName`** constants and **`generateRoute`** in `lib/core/constants/navigators/router.dart`.

The verified inventory remains 79 declared constants (78 registered route
values plus the reserved, unwired `login`). Deferred health-reading, content,
community, emergency, creator-portfolio, and local account-mutation constants
are retained for source recovery, but route resolution now opens
`DeferredFeaturePage`; their seeded screens are not active product surfaces.

Do not invent route strings in screens. Add new routes here and in `RouteName` before use.

| RouteName constant | Route string | Screen widget | File |
|--------------------|--------------|---------------|------|
| `splash` | `splash` | `SplashScreen` | `lib/features/splash/presentation/pages/splash_screen.dart` |
| `onboarding` | `onboarding` | `OnboardingView` | `lib/features/Onboarding/presentation/pages/onboarding.dart` |
| `signUpPhone` | `signUpPhone` | `SignUpEmail` (unsupported phone-auth compatibility alias) | `lib/features/Authentication/presentation/pages/sign_up_email.dart` |
| `signUpEmail` | `signUpEmail` | `SignUpEmail` | `lib/features/Authentication/presentation/pages/sign_up_email.dart` |
| `signUpRole` | `signUpRole` | `SignUpRoleSelectionPage` | `lib/features/Authentication/presentation/pages/sign_up_role_selection.dart` |
| `finishSignUp` | `finishSignUp` | `FinSignUp` | `lib/features/Authentication/presentation/pages/sign_up_con.dart` |
| `patientOnboardingSetup` | `patientOnboardingSetup` | `PatientOnboardingSetupPage` | `lib/features/Onboarding/presentation/pages/profile_setup.dart` |
| `communityAgreement` | `communityAgreement` | `PatientOnboardingSetupPage` (legacy compatibility alias) | `lib/features/Onboarding/presentation/pages/profile_setup.dart` |
| `notificationAgreement` | `notificationAgreement` | `PatientOnboardingSetupPage` (legacy compatibility alias) | `lib/features/Onboarding/presentation/pages/profile_setup.dart` |
| `medicalAgreement` | `medicalAgreement` | `ProfessionalOnboardingSetupPage` (legacy compatibility alias) | `lib/features/Onboarding/presentation/pages/profile_setup.dart` |
| `medicalProfessional` | `medicalProfessional` | `ProfessionalOnboardingSetupPage` | `lib/features/Onboarding/presentation/pages/profile_setup.dart` |
| `medicalEdit` | `medicalEdit` | `DeferredFeaturePage` (legacy local editor disconnected) | `lib/core/routing/deferred_feature_page.dart` |
| `signInPhone` | `signInPhone` | `SignInEmail` (unsupported phone-auth compatibility alias) | `lib/features/Authentication/presentation/pages/sign_in_email.dart` |
| `signInEmail` | `signInEmail` | `SignInEmail` | `lib/features/Authentication/presentation/pages/sign_in_email.dart` |
| `enterEmail` | `enterEmail` | `EnterEmailPage` | `lib/features/Authentication/presentation/pages/enter_email.dart` |
| `enterPassword` | `enterPassword` | `ResetPasswordConfirmPage` (tokenless recovery compatibility alias) | `lib/features/Authentication/presentation/pages/reset_password_confirm_page.dart` |
| `resetPasswordConfirm` | `resetPasswordConfirm` | `ResetPasswordConfirmPage` | `lib/features/Authentication/presentation/pages/reset_password_confirm_page.dart` |
| `emailVerificationConfirm` | `emailVerificationConfirm` | `EmailVerificationConfirmPage` | `lib/features/Authentication/presentation/pages/email_verification_confirm_page.dart` |
| `dashboard` | `dashboard` | `Dashboard` | `lib/features/Home/presentation/pages/dashboard.dart` |
| `search` | `search` | `SearchShellPage` | `lib/features/Home/presentation/pages/search_shell.dart` |
| `findMentor` | `findMentor` | `SearchShellPage` (legacy compatibility alias) | `lib/features/Home/presentation/pages/search_shell.dart` |
| `specialistDetails` | `specialistDetails` | `SpecialistDetailsShellPage` (canonical backend detail and requestable-time booking) | `lib/features/Home/presentation/pages/specialist_details_shell.dart` |
| `appointments` | `appointments` | `AppointmentsShellPage` (role-aware backend list) | `lib/features/Home/presentation/pages/appointment_experience_shell.dart` |
| `appointmentDetail` | `appointmentDetail` | `AppointmentDetailShellPage` (exact ID from authenticated own-list) | `lib/features/Home/presentation/pages/appointment_experience_shell.dart` |
| `consultation` | `consultation` | `ConsultationShellPage` (typed appointment authority) | `lib/features/Consultation/presentation/pages/consultation_shell.dart` |
| `bookAppointment` | `bookAppointment` | `SearchShellPage` (legacy compatibility alias; local booking source disconnected) | `lib/features/Home/presentation/pages/search_shell.dart` |
| `readings` | `readings` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `healthRecord` | `healthRecord` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `manageReadings` | `manageReadings` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `addDevice` | `addDevice` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `bloodSug` | `bloodSug` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `articles` | `articles` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `savedArticles` | `savedArticles` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `publishedArticles` | `publishedArticles` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `caseStudies` | `caseStudies` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `podcast` | `podcast` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `emergency` | `emergency` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `distressCall` | `distressCall` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `discoverCommunities` | `discoverCommunities` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `communityProfile` | `communityProfile` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `createCommunity` | `createCommunity` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `qAAsk` | `qAAsk` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `qAAnswerRequests` | `qAAnswerRequests` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `qAAnswerForYou` | `qAAnswerForYou` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `commentAnswer` | `commentAnswer` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `account` | `account` | `AccountShellPage` | `lib/features/Home/presentation/pages/account_shell.dart` |
| `deleteAccount` | `deleteAccount` | `AccountShellPage` (canonical account deletion alias) | `lib/features/Home/presentation/pages/account_shell.dart` |
| `settings` | `settings` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `changeAuthentication` | `changeAuthentication` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `turnOnAuthentication` | `turnOnAuthentication` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `createPin` | `createPin` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `confirmPinSave` | `confirmPinSave` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `addPhoneNumber` | `addPhoneNumber` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `confirmPhoneNumber` | `confirmPhoneNumber` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `addEmail` | `addEmail` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `editEmail` | `editEmail` | `EditEmailShellPage` | `lib/features/Home/presentation/pages/edit_email_shell.dart` |
| `changeEmail` | `changeEmail` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `enterPasswordToSave` | `enterPasswordToSave` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `password` | `password` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `publicProfile` | `publicProfile` | `SearchShellPage` (legacy compatibility alias; seeded profile booking disconnected) | `lib/features/Home/presentation/pages/search_shell.dart` |
| `manageProfile` | `manageProfile` | `ProfessionalOnboardingSetupPage` (backend-owned professional editor compatibility alias) | `lib/features/Onboarding/presentation/pages/profile_setup.dart` |
| `managePortfolio` | `managePortfolio` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `professionalVerificationDocuments` | `professionalVerificationDocuments` | `ProfessionalVerificationDocumentsShellPage` | `lib/features/Home/presentation/pages/professional_verification_documents_shell.dart` |
| `professionalFinance` | `professionalFinance` | `ProfessionalFinanceShellPage` (professional price, bank, balances, ledger, payouts) | `lib/features/Home/presentation/pages/professional_finance_shell.dart` |
| `editYourName` | `editYourName` | `EditYourNameShellPage` | `lib/features/Home/presentation/pages/edit_your_name_shell.dart` |
| `editProfessionalDetails` | `editProfessionalDetails` | `EditProfessionalDetailsShellPage` | `lib/features/Home/presentation/pages/edit_professional_details_shell.dart` |
| `editYourWebsite` | `editYourWebsite` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `addDescription` | `addDescription` | `AddDescriptionShellPage` | `lib/features/Home/presentation/pages/add_description_shell.dart` |
| `setAddress` | `setAddress` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `ownerCircleProfile` | `ownerCircleProfile` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `messages` | `messages` | `MessagesPage` (authenticated appointment conversations) | `lib/features/Messaging/presentation/pages/Messages.dart` |
| `chat` | `chat` | `ChatPage` (typed conversation/appointment arguments; backend authority required) | `lib/features/Messaging/presentation/pages/Chat.dart` |
| `message` | `message` | `ChatPage` fail-closed compatibility alias; no seeded conversation | `lib/features/Messaging/presentation/pages/Chat.dart` |
| `notification` | `notification` | `NotificationsPage` (authenticated durable inbox) | `lib/features/Messaging/presentation/pages/Notification.dart` |
| `notificationPreferences` | `notificationPreferences` | `NotificationPreferencesPage` | `lib/features/Notifications/presentation/pages/notification_preferences_page.dart` |
| `reminder` | `reminder` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `schedules` | `schedules` | `DeferredFeaturePage` | `lib/core/routing/deferred_feature_page.dart` |
| `selectedDates` | `selectedDates` | `SelectedDatesShellPage` (professional recurring availability) | `lib/features/Home/presentation/pages/selected_dates_shell.dart` |

## Not registered yet

| Constant | Notes |
|----------|--------|
| `login` | Reserved; no screen wired |

## Blueprint mapping (reference)

Figma `routes.json` uses paths like `/splash-screen`, `/sign-up-with-phone`. App uses short `RouteName` strings above. When adding screens, note the blueprint path in this table.

| Blueprint path | App RouteName |
|----------------|---------------|
| `/splash-screen` | `splash` |
| `/onboarding` | `onboarding` |
| `/sign-up-with-phone` | `signUpPhone` |
| `/sign-up-with-email` | `signUpEmail` |
| `/enter-email` | `enterEmail` |
| `/enter-password` | `enterPassword` |
| Backend reset link token landing | `resetPasswordConfirm` |
| Backend verification link token landing | `emailVerificationConfirm` |
| `/community-agreement` | `communityAgreement` |
| `/notification-agreement` | `notificationAgreement` |
| `/dashboard` | `dashboard` |
| `/search` | `search` |
| `/search-find-a-consultant` | `search` |
| `/find-mentor` | `findMentor` |
| `/specialist-details` | `specialistDetails` |
| `/health-record` | `healthRecord` |
| `/saved-articles` | `savedArticles` |
| `/published-articles` | `publishedArticles` |
| `/case-studies` | `caseStudies` |
| `/case-study-story` | `caseStudies` in-page detail state |
| `/viewers-circle-profile` | `communityProfile` |
| `/create-a-community` | `createCommunity` |
| `/q-a-ask` | `qAAsk` |
| `/q-a-answer-requests` | `qAAnswerRequests` |
| `/q-a-answer-for-you` | `qAAnswerForYou` |
| `/comment-answer` | `commentAnswer` |
| `/account` | `account` |
| `/delete-account` | `deleteAccount` |
| `/settings` | `settings` |
| `/change-authentication` | `changeAuthentication` |
| `/turn-on-authentication` | `turnOnAuthentication` |
| `/create-pin` | `createPin` |
| `/confirm-pin-save` | `confirmPinSave` |
| `/add-phone-number` | `addPhoneNumber` |
| `/confirm-phone-number` | `confirmPhoneNumber` |
| `/add-email` | `addEmail` |
| `/edit-email` | `editEmail` |
| `/change-email` | `changeEmail` |
| `/enter-password-to-save` | `enterPasswordToSave` |
| `/password` | `password` |
| `/reminder` | `reminder` |
| `/schedules` | `schedules` |
| `/selected-dates` | `selectedDates` |
| `/profile-view-from-user` | `publicProfile` |
| `/manage-profile` | `manageProfile` |
| `/manage-portfolio` | `managePortfolio` |
| Professional verification owner documents | `professionalVerificationDocuments` |
| Professional payments and payouts | `professionalFinance` |
| `/edit-your-name` | `editYourName` |
| Professional category/specialty details | `editProfessionalDetails` |
| `/edit-your-website` | `editYourWebsite` |
| `/add-desicription` | `addDescription` |
| `/set-address` | `setAddress` |
| `/owner-circle-profile` | `ownerCircleProfile` |
| `/podcast` | `podcast` |
## Phase 1 appointment consultation

| Route | Screen | Authority |
| --- | --- | --- |
| `RouteName.consultation` | `ConsultationShellPage` | Typed appointment ID plus authenticated backend consultation projection; malformed/missing IDs and unsupported roles fail closed |

The route is reachable from canonical Appointment Detail only when the backend
projection exposes a legitimate waiting, admission, join, rejoin, review, or
active-session state. It is not a primary navigation destination and never
accepts a room name, token, participant identity, role, or payment authority
from route arguments.
