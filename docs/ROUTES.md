# CareNet — canonical routes

> Phase 1 note: this table records the committed broad-UI baseline. The approved
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
> Patients edit the existing backend patient profile and professionals enter
> backend professional management. Local PIN, phone, email mutation,
> deactivation, and deletion drafts fail closed until authoritative contracts
> exist. Patient setup
> follows backend readiness instead of entering `communityAgreement`.
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
| `signUpPhone` | `signUpPhone` | `SignUpPhone` | `lib/features/Authentication/presentation/pages/sign_up_phone.dart` |
| `signUpEmail` | `signUpEmail` | `SignUpEmail` | `lib/features/Authentication/presentation/pages/sign_up_email.dart` |
| `signUpRole` | `signUpRole` | `SignUpRoleSelectionPage` | `lib/features/Authentication/presentation/pages/sign_up_role_selection.dart` |
| `finishSignUp` | `finishSignUp` | `FinSignUp` | `lib/features/Authentication/presentation/pages/sign_up_con.dart` |
| `patientOnboardingSetup` | `patientOnboardingSetup` | `PatientOnboardingSetupPage` | `lib/features/Onboarding/presentation/pages/profile_setup.dart` |
| `communityAgreement` | `communityAgreement` | `CommunityCommitment` | `lib/features/Onboarding/presentation/pages/commitment_screen.dart` |
| `notificationAgreement` | `notificationAgreement` | `NotificationScreen` | `lib/features/Onboarding/presentation/pages/notification.dart` |
| `medicalAgreement` | `medicalAgreement` | `MedicalAgreement` | `lib/features/Onboarding/presentation/pages/medical_agreement.dart` |
| `medicalProfessional` | `medicalProfessional` | `ProfessionalOnboardingSetupPage` | `lib/features/Onboarding/presentation/pages/profile_setup.dart` |
| `medicalEdit` | `medicalEdit` | `UserEdit` | `lib/features/Onboarding/presentation/pages/user_edit.dart` |
| `signInPhone` | `signInPhone` | `SignInPhone` | `lib/features/Authentication/presentation/pages/sign_in_phone.dart` |
| `signInEmail` | `signInEmail` | `SignInEmail` | `lib/features/Authentication/presentation/pages/sign_in_email.dart` |
| `enterEmail` | `enterEmail` | `EnterEmailPage` | `lib/features/Authentication/presentation/pages/enter_email.dart` |
| `enterPassword` | `enterPassword` | `EnterPasswordPage` | `lib/features/Authentication/presentation/pages/enter_password.dart` |
| `resetPasswordConfirm` | `resetPasswordConfirm` | `ResetPasswordConfirmPage` | `lib/features/Authentication/presentation/pages/reset_password_confirm_page.dart` |
| `emailVerificationConfirm` | `emailVerificationConfirm` | `EmailVerificationConfirmPage` | `lib/features/Authentication/presentation/pages/email_verification_confirm_page.dart` |
| `dashboard` | `dashboard` | `Dashboard` | `lib/features/Home/presentation/pages/dashboard.dart` |
| `search` | `search` | `SearchShellPage` | `lib/features/Home/presentation/pages/search_shell.dart` |
| `findMentor` | `findMentor` | `SearchShellPage` (legacy compatibility alias) | `lib/features/Home/presentation/pages/search_shell.dart` |
| `specialistDetails` | `specialistDetails` | `SpecialistDetailsShellPage` (canonical backend detail and requestable-time booking) | `lib/features/Home/presentation/pages/specialist_details_shell.dart` |
| `appointments` | `appointments` | `AppointmentsShellPage` (role-aware backend list) | `lib/features/Home/presentation/pages/appointment_experience_shell.dart` |
| `appointmentDetail` | `appointmentDetail` | `AppointmentDetailShellPage` (exact ID from authenticated own-list) | `lib/features/Home/presentation/pages/appointment_experience_shell.dart` |
| `bookAppointment` | `bookAppointment` | `SearchShellPage` (legacy compatibility alias; local booking source disconnected) | `lib/features/Home/presentation/pages/search_shell.dart` |
| `readings` | `readings` | `VitalsReading` | `lib/features/Home/presentation/pages/readings.dart` |
| `healthRecord` | `healthRecord` | `HealthRecordShellPage` | `lib/features/Home/presentation/pages/health_record_shell.dart` |
| `manageReadings` | `manageReadings` | `ManageReadings` | `lib/features/Home/presentation/pages/manage_readings.dart` |
| `addDevice` | `addDevice` | `AddDeviceShellPage` | `lib/features/Home/presentation/pages/add_device_shell.dart` |
| `bloodSug` | `bloodSug` | `BloodSugShellPage` | `lib/features/Home/presentation/pages/blood_sug_shell.dart` |
| `articles` | `articles` | `ArticlesShellPage` | `lib/features/Home/presentation/pages/articles_shell.dart` |
| `savedArticles` | `savedArticles` | `SavedArticlesShellPage` | `lib/features/Home/presentation/pages/saved_articles_shell.dart` |
| `publishedArticles` | `publishedArticles` | `PublishedArticlesShellPage` | `lib/features/Home/presentation/pages/published_articles_shell.dart` |
| `caseStudies` | `caseStudies` | `CaseStudiesShellPage` | `lib/features/Home/presentation/pages/case_studies_shell.dart` |
| `podcast` | `podcast` | `PodcastShellPage` | `lib/features/Home/presentation/pages/podcast_shell.dart` |
| `emergency` | `emergency` | `EmergencyShellPage` | `lib/features/Home/presentation/pages/emergency_shell.dart` |
| `distressCall` | `distressCall` | `DistressCallPage` | `lib/features/Home/presentation/pages/emergency_shell.dart` |
| `discoverCommunities` | `discoverCommunities` | `DiscoverCommunitiesPage` | `lib/features/Home/presentation/pages/circles_shell.dart` |
| `communityProfile` | `communityProfile` | `CommunityProfilePage` | `lib/features/Home/presentation/pages/community_profile_page.dart` |
| `createCommunity` | `createCommunity` | `CreateCommunityPage` | `lib/features/Home/presentation/pages/create_community_page.dart` |
| `qAAsk` | `qAAsk` | `QaAskPage` | `lib/features/Home/presentation/pages/qa_shell.dart` |
| `qAAnswerRequests` | `qAAnswerRequests` | `QaAnswerRequestsPage` | `lib/features/Home/presentation/pages/qa_shell.dart` |
| `qAAnswerForYou` | `qAAnswerForYou` | `QaAnswerForYouPage` | `lib/features/Home/presentation/pages/qa_shell.dart` |
| `commentAnswer` | `commentAnswer` | `QaCommentAnswerPage` | `lib/features/Home/presentation/pages/qa_shell.dart` |
| `account` | `account` | `AccountShellPage` | `lib/features/Home/presentation/pages/account_shell.dart` |
| `deleteAccount` | `deleteAccount` | `DeleteAccountPage` | `lib/features/Home/presentation/pages/account_shell.dart` |
| `settings` | `settings` | `SettingsProfilePage` | `lib/features/Home/presentation/pages/account_shell.dart` |
| `changeAuthentication` | `changeAuthentication` | `ChangeAuthenticationShellPage` | `lib/features/Home/presentation/pages/change_authentication_shell.dart` |
| `turnOnAuthentication` | `turnOnAuthentication` | `TurnOnAuthenticationShellPage` | `lib/features/Home/presentation/pages/turn_on_authentication_shell.dart` |
| `createPin` | `createPin` | `CreatePinShellPage` | `lib/features/Home/presentation/pages/create_pin_shell.dart` |
| `confirmPinSave` | `confirmPinSave` | `ConfirmPinSaveShellPage` | `lib/features/Home/presentation/pages/confirm_pin_save_shell.dart` |
| `addPhoneNumber` | `addPhoneNumber` | `AddPhoneNumberShellPage` | `lib/features/Home/presentation/pages/add_phone_number_shell.dart` |
| `confirmPhoneNumber` | `confirmPhoneNumber` | `ConfirmPhoneNumberShellPage` | `lib/features/Home/presentation/pages/confirm_phone_number_shell.dart` |
| `addEmail` | `addEmail` | `AddEmailShellPage` | `lib/features/Home/presentation/pages/add_email_shell.dart` |
| `editEmail` | `editEmail` | `EditEmailShellPage` | `lib/features/Home/presentation/pages/edit_email_shell.dart` |
| `changeEmail` | `changeEmail` | `ChangeEmailShellPage` | `lib/features/Home/presentation/pages/change_email_shell.dart` |
| `enterPasswordToSave` | `enterPasswordToSave` | `EnterPasswordToSaveShellPage` | `lib/features/Home/presentation/pages/enter_password_to_save_shell.dart` |
| `password` | `password` | `PasswordShellPage` | `lib/features/Home/presentation/pages/password_shell.dart` |
| `publicProfile` | `publicProfile` | `SearchShellPage` (legacy compatibility alias; seeded profile booking disconnected) | `lib/features/Home/presentation/pages/search_shell.dart` |
| `manageProfile` | `manageProfile` | `ProfessionalOnboardingSetupPage` (backend-owned professional editor compatibility alias) | `lib/features/Onboarding/presentation/pages/profile_setup.dart` |
| `managePortfolio` | `managePortfolio` | `ManagePortfolioShellPage` | `lib/features/Home/presentation/pages/manage_portfolio_shell.dart` |
| `professionalVerificationDocuments` | `professionalVerificationDocuments` | `ProfessionalVerificationDocumentsShellPage` | `lib/features/Home/presentation/pages/professional_verification_documents_shell.dart` |
| `professionalFinance` | `professionalFinance` | `ProfessionalFinanceShellPage` (professional price, bank, balances, ledger, payouts) | `lib/features/Home/presentation/pages/professional_finance_shell.dart` |
| `editYourName` | `editYourName` | `EditYourNameShellPage` | `lib/features/Home/presentation/pages/edit_your_name_shell.dart` |
| `editProfessionalDetails` | `editProfessionalDetails` | `EditProfessionalDetailsShellPage` | `lib/features/Home/presentation/pages/edit_professional_details_shell.dart` |
| `editYourWebsite` | `editYourWebsite` | `EditYourWebsiteShellPage` | `lib/features/Home/presentation/pages/edit_your_website_shell.dart` |
| `addDescription` | `addDescription` | `AddDescriptionShellPage` | `lib/features/Home/presentation/pages/add_description_shell.dart` |
| `setAddress` | `setAddress` | `SetAddressShellPage` | `lib/features/Home/presentation/pages/set_address_shell.dart` |
| `ownerCircleProfile` | `ownerCircleProfile` | `CommunityProfilePage` (`isOwner` variant) | `lib/features/Home/presentation/pages/community_profile_page.dart` |
| `messages` | `messages` | `MessagesPage` (authenticated appointment conversations) | `lib/features/Messaging/presentation/pages/Messages.dart` |
| `chat` | `chat` | `ChatPage` (typed conversation/appointment arguments; backend authority required) | `lib/features/Messaging/presentation/pages/Chat.dart` |
| `message` | `message` | `ChatPage` fail-closed compatibility alias; no seeded conversation | `lib/features/Messaging/presentation/pages/Chat.dart` |
| `notification` | `notification` | `NotificationsPage` (authenticated durable inbox) | `lib/features/Messaging/presentation/pages/Notification.dart` |
| `notificationPreferences` | `notificationPreferences` | `NotificationPreferencesPage` | `lib/features/Notifications/presentation/pages/notification_preferences_page.dart` |
| `reminder` | `reminder` | `ReminderShellPage` | `lib/features/Home/presentation/pages/reminder_shell.dart` |
| `schedules` | `schedules` | `SchedulesShellPage` | `lib/features/Home/presentation/pages/schedules_shell.dart` |
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
