import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/data/storage/booking_intent_store.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/booking_intent.dart';
import 'package:app_t/features/Home/domain/entities/public_professional.dart';
import 'package:app_t/features/Home/domain/entities/requestable_times.dart';
import 'package:app_t/features/Home/domain/services/booking_idempotency_key_factory.dart';
import 'package:app_t/features/Home/domain/services/professional_time_formatter.dart';
import 'package:flutter/foundation.dart';

enum BookingGateOutcome {
  ready,
  authenticationRequired,
  onboardingRequired,
  incompatibleRole,
  unavailable,
  failure,
}

enum BookingSubmissionOutcome {
  requested,
  authenticationRequired,
  incompatibleRole,
  staleTime,
  professionalUnavailable,
  uncertain,
  failure,
}

class ProfessionalBookingController extends ChangeNotifier {
  ProfessionalBookingController({
    required this.professionalProfileId,
    required ProfileRepository profileRepository,
    required SchedulingRepository schedulingRepository,
    required BookingIntentStore bookingIntentStore,
    required SessionStore sessionStore,
    required OnboardingRepository onboardingRepository,
    BookingIdempotencyKeyFactory? idempotencyKeyFactory,
    DateTime Function()? clock,
  }) : _profileRepository = profileRepository,
       _schedulingRepository = schedulingRepository,
       _bookingIntentStore = bookingIntentStore,
       _sessionStore = sessionStore,
       _onboardingRepository = onboardingRepository,
       _idempotencyKeyFactory =
           idempotencyKeyFactory ?? BookingIdempotencyKeyFactory(),
       _clock = clock ?? DateTime.now;

  final String professionalProfileId;
  final ProfileRepository _profileRepository;
  final SchedulingRepository _schedulingRepository;
  final BookingIntentStore _bookingIntentStore;
  final SessionStore _sessionStore;
  final OnboardingRepository _onboardingRepository;
  final BookingIdempotencyKeyFactory _idempotencyKeyFactory;
  final DateTime Function() _clock;

  PublicProfessional? professional;
  RequestableTimes? requestableTimes;
  RequestableTime? selectedTime;
  BookingIntent? bookingIntent;
  AppointmentSummary? requestedAppointment;
  String? profileError;
  String? timesError;
  String? bookingError;
  bool profileNotFound = false;
  bool isLoadingProfile = false;
  bool isLoadingTimes = false;
  bool isRefreshing = false;
  bool isSubmitting = false;

  Future<void>? _profileLoad;
  Future<void>? _timesLoad;
  Future<BookingSubmissionOutcome>? _submission;
  int _profileGeneration = 0;
  int _timesGeneration = 0;
  bool _disposed = false;

  Future<void> initialize() async {
    await _restoreIntent();
    await loadProfile();
    if (professional?.bookable == true &&
        professional?.consultationPrice?.isValidNgn == true) {
      await loadTimes();
    } else if (professional != null || profileNotFound) {
      requestableTimes = null;
      selectedTime = null;
      bookingIntent = null;
      await _bookingIntentStore.clear();
    }
  }

  Future<void> refresh() async {
    if (isRefreshing || _profileLoad != null || _timesLoad != null) {
      return;
    }
    isRefreshing = true;
    _notify();
    try {
      await loadProfile(refresh: true);
      if (professional?.bookable == true &&
          professional?.consultationPrice?.isValidNgn == true) {
        await loadTimes(refresh: true);
      } else if (professional != null || profileNotFound) {
        requestableTimes = null;
        selectedTime = null;
        bookingIntent = null;
        await _bookingIntentStore.clear();
      }
    } finally {
      isRefreshing = false;
      _notify();
    }
  }

  Future<void> loadProfile({bool refresh = false}) {
    final active = _profileLoad;
    if (active != null) {
      return active;
    }
    final generation = ++_profileGeneration;
    final future = _loadProfile(generation: generation, refresh: refresh);
    _profileLoad = future;
    return future.whenComplete(() {
      if (identical(_profileLoad, future)) {
        _profileLoad = null;
      }
    });
  }

