import 'package:app_t/features/Messaging/presentation/pages/Messages.dart';
import 'package:app_t/features/Messaging/presentation/pages/Notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('messages show an honest appointment-linked empty state', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MessagesPage()));

    expect(find.text('No appointment conversations yet'), findsOneWidget);
    expect(find.textContaining('eligible consultations'), findsOneWidget);
    expect(find.textContaining('Dr. Lagbaja'), findsNothing);
    expect(find.text('Events'), findsNothing);
    expect(find.text('Payment'), findsNothing);
  });

  testWidgets('notifications do not expose deferred seeded activity', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: NotificationsPage()));

    expect(find.text('No notifications yet'), findsOneWidget);
    expect(
      find.text(
        'Appointment and account updates will appear here when notification delivery is available.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Circle'), findsNothing);
    expect(find.textContaining('article'), findsNothing);
    expect(find.textContaining('podcast'), findsNothing);
    expect(find.textContaining('emergency'), findsNothing);
  });
}
