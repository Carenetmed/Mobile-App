import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Education/data/services/education_content_api_client.dart';
import 'package:app_t/features/Education/domain/entities/public_education_content.dart';
import 'package:dio/dio.dart';

abstract interface class EducationPublicContentSource {
  Future<PublicEducationFeedPage> listPublic({
    String? cursor,
    CancelToken? cancelToken,
  });

  Future<PublicEducationContent> getPublic({
    required String contentId,
    CancelToken? cancelToken,
  });

  Future<void> report({required String contentId, required String reason});
}

class EducationPublicContentRepository implements EducationPublicContentSource {
  const EducationPublicContentRepository({
    required EducationContentApiClient apiClient,
    required SessionStore sessionStore,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore;

  final EducationContentApiClient _apiClient;
  final SessionStore _sessionStore;

  @override
  Future<PublicEducationFeedPage> listPublic({
    String? cursor,
    CancelToken? cancelToken,
  }) => _apiClient.listPublic(cursor: cursor, cancelToken: cancelToken);

  @override
  Future<PublicEducationContent> getPublic({
    required String contentId,
    CancelToken? cancelToken,
  }) => _apiClient.getPublic(contentId: contentId, cancelToken: cancelToken);

  @override
  Future<void> report({
    required String contentId,
    required String reason,
  }) async {
    final session = await _sessionStore.read();
    if (session == null || session.accessToken.trim().isEmpty) {
      throw const AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'Sign in to report this post.',
      );
    }
    await _apiClient.reportPublic(
      contentId: contentId,
      accessToken: session.accessToken,
      reason: reason,
    );
    final current = await _sessionStore.read();
    if (current?.user.id != session.user.id) {
      throw const AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'Your account changed. Please reopen this post.',
      );
    }
  }
}
