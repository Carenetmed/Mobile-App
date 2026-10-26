import 'package:app_t/core/config/app_environment.dart';
import 'package:app_t/core/config/messaging_realtime_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppEnvironmentConfig', () {
    AppEnvironmentConfig messagingConfig(
      String url, {
      CareNetEnvironment environment = CareNetEnvironment.staging,
    }) => AppEnvironmentConfig(
      environment: environment,
      apiBaseUrl: 'https://${AppEnvironmentConfig.canonicalStagingApiHost}',
      firebaseProjectId: AppEnvironmentConfig.canonicalFirebaseProjectId,
      firebaseAppId: AppEnvironmentConfig.stagingAndroidFirebaseAppId,
      googleServerClientId: '',
      messagingWsUrl: url,
    );

    test('messaging URL is optional and is never derived from HTTP', () {
      for (final url in ['', ' \t\n']) {
        final config = messagingConfig(url);
        expect(config.messagingWsUrl, url);
        expect(config.validationErrors(requireProviders: false), isEmpty);
      }
    });

    test('accepts explicit approved staging messaging at startup', () {
      final config = messagingConfig(
        'wss://${MessagingRealtimeConfig.stagingHost}/messaging',
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

    for (final url in [
      'https://${MessagingRealtimeConfig.stagingHost}/messaging',
      'wss://attacker.example/messaging',
      'wss://${MessagingRealtimeConfig.stagingHost}/%6dessaging',
      'wss://${MessagingRealtimeConfig.stagingHost}/messaging?token=x',
    ]) {
      test('startup includes messaging validation for $url', () {
        final config = messagingConfig(url);
        final errors =
            MessagingRealtimeConfig(
              environment: 'staging',
              url: url,
            ).validationErrors();
        expect(errors, isNotEmpty);
        expect(config.validationErrors(requireProviders: false), errors);
        expect(
          () => config.validateForStartup(
            selectedFlavor: 'staging',
            platform: TargetPlatform.android,
            requireProviders: false,
          ),
          throwsStateError,
        );
      });
    }

    test('messaging rejection preserves all existing validation errors', () {
      const baseline = AppEnvironmentConfig(
        environment: CareNetEnvironment.production,
        apiBaseUrl: 'http://wrong.example',
        firebaseProjectId: '',
        firebaseAppId: '',
        googleServerClientId: '',
      );
      const withMessaging = AppEnvironmentConfig(
        environment: CareNetEnvironment.production,
        apiBaseUrl: 'http://wrong.example',
        firebaseProjectId: '',
        firebaseAppId: '',
        googleServerClientId: '',
        messagingWsUrl:
            'wss://${MessagingRealtimeConfig.stagingHost}/messaging',
      );
      expect(baseline.messagingWsUrl, '');
      final baselineErrors = baseline.validationErrors(requireProviders: true);
      expect(baselineErrors, hasLength(5));
      expect(withMessaging.validationErrors(requireProviders: true), [
        ...baselineErrors,
        ...const MessagingRealtimeConfig(
          environment: 'production',
          url: 'wss://${MessagingRealtimeConfig.stagingHost}/messaging',
        ).validationErrors(),
      ]);
    });

    test('factory reads the explicit messaging define', () {
      const environment = String.fromEnvironment('CARENET_ENVIRONMENT');
      if (![
        'staging',
        'production',
      ].contains(environment.trim().toLowerCase())) {
        expect(AppEnvironmentConfig.fromEnvironment, throwsFormatException);
        return;
      }
      expect(
        AppEnvironmentConfig.fromEnvironment().messagingWsUrl,
        const String.fromEnvironment('CARENET_MESSAGING_WS_URL'),
      );
    });

    test('accepts canonical staging configuration', () {
      const config = AppEnvironmentConfig(
        environment: CareNetEnvironment.staging,
        apiBaseUrl: 'https://${AppEnvironmentConfig.canonicalStagingApiHost}',
        firebaseProjectId: AppEnvironmentConfig.canonicalFirebaseProjectId,
        firebaseAppId: 'staging-firebase-app-id',
        googleServerClientId: 'web-client-id',
      );

      expect(config.validationErrors(requireProviders: true), isEmpty);
    });

    test('rejects the discarded Firebase project', () {
      const config = AppEnvironmentConfig(
        environment: CareNetEnvironment.staging,
        apiBaseUrl: 'https://${AppEnvironmentConfig.canonicalStagingApiHost}',
        firebaseProjectId: 'carenet-175b7',
        firebaseAppId: 'wrong-project-app-id',
        googleServerClientId: 'web-client-id',
      );

      expect(
        config.validationErrors(requireProviders: true),
        contains('Firebase must use the canonical CareNet project.'),
      );
    });

    test('production requires HTTPS, a canonical host, and providers', () {
      const config = AppEnvironmentConfig(
        environment: CareNetEnvironment.production,
        apiBaseUrl: 'http://production.example.com',
        firebaseProjectId: AppEnvironmentConfig.canonicalFirebaseProjectId,
        firebaseAppId: 'production-firebase-app-id',
        googleServerClientId: '',
      );

      expect(
        config.validationErrors(requireProviders: true),
        contains('Production API host is not registered as canonical.'),
      );
    });

    test('startup accepts the registered app for the selected flavor', () {
      const config = AppEnvironmentConfig(
        environment: CareNetEnvironment.staging,
        apiBaseUrl: 'https://${AppEnvironmentConfig.canonicalStagingApiHost}',
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

    test('startup recognizes registered Android and iOS flavor app IDs', () {
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
          apiBaseUrl: 'https://${AppEnvironmentConfig.canonicalStagingApiHost}',
          firebaseProjectId: AppEnvironmentConfig.canonicalFirebaseProjectId,
          firebaseAppId: appId,
          googleServerClientId: '',
        );

        final errors = config.startupValidationErrors(
          selectedFlavor: flavor,
          platform: platform,
          requireProviders: false,
        );
        expect(
          errors,
          isNot(
            contains('Firebase app ID does not match the selected flavor.'),
          ),
        );
        if (environment == CareNetEnvironment.production) {
          expect(
            errors,
            contains('Production API host is not registered as canonical.'),
          );
        } else {
          expect(errors, isEmpty);
        }
      }
    });

    test('startup rejects environment and flavor mismatch', () {
      const config = AppEnvironmentConfig(
        environment: CareNetEnvironment.staging,
        apiBaseUrl: 'https://${AppEnvironmentConfig.canonicalStagingApiHost}',
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
          apiBaseUrl: 'https://${AppEnvironmentConfig.canonicalStagingApiHost}',
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
        apiBaseUrl: 'https://${AppEnvironmentConfig.canonicalStagingApiHost}',
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

    test('production startup fails closed without its canonical API host', () {
      for (final apiBaseUrl in [
        'https://${AppEnvironmentConfig.canonicalStagingApiHost}',
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
          contains('Production API host is not registered as canonical.'),
        );
      }
    });

    test('staging startup rejects a production API host', () {
      const config = AppEnvironmentConfig(
        environment: CareNetEnvironment.staging,
        apiBaseUrl: 'https://api.carenet.app',
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
        contains('Staging API host is not the registered CareNet gateway.'),
      );
    });

    test('staging requires HTTPS and the exact registered gateway host', () {
      for (final url in [
        'http://${AppEnvironmentConfig.canonicalStagingApiHost}',
        'https://staging.attacker.example',
      ]) {
        final config = AppEnvironmentConfig(
          environment: CareNetEnvironment.staging,
          apiBaseUrl: url,
          firebaseProjectId: AppEnvironmentConfig.canonicalFirebaseProjectId,
          firebaseAppId: AppEnvironmentConfig.stagingAndroidFirebaseAppId,
          googleServerClientId: '',
        );

        final errors = config.validationErrors(requireProviders: false);
        if (url.startsWith('http:')) {
          expect(errors, contains('CARENET_API_BASE_URL must use HTTPS.'));
        } else {
          expect(
            errors,
            contains('Staging API host is not the registered CareNet gateway.'),
          );
        }
      }
    });

    test('startup rejects API URLs with credentials, query, or fragment', () {
      const config = AppEnvironmentConfig(
        environment: CareNetEnvironment.staging,
        apiBaseUrl:
            'https://user:password@${AppEnvironmentConfig.canonicalStagingApiHost}/api?key=x#part',
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
