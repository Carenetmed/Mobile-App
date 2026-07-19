import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/domain/entities/account_readiness.dart';
import 'package:app_t/features/Home/domain/entities/onboarding_catalog.dart';
import 'package:app_t/features/Home/domain/entities/patient_profile.dart';
import 'package:app_t/features/Home/domain/entities/professional_profile.dart';
import 'package:app_t/features/Home/domain/entities/public_professional.dart';
import 'package:app_t/features/Onboarding/presentation/pages/profile_setup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 932);

Future<void> _pumpSetup(
  WidgetTester tester, {
  required Widget child,
  required _FakeProfileRepository repository,
}) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            routes: <String, WidgetBuilder>{
              RouteName.communityAgreement:
                  (_) => const Scaffold(body: Text('community-agreement')),
              RouteName.professionalVerificationDocuments:
                  (_) => const Scaffold(body: Text('verification-documents')),
            },
            home: child,
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Patient and professional onboarding setup', () {
    testWidgets('patient setup saves backend profile fields', (tester) async {
      final repository = _FakeProfileRepository();
      final onboardingRepository = _FakeOnboardingRepository();
      await _pumpSetup(
        tester,
        repository: repository,
        child: PatientOnboardingSetupPage(
          profileRepository: repository,
          onboardingRepository: onboardingRepository,
        ),
      );

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'Ada Patient');
      await tester.enterText(fields.at(2), 'Ikeja');

      await tester.ensureVisible(find.text('Save and continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save and continue'));
      await tester.pumpAndSettle();

      expect(onboardingRepository.catalogCalls, 1);
      expect(onboardingRepository.readinessCalls, 1);
      expect(repository.updatePatientCalls, 1);
      expect(repository.lastPatientName, 'Ada Patient');
      expect(repository.lastPatientCity, 'Ikeja');
      expect(repository.lastPatientState, 'LA');
      expect(repository.lastPatientCountry, 'NG');
      expect(repository.lastPatientHealthInterests, 'PRIMARY_CARE');
      expect(find.text('community-agreement'), findsOneWidget);
    });

    testWidgets('patient setup blocks save when catalog cannot load', (
      tester,
    ) async {
      final repository = _FakeProfileRepository();
      await _pumpSetup(
        tester,
        repository: repository,
        child: PatientOnboardingSetupPage(
          profileRepository: repository,
          onboardingRepository: _FakeOnboardingRepository(
            failure: const AuthFailure(
              type: AuthFailureType.network,
              message: 'Service is unavailable. Please try again.',
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(EditableText).first, 'Ada Patient');
      await tester.ensureVisible(find.text('Save and continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save and continue'));
      await tester.pumpAndSettle();

      expect(repository.updatePatientCalls, 0);
      expect(
        find.text('Onboarding options are still unavailable.'),
        findsOneWidget,
      );
    });

    testWidgets('professional setup requires credential fields', (
      tester,
    ) async {
      final repository = _FakeProfileRepository();
      await _pumpSetup(
        tester,
        repository: repository,
        child: ProfessionalOnboardingSetupPage(
          profileRepository: repository,
          onboardingRepository: _FakeOnboardingRepository(),
        ),
      );

      await tester.ensureVisible(find.text('Save and verify'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save and verify'));
      await tester.pump();

      expect(repository.updateProfessionalCalls, 0);
      expect(find.text('Legal name is required'), findsOneWidget);
      expect(find.text('License number is required'), findsOneWidget);
      expect(find.text('Qualifications are required'), findsOneWidget);
      expect(find.text('verification-documents'), findsNothing);
    });

    testWidgets('professional setup saves required Nigeria profile fields', (
      tester,
    ) async {
      final repository = _FakeProfileRepository();
      final onboardingRepository = _FakeOnboardingRepository();
      await _pumpSetup(
        tester,
        repository: repository,
        child: ProfessionalOnboardingSetupPage(
          profileRepository: repository,
          onboardingRepository: onboardingRepository,
        ),
      );

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'Ada Okafor');
      await tester.enterText(fields.at(1), 'Dr. Ada Okafor');
      await tester.enterText(fields.at(2), 'Cardiology');
      await tester.enterText(fields.at(3), 'MDCN-12345');
      await tester.enterText(fields.at(4), 'MBBS, FWACP');
      await tester.enterText(fields.at(5), '12');
      await tester.enterText(fields.at(6), 'Care Clinic');
      await tester.enterText(fields.at(7), '1 Care Street');
      await tester.enterText(fields.at(8), 'Ikeja');

      await tester.ensureVisible(find.text('Save and verify'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save and verify'));
      await tester.pumpAndSettle();

      expect(onboardingRepository.catalogCalls, 1);
      expect(onboardingRepository.readinessCalls, 1);
      expect(repository.updateProfessionalCalls, 1);
      expect(repository.lastLegalName, 'Ada Okafor');
      expect(repository.lastDisplayName, 'Dr. Ada Okafor');
      expect(repository.lastCategory, 'MEDICAL_DOCTOR');
      expect(repository.lastLicenseNumber, 'MDCN-12345');
      expect(repository.lastLicensingCouncil, 'MDCN');
      expect(repository.lastQualifications, 'MBBS, FWACP');
      expect(repository.lastYearsOfExperience, 12);
      expect(repository.lastPracticeName, 'Care Clinic');
      expect(repository.lastPracticeCity, 'Ikeja');
      expect(repository.lastPracticeState, 'LA');
      expect(repository.lastPracticeCountry, 'NG');
      expect(find.text('verification-documents'), findsOneWidget);
    });

    testWidgets('professional setup shows safe save failure', (tester) async {
      final repository = _FakeProfileRepository(
        failure: const AuthFailure(
          type: AuthFailureType.validation,
          message: 'Please check the details and try again.',
        ),
      );
      await _pumpSetup(
        tester,
        repository: repository,
        child: ProfessionalOnboardingSetupPage(
          profileRepository: repository,
          onboardingRepository: _FakeOnboardingRepository(),
        ),
      );

      await _fillMinimumProfessionalForm(tester);
      await tester.tap(find.text('Save and verify'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please check the details and try again.'),
        findsOneWidget,
      );
      expect(find.text('verification-documents'), findsNothing);
    });
  });
}

Future<void> _fillMinimumProfessionalForm(WidgetTester tester) async {
  final fields = find.byType(EditableText);
  await tester.enterText(fields.at(0), 'Ada Okafor');
  await tester.enterText(fields.at(1), 'Dr. Ada Okafor');
  await tester.enterText(fields.at(3), 'MDCN-12345');
  await tester.enterText(fields.at(4), 'MBBS');
  await tester.enterText(fields.at(5), '5');
  await tester.enterText(fields.at(6), 'Care Clinic');
  await tester.enterText(fields.at(8), 'Ikeja');
  await tester.ensureVisible(find.text('Save and verify'));
  await tester.pumpAndSettle();
}

class _FakeOnboardingRepository implements OnboardingRepository {
  _FakeOnboardingRepository({this.failure});

  final AuthFailure? failure;
  int catalogCalls = 0;
  int readinessCalls = 0;

  @override
  Future<OnboardingCatalog> onboardingCatalog() async {
    catalogCalls += 1;
    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
    return _catalog;
  }

  @override
  Future<AccountReadiness> accountReadiness() async {
    readinessCalls += 1;
    return const AccountReadiness(
      account: ReadinessAccount(
        role: 'PATIENT',
        status: 'ACTIVE',
        emailVerified: true,
      ),
      patient: PatientReadiness(
        profileStatus: 'INCOMPLETE',
        requiredFields: <String>['name'],
      ),
      professional: ProfessionalReadiness(
        applicationStatus: 'DRAFT',
        verificationStatus: 'NOT_SUBMITTED',
        countryCode: 'NG',
        professionCode: 'MEDICAL_DOCTOR',
        regulatorCode: 'MDCN',
        requiredProfileFields: <String>['licenseNumber'],
        requiredEvidence: <String>['LICENSE'],
        missingEvidence: <String>['LICENSE'],
      ),
      nextAction: 'COMPLETE_PROFILE',
      requiredActions: <String>[],
    );
  }
}

const _catalog = OnboardingCatalog(
  launchCountry: 'NG',
  countries: <OnboardingCountry>[
    OnboardingCountry(code: 'NG', name: 'Nigeria', status: 'ACTIVE'),
  ],
  nigeriaStates: <OnboardingRegion>[
    OnboardingRegion(code: 'LA', name: 'Lagos'),
    OnboardingRegion(code: 'FC', name: 'FCT'),
  ],
  professionalCatalog: <ProfessionalCatalogItem>[
    ProfessionalCatalogItem(
      code: 'MEDICAL_DOCTOR',
      label: 'Medical doctor',
      regulatorCode: 'MDCN',
      regulatorName: 'Medical and Dental Council of Nigeria',
      requiredEvidence: <String>['LICENSE'],
    ),
  ],
  verificationEvidenceTypes: <VerificationEvidenceType>[
    VerificationEvidenceType(
      code: 'LICENSE',
      label: 'Professional license',
      documentType: 'LICENSE',
    ),
  ],
  patientHealthInterestCatalog: <PatientHealthInterest>[
    PatientHealthInterest(code: 'PRIMARY_CARE', label: 'Primary care'),
  ],
);

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({this.failure});

  final AuthFailure? failure;
  int updatePatientCalls = 0;
  int updateProfessionalCalls = 0;
  String? lastPatientName;
  String? lastPatientCity;
  String? lastPatientState;
  String? lastPatientCountry;
  String? lastPatientHealthInterests;
  String? lastLegalName;
  String? lastDisplayName;
  String? lastCategory;
  String? lastLicenseNumber;
  String? lastLicensingCouncil;
  String? lastQualifications;
  int? lastYearsOfExperience;
  String? lastPracticeName;
  String? lastPracticeCity;
  String? lastPracticeState;
  String? lastPracticeCountry;

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
  }) async {
    updatePatientCalls += 1;
    lastPatientName = name;
    lastPatientCity = city;
    lastPatientState = state;
    lastPatientCountry = country;
    lastPatientHealthInterests = healthInterests;
    return PatientProfile(
      name: name,
      dateOfBirth: dateOfBirth,
      city: city,
      state: state,
      country: country,
      healthInterests: healthInterests,
    );
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
    updateProfessionalCalls += 1;
    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
    lastLegalName = legalName;
    lastDisplayName = displayName;
    lastCategory = category;
    lastLicenseNumber = licenseNumber;
    lastLicensingCouncil = licensingCouncil;
    lastQualifications = qualifications;
    lastYearsOfExperience = yearsOfExperience;
    lastPracticeName = practiceName;
    lastPracticeCity = practiceCity;
    lastPracticeState = practiceState;
    lastPracticeCountry = practiceCountry;
    return ProfessionalProfile(
      legalName: legalName,
      displayName: displayName,
      category: category,
      specialty: specialty,
      licenseNumber: licenseNumber,
      licensingCouncil: licensingCouncil,
      qualifications: qualifications,
      yearsOfExperience: yearsOfExperience,
      practiceName: practiceName,
      practiceAddress: practiceAddress,
      practiceCity: practiceCity,
      practiceState: practiceState,
      practiceCountry: practiceCountry,
    );
  }

  @override
  Future<PatientProfile?> patientMe() async => null;

  @override
  Future<ProfessionalProfile?> professionalMe() async => null;

  @override
  Future<List<PublicProfessional>> publicProfessionals() async {
    return const <PublicProfessional>[];
  }
}
