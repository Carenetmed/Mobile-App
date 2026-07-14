import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Home/presentation/pages/appointments_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpAppointments(WidgetTester tester) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: const AppointmentsShellPage(),
            routes: {
              RouteName.bookAppointment:
                  (_) => const BookAppointmentShellPage(),
            },
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('appointments screen shows upcoming and recent sections', (
    tester,
  ) async {
    await _pumpAppointments(tester);

    expect(find.text('Keep your care schedule in one place.'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Recent'), findsOneWidget);
    expect(find.text('Private consult with Dr. Lagbaja'), findsOneWidget);
    expect(find.text('Nutrition follow-up'), findsOneWidget);
  });

  testWidgets('book appointment CTA opens booking route', (tester) async {
    await _pumpAppointments(tester);

    await tester.tap(find.text('Book appointment'));
    await tester.pumpAndSettle();

    expect(find.text('Book Appointment'), findsOneWidget);
    expect(find.text('Booking starts here.'), findsOneWidget);
  });

  testWidgets('booking form validates and prepares backend-required details', (
    tester,
  ) async {
    await _pumpAppointments(tester);

    await tester.tap(find.text('Book appointment'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Review request details'));
    await tester.pumpAndSettle();

    expect(find.text('Clinician is required'), findsOneWidget);
    expect(find.text('Visit type is required'), findsOneWidget);
    expect(find.text('Preferred date is required'), findsOneWidget);
    expect(find.text('Reason for visit is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Dr. Bello');
    await tester.tap(find.text('Video visit'));
    await tester.enterText(find.byType(TextFormField).at(1), 'Fri, 31 May');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Review recurring headaches',
    );
    await tester.tap(find.text('Review request details'));
    await tester.pumpAndSettle();

    expect(find.text('Request details'), findsOneWidget);
    expect(find.text('Dr. Bello'), findsWidgets);
    expect(find.text('Review recurring headaches'), findsWidgets);
    expect(find.text('Backend request not sent'), findsOneWidget);
    expect(
      find.text(
        'No appointment request has been sent yet. Choose a backend availability slot in the upcoming request flow before this can be submitted.',
      ),
      findsOneWidget,
    );
    expect(find.text('Confirmed locally'), findsNothing);
  });

  testWidgets('prepared booking details can be cleared but not confirmed', (
    tester,
  ) async {
    await _pumpAppointments(tester);

    await tester.tap(find.text('Book appointment'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Dr. Bello');
    await tester.tap(find.text('Video visit'));
    await tester.enterText(find.byType(TextFormField).at(1), 'Fri, 31 May');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Review recurring headaches',
    );
    await tester.tap(find.text('Review request details'));
    await tester.pumpAndSettle();

    expect(find.text('Backend request not sent'), findsOneWidget);
    expect(find.text('Confirm request'), findsNothing);

    await tester.tap(find.text('Clear details'));
    await tester.pumpAndSettle();

    expect(find.text('Request details'), findsNothing);
  });
}
