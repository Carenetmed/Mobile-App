import 'dart:async';

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/data/storage/booking_intent_store.dart';
import 'package:app_t/features/Home/domain/entities/account_readiness.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/booking_intent.dart';
import 'package:app_t/features/Home/domain/entities/consultation_price.dart';
import 'package:app_t/features/Home/domain/entities/public_professional.dart';
import 'package:app_t/features/Home/domain/entities/requestable_times.dart';
import 'package:app_t/features/Home/domain/services/booking_idempotency_key_factory.dart';
import 'package:app_t/features/Home/domain/services/booking_resume_service.dart';
import 'package:app_t/features/Home/domain/services/professional_time_formatter.dart';
import 'package:app_t/features/Home/presentation/state/professional_booking_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Booking intent persistence', () {
    test('round-trips only the structured navigation intent', () {
      final intent = _intent();
      final restored = BookingIntent.fromJson(intent.toJson());

      expect(restored.professionalProfileId, 'pro-1');
      expect(restored.startAt, DateTime.parse('2026-07-25T08:00:00Z'));
      expect(restored.durationMinutes, 30);
      expect(restored.consultationMode, ConsultationMode.video);
      expect(restored.idempotencyKey, 'booking-key-12345678');
      expect(restored.resumeRoute, RouteName.specialistDetails);
      expect(restored.toJson().containsKey('accessToken'), isFalse);
      expect(restored.toJson().containsKey('password'), isFalse);
    });

    test('expires and clears after 24 hours', () async {
      final store = InMemoryBookingIntentStore();
      final intent = _intent(createdAt: DateTime.parse('2026-07-24T00:00:00Z'));
      await store.save(intent);

      expect(
        await store.read(
          now: intent.expiresAt.subtract(const Duration(seconds: 1)),
        ),
        isNotNull,
      );
      expect(await store.read(now: intent.expiresAt), isNull);
      expect(await store.read(), isNull);
    });

    test('secure UUID-style keys are valid and distinct', () {
      final factory = BookingIdempotencyKeyFactory();
      final first = factory.create();
      final second = factory.create();

      expect(
        first,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
      expect(second, isNot(first));
    });
  });

  group('Booking resume authority', () {
    test('unauthenticated intent requires authentication', () async {
      final store = InMemoryBookingIntentStore();
      await store.save(_intent());
      final service = _resumeService(
        store: store,
        sessionStore: InMemorySessionStore(),
      );

      final decision = await service.resolveAfterAuthentication();

      expect(decision.target, BookingResumeTarget.authentication);
      expect(decision.intent?.professionalProfileId, 'pro-1');
    });

    test(
      'ready patient binds the intent to backend session identity',
      () async {
        final store = InMemoryBookingIntentStore();
        await store.save(_intent());
        final service = _resumeService(
          store: store,
          sessionStore: _sessionStore(role: 'PATIENT', userId: 'patient-user'),
        );

        final decision = await service.resolveAfterAuthentication();

        expect(decision.target, BookingResumeTarget.professionalDetail);
        expect(decision.intent?.accountUserId, 'patient-user');
        expect((await store.read())?.accountUserId, 'patient-user');
      },
    );

    test('incomplete patient resumes through onboarding', () async {
      final store = InMemoryBookingIntentStore();
      await store.save(_intent());
      final service = _resumeService(
        store: store,
        sessionStore: _sessionStore(role: 'PATIENT'),
        onboardingRepository: _FakeOnboardingRepository(incomplete: true),
      );

      final decision = await service.resolveAfterAuthentication();

      expect(decision.target, BookingResumeTarget.patientOnboarding);
      expect(await store.read(), isNotNull);
    });

    test(
      'professional or changed account fails closed and clears intent',
      () async {
        final store = InMemoryBookingIntentStore();
        await store.save(_intent(accountUserId: 'original-user'));
        final service = _resumeService(
          store: store,
          sessionStore: _sessionStore(
            role: 'PROFESSIONAL',
            userId: 'other-user',
          ),
        );

        final decision = await service.resolveAfterAuthentication();

        expect(decision.target, BookingResumeTarget.incompatibleRole);
        expect(await store.read(), isNull);
      },
    );
  });

  group('Professional booking controller', () {
    test('loads bounded requestable-time pages and merges them', () async {
      final now = DateTime.parse('2026-07-24T12:00:00Z');
      final firstEnd = now.add(const Duration(days: 14));
      final secondEnd = firstEnd.add(const Duration(days: 14));
      final laterStart = DateTime.parse('2026-08-08T08:00:00Z');
      final scheduling = _FakeSchedulingRepository(
        responses: <RequestableTimes>[
          _times(rangeStartAt: now, rangeEndAt: firstEnd),
          RequestableTimes(
            professionalProfileId: 'pro-1',
            timezone: 'Africa/Lagos',
            durationMinutes: 30,
            cadenceMinutes: 30,
            leadTimeMinutes: 120,
            bookingHorizonDays: 60,
            rangeStartAt: firstEnd,
            rangeEndAt: secondEnd,
            times: <RequestableTime>[
              RequestableTime(
                startAt: laterStart,
                endAt: laterStart.add(const Duration(minutes: 30)),
              ),
              RequestableTime(
                startAt: laterStart,
                endAt: laterStart.add(const Duration(minutes: 30)),
              ),
            ],
          ),
        ],
      );
      final controller = _controller(scheduling: scheduling, clock: () => now);
      addTearDown(controller.dispose);

      await controller.initialize();
      await controller.loadLaterTimes();

      expect(scheduling.requestedRanges, <(DateTime?, DateTime?)>[
        (now, firstEnd),
        (firstEnd, secondEnd),
      ]);
      expect(
        controller.requestableTimes!.times.map((time) => time.startAt),
        <DateTime>[_firstStart, laterStart],
      );
      expect(controller.requestableTimes!.rangeEndAt, secondEnd);
    });

    test('serializes repeated later-page requests', () async {
      final now = DateTime.parse('2026-07-24T12:00:00Z');
      final firstEnd = now.add(const Duration(days: 14));
      final secondEnd = firstEnd.add(const Duration(days: 14));
      final laterPage = Completer<RequestableTimes>();
      final scheduling = _FakeSchedulingRepository(
        responses: <RequestableTimes>[
          _times(rangeStartAt: now, rangeEndAt: firstEnd),
        ],
        timesCompleters: <Completer<RequestableTimes>?>[null, laterPage],
      );
      final controller = _controller(scheduling: scheduling, clock: () => now);
      addTearDown(controller.dispose);
      await controller.initialize();

      final first = controller.loadLaterTimes();
      final second = controller.loadLaterTimes();
      await Future<void>.delayed(Duration.zero);
      expect(scheduling.responseIndex, 2);
      laterPage.complete(
        _times(empty: true, rangeStartAt: firstEnd, rangeEndAt: secondEnd),
      );
      await Future.wait(<Future<void>>[first, second]);

      expect(controller.requestableTimes!.rangeEndAt, secondEnd);
      expect(controller.timesError, isNull);
    });

    test('later-page failure preserves previously loaded times', () async {
      final now = DateTime.parse('2026-07-24T12:00:00Z');
      final firstEnd = now.add(const Duration(days: 14));
      final scheduling = _FakeSchedulingRepository(
        responses: <RequestableTimes>[
          _times(rangeStartAt: now, rangeEndAt: firstEnd),
        ],
        timesFailures: <Object?>[null, StateError('offline')],
      );
      final controller = _controller(scheduling: scheduling, clock: () => now);
      addTearDown(controller.dispose);
      await controller.initialize();

      await controller.loadLaterTimes();

      expect(controller.requestableTimes!.times.single.startAt, _firstStart);
      expect(controller.requestableTimes!.rangeEndAt, firstEnd);
      expect(controller.timesError, contains('Could not load later'));
    });

    test('accepts an empty backend schedule without a timezone', () async {
      final controller = _controller(
        scheduling: _FakeSchedulingRepository(
          responses: <RequestableTimes>[_emptyTimesWithoutTimezone()],
        ),
      );
      addTearDown(controller.dispose);

      await controller.initialize();

      expect(controller.requestableTimes, isNotNull);
      expect(controller.requestableTimes!.times, isEmpty);
      expect(controller.timesError, isNull);
    });

    test('rejects non-empty backend times without a timezone', () async {
      final controller = _controller(
        scheduling: _FakeSchedulingRepository(
          responses: <RequestableTimes>[
            RequestableTimes(
              professionalProfileId: 'pro-1',
              timezone: null,
              durationMinutes: 30,
              cadenceMinutes: 30,
              leadTimeMinutes: 120,
              bookingHorizonDays: 60,
              times: <RequestableTime>[
                RequestableTime(
                  startAt: _firstStart,
                  endAt: _firstStart.add(const Duration(minutes: 30)),
                ),
              ],
            ),
          ],
        ),
      );
      addTearDown(controller.dispose);

      await controller.initialize();

      expect(controller.requestableTimes, isNull);
      expect(controller.timesError, contains('Could not load'));
    });

    test('time change replaces the idempotency key', () async {
      final store = InMemoryBookingIntentStore();
      final scheduling = _FakeSchedulingRepository(
        responses: <RequestableTimes>[_times(twoTimes: true)],
      );
      final controller = _controller(store: store, scheduling: scheduling);
      addTearDown(controller.dispose);
      await controller.initialize();

      await controller.selectTime(controller.requestableTimes!.times.first);
      expect(await controller.prepareBooking(), BookingGateOutcome.ready);
      final firstKey = controller.bookingIntent!.idempotencyKey;

      await controller.selectTime(controller.requestableTimes!.times.last);
      final secondKey = controller.bookingIntent!.idempotencyKey;

      expect(secondKey, isNot(firstKey));
      expect((await store.read())?.startAt, _secondStart);
    });

    test(
      'concurrent readiness checks share one request and lock selection',
      () async {
        final readiness = Completer<AccountReadiness>();
        final onboarding = _FakeOnboardingRepository(
          readinessCompleter: readiness,
        );
        final controller = _controller(
          scheduling: _FakeSchedulingRepository(
            responses: <RequestableTimes>[_times(twoTimes: true)],
          ),
          onboardingRepository: onboarding,
        );
        addTearDown(controller.dispose);
        await controller.initialize();
        await controller.selectTime(controller.requestableTimes!.times.first);

        final first = controller.prepareBooking();
        final second = controller.prepareBooking();
        expect(identical(first, second), isTrue);
        await Future<void>.delayed(Duration.zero);

        expect(onboarding.calls, 1);
        expect(controller.isPreparingBooking, isTrue);
        await controller.selectTime(controller.requestableTimes!.times.last);
        expect(controller.selectedTime!.startAt, _firstStart);

        readiness.complete(_completeReadiness());
        expect(
          await Future.wait(<Future<BookingGateOutcome>>[first, second]),
          <BookingGateOutcome>[
            BookingGateOutcome.ready,
            BookingGateOutcome.ready,
          ],
        );
        expect(controller.isPreparingBooking, isFalse);
        expect(onboarding.calls, 1);
      },
    );

    test(
      'late readiness response after dispose preserves the saved intent',
      () async {
        final readiness = Completer<AccountReadiness>();
        final store = InMemoryBookingIntentStore();
        final controller = _controller(
          store: store,
          scheduling: _FakeSchedulingRepository(
            responses: <RequestableTimes>[_times()],
          ),
          onboardingRepository: _FakeOnboardingRepository(
            readinessCompleter: readiness,
          ),
        );
        await controller.initialize();
        await controller.selectTime(controller.requestableTimes!.times.first);

        final gate = controller.prepareBooking();
        await Future<void>.delayed(Duration.zero);
        final savedIntent = await store.read();
        expect(savedIntent, isNotNull);

        controller.dispose();
        readiness.complete(
          AccountReadiness(
            account: const ReadinessAccount(
              role: 'PROFESSIONAL',
              status: 'ACTIVE',
              emailVerified: true,
            ),
            patient: null,
            nextAction: 'PROFESSIONAL_SETUP',
            requiredActions: const <String>[],
          ),
        );

        expect(await gate, BookingGateOutcome.failure);
        expect(await store.read(), savedIntent);
        expect(controller.bookingError, isNull);
      },
    );

    test(
      'readiness failure preserves intent and retry reuses its key',
      () async {
        final store = InMemoryBookingIntentStore();
        final onboarding = _FakeOnboardingRepository(
          failures: <Object?>[StateError('private backend error'), null],
        );
        final scheduling = _FakeSchedulingRepository(
          responses: <RequestableTimes>[_times()],
        );
        final controller = _controller(
          store: store,
          scheduling: scheduling,
          onboardingRepository: onboarding,
        );
        addTearDown(controller.dispose);
        await controller.initialize();
        await controller.selectTime(controller.requestableTimes!.times.first);

        expect(await controller.prepareBooking(), BookingGateOutcome.failure);
        final savedIntent = await store.read();
        expect(controller.bookingReadinessFailed, isTrue);
        expect(
          controller.bookingError,
          contains('Could not verify patient readiness'),
        );
        expect(
          controller.bookingError,
          isNot(contains('private backend error')),
        );
        expect(controller.selectedTime!.startAt, _firstStart);
        expect(savedIntent, isNotNull);
        expect(
          controller.bookingIntent!.idempotencyKey,
          savedIntent!.idempotencyKey,
        );
        expect(controller.isPreparingBooking, isFalse);

        expect(await controller.prepareBooking(), BookingGateOutcome.ready);
        expect(onboarding.calls, 2);
        expect(controller.bookingReadinessFailed, isFalse);
        expect(controller.bookingError, isNull);
        expect(
          controller.bookingIntent!.idempotencyKey,
          savedIntent.idempotencyKey,
        );
        expect(scheduling.requestCalls, 0);
      },
    );

    test('network retry reuses the same idempotency key', () async {
      final scheduling = _FakeSchedulingRepository(
        responses: <RequestableTimes>[_times(), _times(), _times()],
        requestFailures: <Object?>[
          const AuthFailure(type: AuthFailureType.network, message: 'timeout'),
          null,
        ],
      );
      final controller = _controller(scheduling: scheduling);
      addTearDown(controller.dispose);
      await controller.initialize();
      await controller.selectTime(controller.requestableTimes!.times.first);
      await controller.prepareBooking();

      expect(await controller.submit(), BookingSubmissionOutcome.uncertain);
      expect(await controller.submit(), BookingSubmissionOutcome.requested);

      expect(scheduling.requestKeys, hasLength(2));
      expect(scheduling.requestKeys.first, scheduling.requestKeys.last);
    });

    test('repeated submit taps share one in-flight request', () async {
      final completer = Completer<AppointmentSummary>();
      final scheduling = _FakeSchedulingRepository(
        responses: <RequestableTimes>[_times(), _times()],
        requestCompleter: completer,
      );
      final controller = _controller(scheduling: scheduling);
      addTearDown(controller.dispose);
      await controller.initialize();
      await controller.selectTime(controller.requestableTimes!.times.first);
      await controller.prepareBooking();

      final first = controller.submit();
      final second = controller.submit();
      await Future<void>.delayed(Duration.zero);
      expect(scheduling.requestCalls, 1);

      completer.complete(_appointment());
      expect(await first, BookingSubmissionOutcome.requested);
      expect(await second, BookingSubmissionOutcome.requested);
      expect(scheduling.requestCalls, 1);
    });

    test('refresh invalidates a selected stale backend time', () async {
      final store = InMemoryBookingIntentStore();
      final scheduling = _FakeSchedulingRepository(
        responses: <RequestableTimes>[_times(), _times(empty: true)],
      );
      final controller = _controller(store: store, scheduling: scheduling);
      addTearDown(controller.dispose);
      await controller.initialize();
      await controller.selectTime(controller.requestableTimes!.times.first);
      await controller.prepareBooking();

      await controller.loadTimes(refresh: true);

      expect(controller.selectedTime, isNull);
      expect(controller.bookingIntent, isNull);
      expect(await store.read(), isNull);
      expect(controller.bookingError, contains('no longer available'));
    });

    test(
      'temporary profile failure preserves a resumable booking intent',
      () async {
        final store = InMemoryBookingIntentStore();
        await store.save(_intent(accountUserId: 'patient-user'));
        final scheduling = _FakeSchedulingRepository();
        final controller = _controller(
          store: store,
          scheduling: scheduling,
          profileRepository: _FakeProfileRepository(
            error: Exception('offline'),
          ),
        );
        addTearDown(controller.dispose);

        await controller.initialize();

        expect(controller.profileError, isNotNull);
        expect(controller.bookingIntent, isNotNull);
        expect(await store.read(), isNotNull);
        expect(scheduling.responseIndex, 0);
      },
    );

    test(
      'authoritative non-bookable profile clears persisted intent',
      () async {
        final store = InMemoryBookingIntentStore();
        await store.save(_intent(accountUserId: 'patient-user'));
        final controller = _controller(
          store: store,
          profileRepository: const _FakeProfileRepository(
            detail: PublicProfessional(
              id: 'pro-1',
              displayName: 'Dr Care',
              category: 'Doctor',
              verified: true,
            ),
          ),
        );
        addTearDown(controller.dispose);

        await controller.initialize();

        expect(controller.bookingIntent, isNull);
        expect(controller.selectedTime, isNull);
        expect(await store.read(), isNull);
      },
    );

    test(
      '401 preserves the booking intent for authentication resume',
      () async {
        final store = InMemoryBookingIntentStore();
        final scheduling = _FakeSchedulingRepository(
          responses: <RequestableTimes>[_times(), _times()],
          requestFailures: const <Object?>[
            AuthFailure(
              type: AuthFailureType.unauthorized,
              message: 'expired',
              statusCode: 401,
            ),
          ],
        );
        final controller = _controller(store: store, scheduling: scheduling);
        addTearDown(controller.dispose);
        await controller.initialize();
        await controller.selectTime(controller.requestableTimes!.times.first);
        await controller.prepareBooking();
        final originalKey = controller.bookingIntent!.idempotencyKey;

        expect(
          await controller.submit(),
          BookingSubmissionOutcome.authenticationRequired,
        );

        expect((await store.read())?.idempotencyKey, originalKey);
        expect(controller.selectedTime, isNotNull);
      },
    );

    test(
      '404 invalidates an unavailable professional booking intent',
      () async {
        final store = InMemoryBookingIntentStore();
        final scheduling = _FakeSchedulingRepository(
          responses: <RequestableTimes>[_times(), _times()],
          requestFailures: const <Object?>[
            AuthFailure(
              type: AuthFailureType.validation,
              message: 'missing',
              statusCode: 404,
            ),
          ],
        );
        final controller = _controller(store: store, scheduling: scheduling);
        addTearDown(controller.dispose);
        await controller.initialize();
        await controller.selectTime(controller.requestableTimes!.times.first);
        await controller.prepareBooking();

        expect(
          await controller.submit(),
          BookingSubmissionOutcome.professionalUnavailable,
        );

        expect(await store.read(), isNull);
        expect(controller.profileNotFound, isTrue);
        expect(controller.selectedTime, isNull);
      },
    );

    test('409 refreshes times and requires explicit reselection', () async {
      final store = InMemoryBookingIntentStore();
      final scheduling = _FakeSchedulingRepository(
        responses: <RequestableTimes>[_times(), _times(), _times(empty: true)],
        requestFailures: const <Object?>[
          AuthFailure(
            type: AuthFailureType.validation,
            message: 'conflict',
            statusCode: 409,
          ),
        ],
      );
      final controller = _controller(store: store, scheduling: scheduling);
      addTearDown(controller.dispose);
      await controller.initialize();
      await controller.selectTime(controller.requestableTimes!.times.first);
      await controller.prepareBooking();

      expect(await controller.submit(), BookingSubmissionOutcome.staleTime);

      expect(await store.read(), isNull);
      expect(controller.selectedTime, isNull);
      expect(controller.requestableTimes?.times, isEmpty);
      expect(controller.bookingError, contains('no longer available'));
    });
  });

  group('Professional timezone display', () {
    test('renders Africa/Lagos independently of device time', () {
      final labels = ProfessionalTimeFormatter().format(
        utcStartAt: DateTime.parse('2026-07-25T08:00:00Z'),
        professionalTimezone: 'Africa/Lagos',
      );

      expect(labels.professionalTime, '9:00 AM');
      expect(labels.professionalTimezone, 'Africa/Lagos');
    });

    test('uses IANA daylight-saving rules', () {
      final labels = ProfessionalTimeFormatter().format(
        utcStartAt: DateTime.parse('2026-03-08T07:30:00Z'),
        professionalTimezone: 'America/New_York',
      );

      expect(labels.professionalTime, '3:30 AM');
    });
  });
}

