enum AuthFailureType {
  missingConfiguration,
  invalidCredentials,
  validation,
  unauthorized,
  forbidden,
  network,
  server,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure({
    required this.type,
    required this.message,
    this.statusCode,
  });

  final AuthFailureType type;
  final String message;
  final int? statusCode;

  bool get shouldClearSession => type == AuthFailureType.unauthorized;

  @override
  String toString() => message;
}
