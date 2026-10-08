import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/repositories/account_repository.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/auth_api_client.dart';
import 'package:app_t/features/Notifications/domain/services/notification_session_lifecycle.dart';
import 'package:app_t/features/Notifications/data/services/firebase_notification_transport.dart';
import 'package:app_t/features/Notifications/domain/entities/notification_models.dart';
import 'package:app_t/features/Notifications/presentation/state/notification_coordinator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'notification_test_fakes.dart';

void main() {
  test(
    'successful login binds notification lifecycle after session storage',
    () async {
      final store = InMemoryNotificationSessionStore();
      final lifecycle = _RecordingLifecycle();
      final repository = _repository(store, lifecycle);

      final session = await repository.login(
        email: 'patient@example.com',
        password: 'CareNet@123',
      );

      expect((await store.read())?.user.id, 'user-1');
      expect(lifecycle.authenticated, [session]);
    },
  );

  test(
    'notification registration failure never invalidates successful login',
    () async {
      final store = InMemoryNotificationSessionStore();
      final lifecycle = _RecordingLifecycle(failAuthentication: true);

      final session = await _repository(
        store,
        lifecycle,
      ).login(email: 'patient@example.com', password: 'CareNet@123');

      expect(session.user.id, 'user-1');
      expect((await store.read())?.accessToken, 'access-token');
    },
  );

  test(
    'logout unbinds notification installation before clearing session',
    () async {
      final session = notificationTestSession();
      final store = InMemoryNotificationSessionStore(session);
      final lifecycle = _RecordingLifecycle();

      await _repository(store, lifecycle).logout();

      expect(lifecycle.loggedOut, [session]);
      expect(await store.read(), isNull);
    },
  );

  test(
    'unauthorized account refresh unbinds installation before session clear',
    () async {
      final session = notificationTestSession();
      final store = InMemoryNotificationSessionStore(session);
      final lifecycle = _RecordingLifecycle();
      final repository = AccountRepository(
        apiClient: AuthApiClient(
          config: const CareNetApiConfig(baseUrl: 'https://api.carenet.test'),
          dio: Dio()..httpClientAdapter = _UnauthorizedAdapter(),
        ),
        sessionStore: store,
        notificationLifecycle: lifecycle,
      );

      await expectLater(repository.currentAccount(), throwsA(isA<Exception>()));

      expect(lifecycle.loggedOut, [session]);
      expect(await store.read(), isNull);
    },
  );

  test('hung installation removal cannot block logout cleanup', () async {
    final repository = _NeverCompletingRemovalRepository();
    final store = FakeNotificationInstallationStore()..boundUser = 'user-1';
    final coordinator = _coordinator(
      repository,
      store,
      FakeNotificationTransport(configured: false),
      providerTimeout: const Duration(milliseconds: 30),
    );
    addTearDown(coordinator.dispose);

    await coordinator.onAuthenticatedSession(repository.session);
    await coordinator
        .beforeLogout(repository.session)
        .timeout(const Duration(milliseconds: 250));

    expect(store.boundUser, isNull);
  });

  test(
    'auth callback returns while token lookup hangs and ignores its late result',
    () async {
      final session = notificationTestSession();
      final repository = FakeNotificationRepository(session: session);
      final transport = _LateFirstTokenTransport();
      final installationStore = FakeNotificationInstallationStore();
      final coordinator = _coordinator(
        repository,
        installationStore,
        transport,
        providerTimeout: const Duration(seconds: 2),
      );
      addTearDown(coordinator.dispose);

      await coordinator
          .onAuthenticatedSession(session)
          .timeout(const Duration(milliseconds: 250));
      await transport.firstLookupStarted.future.timeout(
        const Duration(milliseconds: 250),
      );

      final nextSession = notificationTestSession(userId: 'user-2');
      repository.session = nextSession;
      await coordinator
          .onAuthenticatedSession(nextSession)
          .timeout(const Duration(milliseconds: 250));
      transport.firstLookup.complete('late-user-1-token');

      await transport.secondLookupStarted.future.timeout(
        const Duration(seconds: 1),
      );
      await _waitUntil(() => installationStore.boundUser == 'user-2');

      expect(repository.registrationPayloads, hasLength(1));
      expect(installationStore.boundUser, 'user-2');
    },
  );

  test(
    'late registration completion cannot bind stale local installation state',
    () async {
      final session = notificationTestSession();
      final repository = _HangingRegistrationRepository(session: session);
      final installationStore = FakeNotificationInstallationStore();
      final coordinator = _coordinator(
        repository,
        installationStore,
        FakeNotificationTransport(),
        providerTimeout: const Duration(milliseconds: 100),
      );
      addTearDown(coordinator.dispose);

      await coordinator
          .onAuthenticatedSession(session)
          .timeout(const Duration(milliseconds: 250));
      await repository.firstRegistrationStarted.future.timeout(
        const Duration(milliseconds: 250),
      );

      final nextSession = notificationTestSession(userId: 'user-2');
      repository.session = nextSession;
      await coordinator
          .onAuthenticatedSession(nextSession)
          .timeout(const Duration(milliseconds: 250));
      repository.releaseFirstRegistration.complete();
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(repository.registrationPayloads, hasLength(1));
      expect(installationStore.boundUser, isNull);

      repository.finishLateFirstRegistration.complete();
      await repository.secondRegistrationFinished.future.timeout(
        const Duration(seconds: 1),
      );

      await _waitUntil(() => installationStore.boundUser == 'user-2');
      expect(installationStore.boundUser, 'user-2');
      expect(
        repository.registrationPayloads
            .map((payload) => payload['bindingGeneration'])
            .toList(),
        ['1', '2'],
      );
    },
  );

  test(
    'auth callback returns while unread fetch hangs; stale account result is ignored',
    () async {
      final firstSession = notificationTestSession();
      final repository = _HangingUnreadRepository(session: firstSession);
      final coordinator = _coordinator(
        repository,
        FakeNotificationInstallationStore(),
        FakeNotificationTransport(configured: false),
        providerTimeout: const Duration(seconds: 2),
      );
      addTearDown(coordinator.dispose);

      await coordinator
          .onAuthenticatedSession(firstSession)
          .timeout(const Duration(milliseconds: 250));
      await repository
          .unreadStarted(0)
          .timeout(const Duration(milliseconds: 250));

      final nextSession = notificationTestSession(userId: 'user-2');
      repository.session = nextSession;
      await coordinator
          .onAuthenticatedSession(nextSession)
          .timeout(const Duration(milliseconds: 250));
      await repository
          .unreadStarted(1)
          .timeout(const Duration(milliseconds: 250));

      repository.unreadResults[0].complete(91);
      await Future<void>.delayed(Duration.zero);
      expect(coordinator.unreadCount, 0);

      repository.unreadResults[1].complete(3);
      await _waitUntil(() => coordinator.unreadCount == 3);
    },
  );

  test('late unread result cannot mutate a disposed coordinator', () async {
    final repository = _HangingUnreadRepository();
    final coordinator = _coordinator(
      repository,
      FakeNotificationInstallationStore(),
      FakeNotificationTransport(configured: false),
      providerTimeout: const Duration(seconds: 2),
    );

    await coordinator
        .onAuthenticatedSession(repository.session)
        .timeout(const Duration(milliseconds: 250));
    await repository
        .unreadStarted(0)
        .timeout(const Duration(milliseconds: 250));
    coordinator.dispose();
    repository.unreadResults[0].complete(12);
    await Future<void>.delayed(Duration.zero);

    expect(coordinator.unreadCount, 0);
  });

  testWidgets(
    'pending notification resolves once navigation becomes ready without blocking auth callback',
    (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      final session = notificationTestSession();
      final repository = _HangingNotificationRepository(
        session: session,
        items: <CareNotification>[
          notificationTestItem(
            id: 'queued-tap',
            entityId: 'appointment-queued',
          ),
        ],
      );
      final store = FakeNotificationInstallationStore();
      final coordinator = _coordinator(
        repository,
        store,
        FakeNotificationTransport(configured: false),
        navigatorKey: navigatorKey,
        providerTimeout: const Duration(seconds: 2),
      );
      addTearDown(coordinator.dispose);
      await tester.pumpWidget(_routingApp(navigatorKey));

      await coordinator.handleTap('queued-tap');
      await coordinator.markNavigationReady();
      await coordinator
          .onAuthenticatedSession(session)
          .timeout(const Duration(milliseconds: 250));
      await repository.notificationStarted.future.timeout(
        const Duration(milliseconds: 250),
      );
      await tester.pump();

      expect(store.pendingNotification, 'queued-tap');
      expect(find.text('home'), findsOneWidget);

      repository.notificationResult.complete(repository.items.single);
      await tester.pumpAndSettle();

      expect(store.pendingNotification, isNull);
      expect(find.text('appointment:appointment-queued'), findsOneWidget);
    },
  );
}

