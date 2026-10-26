import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/core/config/messaging_realtime_config.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/services/auth_api_client.dart';
import 'package:app_t/features/Authentication/data/services/session_refresh_coordinator.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Messaging/data/repositories/messaging_repository.dart';
import 'package:app_t/features/Messaging/data/services/messaging_api_client.dart';
import 'package:app_t/features/Messaging/data/services/messaging_realtime_client.dart';
import 'package:app_t/features/Messaging/data/services/messaging_realtime_session_provider.dart';
import 'package:app_t/features/Messaging/presentation/pages/Messages.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'messaging_test_fakes.dart';

const _apiConfig = CareNetApiConfig(baseUrl: 'https://api.example.test');

void main() {
  testWidgets(
    'real realtime inbox connection disposes without HTTP adapter',
    (tester) async {
      final sockets = <_Socket>[];
      final realtime = MessagingRealtimeClient(
        config: const MessagingRealtimeConfig(
          environment: 'staging',
          url:
              'wss://carenet-messaging-staging-tkgduhftha-el.a.run.app/messaging',
        ),
        sessions: _FixedSessions(),
        channelFactory: (_) {
          final socket = _Socket();
          sockets.add(socket);
          return socket;
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          home: MessagesPage(
            repository: FakeMessagingRepository(),
            realtime: realtime,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(sockets, hasLength(1));
      sockets.single.ack();
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      for (final socket in sockets) {
        await socket.incoming.close();
      }
    },
    timeout: const Timeout(Duration(seconds: 15)),
  );

  for (final rejection in [401, 403, 503]) {
    testWidgets(
      'lost expiry hint uses HTTP $rejection authority, not generic socket rejection',
      (tester) async {
        final store = InMemorySessionStore();
        await store.save(_session('old'));
        final generation = (await store.capture())!.generation;
        final auth = _AuthApi();
        final coordinator = SessionRefreshCoordinator(
          apiClient: auth,
          sessionStore: store,
        );
        final adapter = _ConversationsAdapter();
        final dio = Dio()..httpClientAdapter = adapter;
        dio.interceptors.add(
          SessionRefreshInterceptor(dio: dio, coordinator: coordinator),
        );
        final repository = MessagingRepository(
          apiClient: MessagingApiClient(config: _apiConfig, dio: dio),
          sessionStore: store,
        );
        final sockets = <_Socket>[];
        final realtime = MessagingRealtimeClient(
          config: const MessagingRealtimeConfig(
            environment: 'staging',
            url:
                'wss://carenet-messaging-staging-tkgduhftha-el.a.run.app/messaging',
          ),
          sessions: StoredMessagingRealtimeSessionProvider(
            coordinator: coordinator,
          ),
          initialReconnectDelay: const Duration(milliseconds: 100),
          maximumReconnectDelay: const Duration(milliseconds: 100),
          channelFactory: (_) {
            final socket = _Socket();
            sockets.add(socket);
            return socket;
          },
        );
        await tester.pumpWidget(
          MaterialApp(
            home: MessagesPage(repository: repository, realtime: realtime),
          ),
        );
        await tester.pumpAndSettle();
        expect(sockets, hasLength(1));
        sockets.single.ack();
        await tester.pumpAndSettle();
        expect(auth.calls, 0);

        // Connectivity was lost before any expiry hint. The server now rejects
        // the previously valid credentials; the client must ask HTTP authority.
        adapter.rejection = rejection;
        unawaited(sockets.single.incoming.close());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(sockets, hasLength(2));
        expect(sockets.last.token, 'old');
        unawaited(sockets.last.incoming.close());
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        final expectedToken = rejection == 401 ? 'fresh' : 'old';
        expect(auth.calls, rejection == 401 ? 1 : 0);
        expect((await store.capture())!.session.accessToken, expectedToken);
        expect((await store.capture())!.generation, generation);
        expect(sockets.last.token, expectedToken);
        expect(adapter.authorizations, contains('Bearer old'));
        expect(adapter.authorizations, [
          'Bearer old',
          'Bearer old',
          'Bearer old',
          if (rejection == 401) 'Bearer fresh',
        ]);
        if (rejection == 401) {
          expect(adapter.authorizations.last, 'Bearer fresh');
          sockets.last.ack();
          await tester.pumpAndSettle();
          expect(auth.calls, 1);
          expect(find.text('No appointment conversations yet'), findsOneWidget);
        } else {
          expect(adapter.authorizations, isNot(contains('Bearer fresh')));
          if (rejection == 403) {
            expect(
              find.text('This account cannot access that conversation.'),
              findsOneWidget,
            );
            expect(find.textContaining('session has expired'), findsNothing);
          }
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        final closures = [
          for (final socket in sockets) socket.incoming.close(),
        ];
        await tester.pump();
        await Future.wait(closures);
        dio.close(force: true);
      },
      timeout: const Timeout(Duration(minutes: 1)),
    );
  }
}

class _FixedSessions implements MessagingRealtimeSessionProvider {
  @override
  Future<MessagingRealtimeCredentials?> read() async =>
      const MessagingRealtimeCredentials(
        identity: MessagingRealtimeIdentity(
          userId: 'patient-user',
          generation: 'fixture-generation',
          role: 'PATIENT',
        ),
        accessToken: 'proof',
      );
  @override
  Future<MessagingRealtimeCredentials?> refresh(
    MessagingRealtimeCredentials expected,
  ) => read();
}

class _ConversationsAdapter implements HttpClientAdapter {
  int? rejection;
  final authorizations = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    expect(options.method, 'GET');
    expect(options.uri.path, '/conversations');
    final authorization = options.headers['Authorization'] as String;
    authorizations.add(authorization);
    final status = authorization == 'Bearer fresh' ? 200 : rejection ?? 200;
    return ResponseBody.fromString(
      jsonEncode(
        status == 200
            ? {
              'conversations': <Object>[],
              'pageInfo': {'hasMore': false, 'nextCursor': null},
              'serverTime': '2026-10-27T00:00:00.000Z',
            }
            : {'message': 'Controlled test rejection'},
      ),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _AuthApi extends AuthApiClient {
  _AuthApi() : super(config: _apiConfig);
  int calls = 0;

  @override
  Future<AuthSessionModel> refresh({required String refreshToken}) async {
    expect(refreshToken, 'refresh-proof');
    calls++;
    return _session('fresh');
  }
}

AuthSessionModel _session(String token) => AuthSessionModel.fromJson({
  'accessToken': token,
  'refreshToken': 'refresh-proof',
  'tokenType': 'Bearer',
  'expiresIn': 900,
  'user': {
    'id': 'patient-proof',
    'email': 'patient@example.test',
    'role': 'PATIENT',
    'status': 'ACTIVE',
    'emailVerified': true,
  },
});

class _Socket implements WebSocketChannel {
  final incoming = StreamController<dynamic>.broadcast();
  final output = _SocketSink();
  String get token =>
      (jsonDecode(output.frames.single as String)
              as Map<String, dynamic>)['accessToken']
          as String;
  void ack() => incoming.add(
    jsonEncode({'protocolVersion': 1, 'eventType': 'auth.accepted'}),
  );

  @override
  Stream<dynamic> get stream => incoming.stream;
  @override
  WebSocketSink get sink => output;
  @override
  Future<void> get ready => Future<void>.value();
  @override
  int? get closeCode => 1008;
  @override
  String? get closeReason => 'Policy rejection';
  @override
  String? get protocol => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SocketSink implements WebSocketSink {
  final frames = <dynamic>[];
  @override
  void add(dynamic data) => frames.add(data);
  @override
  void addError(Object error, [StackTrace? stackTrace]) {}
  @override
  Future<void> addStream(Stream<dynamic> stream) async {
    await for (final data in stream) {
      add(data);
    }
  }

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {}
  @override
  Future<void> get done => Future<void>.value();
}
