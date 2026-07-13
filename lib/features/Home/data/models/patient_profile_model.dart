import '../../domain/entities/patient_profile.dart';

class PatientProfileModel extends PatientProfile {
  const PatientProfileModel({
    super.id,
    required super.name,
    super.age,
    super.location,
  });

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    return PatientProfileModel(
      id: json['id'] as String?,
      name: (json['name'] as String?) ?? '',
      age: json['age'] is int ? json['age'] as int : null,
      location: json['location'] as String?,
    );
  }
}
