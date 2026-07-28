import 'consultation_price.dart';

class PublicProfessional {
  const PublicProfessional({
    required this.id,
    required this.displayName,
    required this.category,
    this.specialty,
    this.bio,
    required this.verified,
    this.bookable = false,
    this.consultationPrice,
  });

  final String id;
  final String displayName;
  final String category;
  final String? specialty;
  final String? bio;
  final bool verified;
  final bool bookable;
  final ConsultationPrice? consultationPrice;
}
