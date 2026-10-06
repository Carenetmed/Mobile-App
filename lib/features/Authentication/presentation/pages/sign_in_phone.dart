import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/google_sign_in_provider.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_in_email.dart';
import 'package:flutter/material.dart';

/// Compatibility wrapper for callers that still construct the legacy screen.
/// Phone authentication is not supported; use the canonical email sign-in.
class SignInPhone extends StatelessWidget {
  const SignInPhone({
    super.key,
    this.authRepository,
    this.googleIdTokenProvider,
  });

  final AuthRepository? authRepository;
  final GoogleIdTokenProvider? googleIdTokenProvider;

  @override
  Widget build(BuildContext context) {
    return SignInEmail(
      authRepository: authRepository,
      googleIdTokenProvider: googleIdTokenProvider,
    );
  }
}
