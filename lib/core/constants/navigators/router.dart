import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_in_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_in_phone.dart';
import 'package:app_t/features/Home/presentation/pages/dashboard.dart';
import 'package:app_t/features/Onboarding/presentation/pages/commitment_screen.dart';
import 'package:app_t/features/Onboarding/presentation/pages/medical_agreement.dart';
import 'package:app_t/features/Onboarding/presentation/pages/notification.dart';
import 'package:app_t/features/Onboarding/presentation/pages/onboarding.dart';
import 'package:app_t/features/Onboarding/presentation/pages/profession.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_con.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_phone.dart';
import 'package:app_t/features/Onboarding/presentation/pages/user_edit.dart';
import 'package:app_t/features/splash/presentation/pages/splash_screen.dart';
import 'package:app_t/features/Messaging/presentation/pages/Messages.dart' as messages;
import 'package:app_t/features/Messaging/presentation/pages/Chat.dart' as chat;
import 'package:app_t/features/Messaging/presentation/pages/Message.dart';
import 'package:app_t/features/Messaging/presentation/pages/Notofication.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case RouteName.splash:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const SplashScreen(),
      );
    case RouteName.onboarding:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: OnboardingView(),
      );

    case RouteName.finishSignUp:
      return _getPageRoute(routeName: settings.name!, viewToShow: FinSignUp());

    case RouteName.communityAgreement:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: CommunityCommitment(),
      );
    case RouteName.notificationAgreement:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: NotificationScreen(),
      );
    case RouteName.medicalAgreement:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: MedicalAgreement(),
      );

    case RouteName.medicalProfessional:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: ProfessionScreen(),
      );
    case RouteName.signUpPhone:
      return _getPageRoute(routeName: settings.name!,
          viewToShow: SignUpPhone());

    case RouteName.medicalEdit:
      return _getPageRoute(routeName: settings.name!, viewToShow: UserEdit());

    case RouteName.dashboard:
      return _getPageRoute(routeName: settings.name!, viewToShow: Dashboard());
    case RouteName.signUpEmail:
      return _getPageRoute(routeName: settings.name!,
          viewToShow: SignUpEmail());
    case RouteName.signInEmail:
      return _getPageRoute(routeName: settings.name!,
          viewToShow: SignInEmail());
    case RouteName.signInPhone:
      return _getPageRoute(routeName: settings.name!,
          viewToShow: SignInPhone());
    case RouteName.messages:
      return _getPageRoute(routeName: settings.name!, viewToShow: messages.MessagesPage());
    case RouteName.chat:
      return _getPageRoute(routeName: settings.name!, viewToShow: chat.ChatPageEmpty());
    case RouteName.message:
      return _getPageRoute(routeName: settings.name!, viewToShow: ChatPageUnavailable());
    case RouteName.notification:
      return _getPageRoute(routeName: settings.name!, viewToShow: NotificationsPage());

    /*case RouteName.upload:
      final args = settings.arguments! as UploadParams;
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: UploadPage(params: args),
      ); */

    default:
      return MaterialPageRoute<dynamic>(
        builder:
            (_) => Scaffold(
              body: Center(
                child: Text('No route defined for ${settings.name}'),
              ),
            ),
      );
  }
}

Route<dynamic> _getPageRoute({
  required String routeName,
  required Widget viewToShow,
}) {
  return MaterialPageRoute(
    settings: RouteSettings(name: routeName),
    builder: (_) => viewToShow,
  );
}
