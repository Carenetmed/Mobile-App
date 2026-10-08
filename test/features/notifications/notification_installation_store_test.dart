import 'package:app_t/features/Notifications/data/services/firebase_notification_transport.dart';
import 'package:app_t/core/config/app_environment.dart';
import 'package:app_t/features/Notifications/data/storage/notification_installation_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  test(
    'installation identifier is generated once and persists securely',
    () async {
      final store = SecureNotificationInstallationStore();

      final first = await store.installationId();
      final second = await store.installationId();

      expect(first, hasLength(32));
      expect(second, first);
      expect(first, matches(RegExp(r'^[a-f0-9]{32}$')));
    },
  );

  test(
    'binding generation is serialized and survives store recreation',
    () async {
      final store = SecureNotificationInstallationStore();
      final values = await Future.wait(<Future<String>>[
        store.nextBindingGeneration(),
        store.nextBindingGeneration(),
      ]);

      expect(values, ['1', '2']);
      await store.bindUser('user-1');
      await store.clearBinding();

      expect(
        await SecureNotificationInstallationStore().nextBindingGeneration(),
        '3',
      );
    },
  );

  test('new installation identity resets an orphaned generation', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{
      'carenet.notifications.bindingGeneration': '5000',
    });
    final store = SecureNotificationInstallationStore();

    expect(await store.installationId(), hasLength(32));
    expect(await store.nextBindingGeneration(), '1');
  });

  test('account binding and pending tap are independently cleared', () async {
    final store = SecureNotificationInstallationStore();
    await store.bindUser('user-1');
    await store.savePendingNotificationId('notification-1');

    await store.clearPendingNotificationId();
    expect(await store.boundUserId(), 'user-1');
    expect(await store.pendingNotificationId(), isNull);

    await store.clearBinding();
    expect(await store.boundUserId(), isNull);
  });

  test('Firebase client config requires all four non-secret identifiers', () {
    const complete = FirebaseClientConfig(
      projectId: AppEnvironmentConfig.canonicalFirebaseProjectId,
      appId: '1:123:android:abc',
      messagingSenderId: '123',
      apiKey: 'public-firebase-api-key',
    );
    const incomplete = FirebaseClientConfig(
      projectId: AppEnvironmentConfig.canonicalFirebaseProjectId,
      appId: '',
      messagingSenderId: '123',
      apiKey: 'public-firebase-api-key',
    );

    expect(complete.isConfigured, isTrue);
    expect(
      complete.options.projectId,
      AppEnvironmentConfig.canonicalFirebaseProjectId,
    );
    expect(incomplete.isConfigured, isFalse);
    expect(
      const FirebaseClientConfig(
        projectId: 'carenet-175b7',
        appId: 'wrong-app',
        messagingSenderId: '123',
        apiKey: 'public-firebase-api-key',
      ).isConfigured,
      isFalse,
    );
  });
}
