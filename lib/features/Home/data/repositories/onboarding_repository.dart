import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';

import '../../domain/entities/account_readiness.dart';
import '../../domain/entities/onboarding_catalog.dart';
import '../services/onboarding_api_client.dart';

class OnboardingRepository {
  const OnboardingRepository({
    required OnboardingApiClient apiClient,
    required SessionStore sessionStore,
    AuthRepository? authRepository,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore,
       _authRepository = authRepository;

  final OnboardingApiClient _apiClient;
  final SessionStore _sessionStore;
  final AuthRepository? _authRepository;

  Future<OnboardingCatalog> onboardingCatalog() {
    return _apiClient.onboardingCatalog();
  }

  Future<AccountReadiness> accountReadiness() async {
    try {
      return await _accountReadinessWithCurrentSession();
    } on AuthFailure catch (failure) {
      final authRepository = _authRepository;
      if (failure.type != AuthFailureType.unauthorized ||
          authRepository == null) {
        rethrow;
      }
      await authRepository.refresh();
      return _accountReadinessWithCurrentSession();
    }
  }

  Future<AccountReadiness> _accountReadinessWithCurrentSession() async {
    final current = await _requireSession();
    return _apiClient.accountReadiness(accessToken: current.accessToken);
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