  Future<void> _loadProfile({
    required int generation,
    required bool refresh,
  }) async {
    isLoadingProfile = professional == null;
    profileError = null;
    profileNotFound = false;
    _notify();
    try {
      final loaded = await _profileRepository.publicProfessionalById(
        professionalProfileId: professionalProfileId,
      );
      if (!_acceptProfileGeneration(generation)) {
        return;
      }
      if (loaded == null ||
          !loaded.verified ||
          loaded.id != professionalProfileId) {
        professional = null;
        profileNotFound = true;
        await _bookingIntentStore.clear();
        bookingIntent = null;
        selectedTime = null;
      } else {
        professional = loaded;
      }
    } catch (_) {
      if (_acceptProfileGeneration(generation)) {
        profileError =
            refresh && professional != null
                ? 'Profile refresh failed. Showing the last loaded profile.'
                : 'Could not load this professional. Please try again.';
      }
    } finally {
      if (_acceptProfileGeneration(generation)) {
        isLoadingProfile = false;
        _notify();
      }
    }
  }

  Future<void> loadTimes({bool refresh = false}) {
    final active = _timesLoad;
    if (active != null) {
      return active;
    }
    final generation = ++_timesGeneration;
    final future = _loadTimes(generation: generation, refresh: refresh);
    _timesLoad = future;
    return future.whenComplete(() {
      if (identical(_timesLoad, future)) {
        _timesLoad = null;
      }
    });
  }

  Future<void> _loadTimes({
    required int generation,
    required bool refresh,
  }) async {
    isLoadingTimes = requestableTimes == null;
    timesError = null;
    _notify();
    try {
      final loaded = await _schedulingRepository.publicRequestableTimes(
        professionalProfileId: professionalProfileId,
      );
      if (!_acceptTimesGeneration(generation)) {
        return;
      }
      if (loaded.professionalProfileId != professionalProfileId ||
          loaded.timezone == null ||
          loaded.timezone!.trim().isEmpty ||
          !ProfessionalTimeFormatter().isValidTimezone(loaded.timezone!) ||
          loaded.durationMinutes != 30 ||
          loaded.cadenceMinutes != 30 ||
          loaded.leadTimeMinutes != 120 ||
          loaded.bookingHorizonDays != 60 ||
          loaded.times.any((time) => time.durationMinutes != 30)) {
        throw const FormatException('Invalid requestable-time contract.');
      }
      requestableTimes = loaded;
      final selected = selectedTime;
      if (selected != null && !_containsTime(loaded, selected.startAt)) {
        selectedTime = null;
        bookingIntent = null;
        await _bookingIntentStore.clear();
        bookingError =
            'The selected time is no longer available. Please choose another.';
      } else if (selected == null && bookingIntent != null) {
        final restored = loaded.times.where(
          (time) =>
              time.startAt.toUtc() == bookingIntent!.startAt.toUtc() &&
              time.durationMinutes == bookingIntent!.durationMinutes,
        );
        if (restored.isEmpty) {
          bookingIntent = null;
          await _bookingIntentStore.clear();
        } else {
          selectedTime = restored.first;
        }
      }
    } catch (_) {
      if (_acceptTimesGeneration(generation)) {
        timesError =
            refresh && requestableTimes != null
                ? 'Times refresh failed. Showing the last loaded times.'
                : 'Could not load appointment times. Please try again.';
      }
    } finally {
      if (_acceptTimesGeneration(generation)) {
        isLoadingTimes = false;
        _notify();
      }
    }
  }

  Future<void> selectTime(RequestableTime time) async {
    final available = requestableTimes;
    if (available == null || !_containsTime(available, time.startAt)) {
      return;
    }
    final changed = selectedTime?.startAt.toUtc() != time.startAt.toUtc();
    selectedTime = time;
    bookingError = null;
    if (changed && bookingIntent != null) {
      bookingIntent = _newIntent(
        time,
        accountUserId: bookingIntent!.accountUserId,
      );
      await _bookingIntentStore.save(bookingIntent!);
    }
    _notify();
  }

