import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Home/domain/entities/account_readiness.dart';
import 'package:app_t/features/Onboarding/domain/services/onboarding_readiness_route_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resolver = OnboardingReadinessRouteResolver();

  group('OnboardingReadinessRouteResolver', () {
    test('maps known backend next actions to Flutter destinations', () {
      expect(
        resolver.resolve(
          readiness: _readiness('PATIENT_SETUP', role: 'PATIENT'),
          fallbackRole: 'PATIENT',
        ),
        RouteName.patientOnboardingSetup,
      );
      expect(
        resolver.resolve(
          readiness: _readiness('PATIENT_BOOKING_GATE', role: 'PATIENT'),
          fallbackRole: 'PATIENT',
        ),
        RouteName.dashboard,
      );
      expect(
        resolver.resolve(
          readiness: _readiness('PROFESSIONAL_RESUME_APPLICATION'),
          fallbackRole: 'PROFESSIONAL',
        ),
        RouteName.medicalProfessional,
      );
      expect(
        resolver.resolve(
          readiness: _readiness('PROFESSIONAL_UPLOAD_EVIDENCE'),
          fallbackRole: 'PROFESSIONAL',
        ),
        RouteName.professionalVerificationDocuments,
      );
      expect(
        resolver.resolve(
          readiness: _readiness('PROFESSIONAL_REVIEW'),
          fallbackRole: 'PROFESSIONAL',
        ),
        RouteName.professionalVerificationDocuments,
      );
      expect(
        resolver.resolve(
          readiness: _readiness('PROFESSIONAL_STATUS'),
          fallbackRole: 'PROFESSIONAL',
        ),
        RouteName.professionalVerificationDocuments,
      );
      expect(
        resolver.resolve(
          readiness: _readiness('DASHBOARD', role: 'PATIENT'),
          fallbackRole: 'PATIENT',
        ),
        RouteName.dashboard,
      );
    });

    test('unknown or missing readiness falls back by role safely', () {
      expect(
        resolver.resolve(readiness: null, fallbackRole: 'PATIENT'),
        RouteName.patientOnboardingSetup,
      );
      expect(
        resolver.resolve(readiness: null, fallbackRole: 'PROFESSIONAL'),
        RouteName.medicalProfessional,
      );
      expect(
        resolver.resolve(
          readiness: _readiness('SOMETHING_NEW'),
          fallbackRole: 'PROFESSIONAL',
        ),
        RouteName.medicalProfessional,
      );
      expect(
        resolver.resolve(readiness: _readiness(''), fallbackRole: 'PATIENT'),
        RouteName.patientOnboardingSetup,
      );
      expect(
        resolver.resolve(readiness: null, fallbackRole: 'ADMIN'),
        RouteName.dashboard,
      );
    });

    test('readiness role mismatch cannot route into another role setup', () {
      expect(
        resolver.resolve(
          readiness: _readiness('PROFESSIONAL_UPLOAD_EVIDENCE'),
          fallbackRole: 'PATIENT',
        ),
        RouteName.patientOnboardingSetup,
      );
      expect(
        resolver.resolve(
          readiness: _readiness('PATIENT_SETUP', role: 'PATIENT'),
          fallbackRole: 'PROFESSIONAL',
        ),
        RouteName.medicalProfessional,
      );
    });

    test(
      'patient booking gate cannot send professional to patient dashboard',
      () {
        expect(
          resolver.resolve(
            readiness: _readiness('PATIENT_BOOKING_GATE'),
            fallbackRole: 'PROFESSIONAL',
          ),
          RouteName.medicalProfessional,
        );
      },
    );
  });
}

AccountReadiness _readiness(String nextAction, {String role = 'PROFESSIONAL'}) {
  return AccountReadiness(
    account: ReadinessAccount(
      role: role,
      status: 'ACTIVE',
      emailVerified: true,
    ),
    patient: const PatientReadiness(
      profileStatus: 'NOT_APPLICABLE',
      requiredFields: <String>[],
    ),
    professional: const ProfessionalReadiness(
      applicationStatus: 'DRAFT',
      verificationStatus: 'NOT_SUBMITTED',
      requiredProfileFields: <String>[],
      requiredEvidence: <String>[],
      missingEvidence: <String>[],
    ),
    nextAction: nextAction,
    requiredActions: const <String>[],
  );
}
