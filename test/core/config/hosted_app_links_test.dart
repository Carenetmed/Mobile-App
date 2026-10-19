import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hosted Android associations trust only the matching release keys', () {
    final associations =
        jsonDecode(
              File(
                'hosting/public/.well-known/assetlinks.json',
              ).readAsStringSync(),
            )
            as List<dynamic>;
    const certificates = <String, String>{
      'com.carenet.app.staging':
          '0D:7E:7F:2F:B1:A0:DA:0B:3D:39:2B:0E:B5:42:41:1D:DC:85:90:F6:EA:9E:61:FB:EC:9F:3D:73:69:24:C1:52',
      'com.carenet.app':
          '2C:D8:56:CE:E0:8C:C7:8D:FF:B4:8E:EB:96:C6:56:A3:E3:2D:15:57:20:71:75:95:28:2F:05:D9:9E:96:A1:13',
    };
    expect(
      associations,
      unorderedEquals([
        for (final entry in certificates.entries)
          {
            'relation': ['delegate_permission/common.handle_all_urls'],
            'target': {
              'namespace': 'android_app',
              'package_name': entry.key,
              'sha256_cert_fingerprints': [entry.value],
            },
          },
      ]),
    );
    final signingPolicy =
        File('docs/ANDROID_RELEASE_SIGNING.md').readAsStringSync();
    for (final certificate in certificates.values) {
      expect(signingPolicy, contains(certificate.replaceAll(':', '')));
    }
  });

  test(
    'Hosting serves the static association with JSON and bounded caching',
    () {
      final config =
          jsonDecode(File('firebase.json').readAsStringSync())
              as Map<String, dynamic>;
      final hosting = config['hosting'] as Map<String, dynamic>;
      expect(hosting['public'], 'hosting/public');
      expect(hosting['redirects'], isNull);
      expect(hosting['rewrites'], isNull);
      final headers = (hosting['headers'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .singleWhere(
            (rule) => rule['source'] == '/.well-known/assetlinks.json',
          );
      expect(
        headers['headers'],
        containsAll([
          {'key': 'Content-Type', 'value': 'application/json'},
          {'key': 'Cache-Control', 'value': 'public, max-age=300'},
        ]),
      );
      for (final page in ['reset-password', 'verify-email']) {
        expect(File('hosting/public/$page/index.html').existsSync(), isTrue);
      }
    },
  );
}
