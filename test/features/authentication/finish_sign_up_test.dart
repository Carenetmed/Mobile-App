import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_con.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 932);

Future<void> _pumpFinishSignUp(WidgetTester tester) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            initialRoute: RouteName.finishSignUp,
            routes: {
              RouteName.finishSignUp: (_) => const FinSignUp(),
              RouteName.communityAgreement:
                  (_) => const Scaffold(body: Text('community-agreement')),
            },
          ),
    ),
  );
  await tester.pump();
}

void main() {
  group('Finish sign up', () {
    testWidgets('blocks navigation when required fields are empty', (
      tester,
    ) async {
      await _pumpFinishSignUp(tester);

      await tester.tap(find.text(' Agree & continue'));
      await tester.pump();

      expect(find.text('First name is required'), findsOneWidget);
      expect(find.text('Last name is required'), findsOneWidget);
      expect(find.text('Birthday is required'), findsOneWidget);
      expect(find.text('Email Address is required'), findsOneWidget);
      expect(find.text('Please enter your password'), findsNWidgets(2));
      expect(find.text('community-agreement'), findsNothing);
    });

    testWidgets('navigates when form fields are valid', (tester) async {
      await _pumpFinishSignUp(tester);

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'John');
      await tester.enterText(fields.at(1), 'Doe');
      await tester.tap(find.byType(TextFormField).at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.enterText(fields.at(3), 'john@example.com');
      await tester.enterText(fields.at(4), 'Strong1!');
      await tester.enterText(fields.at(5), 'Strong1!');

      await tester.tap(find.text(' Agree & continue'));
      await tester.pumpAndSettle();

      expect(find.text('community-agreement'), findsOneWidget);
    });

    testWidgets('blocks navigation when confirm password does not match', (
      tester,
    ) async {
      await _pumpFinishSignUp(tester);

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'John');
      await tester.enterText(fields.at(1), 'Doe');
      await tester.tap(find.byType(TextFormField).at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.enterText(fields.at(3), 'john@example.com');
      await tester.enterText(fields.at(4), 'Strong1!');
      await tester.enterText(fields.at(5), 'Mismatch1!');

      await tester.tap(find.text(' Agree & continue'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(find.text('community-agreement'), findsNothing);
    });
  });
}
