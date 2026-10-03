import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/routing/deferred_feature_page.dart';
import 'package:app_t/core/routing/unknown_route_page.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_in_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_con.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_arguments.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_role_selection.dart';
import 'package:app_t/features/Authentication/presentation/pages/enter_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/email_verification_confirm_page.dart';
import 'package:app_t/features/Authentication/presentation/pages/reset_password_confirm_page.dart';
import 'package:app_t/features/Consultation/presentation/pages/consultation_shell.dart';
import 'package:app_t/features/Home/presentation/pages/add_description_shell.dart';
import 'package:app_t/features/Home/presentation/pages/account_shell.dart';
import 'package:app_t/features/Home/presentation/pages/appointment_experience_shell.dart';
import 'package:app_t/features/Home/presentation/pages/dashboard.dart';
import 'package:app_t/features/Home/presentation/pages/edit_professional_details_shell.dart';
import 'package:app_t/features/Home/presentation/pages/edit_your_name_shell.dart';
import 'package:app_t/features/Home/presentation/pages/professional_verification_documents_shell.dart';
import 'package:app_t/features/Home/presentation/pages/professional_finance_shell.dart';
import 'package:app_t/features/Home/presentation/pages/reminder_shell.dart';
import 'package:app_t/features/Home/presentation/pages/schedules_shell.dart';
import 'package:app_t/features/Home/presentation/pages/selected_dates_shell.dart';
import 'package:app_t/features/Home/presentation/pages/search_shell.dart';
import 'package:app_t/features/Home/presentation/pages/specialist_details_shell.dart';
import 'package:app_t/features/Messaging/presentation/pages/Chat.dart' as chat;
import 'package:app_t/features/Messaging/presentation/pages/Messages.dart'
    as messages;
import 'package:app_t/features/Messaging/presentation/pages/Notification.dart';
import 'package:app_t/features/Messaging/presentation/state/messaging_controllers.dart';
import 'package:app_t/features/Notifications/presentation/pages/notification_preferences_page.dart';
import 'package:app_t/features/Onboarding/presentation/pages/onboarding.dart';
import 'package:app_t/features/Onboarding/presentation/pages/profile_setup.dart';
import 'package:app_t/features/Onboarding/presentation/pages/user_edit.dart';
import 'package:app_t/features/splash/presentation/pages/splash_screen.dart';
import 'package:flutter/material.dart';

