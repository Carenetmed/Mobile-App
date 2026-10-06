import 'package:app_t/core/config/app_environment.dart';
import 'package:flutter/foundation.dart';
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

    test('startup accepts the registered app for the selected flavor', () {
      const config = AppEnvironmentConfig(
        environment: CareNetEnvironment.staging,
        apiBaseUrl: 'https://staging.example.com',
        firebaseProjectId: AppEnvironmentConfig.canonicalFirebaseProjectId,
        firebaseAppId: AppEnvironmentConfig.stagingAndroidFirebaseAppId,
        googleServerClientId: '',
      );

      expect(
        config.startupValidationErrors(
          selectedFlavor: 'staging',
          platform: TargetPlatform.android,
          requireProviders: false,
        ),
        isEmpty,
      );
    });

    test('startup accepts registered Android and iOS flavor app IDs', () {
      final cases = [
        (
          CareNetEnvironment.staging,
          'staging',
          TargetPlatform.android,
          AppEnvironmentConfig.stagingAndroidFirebaseAppId,
        ),
        (
          CareNetEnvironment.production,
          'production',
          TargetPlatform.android,
          AppEnvironmentConfig.productionAndroidFirebaseAppId,
        ),
        (
          CareNetEnvironment.staging,
          'staging',
          TargetPlatform.iOS,
          AppEnvironmentConfig.stagingIosFirebaseAppId,
        ),
        (
          CareNetEnvironment.production,
          'production',
          TargetPlatform.iOS,
          AppEnvironmentConfig.productionIosFirebaseAppId,
        ),
      ];

      for (final (environment, flavor, platform, appId) in cases) {
        final config = AppEnvironmentConfig(
          environment: environment,
          apiBaseUrl:
              environment == CareNetEnvironment.production
                  ? 'https://api.example.com'
                  : 'https://staging.example.com',
          firebaseProjectId: AppEnvironmentConfig.canonicalFirebaseProjectId,
          firebaseAppId: appId,
          googleServerClientId: '',
        );

        expect(
          config.startupValidationErrors(
            selectedFlavor: flavor,
            platform: platform,
            requireProviders: false,
          ),
          isEmpty,
        );
      }
    });

    test('startup rejects environment and flavor mismatch', () {
      const config = AppEnvironmentConfig(
        environment: CareNetEnvironment.staging,
        apiBaseUrl: 'https://staging.example.com',
        firebaseProjectId: AppEnvironmentConfig.canonicalFirebaseProjectId,
        firebaseAppId: AppEnvironmentConfig.stagingAndroidFirebaseAppId,
        googleServerClientId: '',
      );

      expect(
        config.startupValidationErrors(
          selectedFlavor: 'production',
          platform: TargetPlatform.android,
          requireProviders: false,
        ),
        contains('CARENET_ENVIRONMENT must match the selected build flavor.'),
      );
    });

    test(
      'startup rejects Firebase app IDs from another flavor or platform',
      () {
        const config = AppEnvironmentConfig(
          environment: CareNetEnvironment.staging,
          apiBaseUrl: 'https://staging.example.com',
          firebaseProjectId: AppEnvironmentConfig.canonicalFirebaseProjectId,
          firebaseAppId: AppEnvironmentConfig.productionAndroidFirebaseAppId,
          googleServerClientId: '',
        );

        expect(
          config.startupValidationErrors(
            selectedFlavor: 'staging',
            platform: TargetPlatform.android,
            requireProviders: false,
          ),
          contains('Firebase app ID does not match the selected flavor.'),
        );
        expect(
          config.startupValidationErrors(
            selectedFlavor: 'staging',
            platform: TargetPlatform.iOS,
            requireProviders: false,
          ),
          contains('Firebase app ID does not match the selected flavor.'),
        );
      },
    );

    test('startup rejects missing or unsupported flavor', () {
      const config = AppEnvironmentConfig(
        environment: CareNetEnvironment.staging,
        apiBaseUrl: 'https://staging.example.com',
        firebaseProjectId: AppEnvironmentConfig.canonicalFirebaseProjectId,
        firebaseAppId: AppEnvironmentConfig.stagingAndroidFirebaseAppId,
        googleServerClientId: '',
      );

      expect(
        config.startupValidationErrors(
          selectedFlavor: null,
          platform: TargetPlatform.android,
          requireProviders: false,
        ),
        contains('A supported staging or production build flavor is required.'),
      );
    });

    test('production startup rejects staging and local API hosts', () {
      for (final apiBaseUrl in [
        'https://staging.example.com',
        'http://localhost:8080',
      ]) {
        final config = AppEnvironmentConfig(
          environment: CareNetEnvironment.production,
          apiBaseUrl: apiBaseUrl,
          firebaseProjectId: AppEnvironmentConfig.canonicalFirebaseProjectId,
          firebaseAppId: AppEnvironmentConfig.productionAndroidFirebaseAppId,
          googleServerClientId: '',
        );

        expect(
          config.startupValidationErrors(
            selectedFlavor: 'production',
            platform: TargetPlatform.android,
            requireProviders: false,
          ),
          contains('Production cannot use a staging or local API endpoint.'),
        );
      }
    });

    test('startup rejects API URLs with credentials, query, or fragment', () {
      const config = AppEnvironmentConfig(
        environment: CareNetEnvironment.staging,
        apiBaseUrl: 'https://user:password@staging.example.com/api?key=x#part',
        firebaseProjectId: AppEnvironmentConfig.canonicalFirebaseProjectId,
        firebaseAppId: AppEnvironmentConfig.stagingAndroidFirebaseAppId,
        googleServerClientId: '',
      );

      expect(
        config.startupValidationErrors(
          selectedFlavor: 'staging',
          platform: TargetPlatform.android,
          requireProviders: false,
        ),
        contains(
          'CARENET_API_BASE_URL cannot contain credentials, a query, or a fragment.',
        ),
      );
    });
  });
}
