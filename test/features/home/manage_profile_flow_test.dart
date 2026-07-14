import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/availability_window.dart';
import 'package:app_t/features/Home/domain/entities/patient_profile.dart';
import 'package:app_t/features/Home/domain/entities/professional_profile.dart';
import 'package:app_t/features/Home/domain/entities/public_professional.dart';
import 'package:app_t/features/Home/presentation/pages/account_shell.dart';
import 'package:app_t/features/Home/presentation/pages/add_description_shell.dart';
import 'package:app_t/features/Home/presentation/pages/edit_your_name_shell.dart';
import 'package:app_t/features/Home/presentation/pages/edit_your_website_shell.dart';
import 'package:app_t/features/Home/presentation/pages/manage_profile_shell.dart';
import 'package:app_t/features/Home/presentation/pages/selected_dates_shell.dart';
import 'package:app_t/features/Home/presentation/pages/set_address_shell.dart';
import 'package:app_t/features/Messaging/presentation/pages/Messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpManageProfile(
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
            home: ManageProfileShellPage(
              profileRepository: profileRepository ?? _FakeProfileRepository(),
            ),
            routes: <String, WidgetBuilder>{
              RouteName.settings: (_) => const SettingsProfilePage(),
              RouteName.editYourName: (_) => const EditYourNameShellPage(),
              RouteName.editYourWebsite:
                  (_) => const EditYourWebsiteShellPage(),
              RouteName.addDescription:
                  (_) => AddDescriptionShellPage(
                    profileRepository:
                        profileRepository ?? _FakeProfileRepository(),
                  ),
              RouteName.setAddress: (_) => const SetAddressShellPage(),
              RouteName.messages: (_) => const MessagesPage(),
              RouteName.selectedDates:
                  (_) => SelectedDatesShellPage(
                    schedulingRepository:
                        schedulingRepository ?? _FakeSchedulingRepository(),
                    initialDate: DateTime(2026, 7, 14),
                  ),
            },
          ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({
    this.professionalProfile,
    this.failure,
    this.updateFailure,
  });

  ProfessionalProfile? professionalProfile;
  final Object? failure;
  final Object? updateFailure;
  String? lastDisplayName;
  String? lastCategory;
  String? lastSpecialty;
  String? lastBio;

  @override
  Future<ProfessionalProfile?> professionalMe() async {
    final error = failure;
    if (error != null) {
      throw error;
    }
    return professionalProfile;
  }

  @override
  Future<PatientProfile?> patientMe() => throw UnimplementedError();

  @override
  Future<List<PublicProfessional>> publicProfessionals() {
    throw UnimplementedError();
  }

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
  }) async {
    final error = updateFailure;
    if (error != null) {
      throw error;
    }
    lastDisplayName = displayName;
    lastCategory = category;
    lastSpecialty = specialty;
    lastBio = bio;
    final updated = ProfessionalProfile(
      id: professionalProfile?.id,
      displayName: displayName,
      category: category,
      specialty: specialty,
      bio: bio,
      verificationStatus: professionalProfile?.verificationStatus,
    );
    professionalProfile = updated;
    return updated;
  }
}

class _FakeSchedulingRepository implements SchedulingRepository {
  _FakeSchedulingRepository({
    this.windows = const <AvailabilityWindow>[],
    this.failure,
    this.replaceFailure,
  });

  final List<AvailabilityWindow> windows;
  final Object? failure;
  final Object? replaceFailure;
  List<AvailabilityWindowDraft>? lastReplacement;

  @override
  Future<List<AvailabilityWindow>> ownAvailability() async {
    final error = failure;
    if (error != null) {
      throw error;
    }
    return windows;
  }

