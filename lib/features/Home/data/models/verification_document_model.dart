import '../../domain/entities/verification_document.dart';

class VerificationDocumentModel extends VerificationDocument {
  const VerificationDocumentModel({
    required super.id,
    required super.documentType,
    required super.status,
    required super.storageProvider,
    required super.mimeType,
    super.fileSizeBytes,
    required super.checksumProvided,
    super.uploadedAt,
  });

  factory VerificationDocumentModel.fromJson(Map<String, dynamic> json) {
    return VerificationDocumentModel(
      id: json['id'] as String? ?? '',
      documentType: json['documentType'] as String? ?? '',
      status: json['status'] as String? ?? '',
      storageProvider: json['storageProvider'] as String? ?? '',
      mimeType: json['mimeType'] as String? ?? '',
      fileSizeBytes: json['fileSizeBytes'] as int?,
      checksumProvided: json['checksumProvided'] as bool? ?? false,
      uploadedAt: _parseDate(json['uploadedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}

class VerificationUploadInitModel {
  const VerificationUploadInitModel({
    required this.document,
    required this.signedUploadUrl,
    required this.expiresInSeconds,
  });

  factory VerificationUploadInitModel.fromJson(Map<String, dynamic> json) {
    final documentJson = json['document'];
    final uploadJson = json['upload'];
    return VerificationUploadInitModel(
      document: VerificationDocumentModel.fromJson(
        documentJson is Map<String, dynamic>
            ? documentJson
            : const <String, dynamic>{},
      ),
      signedUploadUrl:
          uploadJson is Map<String, dynamic>
              ? uploadJson['signedUrl'] as String? ?? ''
              : '',
      expiresInSeconds:
          uploadJson is Map<String, dynamic>
              ? uploadJson['expiresInSeconds'] as int? ?? 0
              : 0,
    );
  }

  final VerificationDocumentModel document;
  final String signedUploadUrl;
  final int expiresInSeconds;
}
