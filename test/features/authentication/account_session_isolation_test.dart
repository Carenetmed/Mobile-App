import 'dart:async';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/models/auth_user_model.dart';
import 'package:app_t/features/Authentication/data/repositories/account_repository.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/auth_api_client.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/domain/entities/account_deletion_receipt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('secure account clear removes a rotated session atomically', () async {
    final store = SecureSessionStore();
    await store.save(_session('first'));
    await store.save(_rotatedSession('first'));
    expect(await store.clearAccountIfCurrent('first'), isTrue);
    expect(await store.read(), isNull);
    expect(await const FlutterSecureStorage().readAll(), isEmpty);
  });

  test('secure account clear preserves a different account', () async {
    final store = SecureSessionStore();
    await store.save(_session('second'));
    expect(await store.clearAccountIfCurrent('first'), isFalse);
    expect((await store.read())?.user.id, 'second');
  });

  test('explicit logout clears its account after token rotation', () async {
    final store = InMemorySessionStore();
    await store.save(_session('first'));
    final api = _PendingAccountClient();
    final repository = AuthRepository(apiClient: api, sessionStore: store);
    final request = repository.logout();
    await api.logoutStarted.future;
    await store.save(_rotatedSession('first'));
    api.logoutResult.complete();
    await request;
    expect(await store.read(), isNull);
  });

  test('successful deletion clears its account after token rotation', () async {
    final store = InMemorySessionStore();
    await store.save(_session('first'));
    final api = _PendingAccountClient();
    final repository = AccountRepository(apiClient: api, sessionStore: store);
    final request = repository.requestAccountDeletion(password: 'test-only');
    await api.deletionStarted.future;
    await store.save(_rotatedSession('first'));
    api.deletionResult.complete(
      AccountDeletionReceipt(
        accountStatus: 'DELETED',
        deletionRequestedAt: DateTime.utc(2026, 10, 1),
        retentionStatus: 'RETAINED_UNDER_POLICY',
        sessionsRevoked: true,
      ),
    );
    await request;
    expect(await store.read(), isNull);
  });

  test('delayed logout cannot clear a newly authenticated account', () async {
    final store = InMemorySessionStore();
    await store.save(_session('first'));
    final api = _PendingAccountClient();
    final repository = AuthRepository(apiClient: api, sessionStore: store);
    final request = repository.logout();
    await api.logoutStarted.future;
    await store.save(_session('second'));
    api.logoutResult.complete();
    await request;
    expect((await store.read())?.user.id, 'second');
  });

  test('delayed deletion cannot clear a newly authenticated account', () async {
    final store = InMemorySessionStore();
    await store.save(_session('first'));
    final api = _PendingAccountClient();
    final repository = AccountRepository(apiClient: api, sessionStore: store);
    final request = repository.requestAccountDeletion(password: 'test-only');
    final rejected = expectLater(request, throwsA(isA<AuthFailure>()));
    await api.deletionStarted.future;
    await store.save(_session('second'));
    api.deletionResult.complete(
      AccountDeletionReceipt(
        accountStatus: 'DELETED',
        deletionRequestedAt: DateTime.utc(2026, 10, 1),
        retentionStatus: 'RETAINED_UNDER_POLICY',
        sessionsRevoked: true,
      ),
    );
    await rejected;
    expect((await store.read())?.user.id, 'second');
  });
  test(
    'late account rejection cannot clear a different account session',
    () async {
      final store = InMemorySessionStore();
      await store.save(_session('first'));
      final api = _PendingAccountClient();
      final repository = AccountRepository(apiClient: api, sessionStore: store);
      final request = repository.currentAccount();
      final rejected = expectLater(request, throwsA(isA<AuthFailure>()));
      await api.started.future;
      await store.save(_session('second'));
      api.result.completeError(
        const AuthFailure(
          type: AuthFailureType.unauthorized,
          message: 'Please sign in again.',
          statusCode: 401,
        ),
      );
      await rejected;
      expect((await store.read())?.user.id, 'second');
    },
  );

  test(
    'late account success cannot return a previous account identity',
    () async {
      final store = InMemorySessionStore();
      await store.save(_session('first'));
      final api = _PendingAccountClient();
      final repository = AccountRepository(apiClient: api, sessionStore: store);
      final request = repository.currentAccount();
      final rejected = expectLater(request, throwsA(isA<AuthFailure>()));
      await api.started.future;
      await store.save(_session('second'));
      api.result.complete(_user('first'));
      await rejected;
      expect((await store.read())?.user.id, 'second');
    },
  );

  test(
    'account response must match the requesting authenticated identity',
    () async {
      final store = InMemorySessionStore();
      await store.save(_session('first'));
      final api = _PendingAccountClient();
      final repository = AccountRepository(apiClient: api, sessionStore: store);
      final request = repository.currentAccount();
      final rejected = expectLater(request, throwsA(isA<AuthFailure>()));
      await api.started.future;
      api.result.complete(_user('other'));
      await rejected;
      expect((await store.read())?.user.id, 'first');
    },
  );

  test('missing configuration preserves the authenticated session', () async {
    final store = InMemorySessionStore();
    await store.save(_session('first'));
    final api = _PendingAccountClient();
    final repository = AccountRepository(apiClient: api, sessionStore: store);
    final request = repository.currentAccount();
    final rejected = expectLater(request, throwsA(isA<AuthFailure>()));
    await api.started.future;
    api.result.completeError(
      const AuthFailure(
        type: AuthFailureType.missingConfiguration,
        message: 'Service configuration is unavailable.',
      ),
    );
    await rejected;
    expect((await store.read())?.user.id, 'first');
  });

  test('current account rejection clears only its matching session', () async {
    final store = InMemorySessionStore();
    await store.save(_session('first'));
    final api = _PendingAccountClient();
    final repository = AccountRepository(apiClient: api, sessionStore: store);
    final request = repository.currentAccount();
    final rejected = expectLater(request, throwsA(isA<AuthFailure>()));
    await api.started.future;
    api.result.completeError(
      const AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'Please sign in again.',
        statusCode: 401,
      ),
    );
    await rejected;
    expect(await store.read(), isNull);
  });
}

