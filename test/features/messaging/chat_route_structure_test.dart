import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/constants/navigators/router.dart';
import 'package:app_t/features/Messaging/presentation/pages/Chat.dart';
import 'package:app_t/features/Messaging/presentation/state/messaging_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'messaging_test_fakes.dart';

void main() {
  testWidgets('chat without authoritative arguments fails closed', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(onGenerateRoute: generateRoute, initialRoute: RouteName.chat),
    );
    await tester.pumpAndSettle();

    expect(find.text('Conversation unavailable'), findsOneWidget);
    expect(find.textContaining('Dr. Uzo'), findsNothing);
    expect(find.textContaining('express contact'), findsNothing);
  });

  testWidgets('legacy message alias cannot expose seeded conversation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: generateRoute,
        initialRoute: RouteName.message,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Conversation unavailable'), findsOneWidget);
    expect(find.textContaining('08:08PM'), findsNothing);
  });

  testWidgets('authoritative accepted thread loads Flyer projection', (
    tester,
  ) async {
    final repository = FakeMessagingRepository(
      conversations: <dynamic>[conversationSummary()].cast(),
      messages: <dynamic>[careMessage()].cast(),
    );
    final realtime = FakeRealtimeConnection();
    await tester.pumpWidget(
      MaterialApp(
        home: ChatPage(
          arguments: const AppointmentConversationRouteArgs(
            conversationId: 'conversation-1',
          ),
          repository: repository,
          realtime: realtime,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dr. Ada Okafor'), findsOneWidget);
    expect(find.text('Please arrive a few minutes early.'), findsOneWidget);
    expect(find.text('Message about this appointment'), findsOneWidget);
    expect(repository.markReadCalls, 1);
  });

  testWidgets('read-only lifecycle disables composer with honest reason', (
    tester,
  ) async {
    final repository = FakeMessagingRepository(
      conversations:
          <dynamic>[
            conversationSummary(status: 'REQUESTED', writable: false),
          ].cast(),
      detail: conversationDetail(status: 'REQUESTED', writable: false),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ChatPage(
          arguments: const AppointmentConversationRouteArgs(
            appointmentId: 'appointment-1',
          ),
          repository: repository,
          realtime: FakeRealtimeConnection(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('chat-read-only')), findsOneWidget);
    expect(
      find.textContaining('until the appointment is accepted again'),
      findsWidgets,
    );
    expect(find.text('Message about this appointment'), findsNothing);
  });
}
