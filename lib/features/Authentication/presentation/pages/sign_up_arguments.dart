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
  const SignUpRoleSelectionArgs({this.initialEmail});

  final String? initialEmail;
}

class FinishSignUpArgs {
  const FinishSignUpArgs({this.initialEmail, required this.role});

  final String? initialEmail;
  final SignUpRole role;
}
