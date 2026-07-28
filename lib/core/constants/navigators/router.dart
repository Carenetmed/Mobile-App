import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/routing/unknown_route_page.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_in_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_in_phone.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_con.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_phone.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_arguments.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_role_selection.dart';
import 'package:app_t/features/Authentication/presentation/pages/enter_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/enter_password.dart';
import 'package:app_t/features/Authentication/presentation/pages/email_verification_confirm_page.dart';
import 'package:app_t/features/Authentication/presentation/pages/reset_password_confirm_page.dart';
import 'package:app_t/features/Home/presentation/pages/add_device_shell.dart';
import 'package:app_t/features/Home/presentation/pages/add_description_shell.dart';
import 'package:app_t/features/Home/presentation/pages/account_shell.dart';
import 'package:app_t/features/Home/presentation/pages/add_email_shell.dart';
import 'package:app_t/features/Home/presentation/pages/add_phone_number_shell.dart';
import 'package:app_t/features/Home/presentation/pages/appointment_experience_shell.dart';
import 'package:app_t/features/Home/presentation/pages/articles_shell.dart';
import 'package:app_t/features/Home/presentation/pages/blood_sug_shell.dart';
import 'package:app_t/features/Home/presentation/pages/case_studies_shell.dart';
import 'package:app_t/features/Home/presentation/pages/change_email_shell.dart';
import 'package:app_t/features/Home/presentation/pages/change_authentication_shell.dart';
import 'package:app_t/features/Home/presentation/pages/confirm_pin_save_shell.dart';
import 'package:app_t/features/Home/presentation/pages/confirm_phone_number_shell.dart';
import 'package:app_t/features/Home/presentation/pages/circles_shell.dart';
import 'package:app_t/features/Home/presentation/pages/community_profile_page.dart';
import 'package:app_t/features/Home/presentation/pages/create_community_page.dart';
import 'package:app_t/features/Home/presentation/pages/create_pin_shell.dart';
import 'package:app_t/features/Home/presentation/pages/dashboard.dart';
import 'package:app_t/features/Home/presentation/pages/edit_email_shell.dart';
import 'package:app_t/features/Home/presentation/pages/edit_professional_details_shell.dart';
import 'package:app_t/features/Home/presentation/pages/edit_your_name_shell.dart';
import 'package:app_t/features/Home/presentation/pages/edit_your_website_shell.dart';
import 'package:app_t/features/Home/presentation/pages/emergency_shell.dart';
import 'package:app_t/features/Home/presentation/pages/enter_password_to_save_shell.dart';
import 'package:app_t/features/Home/presentation/pages/health_record_shell.dart';
import 'package:app_t/features/Home/presentation/pages/manage_profile_shell.dart';
import 'package:app_t/features/Home/presentation/pages/manage_portfolio_shell.dart';
import 'package:app_t/features/Home/presentation/pages/manage_readings.dart';
import 'package:app_t/features/Home/presentation/pages/password_shell.dart';
import 'package:app_t/features/Home/presentation/pages/podcast_shell.dart';
import 'package:app_t/features/Home/presentation/pages/professional_verification_documents_shell.dart';
import 'package:app_t/features/Home/presentation/pages/published_articles_shell.dart';
import 'package:app_t/features/Home/presentation/pages/qa_shell.dart';
import 'package:app_t/features/Home/presentation/pages/readings.dart';
import 'package:app_t/features/Home/presentation/pages/reminder_shell.dart';
import 'package:app_t/features/Home/presentation/pages/schedules_shell.dart';
import 'package:app_t/features/Home/presentation/pages/selected_dates_shell.dart';
import 'package:app_t/features/Home/presentation/pages/set_address_shell.dart';
import 'package:app_t/features/Home/presentation/pages/saved_articles_shell.dart';
import 'package:app_t/features/Home/presentation/pages/search_shell.dart';
import 'package:app_t/features/Home/presentation/pages/specialist_details_shell.dart';
import 'package:app_t/features/Home/presentation/pages/turn_on_authentication_shell.dart';
import 'package:app_t/features/Home/presentation/state/communities_local_store.dart';
import 'package:app_t/features/Messaging/presentation/pages/Chat.dart' as chat;
import 'package:app_t/features/Messaging/presentation/pages/Messages.dart'
    as messages;
import 'package:app_t/features/Messaging/presentation/pages/Notification.dart';
import 'package:app_t/features/Messaging/presentation/state/messaging_controllers.dart';
import 'package:app_t/features/Onboarding/presentation/pages/commitment_screen.dart';
import 'package:app_t/features/Onboarding/presentation/pages/medical_agreement.dart';
import 'package:app_t/features/Onboarding/presentation/pages/notification.dart';
import 'package:app_t/features/Onboarding/presentation/pages/onboarding.dart';
import 'package:app_t/features/Onboarding/presentation/pages/profile_setup.dart';
import 'package:app_t/features/Onboarding/presentation/pages/user_edit.dart';
import 'package:app_t/features/splash/presentation/pages/splash_screen.dart';
import 'package:flutter/material.dart';

