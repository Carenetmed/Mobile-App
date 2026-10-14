import 'dart:async';
import 'dart:ui' show SemanticsAction;

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_user.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/data/repositories/verification_repository.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/domain/entities/account_readiness.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/availability_window.dart';
import 'package:app_t/features/Home/domain/entities/onboarding_catalog.dart';
import 'package:app_t/features/Home/domain/entities/patient_profile.dart';
import 'package:app_t/features/Home/domain/entities/professional_profile.dart';
import 'package:app_t/features/Home/domain/entities/public_professional.dart';
import 'package:app_t/features/Home/domain/entities/requestable_times.dart';
import 'package:app_t/features/Home/domain/entities/verification_document.dart';
import 'package:app_t/features/Home/domain/entities/verification_upload_request.dart';
import 'package:app_t/features/Home/presentation/pages/account_shell.dart';
import 'package:app_t/features/Home/presentation/pages/add_description_shell.dart';
import 'package:app_t/features/Home/presentation/pages/edit_professional_details_shell.dart';
import 'package:app_t/features/Home/presentation/pages/edit_your_name_shell.dart';
import 'package:app_t/features/Home/presentation/pages/edit_your_website_shell.dart';
import 'package:app_t/features/Home/presentation/pages/manage_profile_shell.dart';
import 'package:app_t/features/Home/presentation/pages/professional_verification_documents_shell.dart';
import 'package:app_t/features/Home/presentation/pages/selected_dates_shell.dart';
import 'package:app_t/features/Home/presentation/pages/set_address_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpManageProfile(
  WidgetTester tester, {
  ProfileRepository? profileRepository,
  SchedulingRepository? schedulingRepository,
  VerificationRepository? verificationRepository,
  OnboardingRepository? onboardingRepository,
  VerificationDocumentPicker? verificationDocumentPicker,
  Size screenSize = _phoneSize,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  tester.view.physicalSize = screenSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            builder:
                (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                  child: child!,
                ),
            home: ManageProfileShellPage(
              profileRepository: profileRepository ?? _FakeProfileRepository(),
            ),
            routes: <String, WidgetBuilder>{
              RouteName.settings: (_) => const SettingsProfilePage(),
              RouteName.editYourName:
                  (_) => EditYourNameShellPage(
                    profileRepository:
                        profileRepository ?? _FakeProfileRepository(),
                  ),
              RouteName.editProfessionalDetails:
                  (_) => EditProfessionalDetailsShellPage(
                    profileRepository:
                        profileRepository ?? _FakeProfileRepository(),
                  ),
              RouteName.editYourWebsite:
                  (_) => const EditYourWebsiteShellPage(),
              RouteName.addDescription:
                  (_) => AddDescriptionShellPage(
                    profileRepository:
                        profileRepository ?? _FakeProfileRepository(),
                  ),
              RouteName.setAddress: (_) => const SetAddressShellPage(),
              RouteName.professionalVerificationDocuments:
                  (_) => ProfessionalVerificationDocumentsShellPage(
                    verificationRepository:
                        verificationRepository ?? _FakeVerificationRepository(),
                    onboardingRepository:
                        onboardingRepository ?? _FakeOnboardingRepository(),
                    documentPicker:
                        verificationDocumentPicker ??
                        const _FakeVerificationDocumentPicker(),
                  ),
              RouteName.selectedDates:
                  (_) => SelectedDatesShellPage(
                    schedulingRepository:
                        schedulingRepository ?? _FakeSchedulingRepository(),
                    sessionStore: _professionalSessionStore(),
                    initialDate: DateTime(2026, 7, 14),
                  ),
            },
          ),
    ),
  );
  await tester.pumpAndSettle();
}

