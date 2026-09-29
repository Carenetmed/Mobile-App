# Phase 1 Route And Screen Classification

Slice: `APP-P1-001`

Baseline: `3e04d6e`

This is the final classification of the current committed Flutter route and
screen inventory for the Phase 1 consultation marketplace.

## Classification meanings

- **KEEP**: already belongs to Phase 1 and its working backend/architecture
  boundary must be preserved.
- **ADAPT**: belongs to Phase 1, but its role, data source, navigation position,
  or mixed local content must change.
- **DEFER**: not active in Phase 1. Remove it from navigation/routing first, then
  remove exclusive code in the cleanup slice. Recoverable from archive/history.
- **DELETE**: obsolete, duplicate, reserved, or superseded. Remove it only in the
  ordered cleanup work after retained routes pass tests; no deletion occurs in
  `APP-P1-001`.

## Canonical route inventory

The original APP-P1-001 baseline defined 75 `RouteName` constants and 74 router
cases, with `login` reserved. The live inventory has since grown: as of
APP-P1-021 it contains 79 constants and 78 router cases; `login` remains the
only reserved unwired constant. Three later routes (`appointmentDetail`,
`consultation`, and `professionalFinance`) are included in the current
classification below.

### Launch, authentication, and onboarding

| Route | Current screen | Class | Phase 1 disposition | Figma/reference |
|---|---|---|---|---|
| `splash` | `SplashScreen` | KEEP | Session restore and readiness entry | `/splash-screen` |
| `onboarding` | `OnboardingView` | ADAPT | Keep the recovered entry/auth gateway; remove broad-product promises | `/onboarding`, onboarding variants |
| `signUpPhone` | `SignUpPhone` | DEFER | Hide until real phone/OTP signup contract exists | `/sign-up-with-phone` |
| `signUpEmail` | `SignUpEmail` | KEEP | Email signup entry | `/sign-up-with-email` |
| `signUpRole` | `SignUpRoleSelectionPage` | KEEP | Patient/professional role selection before account creation | New recovered auth flow; no exact original route |
| `finishSignUp` | `FinSignUp` | KEEP | Email/password completion with backend readiness routing | Existing auth flow |
| `patientOnboardingSetup` | `PatientOnboardingSetupPage` | KEEP | Backend-catalog patient profile setup; change final destination away from community agreement | New backend-driven setup |
| `communityAgreement` | `CommunityCommitment` | DELETE | Obsolete social/community onboarding step | `/community-agreement` |
| `notificationAgreement` | `NotificationScreen` | DELETE | Obsolete chained permission screen; later permission request must be contextual | `/notification-agreement` |
| `medicalAgreement` | `MedicalAgreement` | DELETE | Superseded professional onboarding chain | Existing blueprint agreement frame |
| `medicalProfessional` | `ProfessionalOnboardingSetupPage` | KEEP | Backend-catalog professional application/setup | New backend-driven setup |
| `medicalEdit` | `UserEdit` | DELETE | Obsolete pre-catalog professional/profile editor | Legacy profile setup reference |
| `signInPhone` | `SignInPhone` | DEFER | Hide until real phone/OTP sign-in exists | Blueprint phone sign-in family |
| `signInEmail` | `SignInEmail` | KEEP | Email/password and Google sign-in entry | Existing sign-in reference |
| `enterEmail` | `EnterEmailPage` | KEEP | Password-reset request | `/enter-email` |
| `enterPassword` | `EnterPasswordPage` | KEEP | Retain only as the approved recovery/credential step it currently serves | `/enter-password` |
| `resetPasswordConfirm` | `ResetPasswordConfirmPage` | KEEP | Backend token-confirm reset landing | Backend deep-link landing |
| `emailVerificationConfirm` | `EmailVerificationConfirmPage` | KEEP | Backend verification token landing | Backend deep-link landing |
| `login` | none | DELETE | Remove unused reserved constant when route cleanup occurs | None |

