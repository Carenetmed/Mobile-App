class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    required this.emailVerified,
  });

  final String id;
  final String email;
  final String role;
  final String status;
  final bool emailVerified;
}
