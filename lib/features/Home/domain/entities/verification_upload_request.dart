class VerificationUploadRequest {
  const VerificationUploadRequest({
    required this.documentType,
    required this.originalFileName,
    required this.mimeType,
    required this.fileBytes,
    this.fileSizeBytes,
    this.checksumSha256,
  });

  final String documentType;
  final String originalFileName;
  final String mimeType;
  final List<int> fileBytes;
  final int? fileSizeBytes;
  final String? checksumSha256;
}
