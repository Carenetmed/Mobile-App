import '../../domain/entities/consultation_price.dart';

class ConsultationPriceModel extends ConsultationPrice {
  const ConsultationPriceModel({
    required super.amountMinor,
    required super.currency,
    super.updatedAt,
  });

  static ConsultationPriceModel? fromNullableJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      return null;
    }
    final amount = _asInt(value['amountMinor']);
    final currency = value['currency'] as String? ?? '';
    if (amount <= 0 || currency.isEmpty) {
      return null;
    }
    return ConsultationPriceModel(
      amountMinor: amount,
      currency: currency,
      updatedAt: _asDateTime(value['updatedAt']),
    );
  }

  static int _asInt(Object? value) {
    return switch (value) {
      int parsed => parsed,
      num parsed => parsed.toInt(),
      String text => int.tryParse(text) ?? 0,
      _ => 0,
    };
  }

  static DateTime? _asDateTime(Object? value) {
    return value is String ? DateTime.tryParse(value) : null;
  }
}
