import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Home/presentation/pages/account_shell.dart';
import 'package:app_t/features/Home/presentation/pages/add_description_shell.dart';
import 'package:app_t/features/Home/presentation/pages/edit_your_name_shell.dart';
import 'package:app_t/features/Home/presentation/pages/edit_your_website_shell.dart';
import 'package:app_t/features/Home/presentation/pages/manage_profile_shell.dart';
import 'package:app_t/features/Home/presentation/pages/selected_dates_shell.dart';
import 'package:app_t/features/Home/presentation/pages/set_address_shell.dart';
import 'package:app_t/features/Messaging/presentation/pages/Messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpManageProfile(WidgetTester tester) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: const ManageProfileShellPage(),
            routes: <String, WidgetBuilder>{
              RouteName.settings: (_) => const SettingsProfilePage(),
              RouteName.editYourName: (_) => const EditYourNameShellPage(),
              RouteName.editYourWebsite:
                  (_) => const EditYourWebsiteShellPage(),
              RouteName.addDescription: (_) => const AddDescriptionShellPage(),
              RouteName.setAddress: (_) => const SetAddressShellPage(),
              RouteName.messages: (_) => const MessagesPage(),
              RouteName.selectedDates: (_) => const SelectedDatesShellPage(),
            },
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('manage profile shows local profile management sections', (
    tester,
  ) async {
    await _pumpManageProfile(tester);

    expect(find.text('Manage Profile'), findsOneWidget);
    expect(find.text('Old People Circle'), findsOneWidget);
    expect(find.text('Basic'), findsOneWidget);
    expect(find.text('Dr. Lagbaja Omo Tamedu'), findsOneWidget);
    expect(find.text('Lagbaja Eye Clinic & Consulting firm'), findsOneWidget);
    expect(find.text('Business'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -650));
    await tester.pumpAndSettle();

    expect(find.text('Articles'), findsOneWidget);
    expect(find.text('Migrating to Linear 101'), findsOneWidget);
  });

  testWidgets('business hours opens a route-local selected-date draft', (
    tester,
  ) async {
    await _pumpManageProfile(tester);

    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit hours'));
    await tester.pumpAndSettle();

    expect(find.text('Edit business hours'), findsOneWidget);
    expect(find.byType(CalendarDatePicker), findsOneWidget);
    expect(find.text('All day'), findsOneWidget);
    expect(find.text('Weekly availability'), findsOneWidget);

    await tester.tap(find.text('Prepare hours'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Business hours draft prepared'),
      findsOneWidget,
    );
    expect(
      find.textContaining('No profile schedule has been saved'),
      findsOneWidget,
    );
  });

  testWidgets('edit action opens local name draft route', (tester) async {
    await _pumpManageProfile(tester);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit your name'), findsOneWidget);
    expect(find.text('Enter a new name to continue'), findsOneWidget);
    expect(find.text('Your name'), findsWidgets);

    await tester.enterText(find.byType(TextFormField), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Dr. New Name');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Name draft prepared'), findsOneWidget);
    expect(find.text('Dr. New Name'), findsWidgets);
    expect(
      find.textContaining('No profile name has been saved'),
      findsOneWidget,
    );
  });

  testWidgets('basic website action opens local website draft route', (
    tester,
  ) async {
    await _pumpManageProfile(tester);

    await tester.tap(find.text('Edit website'));
    await tester.pumpAndSettle();

    expect(find.text('Edit your website'), findsOneWidget);
    expect(find.text('Add a website'), findsOneWidget);
    expect(find.text('Your website'), findsWidgets);

    await tester.enterText(find.byType(TextFormField), 'not-a-website');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid website'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'exampleclinic.com');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Website draft prepared'), findsOneWidget);
    expect(find.text('exampleclinic.com'), findsWidgets);
    expect(
      find.textContaining('No profile website has been saved'),
      findsOneWidget,
    );
  });

  testWidgets('basic address action opens local address draft route', (
    tester,
  ) async {
    await _pumpManageProfile(tester);

    await tester.tap(find.text('Edit address'));
    await tester.pumpAndSettle();

    expect(find.text('Set address'), findsOneWidget);
    expect(find.text('Your location'), findsWidgets);

    await tester.enterText(find.byType(TextFormField), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Address is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Short');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter at least 10 characters'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField),
      '12 Community Clinic Road, Epe, Lagos',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Address draft prepared'), findsOneWidget);
    expect(find.text('12 Community Clinic Road, Epe, Lagos'), findsWidgets);
    expect(
      find.textContaining('No profile address has been saved'),
      findsOneWidget,
    );
  });

  testWidgets('about action opens local description draft route', (
    tester,
  ) async {
    await _pumpManageProfile(tester);

    await tester.tap(find.text('Edit description'));
    await tester.pumpAndSettle();

    expect(find.text('Add description'), findsOneWidget);
    expect(find.text('Description'), findsWidgets);

    await tester.enterText(find.byType(TextFormField), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Description is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Short');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter at least 20 characters'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField),
      'Experienced clinician focused on practical community care.',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Description draft prepared'), findsOneWidget);
    expect(
      find.textContaining('No profile description has been saved'),
      findsOneWidget,
    );
  });

  testWidgets('message action uses existing honest route', (tester) async {
    await _pumpManageProfile(tester);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Message'));
    await tester.pumpAndSettle();

    expect(find.text('Messages'), findsWidgets);
    expect(find.text('Dr. Lagbaja has replied your message.'), findsOneWidget);
  });

  testWidgets('backend dependent management actions are disabled', (
    tester,
  ) async {
    await _pumpManageProfile(tester);

    for (final label in <String>['Events', 'Boost', 'Podcast', 'Share']) {
      final chip = tester.widget<ActionChip>(
        find.widgetWithText(ActionChip, label),
      );
      expect(chip.onPressed, isNull);
    }

    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();

    expect(find.text('Add members'), findsOneWidget);
    expect(find.text('Edit group details'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsWidgets);
  });
}
