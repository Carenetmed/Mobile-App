import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_session.dart';

class OnboardingReadinessResolver {
  const OnboardingReadinessResolver();

  String routeForSession(AuthSession? session) {
    if (!_hasUsableSession(session)) {
      return RouteName.onboarding;
    }

    final role = session!.user.role.trim().toUpperCase();
    if (role == 'PROFESSIONAL') {
      return RouteName.medicalProfessional;
    }

    return RouteName.dashboard;
  }

  bool _hasUsableSession(AuthSession? session) {
    if (session == null) return false;
    return session.accessToken.trim().isNotEmpty &&
        session.refreshToken.trim().isNotEmpty &&
        session.user.id.trim().isNotEmpty;
  }
}
