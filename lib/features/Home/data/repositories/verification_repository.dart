import 'dart:isolate';

import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/verification_document.dart';
import '../../domain/entities/verification_upload_request.dart';
import '../services/verification_api_client.dart';

class VerificationRepository {
  const VerificationRepository({
    required VerificationApiClient apiClient,
    required SessionStore sessionStore,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore;

  final VerificationApiClient _apiClient;
  final SessionStore _sessionStore;

  Future<List<VerificationDocument>> documents() async {
    final current = await _requireSession();
    return _apiClient.documents(accessToken: current.accessToken);
  }

  Future<VerificationDocument> uploadDocument(
    VerificationUploadRequest request,
  ) async {
    final current = await _requireSession();
    final fileBytes = List<int>.unmodifiable(request.fileBytes);
    final fileSizeBytes = fileBytes.length;
    final controller = request.controller;
    if (controller?.isCancelled ?? false) {
      throw const VerificationUploadCancelled();
    }
    final checksumSha256 = await Isolate.run(
      () => sha256.convert(fileBytes).toString(),
    );
    if (controller?.isCancelled ?? false) {
      throw const VerificationUploadCancelled();
    }
    final init = await _apiClient.uploadInit(
      accessToken: current.accessToken,
      documentType: request.documentType,
      originalFileName: request.originalFileName,
      mimeType: request.mimeType,
      fileSizeBytes: fileSizeBytes,
    );

    final cancelToken = CancelToken();
    controller?.bind(() => cancelToken.cancel('Upload cancelled.'));
    try {
      await _apiClient.uploadBytes(
        signedUploadUrl: init.signedUploadUrl,
        fileBytes: fileBytes,
        mimeType: request.mimeType,
        cancelToken: cancelToken,
        onSendProgress: (sent, total) {
          if (total > 0) {
            request.onProgress?.call((sent / total).clamp(0, 1));
          }
        },
      );
    } on AuthFailure {
      if (cancelToken.isCancelled) {
        throw const VerificationUploadCancelled();
      }
      rethrow;
    } finally {
      controller?.unbind();
    }

    if (controller?.isCancelled ?? false) {
      throw const VerificationUploadCancelled();
    }

    return _apiClient.uploadComplete(
      accessToken: current.accessToken,
      documentId: init.document.id,
      fileSizeBytes: fileSizeBytes,
      checksumSha256: checksumSha256,
    );
  }

  Future<AuthSessionModel> _requireSession() async {
    final current = await _sessionStore.read();
    if (current == null) {
      throw const AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'Please sign in again.',
      );
    }
    return current;
  }
}

class VerificationUploadCancelled implements Exception {
  const VerificationUploadCancelled();
}
