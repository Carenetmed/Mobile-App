import 'dart:async';
import 'dart:ui' show SemanticsAction;

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Messaging/presentation/pages/Messages.dart';
import 'package:app_t/features/Messaging/presentation/pages/Notification.dart';
import 'package:app_t/features/Messaging/domain/entities/messaging_models.dart';
import 'package:app_t/features/Messaging/data/services/messaging_realtime_client.dart';
import 'package:app_t/features/Messaging/data/repositories/messaging_repository.dart';
import 'package:app_t/features/Messaging/presentation/state/messaging_controllers.dart';
import 'package:app_t/features/Notifications/presentation/state/notification_coordinator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'messaging_test_fakes.dart';
import '../notifications/notification_test_fakes.dart';

void main() {
  testWidgets('pre-ACK recovery reloads inbox without a connected event', (
    tester,
  ) async {
    final repository = FakeMessagingRepository();
    final realtime = FakeRealtimeConnection();
    await _showRecoveryInbox(tester, repository, realtime);
    expect(repository.conversationsCalls, 1);
    realtime.recoveryController.add(realtime.owner!);
    await tester.pumpAndSettle();
    expect(repository.conversationsCalls, 2);
    await tester.pump(const Duration(seconds: 35));
    expect(repository.conversationsCalls, 2);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'recovery cooldown and in-flight work coalesce repeated signals',
    (tester) async {
      final repository = FakeMessagingRepository();
      final realtime = FakeRealtimeConnection();
      await _showRecoveryInbox(tester, repository, realtime);
      final held = Completer<ConversationPage>();
      repository.conversationsCompleter = held;
      for (var i = 0; i < 8; i++) {
        realtime.recoveryController.add(realtime.owner!);
      }
      await tester.pump();
      await tester.pump();
      expect(repository.conversationsCalls, 2);
      await tester.pump(const Duration(seconds: 31));
      realtime.recoveryController.add(realtime.owner!);
      await tester.pump();
      expect(repository.conversationsCalls, 2);
      held.complete(
        ConversationPage(
          conversations: const [],
          hasMore: false,
          serverTime: DateTime.utc(2026, 10, 27),
        ),
      );
      await tester.pumpAndSettle();
      realtime.recoveryController.add(realtime.owner!);
      await tester.pumpAndSettle();
      expect(repository.conversationsCalls, 3);
      realtime.recoveryController.add(realtime.owner!);
      await tester.pumpAndSettle();
      expect(repository.conversationsCalls, 3);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final change in ['account', 'generation', 'role', 'logout']) {
    testWidgets('recovery fails closed after $change change', (tester) async {
      final repository = FakeMessagingRepository();
      final realtime = FakeRealtimeConnection();
      await _showRecoveryInbox(tester, repository, realtime);
      switch (change) {
        case 'account':
          repository.userId = 'other-user';
        case 'generation':
          repository.generation = 'other-generation';
        case 'role':
          repository.role = 'UNKNOWN';
        case 'logout':
          repository.sessionError = StateError('session removed');
      }
      realtime.recoveryController.add(realtime.owner!);
      await tester.pumpAndSettle();
      expect(repository.conversationsCalls, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('unrelated recovery owner cannot trigger a repository reload', (
    tester,
  ) async {
    final repository = FakeMessagingRepository();
    final realtime = FakeRealtimeConnection();
    await _showRecoveryInbox(tester, repository, realtime);
    realtime.recoveryController.add(
      const MessagingRealtimeIdentity(
        userId: 'unrelated',
        generation: 'other',
        role: 'PATIENT',
      ),
    );
    await tester.pumpAndSettle();
    expect(repository.conversationsCalls, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('pause and resume fence a pending recovery ownership read', (
    tester,
  ) async {
    final repository = _RecoveryReadRepository();
    final realtime = FakeRealtimeConnection();
    await _showRecoveryInbox(tester, repository, realtime);
    final session = await repository.requireSession();
    final held = Completer<MessagingSession>();
    repository.nextRead = held;
    realtime.recoveryController.add(realtime.owner!);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    realtime.recoveryController.add(realtime.owner!);
    await tester.pump();
    expect(repository.conversationsCalls, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(repository.conversationsCalls, 2);
    held.complete(session);
    await tester.pumpAndSettle();
    expect(repository.conversationsCalls, 2);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('disposed inbox cannot act on a late recovery ownership read', (
    tester,
  ) async {
    final repository = _RecoveryReadRepository();
    final realtime = FakeRealtimeConnection();
    await _showRecoveryInbox(tester, repository, realtime);
    final session = await repository.requireSession();
    final held = Completer<MessagingSession>();
    repository.nextRead = held;
    realtime.recoveryController.add(realtime.owner!);
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    held.complete(session);
    await tester.pumpAndSettle();
    expect(repository.conversationsCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'recovery ownership deadline contains late errors and allows retry',
    (tester) async {
      final repository = _RecoveryReadRepository();
      final realtime = FakeRealtimeConnection();
      await _showRecoveryInbox(tester, repository, realtime);
      final held = Completer<MessagingSession>();
      repository.nextRead = held;
      realtime.recoveryController.add(realtime.owner!);
      await tester.pump();
      await tester.pump(const Duration(seconds: 6));
      held.completeError(StateError('late private storage failure'));
      await tester.pumpAndSettle();
      expect(repository.conversationsCalls, 1);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 25));
      realtime.recoveryController.add(realtime.owner!);
      await tester.pumpAndSettle();
      expect(repository.conversationsCalls, 2);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'inbox ACK during initial load queues one fresh request for repeated ACKs and hints',
    (tester) async {
      final initial = Completer<ConversationPage>();
      final fresh = Completer<ConversationPage>();
      final repository =
          FakeMessagingRepository()..conversationsCompleter = initial;
      final realtime = FakeRealtimeConnection();
      await tester.pumpWidget(
        MaterialApp(
          home: MessagesPage(repository: repository, realtime: realtime),
        ),
      );
      await tester.pump();
      expect(repository.conversationsCalls, 1);
      expect(realtime.startCalls, 1);

      for (var i = 0; i < 3; i++) {
        realtime.stateController.add(true);
        realtime.hintController.add(
          const MessagingRealtimeHint(
            type: 'message.created',
            conversationId: 'conversation-1',
          ),
        );
      }
      await tester.pump();
      expect(repository.conversationsCalls, 1);

      repository.conversationsCompleter = fresh;
      initial.complete(
        ConversationPage(
          conversations: [conversationSummary(counterpartName: 'Old snapshot')],
          hasMore: false,
          serverTime: DateTime.utc(2026, 7, 26, 12),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(repository.conversationsCalls, 2);
      expect(find.text('Old snapshot'), findsOneWidget);
      expect(find.text('Fresh snapshot'), findsNothing);

      fresh.complete(
        ConversationPage(
          conversations: [
            conversationSummary(counterpartName: 'Fresh snapshot'),
          ],
          hasMore: false,
          serverTime: DateTime.utc(2026, 7, 26, 12, 1),
        ),
      );
      await tester.pumpAndSettle();
      expect(repository.conversationsCalls, 2);
      expect(find.text('Fresh snapshot'), findsOneWidget);
      expect(find.text('Old snapshot'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('inbox disposal cancels refresh queued behind initial load', (
    tester,
  ) async {
    final initial = Completer<ConversationPage>();
    final repository =
        FakeMessagingRepository()..conversationsCompleter = initial;
    final realtime = FakeRealtimeConnection();
    await tester.pumpWidget(
      MaterialApp(
        home: MessagesPage(repository: repository, realtime: realtime),
      ),
    );
    await tester.pump();
    expect(repository.conversationsCalls, 1);
    expect(realtime.startCalls, 1);
    realtime.stateController.add(true);
    realtime.hintController.add(
      const MessagingRealtimeHint(
        type: 'message.created',
        conversationId: 'conversation-1',
      ),
    );
    await tester.pump();
    expect(repository.conversationsCalls, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(realtime.disposed, isTrue);
    initial.complete(
      ConversationPage(
        conversations: [conversationSummary(counterpartName: 'Old snapshot')],
        hasMore: false,
        serverTime: DateTime.utc(2026, 7, 26, 12),
      ),
    );
    await tester.pumpAndSettle();
    expect(repository.conversationsCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('inbox reconnect catches up and lifecycle suspends transport', (
    tester,
  ) async {
    final repository = FakeMessagingRepository(
      conversations: [conversationSummary()],
    );
    final realtime = FakeRealtimeConnection();
    await tester.pumpWidget(
      MaterialApp(
        home: MessagesPage(repository: repository, realtime: realtime),
      ),
    );
    await tester.pumpAndSettle();
    expect(realtime.owner?.generation, repository.generation);
    final before = repository.conversationsCalls;
    realtime.stateController.add(true);
    await tester.pumpAndSettle();
    expect(repository.conversationsCalls, greaterThan(before));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(realtime.suspendCalls, greaterThanOrEqualTo(1));
    final paused = repository.conversationsCalls;
    realtime.stateController.add(true);
    await tester.pump();
    expect(repository.conversationsCalls, paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(repository.conversationsCalls, greaterThan(paused));
    expect(realtime.resumeCalls, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(realtime.disposed, isTrue);
  });

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
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
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
      MaterialApp(
        theme: ThemeData(splashFactory: NoSplash.splashFactory),
        home: MessagesPage(repository: repository),
      ),
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

  testWidgets('long conversation content stays usable at 320px and 2x text', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const participant =
        'Dr. A very long professional name that needs to remain readable';
    final repository = FakeMessagingRepository(
      conversations: <ConversationSummary>[
        conversationSummary(
          counterpartName: participant,
          lastActivityAt: DateTime.now().subtract(const Duration(days: 45)),
        ),
      ],
    );
    String? openedRoute;

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
        home: MessagesPage(repository: repository),
        onGenerateRoute: (settings) {
          openedRoute = settings.name;
          return MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('thread')),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(participant), findsOneWidget);
    expect(tester.takeException(), isNull);
    final row = find.byKey(const Key('conversation-conversation-1'));
    expect(
      tester
          .getSemantics(row)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(openedRoute, RouteName.chat);
    expect(find.text('thread'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
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

Future<void> _showRecoveryInbox(
  WidgetTester tester,
  FakeMessagingRepository repository,
  FakeRealtimeConnection realtime,
) async {
  await tester.pumpWidget(
    MaterialApp(home: MessagesPage(repository: repository, realtime: realtime)),
  );
  await tester.pumpAndSettle();
}

class _RecoveryReadRepository extends FakeMessagingRepository {
  Completer<MessagingSession>? nextRead;

  @override
  Future<MessagingSession> requireSession() {
    final pending = nextRead;
    nextRead = null;
    return pending?.future ?? super.requireSession();
  }
}