/// Central route table. Every [RouteName] used in the app must have a case here.
/// See [docs/ROUTES.md] for the human-readable map.
Route<dynamic> generateRoute(RouteSettings settings) {
  final authLinkRoute = _authLinkRoute(settings);
  if (authLinkRoute != null) {
    return authLinkRoute;
  }
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
          initialEmail: args is FinishSignUpArgs
              ? args.initialEmail
              : args is String
              ? args
              : null,
          selectedRole: args is FinishSignUpArgs
              ? args.role
              : SignUpRole.patient,
          onboardingRepository: args is FinishSignUpArgs
              ? args.onboardingRepository
              : null,
        ),
      );
    case RouteName.signUpRole:
      final args = settings.arguments;
      return _page(
        settings,
        SignUpRoleSelectionPage(
          initialEmail: args is SignUpRoleSelectionArgs
              ? args.initialEmail
              : null,
          googleSignUp: args is SignUpRoleSelectionArgs
              ? args.googleSignUp
              : false,
          passwordSignUp: args is SignUpRoleSelectionArgs
              ? args.passwordSignUp
              : false,
          authRepository: args is SignUpRoleSelectionArgs
              ? args.authRepository
              : null,
          googleIdTokenProvider: args is SignUpRoleSelectionArgs
              ? args.googleIdTokenProvider
              : null,
          onboardingRepository: args is SignUpRoleSelectionArgs
              ? args.onboardingRepository
              : null,
        ),
      );
    case RouteName.communityAgreement:
    case RouteName.notificationAgreement:
      return _page(settings, const PatientOnboardingSetupPage());
    case RouteName.patientOnboardingSetup:
      return _page(settings, const PatientOnboardingSetupPage());
    case RouteName.medicalAgreement:
      return _page(settings, const ProfessionalOnboardingSetupPage());
    case RouteName.medicalProfessional:
      return _page(settings, const ProfessionalOnboardingSetupPage());
    case RouteName.signUpPhone:
      return _page(settings, const SignUpEmail());
    case RouteName.signUpEmail:
      return _page(settings, SignUpEmail());
    case RouteName.signInPhone:
      return _page(settings, const SignInEmail());
    case RouteName.signInEmail:
      return _page(settings, const SignInEmail());
    case RouteName.enterEmail:
      return _page(settings, const EnterEmailPage());
    case RouteName.enterPassword:
      return _page(settings, const ResetPasswordConfirmPage(token: null));
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
    case RouteName.consultation:
      final args = settings.arguments;
      return _page(
        settings,
        ConsultationShellPage(
          appointmentId: args is ConsultationRouteArgs
              ? args.appointmentId
              : null,
        ),
      );
    case RouteName.bookAppointment:
      return _page(settings, const SearchShellPage());
    case RouteName.account:
      return _page(settings, const AccountShellPage());
    case RouteName.publicProfile:
      return _page(settings, const SearchShellPage());
    case RouteName.manageProfile:
      return _page(settings, const ProfessionalOnboardingSetupPage());
    case RouteName.professionalVerificationDocuments:
      return _page(
        settings,
        const ProfessionalVerificationDocumentsShellPage(),
      );
    case RouteName.professionalFinance:
      return _page(settings, const ProfessionalFinanceShellPage());
    case RouteName.editYourName:
      return _page(settings, const EditYourNameShellPage());
    case RouteName.editProfessionalDetails:
      return _page(settings, const EditProfessionalDetailsShellPage());
    case RouteName.addDescription:
      return _page(settings, const AddDescriptionShellPage());
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
    case RouteName.notificationPreferences:
      return _page(settings, const NotificationPreferencesPage());
    case RouteName.reminder:
      return _page(settings, const ReminderShellPage());
    case RouteName.schedules:
      return _page(settings, const SchedulesShellPage());
    case RouteName.selectedDates:
      return _page(settings, const SelectedDatesShellPage());
    case RouteName.readings:
    case RouteName.healthRecord:
    case RouteName.manageReadings:
    case RouteName.addDevice:
    case RouteName.bloodSug:
    case RouteName.articles:
    case RouteName.savedArticles:
    case RouteName.publishedArticles:
    case RouteName.caseStudies:
    case RouteName.podcast:
    case RouteName.emergency:
    case RouteName.distressCall:
    case RouteName.settings:
    case RouteName.changeAuthentication:
    case RouteName.turnOnAuthentication:
    case RouteName.createPin:
    case RouteName.confirmPinSave:
    case RouteName.addPhoneNumber:
    case RouteName.confirmPhoneNumber:
    case RouteName.addEmail:
    case RouteName.editEmail:
    case RouteName.changeEmail:
    case RouteName.enterPasswordToSave:
    case RouteName.password:
    case RouteName.managePortfolio:
    case RouteName.editYourWebsite:
    case RouteName.setAddress:
    case RouteName.discoverCommunities:
    case RouteName.communityProfile:
    case RouteName.ownerCircleProfile:
    case RouteName.createCommunity:
    case RouteName.qAAsk:
    case RouteName.qAAnswerRequests:
    case RouteName.qAAnswerForYou:
    case RouteName.commentAnswer:
      return _page(settings, const DeferredFeaturePage());
    case RouteName.deleteAccount:
      return _page(settings, const AccountShellPage());
    default:
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => UnknownRoutePage(routeName: settings.name),
      );
  }
}

Route<dynamic>? _authLinkRoute(RouteSettings settings) {
  final rawName = settings.name;
  if (rawName == null || rawName.isEmpty) return null;

  final uri = Uri.tryParse(rawName);
  if (uri == null) return null;
  if (uri.hasAuthority &&
      uri.host != 'project-a96784ee-811c-46ab-a7b.web.app') {
    return null;
  }

  final token = uri.queryParameters['token'];
  switch (uri.path) {
    case '/verify-email':
      return _page(settings, EmailVerificationConfirmPage(token: token));
    case '/reset-password':
      return _page(settings, ResetPasswordConfirmPage(token: token));
  }
  return null;
}

MaterialPageRoute<void> _page(RouteSettings settings, Widget child) {
  return MaterialPageRoute<void>(
    settings: RouteSettings(name: settings.name, arguments: settings.arguments),
    builder: (_) => child,
  );
}
