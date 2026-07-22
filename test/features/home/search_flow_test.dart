import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/availability_window.dart';
import 'package:app_t/features/Home/domain/entities/patient_profile.dart';
import 'package:app_t/features/Home/domain/entities/professional_profile.dart';
import 'package:app_t/features/Home/domain/entities/public_professional.dart';
import 'package:app_t/features/Home/presentation/pages/search_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpSearch(
  WidgetTester tester, {
  ProfileRepository? profileRepository,
  SchedulingRepository? schedulingRepository,
  DateTime? now,
}) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: SearchShellPage(
              profileRepository:
                  profileRepository ?? _FakeProfileRepository(failure: null),
              schedulingRepository:
                  schedulingRepository ?? _FakeSchedulingRepository(),
              now: now,
            ),
          ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeSchedulingRepository implements SchedulingRepository {
  _FakeSchedulingRepository({
    this.publicWindows,
    this.failure,
    this.requestFailure,
  });

  final List<AvailabilityWindow>? publicWindows;
  final Object? failure;
  final Object? requestFailure;
  String? requestedProfessionalProfileId;
  DateTime? requestedStartAt;
  int? requestedDurationMinutes;

  @override
  Future<List<AvailabilityWindow>> publicAvailability({
    required String professionalProfileId,
  }) async {
    final error = failure;
    if (error != null) {
      throw error;
    }
    return publicWindows ?? const <AvailabilityWindow>[];
  }

  @override
  Future<AppointmentSummary> acceptAppointment({
    required String appointmentId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppointmentSummary> cancelAppointment({
    required String appointmentId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppointmentSummary> completeAppointment({
    required String appointmentId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppointmentSummary> declineAppointment({
    required String appointmentId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<AppointmentSummary>> ownAppointments() {
    throw UnimplementedError();
  }

  @override
  Future<List<AvailabilityWindow>> ownAvailability() {
    throw UnimplementedError();
  }

  @override
  Future<List<AvailabilityWindow>> replaceOwnAvailability({
    required List<AvailabilityWindowDraft> windows,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppointmentSummary> requestAppointment({
    required String professionalProfileId,
    required DateTime requestedStartAt,
    required int durationMinutes,
  }) async {
    final error = requestFailure;
    if (error != null) {
      throw error;
    }
    requestedProfessionalProfileId = professionalProfileId;
    this.requestedStartAt = requestedStartAt;
    requestedDurationMinutes = durationMinutes;
    return AppointmentSummary(
      id: 'appointment-1',
      patientProfileId: 'patient-1',
      professionalProfileId: professionalProfileId,
      requestedStartAt: requestedStartAt,
      durationMinutes: durationMinutes,
      status: AppointmentStatus.requested,
    );
  }

  @override
  Future<AppointmentSummary> rescheduleAppointment({
    required String appointmentId,
    required DateTime requestedStartAt,
    required int durationMinutes,
  }) {
    throw UnimplementedError();
  }
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({this.publicListing, this.failure});

  final List<PublicProfessional>? publicListing;
  final Object? failure;

  @override
  Future<List<PublicProfessional>> publicProfessionals() async {
    final error = failure;
    if (error != null) {
      throw error;
    }
    return publicListing ?? const <PublicProfessional>[];
  }

  @override
  Future<PatientProfile?> patientMe() => throw UnimplementedError();

  @override
  Future<ProfessionalProfile?> professionalMe() => throw UnimplementedError();

  @override
  Future<PatientProfile> updatePatientMe({
    required String name,
    int? age,
    String? location,
    DateTime? dateOfBirth,
    String? city,
    String? state,
    String? country,
    String? healthInterests,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ProfessionalProfile> updateProfessionalMe({
    required String displayName,
    required String category,
    String? legalName,
    String? specialty,
    String? bio,
    String? licenseNumber,
    String? licensingCouncil,
    String? qualifications,
    int? yearsOfExperience,
    String? practiceName,
    String? practiceAddress,
    String? practiceCity,
    String? practiceState,
    String? practiceCountry,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('search tab shows backend error without fallback content', (
    tester,
  ) async {
    await _pumpSearch(
      tester,
      profileRepository: _FakeProfileRepository(
        failure: const AuthFailure(
          type: AuthFailureType.missingConfiguration,
          message: 'raw config message',
        ),
      ),
    );

    expect(find.text('Search specialists'), findsOneWidget);
    expect(find.text('Available specialists'), findsOneWidget);
    expect(find.text('Backend is not configured yet.'), findsOneWidget);
    expect(find.text('0 found'), findsOneWidget);
    expect(find.text('Dr. Uzo Blessing'), findsNothing);
    expect(find.text('Dr. Chris Amaka'), findsNothing);
  });

  testWidgets('search tab reads public verified professionals', (tester) async {
    await _pumpSearch(
      tester,
      profileRepository: _FakeProfileRepository(
        publicListing: const <PublicProfessional>[
          PublicProfessional(
            id: 'pro_1',
            displayName: 'Dr Backend Public',
            category: 'Cardiology',
            specialty: 'Heart health',
            bio: 'Backend public bio for verified care.',
            verified: true,
          ),
        ],
      ),
    );

    expect(find.text('Dr Backend Public'), findsOneWidget);
    expect(find.text('Cardiology - Heart health'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);
    expect(find.text('Dr. Uzo Blessing'), findsNothing);
  });

  testWidgets('search filters public professionals by specialty', (
    tester,
  ) async {
    await _pumpSearch(
      tester,
      profileRepository: _FakeProfileRepository(
        publicListing: const <PublicProfessional>[
          PublicProfessional(
            id: 'pro_1',
            displayName: 'Dr Heart',
            category: 'Cardiology',
            specialty: 'Heart health',
            bio: 'Backend public bio for cardiology.',
            verified: true,
          ),
          PublicProfessional(
            id: 'pro_2',
            displayName: 'Dr Mind',
            category: 'Psychology',
            specialty: 'Mental wellness',
            bio: 'Backend public bio for psychology.',
            verified: true,
          ),
        ],
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'mental');
    await tester.pumpAndSettle();

    expect(find.text('Dr Mind'), findsOneWidget);
    expect(find.text('Dr Heart'), findsNothing);
  });

  testWidgets('search field filters public professional results', (
    tester,
  ) async {
    await _pumpSearch(
      tester,
      profileRepository: _FakeProfileRepository(
        publicListing: const <PublicProfessional>[
          PublicProfessional(
            id: 'pro_1',
            displayName: 'Dr Backend Heart',
            category: 'Cardiology',
            specialty: 'Heart health',
            bio: 'Backend public bio for cardiology.',
            verified: true,
          ),
          PublicProfessional(
            id: 'pro_2',
            displayName: 'Dr Backend Mind',
            category: 'Psychology',
            specialty: 'Mental wellness',
            bio: 'Backend public bio for psychology.',
            verified: true,
          ),
        ],
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'psychology');
    await tester.pumpAndSettle();

    expect(find.text('Dr Backend Mind'), findsOneWidget);
    expect(find.text('Dr Backend Heart'), findsNothing);
  });

  testWidgets('category chip filters public professional results', (
    tester,
  ) async {
    await _pumpSearch(
      tester,
      profileRepository: _FakeProfileRepository(
        publicListing: const <PublicProfessional>[
          PublicProfessional(
            id: 'pro_1',
            displayName: 'Dr Backend Heart',
            category: 'Cardiology',
            specialty: 'Heart health',
            bio: 'Backend public bio for cardiology.',
            verified: true,
          ),
          PublicProfessional(
            id: 'pro_2',
            displayName: 'Dr Backend Mind',
            category: 'Psychology',
            specialty: 'Mental wellness',
            bio: 'Backend public bio for psychology.',
            verified: true,
          ),
        ],
      ),
    );

    await tester.tap(find.text('Cardiology'));
    await tester.pumpAndSettle();

    expect(find.text('Dr Backend Heart'), findsOneWidget);
    expect(find.text('Dr Backend Mind'), findsNothing);
  });

  testWidgets('booking action remains disabled for public listing', (
    tester,
  ) async {
    await _pumpSearch(
      tester,
      profileRepository: _FakeProfileRepository(
        publicListing: const <PublicProfessional>[
          PublicProfessional(
            id: 'pro_1',
            displayName: 'Dr Backend Public',
            category: 'Cardiology',
            specialty: 'Heart health',
            bio: 'Backend public bio for verified care.',
            verified: true,
          ),
        ],
      ),
    );

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Booking deferred'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('profile action opens public listing profile sheet', (
    tester,
  ) async {
    await _pumpSearch(
      tester,
      profileRepository: _FakeProfileRepository(
        publicListing: const <PublicProfessional>[
          PublicProfessional(
            id: 'pro_1',
            displayName: 'Dr Backend Public',
            category: 'Cardiology',
            specialty: 'Heart health',
            bio: 'Backend public bio for verified care.',
            verified: true,
          ),
        ],
      ),
    );

    await tester.tap(find.text('View profile').first);
    await tester.pumpAndSettle();

    expect(find.text('Backend public bio for verified care.'), findsOneWidget);
    expect(
      find.text('No public availability is available yet.'),
      findsOneWidget,
    );
  });

  testWidgets('profile sheet reads public availability without local slots', (
    tester,
  ) async {
    await _pumpSearch(
      tester,
      profileRepository: _FakeProfileRepository(
        publicListing: const <PublicProfessional>[
          PublicProfessional(
            id: 'pro_1',
            displayName: 'Dr Backend Public',
            category: 'Cardiology',
            specialty: 'Heart health',
            bio: 'Backend public bio for verified care.',
            verified: true,
          ),
        ],
      ),
      schedulingRepository: _FakeSchedulingRepository(
        publicWindows: const <AvailabilityWindow>[
          AvailabilityWindow(
            id: 'availability-1',
            weekday: DateTime.tuesday,
            startMinute: 540,
            endMinute: 1020,
            timezone: 'Africa/Lagos',
            active: true,
          ),
        ],
      ),
      now: DateTime(2026, 7, 14, 8),
    );

    await tester.tap(find.text('View profile').first);
    await tester.pumpAndSettle();

    expect(find.text('Public availability'), findsOneWidget);
    expect(find.text('Day 2: 09:00 - 17:00 (Africa/Lagos)'), findsOneWidget);
    expect(find.text('Request appointment'), findsOneWidget);
    expect(find.text('07/14 09:00-09:30 (30 min)'), findsOneWidget);
    expect(find.text('Saturday'), findsNothing);
    expect(find.text('10:00am'), findsNothing);
    expect(find.text('Payment'), findsNothing);
    expect(find.text('Notification'), findsNothing);
    expect(find.text('Calendar'), findsNothing);
    expect(find.text('Review'), findsNothing);
    expect(find.text('Notes'), findsNothing);
    expect(find.text('Prescription'), findsNothing);
    expect(find.text('Call'), findsNothing);
    expect(find.text('Admin'), findsNothing);
  });

  testWidgets('profile sheet sends selected generated appointment request', (
    tester,
  ) async {
    final schedulingRepository = _FakeSchedulingRepository(
      publicWindows: const <AvailabilityWindow>[
        AvailabilityWindow(
          id: 'availability-1',
          weekday: DateTime.tuesday,
          startMinute: 9 * 60,
          endMinute: 10 * 60,
          timezone: 'Africa/Lagos',
          active: true,
        ),
      ],
    );

    await _pumpSearch(
      tester,
      profileRepository: _FakeProfileRepository(
        publicListing: const <PublicProfessional>[
          PublicProfessional(
            id: 'pro_1',
            displayName: 'Dr Backend Public',
            category: 'Cardiology',
            specialty: 'Heart health',
            bio: 'Backend public bio for verified care.',
            verified: true,
          ),
        ],
      ),
      schedulingRepository: schedulingRepository,
      now: DateTime(2026, 7, 14, 8),
    );

    await tester.tap(find.text('View profile').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('07/14 09:00-09:45 (45 min)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Request selected time'));
    await tester.pumpAndSettle();

    expect(schedulingRepository.requestedProfessionalProfileId, 'pro_1');
    expect(schedulingRepository.requestedStartAt, DateTime(2026, 7, 14, 9));
    expect(schedulingRepository.requestedDurationMinutes, 45);
    expect(
      find.text('Request sent. Backend status: REQUESTED.'),
      findsOneWidget,
    );
    expect(find.textContaining('Confirmed locally'), findsNothing);
  });

  testWidgets('profile sheet shows request error without fake success', (
    tester,
  ) async {
    await _pumpSearch(
      tester,
      profileRepository: _FakeProfileRepository(
        publicListing: const <PublicProfessional>[
          PublicProfessional(
            id: 'pro_1',
            displayName: 'Dr Backend Public',
            category: 'Cardiology',
            specialty: 'Heart health',
            bio: 'Backend public bio for verified care.',
            verified: true,
          ),
        ],
      ),
      schedulingRepository: _FakeSchedulingRepository(
        publicWindows: const <AvailabilityWindow>[
          AvailabilityWindow(
            id: 'availability-1',
            weekday: DateTime.tuesday,
            startMinute: 9 * 60,
            endMinute: 10 * 60,
            timezone: 'Africa/Lagos',
            active: true,
          ),
        ],
        requestFailure: const AuthFailure(
          type: AuthFailureType.validation,
          message: 'raw unavailable slot',
        ),
      ),
      now: DateTime(2026, 7, 14, 8),
    );

    await tester.tap(find.text('View profile').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Request selected time'));
    await tester.pumpAndSettle();

    expect(
      find.text('Please choose an available time and try again.'),
      findsOneWidget,
    );
    expect(find.text('raw unavailable slot'), findsNothing);
    expect(find.textContaining('Request sent.'), findsNothing);
  });

  testWidgets('profile sheet shows availability error without fallback slots', (
    tester,
  ) async {
    await _pumpSearch(
      tester,
      profileRepository: _FakeProfileRepository(
        publicListing: const <PublicProfessional>[
          PublicProfessional(
            id: 'pro_1',
            displayName: 'Dr Backend Public',
            category: 'Cardiology',
            specialty: 'Heart health',
            bio: 'Backend public bio for verified care.',
            verified: true,
          ),
        ],
      ),
      schedulingRepository: _FakeSchedulingRepository(
        failure: const AuthFailure(
          type: AuthFailureType.server,
          message: 'raw backend error',
        ),
      ),
    );

    await tester.tap(find.text('View profile').first);
    await tester.pumpAndSettle();

    expect(
      find.text('Service is unavailable. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('raw backend error'), findsNothing);
    expect(find.text('Saturday'), findsNothing);
    expect(find.text('10:00am'), findsNothing);
  });
}
