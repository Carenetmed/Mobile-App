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
    DateTime Function()? clock,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore,
       _clock = clock;

  final VerificationApiClient _apiClient;
  final SessionStore _sessionStore;
  final DateTime Function()? _clock;

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
    final checksumSha256 = await _checksum(fileBytes);
    if (controller?.isCancelled ?? false) {
      throw const VerificationUploadCancelled();
    }
    final beforeInit = await _sameAccount(current, controller);
    final init = await _apiClient.uploadInit(
      accessToken: beforeInit.accessToken,
      documentType: request.documentType,
      originalFileName: request.originalFileName,
      mimeType: request.mimeType,
      fileSizeBytes: fileSizeBytes,
    );

    var capability = init;
    var renewed = false;
    bool expired() =>
        capability.expiresAt != null &&
        !capability.expiresAt!.isAfter((_clock ?? DateTime.now)().toUtc());
    Future<void> renew() async {
      final session = await _sameAccount(current, controller);
      capability = await _apiClient.uploadRenew(
        accessToken: session.accessToken,
        documentId: init.document.id,
      );
      renewed = true;
      if (capability.expiresAt == null || expired()) {
        throw const AuthFailure(
          type: AuthFailureType.unknown,
          message: 'Could not renew the document upload. Please try again.',
        );
      }
    }

    if (expired()) await renew();

    final cancelToken = CancelToken();
    controller?.bind(() => cancelToken.cancel('Upload cancelled.'));
    try {
      while (true) {
        await _sameAccount(current, controller);
        try {
          await _apiClient.uploadBytes(
            signedUploadUrl: capability.signedUploadUrl,
            fileBytes: fileBytes,
            mimeType: request.mimeType,
            requiredHeaders: capability.requiredHeaders,
            cancelToken: cancelToken,
            onSendProgress: (sent, total) {
              if (total > 0) {
                request.onProgress?.call((sent / total).clamp(0, 1));
              }
            },
          );
          break;
        } on AuthFailure catch (failure) {
          if (!renewed &&
              expired() &&
              (failure.statusCode == 401 || failure.statusCode == 403)) {
            await renew();
            continue;
          }
          rethrow;
        }
      }
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

    Future<VerificationDocument> complete() async {
      final session = await _sameAccount(current, controller);
      final document = await _apiClient.uploadComplete(
        accessToken: session.accessToken,
        documentId: init.document.id,
        fileSizeBytes: fileSizeBytes,
        checksumSha256: checksumSha256,
      );
      await _sameAccount(current, controller);
      return document;
    }

    try {
      return await complete();
    } on AuthFailure catch (failure) {
      // Only the new contract promises side-effect-free matching replay.
      if (init.expiresAt != null &&
          ((failure.type == AuthFailureType.network &&
                  failure.statusCode == null) ||
              (failure.type == AuthFailureType.server &&
                  failure.statusCode != null &&
                  failure.statusCode! >= 500 &&
                  failure.statusCode! <= 599))) {
        return complete();
      }
      rethrow;
    }
  }

  Future<AuthSessionModel> _sameAccount(
    AuthSessionModel original,
    VerificationUploadController? controller,
  ) async {
    if (controller?.isCancelled ?? false) {
      throw const VerificationUploadCancelled();
    }
    final session = await _requireSession();
    if (session.user.id != original.user.id) {
      throw const AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'Your account changed. Please start the upload again.',
      );
    }
    if (controller?.isCancelled ?? false) {
      throw const VerificationUploadCancelled();
    }
    return session;
  }

  // Keep isolate capture separate from the operation's network/controller state.
  static Future<String> _checksum(List<int> bytes) =>
      Isolate.run(() => sha256.convert(bytes).toString());

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
