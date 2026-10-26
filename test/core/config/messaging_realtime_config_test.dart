import 'package:app_t/core/config/messaging_realtime_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const host = MessagingRealtimeConfig.stagingHost;
  const approved = 'wss://$host/messaging';

  group('MessagingRealtimeConfig', () {
    for (final environment in ['staging', 'production', '', 'unknown']) {
      for (final url in ['', '  \t\n']) {
        test('blank URL disables transport for $environment ${url.length}', () {
          final config = MessagingRealtimeConfig(
            environment: environment,
            url: url,
          );
          expect(config.validationErrors(), isEmpty);
          expect(config.endpoint, isNull);
        });
      }
    }

    for (final url in [approved, 'wss://$host:443/messaging']) {
      test('accepts approved endpoint $url', () {
        final config = MessagingRealtimeConfig(
          environment: 'staging',
          url: url,
        );
        expect(config.validationErrors(), isEmpty);
        expect(config.endpoint, Uri.parse(url));
        expect(config.endpoint!.host, host);
        expect(config.endpoint!.path, '/messaging');
      });
    }

    for (final environment in [
      'production',
      '',
      'unknown',
      'Staging',
      'STAGING',
      ' staging',
      'staging ',
    ]) {
      test('rejects unsupported exact environment "$environment"', () {
        final config = MessagingRealtimeConfig(
          environment: environment,
          url: approved,
        );
        expect(config.validationErrors(), isNotEmpty);
        expect(config.endpoint, isNull);
      });
    }

    for (final url in [
      'https://$host/messaging',
      'http://$host/messaging',
      'ws://$host/messaging',
      '//$host/messaging',
      '/messaging',
      'not a URI',
      'wss://[invalid/messaging',
      'wss://$host:invalid/messaging',
      'wss://$host:444/messaging',
      'wss://$host:80/messaging',
      'wss://$host:0/messaging',
      'wss://$host:65536/messaging',
      'wss://$host:/messaging',
      'wss://$host:0443/messaging',
      'wss://localhost/messaging',
      'wss://127.0.0.1/messaging',
      'wss://api.carenet.app/messaging',
      'wss://carenet-staging-mobile-gateway-7ncephib.uc.gateway.dev/messaging',
      'wss://$host.attacker.example/messaging',
      'wss://attacker.$host/messaging',
      'wss://$host./messaging',
      'wss://user:password@$host/messaging',
      'wss://@$host/messaging',
      'wss://$host@attacker.example/messaging',
      'wss://attacker.example@$host/messaging',
      'wss://$host',
      'wss://$host/',
      'wss://$host/Messaging',
      '$approved/',
      '$approved/extra',
      'wss://$host//messaging',
      'wss://$host/./messaging',
      'wss://$host/other/../messaging',
      'wss://$host/%6dessaging',
      'wss://$host/messag%69ng',
      'wss://$host/%2fmessaging',
      'wss://$host/%252fmessaging',
      'wss://$host/%2e/messaging',
      '$approved?',
      '$approved?token=secret',
      '$approved#',
      '$approved#fragment',
      ' $approved',
      '$approved ',
      '$approved\n',
      'wss://$host\\messaging',
    ]) {
      test(
        'rejects alternate or malicious URL ${Uri.encodeComponent(url)}',
        () {
          final config = MessagingRealtimeConfig(
            environment: 'staging',
            url: url,
          );
          expect(config.validationErrors(), isNotEmpty);
          expect(config.endpoint, isNull);
        },
      );
    }

    test('factory reads only explicit compile-time messaging settings', () {
      final config = MessagingRealtimeConfig.fromEnvironment();
      expect(
        config.environment,
        const String.fromEnvironment('CARENET_ENVIRONMENT'),
      );
      expect(
        config.url,
        const String.fromEnvironment('CARENET_MESSAGING_WS_URL'),
      );
      if (config.url.trim().isEmpty) {
        expect(config.endpoint, isNull);
        expect(config.validationErrors(), isEmpty);
      }
    });
  });
}
