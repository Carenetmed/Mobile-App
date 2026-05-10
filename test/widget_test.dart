import 'package:app_t/features/Home/presentation/widget/home_readings_row.dart';
import 'package:app_t/features/Home/presentation/model/reading_metric.dart';
import 'package:app_t/features/Home/presentation/pages/manage_readings.dart';
import 'package:app_t/features/Home/presentation/pages/reading_metric_detail_page.dart';
import 'package:app_t/features/Home/presentation/pages/readings.dart';
import 'package:app_t/features/Messaging/presentation/pages/notification_center_page.dart';
import 'package:app_t/features/Reminders/presentation/pages/add_reminder_page.dart';
import 'package:app_t/features/Reminders/presentation/pages/reminder_page.dart';
import 'package:app_t/features/Reminders/presentation/pages/schedule_page.dart';
import 'package:app_t/features/Reminders/presentation/model/reminder_item.dart';
import 'package:app_t/features/Reminders/presentation/pages/reminder_editor_page.dart';
import 'package:app_t/features/Reminders/presentation/pages/reminders_page.dart';
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
  testWidgets('Reminders screen renders the overview and seeded reminders', (
  testWidgets('Readings overview renders the health record section', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(430, 932),
        builder: (context, child) {
          return const MaterialApp(home: ReminderPage());
          return const MaterialApp(home: RemindersPage());
          return const MaterialApp(home: VitalsReading());
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
    expect(find.text('Reminders'), findsOneWidget);
    expect(find.text('Stay on top of your care plan'), findsOneWidget);
    expect(find.text('Morning medication'), findsOneWidget);
    expect(find.text('Create reminder'), findsOneWidget);
  });

  testWidgets('Reminder editor renders editing controls', (
    expect(find.text('Readings'), findsOneWidget);
    expect(find.text('Health records overview'), findsOneWidget);
    expect(find.text('Blood Pressure'), findsOneWidget);
    expect(find.text('Blood Sugar'), findsOneWidget);
    expect(find.text('Weight'), findsOneWidget);
  });

  testWidgets('Manage readings screen renders key controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(430, 932),
        builder: (context, child) {
          return const MaterialApp(home: AddReminderPage());
          return const MaterialApp(home: ManageReadings());
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Add Reminder'), findsOneWidget);
    expect(find.text('Reminder Type'), findsOneWidget);
    expect(find.text('Add another alert'), findsOneWidget);

    expect(find.text('Manage Readings'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Open readings overview'), findsOneWidget);
  });

  testWidgets('Reading metric detail page renders metric content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(430, 932),
        builder: (context, child) {
          return const MaterialApp(home: SchedulePage());
          return MaterialApp(
            home: ReminderEditorPage(reminder: sampleReminders.first),
            home: ReadingMetricDetailPage(metric: metricById('blood_pressure')),
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Task Reminder'), findsOneWidget);
    expect(find.text('Doctors Without Border Event'), findsOneWidget);
    expect(find.text('Starts in'), findsOneWidget);
    expect(find.text('Wednesday,'), findsOneWidget);
    expect(find.text('Edit Reminder'), findsOneWidget);
    expect(find.text('Reminder setup'), findsOneWidget);
    expect(find.text('Reminder enabled'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);
    expect(find.text('Blood Pressure'), findsWidgets);
    expect(find.text('Current reading'), findsOneWidget);
    expect(find.text('Quick insight'), findsOneWidget);
    expect(find.text('See all readings'), findsOneWidget);
  });
}
