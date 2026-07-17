import '../../domain/entities/patient_profile.dart';

class PatientProfileModel extends PatientProfile {
  const PatientProfileModel({
    super.id,
    required super.name,
    super.age,
    super.location,
    super.dateOfBirth,
    super.city,
    super.state,
    super.country,
    super.healthInterests,
  });

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    return PatientProfileModel(
      id: json['id'] as String?,
      name: (json['name'] as String?) ?? '',
      age: json['age'] is int ? json['age'] as int : null,
      location: json['location'] as String?,
      dateOfBirth: _parseDate(json['dateOfBirth']),
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      healthInterests: json['healthInterests'] as String?,
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
