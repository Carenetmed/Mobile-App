import 'package:app_t/core/constants/navigators/router.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Home/presentation/pages/dashboard.dart';
import 'package:app_t/features/Home/presentation/state/account_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpDashboard(WidgetTester tester) async {
  AccountLocalStore.reset();
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => const MaterialApp(
            home: Dashboard(),
            onGenerateRoute: generateRoute,
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('drawer profile opens the account page', (tester) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Delete account'), findsWidgets);
  });

  testWidgets('delete account validates required fields', (tester) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete account').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete account').last);
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Phone number is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('deactivate instead shows the local deactivation modal', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete account').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deactivate your instead?'));
    await tester.pumpAndSettle();

    expect(find.text('Your account is now deactivated'), findsOneWidget);
    expect(find.text('Activate account'), findsOneWidget);
  });

  testWidgets('settings profile validates username and saves locally', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings & Profile'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'lagbaja_carenet'),
      'lagbajatamedu',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'doctor@carenet.app'),
      'doctor',
    );
    await tester.pumpAndSettle();

    expect(find.text('Username taken'), findsOneWidget);
    expect(find.text('Enter a valid email address'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'lagbajatamedu'),
      'lagbaja_new',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'doctor'),
      'newdoctor@carenet.app',
    );
    await tester.enterText(
      find.widgetWithText(
        TextFormField,
        'Husband | Father | Anonymous | Needs help constantly',
      ),
      'Local test bio update',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('newdoctor@carenet.app'), findsOneWidget);
  });

  testWidgets('authentication row opens two-step verification route', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Authentication'));
    await tester.pumpAndSettle();

    expect(find.text('Two-step verification'), findsWidgets);
    expect(find.text('Change PIN'), findsOneWidget);
    expect(find.text('Turn off'), findsOneWidget);
    expect(find.text('Learn more'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsWidgets);

    await tester.tap(find.text('Review turn-on setup'));
    await tester.pumpAndSettle();

    expect(find.text('Turn on Authentication'), findsOneWidget);
    expect(
      find.text(
        'For extra security, turn on two-step verification, which will require a PIN when switching your device.',
      ),
      findsOneWidget,
    );
    expect(find.text('Turn on'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);

    await tester.tap(find.text('Review PIN setup'));
    await tester.pumpAndSettle();

    expect(
      find.text('Create a 6-digit PIN that you can remember'),
      findsOneWidget,
    );

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('PIN is required'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter 6-digit PIN'),
      '123',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a 6-digit PIN'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter 6-digit PIN'),
      '123456',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('ready for secure backend storage'),
      findsOneWidget,
    );
    expect(find.text('Review confirmation step'), findsOneWidget);

    await tester.tap(find.text('Review confirmation step'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm your PIN'), findsWidgets);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('PIN is required'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, '*  *  *      *   *   *'),
      '123',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a 6-digit PIN'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, '*  *  *      *   *   *'),
      '654321',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('PINs do not match'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, '*  *  *      *   *   *'),
      '123456',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('PIN confirmation is ready'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Turn on'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });

  testWidgets('phone number row opens local add-phone draft route', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Phone number'));
    await tester.pumpAndSettle();

    expect(find.text('Add phone number'), findsOneWidget);
    expect(find.text('Current: +234 801 234 5678'), findsOneWidget);

    await tester.tap(find.text('Prepare verification'));
    await tester.pumpAndSettle();

    expect(find.text('Phone number is required'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter phone number'),
      '+234 802 111 2222',
    );
    await tester.tap(find.text('Prepare verification'));
    await tester.pumpAndSettle();

    expect(find.textContaining('ready for SMS verification'), findsOneWidget);
    expect(find.text('Open confirmation step'), findsOneWidget);

    await tester.tap(find.text('Open confirmation step'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm phone number'), findsOneWidget);
    expect(find.text('Enter your phone number to continue'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, '+234 802 111 2222'),
      findsOneWidget,
    );

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('ready for backend OTP verification'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('+234 801 234 5678'), findsOneWidget);
  });

  testWidgets('confirm phone number route validates without saving account', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    Navigator.of(
      tester.element(find.byType(Dashboard)),
    ).pushNamed(RouteName.confirmPhoneNumber);
    await tester.pumpAndSettle();

    expect(find.text('Confirm phone number'), findsOneWidget);
    expect(find.text('Current saved phone: +234 801 234 5678'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Phone number is required'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter phone number'),
      '123',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid phone number'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, '123'),
      '+234 803 333 4444',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('ready for backend OTP verification'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('+234 801 234 5678'), findsOneWidget);
  });

  testWidgets('email address row opens local add-email draft route', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Email address'));
    await tester.pumpAndSettle();

    expect(find.text('Add email address'), findsOneWidget);
    expect(find.text('Current: doctor@carenet.app'), findsOneWidget);

    await tester.tap(find.text('Prepare verification'));
    await tester.pumpAndSettle();

    expect(find.text('Email address is required'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter email address'),
      'doctor',
    );
    await tester.tap(find.text('Prepare verification'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter email address'),
      'newdoctor@carenet.app',
    );
    await tester.tap(find.text('Prepare verification'));
    await tester.pumpAndSettle();

    expect(find.textContaining('ready for email verification'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('doctor@carenet.app'), findsOneWidget);
  });

  testWidgets('change existing email opens local change-email draft route', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Email address'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change existing email'));
    await tester.pumpAndSettle();

    expect(find.text('Change your email address'), findsOneWidget);
    expect(
      find.text('We will send a verification code to this email address'),
      findsOneWidget,
    );
    expect(find.text('Current: doctor@carenet.app'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Email address is required'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter email'),
      'doctor',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter email'),
      'doctor@carenet.app',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a different email address'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter email'),
      'changed-doctor@carenet.app',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.textContaining('ready for code verification'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('doctor@carenet.app'), findsOneWidget);
  });

  testWidgets('review current email opens local edit-email route', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Email address'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review current email'));
    await tester.pumpAndSettle();

    expect(find.text('Email address'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('doctor@carenet.app'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);
    expect(find.text('Edit email'), findsOneWidget);
    expect(find.text('Remove email'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);

    await tester.tap(find.text('Remove email'));
    await tester.pumpAndSettle();

    expect(find.text('doctor@carenet.app'), findsOneWidget);

    await tester.tap(find.text('Edit email'));
    await tester.pumpAndSettle();

    expect(find.text('Change your email address'), findsOneWidget);
  });

  testWidgets('password-to-save route prepares backend re-auth only', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Email address'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review current email'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review password step'));
    await tester.pumpAndSettle();

    expect(find.text('Enter password to save'), findsOneWidget);
    expect(find.text('Enter your password to continue'), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('Password is required'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter your password'),
      'short',
    );
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('Enter at least 8 characters'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter your password'),
      'CareNet@123',
    );
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('ready for backend re-authentication'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('doctor@carenet.app'), findsOneWidget);
  });

  testWidgets('password row opens locked password route', (tester) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Password'));
    await tester.pumpAndSettle();

    expect(find.text('Password'), findsWidgets);
    expect(
      find.text(
        'Your password helps to keep your account secure and makes it easy to log into your account',
      ),
      findsOneWidget,
    );
    expect(find.text('Edit password'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsWidgets);
  });
}
