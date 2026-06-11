import 'package:app_t/features/Home/presentation/pages/articles_shell.dart';
import 'package:app_t/features/Home/presentation/state/articles_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpArticles(WidgetTester tester) async {
  ArticlesLocalStore.reset();
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder: (_, __) => const MaterialApp(home: ArticlesShellPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('articles screen shows list content', (tester) async {
    await _pumpArticles(tester);

    expect(
      find.text('What to monitor after an intense workout'),
      findsOneWidget,
    );
    expect(
      find.text('Five easy breakfast upgrades for steadier energy'),
      findsOneWidget,
    );
  });

  testWidgets('opening an article shows detail view', (tester) async {
    await _pumpArticles(tester);

    await tester.tap(find.text('Open article').first);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Watch for chest tightness, unusual dizziness, and recovery that stays delayed beyond the rest of your day. Rehydrating early and easing back into movement usually helps, but persistent warning signs are a cue to pause and get professional advice.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'This article is local content for now. Later content APIs should replace the article source without changing the list/detail reader flow.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('opening and saving an article updates local read/saved state', (
    tester,
  ) async {
    await _pumpArticles(tester);

    await tester.tap(find.text('Open article').first);
    await tester.pumpAndSettle();

    expect(find.text('Save article'), findsOneWidget);

    await tester.tap(find.text('Save article'));
    await tester.pumpAndSettle();

    expect(find.text('Saved locally'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Read article'), findsOneWidget);
  });
}
