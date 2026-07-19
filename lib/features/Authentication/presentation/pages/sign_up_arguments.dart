import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/google_sign_in_provider.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';

enum SignUpRole {
  patient,
  professional;

  String get backendValue {
    switch (this) {
      case SignUpRole.patient:
        return 'PATIENT';
      case SignUpRole.professional:
        return 'PROFESSIONAL';
    }
  }

  String get title {
    switch (this) {
      case SignUpRole.patient:
        return 'Patient';
      case SignUpRole.professional:
        return 'Professional';
    }
  }
}

class SignUpRoleSelectionArgs {
  const SignUpRoleSelectionArgs({
    this.initialEmail,
    this.googleSignUp = false,
    this.authRepository,
    this.googleIdTokenProvider,
    this.onboardingRepository,
  });

  final String? initialEmail;
  final bool googleSignUp;
  final AuthRepository? authRepository;
  final GoogleIdTokenProvider? googleIdTokenProvider;
  final OnboardingRepository? onboardingRepository;
}

class FinishSignUpArgs {
  const FinishSignUpArgs({
    this.initialEmail,
    required this.role,
    this.onboardingRepository,
  });

  final String? initialEmail;
  final SignUpRole role;
  final OnboardingRepository? onboardingRepository;
}
