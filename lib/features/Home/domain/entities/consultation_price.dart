class ConsultationPrice {
  const ConsultationPrice({
    required this.amountMinor,
    required this.currency,
    this.updatedAt,
  });

  final int amountMinor;
  final String currency;
  final DateTime? updatedAt;

  bool get isValidNgn => currency == 'NGN' && amountMinor > 0;
}
