import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Messaging/presentation/pages/Messages.dart';
import 'package:app_t/features/Messaging/presentation/pages/Notification.dart';
import 'package:app_t/features/Messaging/domain/entities/messaging_models.dart';
import 'package:app_t/features/Messaging/data/services/messaging_realtime_client.dart';
import 'package:app_t/features/Messaging/presentation/state/messaging_controllers.dart';
import 'package:app_t/features/Notifications/presentation/state/notification_coordinator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'messaging_test_fakes.dart';
import '../notifications/notification_test_fakes.dart';

void main() {
  testWidgets('empty backend list shows honest appointment-linked state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: MessagesPage(repository: FakeMessagingRepository())),
    );
    await tester.pumpAndSettle();

    expect(find.text('No appointment conversations yet'), findsOneWidget);
    expect(
      find.textContaining('after an eligible appointment'),
      findsOneWidget,
    );
    expect(find.textContaining('Dr. Uzo'), findsNothing);
    expect(find.text('New chat'), findsNothing);
  });

  testWidgets(
    'conversation list renders authority fields and exact route args',
    (tester) async {
      final repository = FakeMessagingRepository(
        conversations:
            <dynamic>[
              conversationSummary(
                unreadCount: 3,
                lastMessage: ConversationLastMessage(
                  messageId: 'message-1',
                  sequence: BigInt.one,
                  authorUserId: 'professional-user',
                  createdAt: DateTime.utc(2026, 7, 26, 12),
                  preview: 'Please arrive early.',
                ),
              ),
            ].cast(),
      );
      AppointmentConversationRouteArgs? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: MessagesPage(repository: repository),
          onGenerateRoute: (settings) {
            if (settings.name == RouteName.chat) {
              captured = settings.arguments as AppointmentConversationRouteArgs;
              return MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: Text('thread')),
              );
            }
            return null;
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dr. Ada Okafor'), findsOneWidget);
      expect(find.text('Please arrive early.'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      await tester.tap(find.byKey(const Key('conversation-conversation-1')));
      await tester.pumpAndSettle();
      expect(captured?.conversationId, 'conversation-1');
      expect(captured?.appointmentId, 'appointment-1');
    },
  );

  testWidgets('refresh failure preserves previously loaded conversations', (
    tester,
  ) async {
    final repository = FakeMessagingRepository(
      conversations: <dynamic>[conversationSummary()].cast(),
    );
    await tester.pumpWidget(
      MaterialApp(home: MessagesPage(repository: repository)),
    );
    await tester.pumpAndSettle();
    repository.conversationsError = StateError('offline');

    await tester.tap(find.byKey(const Key('messages-refresh')));
    await tester.pumpAndSettle();

    expect(find.text('Dr. Ada Okafor'), findsOneWidget);
    expect(
      find.textContaining('previous conversations remain visible'),
      findsOneWidget,
    );
  });

  testWidgets('realtime hint refreshes authoritative conversation metadata', (
    tester,
  ) async {
    final repository = FakeMessagingRepository(
      conversations: <dynamic>[conversationSummary()].cast(),
    );
    final realtime = FakeRealtimeConnection();
    await tester.pumpWidget(
      MaterialApp(
        home: MessagesPage(repository: repository, realtime: realtime),
      ),
    );
    await tester.pumpAndSettle();
    final before = repository.conversationsCalls;

    realtime.hintController.add(
      const MessagingRealtimeHint(
        type: 'message.created',
        conversationId: 'conversation-1',
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(repository.conversationsCalls, greaterThan(before));
  });

  testWidgets('notifications do not expose deferred seeded activity', (
    tester,
  ) async {
    final repository = FakeNotificationRepository();
    final coordinator = NotificationCoordinator(
      repository: repository,
      installationStore: FakeNotificationInstallationStore(),
      transport: FakeNotificationTransport(),
      navigatorKey: GlobalKey<NavigatorState>(),
      metadataLoader:
          () async => const NotificationDeviceMetadata(
            platform: 'ANDROID',
            appId: 'com.carenet.app',
            appVersion: '1.0.0+1',
            locale: 'en_NG',
          ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: NotificationsPage(
          repository: repository,
          coordinator: coordinator,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No notifications yet'), findsOneWidget);
    expect(find.textContaining('Circle'), findsNothing);
    expect(find.textContaining('podcast'), findsNothing);
  });
}
