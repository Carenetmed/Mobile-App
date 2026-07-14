import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';

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
    final fileSizeBytes = request.fileSizeBytes ?? request.fileBytes.length;
    final init = await _apiClient.uploadInit(
      accessToken: current.accessToken,
      documentType: request.documentType,
      originalFileName: request.originalFileName,
      mimeType: request.mimeType,
      fileSizeBytes: fileSizeBytes,
    );

    await _apiClient.uploadBytes(
      signedUploadUrl: init.signedUploadUrl,
      fileBytes: request.fileBytes,
      mimeType: request.mimeType,
    );

    return _apiClient.uploadComplete(
      accessToken: current.accessToken,
      documentId: init.document.id,
      fileSizeBytes: fileSizeBytes,
      checksumSha256: request.checksumSha256,
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