BookingIntent _intent({String? accountUserId, DateTime? createdAt}) {
  final created = (createdAt ?? DateTime.now()).toUtc();
  return BookingIntent(
    professionalProfileId: 'pro-1',
    startAt: DateTime.parse('2026-07-25T08:00:00Z'),
    endAt: DateTime.parse('2026-07-25T08:30:00Z'),
    durationMinutes: 30,
    idempotencyKey: 'booking-key-12345678',
    resumeRoute: RouteName.specialistDetails,
    createdAt: created,
    expiresAt: created.add(const Duration(hours: 24)),
    accountUserId: accountUserId,
  );
}

BookingResumeService _resumeService({
  required BookingIntentStore store,
  required SessionStore sessionStore,
  OnboardingRepository? onboardingRepository,
}) {
  return BookingResumeService(
    bookingIntentStore: store,
    sessionStore: sessionStore,
    onboardingRepository: onboardingRepository ?? _FakeOnboardingRepository(),
  );
}

ProfessionalBookingController _controller({
  BookingIntentStore? store,
  _FakeSchedulingRepository? scheduling,
  ProfileRepository? profileRepository,
  OnboardingRepository? onboardingRepository,
  DateTime Function()? clock,
}) {
  return ProfessionalBookingController(
    professionalProfileId: 'pro-1',
    profileRepository: profileRepository ?? const _FakeProfileRepository(),
    schedulingRepository: scheduling ?? _FakeSchedulingRepository(),
    bookingIntentStore: store ?? InMemoryBookingIntentStore(),
    sessionStore: _sessionStore(role: 'PATIENT'),
    onboardingRepository: onboardingRepository ?? _FakeOnboardingRepository(),
    clock: clock ?? () => DateTime.now().toUtc(),
  );
}

