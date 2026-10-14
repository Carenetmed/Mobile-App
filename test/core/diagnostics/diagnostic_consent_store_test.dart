import 'dart:convert';

import 'package:app_t/core/diagnostics/diagnostic_consent_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test(
    'diagnostic sharing defaults off without a matching explicit grant',
    () async {
      expect(await SecureDiagnosticConsentStore().enabledGeneration(), isNull);
      expect(
        await SecureDiagnosticConsentStore().isEnabledFor('session-a'),
        isFalse,
      );
    },
  );

  test(
    'consent survives store recreation only for its session generation',
    () async {
      await SecureDiagnosticConsentStore().enableFor('session-a');
      final restored = SecureDiagnosticConsentStore();
      expect(await restored.isEnabledFor('session-a'), isTrue);
      expect(await restored.isEnabledFor('session-b'), isFalse);
    },
  );

  test(
    'record contains only schema and opaque generation, never credentials',
    () async {
      await SecureDiagnosticConsentStore().enableFor('session-a');
      final values = await const FlutterSecureStorage().readAll();
      expect(values.keys, [SecureDiagnosticConsentStore.key]);
      expect(jsonDecode(values[SecureDiagnosticConsentStore.key]!), {
        'schemaVersion': 1,
        'sessionGeneration': 'session-a',
      });
    },
  );

  test('disable removes the matching grant', () async {
    final store = SecureDiagnosticConsentStore();
    await store.enableFor('session-a');
    await store.disableFor('session-a');
    expect(await store.isEnabledFor('session-a'), isFalse);
    expect(await const FlutterSecureStorage().readAll(), isEmpty);
  });

  test(
    'late old-session revocation cannot remove a newer-session grant',
    () async {
      final store = SecureDiagnosticConsentStore();
      await store.enableFor('session-b');
      await store.disableFor('session-a');
      expect(await store.isEnabledFor('session-b'), isTrue);
    },
  );

  test(
    'concurrent writes serialize and the latest selected binding wins',
    () async {
      final store = SecureDiagnosticConsentStore();
      await Future.wait([
        store.enableFor('session-a'),
        store.enableFor('session-b'),
        store.disableFor('session-a'),
      ]);
      expect(await store.isEnabledFor('session-b'), isTrue);
      expect(await store.isEnabledFor('session-a'), isFalse);
    },
  );

  test('corrupt, partial, unknown or contaminated records fail closed', () async {
    for (final encoded in [
      '{invalid',
      '{}',
      '[]',
      '${List.filled(300, ' ').join()}{"schemaVersion":1,"sessionGeneration":"session-a"}',
      '{"schemaVersion":2,"sessionGeneration":"session-a"}',
      '{"schemaVersion":1,"sessionGeneration":""}',
      '{"schemaVersion":1,"sessionGeneration":"session-a","token":"synthetic"}',
    ]) {
      FlutterSecureStorage.setMockInitialValues({
        SecureDiagnosticConsentStore.key: encoded,
      });
      expect(
        await SecureDiagnosticConsentStore().isEnabledFor('session-a'),
        isFalse,
      );
      expect(await SecureDiagnosticConsentStore().enabledGeneration(), isNull);
    }
  });

  test(
    'credential-like invalid bindings cannot be persisted or echoed',
    () async {
      final store = SecureDiagnosticConsentStore();
      const value = 'synthetic.jwt.secret';
      await expectLater(
        store.enableFor(value),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'safe message',
            isNot(contains(value)),
          ),
        ),
      );
      expect(await const FlutterSecureStorage().readAll(), isEmpty);
      expect(await store.isEnabledFor(value), isFalse);
    },
  );
}
