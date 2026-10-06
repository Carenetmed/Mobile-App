import 'package:app_t/main.dart' as app_entrypoint;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('invalid startup configuration fails closed before app setup', (
    tester,
  ) async {
    await app_entrypoint.main();
    await tester.pump();

    expect(
      find.text(
        'CareNet could not start because this app has an invalid environment '
        'configuration. Reinstall the correct app version or contact support.',
      ),
      findsOneWidget,
    );
    expect(find.text('Home'), findsNothing);
  });
}
