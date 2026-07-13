import 'package:app_t/features/Home/presentation/pages/health_record_shell.dart';
import 'package:app_t/features/Home/presentation/state/readings_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpHealthRecord(WidgetTester tester) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder: (_, __) => const MaterialApp(home: HealthRecordShellPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(ReadingsLocalStore.reset);

  testWidgets('health record shows blueprint-backed reading sections', (
    tester,
  ) async {
    await _pumpHealthRecord(tester);

    expect(find.text('Health File'), findsOneWidget);
    expect(find.text('Health Record'), findsOneWidget);
    expect(find.text('Blood Pressure'), findsOneWidget);
    expect(find.text('Blood Sugar'), findsOneWidget);
    expect(find.text('Heart Rate'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
  });

  testWidgets('health record reflects latest local blood sugar reading', (
    tester,
  ) async {
    ReadingsLocalStore.saveBloodSugar(
      reading: '144',
      context: 'After meal',
      note: 'Felt tired after lunch',
    );

    await _pumpHealthRecord(tester);

    expect(find.text('144 mg/dL'), findsOneWidget);
    expect(find.text('After meal'), findsOneWidget);
    expect(find.text('Felt tired after lunch'), findsOneWidget);
  });
}