NotificationCoordinator _coordinator(
  FakeNotificationRepository repository,
  FakeNotificationInstallationStore installationStore,
  NotificationTransport transport, {
  GlobalKey<NavigatorState>? navigatorKey,
  Duration providerTimeout = const Duration(seconds: 8),
}) {
  return NotificationCoordinator(
    repository: repository,
    installationStore: installationStore,
    transport: transport,
    navigatorKey: navigatorKey ?? GlobalKey<NavigatorState>(),
    providerTimeout: providerTimeout,
    metadataLoader:
        () async => const NotificationDeviceMetadata(
          platform: 'ANDROID',
          appId: 'com.carenet.app',
          appVersion: '1.0.0+1',
          locale: 'en_NG',
        ),
  );
}

Future<void> _waitUntil(bool Function() predicate) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (!predicate() && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(predicate(), isTrue);
}

class _LateFirstTokenTransport extends FakeNotificationTransport {
  final Completer<void> firstLookupStarted = Completer<void>();
  final Completer<void> secondLookupStarted = Completer<void>();
  final Completer<String?> firstLookup = Completer<String?>();
  int _calls = 0;

  @override
  Future<String?> endpoint() {
    _calls++;
    if (_calls == 1) {
      firstLookupStarted.complete();
      return firstLookup.future;
    }
    secondLookupStarted.complete();
    return Future<String?>.value('current-user-token');
  }
}

