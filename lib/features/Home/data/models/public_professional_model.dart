import '../../domain/entities/public_professional.dart';
import 'consultation_price_model.dart';

class PublicProfessionalModel extends PublicProfessional {
  const PublicProfessionalModel({
    required super.id,
    required super.displayName,
    required super.category,
    super.specialty,
    super.bio,
    required super.verified,
    super.bookable,
    super.consultationPrice,
  });

  factory PublicProfessionalModel.fromJson(Map<String, dynamic> json) {
    return PublicProfessionalModel(
      id: (json['id'] as String?) ?? '',
      displayName: (json['displayName'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      specialty: json['specialty'] as String?,
      bio: json['bio'] as String?,
      verified: json['verified'] == true,
      bookable: json['bookable'] == true,
      consultationPrice: ConsultationPriceModel.fromNullableJson(
        json['consultationPrice'],
      ),
    );
  }
}
