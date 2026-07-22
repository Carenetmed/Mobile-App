import 'package:app_t/features/Home/presentation/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 932);

Future<void> _pumpHome(
  WidgetTester tester, {
  required bool professional,
  required VoidCallback onPrimaryAction,
  required VoidCallback onAppointments,
}) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: Scaffold(
              body: Home(
                isProfessional: professional,
                onPrimaryAction: onPrimaryAction,
                onAppointments: onAppointments,
              ),
            ),
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('patient home exposes focused care actions only', (tester) async {
    var findCareCalls = 0;
    var appointmentCalls = 0;
    await _pumpHome(
      tester,
      professional: false,
      onPrimaryAction: () => findCareCalls += 1,
      onAppointments: () => appointmentCalls += 1,
    );

    expect(find.text('Your care'), findsOneWidget);
    expect(find.text('Find care'), findsOneWidget);
    expect(find.text('Appointments'), findsOneWidget);
    expect(find.text('Feed'), findsNothing);
    expect(find.text('Articles'), findsNothing);
    expect(find.text('Upgrade'), findsNothing);

    await tester.tap(find.text('Find care'));
    await tester.tap(find.text('Appointments'));
    expect(findCareCalls, 1);
    expect(appointmentCalls, 1);
  });

  testWidgets('professional home exposes schedule and appointment actions', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      professional: true,
      onPrimaryAction: () {},
      onAppointments: () {},
    );

    expect(find.text('Professional workspace'), findsOneWidget);
    expect(find.text('Manage schedule'), findsOneWidget);
    expect(find.text('Appointments'), findsOneWidget);
    expect(find.text('Feed'), findsNothing);
    expect(find.text('Articles'), findsNothing);
  });
}
