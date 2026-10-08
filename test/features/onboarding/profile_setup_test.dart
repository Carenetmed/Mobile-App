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
          (context, _) => MaterialApp(
            builder:
                (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                  child: child!,
                ),
            routes: <String, WidgetBuilder>{
              RouteName.dashboard:
                  (_) => const Scaffold(body: Text('patient-dashboard')),
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
    testWidgets('patient setup completes at compact width with 2x text', (
      tester,
    ) async {
      final repository = _FakeProfileRepository();
      final onboardingRepository = _FakeOnboardingRepository(
        readiness: const AccountReadiness(
          account: ReadinessAccount(
            role: 'PATIENT',
            status: 'ACTIVE',
            emailVerified: true,
          ),
          patient: PatientReadiness(
            profileStatus: 'COMPLETE',
            requiredFields: <String>[],
          ),
          professional: null,
          nextAction: 'PATIENT_BOOKING_GATE',
          requiredActions: <String>[],
        ),
      );
      await _pumpSetup(
        tester,
        repository: repository,
        screenSize: const Size(320, 568),
        textScaler: const TextScaler.linear(2),
        child: PatientOnboardingSetupPage(
          profileRepository: repository,
          onboardingRepository: onboardingRepository,
        ),
      );

      expect(find.text('Set up your patient profile'), findsOneWidget);
      expect(find.byType(EditableText), findsNWidgets(3));
      expect(tester.takeException(), isNull);

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'Ada Patient');
      await tester.ensureVisible(fields.at(2));
      await tester.enterText(fields.at(2), 'Ikeja');
      await _selectCatalogValue(tester, 'patient-state', 'Lagos');
      await _selectCatalogValue(tester, 'patient-country', 'Nigeria');
      await _selectCatalogValue(
        tester,
        'patient-health-interest',
        'Primary care',
      );

      final save = find.text('Save and continue');
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      expect(save, findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(save);
      await tester.pumpAndSettle();

      expect(repository.updatePatientCalls, 1);
      expect(repository.lastPatientName, 'Ada Patient');
      expect(repository.lastPatientCity, 'Ikeja');
      expect(find.text('patient-dashboard'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('patient setup saves backend profile fields', (tester) async {
      final repository = _FakeProfileRepository();
      final onboardingRepository = _FakeOnboardingRepository(
        readiness: const AccountReadiness(
          account: ReadinessAccount(
            role: 'PATIENT',
            status: 'ACTIVE',
            emailVerified: true,
          ),
          patient: PatientReadiness(
            profileStatus: 'COMPLETE',
            requiredFields: <String>[],
          ),
          professional: null,
          nextAction: 'PATIENT_BOOKING_GATE',
          requiredActions: <String>[],
        ),
      );
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
      await _selectCatalogValue(tester, 'patient-state', 'Lagos');
      await _selectCatalogValue(tester, 'patient-country', 'Nigeria');
      await _selectCatalogValue(
        tester,
        'patient-health-interest',
        'Primary care',
      );

      await tester.ensureVisible(find.text('Save and continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save and continue'));
      await tester.pumpAndSettle();

      expect(onboardingRepository.catalogCalls, 1);
      expect(onboardingRepository.readinessCalls, 2);
      expect(repository.updatePatientCalls, 1);
      expect(repository.lastPatientName, 'Ada Patient');
      expect(repository.lastPatientCity, 'Ikeja');
      expect(repository.lastPatientState, 'LA');
      expect(repository.lastPatientCountry, 'NG');
      expect(repository.lastPatientHealthInterests, 'PRIMARY_CARE');
      expect(find.text('patient-dashboard'), findsOneWidget);
      expect(find.text('community-agreement'), findsNothing);
    });

    testWidgets('patient setup shows backend required profile fields', (
      tester,
    ) async {
      final repository = _FakeProfileRepository();
      await _pumpSetup(
        tester,
        repository: repository,
        child: PatientOnboardingSetupPage(
          profileRepository: repository,
          onboardingRepository: _FakeOnboardingRepository(
            readiness: const AccountReadiness(
              account: ReadinessAccount(
                role: 'PATIENT',
                status: 'ACTIVE',
                emailVerified: false,
              ),
              patient: PatientReadiness(
                profileStatus: 'DRAFT',
                requiredFields: <String>['name', 'country'],
              ),
              professional: null,
              nextAction: 'PATIENT_SETUP',
              requiredActions: <String>['PATIENT_name', 'PATIENT_country'],
            ),
          ),
        ),
      );

      expect(find.text('Patient readiness'), findsOneWidget);
      expect(
        find.text('2 patient profile fields still need confirmation.'),
        findsOneWidget,
      );
      expect(find.text('Required patient field: Name'), findsOneWidget);
      expect(find.text('Required patient field: Country'), findsOneWidget);
    });

    testWidgets('patient setup preloads only matching backend profile values', (
      tester,
    ) async {
      final repository = _FakeProfileRepository(
        patientProfile: const PatientProfile(
          name: 'Ada Existing',
          city: 'Ikeja',
          state: 'LA',
          country: 'NG',
          healthInterests: 'PRIMARY_CARE',
        ),
      );
      await _pumpSetup(
        tester,
        repository: repository,
        child: PatientOnboardingSetupPage(
          profileRepository: repository,
          onboardingRepository: _FakeOnboardingRepository(),
        ),
      );

      expect(find.text('Ada Existing'), findsOneWidget);
      expect(find.text('Ikeja'), findsOneWidget);
      expect(find.text('Lagos'), findsWidgets);
      expect(find.text('Nigeria'), findsWidgets);
      expect(find.text('Primary care'), findsWidgets);
    });

    testWidgets('new patient must explicitly select catalog values', (
      tester,
    ) async {
      final repository = _FakeProfileRepository();
      await _pumpSetup(
        tester,
        repository: repository,
        child: PatientOnboardingSetupPage(
          profileRepository: repository,
          onboardingRepository: _FakeOnboardingRepository(),
        ),
      );

      await tester.enterText(find.byType(EditableText).first, 'Ada Patient');
      await tester.ensureVisible(find.text('Save and continue'));
      await tester.tap(find.text('Save and continue'));
      await tester.pump();

      expect(find.text('State is required'), findsOneWidget);
      expect(find.text('Country is required'), findsOneWidget);
      expect(find.text('Health interest is required'), findsOneWidget);
      expect(repository.updatePatientCalls, 0);
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

    testWidgets('patient setup retries a failed load without losing input', (
      tester,
    ) async {
      final repository = _FakeProfileRepository();
      final onboardingRepository = _FakeOnboardingRepository(
        failure: const AuthFailure(
          type: AuthFailureType.network,
          message: 'Service is unavailable. Please try again.',
        ),
      );
      await _pumpSetup(
        tester,
        repository: repository,
        child: PatientOnboardingSetupPage(
          profileRepository: repository,
          onboardingRepository: onboardingRepository,
        ),
      );

      final nameField = find.byType(EditableText).first;
      await tester.enterText(nameField, 'Ada Patient');
      onboardingRepository.failure = null;
      final retry = find.byKey(const ValueKey('retry-onboarding-load'));
      await tester.ensureVisible(retry);
      await tester.tap(retry);
      await tester.pumpAndSettle();

      expect(onboardingRepository.catalogCalls, 2);
      expect(find.text('Ada Patient'), findsOneWidget);
      expect(find.text('Retry loading setup'), findsNothing);
      expect(tester.takeException(), isNull);
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

      await _selectCatalogValue(
        tester,
        'professional-category',
        'Medical doctor',
      );
      await _selectCatalogValue(tester, 'professional-state', 'Lagos');
      await _selectCatalogValue(tester, 'professional-country', 'Nigeria');

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

    testWidgets('professional setup completes at compact width with 2x text', (
      tester,
    ) async {
      final repository = _FakeProfileRepository();
      await _pumpSetup(
        tester,
        repository: repository,
        screenSize: const Size(320, 568),
        textScaler: const TextScaler.linear(2),
        child: ProfessionalOnboardingSetupPage(
          profileRepository: repository,
          onboardingRepository: _FakeOnboardingRepository(),
        ),
      );

      expect(find.text('Professional verification profile'), findsOneWidget);
      final fields = find.byType(EditableText);
      expect(fields, findsNWidgets(9));
      expect(tester.takeException(), isNull);

      const fieldValues = <int, String>{
        0: 'Ada Okafor',
        1: 'Dr. Ada Okafor',
        2: 'Cardiology',
        3: 'MDCN-12345',
        4: 'MBBS',
        5: '12',
        6: 'Care Clinic',
        7: '1 Care Street',
        8: 'Ikeja',
      };
      for (final entry in fieldValues.entries) {
        final field = fields.at(entry.key);
        await tester.ensureVisible(field);
        await tester.enterText(field, entry.value);
      }
      await _selectCatalogValue(
        tester,
        'professional-category',
        'Medical doctor',
      );
      await _selectCatalogValue(tester, 'professional-state', 'Lagos');
      await _selectCatalogValue(tester, 'professional-country', 'Nigeria');

      final save = find.text('Save and verify');
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      expect(save, findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(save);
      await tester.pumpAndSettle();

      expect(repository.updateProfessionalCalls, 1);
      expect(repository.lastLegalName, 'Ada Okafor');
      expect(repository.lastDisplayName, 'Dr. Ada Okafor');
      expect(repository.lastCategory, 'MEDICAL_DOCTOR');
      expect(repository.lastLicenseNumber, 'MDCN-12345');
      expect(repository.lastPracticeCity, 'Ikeja');
      expect(find.text('verification-documents'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('professional setup shows backend required profile fields', (
      tester,
    ) async {
      final repository = _FakeProfileRepository();
      await _pumpSetup(
        tester,
        repository: repository,
        child: ProfessionalOnboardingSetupPage(
          profileRepository: repository,
          onboardingRepository: _FakeOnboardingRepository(
            readiness: const AccountReadiness(
              account: ReadinessAccount(
                role: 'PROFESSIONAL',
                status: 'ACTIVE',
                emailVerified: true,
              ),
              patient: null,
              professional: ProfessionalReadiness(
                applicationStatus: 'DRAFT',
                verificationStatus: 'NOT_SUBMITTED',
                countryCode: 'NG',
                professionCode: 'MEDICAL_DOCTOR',
                regulatorCode: 'MDCN',
                requiredProfileFields: <String>[
                  'licenseNumber',
                  'practiceState',
                ],
                requiredEvidence: <String>[
                  'PROFESSIONAL_REGISTRATION_OR_LICENSE',
                ],
                missingEvidence: <String>[
                  'PROFESSIONAL_REGISTRATION_OR_LICENSE',
                ],
              ),
              nextAction: 'PROFESSIONAL_RESUME_APPLICATION',
              requiredActions: <String>[
                'PROFESSIONAL_licenseNumber',
                'PROFESSIONAL_practiceState',
              ],
            ),
          ),
        ),
      );

      await tester.ensureVisible(find.text('Professional readiness'));
      await tester.pumpAndSettle();

      expect(find.text('Professional readiness'), findsOneWidget);
      expect(
        find.text('2 professional profile fields still need confirmation.'),
        findsOneWidget,
      );
      expect(
        find.text('Required profile field: License Number'),
        findsOneWidget,
      );
      expect(
        find.text('Required profile field: Practice State'),
        findsOneWidget,
      );
    });

    testWidgets('professional setup preloads matching backend profile values', (
      tester,
    ) async {
      final repository = _FakeProfileRepository(
        professionalProfile: const ProfessionalProfile(
          legalName: 'Ada Okafor',
          displayName: 'Dr. Ada Okafor',
          category: 'MEDICAL_DOCTOR',
          specialty: 'Cardiology',
          licenseNumber: 'MDCN-12345',
          qualifications: 'MBBS',
          yearsOfExperience: 8,
          practiceName: 'Care Clinic',
          practiceCity: 'Ikeja',
          practiceState: 'LA',
          practiceCountry: 'NG',
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

      expect(find.text('Ada Okafor'), findsOneWidget);
      expect(find.text('Dr. Ada Okafor'), findsWidgets);
      expect(find.text('Medical doctor'), findsWidgets);
      expect(find.text('Lagos'), findsWidgets);
      expect(find.text('Nigeria'), findsWidgets);
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
      await _selectCatalogValue(
        tester,
        'professional-category',
        'Medical doctor',
      );
      await _selectCatalogValue(tester, 'professional-state', 'Lagos');
      await _selectCatalogValue(tester, 'professional-country', 'Nigeria');

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

    testWidgets(
      'professional setup retries a failed load without losing input',
      (tester) async {
        final repository = _FakeProfileRepository();
        final onboardingRepository = _FakeOnboardingRepository(
          failure: const AuthFailure(
            type: AuthFailureType.network,
            message: 'Service is unavailable. Please try again.',
          ),
        );
        await _pumpSetup(
          tester,
          repository: repository,
          child: ProfessionalOnboardingSetupPage(
            profileRepository: repository,
            onboardingRepository: onboardingRepository,
          ),
        );

        final legalName = find.byType(EditableText).at(0);
        final displayName = find.byType(EditableText).at(1);
        await tester.enterText(legalName, 'Ada Okafor');
        await tester.enterText(displayName, 'Dr. Ada Okafor');
        onboardingRepository.failure = null;
        final retry = find.byKey(const ValueKey('retry-onboarding-load'));
        await tester.ensureVisible(retry);
        await tester.tap(retry);
        await tester.pumpAndSettle();

        expect(onboardingRepository.catalogCalls, 2);
        expect(find.text('Ada Okafor'), findsOneWidget);
        expect(find.text('Dr. Ada Okafor'), findsNWidgets(2));
        expect(find.text('Retry loading setup'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
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
  await _selectCatalogValue(tester, 'professional-category', 'Medical doctor');
  await _selectCatalogValue(tester, 'professional-state', 'Lagos');
  await _selectCatalogValue(tester, 'professional-country', 'Nigeria');
  await tester.ensureVisible(find.text('Save and verify'));
  await tester.pumpAndSettle();
}

Future<void> _selectCatalogValue(
  WidgetTester tester,
  String key,
  String value,
) async {
  final field = find.byKey(ValueKey<String>(key));
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text(value).last);
  await tester.pumpAndSettle();
}

class _FakeOnboardingRepository implements OnboardingRepository {
  _FakeOnboardingRepository({this.failure, this.readiness});

  AuthFailure? failure;
  final AccountReadiness? readiness;
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
    return readiness ??
        const AccountReadiness(
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
  _FakeProfileRepository({
    this.failure,
    this.patientProfile,
    this.professionalProfile,
  });

  final AuthFailure? failure;
  final PatientProfile? patientProfile;
  final ProfessionalProfile? professionalProfile;
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
  Future<PatientProfile?> patientMe() async => patientProfile;

  @override
  Future<ProfessionalProfile?> professionalMe() async => professionalProfile;

  @override
  Future<List<PublicProfessional>> publicProfessionals() async {
    return const <PublicProfessional>[];
  }

  @override
  Future<PublicProfessional?> publicProfessionalById({
    required String professionalProfileId,
  }) async {
    return null;
  }
}
