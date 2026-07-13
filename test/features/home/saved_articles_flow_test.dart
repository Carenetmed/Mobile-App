import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Home/presentation/pages/articles_shell.dart';
import 'package:app_t/features/Home/presentation/pages/saved_articles_shell.dart';
import 'package:app_t/features/Home/presentation/state/articles_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpSavedArticles(
  WidgetTester tester, {
  bool withSavedArticle = false,
}) async {
  ArticlesLocalStore.reset();
  if (withSavedArticle) {
    ArticlesLocalStore.toggleSaved('What to monitor after an intense workout');
  }

  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: const SavedArticlesShellPage(),
            routes: <String, WidgetBuilder>{
              RouteName.articles: (_) => const ArticlesShellPage(),
            },
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('saved articles screen shows empty state', (tester) async {
    await _pumpSavedArticles(tester);

    expect(find.text('Saved Articles'), findsOneWidget);
    expect(find.text('For you'), findsOneWidget);
    expect(find.text('Request'), findsOneWidget);
    expect(find.text('Drafts'), findsOneWidget);
    expect(find.text('You have no saved articles'), findsOneWidget);
  });

  testWidgets('browse articles button opens the article reader', (
    tester,
  ) async {
    await _pumpSavedArticles(tester);

    await tester.tap(find.text('Browse articles'));
    await tester.pumpAndSettle();

    expect(
      find.text('What to monitor after an intense workout'),
      findsOneWidget,
    );
    expect(find.text('Open article'), findsWidgets);
  });

  testWidgets('saved article can be read and removed', (tester) async {
    await _pumpSavedArticles(tester, withSavedArticle: true);

    expect(
      find.text('What to monitor after an intense workout'),
      findsOneWidget,
    );

    await tester.tap(find.text('Read'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Watch for chest tightness, unusual dizziness, and recovery that stays delayed beyond the rest of your day. Rehydrating early and easing back into movement usually helps, but persistent warning signs are a cue to pause and get professional advice.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Remove saved'));
    await tester.pumpAndSettle();

    expect(find.text('You have no saved articles'), findsOneWidget);
  });
}
