import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config/app_environment.dart';
import '../diagnostics/diagnostic_consent_store.dart';
import '../diagnostics/diagnostic_preferences_controller.dart';
import '../diagnostics/release_health_api_client.dart';
import '../diagnostics/release_health_coordinator.dart';
import '../diagnostics/release_health_error_bridge.dart';
import '../diagnostics/release_health_metadata.dart';
import '../config/carenet_api_config.dart';
import '../network/carenet_http_client.dart';
import '../../features/Authentication/data/repositories/account_repository.dart';
import '../../features/Authentication/data/repositories/auth_repository.dart';
import '../../features/Authentication/data/services/auth_api_client.dart';
import '../../features/Authentication/data/services/google_sign_in_provider.dart';
import '../../features/Authentication/data/services/session_refresh_coordinator.dart';
import '../../features/Authentication/data/storage/session_store.dart';
import '../../features/Consultation/data/repositories/consultation_repository.dart';
import '../../features/Consultation/data/services/consultation_api_client.dart';
import '../../features/Consultation/domain/services/consultation_permission_service.dart';
import '../../features/Home/data/repositories/profile_repository.dart';
import '../../features/Home/data/repositories/financial_repository.dart';
import '../../features/Home/data/repositories/onboarding_repository.dart';
import '../../features/Home/data/repositories/scheduling_repository.dart';
import '../../features/Home/data/repositories/verification_repository.dart';
import '../../features/Home/data/services/onboarding_api_client.dart';
import '../../features/Home/data/services/profile_api_client.dart';
import '../../features/Home/data/services/financial_api_client.dart';
import '../../features/Home/data/services/scheduling_api_client.dart';
import '../../features/Home/data/services/verification_api_client.dart';
import '../../features/Home/data/storage/booking_intent_store.dart';
import '../../features/Home/data/storage/payment_checkout_intent_store.dart';
import '../../features/Home/domain/services/booking_resume_service.dart';
import '../../features/Messaging/data/repositories/messaging_repository.dart';
import '../../features/Messaging/data/services/messaging_api_client.dart';
import '../../features/Notifications/data/repositories/notification_repository.dart';
import '../../features/Notifications/data/services/firebase_notification_transport.dart';
import '../../features/Notifications/data/services/notification_api_client.dart';
import '../../features/Notifications/data/storage/notification_installation_store.dart';
import '../../features/Notifications/presentation/state/notification_coordinator.dart';
import '../routing/app_navigator.dart';

/// Global service locator. Register dependencies here as features are built.
final GetIt sl = GetIt.instance;

