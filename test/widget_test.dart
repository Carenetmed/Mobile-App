import 'package:app_t/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Matches [ScreenUtilInit] design size in [CarenetApp].
const Size _phoneSize = Size(430, 932);

Future<void> _pumpCarenetApp(WidgetTester tester) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const CarenetApp());
  await tester.pump();
}

void main() {
  testWidgets('App launches on splash screen', (WidgetTester tester) async {
    await _pumpCarenetApp(tester);

    expect(find.text('CARENET'), findsOneWidget);
    expect(find.text('HEALTH SERVICES'), findsOneWidget);

    // Finish splash timer so no pending timers remain.
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
  });

  testWidgets('Splash navigates to onboarding after delay', (WidgetTester tester) async {
    await _pumpCarenetApp(tester);

    expect(find.text('CARENET'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.text('Where Knowledge Meets Collaboration'), findsOneWidget);
  });
}
