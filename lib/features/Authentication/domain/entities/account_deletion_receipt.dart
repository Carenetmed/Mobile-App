class AccountDeletionReceipt {
  const AccountDeletionReceipt({
    required this.accountStatus,
    required this.deletionRequestedAt,
    required this.retentionStatus,
    required this.sessionsRevoked,
  });

  factory AccountDeletionReceipt.fromJson(Map<String, dynamic> json) {
    final requestedAt = DateTime.tryParse(
      json['deletionRequestedAt'] as String? ?? '',
    );
    if (requestedAt == null) {
      throw const FormatException('Invalid account deletion receipt.');
    }
    return AccountDeletionReceipt(
      accountStatus: json['accountStatus'] as String? ?? '',
      deletionRequestedAt: requestedAt.toUtc(),
      retentionStatus: json['retentionStatus'] as String? ?? '',
      sessionsRevoked: json['sessionsRevoked'] == true,
    );
  }

  final String accountStatus;
  final DateTime deletionRequestedAt;
  final String retentionStatus;
  final bool sessionsRevoked;

  bool get isValid =>
      accountStatus == 'DELETED' &&
      retentionStatus == 'RETAINED_UNDER_POLICY' &&
      sessionsRevoked;
}
