import 'dart:async';

import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_session.dart';
import 'package:app_t/features/Home/domain/services/booking_resume_service.dart';
import 'package:app_t/features/Notifications/presentation/state/notification_coordinator.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.authRepository,
    this.bookingResumeService,
    this.notificationCoordinator,
    this.restoreTimeout = const Duration(seconds: 5),
    this.refreshTimeout = const Duration(seconds: 5),
    this.bookingResumeTimeout = const Duration(seconds: 5),
  });

  final AuthRepository? authRepository;
  final BookingResumeService? bookingResumeService;
  final NotificationCoordinator? notificationCoordinator;
  final Duration restoreTimeout;
  final Duration refreshTimeout;
  final Duration bookingResumeTimeout;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Matches Figma prototype timeout (0.8s) on splash screen.
  static const Duration _splashDuration = Duration(milliseconds: 800);
  Timer? _startupTimer;

  AuthRepository get _authRepository =>
      widget.authRepository ?? sl<AuthRepository>();

  BookingResumeService? get _bookingResumeService {
    if (widget.bookingResumeService != null) {
      return widget.bookingResumeService;
    }
    return sl.isRegistered<BookingResumeService>()
        ? sl<BookingResumeService>()
        : null;
  }

  NotificationCoordinator? get _notificationCoordinator {
    if (widget.notificationCoordinator != null) {
      return widget.notificationCoordinator;
    }
    return sl.isRegistered<NotificationCoordinator>()
        ? sl<NotificationCoordinator>()
        : null;
  }

  @override
  void initState() {
    super.initState();
    _startupTimer = Timer(_splashDuration, _restoreSessionAndRoute);
  }

  @override
  void dispose() {
    _startupTimer?.cancel();
    super.dispose();
  }

  Future<void> _restoreSessionAndRoute() async {
    if (!mounted) return;
    AuthSession? session;
    try {
      // Bound the wait, not the platform read. Late completion cannot resume launch.
      session = await _authRepository.restore().timeout(widget.restoreTimeout);
    } catch (_) {
      session = null;
    }

    if (!mounted) return;
    if (_hasUsableSession(session)) {
      try {
        session = await _authRepository.refresh().timeout(
          widget.refreshTimeout,
        );
      } on TimeoutException {
        // Continue with the restored session while the serialized refresh
        // remains eligible to complete and notify dependent session services.
      } on AuthFailure catch (failure) {
        if (failure.shouldClearSession) session = null;
      } catch (_) {
        // A transient refresh failure does not erase a locally restorable session.
      }
    }

    if (!mounted) return;
    if (!_hasUsableSession(session)) {
      _replaceWith(RouteName.onboarding);
      return;
    }

    final resumeService = _bookingResumeService;
    if (resumeService != null) {
      try {
        final decision = await resumeService
            .resolveAfterAuthentication()
            .timeout(widget.bookingResumeTimeout);
        if (!mounted) return;
        if (decision.target == BookingResumeTarget.professionalDetail &&
            decision.intent != null) {
          _replaceWith(
            RouteName.specialistDetails,
            arguments: decision.intent!.professionalProfileId,
          );
          return;
        }
        if (decision.target == BookingResumeTarget.patientOnboarding) {
          _replaceWith(RouteName.patientOnboardingSetup);
          return;
        }
        if (decision.target == BookingResumeTarget.authentication) {
          _replaceWith(RouteName.signInEmail);
          return;
        }
      } catch (_) {
        // Session restoration remains usable when booking-intent recovery fails.
      }
    }
    if (!mounted) return;
    _replaceWith(RouteName.dashboard);
  }

  void _replaceWith(String routeName, {Object? arguments}) {
    Navigator.of(context).pushReplacementNamed(routeName, arguments: arguments);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_notificationCoordinator?.markNavigationReady());
    });
  }

  bool _hasUsableSession(AuthSession? session) {
    if (session == null) return false;
    return session.accessToken.trim().isNotEmpty &&
        session.refreshToken.trim().isNotEmpty &&
        session.user.id.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgImage(
                width: 144.w,
                height: 144.h,
                imgName: AssetsImages.appLogo,
              ),
              RPadding(
                padding: EdgeInsets.symmetric(vertical: 3.h),
                child: Text(
                  'CARENET',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    color: AppColors.kBlack,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'HEALTH SERVICES',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  color: AppColors.kBlack,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
