import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Home/presentation/pages/post_shell.dart';
import 'package:app_t/features/Home/presentation/pages/qa_shell.dart';
import 'package:app_t/features/Home/presentation/state/qa_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpQa(WidgetTester tester) async {
  QaLocalStore.reset();
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: const PostShellPage(),
            routes: {
              RouteName.qAAsk: (_) => const QaAskPage(),
              RouteName.qAAnswerRequests: (_) => const QaAnswerRequestsPage(),
              RouteName.qAAnswerForYou: (_) => const QaAnswerForYouPage(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == RouteName.commentAnswer) {
                final args = settings.arguments! as QaCommentRouteArgs;
                return MaterialPageRoute<void>(
                  builder:
                      (_) => QaCommentAnswerPage(questionId: args.questionId),
                );
              }
              return null;
            },
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('post tab now shows q and a feed content', (tester) async {
    await _pumpQa(tester);

    expect(find.text('Q&A feed'), findsOneWidget);
    expect(find.text('Should men treat prostate cancer?'), findsOneWidget);
    expect(find.text('Ask'), findsOneWidget);
  });

  testWidgets('answer button opens answer requests page', (tester) async {
    await _pumpQa(tester);

    await tester.tap(find.text('Answer'));
    await tester.pumpAndSettle();

    expect(find.text('Answer requests'), findsOneWidget);
    expect(find.text('See tagged questions for you'), findsOneWidget);
  });

  testWidgets('ask button opens ask page', (tester) async {
    await _pumpQa(tester);

    await tester.tap(find.text('Ask'));
    await tester.pumpAndSettle();

    expect(find.text('Ask Q&A'), findsOneWidget);
    expect(find.text('Question'), findsOneWidget);
  });

  testWidgets('ask page validates question format', (tester) async {
    await _pumpQa(tester);

    await tester.tap(find.text('Ask'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(find.text('Question is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Tell me about sleep');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(find.text('Start with What, How, Why, or Where'), findsOneWidget);
  });

  testWidgets('sending a valid question returns to feed and adds it locally', (
    tester,
  ) async {
    await _pumpQa(tester);

    await tester.tap(find.text('Ask'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField),
      'What helps keep a sleep routine consistent?',
    );
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(find.text('Q&A feed'), findsOneWidget);
    expect(
      find.text('What helps keep a sleep routine consistent?'),
      findsOneWidget,
    );
    expect(find.text('Saved locally'), findsOneWidget);
    expect(find.text('No answers yet'), findsOneWidget);
  });

  testWidgets('answer flow saves a local answer draft', (tester) async {
    await _pumpQa(tester);

    await tester.tap(find.text('Answer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('See tagged questions for you'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Answer').first);
    await tester.pumpAndSettle();

    expect(find.text('Comment'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField),
      'Screening early and keeping regular doctor visits helps a lot.',
    );
    await tester.tap(find.byIcon(Icons.send_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Tagged questions'), findsOneWidget);

    Navigator.of(tester.element(find.text('Tagged questions'))).maybePop();
    await tester.pumpAndSettle();

    expect(find.text('Answer requests'), findsOneWidget);
    expect(
      find.text(
        'Screening early and keeping regular doctor visits helps a lot.',
      ),
      findsOneWidget,
    );
    expect(find.text('Saved locally'), findsOneWidget);
  });
}
