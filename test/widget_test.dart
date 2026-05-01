import 'package:app_t/features/Home/presentation/widget/home_readings_row.dart';
import 'package:app_t/features/Messaging/presentation/pages/notification_center_page.dart';
import 'package:app_t/features/Reminders/presentation/model/reminder_item.dart';
import 'package:app_t/features/Reminders/presentation/pages/reminder_editor_page.dart';
import 'package:app_t/features/Reminders/presentation/pages/reminders_page.dart';
import 'package:app_t/features/Settings/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Settings screen renders expected sections', (
    WidgetTester tester,
  ) async {
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

  testWidgets('Reminders screen renders the overview and seeded reminders', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(430, 932),
        builder: (context, child) {
          return const MaterialApp(home: RemindersPage());
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Reminders'), findsOneWidget);
    expect(find.text('Stay on top of your care plan'), findsOneWidget);
    expect(find.text('Morning medication'), findsOneWidget);
    expect(find.text('Create reminder'), findsOneWidget);
  });

  testWidgets('Reminder editor renders editing controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(430, 932),
        builder: (context, child) {
          return MaterialApp(
            home: ReminderEditorPage(reminder: sampleReminders.first),
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Edit Reminder'), findsOneWidget);
    expect(find.text('Reminder setup'), findsOneWidget);
    expect(find.text('Reminder enabled'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);
  });
}
