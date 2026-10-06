import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/google_sign_in_provider.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_email.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:flutter/material.dart';

/// Compatibility wrapper for legacy callers of the retired phone signup.
///
/// CareNet has no phone/SMS authentication contract, so this entry point
/// delegates to the supported email and Google signup experience.
class SignUpPhone extends StatelessWidget {
  const SignUpPhone({
    super.key,
    this.authRepository,
    this.googleIdTokenProvider,
    this.onboardingRepository,
  });

  final AuthRepository? authRepository;
  final GoogleIdTokenProvider? googleIdTokenProvider;
  final OnboardingRepository? onboardingRepository;

  @override
  Widget build(BuildContext context) {
    return SignUpEmail(
      authRepository: authRepository,
      googleIdTokenProvider: googleIdTokenProvider,
      onboardingRepository: onboardingRepository,
    );
  }
}
