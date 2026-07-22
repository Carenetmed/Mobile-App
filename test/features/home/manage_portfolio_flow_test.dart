import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Home/presentation/pages/account_shell.dart';
import 'package:app_t/features/Home/presentation/pages/manage_portfolio_shell.dart';
import 'package:app_t/features/Home/presentation/pages/manage_profile_shell.dart';
import 'package:app_t/features/Home/presentation/pages/published_articles_shell.dart';
import 'package:app_t/features/Messaging/presentation/pages/Messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpManagePortfolio(WidgetTester tester) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: const ManagePortfolioShellPage(),
            routes: <String, WidgetBuilder>{
              RouteName.settings: (_) => const SettingsProfilePage(),
              RouteName.messages: (_) => const MessagesPage(),
              RouteName.publishedArticles:
                  (_) => const PublishedArticlesShellPage(),
            },
          ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpManageProfile(WidgetTester tester) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: const ManageProfileShellPage(),
            routes: <String, WidgetBuilder>{
              RouteName.managePortfolio:
                  (_) => const ManagePortfolioShellPage(),
              RouteName.settings: (_) => const SettingsProfilePage(),
              RouteName.messages: (_) => const MessagesPage(),
              RouteName.publishedArticles:
                  (_) => const PublishedArticlesShellPage(),
            },
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('manage portfolio shows local portfolio content', (tester) async {
    await _pumpManagePortfolio(tester);

    expect(find.text('Manage Portfolio'), findsOneWidget);
    expect(find.text('Old People Circle'), findsOneWidget);
    expect(find.text('Circle - 5.0 - 120 members'), findsOneWidget);
    expect(find.text('Page'), findsWidgets);
    expect(find.text('60+ Exercise Group'), findsWidgets);
    expect(find.text('Tailok Olwan'), findsWidgets);
  });

  testWidgets('page and circles tabs switch local portfolio sections', (
    tester,
  ) async {
    await _pumpManagePortfolio(tester);

    expect(find.text('Local draft preview'), findsOneWidget);

    await tester.tap(find.text('Circles').first);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'A local managed community portfolio preview until creator portfolio APIs exist.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('creator and monetization actions are disabled', (tester) async {
    await _pumpManagePortfolio(tester);

    for (final label in <String>['Events', 'Boost', 'Podcast', 'Share']) {
      final chip = tester.widget<ActionChip>(
        find.widgetWithText(ActionChip, label),
      );
      expect(chip.onPressed, isNull);
    }

    expect(find.text('Add new article'), findsOneWidget);
    expect(find.text('Upload new podcast'), findsOneWidget);
    expect(find.text('Upgrade'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsWidgets);
  });

  testWidgets('edit and message actions use existing honest routes', (
    tester,
  ) async {
    await _pumpManagePortfolio(tester);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Settings & Profile'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Message'));
    await tester.pumpAndSettle();

    expect(find.text('Messages'), findsWidgets);
  });

  testWidgets('manage profile does not expose creator portfolio entry', (
    tester,
  ) async {
    await _pumpManageProfile(tester);

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Articles'), findsNothing);
    expect(find.text('Manage Portfolio'), findsNothing);
    expect(find.text('Upload new podcast'), findsNothing);
  });

  testWidgets('published articles opens local list and detail surface', (
    tester,
  ) async {
    await _pumpManagePortfolio(tester);

    await tester.tap(find.text('Articles'));
    await tester.pumpAndSettle();

    expect(find.text('Published Articles'), findsOneWidget);
    expect(find.text('For you'), findsOneWidget);
    expect(find.text('Request'), findsOneWidget);
    expect(find.text('Drafts'), findsOneWidget);
    expect(find.text('Creator article library'), findsOneWidget);
    expect(find.text('60+ Exercise Group'), findsWidgets);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Article details'), findsOneWidget);
    expect(find.text('Publishing controls locked'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsWidgets);
  });

  testWidgets(
    'published article request and draft tabs are honest deferred states',
    (tester) async {
      await _pumpManagePortfolio(tester);

      await tester.tap(find.text('Articles'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Request'));
      await tester.pumpAndSettle();

      expect(find.text('No article requests'), findsOneWidget);

      await tester.tap(find.text('Drafts'));
      await tester.pumpAndSettle();

      expect(find.text('Drafts are not available yet'), findsOneWidget);
    },
  );
}
