import 'package:url_launcher/url_launcher.dart';

abstract class HostedCheckoutLauncher {
  Future<bool> open(Uri uri);
}

class SystemHostedCheckoutLauncher implements HostedCheckoutLauncher {
  const SystemHostedCheckoutLauncher();

  @override
  Future<bool> open(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

bool isApprovedCheckoutUri(Uri? uri) {
  if (uri == null || uri.scheme.toLowerCase() != 'https') {
    return false;
  }
  final host = uri.host.toLowerCase();
  return host == 'checkout.paystack.com';
}
