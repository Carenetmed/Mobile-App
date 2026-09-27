import 'package:app_t/core/config/carenet_public_links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('public links use the canonical Firebase Hosting origin', () {
    for (final uri in <Uri>[
      CareNetPublicLinks.terms,
      CareNetPublicLinks.privacy,
      CareNetPublicLinks.support,
      CareNetPublicLinks.accountDeletion,
    ]) {
      expect(uri.scheme, 'https');
      expect(uri.host, CareNetPublicLinks.host);
      expect(uri.query, isEmpty);
    }
  });
}
