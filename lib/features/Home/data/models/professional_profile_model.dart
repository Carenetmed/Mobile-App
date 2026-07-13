import '../../domain/entities/professional_profile.dart';

class ProfessionalProfileModel extends ProfessionalProfile {
  const ProfessionalProfileModel({
    super.id,
    required super.displayName,
    required super.category,
    super.specialty,
    super.bio,
    super.verificationStatus,
  });

  factory ProfessionalProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalProfileModel(
      id: json['id'] as String?,
      displayName: (json['displayName'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      specialty: json['specialty'] as String?,
      bio: json['bio'] as String?,
      verificationStatus: json['verificationStatus'] as String?,
    );
  }
}
