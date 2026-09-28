class VerificationUploadRequest {
  const VerificationUploadRequest({
    required this.documentType,
    required this.originalFileName,
    required this.mimeType,
    required this.fileBytes,
    this.fileSizeBytes,
    this.onProgress,
    this.controller,
  });

  final String documentType;
  final String originalFileName;
  final String mimeType;
  final List<int> fileBytes;
  final int? fileSizeBytes;
  final void Function(double progress)? onProgress;
  final VerificationUploadController? controller;
}

class VerificationUploadController {
  bool _isCancelled = false;
  void Function()? _cancelActiveRequest;

  bool get isCancelled => _isCancelled;

  void cancel() {
    if (_isCancelled) {
      return;
    }
    _isCancelled = true;
    _cancelActiveRequest?.call();
  }

  void bind(void Function() cancelActiveRequest) {
    _cancelActiveRequest = cancelActiveRequest;
    if (_isCancelled) {
      cancelActiveRequest();
    }
  }

  void unbind() {
    _cancelActiveRequest = null;
  }
}
