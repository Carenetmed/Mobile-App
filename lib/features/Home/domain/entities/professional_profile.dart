import 'consultation_price.dart';

class ProfessionalProfile {
  const ProfessionalProfile({
    this.id,
    this.legalName,
    required this.displayName,
    required this.category,
    this.specialty,
    this.bio,
    this.verificationStatus,
    this.licenseNumber,
    this.licensingCouncil,
    this.qualifications,
    this.yearsOfExperience,
    this.practiceName,
    this.practiceAddress,
    this.practiceCity,
    this.practiceState,
    this.practiceCountry,
    this.consultationPrice,
  });

  final String? id;
  final String? legalName;
  final String displayName;
  final String category;
  final String? specialty;
  final String? bio;
  final String? verificationStatus;
  final String? licenseNumber;
  final String? licensingCouncil;
  final String? qualifications;
  final int? yearsOfExperience;
  final String? practiceName;
  final String? practiceAddress;
  final String? practiceCity;
  final String? practiceState;
  final String? practiceCountry;
  final ConsultationPrice? consultationPrice;
}
