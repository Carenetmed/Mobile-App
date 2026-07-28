class PaymentCheckoutIntent {
  const PaymentCheckoutIntent({
    required this.appointmentId,
    required this.accountUserId,
    required this.idempotencyKey,
    required this.createdAt,
    required this.expiresAt,
  });

  final String appointmentId;
  final String accountUserId;
  final String idempotencyKey;
  final DateTime createdAt;
  final DateTime expiresAt;

  bool isExpired(DateTime now) => !expiresAt.isAfter(now.toUtc());

  Map<String, dynamic> toJson() => <String, dynamic>{
    'appointmentId': appointmentId,
    'accountUserId': accountUserId,
    'idempotencyKey': idempotencyKey,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'expiresAt': expiresAt.toUtc().toIso8601String(),
  };

  factory PaymentCheckoutIntent.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '');
    final expiresAt = DateTime.tryParse(json['expiresAt'] as String? ?? '');
    final intent = PaymentCheckoutIntent(
      appointmentId: json['appointmentId'] as String? ?? '',
      accountUserId: json['accountUserId'] as String? ?? '',
      idempotencyKey: json['idempotencyKey'] as String? ?? '',
      createdAt:
          createdAt?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      expiresAt:
          expiresAt?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
    if (intent.appointmentId.isEmpty ||
        intent.accountUserId.isEmpty ||
        intent.idempotencyKey.isEmpty ||
        !intent.expiresAt.isAfter(intent.createdAt)) {
      throw const FormatException('Invalid payment checkout intent.');
    }
    return intent;
  }
}
