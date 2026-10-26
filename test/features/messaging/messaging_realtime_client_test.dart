import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app_t/core/config/messaging_realtime_config.dart';
import 'package:app_t/features/Messaging/data/services/messaging_realtime_client.dart';
import 'package:app_t/features/Messaging/data/services/messaging_realtime_session_provider.dart';
// Available through flutter_test; no dependency change is needed.
// ignore: depend_on_referenced_packages
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const _config = MessagingRealtimeConfig(
  environment: 'staging',
  url: 'wss://carenet-messaging-staging-tkgduhftha-el.a.run.app/messaging',
);
const _owner = MessagingRealtimeIdentity(
  userId: 'patient',
  generation: 'first',
  role: 'PATIENT',
);
const _credentials = MessagingRealtimeCredentials(
  identity: _owner,
  accessToken: 'token-one',
);
const _deadline = Duration(seconds: 2);
const _retry = Duration(milliseconds: 100);

void main() {
  test('only protocol v1 ACK enables connected and hint delivery', () {
    fakeAsync((clock) {
      final h = _Harness(clock)..start();
      expect(h.states, [false]);
      h.frame('message.created');
      h.frame('auth.accepted', version: 2);
      expect(h.hints, isEmpty);
      expect(h.states, [false]);
      h.frame('auth.accepted');
      expect(h.states, [false, true]);
      h.frame('auth.accepted');
      h.frame('message.created', sequence: '9007199254740993');
      expect(h.states, [false, true]);
      expect(h.hints.single.sequence, BigInt.parse('9007199254740993'));
      h.dispose();
    });
  });

  test('missing ACK times out, closes old channel, and retries', () {
    fakeAsync((clock) {
      final h = _Harness(clock)..start();
      final old = h.channels.single;
      clock.elapse(_deadline);
      clock.flushMicrotasks();
      expect(old.output.closes, 1);
      expect(h.states, [false]);
      h.retry();
      expect(h.channels, hasLength(2));
      expect(h.channels.last.sent, hasLength(1));
      h.dispose();
    });
  });

  for (final acknowledged in [false, true]) {
    test(
      'expiry ${acknowledged ? 'after' : 'before'} ACK refreshes once on a new socket',
      () {
        fakeAsync((clock) {
          final h = _Harness(clock)..start();
          if (acknowledged) h.frame('auth.accepted');
          final old = h.channels.single;
          h.sessions.refreshGate = Completer<MessagingRealtimeCredentials?>();
          old.event('auth.expiring');
          old.event('auth.expiring');
          clock.flushMicrotasks();
          expect(h.sessions.refreshes, 1);
          expect(h.sessions.expected!.accessToken, 'token-one');
          expect(old.output.closes, 1);
          expect(old.sent, hasLength(1));
          expect(h.states.last, false);
          h.sessions.current = const MessagingRealtimeCredentials(
            identity: _owner,
            accessToken: 'token-two',
          );
          h.sessions.refreshGate!.complete(h.sessions.current);
          clock.flushMicrotasks();
          h.retry();
          expect(h.channels, hasLength(2));
          expect(jsonDecode(h.channels.last.sent.single as String), {
            'type': 'auth',
            'accessToken': 'token-two',
            'protocolVersion': 1,
          });
          expect(old.sent, hasLength(1));
          expect(h.states.last, false);
          h.frame('auth.accepted');
          expect(h.states.last, true);
          h.dispose();
        });
      },
    );
  }

  test('concurrent starts and error/done callbacks serialize attempts', () {
    fakeAsync((clock) {
      final h = _Harness(clock);
      h.sessions.readGate = Completer<MessagingRealtimeCredentials?>();
      for (var i = 0; i < 8; i++) {
        h.client.start(_owner);
      }
      clock.flushMicrotasks();
      expect(h.sessions.reads, 1);
      h.sessions.readGate!.complete(_credentials);
      h.sessions.readGate = null;
      clock.flushMicrotasks();
      expect(h.channels, hasLength(1));
      final old = h.channels.single;
      old.incoming.addError(StateError('transport failure'));
      old.incoming.close();
      clock.flushMicrotasks();
      h.retry();
      expect(h.channels, hasLength(2));
      expect(old.output.closes, 1);
      h.dispose();
    });
  });

  test(
    'every reconnect reads current token and never replays the old token',
    () {
      fakeAsync((clock) {
        final h = _Harness(clock)..start();
        h.frame('auth.accepted');
        final reads = h.sessions.reads;
        h.sessions.current = const MessagingRealtimeCredentials(
          identity: _owner,
          accessToken: 'rotated',
        );
        h.channels.single.incoming.close();
        clock.flushMicrotasks();
        h.retry();
        expect(h.sessions.reads, greaterThan(reads));
        expect(
          jsonDecode(h.channels.last.sent.single as String)['accessToken'],
          'rotated',
        );
        h.dispose();
      });
    },
  );

  test('token rotated while ready is pending is used in first auth frame', () {
    fakeAsync((clock) {
      final h = _Harness(clock);
      final ready = Completer<void>();
      h.nextReady = ready.future;
      h.start();
      h.sessions.current = const MessagingRealtimeCredentials(
        identity: _owner,
        accessToken: 'rotated-before-auth',
      );
      ready.complete();
      clock.flushMicrotasks();
      final token =
          jsonDecode(h.channels.single.sent.single as String)['accessToken'];
      h.dispose();
      expect(token, 'rotated-before-auth');
    });
  });

  test('pending refresh is bounded by session deadline and allows retry', () {
    fakeAsync((clock) {
      final h = _Harness(clock)..start();
      h.frame('auth.accepted');
      final refresh = Completer<MessagingRealtimeCredentials?>();
      h.sessions.refreshGate = refresh;
      h.frame('auth.expiring');
      expect(h.sessions.refreshes, 1);
      clock.elapse(_deadline);
      clock.flushMicrotasks();
      h.retry();
      final attempts = h.channels.length;
      h.dispose();
      refresh.completeError(StateError('late refresh timeout completion'));
      clock.flushMicrotasks();
      expect(attempts, 2);
    });
  });

  test(
    'late refresh persistence after timeout supplies next reconnect token',
    () {
      fakeAsync((clock) {
        final h = _Harness(clock)..start();
        h.frame('auth.accepted');
        final refresh = Completer<MessagingRealtimeCredentials?>();
        h.sessions.refreshGate = refresh;
        h.frame('auth.expiring');
        clock.elapse(_deadline);
        clock.flushMicrotasks();
        h.retry();
        expect(h.channels, hasLength(2));
        h.frame('auth.accepted');
        h.sessions.current = const MessagingRealtimeCredentials(
          identity: _owner,
          accessToken: 'persisted-after-timeout',
        );
        refresh.complete(h.sessions.current);
        clock.flushMicrotasks();
        expect(h.channels, hasLength(2));
        expect(h.channels.last.sent, hasLength(1));
        h.channels.last.incoming.close();
        clock.flushMicrotasks();
        h.retry();
        expect(h.channels, hasLength(3));
        expect(
          jsonDecode(h.channels.last.sent.single as String)['accessToken'],
          'persisted-after-timeout',
        );
        expect(h.sessions.refreshes, 1);
        h.dispose();
      });
    },
  );

  test('new explicit owner survives old refresh completion', () {
    fakeAsync((clock) {
      final h = _Harness(clock)..start();
      h.frame('auth.accepted');
      final refresh = Completer<MessagingRealtimeCredentials?>();
      h.sessions.refreshGate = refresh;
      h.frame('auth.expiring');
      const next = MessagingRealtimeCredentials(
        identity: MessagingRealtimeIdentity(
          userId: 'next',
          generation: 'next',
          role: 'PROFESSIONAL',
        ),
        accessToken: 'next-owner-token',
      );
      h.sessions.current = next;
      h.client.start(next.identity);
      clock.flushMicrotasks();
      refresh.complete(_credentials);
      clock.flushMicrotasks();
      h.retry();
      expect(h.channels, hasLength(2));
      expect(
        jsonDecode(h.channels.last.sent.single as String)['accessToken'],
        'next-owner-token',
      );
      h.frame('auth.accepted');
      expect(h.states.last, true);
      h.dispose();
    });
  });

  for (final boundary in ['read', 'ready', 'refresh']) {
    test('suspend during pending $boundary prevents background attempts', () {
      fakeAsync((clock) {
        final h = _Harness(clock);
        final read = Completer<MessagingRealtimeCredentials?>();
        final ready = Completer<void>();
        final refresh = Completer<MessagingRealtimeCredentials?>();
        if (boundary == 'read') h.sessions.readGate = read;
        if (boundary == 'ready') h.nextReady = ready.future;
        h.start();
        if (boundary == 'refresh') {
          h.sessions.refreshGate = refresh;
          h.frame('auth.expiring');
        }
        h.client.suspend();
        clock.flushMicrotasks();
        final attempts = h.channels.length;
        if (boundary == 'read') {
          h.sessions.readGate = null;
          read.complete(_credentials);
        }
        if (boundary == 'ready') {
          h.nextReady = null;
          ready.complete();
        }
        if (boundary == 'refresh') refresh.complete(_credentials);
        clock.flushMicrotasks();
        clock.elapse(const Duration(minutes: 1));
        expect(h.channels, hasLength(attempts));
        expect(h.states, [false]);
        h.client.resume();
        clock.flushMicrotasks();
        expect(h.channels, hasLength(attempts + 1));
        h.frame('auth.accepted');
        expect(h.states.last, true);
        h.dispose();
      });
    });
  }

  test('expiry fences ACK and hint already awaiting shared session read', () {
    fakeAsync((clock) {
      final h = _Harness(clock)..start();
      final read = Completer<MessagingRealtimeCredentials?>();
      h.sessions.readGate = read;
      h.frame('auth.accepted');
      h.frame('message.created');
      h.frame('auth.expiring');
      h.sessions.readGate = null;
      read.complete(_credentials);
      clock.flushMicrotasks();
      expect(h.states, [false]);
      expect(h.hints, isEmpty);
      expect(h.sessions.refreshes, 1);
      expect(h.channels.single.output.closes, 1);
      h.dispose();
    });
  });

  test('old pending ACK cannot authenticate replacement attempt', () {
    fakeAsync((clock) {
      final h = _Harness(clock)..start();
      final read = Completer<MessagingRealtimeCredentials?>();
      h.sessions.readGate = read;
      h.frame('auth.accepted');
      h.client.suspend();
      clock.flushMicrotasks();
      h.sessions.readGate = null;
      h.client.resume();
      clock.flushMicrotasks();
      expect(h.channels, hasLength(2));
      read.complete(_credentials);
      clock.flushMicrotasks();
      expect(h.states, [false]);
      h.frame('auth.accepted');
      expect(h.states, [false, true]);
      h.dispose();
    });
  });

  for (final failure in ['factory', 'send']) {
    test(
      '$failure callback failure is contained and retry remains serialized',
      () {
        fakeAsync((clock) {
          final h = _Harness(clock);
          h.failFactory = failure == 'factory';
          h.failSend = failure == 'send';
          h.start();
          expect(h.states, [false]);
          if (failure == 'send') expect(h.channels.single.output.closes, 1);
          h.failFactory = false;
          h.failSend = false;
          h.retry();
          expect(h.channels.length, failure == 'factory' ? 1 : 2);
          expect(h.channels.last.sent, hasLength(1));
          h.dispose();
        });
      },
    );
  }

  test('close deadline bounds disposal when channel sink never completes', () {
    fakeAsync((clock) {
      final h = _Harness(clock)..start();
      h.channels.single.output.closeGate = Completer<void>();
      var disposed = false;
      h.client.dispose().then((_) => disposed = true);
      clock.flushMicrotasks();
      expect(disposed, false);
      clock.elapse(_deadline);
      clock.flushMicrotasks();
      expect(disposed, true);
      h.channels.single.output.closeGate!.completeError(
        StateError('late close'),
      );
      clock.flushMicrotasks();
      h.retry();
      expect(h.channels, hasLength(1));
    });
  });

  for (final transition in ['dispose', 'suspend', 'new owner']) {
    test(
      '$transition during delayed close prevents stale refresh dispatch',
      () {
        fakeAsync((clock) {
          final h = _Harness(clock)..start();
          h.frame('auth.accepted');
          final old = h.channels.single;
          final close = Completer<void>();
          old.output.closeGate = close;
          h.frame('auth.expiring');
          expect(old.output.closes, 1);
          expect(h.sessions.refreshes, 0);

          const next = MessagingRealtimeCredentials(
            identity: MessagingRealtimeIdentity(
              userId: 'replacement',
              generation: 'replacement-generation',
              role: 'PROFESSIONAL',
            ),
            accessToken: 'replacement-token',
          );
          var disposed = false;
          if (transition == 'dispose') {
            h.client.dispose().then((_) => disposed = true);
          } else if (transition == 'suspend') {
            h.client.suspend();
          } else {
            h.sessions.current = next;
            h.client.start(next.identity);
          }
          clock.flushMicrotasks();
          expect(h.channels, hasLength(1));
          expect(h.sessions.refreshes, 0);
          close.complete();
          clock.flushMicrotasks();
          expect(h.sessions.refreshes, 0);
          expect(old.sent, hasLength(1));
          expect(h.states.last, false);
          expect(h.hints, isEmpty);
          h.retry();
          expect(h.sessions.refreshes, 0);

          if (transition == 'new owner') {
            expect(h.channels, hasLength(2));
            expect(
              jsonDecode(h.channels.last.sent.single as String)['accessToken'],
              next.accessToken,
            );
            h.frame('auth.accepted');
            expect(h.states.last, true);
            h.dispose();
          } else {
            clock.elapse(const Duration(minutes: 1));
            expect(h.channels, hasLength(1));
            expect(h.sessions.refreshes, 0);
            if (transition == 'dispose') {
              expect(disposed, true);
            } else {
              h.dispose();
            }
            expect(clock.nonPeriodicTimerCount + clock.periodicTimerCount, 0);
          }
        });
      },
    );
  }

  final changes = <String, MessagingRealtimeCredentials?>{
    'role': const MessagingRealtimeCredentials(
      identity: MessagingRealtimeIdentity(
        userId: 'patient',
        generation: 'first',
        role: 'PROFESSIONAL',
      ),
      accessToken: 'other',
    ),
    'user': const MessagingRealtimeCredentials(
      identity: MessagingRealtimeIdentity(
        userId: 'other',
        generation: 'first',
        role: 'PATIENT',
      ),
      accessToken: 'other',
    ),
    'same-user generation': const MessagingRealtimeCredentials(
      identity: MessagingRealtimeIdentity(
        userId: 'patient',
        generation: 'second',
        role: 'PATIENT',
      ),
      accessToken: 'other',
    ),
    'logout': null,
  };
  for (final change in changes.entries) {
    test('${change.key} during pending ACK validation rejects late ACK', () {
      fakeAsync((clock) {
        final h = _Harness(clock)..start();
        final read = Completer<MessagingRealtimeCredentials?>();
        h.sessions.readGate = read;
        h.frame('auth.accepted');
        expect(h.states, [false]);
        h.sessions.current = change.value;
        h.sessions.readGate = null;
        read.complete(change.value);
        clock.flushMicrotasks();
        expect(h.states, [false]);
        expect(h.channels.single.output.closes, 1);
        expect(h.hints, isEmpty);
        h.retry();
        expect(h.channels, hasLength(1));
        h.dispose();
      });
    });
    for (final boundary in ['ready', 'ACK', 'hint', 'refresh']) {
      test('${change.key} is fenced at $boundary', () {
        fakeAsync((clock) {
          final h = _Harness(clock);
          final ready = Completer<void>();
          if (boundary == 'ready') h.nextReady = ready.future;
          h.start();
          final old = h.channels.single;
          if (boundary == 'hint') h.frame('auth.accepted');
          h.sessions.current = change.value;
          if (boundary == 'ready') {
            ready.complete();
            clock.flushMicrotasks();
            expect(old.sent, isEmpty);
          } else {
            h.frame(
              boundary == 'ACK'
                  ? 'auth.accepted'
                  : boundary == 'hint'
                  ? 'message.created'
                  : 'auth.expiring',
            );
          }
          expect(h.hints, isEmpty);
          expect(h.states.last, false);
          expect(old.output.closes, 1);
          expect(h.sessions.refreshes, 0);
          h.retry();
          expect(h.channels, hasLength(1));
          h.dispose();
        });
      });
    }
    test('late ${change.key} refresh result cannot reconnect old owner', () {
      fakeAsync((clock) {
        final h = _Harness(clock)..start();
        h.frame('auth.accepted');
        h.sessions.refreshGate = Completer<MessagingRealtimeCredentials?>();
        h.frame('auth.expiring');
        h.sessions.current = change.value;
        h.sessions.refreshGate!.complete(change.value);
        clock.flushMicrotasks();
        h.retry();
        expect(h.channels, hasLength(1));
        expect(h.states.last, false);
        h.dispose();
      });
    });
  }

  for (final boundary in ['read', 'ready', 'refresh']) {
    test(
      'dispose during pending $boundary contains late errors and cancels retries',
      () {
        fakeAsync((clock) {
          final h = _Harness(clock);
          final read = Completer<MessagingRealtimeCredentials?>();
          final ready = Completer<void>();
          final refresh = Completer<MessagingRealtimeCredentials?>();
          if (boundary == 'read') h.sessions.readGate = read;
          if (boundary == 'ready') h.nextReady = ready.future;
          h.start();
          if (boundary == 'refresh') {
            h.sessions.refreshGate = refresh;
            h.frame('auth.expiring');
          }
          h.dispose();
          final count = h.channels.length;
          final states = h.states.toList();
          if (boundary == 'read') read.completeError(StateError('late read'));
          if (boundary == 'ready') {
            ready.completeError(StateError('late ready'));
          }
          if (boundary == 'refresh') {
            refresh.completeError(StateError('late refresh'));
          }
          clock.flushMicrotasks();
          clock.elapse(const Duration(minutes: 1));
          expect(h.channels, hasLength(count));
          expect(h.states, states);
          expect(h.hints, isEmpty);
          expect(clock.nonPeriodicTimerCount + clock.periodicTimerCount, 0);
        });
      },
    );
  }

  test('suspend stops attempts and resume revalidates identity', () {
    fakeAsync((clock) {
      final h = _Harness(clock)..start();
      h.frame('auth.accepted');
      h.client.suspend();
      clock.flushMicrotasks();
      expect(h.channels.single.output.closes, 1);
      expect(h.states.last, false);
      clock.elapse(const Duration(minutes: 1));
      h.client.start(_owner);
      clock.flushMicrotasks();
      expect(h.channels, hasLength(1));
      h.sessions.current = changes['same-user generation'];
      h.client.resume();
      clock.flushMicrotasks();
      expect(h.channels, hasLength(1));
      h.retry();
      expect(h.channels, hasLength(1));
      h.dispose();
    });
  });

  test(
    'resume with same owner uses fresh credentials and requires new ACK',
    () {
      fakeAsync((clock) {
        final h = _Harness(clock)..start();
        h.frame('auth.accepted');
        h.client.suspend();
        clock.flushMicrotasks();
        h.sessions.current = const MessagingRealtimeCredentials(
          identity: _owner,
          accessToken: 'resumed',
        );
        h.client.resume();
        clock.flushMicrotasks();
        expect(h.channels, hasLength(2));
        expect(h.states.last, false);
        expect(
          jsonDecode(h.channels.last.sent.single as String)['accessToken'],
          'resumed',
        );
        h.frame('auth.accepted');
        expect(h.states.last, true);
        h.dispose();
      });
    },
  );

  test(
    'malformed, binary, unknown version and oversized UTF8 frames are ignored',
    () {
      fakeAsync((clock) {
        final h = _Harness(clock)..start();
        h.frame('auth.accepted');
        final channel = h.channels.single;
        for (final frame in <Object>[
          'not-json',
          '[]',
          'null',
          <int>[1, 2],
          jsonEncode({'eventType': 'message.created'}),
          jsonEncode({'protocolVersion': 2, 'eventType': 'message.created'}),
          jsonEncode({
            'protocolVersion': 1,
            'eventType': 'message.created',
            'conversationId': List.filled(3000, '\u20ac').join(),
          }),
        ]) {
          channel.incoming.add(frame);
        }
        clock.flushMicrotasks();
        expect(h.hints, isEmpty);
        expect(channel.output.closes, 0);
        h.frame('message.created', sequence: '9007199254740993');
        expect(h.hints.single.sequence, BigInt.parse('9007199254740993'));
        h.dispose();
      });
    },
  );

  test('32 pending frames share one read and drain without dropping hints', () {
    fakeAsync((clock) {
      final h = _Harness(clock)..start();
      h.frame('auth.accepted');
      final reads = h.sessions.reads;
      final read = Completer<MessagingRealtimeCredentials?>();
      h.sessions.readGate = read;
      final channel = h.channels.single;
      for (var i = 0; i < 32; i++) {
        channel.event('message.created', sequence: '${i + 1}');
      }
      clock.flushMicrotasks();
      expect(h.sessions.reads, reads + 1);
      expect(channel.output.closes, 0);
      expect(h.hints, isEmpty);
      h.sessions.readGate = null;
      read.complete(_credentials);
      clock.flushMicrotasks();
      expect(
        h.hints.map((hint) => hint.sequence),
        List.generate(32, (i) => BigInt.from(i + 1)),
      );
      expect(channel.output.closes, 0);
      h.dispose();
    });
  });

  test('pending frame queue is bounded while session read is blocked', () {
    fakeAsync((clock) {
      final h = _Harness(clock)..start();
      h.frame('auth.accepted');
      h.sessions.readGate = Completer<MessagingRealtimeCredentials?>();
      final old = h.channels.single;
      for (var i = 0; i < 33; i++) {
        old.event('message.created');
      }
      clock.flushMicrotasks();
      expect(old.output.closes, 1);
      expect(h.hints, isEmpty);
      h.sessions.readGate!.complete(_credentials);
      h.sessions.readGate = null;
      clock.flushMicrotasks();
      expect(h.hints, isEmpty);
      h.dispose();
    });
  });

  for (final boundary in ['read', 'ready']) {
    test('$boundary deadline closes attempt and permits bounded retry', () {
      fakeAsync((clock) {
        final h = _Harness(clock);
        final read = Completer<MessagingRealtimeCredentials?>();
        final ready = Completer<void>();
        if (boundary == 'read') h.sessions.readGate = read;
        if (boundary == 'ready') h.nextReady = ready.future;
        h.start();
        clock.elapse(_deadline);
        clock.flushMicrotasks();
        if (boundary == 'ready') expect(h.channels.single.output.closes, 1);
        h.sessions.readGate = null;
        h.nextReady = null;
        h.retry();
        expect(h.channels.length, boundary == 'read' ? 1 : 2);
        h.dispose();
        if (boundary == 'read') read.completeError(StateError('late'));
        if (boundary == 'ready') ready.completeError(StateError('late'));
        clock.flushMicrotasks();
      });
    });
  }

  test(
    'periodic owner check fences idle authenticated connection after logout',
    () {
      fakeAsync((clock) {
        final h = _Harness(clock)..start();
        h.frame('auth.accepted');
        h.sessions.current = null;
        clock.elapse(const Duration(seconds: 5));
        clock.flushMicrotasks();
        expect(h.states.last, false);
        expect(h.channels.single.output.closes, 1);
        h.retry();
        expect(h.channels, hasLength(1));
        h.dispose();
      });
    },
  );
}

