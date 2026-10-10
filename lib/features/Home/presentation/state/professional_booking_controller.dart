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
  static const int requestableRangeDays = 14;

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
  ConsultationMode selectedMode = ConsultationMode.video;
  AppointmentSummary? requestedAppointment;
  String? profileError;
  String? timesError;
  String? bookingError;
  bool profileNotFound = false;
  bool isLoadingProfile = false;
  bool isLoadingTimes = false;
  bool isLoadingLaterTimes = false;
  bool isRefreshing = false;
  bool isSubmitting = false;
  bool isPreparingBooking = false;
  bool bookingReadinessFailed = false;

  Future<void>? _profileLoad;
  Future<void>? _timesLoad;
  Future<BookingGateOutcome>? _bookingGateCheck;
  Future<BookingSubmissionOutcome>? _submission;
  int _profileGeneration = 0;
  int _timesGeneration = 0;
  bool _disposed = false;
  DateTime? _bookingWindowEndAt;

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
    if (isRefreshing ||
        isPreparingBooking ||
        isSubmitting ||
        isLoadingLaterTimes ||
        _profileLoad != null ||
        _timesLoad != null) {
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
    if (isLoadingLaterTimes) return Future<void>.value();
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
      final rangeStartAt = _clock().toUtc();
      final rangeEndAt = rangeStartAt.add(
        const Duration(days: requestableRangeDays),
      );
      final loaded = await _schedulingRepository.publicRequestableTimes(
        professionalProfileId: professionalProfileId,
        rangeStartAt: rangeStartAt,
        rangeEndAt: rangeEndAt,
      );
      if (!_acceptTimesGeneration(generation)) {
        return;
      }
      if (!_hasValidTimesContract(loaded) ||
          (loaded.rangeStartAt != null &&
              (loaded.rangeStartAt!.toUtc() != rangeStartAt ||
                  loaded.rangeEndAt!.isAfter(rangeEndAt)))) {
        throw const FormatException('Invalid requestable-time contract.');
      }
      final effectiveLoaded =
          loaded.rangeStartAt == null
              ? RequestableTimes(
                professionalProfileId: loaded.professionalProfileId,
                timezone: loaded.timezone,
                durationMinutes: loaded.durationMinutes,
                cadenceMinutes: loaded.cadenceMinutes,
                leadTimeMinutes: loaded.leadTimeMinutes,
                bookingHorizonDays: loaded.bookingHorizonDays,
                times: loaded.times,
                rangeStartAt: rangeStartAt,
                rangeEndAt: rangeEndAt,
              )
              : loaded;
      requestableTimes = effectiveLoaded;
      _bookingWindowEndAt = rangeStartAt.add(
        Duration(days: loaded.bookingHorizonDays),
      );
      final selected = selectedTime;
      if (selected != null &&
          !_containsTime(effectiveLoaded, selected.startAt)) {
        selectedTime = null;
        bookingIntent = null;
        await _bookingIntentStore.clear();
        bookingError =
            'The selected time is no longer available. Please choose another.';
      } else if (selected == null && bookingIntent != null) {
        final restored = effectiveLoaded.times.where(
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

  bool get canLoadLaterTimes {
    final rangeEndAt = requestableTimes?.rangeEndAt;
    final bookingWindowEndAt = _bookingWindowEndAt;
    return rangeEndAt != null &&
        bookingWindowEndAt != null &&
        rangeEndAt.isBefore(bookingWindowEndAt) &&
        !isLoadingLaterTimes;
  }

  Future<void> loadLaterTimes() async {
    if (isPreparingBooking ||
        isSubmitting ||
        !canLoadLaterTimes ||
        _timesLoad != null) {
      return;
    }
    final current = requestableTimes!;
    final startAt = current.rangeEndAt!;
    final policyEndAt = _bookingWindowEndAt!;
    final candidateEnd = startAt.add(
      const Duration(days: requestableRangeDays),
    );
    final endAt =
        candidateEnd.isBefore(policyEndAt) ? candidateEnd : policyEndAt;
    isLoadingLaterTimes = true;
    timesError = null;
    _notify();
    try {
      final loaded = await _schedulingRepository.publicRequestableTimes(
        professionalProfileId: professionalProfileId,
        rangeStartAt: startAt,
        rangeEndAt: endAt,
      );
      if (_disposed) return;
      if (!_hasValidTimesContract(loaded) ||
          loaded.rangeStartAt?.toUtc() != startAt.toUtc() ||
          loaded.rangeEndAt == null ||
          loaded.rangeEndAt!.isAfter(endAt) ||
          loaded.timezone != current.timezone ||
          loaded.durationMinutes != current.durationMinutes ||
          loaded.cadenceMinutes != current.cadenceMinutes ||
          loaded.leadTimeMinutes != current.leadTimeMinutes ||
          loaded.bookingHorizonDays != current.bookingHorizonDays) {
        throw const FormatException('Invalid requestable-time page.');
      }
      final merged =
          <int, RequestableTime>{
              for (final time in current.times)
                time.startAt.toUtc().millisecondsSinceEpoch: time,
              for (final time in loaded.times)
                time.startAt.toUtc().millisecondsSinceEpoch: time,
            }.values.toList()
            ..sort((left, right) => left.startAt.compareTo(right.startAt));
      requestableTimes = RequestableTimes(
        professionalProfileId: current.professionalProfileId,
        timezone: loaded.timezone ?? current.timezone,
        durationMinutes: current.durationMinutes,
        cadenceMinutes: current.cadenceMinutes,
        leadTimeMinutes: current.leadTimeMinutes,
        bookingHorizonDays: current.bookingHorizonDays,
        times: merged,
        rangeStartAt: current.rangeStartAt,
        rangeEndAt: loaded.rangeEndAt,
      );
    } catch (_) {
      if (!_disposed) {
        timesError =
            'Could not load later appointment times. Please try again.';
      }
    } finally {
      if (!_disposed) {
        isLoadingLaterTimes = false;
        _notify();
      }
    }
  }

  bool _hasValidTimesContract(RequestableTimes loaded) {
    final timezone = loaded.timezone?.trim();
    final hasRequestableTimes = loaded.times.isNotEmpty;
    return loaded.professionalProfileId == professionalProfileId &&
        (!hasRequestableTimes ||
            (timezone != null &&
                timezone.isNotEmpty &&
                ProfessionalTimeFormatter().isValidTimezone(timezone))) &&
        (hasRequestableTimes ||
            timezone == null ||
            timezone.isEmpty ||
            ProfessionalTimeFormatter().isValidTimezone(timezone)) &&
        loaded.durationMinutes == 30 &&
        loaded.cadenceMinutes == 30 &&
        loaded.leadTimeMinutes == 120 &&
        loaded.bookingHorizonDays == 60 &&
        ((loaded.rangeStartAt == null) == (loaded.rangeEndAt == null)) &&
        (loaded.rangeStartAt == null ||
            loaded.rangeEndAt!.isAfter(loaded.rangeStartAt!)) &&
        loaded.times.every(
          (time) =>
              time.durationMinutes == 30 &&
              (loaded.rangeStartAt == null ||
                  (!time.startAt.isBefore(loaded.rangeStartAt!) &&
                      !time.endAt.isAfter(loaded.rangeEndAt!))),
        );
  }

  Future<void> selectTime(RequestableTime time) async {
    if (isSubmitting || isPreparingBooking) {
      return;
    }
    final available = requestableTimes;
    if (available == null || !_containsTime(available, time.startAt)) {
      return;
    }
    final changed = selectedTime?.startAt.toUtc() != time.startAt.toUtc();
    selectedTime = time;
    bookingError = null;
    bookingReadinessFailed = false;
    if (changed && bookingIntent != null) {
      bookingIntent = _newIntent(
        time,
        accountUserId: bookingIntent!.accountUserId,
      );
      await _bookingIntentStore.save(bookingIntent!);
    }
    _notify();
  }

  Future<void> selectMode(ConsultationMode mode) async {
    if (selectedMode == mode || isSubmitting || isPreparingBooking) {
      return;
    }
    selectedMode = mode;
    bookingError = null;
    bookingReadinessFailed = false;
    final time = selectedTime;
    if (time != null && bookingIntent != null) {
      bookingIntent = _newIntent(
        time,
        accountUserId: bookingIntent!.accountUserId,
      );
      await _bookingIntentStore.save(bookingIntent!);
    }
    _notify();
  }

  Future<void> cancelIntent() async {
    if (isSubmitting || isPreparingBooking) {
      return;
    }
    await _clearIntent();
  }

  Future<void> _clearIntent() async {
    selectedTime = null;
    bookingIntent = null;
    bookingError = null;
    bookingReadinessFailed = false;
    await _bookingIntentStore.clear();
    _notify();
  }

  Future<BookingGateOutcome> prepareBooking() {
    if (_disposed) {
      return Future<BookingGateOutcome>.value(BookingGateOutcome.failure);
    }
    final active = _bookingGateCheck;
    if (active != null) {
      return active;
    }

    isPreparingBooking = true;
    bookingReadinessFailed = false;
    bookingError = null;
    _notify();

    final future = _runPrepareBooking();
    late final Future<BookingGateOutcome> tracked;
    tracked = future.whenComplete(() {
      if (!_disposed && identical(_bookingGateCheck, tracked)) {
        _bookingGateCheck = null;
        isPreparingBooking = false;
        _notify();
      }
    });
    _bookingGateCheck = tracked;
    return tracked;
  }

  Future<BookingGateOutcome> _runPrepareBooking() async {
    try {
      return await _prepareBooking();
    } catch (_) {
      if (_disposed) {
        return BookingGateOutcome.failure;
      }
      bookingReadinessFailed = true;
      bookingError =
          "We couldn't confirm that your account is ready to request an appointment. Please try again.";
      _notify();
      return BookingGateOutcome.failure;
    }
  }

  Future<BookingGateOutcome> _prepareBooking() async {
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
    if (_disposed) {
      return BookingGateOutcome.failure;
    }
    final existing = await _bookingIntentStore.read(now: _clock().toUtc());
    if (_disposed) {
      return BookingGateOutcome.failure;
    }
    var intent =
        existing != null &&
                existing.matches(
                  professionalProfileId: professionalProfileId,
                  startAt: time.startAt,
                  durationMinutes: 30,
                  consultationMode: selectedMode,
                )
            ? existing
            : _newIntent(time, accountUserId: session?.user.id);
    await _bookingIntentStore.save(intent);
    if (_disposed) {
      return BookingGateOutcome.failure;
    }
    bookingIntent = intent;

    if (session == null) {
      _notify();
      return BookingGateOutcome.authenticationRequired;
    }
    if (session.user.role.trim().toUpperCase() != 'PATIENT') {
      await _clearIntent();
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
      await _clearIntent();
      bookingError = 'The saved booking belongs to another account.';
      _notify();
      return BookingGateOutcome.incompatibleRole;
    }
    if (intent.accountUserId == null || intent.accountUserId!.isEmpty) {
      intent = intent.copyWith(accountUserId: accountId);
      await _bookingIntentStore.save(intent);
      bookingIntent = intent;
    }

    final readiness = await _onboardingRepository.accountReadiness();
    if (_disposed) {
      return BookingGateOutcome.failure;
    }
    if (readiness.account.role.trim().toUpperCase() != 'PATIENT') {
      selectedTime = null;
      bookingIntent = null;
      await _bookingIntentStore.clear();
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
        await _clearIntent();
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
        await _clearIntent();
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
        consultationMode: persisted.consultationMode,
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
          await _clearIntent();
          bookingError =
              'This account cannot request patient appointments. '
              'Use a patient account to continue.';
          return BookingSubmissionOutcome.incompatibleRole;
        case 404:
          await _clearIntent();
          professional = null;
          profileNotFound = true;
          return BookingSubmissionOutcome.professionalUnavailable;
        case 409:
          await _clearIntent();
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
      consultationMode: selectedMode,
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
    selectedMode = intent.consultationMode;
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