/// Call once from [main] before [runApp].
Future<void> configureDependencies() async {
  if (!sl.isRegistered<CareNetApiConfig>()) {
    sl.registerLazySingleton<CareNetApiConfig>(
      CareNetApiConfig.fromEnvironment,
    );
  }
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(CareNetHttpClient.create);
  }
  if (!sl.isRegistered<AuthApiClient>()) {
    sl.registerLazySingleton<AuthApiClient>(
      () => AuthApiClient(config: sl<CareNetApiConfig>(), dio: sl<Dio>()),
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
  if (!sl.isRegistered<DiagnosticConsentStore>()) {
    sl.registerLazySingleton<DiagnosticConsentStore>(
      SecureDiagnosticConsentStore.new,
    );
  }
  if (!sl.isRegistered<ReleaseHealthTransport>()) {
    sl.registerLazySingleton<ReleaseHealthTransport>(
      () => ReleaseHealthApiClient(config: sl<CareNetApiConfig>()),
    );
  }
  if (!sl.isRegistered<ReleaseHealthCoordinator>()) {
    sl.registerLazySingleton<ReleaseHealthCoordinator>(
      () => ReleaseHealthCoordinator(
        sessions: sl<SessionStore>(),
        consent: sl<DiagnosticConsentStore>(),
        transport: sl<ReleaseHealthTransport>(),
        metadata: () async {
          final package = await PackageInfo.fromPlatform();
          return ReleaseHealthMetadata(
            version: package.version,
            buildNumber: package.buildNumber,
            environment: AppEnvironmentConfig.fromEnvironment().environment,
          );
        },
      ),
      dispose: (coordinator) => coordinator.dispose(),
    );
  }
  if (!sl.isRegistered<ReleaseHealthErrorBridge>()) {
    sl.registerLazySingleton<ReleaseHealthErrorBridge>(
      () => ReleaseHealthErrorBridge(
        report: (code) => sl<ReleaseHealthCoordinator>().report(code),
      ),
      dispose: (bridge) => bridge.dispose(),
    );
  }
  if (!sl.isRegistered<DiagnosticPreferencesController>()) {
    sl.registerLazySingleton<DiagnosticPreferencesController>(
      () => DiagnosticPreferencesController(
        sessions: sl<SessionStore>(),
        consent: sl<DiagnosticConsentStore>(),
        coordinator: sl<ReleaseHealthCoordinator>(),
      ),
      dispose: (controller) => controller.dispose(),
    );
  }
  if (!sl.isRegistered<SessionRefreshCoordinator>()) {
    sl.registerLazySingleton<SessionRefreshCoordinator>(
      () => SessionRefreshCoordinator(
        apiClient: sl<AuthApiClient>(),
        sessionStore: sl<SessionStore>(),
      ),
    );
  }
  if (!sl<Dio>().interceptors.any(
    (item) => item is SessionRefreshInterceptor,
  )) {
    sl<Dio>().interceptors.add(
      SessionRefreshInterceptor(
        dio: sl<Dio>(),
        coordinator: sl<SessionRefreshCoordinator>(),
      ),
    );
  }
  if (!sl.isRegistered<BookingIntentStore>()) {
    sl.registerLazySingleton<BookingIntentStore>(SecureBookingIntentStore.new);
  }
  if (!sl.isRegistered<PaymentCheckoutIntentStore>()) {
    sl.registerLazySingleton<PaymentCheckoutIntentStore>(
      SecurePaymentCheckoutIntentStore.new,
    );
  }
  if (!sl.isRegistered<ProfileApiClient>()) {
    sl.registerLazySingleton<ProfileApiClient>(
      () => ProfileApiClient(config: sl<CareNetApiConfig>(), dio: sl<Dio>()),
    );
  }
  if (!sl.isRegistered<FinancialApiClient>()) {
    sl.registerLazySingleton<FinancialApiClient>(
      () => FinancialApiClient(config: sl<CareNetApiConfig>(), dio: sl<Dio>()),
    );
  }
  if (!sl.isRegistered<OnboardingApiClient>()) {
    sl.registerLazySingleton<OnboardingApiClient>(
      () => OnboardingApiClient(config: sl<CareNetApiConfig>(), dio: sl<Dio>()),
    );
  }
  if (!sl.isRegistered<SchedulingApiClient>()) {
    sl.registerLazySingleton<SchedulingApiClient>(
      () => SchedulingApiClient(config: sl<CareNetApiConfig>(), dio: sl<Dio>()),
    );
  }
  if (!sl.isRegistered<ConsultationApiClient>()) {
    sl.registerLazySingleton<ConsultationApiClient>(
      () =>
          ConsultationApiClient(config: sl<CareNetApiConfig>(), dio: sl<Dio>()),
    );
  }
  if (!sl.isRegistered<VerificationApiClient>()) {
    sl.registerLazySingleton<VerificationApiClient>(
      () => VerificationApiClient(
        config: sl<CareNetApiConfig>(),
        dio: sl<Dio>(),
        uploadDio: CareNetHttpClient.createUpload(),
      ),
    );
  }
  if (!sl.isRegistered<MessagingApiClient>()) {
    sl.registerLazySingleton<MessagingApiClient>(
      () => MessagingApiClient(config: sl<CareNetApiConfig>(), dio: sl<Dio>()),
    );
  }
  if (!sl.isRegistered<NotificationApiClient>()) {
    sl.registerLazySingleton<NotificationApiClient>(
      () =>
          NotificationApiClient(config: sl<CareNetApiConfig>(), dio: sl<Dio>()),
    );
  }
  if (!sl.isRegistered<NotificationInstallationStore>()) {
    sl.registerLazySingleton<NotificationInstallationStore>(
      SecureNotificationInstallationStore.new,
    );
  }
  if (!sl.isRegistered<NotificationTransport>()) {
    sl.registerLazySingleton<NotificationTransport>(
      FirebaseNotificationTransport.new,
    );
  }
  if (!sl.isRegistered<NotificationRepository>()) {
    sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepository(
        apiClient: sl<NotificationApiClient>(),
        sessionStore: sl<SessionStore>(),
      ),
    );
  }
  if (!sl.isRegistered<NotificationCoordinator>()) {
    sl.registerLazySingleton<NotificationCoordinator>(
      () => NotificationCoordinator(
        repository: sl<NotificationRepository>(),
        installationStore: sl<NotificationInstallationStore>(),
        transport: sl<NotificationTransport>(),
        navigatorKey: appNavigatorKey,
      ),
    );
  }
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepository(
        apiClient: sl<AuthApiClient>(),
        sessionStore: sl<SessionStore>(),
        notificationLifecycle: sl<NotificationCoordinator>(),
        refreshCoordinator: sl<SessionRefreshCoordinator>(),
      ),
    );
  }
  if (!sl.isRegistered<AccountRepository>()) {
    sl.registerLazySingleton<AccountRepository>(
      () => AccountRepository(
        apiClient: sl<AuthApiClient>(),
        sessionStore: sl<SessionStore>(),
        notificationLifecycle: sl<NotificationCoordinator>(),
      ),
    );
  }
  if (!sl.isRegistered<ProfileRepository>()) {
    sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepository(
        apiClient: sl<ProfileApiClient>(),
        sessionStore: sl<SessionStore>(),
      ),
    );
  }
  if (!sl.isRegistered<FinancialRepository>()) {
    sl.registerLazySingleton<FinancialRepository>(
      () => FinancialRepository(
        apiClient: sl<FinancialApiClient>(),
        sessionStore: sl<SessionStore>(),
      ),
    );
  }
  if (!sl.isRegistered<OnboardingRepository>()) {
    sl.registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepository(
        apiClient: sl<OnboardingApiClient>(),
        sessionStore: sl<SessionStore>(),
        authRepository: sl<AuthRepository>(),
      ),
    );
  }
  if (!sl.isRegistered<BookingResumeService>()) {
    sl.registerLazySingleton<BookingResumeService>(
      () => BookingResumeService(
        bookingIntentStore: sl<BookingIntentStore>(),
        sessionStore: sl<SessionStore>(),
        onboardingRepository: sl<OnboardingRepository>(),
      ),
    );
  }
  if (!sl.isRegistered<SchedulingRepository>()) {
    sl.registerLazySingleton<SchedulingRepository>(
      () => SchedulingRepository(
        apiClient: sl<SchedulingApiClient>(),
        sessionStore: sl<SessionStore>(),
      ),
    );
  }
  if (!sl.isRegistered<ConsultationRepository>()) {
    sl.registerLazySingleton<ConsultationRepository>(
      () => ConsultationRepository(
        apiClient: sl<ConsultationApiClient>(),
        sessionStore: sl<SessionStore>(),
      ),
    );
  }
  if (!sl.isRegistered<ConsultationPermissionService>()) {
    sl.registerLazySingleton<ConsultationPermissionService>(
      DeviceConsultationPermissionService.new,
    );
  }
  if (!sl.isRegistered<VerificationRepository>()) {
    sl.registerLazySingleton<VerificationRepository>(
      () => VerificationRepository(
        apiClient: sl<VerificationApiClient>(),
        sessionStore: sl<SessionStore>(),
      ),
    );
  }
  if (!sl.isRegistered<MessagingRepository>()) {
    sl.registerLazySingleton<MessagingRepository>(
      () => MessagingRepository(
        apiClient: sl<MessagingApiClient>(),
        sessionStore: sl<SessionStore>(),
      ),
    );
  }
}
