import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/constants/navigators/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpRoutingHost(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(onGenerateRoute: generateRoute, initialRoute: RouteName.chat),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('chat route opens the canonical conversation screen', (
    tester,
  ) async {
    await _pumpRoutingHost(tester);

    expect(find.text('Read 08:08PM'), findsOneWidget);
    expect(find.text('09:08PM Read'), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
  });

  testWidgets('legacy message route stays as compatibility alias notice', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: generateRoute,
        initialRoute: RouteName.message,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Read 08:08PM'), findsNothing);
    expect(find.byType(RichText), findsWidgets);
    expect(find.text('Message'), findsOneWidget);
  });
}
