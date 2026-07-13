import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Home/presentation/pages/emergency_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpEmergency(WidgetTester tester) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: const EmergencyShellPage(),
            routes: {RouteName.distressCall: (_) => const DistressCallPage()},
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('emergency screen shows status and updates', (tester) async {
    await _pumpEmergency(tester);

    expect(find.text('Emergency support is now in one place.'), findsOneWidget);
    expect(find.text('Current status'), findsOneWidget);
    expect(find.text('Ambulance approved'), findsOneWidget);
    expect(find.text('Circle notified'), findsOneWidget);
  });

  testWidgets('open distress call routes into distress form', (tester) async {
    await _pumpEmergency(tester);

    await tester.tap(find.text('Open distress call'));
    await tester.pumpAndSettle();

    expect(find.text('Distress Call'), findsOneWidget);
    expect(find.text('Share updated emergency details.'), findsOneWidget);
  });

  testWidgets('distress call form validates and saves update', (tester) async {
    await _pumpEmergency(tester);

    await tester.tap(find.text('Open distress call'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save distress update'));
    await tester.pumpAndSettle();

    expect(find.text('Location is required'), findsOneWidget);
    expect(find.text('Emergency details is required'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      '14 Palm Street, Lagos',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Responder should call on arrival; patient is conscious.',
    );
    await tester.tap(find.text('Save distress update'));
    await tester.pumpAndSettle();

    expect(find.text('Latest distress update'), findsOneWidget);
    expect(find.text('14 Palm Street, Lagos'), findsWidgets);
    expect(find.text('Saved locally'), findsOneWidget);
    expect(
      find.text('Responder should call on arrival; patient is conscious.'),
      findsWidgets,
    );
  });

  testWidgets('distress update can be queued or cleared locally', (
    tester,
  ) async {
    await _pumpEmergency(tester);

    await tester.tap(find.text('Open distress call'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      '14 Palm Street, Lagos',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Responder should call on arrival; patient is conscious.',
    );
    await tester.tap(find.text('Save distress update'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send to dispatch'));
    await tester.pumpAndSettle();

    expect(find.text('Queued for dispatch'), findsOneWidget);

    await tester.tap(find.text('Clear update'));
    await tester.pumpAndSettle();

    expect(find.text('Latest distress update'), findsNothing);
  });
}
