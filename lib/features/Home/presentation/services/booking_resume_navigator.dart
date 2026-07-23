import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/features/Home/domain/services/booking_resume_service.dart';
import 'package:flutter/material.dart';

class BookingResumeNavigator {
  const BookingResumeNavigator._();

  static Future<bool> hasPendingIntent() async {
    if (!sl.isRegistered<BookingResumeService>()) {
      return false;
    }
    return sl<BookingResumeService>().hasPendingIntent();
  }

  static Future<void> afterAuthentication(
    BuildContext context, {
    required String fallbackRoute,
  }) async {
    if (!sl.isRegistered<BookingResumeService>()) {
      Navigator.of(context).pushNamed(fallbackRoute);
      return;
    }

    BookingResumeDecision decision;
    try {
      decision = await sl<BookingResumeService>().resolveAfterAuthentication();
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pushNamed(fallbackRoute);
      return;
    }
    if (!context.mounted) {
      return;
    }

    switch (decision.target) {
      case BookingResumeTarget.professionalDetail:
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteName.specialistDetails,
          (route) => false,
          arguments: decision.intent!.professionalProfileId,
        );
        return;
      case BookingResumeTarget.patientOnboarding:
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteName.patientOnboardingSetup,
          (route) => false,
        );
        return;
      case BookingResumeTarget.incompatibleRole:
        await showDialog<void>(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: const Text('Patient account required'),
                content: const Text(
                  'This account cannot request patient appointments. '
                  'Your account and session have not been changed.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Go to dashboard'),
                  ),
                ],
              ),
        );
        if (context.mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(RouteName.dashboard, (route) => false);
        }
        return;
      case BookingResumeTarget.authentication:
        Navigator.of(context).pushNamed(RouteName.signInEmail);
        return;
      case BookingResumeTarget.none:
        Navigator.of(context).pushNamed(fallbackRoute);
        return;
    }
  }
}