class _HangingRegistrationRepository extends FakeNotificationRepository {
  _HangingRegistrationRepository({super.session});

  final Completer<void> firstRegistrationStarted = Completer<void>();
  final Completer<void> releaseFirstRegistration = Completer<void>();
  final Completer<void> finishLateFirstRegistration = Completer<void>();
  final Completer<void> secondRegistrationFinished = Completer<void>();
  int _registrations = 0;

  @override
  Future<void> registerInstallation({
    required AuthSessionModel session,
    required Map<String, dynamic> payload,
  }) async {
    registrationPayloads.add(Map<String, dynamic>.of(payload));
    _registrations++;
    if (_registrations == 1) {
      firstRegistrationStarted.complete();
      await releaseFirstRegistration.future;
      await finishLateFirstRegistration.future;
      return;
    }
    secondRegistrationFinished.complete();
  }
}

class _HangingUnreadRepository extends FakeNotificationRepository {
  _HangingUnreadRepository({super.session});

  final List<Completer<int>> unreadResults = <Completer<int>>[];
  final List<Completer<void>> _unreadStarted = <Completer<void>>[];

  Future<void> unreadStarted(int index) => _unreadStarted[index].future;

  @override
  Future<int> unreadCount() {
    final started = Completer<void>();
    final result = Completer<int>();
    _unreadStarted.add(started);
    unreadResults.add(result);
    started.complete();
    return result.future;
  }
}

class _HangingNotificationRepository extends FakeNotificationRepository {
  _HangingNotificationRepository({
    required super.session,
    required super.items,
  });

  final Completer<void> notificationStarted = Completer<void>();
  final Completer<CareNotification> notificationResult =
      Completer<CareNotification>();

  @override
  Future<CareNotification> notification(String id) {
    notificationStarted.complete();
    return notificationResult.future;
  }
}

class _NeverCompletingRemovalRepository extends FakeNotificationRepository {
  @override
  Future<void> removeInstallation({
    required AuthSessionModel session,
    required String installationId,
  }) => Completer<void>().future;
}

Widget _routingApp(GlobalKey<NavigatorState> navigatorKey) {
  return MaterialApp(
    navigatorKey: navigatorKey,
    home: const Scaffold(body: Text('home')),
    onGenerateRoute:
        (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder:
              (_) => Scaffold(
                body: Text(switch (settings.name) {
                  RouteName.appointmentDetail =>
                    'appointment:${settings.arguments}',
                  RouteName.notification => 'notification-inbox',
                  _ => 'other-route',
                }),
              ),
        ),
  );
}

AuthRepository _repository(
  InMemoryNotificationSessionStore store,
  NotificationSessionLifecycle lifecycle,
) {
  return AuthRepository(
    apiClient: AuthApiClient(
      config: const CareNetApiConfig(baseUrl: 'https://api.carenet.test'),
      dio: Dio()..httpClientAdapter = _AuthAdapter(),
    ),
    sessionStore: store,
    notificationLifecycle: lifecycle,
  );
}

class _RecordingLifecycle implements NotificationSessionLifecycle {
  _RecordingLifecycle({this.failAuthentication = false});

  final bool failAuthentication;
  final List<AuthSessionModel> authenticated = <AuthSessionModel>[];
  final List<AuthSessionModel> loggedOut = <AuthSessionModel>[];

  @override
  Future<void> beforeLogout(AuthSessionModel session) async {
    loggedOut.add(session);
  }

  @override
  Future<void> afterAccountDeletion(AuthSessionModel session) async {
    loggedOut.add(session);
  }

  @override
  Future<void> onAuthenticatedSession(AuthSessionModel session) async {
    authenticated.add(session);
    if (failAuthentication) throw StateError('FCM unavailable');
  }
}

class _AuthAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body =
        options.path.endsWith('/auth/login')
            ? <String, dynamic>{
              'accessToken': 'access-token',
              'refreshToken': 'refresh-token',
              'tokenType': 'Bearer',
              'expiresIn': 900,
              'user': <String, dynamic>{
                'id': 'user-1',
                'email': 'patient@example.com',
                'role': 'PATIENT',
                'status': 'ACTIVE',
                'emailVerified': true,
              },
            }
            : <String, dynamic>{};
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _UnauthorizedAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(<String, dynamic>{'message': 'Unauthorized'}),
      401,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
