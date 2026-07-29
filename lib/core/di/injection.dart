import 'package:get_it/get_it.dart';

import '../config/carenet_api_config.dart';
import '../../features/Authentication/data/repositories/account_repository.dart';
import '../../features/Authentication/data/repositories/auth_repository.dart';
import '../../features/Authentication/data/services/auth_api_client.dart';
import '../../features/Authentication/data/services/google_sign_in_provider.dart';
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
      () => ProfileApiClient(config: sl<CareNetApiConfig>()),
    );
  }
  if (!sl.isRegistered<FinancialApiClient>()) {
    sl.registerLazySingleton<FinancialApiClient>(
      () => FinancialApiClient(config: sl<CareNetApiConfig>()),
    );
  }
  if (!sl.isRegistered<OnboardingApiClient>()) {
    sl.registerLazySingleton<OnboardingApiClient>(
      () => OnboardingApiClient(config: sl<CareNetApiConfig>()),
    );
  }
  if (!sl.isRegistered<SchedulingApiClient>()) {
    sl.registerLazySingleton<SchedulingApiClient>(
      () => SchedulingApiClient(config: sl<CareNetApiConfig>()),
    );
  }
  if (!sl.isRegistered<ConsultationApiClient>()) {
    sl.registerLazySingleton<ConsultationApiClient>(
      () => ConsultationApiClient(config: sl<CareNetApiConfig>()),
    );
  }
  if (!sl.isRegistered<VerificationApiClient>()) {
    sl.registerLazySingleton<VerificationApiClient>(
      () => VerificationApiClient(config: sl<CareNetApiConfig>()),
    );
  }
  if (!sl.isRegistered<MessagingApiClient>()) {
    sl.registerLazySingleton<MessagingApiClient>(
      () => MessagingApiClient(config: sl<CareNetApiConfig>()),
    );
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
