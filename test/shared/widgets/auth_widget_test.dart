import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/shared/widgets/auth_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 932);

Future<void> _pumpAuthWidget(
  WidgetTester tester, {
  required Widget child,
  Size screenSize = _phoneSize,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  tester.view.physicalSize = screenSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (context, _) => MaterialApp(
            home: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: Scaffold(body: child),
            ),
          ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('AuthWidget fires tap when enabled', (tester) async {
    var tapped = false;

    await _pumpAuthWidget(
      tester,
      child: AuthWidget(
        assetPath: AssetsIcon.google,
        title: 'Continue with Google',
        btnAction: () {
          tapped = true;
        },
      ),
    );

    await tester.tap(find.text('Continue with Google'));
    await tester.pump();

    final semanticsFinder = find.descendant(
      of: find.byType(AuthWidget),
      matching: find.byType(Semantics),
    );

    expect(tapped, isTrue);
    expect(
      tester.firstWidget<Semantics>(semanticsFinder).properties.enabled,
      isTrue,
    );
    expect(
      tester.firstWidget<Semantics>(semanticsFinder).properties.label,
      'Continue with Google',
    );
  });

  testWidgets('AuthWidget wraps and grows at 2x text on a compact screen', (
    tester,
  ) async {
    await _pumpAuthWidget(
      tester,
      child: AuthWidget(
        assetPath: AssetsIcon.google,
        title: 'Continue with Google securely',
        btnAction: () {},
      ),
      screenSize: const Size(320, 568),
      textScaler: const TextScaler.linear(2),
    );

    expect(
      tester.getSize(find.byType(InkWell)).height,
      greaterThanOrEqualTo(48),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('AuthWidget is visibly disabled when no action exists', (
    tester,
  ) async {
    await _pumpAuthWidget(
      tester,
      child: const AuthWidget(
        assetPath: AssetsIcon.apple,
        title: 'Continue with Apple',
      ),
    );

    final widgetFinder = find.byType(AuthWidget);
    final semantics = tester.firstWidget<Semantics>(
      find.descendant(of: widgetFinder, matching: find.byType(Semantics)),
    );
    final opacity = tester.firstWidget<Opacity>(
      find.descendant(of: widgetFinder, matching: find.byType(Opacity)),
    );
    final inkWell = tester.firstWidget<InkWell>(
      find.descendant(of: widgetFinder, matching: find.byType(InkWell)),
    );

    expect(semantics.properties.enabled, isFalse);
    expect(opacity.opacity, 0.55);
    expect(inkWell.onTap, isNull);
  });
}
