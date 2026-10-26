class MessagingRealtimeConfig {
  const MessagingRealtimeConfig({required this.environment, required this.url});

  factory MessagingRealtimeConfig.fromEnvironment() =>
      const MessagingRealtimeConfig(
        environment: String.fromEnvironment('CARENET_ENVIRONMENT'),
        url: String.fromEnvironment('CARENET_MESSAGING_WS_URL'),
      );

  static const String stagingHost =
      'carenet-messaging-staging-tkgduhftha-el.a.run.app';

  final String environment;
  final String url;

  Uri? get endpoint =>
      url.trim().isEmpty || validationErrors().isNotEmpty
          ? null
          : Uri.parse(url);

  List<String> validationErrors() {
    if (url.trim().isEmpty) return <String>[];

    final errors = <String>[];
    if (environment != 'staging') {
      errors.add(
        'CARENET_MESSAGING_WS_URL is only approved for exact staging environment.',
      );
    }

    // Check the raw spelling as well: URI parsing can normalize alternate paths.
    if (url != 'wss://$stagingHost/messaging' &&
        url != 'wss://$stagingHost:443/messaging') {
      errors.add(
        'CARENET_MESSAGING_WS_URL must use the registered staging WSS '
        'host, port 443, and exact /messaging path without credentials, '
        'query, fragment, or encoding.',
      );
    }
    return errors;
  }
}
