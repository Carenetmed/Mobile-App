import 'dart:async';

import 'package:app_t/features/Authentication/data/services/google_sign_in_provider.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

class _Google extends Fake implements GoogleSignIn {
  int initializations = 0;
  int authentications = 0;
  String? clientId;
  bool supported = true;
  String? token = 'test-id-token';
  Object? initializationError;
  Object? authenticationError;
  Completer<void>? initialization;
  Completer<GoogleSignInAccount>? authentication;

  @override
  Future<void> initialize({
    String? clientId,
    String? serverClientId,
    String? nonce,
    String? hostedDomain,
  }) async {
    initializations++;
    this.clientId = serverClientId;
    if (initializationError case final error?) throw error;
    await initialization?.future;
  }

  @override
  bool supportsAuthenticate() => supported;

  @override
  Future<GoogleSignInAccount> authenticate({
    List<String> scopeHint = const <String>[],
  }) async {
    authentications++;
    if (authenticationError case final error?) throw error;
    return authentication == null ? _Account(token) : authentication!.future;
  }
}

class _Account extends Fake implements GoogleSignInAccount {
  _Account(this.token);
  final String? token;

  @override
  GoogleSignInAuthentication get authentication =>
      GoogleSignInAuthentication(idToken: token);
}

TypeMatcher<AuthFailure> failure(AuthFailureType type) =>
    isA<AuthFailure>().having((value) => value.type, 'type', type);

void main() {
  late _Google google;
  late GoogleSignInIdTokenProvider provider;

  setUp(() {
    google = _Google();
    provider = GoogleSignInIdTokenProvider(
      config: const GoogleSignInConfig(serverClientId: ' web-client '),
      googleSignIn: google,
    );
  });

  test('missing configuration never invokes the SDK', () async {
    provider = GoogleSignInIdTokenProvider(
      config: const GoogleSignInConfig(serverClientId: '  '),
      googleSignIn: google,
    );
    expect(provider.isConfigured, isFalse);
    await expectLater(
      provider.signInIdToken(),
      throwsA(failure(AuthFailureType.missingConfiguration)),
    );
    expect(google.initializations, 0);
    expect(google.authentications, 0);
  });

  test('uses trimmed server client and returns the exact SDK token', () async {
    expect(provider.isConfigured, isTrue);
    expect(await provider.signInIdToken(), 'test-id-token');
    expect(google.clientId, 'web-client');
  });

  test('successful initialization is reused for subsequent sign-ins', () async {
    await provider.signInIdToken();
    await provider.signInIdToken();
    expect(google.initializations, 1);
    expect(google.authentications, 2);
  });

  test('concurrent taps share initialization and authentication', () async {
    google.initialization = Completer<void>();
    google.authentication = Completer<GoogleSignInAccount>();
    final first = provider.signInIdToken();
    final second = provider.signInIdToken();
    expect(identical(first, second), isTrue);
    expect(google.initializations, 1);
    google.initialization!.complete();
    await Future<void>.delayed(Duration.zero);
    expect(google.authentications, 1);
    google.authentication!.complete(_Account('shared-token'));
    expect(await first, 'shared-token');
    expect(await second, 'shared-token');
  });

  test(
    'rejected initialization can retry without restarting the app',
    () async {
      google.initializationError = StateError('private SDK detail');
      await expectLater(
        provider.signInIdToken(),
        throwsA(failure(AuthFailureType.unknown)),
      );
      google.initializationError = null;
      expect(await provider.signInIdToken(), 'test-id-token');
      expect(google.initializations, 2);
    },
  );

  testWidgets('timeout retains one initialization until it completes', (
    tester,
  ) async {
    google.initialization = Completer<void>();
    final first = expectLater(
      provider.signInIdToken(),
      throwsA(failure(AuthFailureType.network)),
    );
    await tester.pump(const Duration(seconds: 30));
    await first;
    expect(google.authentications, 0);
    final retry = provider.signInIdToken();
    expect(google.initializations, 1);
    google.initialization!.complete();
    await tester.pump();
    expect(await retry, 'test-id-token');
    expect(google.authentications, 1);
  });

  testWidgets('late initialization rejection allows a fresh retry', (
    tester,
  ) async {
    google.initialization = Completer<void>();
    final first = expectLater(
      provider.signInIdToken(),
      throwsA(failure(AuthFailureType.network)),
    );
    await tester.pump(const Duration(seconds: 30));
    await first;
    google.initialization!.completeError(StateError('private late failure'));
    await tester.pump();
    google.initialization = null;
    final retry = provider.signInIdToken();
    await tester.pump();
    expect(await retry, 'test-id-token');
    expect(google.initializations, 2);
  });

  test(
    'unsupported platform never starts interactive authentication',
    () async {
      google.supported = false;
      await expectLater(
        provider.signInIdToken(),
        throwsA(failure(AuthFailureType.validation)),
      );
      expect(google.authentications, 0);
    },
  );

  for (final token in <String?>[null, '  ']) {
    test(
      'rejects ${token == null ? 'missing' : 'blank'} SDK ID token',
      () async {
        google.token = token;
        await expectLater(
          provider.signInIdToken(),
          throwsA(failure(AuthFailureType.validation)),
        );
      },
    );
  }

  const mappings = <GoogleSignInExceptionCode, AuthFailureType>{
    GoogleSignInExceptionCode.canceled: AuthFailureType.validation,
    GoogleSignInExceptionCode.clientConfigurationError:
        AuthFailureType.missingConfiguration,
    GoogleSignInExceptionCode.providerConfigurationError:
        AuthFailureType.missingConfiguration,
    GoogleSignInExceptionCode.uiUnavailable: AuthFailureType.validation,
    GoogleSignInExceptionCode.interrupted: AuthFailureType.unknown,
    GoogleSignInExceptionCode.userMismatch: AuthFailureType.unknown,
    GoogleSignInExceptionCode.unknownError: AuthFailureType.unknown,
  };
  for (final entry in mappings.entries) {
    test('maps ${entry.key.name} without exposing SDK details', () async {
      google.authenticationError = GoogleSignInException(
        code: entry.key,
        description: 'private provider detail',
      );
      await expectLater(
        provider.signInIdToken(),
        throwsA(
          failure(entry.value).having(
            (value) => value.message,
            'safe message',
            isNot(contains('private provider detail')),
          ),
        ),
      );
    });
  }

  test(
    'unknown SDK errors remain safe and later attempts can succeed',
    () async {
      google.authenticationError = StateError('private SDK detail');
      await expectLater(
        provider.signInIdToken(),
        throwsA(
          failure(AuthFailureType.unknown).having(
            (value) => value.message,
            'safe message',
            isNot(contains('private SDK detail')),
          ),
        ),
      );
      google.authenticationError = null;
      expect(await provider.signInIdToken(), 'test-id-token');
      expect(google.initializations, 1);
    },
  );

  test('existing domain failure is preserved', () async {
    const original = AuthFailure(
      type: AuthFailureType.server,
      message: 'Safe domain failure.',
    );
    google.authenticationError = original;
    await expectLater(provider.signInIdToken(), throwsA(same(original)));
  });
}