/// Central route table. Every [RouteName] used in the app must have a case here.
/// See [docs/ROUTES.md] for the human-readable map.
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case RouteName.splash:
      return _page(settings, const SplashScreen());
    case RouteName.onboarding:
      return _page(settings, const OnboardingView());
    case RouteName.finishSignUp:
      final args = settings.arguments;
      return _page(
        settings,
        FinSignUp(
          initialEmail:
              args is FinishSignUpArgs
                  ? args.initialEmail
                  : args is String
                  ? args
                  : null,
          selectedRole:
              args is FinishSignUpArgs ? args.role : SignUpRole.patient,
          onboardingRepository:
              args is FinishSignUpArgs ? args.onboardingRepository : null,
        ),
      );
    case RouteName.signUpRole:
      final args = settings.arguments;
      return _page(
        settings,
        SignUpRoleSelectionPage(
          initialEmail:
              args is SignUpRoleSelectionArgs ? args.initialEmail : null,
          googleSignUp:
              args is SignUpRoleSelectionArgs ? args.googleSignUp : false,
          passwordSignUp:
              args is SignUpRoleSelectionArgs ? args.passwordSignUp : false,
          authRepository:
              args is SignUpRoleSelectionArgs ? args.authRepository : null,
          googleIdTokenProvider:
              args is SignUpRoleSelectionArgs
                  ? args.googleIdTokenProvider
                  : null,
          onboardingRepository:
              args is SignUpRoleSelectionArgs
                  ? args.onboardingRepository
                  : null,
        ),
      );
    case RouteName.communityAgreement:
      return _page(settings, CommunityCommitment());
    case RouteName.patientOnboardingSetup:
      return _page(settings, const PatientOnboardingSetupPage());
    case RouteName.notificationAgreement:
      return _page(settings, NotificationScreen());
    case RouteName.medicalAgreement:
      return _page(settings, MedicalAgreement());
    case RouteName.medicalProfessional:
      return _page(settings, const ProfessionalOnboardingSetupPage());
    case RouteName.signUpPhone:
      return _page(settings, SignUpPhone());
    case RouteName.signUpEmail:
      return _page(settings, SignUpEmail());
    case RouteName.signInPhone:
      return _page(settings, const SignInPhone());
    case RouteName.signInEmail:
      return _page(settings, const SignInEmail());
    case RouteName.enterEmail:
      return _page(settings, const EnterEmailPage());
    case RouteName.enterPassword:
      return _page(settings, const EnterPasswordPage());
    case RouteName.resetPasswordConfirm:
      final args = settings.arguments;
      return _page(
        settings,
        ResetPasswordConfirmPage(token: args is String ? args : null),
      );
    case RouteName.emailVerificationConfirm:
      final args = settings.arguments;
      return _page(
        settings,
        EmailVerificationConfirmPage(token: args is String ? args : null),
      );
    case RouteName.medicalEdit:
      return _page(settings, UserEdit());
    case RouteName.dashboard:
      final initialIndex = settings.arguments;
      return _page(
        settings,
        Dashboard(initialIndex: initialIndex is int ? initialIndex : 0),
      );
    case RouteName.search:
      return _page(settings, const SearchShellPage());
    case RouteName.findMentor:
      return _page(settings, const SearchShellPage());
    case RouteName.specialistDetails:
      final args = settings.arguments;
      return _page(
        settings,
        SpecialistDetailsShellPage(specialistId: args is String ? args : null),
      );
    case RouteName.appointments:
      return _page(settings, const AppointmentsShellPage());
    case RouteName.appointmentDetail:
      final args = settings.arguments;
      return _page(
        settings,
        AppointmentDetailShellPage(appointmentId: args is String ? args : null),
      );
    case RouteName.bookAppointment:
      return _page(settings, const SearchShellPage());
    case RouteName.readings:
      return _page(settings, VitalsReading());
    case RouteName.healthRecord:
      return _page(settings, const HealthRecordShellPage());
    case RouteName.manageReadings:
      return _page(settings, ManageReadings());
    case RouteName.addDevice:
      return _page(settings, const AddDeviceShellPage());
    case RouteName.bloodSug:
      return _page(settings, const BloodSugShellPage());
    case RouteName.articles:
      return _page(settings, const ArticlesShellPage());
    case RouteName.savedArticles:
      return _page(settings, const SavedArticlesShellPage());
    case RouteName.publishedArticles:
      return _page(settings, const PublishedArticlesShellPage());
    case RouteName.caseStudies:
      return _page(settings, const CaseStudiesShellPage());
    case RouteName.podcast:
      return _page(settings, const PodcastShellPage());
    case RouteName.emergency:
      return _page(settings, const EmergencyShellPage());
    case RouteName.distressCall:
      return _page(settings, const DistressCallPage());
    case RouteName.account:
      return _page(settings, const AccountShellPage());
    case RouteName.deleteAccount:
      return _page(settings, const DeleteAccountPage());
    case RouteName.settings:
      return _page(settings, const SettingsProfilePage());
    case RouteName.changeAuthentication:
      return _page(settings, const ChangeAuthenticationShellPage());
    case RouteName.turnOnAuthentication:
      return _page(settings, const TurnOnAuthenticationShellPage());
    case RouteName.createPin:
      return _page(settings, const CreatePinShellPage());
    case RouteName.confirmPinSave:
      final args = settings.arguments;
      return _page(
        settings,
        ConfirmPinSaveShellPage(draftPin: args is String ? args : null),
      );
    case RouteName.addPhoneNumber:
      return _page(settings, const AddPhoneNumberShellPage());
    case RouteName.confirmPhoneNumber:
      final args = settings.arguments;
      return _page(
        settings,
        ConfirmPhoneNumberShellPage(
          initialPhoneNumber: args is String ? args : null,
        ),
      );
    case RouteName.addEmail:
      return _page(settings, const AddEmailShellPage());
    case RouteName.editEmail:
      return _page(settings, const EditEmailShellPage());
    case RouteName.changeEmail:
      return _page(settings, const ChangeEmailShellPage());
    case RouteName.enterPasswordToSave:
      return _page(settings, const EnterPasswordToSaveShellPage());
    case RouteName.password:
      return _page(settings, const PasswordShellPage());
    case RouteName.publicProfile:
      return _page(settings, const SearchShellPage());
    case RouteName.manageProfile:
      return _page(settings, const ManageProfileShellPage());
    case RouteName.managePortfolio:
      return _page(settings, const ManagePortfolioShellPage());
    case RouteName.professionalVerificationDocuments:
      return _page(
        settings,
        const ProfessionalVerificationDocumentsShellPage(),
      );
    case RouteName.editYourName:
      return _page(settings, const EditYourNameShellPage());
    case RouteName.editProfessionalDetails:
      return _page(settings, const EditProfessionalDetailsShellPage());
    case RouteName.editYourWebsite:
      return _page(settings, const EditYourWebsiteShellPage());
    case RouteName.addDescription:
      return _page(settings, const AddDescriptionShellPage());
    case RouteName.setAddress:
      return _page(settings, const SetAddressShellPage());
    case RouteName.discoverCommunities:
      return _page(settings, const DiscoverCommunitiesPage());
    case RouteName.communityProfile:
      final args = settings.arguments;
      if (args is CommunityProfileRouteArgs) {
        return _page(
          settings,
          CommunityProfilePage(profile: args.profile, isOwner: args.isOwner),
        );
      }
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => UnknownRoutePage(routeName: settings.name),
      );
    case RouteName.ownerCircleProfile:
      final args = settings.arguments;
      final profile =
          args is CommunityProfileRouteArgs
              ? args.profile
              : CommunitiesLocalStore.ownerCircleProfile;
      return _page(
        settings,
        CommunityProfilePage(profile: profile, isOwner: true),
      );
    case RouteName.createCommunity:
      return _page(settings, const CreateCommunityPage());
    case RouteName.qAAsk:
      return _page(settings, const QaAskPage());
    case RouteName.qAAnswerRequests:
      return _page(settings, const QaAnswerRequestsPage());
    case RouteName.qAAnswerForYou:
      return _page(settings, const QaAnswerForYouPage());
    case RouteName.commentAnswer:
      final args = settings.arguments;
      if (args is QaCommentRouteArgs) {
        return _page(
          settings,
          QaCommentAnswerPage(questionId: args.questionId),
        );
      }
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => UnknownRoutePage(routeName: settings.name),
      );
    case RouteName.messages:
      return _page(settings, const messages.MessagesPage());
    case RouteName.chat:
      final args = settings.arguments;
      return _page(
        settings,
        chat.ChatPage(
          arguments: args is AppointmentConversationRouteArgs ? args : null,
        ),
      );
    case RouteName.message:
      return _page(settings, const chat.ChatPage());
    case RouteName.notification:
      return _page(settings, const NotificationsPage());
    case RouteName.reminder:
      return _page(settings, const ReminderShellPage());
    case RouteName.schedules:
      return _page(settings, const SchedulesShellPage());
    case RouteName.selectedDates:
      return _page(settings, const SelectedDatesShellPage());
    default:
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => UnknownRoutePage(routeName: settings.name),
      );
  }
}

MaterialPageRoute<void> _page(RouteSettings settings, Widget child) {
  return MaterialPageRoute<void>(
    settings: RouteSettings(name: settings.name, arguments: settings.arguments),
    builder: (_) => child,
  );
}