AuthUserModel _user(String id) => AuthUserModel(
  id: id,
  email: '$id@example.test',
  role: 'PATIENT',
  status: 'ACTIVE',
  emailVerified: true,
);

AuthSessionModel _session(String id) => AuthSessionModel.fromJson({
  'accessToken': '$id-access',
  'refreshToken': '$id-refresh',
  'tokenType': 'Bearer',
  'expiresIn': 900,
  'user': _user(id).toJson(),
});

AuthSessionModel _rotatedSession(String id) => AuthSessionModel.fromJson({
  'accessToken': '$id-access-rotated',
  'refreshToken': '$id-refresh-rotated',
  'tokenType': 'Bearer',
  'expiresIn': 900,
  'user': _user(id).toJson(),
});

class _PendingAccountClient extends AuthApiClient {
  _PendingAccountClient()
    : super(
        config: const CareNetApiConfig(baseUrl: 'https://api.example.test'),
      );

  final started = Completer<void>();
  final result = Completer<AuthUserModel>();
  final logoutStarted = Completer<void>();
  final logoutResult = Completer<void>();
  final deletionStarted = Completer<void>();
  final deletionResult = Completer<AccountDeletionReceipt>();

  @override
  Future<void> logout({required String refreshToken}) {
    logoutStarted.complete();
    return logoutResult.future;
  }

  @override
  Future<AccountDeletionReceipt> requestAccountDeletion({
    required String accessToken,
    String? password,
    String? googleIdToken,
  }) {
    deletionStarted.complete();
    return deletionResult.future;
  }

  @override
  Future<AuthUserModel> me({required String accessToken}) {
    started.complete();
    return result.future;
  }
}
