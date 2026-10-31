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
    this.expiresAt,
  }) : requiredHeaders = const <String, String>{};

  VerificationUploadInitModel._({
    required this.document,
    required this.signedUploadUrl,
    required this.expiresInSeconds,
    required this.expiresAt,
    required Map<String, String> requiredHeaders,
  }) : requiredHeaders = Map<String, String>.unmodifiable(requiredHeaders);

  factory VerificationUploadInitModel.fromJson(Map<String, dynamic> json) {
    final documentJson = json['document'];
    final uploadJson = json['upload'];
    final document = VerificationDocumentModel.fromJson(
      documentJson is Map<String, dynamic>
          ? documentJson
          : const <String, dynamic>{},
    );
    final upload =
        uploadJson is Map<String, dynamic>
            ? uploadJson
            : const <String, dynamic>{};
    final seconds = upload['expiresInSeconds'];
    if (upload.containsKey('expiresInSeconds') &&
        (seconds is! int || seconds <= 0)) {
      throw const FormatException('Invalid upload expiry duration');
    }
    DateTime? expiresAt;
    final headers = <String, String>{};
    if (upload.containsKey('expiresAt') ||
        upload.containsKey('requiredHeaders')) {
      final expiry = upload['expiresAt'];
      final rawHeaders = upload['requiredHeaders'];
      if (expiry is! String ||
          !RegExp(
            r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?Z$',
          ).hasMatch(expiry) ||
          rawHeaders is! Map) {
        throw const FormatException('Incomplete upload metadata');
      }
      expiresAt = DateTime.tryParse(expiry);
      // DateTime parsing normalizes invalid calendar dates; reject those too.
      if (expiresAt == null ||
          !expiresAt.isUtc ||
          expiresAt.toIso8601String().substring(0, 19) !=
              expiry.substring(0, 19)) {
        throw const FormatException('Invalid absolute upload expiry');
      }
      const allowed = <String>{
        'content-type',
        'content-length',
        'x-goog-if-generation-match',
      };
      for (final entry in rawHeaders.entries) {
        final key = entry.key;
        final value = entry.value;
        if (key is! String || value is! String) {
          throw const FormatException('Invalid upload header type');
        }
        final name = key.toLowerCase();
        if (!allowed.contains(name) || headers.containsKey(name)) {
          throw const FormatException('Unsupported or duplicate upload header');
        }
        headers[name] = value;
      }
      final mime = headers['content-type'];
      final length = headers['content-length'];
      final size = length == null ? null : int.tryParse(length);
      if (headers.length != 3 ||
          !const {
            'application/pdf',
            'image/jpeg',
            'image/png',
          }.contains(mime) ||
          length == null ||
          !RegExp(r'^[0-9]+$').hasMatch(length) ||
          size == null ||
          size <= 0 ||
          headers['x-goog-if-generation-match'] != '0' ||
          (documentJson is Map &&
              documentJson.containsKey('mimeType') &&
              document.mimeType != mime) ||
          (documentJson is Map &&
              documentJson.containsKey('fileSizeBytes') &&
              document.fileSizeBytes != size)) {
        throw const FormatException('Invalid upload header contract');
      }
    }
    return VerificationUploadInitModel._(
      document: document,
      expiresAt: expiresAt,
      requiredHeaders: headers,
      signedUploadUrl:
          uploadJson is Map<String, dynamic>
              ? uploadJson['signedUrl'] as String? ?? ''
              : '',
      expiresInSeconds: seconds as int? ?? 0,
    );
  }

  final VerificationDocumentModel document;
  final String signedUploadUrl;
  final int expiresInSeconds;
  final DateTime? expiresAt;
  final Map<String, String> requiredHeaders;
}
