import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Home/domain/entities/account_readiness.dart';

class OnboardingReadinessRouteResolver {
  const OnboardingReadinessRouteResolver();

  String resolve({
    required AccountReadiness? readiness,
    required String fallbackRole,
  }) {
    final role = fallbackRole.trim().toUpperCase();
    final readinessRole = readiness?.account.role.trim().toUpperCase();
    if (readinessRole != null &&
        readinessRole.isNotEmpty &&
        readinessRole != role) {
      return fallbackForRole(role);
    }

    final action = readiness?.nextAction.trim().toUpperCase();
    switch (action) {
      case 'PATIENT_SETUP':
        return role == 'PATIENT'
            ? RouteName.patientOnboardingSetup
            : fallbackForRole(role);
      case 'PATIENT_BOOKING_GATE':
        return role == 'PATIENT' ? RouteName.dashboard : fallbackForRole(role);
      case 'DASHBOARD':
        return RouteName.dashboard;
      case 'PROFESSIONAL_RESUME_APPLICATION':
        return role == 'PROFESSIONAL'
            ? RouteName.medicalProfessional
            : fallbackForRole(role);
      case 'PROFESSIONAL_UPLOAD_EVIDENCE':
      case 'PROFESSIONAL_REVIEW':
      case 'PROFESSIONAL_STATUS':
        return role == 'PROFESSIONAL'
            ? RouteName.professionalVerificationDocuments
            : fallbackForRole(role);
      default:
        return fallbackForRole(role);
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
