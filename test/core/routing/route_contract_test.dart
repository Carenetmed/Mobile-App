import 'dart:io';

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/constants/navigators/router.dart';
import 'package:app_t/core/routing/deferred_feature_page.dart';
import 'package:app_t/core/routing/unknown_route_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _activeTypes = <String, String>{
  RouteName.splash: 'SplashScreen',
  RouteName.onboarding: 'OnboardingView',
  RouteName.signUpEmail: 'SignUpEmail',
  RouteName.signUpRole: 'SignUpRoleSelectionPage',
  RouteName.finishSignUp: 'FinSignUp',
  RouteName.patientOnboardingSetup: 'PatientOnboardingSetupPage',
  RouteName.signInEmail: 'SignInEmail',
  RouteName.enterEmail: 'EnterEmailPage',
  RouteName.resetPasswordConfirm: 'ResetPasswordConfirmPage',
  RouteName.emailVerificationConfirm: 'EmailVerificationConfirmPage',
  RouteName.dashboard: 'Dashboard',
  RouteName.search: 'SearchShellPage',
  RouteName.specialistDetails: 'SpecialistDetailsShellPage',
  RouteName.appointments: 'AppointmentsShellPage',
  RouteName.appointmentDetail: 'AppointmentDetailShellPage',
  RouteName.consultation: 'ConsultationShellPage',
  RouteName.account: 'AccountShellPage',
  RouteName.editEmail: 'EditEmailShellPage',
  RouteName.professionalVerificationDocuments:
      'ProfessionalVerificationDocumentsShellPage',
  RouteName.professionalFinance: 'ProfessionalFinanceShellPage',
  RouteName.editYourName: 'EditYourNameShellPage',
  RouteName.editProfessionalDetails: 'EditProfessionalDetailsShellPage',
  RouteName.addDescription: 'AddDescriptionShellPage',
  RouteName.messages: 'MessagesPage',
  RouteName.chat: 'ChatPage',
  RouteName.notification: 'NotificationsPage',
  RouteName.notificationPreferences: 'NotificationPreferencesPage',
  RouteName.reminder: 'ReminderShellPage',
  RouteName.schedules: 'SchedulesShellPage',
  RouteName.selectedDates: 'SelectedDatesShellPage',
};

const _aliasTypes = <String, String>{
  RouteName.signUpPhone: 'SignUpEmail',
  RouteName.communityAgreement: 'PatientOnboardingSetupPage',
  RouteName.notificationAgreement: 'PatientOnboardingSetupPage',
  RouteName.medicalAgreement: 'ProfessionalOnboardingSetupPage',
  RouteName.medicalProfessional: 'ProfessionalOnboardingSetupPage',
  RouteName.signInPhone: 'SignInEmail',
  RouteName.enterPassword: 'ResetPasswordConfirmPage',
  RouteName.findMentor: 'SearchShellPage',
  RouteName.bookAppointment: 'SearchShellPage',
  RouteName.deleteAccount: 'AccountShellPage',
  RouteName.publicProfile: 'SearchShellPage',
  RouteName.manageProfile: 'ProfessionalOnboardingSetupPage',
  RouteName.message: 'ChatPage',
};

const _deferredRoutes = <String>{
  RouteName.medicalEdit,
  RouteName.readings,
  RouteName.healthRecord,
  RouteName.manageReadings,
  RouteName.addDevice,
  RouteName.bloodSug,
  RouteName.articles,
  RouteName.savedArticles,
  RouteName.publishedArticles,
  RouteName.caseStudies,
  RouteName.podcast,
  RouteName.emergency,
  RouteName.distressCall,
  RouteName.discoverCommunities,
  RouteName.communityProfile,
  RouteName.ownerCircleProfile,
  RouteName.createCommunity,
  RouteName.qAAsk,
  RouteName.qAAnswerRequests,
  RouteName.qAAnswerForYou,
  RouteName.commentAnswer,
  RouteName.settings,
  RouteName.changeAuthentication,
  RouteName.turnOnAuthentication,
  RouteName.createPin,
  RouteName.confirmPinSave,
  RouteName.addPhoneNumber,
  RouteName.confirmPhoneNumber,
  RouteName.addEmail,
  RouteName.changeEmail,
  RouteName.enterPasswordToSave,
  RouteName.password,
  RouteName.managePortfolio,
  RouteName.editYourWebsite,
  RouteName.setAddress,
};

void main() {
  test('every declared route has exactly one reviewed disposition', () {
    final routeSource =
        File('lib/core/constants/navigators/routeName.dart').readAsStringSync();
    final sourceMatches =
        RegExp(
          r"static const String\s+\w+\s*=\s*'([^']+)'",
        ).allMatches(routeSource).toList();
    final sourceValues = sourceMatches.map((match) => match.group(1)!).toSet();
    final dispositions = <String>[
      ..._activeTypes.keys,
      ..._aliasTypes.keys,
      ..._deferredRoutes,
      RouteName.login,
    ];

    expect(RouteName.values, hasLength(79));
    expect(sourceMatches, hasLength(RouteName.values.length));
    expect(sourceValues, equals(RouteName.values.toSet()));
    expect(RouteName.values.toSet(), hasLength(RouteName.values.length));
    expect(dispositions.toSet(), hasLength(dispositions.length));
    expect(dispositions.toSet(), equals(RouteName.values.toSet()));
  });

  testWidgets(
    'active and compatibility routes resolve exact reviewed widgets',
    (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (value) {
              context = value;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      for (final entry in {..._activeTypes, ..._aliasTypes}.entries) {
        final page = _pageFor(context, entry.key);
        expect(
          page.runtimeType.toString(),
          entry.value,
          reason: '${entry.key} must keep its reviewed route authority',
        );
      }
    },
  );

  testWidgets('deferred, reserved, and unknown routes fail closed', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    for (final routeName in _deferredRoutes) {
      expect(
        _pageFor(context, routeName),
        isA<DeferredFeaturePage>(),
        reason: '$routeName must remain unavailable in the active product',
      );
    }
    expect(_pageFor(context, RouteName.login), isA<UnknownRoutePage>());
    expect(_pageFor(context, 'not-a-carenet-route'), isA<UnknownRoutePage>());
  });
}

Widget _pageFor(BuildContext context, String routeName) {
  final route = generateRoute(RouteSettings(name: routeName));
  return (route as MaterialPageRoute<void>).builder(context);
}
