import '../../domain/entities/onboarding_catalog.dart';

class OnboardingCatalogModel extends OnboardingCatalog {
  const OnboardingCatalogModel({
    required super.launchCountry,
    required super.countries,
    required super.nigeriaStates,
    required super.professionalCatalog,
    required super.verificationEvidenceTypes,
    required super.patientHealthInterestCatalog,
  });

  factory OnboardingCatalogModel.fromJson(Map<String, dynamic> json) {
    return OnboardingCatalogModel(
      launchCountry: (json['launchCountry'] as String?) ?? '',
      countries: _items(json['countries'], OnboardingCountryModel.fromJson),
      nigeriaStates: _items(
        json['nigeriaStates'],
        OnboardingRegionModel.fromJson,
      ),
      professionalCatalog: _items(
        json['professionalCatalog'],
        ProfessionalCatalogItemModel.fromJson,
      ),
      verificationEvidenceTypes: _items(
        json['verificationEvidenceTypes'],
        VerificationEvidenceTypeModel.fromJson,
      ),
      patientHealthInterestCatalog: _items(
        json['patientHealthInterestCatalog'],
        PatientHealthInterestModel.fromJson,
      ),
    );
  }
}

class OnboardingCountryModel extends OnboardingCountry {
  const OnboardingCountryModel({
    required super.code,
    required super.name,
    required super.status,
  });

  factory OnboardingCountryModel.fromJson(Map<String, dynamic> json) {
    return OnboardingCountryModel(
      code: (json['code'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
    );
  }
}

class OnboardingRegionModel extends OnboardingRegion {
  const OnboardingRegionModel({required super.code, required super.name});

  factory OnboardingRegionModel.fromJson(Map<String, dynamic> json) {
    return OnboardingRegionModel(
      code: (json['code'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
    );
  }
}

class ProfessionalCatalogItemModel extends ProfessionalCatalogItem {
  const ProfessionalCatalogItemModel({
    required super.code,
    required super.label,
    required super.regulatorCode,
    required super.regulatorName,
    required super.requiredEvidence,
  });

  factory ProfessionalCatalogItemModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalCatalogItemModel(
      code: (json['code'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
      regulatorCode: (json['regulatorCode'] as String?) ?? '',
      regulatorName: (json['regulatorName'] as String?) ?? '',
      requiredEvidence:
          (json['requiredEvidence'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const <String>[],
    );
  }
}

class VerificationEvidenceTypeModel extends VerificationEvidenceType {
  const VerificationEvidenceTypeModel({
    required super.code,
    required super.label,
    required super.documentType,
  });

  factory VerificationEvidenceTypeModel.fromJson(Map<String, dynamic> json) {
    return VerificationEvidenceTypeModel(
      code: (json['code'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
      documentType: (json['documentType'] as String?) ?? '',
    );
  }
}

class PatientHealthInterestModel extends PatientHealthInterest {
  const PatientHealthInterestModel({required super.code, required super.label});

  factory PatientHealthInterestModel.fromJson(Map<String, dynamic> json) {
    return PatientHealthInterestModel(
      code: (json['code'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
    );
  }
}

List<T> _items<T>(
  Object? value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  return (value as List<dynamic>?)
          ?.whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList(growable: false) ??
      <T>[];
}
