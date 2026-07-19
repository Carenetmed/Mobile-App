import '../../domain/entities/account_readiness.dart';

class AccountReadinessModel extends AccountReadiness {
  const AccountReadinessModel({
    required super.account,
    super.patient,
    super.professional,
    required super.nextAction,
    required super.requiredActions,
  });

  factory AccountReadinessModel.fromJson(Map<String, dynamic> json) {
    return AccountReadinessModel(
      account: ReadinessAccountModel.fromJson(
        (json['account'] as Map<String, dynamic>?) ?? const <String, dynamic>{},
      ),
      patient:
          json['patient'] is Map<String, dynamic>
              ? PatientReadinessModel.fromJson(
                json['patient'] as Map<String, dynamic>,
              )
              : null,
      professional:
          json['professional'] is Map<String, dynamic>
              ? ProfessionalReadinessModel.fromJson(
                json['professional'] as Map<String, dynamic>,
              )
              : null,
      nextAction: (json['nextAction'] as String?) ?? '',
      requiredActions:
          (json['requiredActions'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const <String>[],
    );
  }
}

class ReadinessAccountModel extends ReadinessAccount {
  const ReadinessAccountModel({
    required super.role,
    required super.status,
    required super.emailVerified,
  });

  factory ReadinessAccountModel.fromJson(Map<String, dynamic> json) {
    return ReadinessAccountModel(
      role: (json['role'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      emailVerified: (json['emailVerified'] as bool?) ?? false,
    );
  }
}

class PatientReadinessModel extends PatientReadiness {
  const PatientReadinessModel({
    required super.profileStatus,
    required super.requiredFields,
  });

  factory PatientReadinessModel.fromJson(Map<String, dynamic> json) {
    return PatientReadinessModel(
      profileStatus: (json['profileStatus'] as String?) ?? '',
      requiredFields: _stringList(json['requiredFields']),
    );
  }
}

class ProfessionalReadinessModel extends ProfessionalReadiness {
  const ProfessionalReadinessModel({
    required super.applicationStatus,
    required super.verificationStatus,
    super.countryCode,
    super.professionCode,
    super.regulatorCode,
    required super.requiredProfileFields,
    required super.requiredEvidence,
    required super.missingEvidence,
  });

  factory ProfessionalReadinessModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalReadinessModel(
      applicationStatus: (json['applicationStatus'] as String?) ?? '',
      verificationStatus: (json['verificationStatus'] as String?) ?? '',
      countryCode: json['countryCode'] as String?,
      professionCode: json['professionCode'] as String?,
      regulatorCode: json['regulatorCode'] as String?,
      requiredProfileFields: _stringList(json['requiredProfileFields']),
      requiredEvidence: _stringList(json['requiredEvidence']),
      missingEvidence: _stringList(json['missingEvidence']),
    );
  }
}

List<String> _stringList(Object? value) {
  return (value as List<dynamic>?)?.whereType<String>().toList(
        growable: false,
      ) ??
      const <String>[];
}