### Marketplace, scheduling, and deferred product modules

| Route | Current screen | Class | Phase 1 disposition | Figma/reference |
|---|---|---|---|---|
| `dashboard` | `Dashboard` | ADAPT | Role-aware four-tab shell; notification and account access live in the header | `/dashboard` |
| `search` | `SearchShellPage` | ADAPT | Canonical patient **Find Care** destination using backend public professionals | `/search`, `/search-find-a-consultant` |
| `findMentor` | `FindMentorShellPage` | DELETE | Duplicate local discovery route; consolidate into Find Care | `/find-mentor` |
| `specialistDetails` | `SpecialistDetailsShellPage` | ADAPT | Canonical public professional detail; remove local compatibility branch | `/specialist-details` |
| `appointments` | `AppointmentsShellPage` | ADAPT | Role-aware patient/professional list and lifecycle surface | `/appointments`, `/appointment` |
| `appointmentDetail` | `AppointmentDetailShellPage` | KEEP | Authenticated exact-ID detail resolved from the current account's backend-owned appointment list | `/appointment-detail` |
| `consultation` | `ConsultationShellPage` | KEEP | Appointment-linked backend-authorized audio/video consultation; no separate Calls destination | `/consultation` |
| `bookAppointment` | `BookAppointmentShellPage` | DELETE | Remove local draft form; booking starts from a real backend slot | `/book-appointment` |
| `readings` | `VitalsReading` | DEFER | Remove from active Phase 1 | `/readings` |
| `healthRecord` | `HealthRecordShellPage` | DEFER | Remove from active Phase 1 | `/health-record` |
| `manageReadings` | `ManageReadings` | DEFER | Remove from active Phase 1 | `/manage-readingsr` |
| `addDevice` | `AddDeviceShellPage` | DEFER | Remove from active Phase 1 | `/add-new-readings` family |
| `bloodSug` | `BloodSugShellPage` | DEFER | Remove from active Phase 1 | Readings/device family |
| `articles` | `ArticlesShellPage` | DEFER | Remove from active Phase 1 | `/articles`, `/article`, `/open-article` |
| `savedArticles` | `SavedArticlesShellPage` | DEFER | Remove from active Phase 1 | `/saved-articles` |
| `publishedArticles` | `PublishedArticlesShellPage` | DEFER | Remove creator/content surface | `/published-articles` |
| `caseStudies` | `CaseStudiesShellPage` | DEFER | Remove content surface | `/case-studies`, `/case-study-story` |
| `podcast` | `PodcastShellPage` | DEFER | Remove media/content surface | `/podcast`, `/podcasts` |
| `emergency` | `EmergencyShellPage` | DEFER | Remove unsafe local emergency claims | Emergency blueprint family |
| `distressCall` | `DistressCallPage` | DEFER | Remove unsafe local dispatch flow | Emergency/distress family |
| `discoverCommunities` | `DiscoverCommunitiesPage` | DEFER | Remove from active Phase 1 | `/community-invitations-discover` |
| `communityProfile` | `CommunityProfilePage` | DEFER | Remove from active Phase 1 | `/viewers-circle-profile` |
| `ownerCircleProfile` | `CommunityProfilePage` owner variant | DEFER | Remove from active Phase 1 | `/owner-circle-profile` |
| `createCommunity` | `CreateCommunityPage` | DEFER | Remove from active Phase 1 | `/create-a-community` |
| `qAAsk` | `QaAskPage` | DEFER | Remove social Q&A | `/q-a-ask` |
| `qAAnswerRequests` | `QaAnswerRequestsPage` | DEFER | Remove social Q&A | `/q-a-answer-requests` |
| `qAAnswerForYou` | `QaAnswerForYouPage` | DEFER | Remove social Q&A | `/q-a-answer-for-you` |
| `commentAnswer` | `QaCommentAnswerPage` | DEFER | Remove social Q&A | `/comment-answer` |