  Future<void> cancelIntent() async {
    selectedTime = null;
    bookingIntent = null;
    bookingError = null;
    await _bookingIntentStore.clear();
    _notify();
  }

  Future<BookingGateOutcome> prepareBooking() async {
    final time = selectedTime;
    if (professional?.bookable != true ||
        professional?.consultationPrice?.isValidNgn != true) {
      bookingError =
          'This professional has not published a consultation price yet.';
      _notify();
      return BookingGateOutcome.unavailable;
    }
    if (time == null) {
      bookingError = 'Choose an available appointment time first.';
      _notify();
      return BookingGateOutcome.unavailable;
    }

    final session = await _sessionStore.read();
    final existing = await _bookingIntentStore.read(now: _clock().toUtc());
    var intent =
        existing != null &&
                existing.matches(
                  professionalProfileId: professionalProfileId,
                  startAt: time.startAt,
                  durationMinutes: 30,
                )
            ? existing
            : _newIntent(time, accountUserId: session?.user.id);
    await _bookingIntentStore.save(intent);
    bookingIntent = intent;

    if (session == null) {
      _notify();
      return BookingGateOutcome.authenticationRequired;
    }
    if (session.user.role.trim().toUpperCase() != 'PATIENT') {
      await cancelIntent();
      bookingError =
          'This account cannot request patient appointments. '
          'Use a patient account to continue.';
      _notify();
      return BookingGateOutcome.incompatibleRole;
    }
    final accountId = session.user.id.trim();
    if (accountId.isEmpty ||
        (intent.accountUserId?.isNotEmpty == true &&
            intent.accountUserId != accountId)) {
      await cancelIntent();
      bookingError = 'The saved booking belongs to another account.';
      _notify();
      return BookingGateOutcome.incompatibleRole;
    }
    if (intent.accountUserId == null || intent.accountUserId!.isEmpty) {
      intent = intent.copyWith(accountUserId: accountId);
      await _bookingIntentStore.save(intent);
      bookingIntent = intent;
    }

    try {
      final readiness = await _onboardingRepository.accountReadiness();
      if (readiness.account.role.trim().toUpperCase() != 'PATIENT') {
        await cancelIntent();
        bookingError =
            'This account cannot request patient appointments. '
            'Use a patient account to continue.';
        _notify();
        return BookingGateOutcome.incompatibleRole;
      }
      final incomplete =
          readiness.nextAction.trim().toUpperCase() == 'PATIENT_SETUP' ||
          (readiness.patient?.requiredFields.isNotEmpty ?? true);
      return incomplete
          ? BookingGateOutcome.onboardingRequired
          : BookingGateOutcome.ready;
    } catch (_) {
      bookingError = 'Could not verify patient readiness. Please try again.';
      _notify();
      return BookingGateOutcome.failure;
    }
  }

  Future<BookingSubmissionOutcome> submit() {
    final active = _submission;
    if (active != null) {
      return active;
    }
    final future = _submit();
    _submission = future;
    return future.whenComplete(() {
      if (identical(_submission, future)) {
        _submission = null;
      }
    });
  }