  @override
  Future<List<AvailabilityWindow>> replaceOwnAvailability({
    required List<AvailabilityWindowDraft> windows,
  }) async {
    final error = replaceFailure;
    if (error != null) {
      throw error;
    }
    lastReplacement = windows;
    return windows
        .map(
          (window) => AvailabilityWindow(
            id: 'availability-${window.weekday}',
            weekday: window.weekday,
            startMinute: window.startMinute,
            endMinute: window.endMinute,
            timezone: window.timezone,
            active: window.active,
          ),
        )
        .toList(growable: false);
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
  Future<List<AvailabilityWindow>> publicAvailability({
    required String professionalProfileId,
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

void main() {
  testWidgets('manage profile shows local profile management sections', (
    tester,
  ) async {
    await _pumpManageProfile(tester);

    expect(find.text('Manage Profile'), findsOneWidget);
    expect(find.text('Professional profile'), findsOneWidget);
    expect(
      find.text('Professional profile has not been created yet.'),
      findsOneWidget,
    );
    expect(find.text('Basic'), findsOneWidget);
    expect(find.text('Not available'), findsWidgets);
    expect(find.text('Dr. Lagbaja Omo Tamedu'), findsNothing);
    expect(find.text('Lagbaja Eye Clinic & Consulting firm'), findsNothing);
    expect(find.text('Business'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -650));
    await tester.pumpAndSettle();

    expect(find.text('Articles'), findsOneWidget);
    expect(find.text('Migrating to Linear 101'), findsOneWidget);
  });

  testWidgets('manage profile reads professional self profile', (tester) async {
    await _pumpManageProfile(
      tester,
      profileRepository: _FakeProfileRepository(
        professionalProfile: const ProfessionalProfile(
          id: 'pro_1',
          displayName: 'Dr Backend Profile',
          category: 'Cardiology',
          specialty: 'Heart health',
          bio: 'Backend-owned professional bio for patient-facing care.',
          verificationStatus: 'VERIFIED',
        ),
      ),
    );

    expect(find.text('Dr Backend Profile'), findsWidgets);
    expect(find.text('Cardiology'), findsWidgets);
    expect(find.text('Heart health'), findsOneWidget);
    expect(
      find.text('Backend-owned professional bio for patient-facing care.'),
      findsOneWidget,
    );
    expect(
      find.text('Professional profile has not been created yet.'),
      findsNothing,
    );
  });

  testWidgets('manage profile keeps local screen when profile read fails', (
    tester,
  ) async {
    await _pumpManageProfile(
      tester,
      profileRepository: _FakeProfileRepository(
        failure: const AuthFailure(
          type: AuthFailureType.missingConfiguration,
          message: 'raw config message',
        ),
      ),
    );

    expect(find.text('Backend is not configured yet.'), findsOneWidget);
    expect(find.text('Manage Profile'), findsOneWidget);
    expect(find.text('Not available'), findsWidgets);
    expect(find.text('Dr. Lagbaja Omo Tamedu'), findsNothing);
    expect(find.text('raw config message'), findsNothing);
  });

  testWidgets('business hours reads and saves backend availability', (
    tester,
  ) async {
    final schedulingRepository = _FakeSchedulingRepository(
      windows: const <AvailabilityWindow>[
        AvailabilityWindow(
          id: 'availability-1',
          weekday: DateTime.monday,
          startMinute: 9 * 60,
          endMinute: 17 * 60,
          timezone: 'Africa/Lagos',
          active: true,
        ),
      ],
    );

    await _pumpManageProfile(
      tester,
      schedulingRepository: schedulingRepository,
    );

    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit hours'));
    await tester.pumpAndSettle();

    expect(find.text('Edit business hours'), findsOneWidget);
    expect(find.byType(CalendarDatePicker), findsOneWidget);
    expect(find.text('All day'), findsOneWidget);
    expect(find.text('Weekly availability'), findsOneWidget);
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('09:00 - 17:00'), findsOneWidget);
    expect(find.text('Payment'), findsNothing);
    expect(find.text('Notification'), findsNothing);
    expect(find.text('Calendar sync'), findsNothing);
    expect(find.text('Review'), findsNothing);
    expect(find.text('Prescription'), findsNothing);
    expect(find.text('Call'), findsNothing);
    expect(find.text('Admin'), findsNothing);

    await tester.tap(find.text('Save availability'));
    await tester.pumpAndSettle();

    expect(schedulingRepository.lastReplacement, isNotNull);
    expect(schedulingRepository.lastReplacement, hasLength(2));
    expect(
      schedulingRepository.lastReplacement!.map((window) => window.weekday),
      <int>[DateTime.monday, DateTime.tuesday],
    );
    expect(schedulingRepository.lastReplacement!.last.startMinute, 0);
    expect(schedulingRepository.lastReplacement!.last.endMinute, 24 * 60);
    expect(find.text('Availability saved from backend.'), findsOneWidget);
    expect(find.text('No profile schedule has been saved.'), findsNothing);
  });

  testWidgets(
    'business hours shows safe backend errors without local fallback',
    (tester) async {
      await _pumpManageProfile(
        tester,
        schedulingRepository: _FakeSchedulingRepository(
          failure: const AuthFailure(
            type: AuthFailureType.server,
            message: 'raw availability failure',
          ),
        ),
      );

      await tester.drag(find.byType(ListView), const Offset(0, -450));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit hours'));
      await tester.pumpAndSettle();

      expect(
        find.text('Service is unavailable. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('raw availability failure'), findsNothing);
      expect(find.text('Closed'), findsNothing);
      expect(find.text('Available 24 hours'), findsNothing);
    },
  );

  testWidgets('business hours shows backend empty state honestly', (
    tester,
  ) async {
    await _pumpManageProfile(tester);

    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit hours'));
    await tester.pumpAndSettle();

    expect(find.text('No backend availability is saved yet.'), findsOneWidget);
    expect(find.text('Closed'), findsNothing);
    expect(find.text('Available 24 hours'), findsNothing);
  });

  testWidgets('business hours save failure shows safe error without success', (
    tester,
  ) async {
    await _pumpManageProfile(
      tester,
      schedulingRepository: _FakeSchedulingRepository(
        replaceFailure: const AuthFailure(
          type: AuthFailureType.validation,
          message: 'raw invalid availability',
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit hours'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save availability'));
    await tester.pumpAndSettle();

    expect(
      find.text('Please check the availability and try again.'),
      findsOneWidget,
    );
    expect(find.text('raw invalid availability'), findsNothing);
    expect(find.text('Availability saved from backend.'), findsNothing);
  });

  testWidgets('edit action opens local name draft route', (tester) async {
    await _pumpManageProfile(tester);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit your name'), findsOneWidget);
    expect(find.text('Enter a new name to continue'), findsOneWidget);
    expect(find.text('Your name'), findsWidgets);

    await tester.enterText(find.byType(TextFormField), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Dr. New Name');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Name draft prepared'), findsOneWidget);
    expect(find.text('Dr. New Name'), findsWidgets);
    expect(
      find.textContaining('No profile name has been saved'),
      findsOneWidget,
    );
  });

  testWidgets('basic website action opens local website draft route', (
    tester,
  ) async {
    await _pumpManageProfile(tester);

    await tester.tap(find.text('Edit website'));
    await tester.pumpAndSettle();

    expect(find.text('Edit your website'), findsOneWidget);
    expect(find.text('Add a website'), findsOneWidget);
    expect(find.text('Your website'), findsWidgets);

    await tester.enterText(find.byType(TextFormField), 'not-a-website');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid website'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'exampleclinic.com');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Website draft prepared'), findsOneWidget);
    expect(find.text('exampleclinic.com'), findsWidgets);
    expect(
      find.textContaining('No profile website has been saved'),
      findsOneWidget,
    );
  });

  testWidgets('basic address action opens local address draft route', (
    tester,
  ) async {
    await _pumpManageProfile(tester);

    await tester.tap(find.text('Edit address'));
    await tester.pumpAndSettle();

    expect(find.text('Set address'), findsOneWidget);
    expect(find.text('Your location'), findsWidgets);

    await tester.enterText(find.byType(TextFormField), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Address is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Short');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter at least 10 characters'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField),
      '12 Community Clinic Road, Epe, Lagos',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Address draft prepared'), findsOneWidget);
    expect(find.text('12 Community Clinic Road, Epe, Lagos'), findsWidgets);
    expect(
      find.textContaining('No profile address has been saved'),
      findsOneWidget,
    );
  });

  testWidgets('about action saves professional bio only', (tester) async {
    final repository = _FakeProfileRepository(
      professionalProfile: const ProfessionalProfile(
        id: 'pro_1',
        displayName: 'Dr Backend Profile',
        category: 'Cardiology',
        specialty: 'Heart health',
        bio: 'Existing backend bio for the current professional profile.',
        verificationStatus: 'VERIFIED',
      ),
    );

    await _pumpManageProfile(tester, profileRepository: repository);

    await tester.tap(find.text('Edit description'));
    await tester.pumpAndSettle();

    expect(find.text('Add description'), findsOneWidget);
    expect(find.text('Description'), findsWidgets);

    await tester.enterText(find.byType(TextFormField), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Description is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Short');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter at least 20 characters'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField),
      'Experienced clinician focused on practical community care.',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Description saved'), findsOneWidget);
    expect(
      find.textContaining('Only your professional bio was updated'),
      findsOneWidget,
    );
    expect(repository.lastDisplayName, 'Dr Backend Profile');
    expect(repository.lastCategory, 'Cardiology');
    expect(repository.lastSpecialty, 'Heart health');
    expect(
      repository.lastBio,
      'Experienced clinician focused on practical community care.',
    );
  });

  testWidgets('about action does not create a partial professional profile', (
    tester,
  ) async {
    await _pumpManageProfile(tester);

    await tester.tap(find.text('Edit description'));
    await tester.pumpAndSettle();

    expect(
      find.text('Professional profile has not been created yet.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byType(TextFormField),
      'Experienced clinician focused on practical community care.',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Description saved'), findsNothing);
    expect(
      find.text('Professional profile has not been created yet.'),
      findsOneWidget,
    );
  });

  testWidgets('about action shows safe professional bio save error', (
    tester,
  ) async {
    await _pumpManageProfile(
      tester,
      profileRepository: _FakeProfileRepository(
        professionalProfile: const ProfessionalProfile(
          id: 'pro_1',
          displayName: 'Dr Backend Profile',
          category: 'Cardiology',
          specialty: 'Heart health',
          bio: 'Existing backend bio for the current professional profile.',
          verificationStatus: 'VERIFIED',
        ),
        updateFailure: const AuthFailure(
          type: AuthFailureType.server,
          message: 'raw server details',
        ),
      ),
    );

    await tester.tap(find.text('Edit description'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField),
      'Experienced clinician focused on practical community care.',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text('Service is unavailable. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('raw server details'), findsNothing);
    expect(find.text('Description saved'), findsNothing);
  });

  testWidgets('message action uses existing honest route', (tester) async {
    await _pumpManageProfile(tester);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Message'));
    await tester.pumpAndSettle();

    expect(find.text('Messages'), findsWidgets);
    expect(find.text('Dr. Lagbaja has replied your message.'), findsOneWidget);
  });

  testWidgets('backend dependent management actions are disabled', (
    tester,
  ) async {
    await _pumpManageProfile(tester);

    for (final label in <String>['Events', 'Boost', 'Podcast', 'Share']) {
      final chip = tester.widget<ActionChip>(
        find.widgetWithText(ActionChip, label),
      );
      expect(chip.onPressed, isNull);
    }

    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();

    expect(find.text('Add members'), findsOneWidget);
    expect(find.text('Edit group details'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsWidgets);
  });
}
