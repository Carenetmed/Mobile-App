import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Home/domain/entities/account_readiness.dart';

class OnboardingReadinessRouteResolver {
  const OnboardingReadinessRouteResolver();

  String resolve({
    required AccountReadiness? readiness,
    required String fallbackRole,
  }) {
    final action = readiness?.nextAction.trim().toUpperCase();
    switch (action) {
      case 'PATIENT_SETUP':
        return RouteName.patientOnboardingSetup;
      case 'PATIENT_BOOKING_GATE':
      case 'DASHBOARD':
        return RouteName.dashboard;
      case 'PROFESSIONAL_RESUME_APPLICATION':
        return RouteName.medicalProfessional;
      case 'PROFESSIONAL_UPLOAD_EVIDENCE':
      case 'PROFESSIONAL_REVIEW':
      case 'PROFESSIONAL_STATUS':
        return RouteName.professionalVerificationDocuments;
      default:
        return fallbackForRole(fallbackRole);
    }
  }

  String fallbackForRole(String role) {
    return switch (role.trim().toUpperCase()) {
      'PROFESSIONAL' => RouteName.medicalProfessional,
      'PATIENT' => RouteName.patientOnboardingSetup,
      _ => RouteName.dashboard,
    };
  }
}
