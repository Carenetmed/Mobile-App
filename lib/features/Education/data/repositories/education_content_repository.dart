import 'dart:typed_data';

import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Education/data/services/education_content_api_client.dart';
import 'package:app_t/features/Education/domain/entities/education_content.dart';
import 'package:dio/dio.dart';

abstract interface class EducationContentDataSource {
  Future<List<EducationContent>> listMine({CancelToken? cancelToken});

  Future<EducationContent> createDraft({
    required EducationContentType type,
    required String title,
    String? body,
    String? caption,
  });

  Future<EducationContent> updateDraft({
    required EducationContent content,
    required String title,
    String? body,
    String? caption,
  });

  Future<EducationVideoUploadReceipt> uploadVideo({
    required String contentId,
    required String fileName,
    required Uint8List bytes,
    required CancelToken cancelToken,
    void Function(double progress)? onProgress,
  });

  Future<void> submit({required String contentId});

  Future<void> archive({required String contentId});
}

class EducationContentRepository implements EducationContentDataSource {
  const EducationContentRepository({
    required EducationContentApiClient apiClient,
    required SessionStore sessionStore,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore;

  final EducationContentApiClient _apiClient;
  final SessionStore _sessionStore;

  @override
  Future<List<EducationContent>> listMine({CancelToken? cancelToken}) async {
    final session = await _requireProfessionalSession();
    final result = await _apiClient.listMine(
      accessToken: session.accessToken,
      cancelToken: cancelToken,
    );
    await _ensureSameAccount(session);
    return result;
  }

  @override
  Future<EducationContent> createDraft({
    required EducationContentType type,
    required String title,
    String? body,
    String? caption,
  }) async {
    final session = await _requireProfessionalSession();
    final result = await _apiClient.createDraft(
      accessToken: session.accessToken,
      type: type,
      title: title,
      body: body,
      caption: caption,
    );
    await _ensureSameAccount(session);
    return result;
  }

  @override
  Future<EducationContent> updateDraft({
    required EducationContent content,
    required String title,
    String? body,
    String? caption,
  }) async {
    final session = await _requireProfessionalSession();
    final result = await _apiClient.updateDraft(
      accessToken: session.accessToken,
      content: content,
      title: title,
      body: body,
      caption: caption,
    );
    await _ensureSameAccount(session);
    return result;
  }

  @override
  Future<EducationVideoUploadReceipt> uploadVideo({
    required String contentId,
    required String fileName,
    required Uint8List bytes,
    required CancelToken cancelToken,
    void Function(double progress)? onProgress,
  }) async {
    final session = await _requireProfessionalSession();
    final result = await _apiClient.uploadVideo(
      accessToken: session.accessToken,
      contentId: contentId,
      fileName: fileName,
      bytes: bytes,
      cancelToken: cancelToken,
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call((sent / total).clamp(0, 1));
      },
    );
    await _ensureSameAccount(session);
    return result;
  }

  @override
  Future<void> submit({required String contentId}) async {
    final session = await _requireProfessionalSession();
    await _apiClient.submit(
      accessToken: session.accessToken,
      contentId: contentId,
    );
    await _ensureSameAccount(session);
  }

  @override
  Future<void> archive({required String contentId}) async {
    final session = await _requireProfessionalSession();
    await _apiClient.archive(
      accessToken: session.accessToken,
      contentId: contentId,
    );
    await _ensureSameAccount(session);
  }

  Future<AuthSessionModel> _requireProfessionalSession() async {
    final session = await _sessionStore.read();
    if (session == null) {
      throw const AuthFailure(
        type: AuthFailureType.unauthorized,
        message:
            'Sign in with a professional account to manage education posts.',
      );
    }
    if (session.user.role.toUpperCase() != 'PROFESSIONAL') {
      throw const AuthFailure(
        type: AuthFailureType.forbidden,
        message:
            'Education posts are available to active, verified medical doctors.',
      );
    }
    return session;
  }

  Future<void> _ensureSameAccount(AuthSessionModel expected) async {
    final current = await _sessionStore.read();
    if (current?.user.id != expected.user.id) {
      throw const AuthFailure(
        type: AuthFailureType.unauthorized,
        message:
            'Your account changed. Reopen the education studio to continue.',
      );
    }
  }
}