InMemorySessionStore _professionalSessionStore() {
  return InMemorySessionStore()..save(
    const AuthSessionModel(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      tokenType: 'Bearer',
      expiresIn: 900,
      user: AuthUser(
        id: 'professional-user',
        email: 'professional@carenet.app',
        role: 'PROFESSIONAL',
        status: 'ACTIVE',
        emailVerified: true,
      ),
    ),
  );
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
  Future<PublicProfessional?> publicProfessionalById({
    required String professionalProfileId,
  }) {
    throw UnimplementedError();
  }

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
  Future<RequestableTimes> publicRequestableTimes({
    required String professionalProfileId,
    DateTime? rangeStartAt,
    DateTime? rangeEndAt,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppointmentSummary> requestAppointment({
    required String professionalProfileId,
    required DateTime requestedStartAt,
    required int durationMinutes,
    required String idempotencyKey,
    ConsultationMode consultationMode = ConsultationMode.video,
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

class _FakeVerificationRepository implements VerificationRepository {
  _FakeVerificationRepository({
    this.documentsResult = const <VerificationDocument>[],
    this.failure,
    this.uploadFailure,
    this.holdUpload = false,
  });

  List<VerificationDocument> documentsResult;
  final Object? failure;
  final Object? uploadFailure;
  final bool holdUpload;
  VerificationUploadRequest? lastUploadRequest;

  @override
  Future<List<VerificationDocument>> documents() async {
    final error = failure;
    if (error != null) {
      throw error;
    }
    return documentsResult;
  }

  @override
  Future<VerificationDocument> uploadDocument(
    VerificationUploadRequest request,
  ) async {
    final error = uploadFailure;
    if (error != null) {
      throw error;
    }
    lastUploadRequest = request;
    request.onProgress?.call(0.5);
    if (holdUpload) {
      final cancelled = Completer<void>();
      request.controller?.bind(
        () => cancelled.completeError(const VerificationUploadCancelled()),
      );
      await cancelled.future;
    }
    final document = VerificationDocument(
      id: 'uploaded-document',
      documentType: request.documentType,
      status: 'PENDING',
      storageProvider: 'gcs',
      mimeType: request.mimeType,
      fileSizeBytes: request.fileSizeBytes,
      checksumProvided: false,
      uploadedAt: DateTime.utc(2026, 7, 15),
    );
    documentsResult = <VerificationDocument>[...documentsResult, document];
    return document;
  }
}

class _FakeVerificationDocumentPicker implements VerificationDocumentPicker {
  const _FakeVerificationDocumentPicker({this.file});

  final VerificationPickedFile? file;

  @override
  Future<VerificationPickedFile?> pick() async => file;
}

class _FakeOnboardingRepository implements OnboardingRepository {
  _FakeOnboardingRepository({this.failure});

  final AuthFailure? failure;

  @override
  Future<OnboardingCatalog> onboardingCatalog() async {
    final error = failure;
    if (error != null) {
      throw error;
    }
    return _catalog;
  }

  @override
  Future<AccountReadiness> accountReadiness() async {
    final error = failure;
    if (error != null) {
      throw error;
    }
    return _professionalReadiness;
  }
}

const _professionalReadiness = AccountReadiness(
  account: ReadinessAccount(
    role: 'PROFESSIONAL',
    status: 'ACTIVE',
    emailVerified: true,
  ),
  patient: null,
  professional: ProfessionalReadiness(
    applicationStatus: 'READY_TO_SUBMIT',
    verificationStatus: 'NOT_SUBMITTED',
    countryCode: 'NG',
    professionCode: 'MEDICAL_DOCTOR',
    regulatorCode: 'MDCN',
    requiredProfileFields: <String>[],
    requiredEvidence: <String>[
      'GOVERNMENT_IDENTITY',
      'PROFESSIONAL_REGISTRATION_OR_LICENSE',
      'QUALIFICATION_CERTIFICATE',
    ],
    missingEvidence: <String>[
      'GOVERNMENT_IDENTITY',
      'PROFESSIONAL_REGISTRATION_OR_LICENSE',
    ],
  ),
  nextAction: 'PROFESSIONAL_UPLOAD_EVIDENCE',
  requiredActions: <String>[
    'UPLOAD_GOVERNMENT_IDENTITY',
    'UPLOAD_PROFESSIONAL_REGISTRATION_OR_LICENSE',
  ],
);

const _catalog = OnboardingCatalog(
  launchCountry: 'NG',
  countries: <OnboardingCountry>[
    OnboardingCountry(code: 'NG', name: 'Nigeria', status: 'ACTIVE'),
  ],
  nigeriaStates: <OnboardingRegion>[
    OnboardingRegion(code: 'LA', name: 'Lagos'),
  ],
  professionalCatalog: <ProfessionalCatalogItem>[
    ProfessionalCatalogItem(
      code: 'MEDICAL_DOCTOR',
      label: 'Medical doctor',
      regulatorCode: 'MDCN',
      regulatorName: 'Medical and Dental Council of Nigeria',
      requiredEvidence: <String>[
        'GOVERNMENT_IDENTITY',
        'PROFESSIONAL_REGISTRATION_OR_LICENSE',
        'QUALIFICATION_CERTIFICATE',
      ],
    ),
  ],
  verificationEvidenceTypes: <VerificationEvidenceType>[
    VerificationEvidenceType(
      code: 'GOVERNMENT_IDENTITY',
      label: 'Government identity',
      documentType: 'IDENTITY',
    ),
    VerificationEvidenceType(
      code: 'PROFESSIONAL_REGISTRATION_OR_LICENSE',
      label: 'Professional registration or license',
      documentType: 'LICENSE',
    ),
    VerificationEvidenceType(
      code: 'QUALIFICATION_CERTIFICATE',
      label: 'Qualification certificate',
      documentType: 'CERTIFICATION',
    ),
  ],
  patientHealthInterestCatalog: <PatientHealthInterest>[
    PatientHealthInterest(code: 'PRIMARY_CARE', label: 'Primary care'),
  ],
);

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

    expect(find.text('Articles'), findsNothing);
    expect(find.text('Migrating to Linear 101'), findsNothing);
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

  testWidgets('manage profile remains usable at compact width and large text', (
    tester,
  ) async {
    await _pumpManageProfile(
      tester,
      screenSize: const Size(320, 568),
      textScaler: const TextScaler.linear(2),
      profileRepository: _FakeProfileRepository(
        professionalProfile: const ProfessionalProfile(
          id: 'pro-large-text',
          displayName: 'Dr. A Very Long Professional Display Name',
          category: 'Specialist healthcare consultation category',
          specialty: 'Long specialty label for accessibility testing',
          bio:
              'A backend-owned professional biography with enough text to verify that the profile remains scrollable at enlarged text.',
          verificationStatus: 'VERIFIED',
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Business'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Business'), findsOneWidget);
    expect(find.text('Edit hours'), findsOneWidget);
  });

  testWidgets(
    'professional profile editors have accessible back actions at compact large text',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await _pumpManageProfile(
          tester,
          screenSize: const Size(320, 568),
          textScaler: const TextScaler.linear(2),
          profileRepository: _FakeProfileRepository(
            professionalProfile: const ProfessionalProfile(
              id: 'pro_accessibility',
              displayName: 'Dr. Accessible Profile',
              category: 'Primary care',
              specialty: 'Family medicine',
              bio: 'Backend-owned profile summary.',
              verificationStatus: 'VERIFIED',
            ),
          ),
        );

        const editors = <(String, String)>[
          ('Edit', 'Edit your name'),
          ('Edit category', 'Professional details'),
          ('Edit description', 'Add description'),
        ];

        for (final (entryAction, editorTitle) in editors) {
          final action = find.text(entryAction).last;
          await tester.scrollUntilVisible(
            action,
            160,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          await tester.tap(action);
          await tester.pumpAndSettle();

          expect(find.text(editorTitle), findsOneWidget);
          expect(find.byTooltip('Back'), findsOneWidget);
          final backButton = find.widgetWithIcon(IconButton, Icons.arrow_back);
          expect(backButton, findsOneWidget);
          final backSemantics = find.bySemanticsLabel('Back');
          expect(backSemantics, findsOneWidget);
          final semanticsData =
              tester.getSemantics(backSemantics).getSemanticsData();
          expect(semanticsData.hasAction(SemanticsAction.tap), isTrue);
          expect(tester.getSize(backButton).width, greaterThanOrEqualTo(48));
          expect(tester.getSize(backButton).height, greaterThanOrEqualTo(48));
          expect(tester.takeException(), isNull);

          await tester.tap(backButton);
          await tester.pumpAndSettle();
          expect(find.text('Manage Profile'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('verification metadata remains usable at compact large text', (
    tester,
  ) async {
    await _pumpManageProfile(
      tester,
      screenSize: const Size(320, 568),
      textScaler: const TextScaler.linear(2),
      verificationRepository: _FakeVerificationRepository(
        documentsResult: <VerificationDocument>[
          VerificationDocument(
            id: 'document-with-a-long-backend-owned-identifier',
            documentType: 'license',
            status: 'PENDING',
            storageProvider: 'gcs',
            mimeType: 'application/octet-stream-with-extra-metadata',
            fileSizeBytes: 2048,
            checksumProvided: true,
            uploadedAt: DateTime.utc(2026, 7, 15),
          ),
        ],
      ),
    );

    await tester.tap(find.text('Verification'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    for (var i = 0; i < 10; i++) {
      await tester.drag(find.byType(ListView).last, const Offset(0, -260));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    expect(find.text('Verification documents'), findsOneWidget);
    expect(
      find.text('document-with-a-long-backend-owned-identifier'),
      findsNothing,
    );
    expect(find.text('File type unavailable'), findsOneWidget);
    expect(find.text('2 KB'), findsOneWidget);
  });

  testWidgets('verification entry opens owner document status shell', (
    tester,
  ) async {
    await _pumpManageProfile(
      tester,
      verificationRepository: _FakeVerificationRepository(
        documentsResult: <VerificationDocument>[
          VerificationDocument(
            id: 'document-1',
            documentType: 'license',
            status: 'PENDING',
            storageProvider: 'gcs',
            mimeType: 'application/pdf',
            fileSizeBytes: 2048,
            checksumProvided: true,
            uploadedAt: DateTime.utc(2026, 7, 15),
          ),
        ],
      ),
    );

    await tester.tap(find.text('Verification'));
    await tester.pumpAndSettle();

    expect(find.text('Verification documents'), findsOneWidget);
    expect(find.text('Professional verification'), findsOneWidget);
    expect(find.text('Verification readiness'), findsOneWidget);
    expect(
      find.text('2 required evidence items still need upload.'),
      findsOneWidget,
    );
    expect(find.text('Missing: Government identity'), findsOneWidget);
    expect(
      find.text('Missing: Professional registration or license'),
      findsOneWidget,
    );
    expect(find.text('Received: Qualification certificate'), findsOneWidget);
    expect(find.text('License'), findsWidgets);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('document-1'), findsNothing);
    expect(find.text('application/pdf'), findsNothing);
    expect(find.text('PDF document'), findsOneWidget);
    expect(find.text('2 KB'), findsOneWidget);
    expect(find.text('Checksum'), findsNothing);
    expect(find.text('Provided'), findsNothing);
    expect(find.text('15 Jul 2026'), findsOneWidget);
    expect(find.text('Upload document'), findsOneWidget);
    expect(
      find.text('Select one PDF, JPEG, or PNG file under 10 MB.'),
      findsOneWidget,
    );
    expect(find.text('signedUrl'), findsNothing);
    expect(find.text('storageObjectKey'), findsNothing);
    expect(find.text('private/object/key.pdf'), findsNothing);
    expect(find.text('raw-secret-checksum'), findsNothing);
    expect(find.text('Admin'), findsNothing);
    expect(find.text('Payment'), findsNothing);
    expect(find.text('Review'), findsNothing);
    expect(find.text('Call'), findsNothing);
    expect(find.text('Prescription'), findsNothing);
  });

  testWidgets('verification documents show empty state honestly', (
    tester,
  ) async {
    await _pumpManageProfile(tester);

    await tester.tap(find.text('Verification'));
    await tester.pumpAndSettle();

    expect(
      find.text('No verification documents are submitted yet.'),
      findsOneWidget,
    );
    expect(find.text('Verification documents'), findsOneWidget);
  });

  testWidgets('verification documents show safe backend error', (tester) async {
    await _pumpManageProfile(
      tester,
      verificationRepository: _FakeVerificationRepository(
        failure: const AuthFailure(
          type: AuthFailureType.server,
          message: 'raw private storage failure',
        ),
      ),
    );

    await tester.tap(find.text('Verification'));
    await tester.pumpAndSettle();

    expect(
      find.text('Service is unavailable. Please try again.'),
      findsWidgets,
    );
    expect(find.text('raw private storage failure'), findsNothing);
    expect(find.text('Verification documents'), findsOneWidget);
  });

  testWidgets('verification readiness shows safe requirement error', (
    tester,
  ) async {
    await _pumpManageProfile(
      tester,
      onboardingRepository: _FakeOnboardingRepository(
        failure: const AuthFailure(
          type: AuthFailureType.network,
          message: 'raw readiness network failure',
        ),
      ),
    );

    await tester.tap(find.text('Verification'));
    await tester.pumpAndSettle();

    expect(find.text('Verification readiness'), findsOneWidget);
    expect(
      find.textContaining('Pull to refresh before uploading more documents.'),
      findsOneWidget,
    );
    expect(find.text('raw readiness network failure'), findsNothing);
  });

  testWidgets(
    'verification upload sends selected type and safe file metadata',
    (tester) async {
      final repository = _FakeVerificationRepository();
      await _pumpManageProfile(
        tester,
        verificationRepository: repository,
        verificationDocumentPicker: const _FakeVerificationDocumentPicker(
          file: VerificationPickedFile(
            name: 'license.pdf',
            mimeType: 'application/pdf',
            bytes: <int>[1, 2, 3, 4],
          ),
        ),
      );

      await tester.tap(find.text('Verification'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose file to upload'));
      await tester.pumpAndSettle();

      expect(repository.lastUploadRequest, isNotNull);
      expect(repository.lastUploadRequest!.documentType, 'LICENSE');
      expect(repository.lastUploadRequest!.originalFileName, 'license.pdf');
      expect(repository.lastUploadRequest!.mimeType, 'application/pdf');
      expect(repository.lastUploadRequest!.fileBytes, <int>[1, 2, 3, 4]);
      expect(repository.lastUploadRequest!.fileSizeBytes, 4);
      expect(repository.lastUploadRequest!.controller, isNotNull);
      expect(repository.lastUploadRequest!.onProgress, isNotNull);
      expect(repository.documentsResult, hasLength(1));
      expect(repository.documentsResult.single.documentType, 'LICENSE');
      expect(
        find.text('Document uploaded and pending review.'),
        findsOneWidget,
      );
      expect(find.text('signedUrl'), findsNothing);
      expect(find.text('storageObjectKey'), findsNothing);
      expect(find.text('license.pdf'), findsNothing);
      expect(find.text('raw-secret-checksum'), findsNothing);
    },
  );

  testWidgets('verification upload supports identity document selection', (
    tester,
  ) async {
    final repository = _FakeVerificationRepository();
    await _pumpManageProfile(
      tester,
      verificationRepository: repository,
      verificationDocumentPicker: const _FakeVerificationDocumentPicker(
        file: VerificationPickedFile(
          name: 'identity.png',
          mimeType: 'image/png',
          bytes: <int>[7, 8, 9],
        ),
      ),
    );

    await tester.tap(find.text('Verification'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('License'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Identity').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose file to upload'));
    await tester.pumpAndSettle();

    expect(repository.lastUploadRequest?.documentType, 'IDENTITY');
    expect(repository.lastUploadRequest?.originalFileName, 'identity.png');
    expect(repository.lastUploadRequest?.mimeType, 'image/png');
  });

  testWidgets('verification upload rejects unsupported file type', (
    tester,
  ) async {
    final repository = _FakeVerificationRepository();
    await _pumpManageProfile(
      tester,
      verificationRepository: repository,
      verificationDocumentPicker: const _FakeVerificationDocumentPicker(
        file: VerificationPickedFile(
          name: 'license.txt',
          mimeType: 'text/plain',
          bytes: <int>[1, 2, 3],
        ),
      ),
    );

    await tester.tap(find.text('Verification'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose file to upload'));
    await tester.pumpAndSettle();

    expect(
      find.text('Only PDF, JPEG, or PNG files are supported.'),
      findsOneWidget,
    );
    expect(repository.lastUploadRequest, isNull);
  });

  testWidgets('verification upload rejects files over 10 MB', (tester) async {
    final repository = _FakeVerificationRepository();
    await _pumpManageProfile(
      tester,
      verificationRepository: repository,
      verificationDocumentPicker: _FakeVerificationDocumentPicker(
        file: VerificationPickedFile(
          name: 'license.pdf',
          mimeType: 'application/pdf',
          bytes: List<int>.filled(10 * 1024 * 1024 + 1, 1),
        ),
      ),
    );

    await tester.tap(find.text('Verification'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose file to upload'));
    await tester.pumpAndSettle();

    expect(find.text('Select a file smaller than 10 MB.'), findsOneWidget);
    expect(repository.lastUploadRequest, isNull);
  });

  testWidgets('verification upload cancellation does not call repository', (
    tester,
  ) async {
    final repository = _FakeVerificationRepository();
    await _pumpManageProfile(
      tester,
      verificationRepository: repository,
      verificationDocumentPicker: const _FakeVerificationDocumentPicker(),
    );

    await tester.tap(find.text('Verification'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose file to upload'));
    await tester.pumpAndSettle();

    expect(find.text('No file selected.'), findsOneWidget);
    expect(repository.lastUploadRequest, isNull);
  });

  testWidgets('in-flight verification upload shows progress and cancels', (
    tester,
  ) async {
    final repository = _FakeVerificationRepository(holdUpload: true);
    await _pumpManageProfile(
      tester,
      verificationRepository: repository,
      verificationDocumentPicker: const _FakeVerificationDocumentPicker(
        file: VerificationPickedFile(
          name: 'license.pdf',
          mimeType: 'application/pdf',
          bytes: <int>[1, 2, 3],
        ),
      ),
    );

    await tester.tap(find.text('Verification'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose file to upload'));
    await tester.pump();

    expect(find.text('50% uploaded'), findsOneWidget);
    expect(find.text('Cancel upload'), findsOneWidget);

    await tester.tap(find.text('Cancel upload'));
    await tester.pumpAndSettle();

    expect(find.text('Upload cancelled.'), findsOneWidget);
    expect(find.text('Document uploaded and pending review.'), findsNothing);
  });

  testWidgets('verification upload failure shows safe error without success', (
    tester,
  ) async {
    final repository = _FakeVerificationRepository(
      uploadFailure: const AuthFailure(
        type: AuthFailureType.server,
        message: 'raw signed url failure',
      ),
    );
    await _pumpManageProfile(
      tester,
      verificationRepository: repository,
      verificationDocumentPicker: const _FakeVerificationDocumentPicker(
        file: VerificationPickedFile(
          name: 'license.pdf',
          mimeType: 'application/pdf',
          bytes: <int>[1, 2, 3],
        ),
      ),
    );

    await tester.tap(find.text('Verification'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose file to upload'));
    await tester.pumpAndSettle();

    expect(
      find.text('Service is unavailable. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('raw signed url failure'), findsNothing);
    expect(find.text('Document uploaded and pending review.'), findsNothing);
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

    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('Weekly availability'), findsOneWidget);
    expect(find.text('Monday - Active'), findsOneWidget);
    expect(find.textContaining('9:00 am - 5:00 pm'), findsOneWidget);
    expect(find.text('Payment'), findsNothing);
    expect(find.text('Notification'), findsNothing);
    expect(find.text('Calendar sync'), findsNothing);
    expect(find.text('Review'), findsNothing);
    expect(find.text('Prescription'), findsNothing);
    expect(find.text('Call'), findsNothing);
    expect(find.text('Admin'), findsNothing);

    await tester.tap(find.byTooltip('Edit availability'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(schedulingRepository.lastReplacement, isNotNull);
    expect(schedulingRepository.lastReplacement, hasLength(1));
    expect(
      schedulingRepository.lastReplacement!.map((window) => window.weekday),
      <int>[DateTime.monday],
    );
    expect(schedulingRepository.lastReplacement!.last.startMinute, 9 * 60);
    expect(schedulingRepository.lastReplacement!.last.endMinute, 17 * 60);
    expect(find.text('Availability updated.'), findsOneWidget);
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

    expect(find.text('No recurring availability'), findsOneWidget);
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
    await tester.tap(find.text('Add availability window'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text('Please check the availability and try again.'),
      findsWidgets,
    );
    expect(find.text('raw invalid availability'), findsNothing);
    expect(find.text('Availability saved from backend.'), findsNothing);
  });

  testWidgets('edit action updates professional display name only', (
    tester,
  ) async {
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

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit your name'), findsOneWidget);
    expect(find.text('Enter a new name to continue'), findsOneWidget);
    expect(find.text('Your name'), findsWidgets);
    expect(find.text('Dr Backend Profile'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsOneWidget);
    expect(repository.lastDisplayName, isNull);

    await tester.enterText(find.byType(TextFormField), 'Dr. New Name');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Display name saved'), findsOneWidget);
    expect(find.text('Dr. New Name'), findsWidgets);
    expect(
      find.textContaining('Only your professional display name was updated'),
      findsOneWidget,
    );
    expect(repository.lastDisplayName, 'Dr. New Name');
    expect(repository.lastCategory, 'Cardiology');
    expect(repository.lastSpecialty, 'Heart health');
    expect(
      repository.lastBio,
      'Existing backend bio for the current professional profile.',
    );
  });

  testWidgets('edit action does not create a partial professional profile', (
    tester,
  ) async {
    final repository = _FakeProfileRepository();
    await _pumpManageProfile(tester, profileRepository: repository);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(
      find.text('Professional profile has not been created yet.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField), 'Dr. New Name');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Display name saved'), findsNothing);
    expect(repository.lastDisplayName, isNull);
    expect(
      find.text('Professional profile has not been created yet.'),
      findsOneWidget,
    );
  });

  testWidgets('edit action shows safe display name save error', (tester) async {
    final repository = _FakeProfileRepository(
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
        message: 'raw profile update failure',
      ),
    );

    await _pumpManageProfile(tester, profileRepository: repository);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Dr. New Name');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text('Service is unavailable. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('raw profile update failure'), findsNothing);
    expect(find.text('Display name saved'), findsNothing);
  });

  testWidgets(
    'category action updates professional category and specialty only',
    (tester) async {
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

      await tester.tap(find.text('Edit category'));
      await tester.pumpAndSettle();

      expect(find.text('Professional details'), findsOneWidget);
      expect(find.text('Category and specialty'), findsOneWidget);
      expect(find.text('Cardiology'), findsOneWidget);
      expect(find.text('Heart health'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), '');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Category is required'), findsOneWidget);
      expect(repository.lastCategory, isNull);

      await tester.enterText(find.byType(TextFormField).at(0), 'Mental health');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Community therapy',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Professional details saved'), findsOneWidget);
      expect(find.text('Mental health'), findsWidgets);
      expect(find.text('Community therapy'), findsWidgets);
      expect(
        find.textContaining(
          'Only your professional category and specialty were updated',
        ),
        findsOneWidget,
      );
      expect(repository.lastDisplayName, 'Dr Backend Profile');
      expect(repository.lastCategory, 'Mental health');
      expect(repository.lastSpecialty, 'Community therapy');
      expect(
        repository.lastBio,
        'Existing backend bio for the current professional profile.',
      );
    },
  );

  testWidgets('category action clears optional specialty as null', (
    tester,
  ) async {
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

    await tester.tap(find.text('Edit category'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Cardiology');
    await tester.enterText(find.byType(TextFormField).at(1), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Professional details saved'), findsOneWidget);
    expect(repository.lastDisplayName, 'Dr Backend Profile');
    expect(repository.lastCategory, 'Cardiology');
    expect(repository.lastSpecialty, isNull);
    expect(
      repository.lastBio,
      'Existing backend bio for the current professional profile.',
    );
  });

  testWidgets(
    'category action does not create a partial professional profile',
    (tester) async {
      final repository = _FakeProfileRepository();
      await _pumpManageProfile(tester, profileRepository: repository);

      await tester.tap(find.text('Edit category'));
      await tester.pumpAndSettle();

      expect(
        find.text('Professional profile has not been created yet.'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'Cardiology');
      await tester.enterText(find.byType(TextFormField).at(1), 'Heart health');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repository.lastCategory, isNull);
      expect(find.text('Professional details saved'), findsNothing);
      expect(
        find.text('Professional profile has not been created yet.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('category action shows safe backend save error', (tester) async {
    final repository = _FakeProfileRepository(
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
        message: 'raw category update failure',
      ),
    );

    await _pumpManageProfile(tester, profileRepository: repository);

    await tester.tap(find.text('Edit category'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Mental health');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Community therapy',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text('Service is unavailable. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('raw category update failure'), findsNothing);
    expect(find.text('Professional details saved'), findsNothing);
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

  testWidgets('profile management hides deferred product actions', (
    tester,
  ) async {
    await _pumpManageProfile(tester);

    for (final label in <String>[
      'Message',
      'Events',
      'Boost',
      'Podcast',
      'Share',
    ]) {
      expect(find.text(label), findsNothing);
    }
  });

  testWidgets('business section omits community management actions', (
    tester,
  ) async {
    await _pumpManageProfile(tester);

    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();

    expect(find.text('Add members'), findsNothing);
    expect(find.text('Edit group details'), findsNothing);
  });
}
