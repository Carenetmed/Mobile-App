import '../../domain/entities/professional_profile.dart';
import 'consultation_price_model.dart';

class ProfessionalProfileModel extends ProfessionalProfile {
  const ProfessionalProfileModel({
    super.id,
    super.legalName,
    required super.displayName,
    required super.category,
    super.specialty,
    super.bio,
    super.verificationStatus,
    super.licenseNumber,
    super.licensingCouncil,
    super.qualifications,
    super.yearsOfExperience,
    super.practiceName,
    super.practiceAddress,
    super.practiceCity,
    super.practiceState,
    super.practiceCountry,
    super.professionCode,
    super.practiceCountryCode,
    super.consultationPrice,
  });

  factory ProfessionalProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalProfileModel(
      id: json['id'] as String?,
      legalName: json['legalName'] as String?,
      displayName: (json['displayName'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      specialty: json['specialty'] as String?,
      bio: json['bio'] as String?,
      verificationStatus: json['verificationStatus'] as String?,
      licenseNumber: json['licenseNumber'] as String?,
      licensingCouncil: json['licensingCouncil'] as String?,
      qualifications: json['qualifications'] as String?,
      yearsOfExperience: json['yearsOfExperience'] is int
          ? json['yearsOfExperience'] as int
          : null,
      practiceName: json['practiceName'] as String?,
      practiceAddress: json['practiceAddress'] as String?,
      practiceCity: json['practiceCity'] as String?,
      practiceState: json['practiceState'] as String?,
      practiceCountry: json['practiceCountry'] as String?,
      professionCode:
          (json['professionCode'] as String?) ??
          (json['categoryCode'] as String?),
      practiceCountryCode:
          (json['practiceCountryCode'] as String?) ??
          (json['countryCode'] as String?),
      consultationPrice: ConsultationPriceModel.fromNullableJson(
        json['consultationPrice'],
      ),
    );
  }
}