class _Harness {
  _Harness(this.clock) {
    client = MessagingRealtimeClient(
      config: _config,
      sessions: sessions,
      initialReconnectDelay: _retry,
      maximumReconnectDelay: _retry,
      connectionTimeout: _deadline,
      acknowledgementTimeout: _deadline,
      sessionTimeout: _deadline,
      closeTimeout: _deadline,
      sessionCheckInterval: const Duration(seconds: 5),
      random: Random(1),
      channelFactory: (uri) {
        expect(uri.toString(), _config.url);
        expect(uri.query, isEmpty);
        expect(uri.userInfo, isEmpty);
        if (failFactory) throw StateError('factory callback failed');
        final channel = _Channel(ready: nextReady);
        channel.output.failSend = failSend;
        channels.add(channel);
        return channel;
      },
    );
    client.connectionState.listen(states.add);
    client.hints.listen(hints.add);
  }
  final FakeAsync clock;
  final sessions = _Sessions();
  final channels = <_Channel>[];
  final states = <bool>[];
  final hints = <MessagingRealtimeHint>[];
  late final MessagingRealtimeClient client;
  Future<void>? nextReady;
  bool failFactory = false, failSend = false;
  void start() {
    client.start(_owner);
    clock.flushMicrotasks();
  }

  void frame(String type, {int version = 1, String sequence = '1'}) {
    channels.last.event(type, version: version, sequence: sequence);
    clock.flushMicrotasks();
  }