class _FakeProfileRepository implements ProfileRepository {
  const _FakeProfileRepository({
    this.detail = const PublicProfessional(
      id: 'pro-1',
      displayName: 'Dr Care',
      category: 'Doctor',
      verified: true,
      bookable: true,
      consultationPrice: ConsultationPrice(
        amountMinor: 1500000,
        currency: 'NGN',
      ),
    ),
    this.error,
  });

  final PublicProfessional? detail;
  final Object? error;

  @override
  Future<PublicProfessional?> publicProfessionalById({
    required String professionalProfileId,
  }) async {
    if (error != null) {
      throw error!;
    }
    return detail;
  }

  @override
  Future<List<PublicProfessional>> publicProfessionals() {
    throw StateError('Directory must not be used.');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSchedulingRepository implements SchedulingRepository {
  _FakeSchedulingRepository({
    List<RequestableTimes>? responses,
    this.requestFailures = const <Object?>[],
    this.requestCompleter,
    this.timesFailures = const <Object?>[],
    this.timesCompleters = const <Completer<RequestableTimes>?>[],
  }) : responses = responses ?? <RequestableTimes>[_times()];

  final List<RequestableTimes> responses;
  final List<Object?> requestFailures;
  final Completer<AppointmentSummary>? requestCompleter;
  final List<Object?> timesFailures;
  final List<Completer<RequestableTimes>?> timesCompleters;
  int responseIndex = 0;
  int requestCalls = 0;
  final List<String> requestKeys = <String>[];
  final List<(DateTime?, DateTime?)> requestedRanges =
      <(DateTime?, DateTime?)>[];

  @override
  Future<RequestableTimes> publicRequestableTimes({
    required String professionalProfileId,
    DateTime? rangeStartAt,
    DateTime? rangeEndAt,
  }) async {
    requestedRanges.add((rangeStartAt, rangeEndAt));
    final callIndex = responseIndex;
    final responseListIndex =
        callIndex < responses.length ? callIndex : responses.length - 1;
    responseIndex += 1;
    if (callIndex < timesFailures.length && timesFailures[callIndex] != null) {
      throw timesFailures[callIndex]!;
    }
    if (callIndex < timesCompleters.length &&
        timesCompleters[callIndex] != null) {
      return timesCompleters[callIndex]!.future;
    }
    return responses[responseListIndex];
  }

  @override
  Future<AppointmentSummary> requestAppointment({
    required String professionalProfileId,
    required DateTime requestedStartAt,
    required int durationMinutes,
    required String idempotencyKey,
    ConsultationMode consultationMode = ConsultationMode.video,
  }) async {
    final index = requestCalls;
    requestCalls += 1;
    requestKeys.add(idempotencyKey);
    if (index < requestFailures.length && requestFailures[index] != null) {
      throw requestFailures[index]!;
    }
    if (requestCompleter != null) {
      return requestCompleter!.future;
    }
    return _appointment();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOnboardingRepository implements OnboardingRepository {
  _FakeOnboardingRepository({
    this.incomplete = false,
    this.failures = const <Object?>[],
    this.readinessCompleter,
  });

  final bool incomplete;
  final List<Object?> failures;
  final Completer<AccountReadiness>? readinessCompleter;
  int calls = 0;

  @override
  Future<AccountReadiness> accountReadiness() async {
    final call = calls++;
    if (call < failures.length && failures[call] != null) {
      throw failures[call]!;
    }
    final pending = readinessCompleter;
    if (pending != null) {
      return pending.future;
    }
    return _completeReadiness(incomplete: incomplete);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AccountReadiness _completeReadiness({bool incomplete = false}) {
  return AccountReadiness(
    account: const ReadinessAccount(
      role: 'PATIENT',
      status: 'ACTIVE',
      emailVerified: true,
    ),
    patient: PatientReadiness(
      profileStatus: incomplete ? 'INCOMPLETE' : 'COMPLETE',
      requiredFields: incomplete ? const <String>['name'] : const <String>[],
    ),
    nextAction: incomplete ? 'PATIENT_SETUP' : 'PATIENT_BOOKING_GATE',
    requiredActions: incomplete ? const <String>['PATIENT_name'] : const [],
  );
}

SessionStore _sessionStore({
  required String role,
  String userId = 'patient-user',
}) {
  return InMemorySessionStore()..save(
    AuthSessionModel.fromJson(<String, dynamic>{
      'accessToken': 'access-token',
      'refreshToken': 'refresh-token',
      'expiresIn': 900,
      'user': <String, dynamic>{
        'id': userId,
        'email': 'care@example.com',
        'role': role,
        'status': 'ACTIVE',
        'emailVerified': true,
      },
    }),
  );
}

final DateTime _firstStart = DateTime.parse('2026-07-25T08:00:00Z');
final DateTime _secondStart = DateTime.parse('2026-07-25T08:30:00Z');

RequestableTimes _times({
  bool empty = false,
  bool twoTimes = false,
  DateTime? rangeStartAt,
  DateTime? rangeEndAt,
}) {
  return RequestableTimes(
    professionalProfileId: 'pro-1',
    timezone: 'Africa/Lagos',
    durationMinutes: 30,
    cadenceMinutes: 30,
    leadTimeMinutes: 120,
    bookingHorizonDays: 60,
    rangeStartAt: rangeStartAt,
    rangeEndAt: rangeEndAt,
    times:
        empty
            ? const <RequestableTime>[]
            : <RequestableTime>[
              RequestableTime(
                startAt: _firstStart,
                endAt: _firstStart.add(const Duration(minutes: 30)),
              ),
              if (twoTimes)
                RequestableTime(
                  startAt: _secondStart,
                  endAt: _secondStart.add(const Duration(minutes: 30)),
                ),
            ],
  );
}

RequestableTimes _emptyTimesWithoutTimezone() {
  return const RequestableTimes(
    professionalProfileId: 'pro-1',
    timezone: null,
    durationMinutes: 30,
    cadenceMinutes: 30,
    leadTimeMinutes: 120,
    bookingHorizonDays: 60,
    times: <RequestableTime>[],
  );
}

AppointmentSummary _appointment() {
  return AppointmentSummary(
    id: 'appointment-1',
    patientProfileId: 'patient-1',
    professionalProfileId: 'pro-1',
    requestedStartAt: _firstStart,
    durationMinutes: 30,
    status: AppointmentStatus.requested,
  );
}