  Future<BookingSubmissionOutcome> _submit() async {
    final intent = bookingIntent ?? await _bookingIntentStore.read();
    if (intent == null || selectedTime == null) {
      return BookingSubmissionOutcome.staleTime;
    }
    isSubmitting = true;
    bookingError = null;
    _notify();
    try {
      await loadProfile(refresh: true);
      await loadTimes(refresh: true);
      if (professional == null || profileNotFound) {
        await cancelIntent();
        return BookingSubmissionOutcome.professionalUnavailable;
      }
      final selected = selectedTime;
      if (selected == null ||
          !_containsTime(requestableTimes, intent.startAt) ||
          !intent.matches(
            professionalProfileId: professionalProfileId,
            startAt: selected.startAt,
            durationMinutes: 30,
          )) {
        await cancelIntent();
        bookingError =
            'The selected time is no longer available. Please choose another.';
        return BookingSubmissionOutcome.staleTime;
      }

      final gate = await prepareBooking();
      if (gate == BookingGateOutcome.authenticationRequired) {
        return BookingSubmissionOutcome.authenticationRequired;
      }
      if (gate == BookingGateOutcome.incompatibleRole) {
        return BookingSubmissionOutcome.incompatibleRole;
      }
      if (gate != BookingGateOutcome.ready) {
        return BookingSubmissionOutcome.failure;
      }

      final persisted = bookingIntent!;
      requestedAppointment = await _schedulingRepository.requestAppointment(
        professionalProfileId: professionalProfileId,
        requestedStartAt: persisted.startAt,
        durationMinutes: 30,
        idempotencyKey: persisted.idempotencyKey,
      );
      if (requestedAppointment!.status != AppointmentStatus.requested) {
        throw const FormatException('Unexpected appointment status.');
      }
      await _bookingIntentStore.clear();
      bookingIntent = null;
      selectedTime = null;
      return BookingSubmissionOutcome.requested;
    } on AuthFailure catch (failure) {
      switch (failure.statusCode) {
        case 401:
          return BookingSubmissionOutcome.authenticationRequired;
        case 403:
          await cancelIntent();
          bookingError =
              'This account cannot request patient appointments. '
              'Use a patient account to continue.';
          return BookingSubmissionOutcome.incompatibleRole;
        case 404:
          await cancelIntent();
          professional = null;
          profileNotFound = true;
          return BookingSubmissionOutcome.professionalUnavailable;
        case 409:
          await cancelIntent();
          await loadTimes(refresh: true);
          bookingError =
              'That time is no longer available. Please choose another.';
          return BookingSubmissionOutcome.staleTime;
      }
      if (failure.type == AuthFailureType.network) {
        bookingError =
            'The request result is uncertain. Retry safely with the same selection.';
        return BookingSubmissionOutcome.uncertain;
      }
      bookingError =
          'Could not send the appointment request. Please try again.';
      return BookingSubmissionOutcome.failure;
    } catch (_) {
      bookingError =
          'Could not send the appointment request. Please try again.';
      return BookingSubmissionOutcome.failure;
    } finally {
      isSubmitting = false;
      _notify();
    }
  }

  BookingIntent _newIntent(
    RequestableTime time, {
    required String? accountUserId,
  }) {
    final now = _clock().toUtc();
    return BookingIntent(
      professionalProfileId: professionalProfileId,
      startAt: time.startAt.toUtc(),
      endAt: time.endAt.toUtc(),
      durationMinutes: 30,
      idempotencyKey: _idempotencyKeyFactory.create(),
      resumeRoute: RouteName.specialistDetails,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 24)),
      accountUserId:
          accountUserId?.trim().isEmpty == true ? null : accountUserId,
    );
  }

  Future<void> _restoreIntent() async {
    final intent = await _bookingIntentStore.read(now: _clock().toUtc());
    if (intent == null) {
      return;
    }
    if (intent.professionalProfileId != professionalProfileId) {
      await _bookingIntentStore.clear();
      return;
    }
    final session = await _sessionStore.read();
    if (session != null) {
      final userId = session.user.id.trim();
      final role = session.user.role.trim().toUpperCase();
      if (role != 'PATIENT' ||
          (intent.accountUserId?.isNotEmpty == true &&
              intent.accountUserId != userId)) {
        await _bookingIntentStore.clear();
        return;
      }
    }
    bookingIntent = intent;
  }

  bool _containsTime(RequestableTimes? response, DateTime startAt) {
    return response?.times.any(
          (time) => time.startAt.toUtc() == startAt.toUtc(),
        ) ??
        false;
  }

  bool _acceptProfileGeneration(int generation) {
    return !_disposed && generation == _profileGeneration;
  }

  bool _acceptTimesGeneration(int generation) {
    return !_disposed && generation == _timesGeneration;
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