  void retry() {
    clock.elapse(const Duration(milliseconds: 125));
    clock.flushMicrotasks();
  }

  void dispose() {
    var done = false;
    client.dispose().then((_) => done = true);
    clock.flushMicrotasks();
    expect(done, true);
  }
}

class _Sessions implements MessagingRealtimeSessionProvider {
  MessagingRealtimeCredentials? current = _credentials;
  Completer<MessagingRealtimeCredentials?>? readGate, refreshGate;
  MessagingRealtimeCredentials? expected;
  int reads = 0, refreshes = 0;
  @override
  Future<MessagingRealtimeCredentials?> read() async {
    reads++;
    return readGate?.future ?? current;
  }

  @override
  Future<MessagingRealtimeCredentials?> refresh(
    MessagingRealtimeCredentials expected,
  ) async {
    refreshes++;
    this.expected = expected;
    return refreshGate?.future ?? current;
  }
}

class _Channel implements WebSocketChannel {
  _Channel({Future<void>? ready}) : ready = ready ?? Future<void>.value();
  final incoming = StreamController<dynamic>();
  final sent = <Object?>[];
  late final output = _Sink(sent);
  void event(String type, {int version = 1, String sequence = '1'}) =>
      incoming.add(
        jsonEncode({
          'protocolVersion': version,
          'eventType': type,
          'conversationId': 'conversation',
          'sequence': sequence,
        }),
      );
  @override
  final Future<void> ready;
  @override
  Stream<dynamic> get stream => incoming.stream;
  @override
  WebSocketSink get sink => output;
  @override
  int? get closeCode => null;
  @override
  String? get closeReason => null;
  @override
  String? get protocol => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Sink implements WebSocketSink {
  _Sink(this.sent);
  final List<Object?> sent;
  final completed = Completer<void>();
  int closes = 0;
  bool failSend = false;
  Completer<void>? closeGate;
  @override
  void add(Object? data) {
    if (failSend) throw StateError('sink callback failed');
    sent.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}
  @override
  Future<void> addStream(Stream stream) async {
    await for (final value in stream) {
      add(value);
    }
  }

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    closes++;
    if (closeGate != null) await closeGate!.future;
    if (!completed.isCompleted) completed.complete();
  }

  @override
  Future<void> get done => completed.future;
}
