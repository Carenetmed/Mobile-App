import 'package:app_t/features/Home/presentation/pages/dashboard.dart';
import 'package:app_t/features/Home/presentation/pages/appointments_shell.dart';
import 'package:app_t/features/Home/presentation/pages/find_mentor_shell.dart';
import 'package:app_t/features/Home/presentation/pages/reminder_shell.dart';
import 'package:app_t/features/Home/presentation/pages/schedules_shell.dart';
import 'package:app_t/features/Home/presentation/pages/specialist_details_shell.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpDashboard(WidgetTester tester) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: const Dashboard(),
            routes: {
              RouteName.reminder: (_) => const ReminderShellPage(),
              RouteName.schedules: (_) => const SchedulesShellPage(),
              RouteName.findMentor: (_) => const FindMentorShellPage(),
              RouteName.specialistDetails:
                  (_) => const SpecialistDetailsShellPage(),
              RouteName.bookAppointment:
                  (_) => const BookAppointmentShellPage(),
            },
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('dashboard bottom navigation switches to real shell pages', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(find.text('Search specialists'), findsOneWidget);
    expect(find.text('Available specialists'), findsOneWidget);

    await tester.tap(find.text('Post'));
    await tester.pumpAndSettle();
    expect(find.text('Q&A feed'), findsOneWidget);

    await tester.tap(find.text('Circles'));
    await tester.pumpAndSettle();
    expect(find.text('My communities'), findsOneWidget);

    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Your appointment is booked'), findsOneWidget);
  });

  testWidgets('drawer schedule opens the task reminder route', (tester) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();

    expect(find.text('Task Reminder'), findsOneWidget);
    expect(find.text('Doctors Without Border Event'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Frequency'), findsOneWidget);
    expect(find.text('Once'), findsOneWidget);
    expect(find.text('Add reminder'), findsOneWidget);

    await tester.tap(find.text('Doctors Without Border Event'));
    await tester.pumpAndSettle();

    expect(find.text('Frequency'), findsNothing);

    final calendar = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    calendar.onDateChanged(calendar.initialDate!.add(const Duration(days: 1)));
    await tester.pumpAndSettle();

    expect(find.text('No local schedule for this date'), findsOneWidget);
    expect(find.text('Doctors Without Border Event'), findsNothing);
  });

  testWidgets('drawer providers opens mentor finder and booking handoff', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.dragFrom(const Offset(0, 200), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Providers'));
    await tester.pumpAndSettle();

    expect(find.text('Find a Mentor'), findsOneWidget);
    expect(find.text('Dr. Uzo Blessing'), findsOneWidget);
    expect(find.text('Book Appointment'), findsWidgets);

    await tester.tap(find.text('View details').first);
    await tester.pumpAndSettle();

    expect(find.text('Specialist Details'), findsOneWidget);
    expect(find.text('Available Time'), findsOneWidget);
    expect(find.text('CHOOSE DAY'), findsOneWidget);
    expect(find.text('CHOOSE TIME'), findsOneWidget);

    await tester.tap(find.text('11:30am'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Selected slot'), findsOneWidget);

    await tester.tap(find.text('Book appointment'));
    await tester.pumpAndSettle();

    expect(find.text('Clinician'), findsOneWidget);
  });
}
