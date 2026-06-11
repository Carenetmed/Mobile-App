import 'package:app_t/features/Home/presentation/pages/search_shell.dart';
import 'package:app_t/features/Home/presentation/state/search_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpSearch(WidgetTester tester) async {
  SearchLocalStore.reset();
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder: (_, __) => const MaterialApp(home: SearchShellPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('search tab shows real local specialist content', (tester) async {
    await _pumpSearch(tester);

    expect(find.text('Search specialists'), findsOneWidget);
    expect(find.text('Available specialists'), findsOneWidget);
    expect(find.text('Dr. Uzo Blessing'), findsOneWidget);
    expect(find.text('Dr. Chris Amaka'), findsOneWidget);
  });

  testWidgets('search field filters specialist results', (tester) async {
    await _pumpSearch(tester);

    await tester.enterText(find.byType(TextFormField), 'psychologist');
    await tester.pumpAndSettle();

    expect(find.text('Dr. Lakasegbe'), findsOneWidget);
    expect(find.text('Dr. Uzo Blessing'), findsNothing);
  });

  testWidgets('category chip filters specialist results', (tester) async {
    await _pumpSearch(tester);

    await tester.tap(find.text('Generalist'));
    await tester.pumpAndSettle();

    expect(find.text('Dr. Uzo Blessing'), findsOneWidget);
    expect(find.text('Dr. Chris Amaka'), findsOneWidget);
    expect(find.text('Dr. Lakasegbe'), findsNothing);
  });

  testWidgets('schedule action marks a specialist locally', (tester) async {
    await _pumpSearch(tester);

    await tester.tap(find.text('Schedule').first);
    await tester.pumpAndSettle();

    expect(find.text('Requested locally'), findsOneWidget);
  });

  testWidgets('profile action opens local specialist profile sheet', (
    tester,
  ) async {
    await _pumpSearch(tester);

    await tester.tap(find.text('View profile').first);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Available for general care, ENT concerns, neurological reviews, and first-line triage.',
      ),
      findsOneWidget,
    );
  });
}
