import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/data/storage/booking_intent_store.dart';

import '../entities/booking_intent.dart';

enum BookingResumeTarget {
  none,
  authentication,
  patientOnboarding,
  professionalDetail,
  incompatibleRole,
}

class BookingResumeDecision {
  const BookingResumeDecision({required this.target, this.intent});

  final BookingResumeTarget target;
  final BookingIntent? intent;
}

class BookingResumeService {
  const BookingResumeService({
    required BookingIntentStore bookingIntentStore,
    required SessionStore sessionStore,
    required OnboardingRepository onboardingRepository,
  }) : _bookingIntentStore = bookingIntentStore,
       _sessionStore = sessionStore,
       _onboardingRepository = onboardingRepository;

  final BookingIntentStore _bookingIntentStore;
  final SessionStore _sessionStore;
  final OnboardingRepository _onboardingRepository;

  Future<bool> hasPendingIntent() async {
    return await _bookingIntentStore.read() != null;
  }

  Future<BookingResumeDecision> resolveAfterAuthentication() async {
    final intent = await _bookingIntentStore.read();
    if (intent == null) {
      return const BookingResumeDecision(target: BookingResumeTarget.none);
    }

    final session = await _sessionStore.read();
    if (session == null) {
      return BookingResumeDecision(
        target: BookingResumeTarget.authentication,
        intent: intent,
      );
    }

    final role = session.user.role.trim().toUpperCase();
    if (role != 'PATIENT') {
      await _bookingIntentStore.clear();
      return const BookingResumeDecision(
        target: BookingResumeTarget.incompatibleRole,
      );
    }

    final sessionUserId = session.user.id.trim();
    final boundUserId = intent.accountUserId?.trim();
    if (sessionUserId.isEmpty ||
        (boundUserId != null &&
            boundUserId.isNotEmpty &&
            boundUserId != sessionUserId)) {
      await _bookingIntentStore.clear();
      return const BookingResumeDecision(
        target: BookingResumeTarget.incompatibleRole,
      );
    }

    var boundIntent = intent;
    if (boundUserId == null || boundUserId.isEmpty) {
      boundIntent = intent.copyWith(accountUserId: sessionUserId);
      await _bookingIntentStore.save(boundIntent);
    }

    final readiness = await _onboardingRepository.accountReadiness();
    final authoritativeRole = readiness.account.role.trim().toUpperCase();
    if (authoritativeRole != 'PATIENT') {
      await _bookingIntentStore.clear();
      return const BookingResumeDecision(
        target: BookingResumeTarget.incompatibleRole,
      );
    }

    final patientIncomplete =
        readiness.nextAction.trim().toUpperCase() == 'PATIENT_SETUP' ||
        (readiness.patient?.requiredFields.isNotEmpty ?? true);
    return BookingResumeDecision(
      target:
          patientIncomplete
              ? BookingResumeTarget.patientOnboarding
              : BookingResumeTarget.professionalDetail,
      intent: boundIntent,
    );
  }
}
