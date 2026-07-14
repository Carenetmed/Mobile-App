import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/availability_window.dart';
import 'package:app_t/features/Home/domain/entities/patient_profile.dart';
import 'package:app_t/features/Home/domain/entities/professional_profile.dart';
import 'package:app_t/features/Home/domain/entities/public_professional.dart';
import 'package:app_t/features/Home/presentation/pages/specialist_details_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpSpecialistDetails(
  WidgetTester tester, {
  String? specialistId = 'pro_1',
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
            home: SpecialistDetailsShellPage(
              specialistId: specialistId,
              profileRepository: profileRepository ?? _FakeProfileRepository(),
              schedulingRepository:
                  schedulingRepository ?? _FakeSchedulingRepository(),
              now: now ?? DateTime(2026, 7, 14, 8),
            ),
          ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({this.publicListing});

  final List<PublicProfessional>? publicListing;

  @override
  Future<List<PublicProfessional>> publicProfessionals() async {
    return publicListing ??
        const <PublicProfessional>[
          PublicProfessional(
            id: 'pro_1',
            displayName: 'Dr Backend Details',
            category: 'Cardiology',
            specialty: 'Heart health',
            bio: 'Backend detail summary from the public listing.',
            verified: true,
          ),
        ];
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
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ProfessionalProfile> updateProfessionalMe({
    required String displayName,
    required String category,
    String? specialty,
    String? bio,
  }) {
    throw UnimplementedError();
  }
}

class _FakeSchedulingRepository implements SchedulingRepository {
  _FakeSchedulingRepository({this.failure, this.requestFailure});

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
    return const <AvailabilityWindow>[
      AvailabilityWindow(
        id: 'availability-1',
        weekday: DateTime.tuesday,
        startMinute: 9 * 60,
        endMinute: 10 * 60,
        timezone: 'Africa/Lagos',
        active: true,
      ),
    ];
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
  Future<AppointmentSummary> rescheduleAppointment({
    required String appointmentId,
    required DateTime requestedStartAt,
    required int durationMinutes,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets(
    'specialist details reads backend professional and availability',
    (tester) async {
      await _pumpSpecialistDetails(tester);

      expect(find.text('Specialist Details'), findsOneWidget);
      expect(find.text('Dr Backend Details'), findsOneWidget);
      expect(find.text('Cardiology - Heart health'), findsOneWidget);
      expect(
        find.text('Backend detail summary from the public listing.'),
        findsOneWidget,
      );
      expect(find.text('Public availability'), findsOneWidget);
      expect(find.text('Day 2: 09:00 - 10:00 (Africa/Lagos)'), findsOneWidget);
      expect(find.text('Request appointment'), findsOneWidget);
      expect(find.text('07/14 09:00-09:30 (30 min)'), findsOneWidget);
      expect(find.text('Saturday'), findsNothing);
      expect(find.text('10:00am'), findsNothing);
      expect(find.text('Review'), findsNothing);
      expect(find.text('Payment'), findsNothing);
      expect(find.text('Calendar'), findsNothing);
      expect(find.text('Admin'), findsNothing);
    },
  );

  testWidgets('specialist details sends selected backend appointment request', (
    tester,
  ) async {
    final schedulingRepository = _FakeSchedulingRepository();

    await _pumpSpecialistDetails(
      tester,
      schedulingRepository: schedulingRepository,
    );

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

  testWidgets('specialist details shows safe availability failure', (
    tester,
  ) async {
    await _pumpSpecialistDetails(
      tester,
      schedulingRepository: _FakeSchedulingRepository(
        failure: const AuthFailure(
          type: AuthFailureType.server,
          message: 'raw scheduling failure',
        ),
      ),
    );

    expect(
      find.text('Service is unavailable. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('raw scheduling failure'), findsNothing);
    expect(find.text('Saturday'), findsNothing);
    expect(find.text('10:00am'), findsNothing);
  });

  testWidgets('specialist details shows request failure without fake success', (
    tester,
  ) async {
    await _pumpSpecialistDetails(
      tester,
      schedulingRepository: _FakeSchedulingRepository(
        requestFailure: const AuthFailure(
          type: AuthFailureType.validation,
          message: 'raw unavailable slot',
        ),
      ),
    );

    await tester.tap(find.text('Request selected time'));
    await tester.pumpAndSettle();

    expect(
      find.text('Please choose an available time and try again.'),
      findsOneWidget,
    );
    expect(find.text('raw unavailable slot'), findsNothing);
    expect(find.textContaining('Request sent.'), findsNothing);
    expect(find.textContaining('Confirmed locally'), findsNothing);
  });

  testWidgets('specialist details handles unresolved backend professional id', (
    tester,
  ) async {
    await _pumpSpecialistDetails(
      tester,
      specialistId: 'missing',
      profileRepository: _FakeProfileRepository(
        publicListing: const <PublicProfessional>[
          PublicProfessional(
            id: 'pro_1',
            displayName: 'Dr Backend Details',
            category: 'Cardiology',
            specialty: 'Heart health',
            verified: true,
          ),
        ],
      ),
    );

    expect(
      find.text('Backend professional could not be found.'),
      findsOneWidget,
    );
    expect(find.text('Dr. Uzo Blessing'), findsNothing);
    expect(find.text('Saturday'), findsNothing);
  });
}
