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
            ),
          ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeSchedulingRepository implements SchedulingRepository {
  _FakeSchedulingRepository({this.publicWindows, this.failure});

  final List<AvailabilityWindow>? publicWindows;
  final Object? failure;

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
            weekday: 1,
            startMinute: 540,
            endMinute: 1020,
            timezone: 'Africa/Lagos',
            active: true,
          ),
        ],
      ),
    );

    await tester.tap(find.text('View profile').first);
    await tester.pumpAndSettle();

    expect(find.text('Public availability'), findsOneWidget);
    expect(find.text('Day 1: 09:00 - 17:00 (Africa/Lagos)'), findsOneWidget);
    expect(
      find.text('Booking remains deferred until appointment request wiring.'),
      findsOneWidget,
    );
    expect(find.text('Saturday'), findsNothing);
    expect(find.text('10:00am'), findsNothing);
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
