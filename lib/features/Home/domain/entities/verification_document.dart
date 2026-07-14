class VerificationDocument {
  const VerificationDocument({
    required this.id,
    required this.documentType,
    required this.status,
    required this.storageProvider,
    required this.mimeType,
    this.fileSizeBytes,
    required this.checksumProvided,
    this.uploadedAt,
  });

  final String id;
  final String documentType;
  final String status;
  final String storageProvider;
  final String mimeType;
  final int? fileSizeBytes;
  final bool checksumProvided;
  final DateTime? uploadedAt;
}