### Account, profile, messaging, and secondary routes

| Route | Current screen | Class | Phase 1 disposition | Figma/reference |
|---|---|---|---|---|
| `account` | `AccountShellPage` | ADAPT | Role-aware Profile root; keep real account/session reads and logout | `/account` |
| `deleteAccount` | `DeleteAccountPage` | ADAPT | Keep only after local deactivation is replaced by approved backend behavior | `/delete-account` |
| `settings` | `SettingsProfilePage` | ADAPT | Patient/profile/privacy/security settings; remove creator/social copy | `/settings` |
| `changeAuthentication` | `ChangeAuthenticationShellPage` | ADAPT | Keep only real provider/account-security operations | `/change-authentication` |
| `turnOnAuthentication` | `TurnOnAuthenticationShellPage` | DEFER | Hide until MFA/PIN contract exists | `/turn-on-authentication` |
| `createPin` | `CreatePinShellPage` | DEFER | Hide local PIN draft until secure implementation exists | `/create-pin` |
| `confirmPinSave` | `ConfirmPinSaveShellPage` | DEFER | Hide local confirmation until secure implementation exists | `/confirm-pin-save` |
| `addPhoneNumber` | `AddPhoneNumberShellPage` | DEFER | Hide until OTP, uniqueness, recovery, and audit rules exist | `/add-phone-number` |
| `confirmPhoneNumber` | `ConfirmPhoneNumberShellPage` | DEFER | Hide until real OTP verification exists | `/confirm-phone-number` |
| `addEmail` | `AddEmailShellPage` | DEFER | Hide local draft until email mutation/verification contract exists | `/add-email` |
| `editEmail` | `EditEmailShellPage` | DEFER | Hide local management flow until backend mutation exists | `/edit-email` |
| `changeEmail` | `ChangeEmailShellPage` | DEFER | Hide local change flow until backend mutation exists | `/change-email` |
| `enterPasswordToSave` | `EnterPasswordToSaveShellPage` | DEFER | Hide local re-auth draft until backend re-auth exists | `/enter-password-to-save` |
| `password` | `PasswordShellPage` | DEFER | Hide local information-only route until real password change policy exists | `/password` |
| `publicProfile` | `PublicProfileShellPage` | DELETE | Local creator-style duplicate; public professional detail belongs to `specialistDetails` | `/profile-view-from-user` |
| `manageProfile` | `ManageProfileShellPage` | ADAPT | Professional Profile root; keep backend profile/verification sections, remove creator content | `/manage-profile` |
| `managePortfolio` | `ManagePortfolioShellPage` | DELETE | Creator portfolio is outside Phase 1 | `/manage-portfolio` |
| `professionalVerificationDocuments` | `ProfessionalVerificationDocumentsShellPage` | KEEP | Real verification upload/list/status and readiness | Backend-owned verification surface |
| `professionalFinance` | `ProfessionalFinanceShellPage` | KEEP | Backend-priced consultation and professional finance authority; no client-calculated balances | Professional Account finance surface |
| `editYourName` | `EditYourNameShellPage` | ADAPT | Replace `PublicProfileLocalStore` draft with role-appropriate backend profile update | `/edit-your-name` |
| `editProfessionalDetails` | `EditProfessionalDetailsShellPage` | ADAPT | Keep backend category/specialty update; align with professional Profile | Professional details reference |
| `editYourWebsite` | `EditYourWebsiteShellPage` | DEFER | Website is not in the current backend/Phase 1 required profile contract | `/edit-your-website` |
| `addDescription` | `AddDescriptionShellPage` | ADAPT | Keep real professional bio update; remove local profile assumptions | `/add-desicription` |
| `setAddress` | `SetAddressShellPage` | ADAPT | Use backend practice location fields; remove `PublicProfileLocalStore` draft | `/set-address` |
| `messages` | `MessagesPage` | ADAPT | Appointment-linked conversation list only; remove seeded/generic social data | `/messages` |
| `chat` | `ChatPage` | ADAPT | Appointment-authorized conversation only; no seeded default | Existing chat/message reference |
| `message` | `ChatPage` unavailable alias | DELETE | Remove duplicate compatibility alias after callers use `chat` | `/message` |
| `notification` | `NotificationsPage` | KEEP | Header-bell destination backed by the authenticated durable transactional inbox | `/notification`, `/notifications` |
| `notificationPreferences` | `NotificationPreferencesPage` | KEEP | Post-baseline route for backend push/email category preferences, opened from Account or inbox | New Phase 1 transactional-notification surface |
| `reminder` | `ReminderShellPage` | DEFER | Generic local reminders are outside Phase 1 | `/reminder` |
| `schedules` | `SchedulesShellPage` | DEFER | Generic event/task schedule is not professional availability | `/schedules` |
| `selectedDates` | `SelectedDatesShellPage` | ADAPT | Canonical professional **Schedule** using real own availability | `/selected-dates`, `/schedule` family |

