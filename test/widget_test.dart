import 'package:app_t/features/Home/presentation/widget/home_readings_row.dart';
import 'package:app_t/features/Messaging/presentation/pages/notification_center_page.dart';
import 'package:app_t/features/Reminders/presentation/pages/add_reminder_page.dart';
import 'package:app_t/features/Reminders/presentation/pages/reminder_page.dart';
import 'package:app_t/features/Reminders/presentation/pages/schedule_page.dart';
import 'package:app_t/features/Settings/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _setPhoneSurface(WidgetTester tester) async {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('Settings screen renders expected sections', (
    WidgetTester tester,
  ) async {
    await _setPhoneSurface(tester);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(430, 932),
        builder: (context, child) {
          return const MaterialApp(home: SettingsPage());
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Settings & Privacy'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Privacy & safety'), findsOneWidget);
    expect(find.text('Help & support'), findsOneWidget);
    expect(find.text('Deactivate account'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
  });

  testWidgets('Home readings row renders the new health record cards', (
    WidgetTester tester,
  ) async {
    await _setPhoneSurface(tester);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(430, 932),
        builder: (context, child) {
          return const MaterialApp(home: Scaffold(body: HomeReadingsRow()));
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Add new\nReadings'), findsOneWidget);
    expect(find.text('Blood Sugar'), findsOneWidget);
    expect(find.text('Blood Pressure'), findsOneWidget);
    expect(find.text('Weight'), findsOneWidget);
  });

  testWidgets('Notification center screen renders the figma content', (
    WidgetTester tester,
  ) async {
    await _setPhoneSurface(tester);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(430, 932),
        builder: (context, child) {
          return const MaterialApp(
            home: Scaffold(body: NotificationCenterPage()),
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Events'), findsOneWidget);
    expect(find.text('Your appointment is booked'), findsOneWidget);
    expect(
      find.text('360 Club event is coming up today by 6pm'),
      findsOneWidget,
    );
  });

  testWidgets('Reminder pages render exported schedule content', (
    WidgetTester tester,
  ) async {
    await _setPhoneSurface(tester);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(430, 932),
        builder: (context, child) {
          return const MaterialApp(home: ReminderPage());
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Reminder'), findsOneWidget);
    expect(find.text('Friday, February, 07, 2025'), findsOneWidget);
    expect(
      find.text('You have no reminders. Add reminders now'),
      findsOneWidget,
    );
  });

  testWidgets('Add reminder and task reminder pages render core content', (
    WidgetTester tester,
  ) async {
    await _setPhoneSurface(tester);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(430, 932),
        builder: (context, child) {
          return const MaterialApp(home: AddReminderPage());
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Add Reminder'), findsOneWidget);
    expect(find.text('Reminder Type'), findsOneWidget);
    expect(find.text('Add another alert'), findsOneWidget);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(430, 932),
        builder: (context, child) {
          return const MaterialApp(home: SchedulePage());
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Task Reminder'), findsOneWidget);
    expect(find.text('Doctors Without Border Event'), findsOneWidget);
    expect(find.text('Starts in'), findsOneWidget);
    expect(find.text('Wednesday,'), findsOneWidget);
  });
}
