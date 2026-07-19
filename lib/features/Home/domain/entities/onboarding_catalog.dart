class OnboardingCatalog {
  const OnboardingCatalog({
    required this.launchCountry,
    required this.countries,
    required this.nigeriaStates,
    required this.professionalCatalog,
    required this.verificationEvidenceTypes,
    required this.patientHealthInterestCatalog,
  });

  final String launchCountry;
  final List<OnboardingCountry> countries;
  final List<OnboardingRegion> nigeriaStates;
  final List<ProfessionalCatalogItem> professionalCatalog;
  final List<VerificationEvidenceType> verificationEvidenceTypes;
  final List<PatientHealthInterest> patientHealthInterestCatalog;
}

class OnboardingCountry {
  const OnboardingCountry({
    required this.code,
    required this.name,
    required this.status,
  });

  final String code;
  final String name;
  final String status;
}

class OnboardingRegion {
  const OnboardingRegion({required this.code, required this.name});

  final String code;
  final String name;
}

class ProfessionalCatalogItem {
  const ProfessionalCatalogItem({
    required this.code,
    required this.label,
    required this.regulatorCode,
    required this.regulatorName,
    required this.requiredEvidence,
  });

  final String code;
  final String label;
  final String regulatorCode;
  final String regulatorName;
  final List<String> requiredEvidence;
}

class VerificationEvidenceType {
  const VerificationEvidenceType({
    required this.code,
    required this.label,
    required this.documentType,
  });

  final String code;
  final String label;
  final String documentType;
}

class PatientHealthInterest {
  const PatientHealthInterest({required this.code, required this.label});

  final String code;
  final String label;
}