## Page files without an independent named route

| File/screen | Class | Disposition |
|---|---|---|
| `Authentication/presentation/pages/sign_up_arguments.dart` | KEEP | Typed auth navigation support, not a screen |
| `Home/presentation/pages/home.dart` | ADAPT | Becomes role-aware Home content |
| `Home/presentation/pages/feed_tab.dart` | DEFER | General feed; remove after Home adaptation passes |
| `Home/presentation/pages/home_articles_tab.dart` | DEFER | Content tab; remove after Home adaptation passes |
| `Home/presentation/pages/home_messages_tab.dart` | DELETE | Seeded duplicate of the approved primary Messages destination |
| `Home/presentation/pages/post_shell.dart` | DEFER | Public post/Q&A host used by current dashboard |
| `Home/presentation/pages/call_professional.dart` | ADAPT | Video/audio is Phase 1, but entry must move to Appointment Detail as Join Consultation and use an approved external RTC contract; currently unregistered |
| `Onboarding/presentation/pages/profession.dart` | DELETE | Obsolete pre-catalog profession picker; no router case |
| `Home/presentation/pages/search_shell.dart` `DashboardShellScaffold` | ADAPT | Shared visual shell may be retained only if it serves new role-aware destinations |

## Current route-to-Phase-1 mapping

| Phase 1 destination | Canonical route(s) after adaptation | Routes explicitly not used |
|---|---|---|
| Patient Home | `dashboard` role shell + adapted `Home` content | Feed, Post, Circles, Articles tabs |
| Patient Find Care | `search`, `specialistDetails` | `findMentor`, local `publicProfile` |
| Patient Appointments | `appointments` | local `bookAppointment` |
| Patient Messages | `messages`, `chat` after contract | `message` alias, seeded Home messages |
| Patient Profile | `account`, adapted `settings` | creator portfolio and unsupported security drafts |
| Professional Home | `dashboard` role shell + adapted `Home` content | feed/content dashboard |
| Professional Schedule | adapted `selectedDates` | generic `schedules`, `reminder` |
| Professional Appointments | `appointments` | local `bookAppointment` |
| Professional Messages | `messages`, `chat` after contract | generic/seeded messaging |
| Professional Profile | `manageProfile`, `professionalVerificationDocuments`, adapted account/settings/edit routes | `managePortfolio`, creator `publicProfile` |
| Notifications | `notification` from header bell | bottom-nav Notifications tab |

## Removal ordering rule

Classification does not authorize immediate deletion. Runtime work must first:

1. Create and verify the archive refs.
2. Remove deferred/obsolete destinations from active navigation.
3. Remove their router cases only after no retained caller uses them.
4. Prove retained auth, onboarding, Find Care, availability, appointments,
   verification, profile, and account paths.
5. Remove exclusive dead files, assets, packages, and tests in a separate cleanup
   slice with an import/package usage report.
