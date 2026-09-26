import 'package:app_t/core/config/app_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppEnvironmentConfig', () {
    test('accepts canonical staging configuration', () {
      const config = AppEnvironmentConfig(
        environment: CareNetEnvironment.staging,
        apiBaseUrl: 'https://staging.example.com',
        firebaseProjectId: AppEnvironmentConfig.canonicalFirebaseProjectId,
        firebaseAppId: 'staging-firebase-app-id',
        googleServerClientId: 'web-client-id',
      );

      expect(config.validationErrors(requireProviders: true), isEmpty);
    });

    test('rejects the discarded Firebase project', () {
      const config = AppEnvironmentConfig(
        environment: CareNetEnvironment.staging,
        apiBaseUrl: 'https://staging.example.com',
        firebaseProjectId: 'carenet-175b7',
        firebaseAppId: 'wrong-project-app-id',
        googleServerClientId: 'web-client-id',
      );

      expect(
        config.validationErrors(requireProviders: true),
        contains('Firebase must use the canonical CareNet project.'),
      );
    });

    test('production requires HTTPS and configured providers', () {
      const config = AppEnvironmentConfig(
        environment: CareNetEnvironment.production,
        apiBaseUrl: 'http://production.example.com',
        firebaseProjectId: AppEnvironmentConfig.canonicalFirebaseProjectId,
        firebaseAppId: 'production-firebase-app-id',
        googleServerClientId: '',
      );

      expect(config.validationErrors(requireProviders: true), hasLength(2));
    });
  });
}
