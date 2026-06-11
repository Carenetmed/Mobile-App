import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Home/presentation/pages/add_device_shell.dart';
import 'package:app_t/features/Home/presentation/pages/blood_sug_shell.dart';
import 'package:app_t/features/Home/presentation/pages/manage_readings.dart';
import 'package:app_t/features/Home/presentation/pages/readings.dart';
import 'package:app_t/features/Home/presentation/state/readings_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpReadings(WidgetTester tester) async {
  ReadingsLocalStore.reset();
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: VitalsReading(),
            routes: {
              RouteName.manageReadings: (_) => ManageReadings(),
              RouteName.addDevice: (_) => const AddDeviceShellPage(),
              RouteName.bloodSug: (_) => const BloodSugShellPage(),
            },
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('readings add new card routes to manage readings', (
    tester,
  ) async {
    await _pumpReadings(tester);

    await tester.tap(find.text('Add new\nReadings'));
    await tester.pumpAndSettle();

    expect(find.text('Manage Readings'), findsOneWidget);
  });

  testWidgets('manage readings done returns to readings', (tester) async {
    await _pumpReadings(tester);

    await tester.tap(find.text('Add new\nReadings'));
    await tester.pumpAndSettle();
    expect(find.text('Manage Readings'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Readings'), findsOneWidget);
  });

  testWidgets('blood sugar selection continues into add device flow', (
    tester,
  ) async {
    await _pumpReadings(tester);

    await tester.tap(find.text('Add new\nReadings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Blood Sugar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Add Device'), findsOneWidget);

    await tester.tap(find.text('Continue to Blood Sugar'));
    await tester.pumpAndSettle();

    expect(find.text('Log your first blood sugar reading.'), findsOneWidget);
  });

  testWidgets('blood sugar save blocks invalid input and saves valid entry', (
    tester,
  ) async {
    await _pumpReadings(tester);

    await tester.tap(find.text('Add new\nReadings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Blood Sugar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue to Blood Sugar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save reading'));
    await tester.pumpAndSettle();

    expect(find.text('Blood sugar reading is required'), findsOneWidget);
    expect(find.text('Choose when the reading was taken'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, '112');
    await tester.tap(find.text('Before meal'));
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Felt steady this morning',
    );
    await tester.tap(find.text('Save reading'));
    await tester.pumpAndSettle();

    expect(find.text('Latest local entry'), findsOneWidget);
    expect(find.text('112 mg/dL'), findsWidgets);
    expect(find.text('Captured: Before meal'), findsOneWidget);
    expect(find.text('Note: Felt steady this morning'), findsOneWidget);
  });

  testWidgets('readings disabled affordances do not navigate', (tester) async {
    await _pumpReadings(tester);

    expect(find.text('Download\nReadings'), findsOneWidget);
    expect(
      find.byTooltip(
        'Download export is intentionally deferred until the add-reading flow is implemented.',
      ),
      findsOneWidget,
    );
    expect(find.text('Manage Readings'), findsNothing);
    expect(find.text('Readings'), findsOneWidget);
  });

  testWidgets('saved blood sugar entry flows back to readings dashboard', (
    tester,
  ) async {
    await _pumpReadings(tester);

    await tester.tap(find.text('Add new\nReadings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Blood Sugar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue to Blood Sugar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '145');
    await tester.tap(find.text('After meal'));
    await tester.enterText(find.byType(TextFormField).at(1), 'Post lunch');
    await tester.tap(find.text('Save reading'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('145 mg/dL'), findsOneWidget);
    expect(find.text('Latest blood sugar entry'), findsOneWidget);
    expect(find.text('145 mg/dL • After meal'), findsOneWidget);
    expect(find.text('Post lunch'), findsOneWidget);
  });

  testWidgets('blood sugar history and trend update after multiple saves', (
    tester,
  ) async {
    await _pumpReadings(tester);

    await tester.tap(find.text('Add new\nReadings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Blood Sugar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue to Blood Sugar'));
    await tester.pumpAndSettle();

    expect(find.text('No saved blood sugar readings yet.'), findsOneWidget);
    expect(
      find.text('Add one more reading to see a trend summary.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField).first, '120');
    await tester.tap(find.text('Before meal'));
    await tester.tap(find.text('Save reading'));
    await tester.pumpAndSettle();

    expect(find.text('120 mg/dL'), findsWidgets);
    expect(
      find.text('Add one more reading to see a trend summary.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField).first, '135');
    await tester.tap(find.text('After meal'));
    await tester.tap(find.text('Save reading'));
    await tester.pumpAndSettle();

    expect(find.text('15 mg/dL up from the previous reading.'), findsOneWidget);
    expect(find.text('135 mg/dL'), findsWidgets);
    expect(find.text('After meal'), findsWidgets);
    expect(find.text('120 mg/dL'), findsWidgets);
    expect(find.text('Before meal'), findsWidgets);
  });

  testWidgets('blood sugar history entries can be deleted', (tester) async {
    await _pumpReadings(tester);

    await tester.tap(find.text('Add new\nReadings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Blood Sugar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue to Blood Sugar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '120');
    await tester.tap(find.text('Before meal'));
    await tester.tap(find.text('Save reading'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '135');
    await tester.tap(find.text('After meal'));
    await tester.tap(find.text('Save reading'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Delete 135 mg/dL entry'));
    await tester.pumpAndSettle();

    expect(find.text('135 mg/dL'), findsNothing);
    expect(find.text('120 mg/dL'), findsWidgets);
    expect(find.text('Before meal'), findsWidgets);
    expect(find.text('Captured: Before meal'), findsOneWidget);
    expect(
      find.text('Add one more reading to see a trend summary.'),
      findsOneWidget,
    );
  });
}
