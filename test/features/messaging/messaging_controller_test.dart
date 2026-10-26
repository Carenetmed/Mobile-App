import 'dart:async';

import 'package:app_t/features/Messaging/presentation/state/messaging_controllers.dart';
import 'package:app_t/features/Messaging/data/services/messaging_realtime_client.dart';
import 'package:app_t/features/Messaging/domain/entities/messaging_models.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'messaging_test_fakes.dart';

void main() {
  test(
    'deferred chat load suspends before starting realtime in background',
    () async {
      final page = Completer<ConversationPage>();
      final repository = FakeMessagingRepository(
        conversations: [conversationSummary()],
      )..conversationsCompleter = page;
      final realtime = FakeRealtimeConnection();
      final controller = AppointmentChatController(
        repository: repository,
        realtime: realtime,
        conversationId: 'conversation-1',
        disconnectedPollInterval: const Duration(milliseconds: 5),
      );
      addTearDown(controller.dispose);
      final loading = controller.load();
      await Future<void>.delayed(Duration.zero);
      expect(repository.conversationsCalls, 1);
      expect(realtime.startCalls, 0);
      await controller.onAppPaused();
      page.complete(
        ConversationPage(
          conversations: [conversationSummary()],
          hasMore: false,
          serverTime: DateTime.utc(2026, 7, 26, 12),
        ),
      );
      await loading;
      expect(controller.detail, isNotNull);
      expect(realtime.lifecycleCalls, ['suspend', 'suspend', 'start']);
      expect(controller.realtimeConnected, isFalse);
      final before = repository.messagesCalls;
      realtime.stateController.add(false);
      await Future<void>.delayed(const Duration(milliseconds: 18));
      expect(repository.messagesCalls, before);
      expect(realtime.resumeCalls, 0);
      await controller.onAppResumed();
      expect(repository.messagesCalls, greaterThan(before));
      expect(realtime.lifecycleCalls.last, 'resume');
    },
  );

  test(
    'typed realtime owner pauses polling and resumes after HTTP catch-up',
    () async {
      final repository = FakeMessagingRepository(
        conversations: [conversationSummary()],
      );
      final realtime = FakeRealtimeConnection();
      final controller = AppointmentChatController(
        repository: repository,
        realtime: realtime,
        conversationId: 'conversation-1',
        disconnectedPollInterval: const Duration(milliseconds: 5),
      );
      addTearDown(controller.dispose);
      await controller.load();
      expect(realtime.owner?.userId, repository.userId);
      expect(realtime.owner?.generation, repository.generation);
      expect(realtime.owner?.role, repository.role);

      await controller.onAppPaused();
      expect(realtime.suspendCalls, 1);
      final before = repository.messagesCalls;
      realtime.stateController.add(false);
      realtime.hintController.add(
        const MessagingRealtimeHint(
          type: 'message.created',
          conversationId: 'conversation-1',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 18));
      expect(repository.messagesCalls, before);

      await controller.onAppResumed();
      expect(repository.messagesCalls, greaterThan(before));
      expect(realtime.resumeCalls, 1);
    },
  );

  test(
    'missing session generation retains HTTP without starting realtime',
    () async {
      final repository = FakeMessagingRepository(
        generation: null,
        conversations: [conversationSummary()],
        messages: [careMessage()],
      );
      final realtime = FakeRealtimeConnection();
      final controller = AppointmentChatController(
        repository: repository,
        realtime: realtime,
        conversationId: 'conversation-1',
      );
      addTearDown(controller.dispose);
      await controller.load();
      expect(controller.detail, isNotNull);
      expect(controller.flyerController.messages, hasLength(1));
      expect(realtime.startCalls, 0);
      expect(realtime.owner, isNull);
      final before = repository.messagesCalls;
      await controller.catchUp();
      expect(repository.messagesCalls, greaterThan(before));
    },
  );

  group('conversation list', () {
    test(
      'orders by last activity and unread does not override order',
      () async {
        final repository = FakeMessagingRepository(
          conversations:
              <dynamic>[
                conversationSummary(
                  conversationId: 'older-unread',
                  unreadCount: 9,
                  lastActivityAt: DateTime.utc(2026, 7, 26, 10),
                ),
                conversationSummary(
                  conversationId: 'newer-read',
                  unreadCount: 0,
                  lastActivityAt: DateTime.utc(2026, 7, 26, 11),
                ),
              ].cast(),
        );
        final controller = ConversationListController(repository: repository);

        await controller.load();

        expect(
          controller.conversations.map((item) => item.conversationId),
          <String>['newer-read', 'older-unread'],
        );
        controller.dispose();
      },
    );

    test('serializes repeated initial loads', () async {
      final repository = FakeMessagingRepository();
      final controller = ConversationListController(repository: repository);

      await Future.wait(<Future<void>>[controller.load(), controller.load()]);

      expect(repository.conversationsCalls, 1);
      controller.dispose();
    });

    test(
      'cursor pagination deduplicates and preserves stable ordering',
      () async {
        final repository =
            FakeMessagingRepository()
              ..conversationPages = <ConversationPage>[
                ConversationPage(
                  conversations: <ConversationSummary>[
                    conversationSummary(
                      conversationId: 'conversation-b',
                      lastActivityAt: DateTime.utc(2026, 7, 26, 10),
                    ),
                  ],
                  hasMore: true,
                  nextCursor: 'cursor-1',
                  serverTime: DateTime.utc(2026, 7, 26, 12),
                ),
                ConversationPage(
                  conversations: <ConversationSummary>[
                    conversationSummary(
                      conversationId: 'conversation-b',
                      lastActivityAt: DateTime.utc(2026, 7, 26, 10),
                    ),
                    conversationSummary(
                      conversationId: 'conversation-a',
                      lastActivityAt: DateTime.utc(2026, 7, 26, 10),
                    ),
                  ],
                  hasMore: false,
                  serverTime: DateTime.utc(2026, 7, 26, 12),
                ),
              ];
        final controller = ConversationListController(repository: repository);

        await controller.load();
        await Future.wait(<Future<void>>[
          controller.loadMore(),
          controller.loadMore(),
        ]);

        expect(repository.requestedCursors, <String?>[null, 'cursor-1']);
        expect(
          controller.conversations.map((item) => item.conversationId),
          <String>['conversation-a', 'conversation-b'],
        );
        controller.dispose();
      },
    );

    test('account change clears the previous conversation list', () async {
      final repository = FakeMessagingRepository(
        conversations: <ConversationSummary>[conversationSummary()],
      );
      final controller = ConversationListController(repository: repository);
      await controller.load();

      repository
        ..userId = 'professional-user'
        ..conversationsValue = <ConversationSummary>[];
      await controller.load(refresh: true);

      expect(controller.conversations, isEmpty);
      controller.dispose();
    });

    test('late list completion cannot update a disposed controller', () async {
      final repository = FakeMessagingRepository();
      final pending = Completer<ConversationPage>();
      repository.conversationsCompleter = pending;
      final controller = ConversationListController(repository: repository);

      final load = controller.load();
      await Future<void>.delayed(Duration.zero);
      controller.dispose();
      pending.complete(
        ConversationPage(
          conversations: <ConversationSummary>[conversationSummary()],
          hasMore: false,
          serverTime: DateTime.utc(2026, 7, 26, 12),
        ),
      );
      await load;

      expect(controller.conversations, isEmpty);
    });
  });

  group('appointment thread', () {
    test(
      'uses sequence authority and deduplicates client message IDs',
      () async {
        final repository = FakeMessagingRepository(
          conversations: <dynamic>[conversationSummary()].cast(),
          messages:
              <dynamic>[
                careMessage(
                  id: 'message-2',
                  clientMessageId: 'same-client',
                  text: 'new committed copy',
                  sequence: BigInt.two,
                ),
                careMessage(
                  id: 'message-1',
                  clientMessageId: 'same-client',
                  text: 'old duplicate copy',
                  sequence: BigInt.one,
                ),
              ].cast(),
        );
        final controller = AppointmentChatController(
          repository: repository,
          realtime: FakeRealtimeConnection(),
          conversationId: 'conversation-1',
        );

        await controller.load();

        expect(controller.flyerController.messages, hasLength(1));
        expect(
          (controller.flyerController.messages.single as TextMessage).text,
          'new committed copy',
        );
        controller.dispose();
      },
    );

    test('ambiguous retry reuses the original client message ID', () async {
      final repository = FakeMessagingRepository(
        conversations: <dynamic>[conversationSummary()].cast(),
      );
      final controller = AppointmentChatController(
        repository: repository,
        realtime: FakeRealtimeConnection(),
        conversationId: 'conversation-1',
        idFactory: () => 'fixed-client-id',
      );
      await controller.load();
      repository.sendError = StateError('timeout');

      await controller.send('Need help before the appointment');

      expect(controller.pendingMessages.single.retryable, isTrue);
      repository.sendError = null;
      await controller.retry('fixed-client-id');

      expect(repository.sentClientIds, <String>[
        'fixed-client-id',
        'fixed-client-id',
      ]);
      expect(controller.pendingMessages, isEmpty);
      controller.dispose();
    });

    test(
      'validates 4000 Unicode code points without splitting emoji',
      () async {
        final repository = FakeMessagingRepository(
          conversations: <dynamic>[conversationSummary()].cast(),
        );
        final controller = AppointmentChatController(
          repository: repository,
          realtime: FakeRealtimeConnection(),
          conversationId: 'conversation-1',
        );
        await controller.load();

        final emoji = String.fromCharCode(0x1f642);
        await controller.send(List<String>.filled(4000, emoji).join());
        expect(repository.sendCalls, 1);

        await controller.send(List<String>.filled(4001, emoji).join());
        expect(repository.sendCalls, 1);
        expect(controller.errorMessage, contains('4,000'));
        controller.dispose();
      },
    );

    test('socket hint triggers authoritative HTTP catch-up', () async {
      final repository = FakeMessagingRepository(
        conversations: <dynamic>[conversationSummary()].cast(),
        messages: <CareMessage>[
          careMessage(id: 'message-1', sequence: BigInt.one),
        ],
      );
      final realtime = FakeRealtimeConnection();
      final controller = AppointmentChatController(
        repository: repository,
        realtime: realtime,
        conversationId: 'conversation-1',
      );
      await controller.load();
      final before = repository.messagesCalls;
      repository.messagesValue = <CareMessage>[
        ...repository.messagesValue,
        careMessage(
          id: 'message-2',
          clientMessageId: 'client-2',
          sequence: BigInt.two,
        ),
      ];
      realtime.hintController.add(
        const MessagingRealtimeHint(
          type: 'message.created',
          conversationId: 'conversation-1',
          sequence: null,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(repository.messagesCalls, greaterThan(before));
      expect(repository.requestedAfterSequences.last, BigInt.one);
      expect(controller.flyerController.messages, hasLength(2));
      controller.dispose();
      expect(realtime.disposed, isTrue);
    });

    test(
      'read cursor advances only after visible projection is confirmed',
      () async {
        final repository = FakeMessagingRepository(
          conversations: <dynamic>[conversationSummary()].cast(),
          messages: <dynamic>[careMessage()].cast(),
        );
        final controller = AppointmentChatController(
          repository: repository,
          realtime: FakeRealtimeConnection(),
          conversationId: 'conversation-1',
        );

        await controller.load();
        expect(repository.markReadCalls, 0);

        await controller.markVisibleRead();
        await controller.markVisibleRead();

        expect(repository.markReadCalls, 1);
        controller.dispose();
      },
    );

    test('account switch clears prior private message state', () async {
      final repository = FakeMessagingRepository(
        conversations: <dynamic>[conversationSummary()].cast(),
        messages: <dynamic>[careMessage()].cast(),
      );
      final controller = AppointmentChatController(
        repository: repository,
        realtime: FakeRealtimeConnection(),
        conversationId: 'conversation-1',
      );
      await controller.load();
      expect(controller.flyerController.messages, isNotEmpty);

      repository.userId = 'different-user';
      await controller.catchUp();

      expect(controller.flyerController.messages, isEmpty);
      expect(controller.detail, isNull);
      expect(controller.errorMessage, contains('account changed'));
      controller.dispose();
    });

    test(
      'appointment ID resolves the exact authoritative conversation',
      () async {
        final repository = FakeMessagingRepository(
          conversations: <ConversationSummary>[
            conversationSummary(
              conversationId: 'conversation-exact',
              appointmentId: 'appointment-exact',
            ),
          ],
        );
        final controller = AppointmentChatController(
          repository: repository,
          realtime: FakeRealtimeConnection(),
          appointmentId: 'appointment-exact',
        );

        await controller.load();

        expect(controller.summary?.conversationId, 'conversation-exact');
        controller.dispose();
      },
    );

    test('appointment without a conversation fails closed', () async {
      final controller = AppointmentChatController(
        repository: FakeMessagingRepository(),
        realtime: FakeRealtimeConnection(),
        appointmentId: 'requested-appointment',
      );

      await controller.load();

      expect(controller.detail, isNull);
      expect(controller.errorMessage, contains('no longer available'));
      controller.dispose();
    });

    test('successful send replaces the optimistic projection', () async {
      final repository = FakeMessagingRepository(
        conversations: <ConversationSummary>[conversationSummary()],
      );
      final controller = AppointmentChatController(
        repository: repository,
        realtime: FakeRealtimeConnection(),
        conversationId: 'conversation-1',
        idFactory: () => 'one-client-id',
      );
      await controller.load();

      await controller.send('A committed appointment message');

      expect(controller.pendingMessages, isEmpty);
      expect(repository.sentClientIds, <String>['one-client-id']);
      expect(
        controller.flyerController.messages.where(
          (message) => message.id == 'server-one-client-id',
        ),
        hasLength(1),
      );
      controller.dispose();
    });

    test(
      'optimistic send and repeated taps share one in-flight request',
      () async {
        final repository = FakeMessagingRepository(
          conversations: <ConversationSummary>[conversationSummary()],
        );
        final pendingResponse = Completer<CareMessage>();
        repository.sendCompleter = pendingResponse;
        final controller = AppointmentChatController(
          repository: repository,
          realtime: FakeRealtimeConnection(),
          conversationId: 'conversation-1',
          idFactory: () => 'one-client-id',
        );
        await controller.load();

        final first = controller.send('Please confirm the appointment');
        final second = controller.send('Duplicate tap');
        await Future<void>.delayed(Duration.zero);

        expect(repository.sendCalls, 1);
        expect(
          controller.pendingMessages.single.clientMessageId,
          'one-client-id',
        );
        expect(
          controller.flyerController.messages.single.status,
          MessageStatus.sending,
        );

        pendingResponse.complete(
          careMessage(
            id: 'message-committed',
            clientMessageId: 'one-client-id',
            authorUserId: 'patient-user',
          ),
        );
        await Future.wait(<Future<void>>[first, second]);

        expect(repository.sendCalls, 1);
        expect(controller.pendingMessages, isEmpty);
        controller.dispose();
      },
    );

    test('read-only lifecycle cannot send a message', () async {
      final repository = FakeMessagingRepository(
        conversations: <ConversationSummary>[
          conversationSummary(status: 'CANCELLED', writable: false),
        ],
        detail: conversationDetail(status: 'CANCELLED', writable: false),
      );
      final controller = AppointmentChatController(
        repository: repository,
        realtime: FakeRealtimeConnection(),
        conversationId: 'conversation-1',
      );
      await controller.load();

      await controller.send('This must not be submitted');

      expect(repository.sendCalls, 0);
      expect(controller.pendingMessages, isEmpty);
      controller.dispose();
    });

    test('counterpart read cursor maps committed messages to Seen', () async {
      final repository = FakeMessagingRepository(
        conversations: <ConversationSummary>[conversationSummary()],
        detail: conversationDetail(professionalRead: BigInt.one),
        messages: <CareMessage>[
          careMessage(authorUserId: 'patient-user', seenByOther: true),
        ],
      );
      final controller = AppointmentChatController(
        repository: repository,
        realtime: FakeRealtimeConnection(),
        conversationId: 'conversation-1',
      );

      await controller.load();

      expect(
        controller.flyerController.messages.single.status,
        MessageStatus.seen,
      );
      controller.dispose();
    });

    test('older history is serialized and remains in sequence order', () async {
      final repository = FakeMessagingRepository(
          conversations: <ConversationSummary>[conversationSummary()],
        )
        ..messagePages = <MessagePage>[
          MessagePage(
            messages: <CareMessage>[
              careMessage(id: 'message-2', sequence: BigInt.two),
            ],
            hasMoreBefore: true,
            hasMoreAfter: false,
            firstSequence: BigInt.two,
            lastSequence: BigInt.two,
          ),
          MessagePage(
            messages: <CareMessage>[
              careMessage(
                id: 'message-1',
                clientMessageId: 'client-older',
                sequence: BigInt.one,
              ),
            ],
            hasMoreBefore: false,
            hasMoreAfter: false,
            firstSequence: BigInt.one,
            lastSequence: BigInt.one,
          ),
        ];
      final controller = AppointmentChatController(
        repository: repository,
        realtime: FakeRealtimeConnection(),
        conversationId: 'conversation-1',
      );
      await controller.load();

      await Future.wait(<Future<void>>[
        controller.loadOlder(),
        controller.loadOlder(),
      ]);

      expect(repository.requestedBeforeSequences, <BigInt?>[null, BigInt.two]);
      expect(
        controller.flyerController.messages.map((message) => message.id),
        <String>['message-1', 'message-2'],
      );
      controller.dispose();
    });

    test('unrelated socket hint cannot load another conversation', () async {
      final repository = FakeMessagingRepository(
        conversations: <ConversationSummary>[conversationSummary()],
      );
      final realtime = FakeRealtimeConnection();
      final controller = AppointmentChatController(
        repository: repository,
        realtime: realtime,
        conversationId: 'conversation-1',
      );
      await controller.load();
      final before = repository.messagesCalls;

      realtime.hintController.add(
        const MessagingRealtimeHint(
          type: 'message.created',
          conversationId: 'conversation-other',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(repository.messagesCalls, before);
      controller.dispose();
    });

    test('foreground recovery catches up and disposal stops polling', () async {
      final repository = FakeMessagingRepository(
        conversations: <ConversationSummary>[conversationSummary()],
      );
      final realtime = FakeRealtimeConnection();
      final controller = AppointmentChatController(
        repository: repository,
        realtime: realtime,
        conversationId: 'conversation-1',
        disconnectedPollInterval: const Duration(milliseconds: 5),
      );
      await controller.load();
      final afterLoad = repository.messagesCalls;

      await controller.onAppResumed();
      expect(repository.messagesCalls, greaterThan(afterLoad));

      realtime.stateController.add(false);
      await Future<void>.delayed(const Duration(milliseconds: 18));
      final beforeDispose = repository.messagesCalls;
      expect(beforeDispose, greaterThan(afterLoad + 1));

      controller.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 18));
      expect(repository.messagesCalls, beforeDispose);
      expect(realtime.disposed, isTrue);
    });

    test('healthy realtime stops disconnected polling', () async {
      final repository = FakeMessagingRepository(
        conversations: <ConversationSummary>[conversationSummary()],
      );
      final realtime = FakeRealtimeConnection();
      final controller = AppointmentChatController(
        repository: repository,
        realtime: realtime,
        conversationId: 'conversation-1',
        disconnectedPollInterval: const Duration(milliseconds: 5),
      );
      await controller.load();

      realtime.stateController.add(false);
      await Future<void>.delayed(const Duration(milliseconds: 16));
      realtime.stateController.add(true);
      await Future<void>.delayed(Duration.zero);
      final afterReconnectCatchUp = repository.messagesCalls;
      await Future<void>.delayed(const Duration(milliseconds: 16));

      expect(repository.messagesCalls, afterReconnectCatchUp);
      controller.dispose();
    });

    test('session loss clears private thread state', () async {
      final repository = FakeMessagingRepository(
        conversations: <ConversationSummary>[conversationSummary()],
        messages: <CareMessage>[careMessage()],
      );
      final controller = AppointmentChatController(
        repository: repository,
        realtime: FakeRealtimeConnection(),
        conversationId: 'conversation-1',
      );
      await controller.load();
      repository.sessionError = StateError('signed out');

      await controller.catchUp();

      expect(controller.flyerController.messages, isEmpty);
      expect(controller.detail, isNull);
      expect(controller.currentUserId, isNull);
      controller.dispose();
    });

    test('non-participant session fails closed', () async {
      final repository = FakeMessagingRepository(
        userId: 'unrelated-user',
        conversations: <ConversationSummary>[conversationSummary()],
      );
      final controller = AppointmentChatController(
        repository: repository,
        realtime: FakeRealtimeConnection(),
        conversationId: 'conversation-1',
      );

      await controller.load();

      expect(controller.detail, isNull);
      expect(controller.errorMessage, contains('cannot access'));
      controller.dispose();
    });
  });
}
