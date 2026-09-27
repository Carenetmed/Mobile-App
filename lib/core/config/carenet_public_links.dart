import 'package:url_launcher/url_launcher.dart';

typedef PublicLinkLauncher = Future<bool> Function(Uri uri);

abstract final class CareNetPublicLinks {
  static const host = 'project-a96784ee-811c-46ab-a7b.web.app';
  static final terms = Uri.https(host, '/terms');
  static final privacy = Uri.https(host, '/privacy');
  static final support = Uri.https(host, '/support');
  static final accountDeletion = Uri.https(host, '/account-deletion');

  static Future<bool> launch(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
