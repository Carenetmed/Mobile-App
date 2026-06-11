import 'package:app_t/features/Home/presentation/pages/case_studies_shell.dart';
import 'package:app_t/features/Home/presentation/state/case_studies_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpCaseStudies(WidgetTester tester) async {
  CaseStudiesLocalStore.reset();
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder: (_, __) => const MaterialApp(home: CaseStudiesShellPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('case studies screen shows local case study content', (
    tester,
  ) async {
    await _pumpCaseStudies(tester);

    expect(find.text('Case Studies'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Case studies'), findsOneWidget);
    expect(find.text('Best'), findsWidgets);
    expect(
      find.text(
        'The First Successful 3D-Printed Organ Transplant: Lessons Learned',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Managing Rare Medical Conditions: Insights from Experts'),
      findsOneWidget,
    );
  });

  testWidgets('best filter narrows the visible case studies', (tester) async {
    await _pumpCaseStudies(tester);

    await tester.tap(find.text('Best').first);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'The First Successful 3D-Printed Organ Transplant: Lessons Learned',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Managing Rare Medical Conditions: Insights from Experts'),
      findsNothing,
    );
  });

  testWidgets('opening a case study shows detail and marks it read', (
    tester,
  ) async {
    await _pumpCaseStudies(tester);

    await tester.tap(
      find.text(
        'The First Successful 3D-Printed Organ Transplant: Lessons Learned',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dr. Bisi Lawal'), findsOneWidget);
    expect(
      find.text(
        'This local case study summarizes how preparation, surgical planning, follow-up readings, and patient communication can shape recovery after a high-complexity intervention. In a backend version, the content API should provide the verified article body, author record, and publication metadata.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Read'), findsOneWidget);
  });
}
