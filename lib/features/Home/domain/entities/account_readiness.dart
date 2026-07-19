class AccountReadiness {
  const AccountReadiness({
    required this.account,
    this.patient,
    this.professional,
    required this.nextAction,
    required this.requiredActions,
  });

  final ReadinessAccount account;
  final PatientReadiness? patient;
  final ProfessionalReadiness? professional;
  final String nextAction;
  final List<String> requiredActions;
}

class ReadinessAccount {
  const ReadinessAccount({
    required this.role,
    required this.status,
    required this.emailVerified,
  });

  final String role;
  final String status;
  final bool emailVerified;
}

class PatientReadiness {
  const PatientReadiness({
    required this.profileStatus,
    required this.requiredFields,
  });

  final String profileStatus;
  final List<String> requiredFields;
}

class ProfessionalReadiness {
  const ProfessionalReadiness({
    required this.applicationStatus,
    required this.verificationStatus,
    this.countryCode,
    this.professionCode,
    this.regulatorCode,
    required this.requiredProfileFields,
    required this.requiredEvidence,
    required this.missingEvidence,
  });

  final String applicationStatus;
  final String verificationStatus;
  final String? countryCode;
  final String? professionCode;
  final String? regulatorCode;
  final List<String> requiredProfileFields;
  final List<String> requiredEvidence;
  final List<String> missingEvidence;
}
