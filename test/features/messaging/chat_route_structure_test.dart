import 'dart:ui' show SemanticsAction;

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

  testWidgets('long chat title stays readable at compact width and 2x text', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const participant =
        'Dr. A very long professional name that needs to remain readable';
    final repository = FakeMessagingRepository(
      conversations: <dynamic>[conversationSummary()].cast(),
      detail: conversationDetail(professionalName: participant),
      messages: <dynamic>[careMessage()].cast(),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(splashFactory: NoSplash.splashFactory),
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
        home: ChatPage(
          arguments: const AppointmentConversationRouteArgs(
            conversationId: 'conversation-1',
          ),
          repository: repository,
          realtime: FakeRealtimeConnection(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(participant), findsOneWidget);
    expect(find.byKey(const Key('chat-open-appointment')), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('failed message retry exposes a 48dp action target', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final repository = FakeMessagingRepository(
      conversations: <dynamic>[conversationSummary()].cast(),
      messages: <dynamic>[careMessage()].cast(),
    )..sendError = StateError('offline');
    await tester.pumpWidget(
      MaterialApp(
        home: ChatPage(
          arguments: const AppointmentConversationRouteArgs(
            conversationId: 'conversation-1',
          ),
          repository: repository,
          realtime: FakeRealtimeConnection(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final composer = find.byType(TextField).last;
    await tester.enterText(composer, 'A consultation question');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    final retry = find.ancestor(
      of: find.text('Not sent'),
      matching: find.byType(TextButton),
    );
    expect(retry, findsOneWidget);
    expect(tester.getSize(retry).height, greaterThanOrEqualTo(48));
    final node = tester.getSemantics(retry);
    expect(node.label, contains('Not sent'));
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    semantics.dispose();
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
