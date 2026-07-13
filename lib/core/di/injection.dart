import 'package:get_it/get_it.dart';

import '../config/carenet_api_config.dart';
import '../../features/Authentication/data/repositories/account_repository.dart';
import '../../features/Authentication/data/repositories/auth_repository.dart';
import '../../features/Authentication/data/services/auth_api_client.dart';
import '../../features/Authentication/data/services/google_sign_in_provider.dart';
import '../../features/Authentication/data/storage/session_store.dart';

/// Global service locator. Register dependencies here as features are built.
final GetIt sl = GetIt.instance;

/// Call once from [main] before [runApp].
Future<void> configureDependencies() async {
  if (!sl.isRegistered<CareNetApiConfig>()) {
    sl.registerLazySingleton<CareNetApiConfig>(
      CareNetApiConfig.fromEnvironment,
    );
  }
  if (!sl.isRegistered<AuthApiClient>()) {
    sl.registerLazySingleton<AuthApiClient>(
      () => AuthApiClient(config: sl<CareNetApiConfig>()),
    );
  }
  if (!sl.isRegistered<GoogleSignInConfig>()) {
    sl.registerLazySingleton<GoogleSignInConfig>(
      GoogleSignInConfig.fromEnvironment,
    );
  }
  if (!sl.isRegistered<GoogleIdTokenProvider>()) {
    sl.registerLazySingleton<GoogleIdTokenProvider>(
      () => GoogleSignInIdTokenProvider(config: sl<GoogleSignInConfig>()),
    );
  }
  if (!sl.isRegistered<SessionStore>()) {
    sl.registerLazySingleton<SessionStore>(SecureSessionStore.new);
  }
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepository(
        apiClient: sl<AuthApiClient>(),
        sessionStore: sl<SessionStore>(),
      ),
    );
  }
  if (!sl.isRegistered<AccountRepository>()) {
    sl.registerLazySingleton<AccountRepository>(
      () => AccountRepository(
        apiClient: sl<AuthApiClient>(),
        sessionStore: sl<SessionStore>(),
      ),
    );
  }
}
