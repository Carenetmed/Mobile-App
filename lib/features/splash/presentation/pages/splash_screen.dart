import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_session.dart';
import 'package:app_t/features/Home/domain/services/booking_resume_service.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.authRepository,
    this.bookingResumeService,
  });

  final AuthRepository? authRepository;
  final BookingResumeService? bookingResumeService;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Matches Figma prototype timeout (0.8s) on splash screen.
  static const Duration _splashDuration = Duration(milliseconds: 800);

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

  @override
  void initState() {
    super.initState();
    Future.delayed(_splashDuration, _restoreSessionAndRoute);
  }

  Future<void> _restoreSessionAndRoute() async {
    AuthSession? session;
    try {
      session = await _authRepository.restore();
    } catch (_) {
      session = null;
    }

    if (!mounted) return;
    if (!_hasUsableSession(session)) {
      Navigator.of(context).pushReplacementNamed(RouteName.onboarding);
      return;
    }

    final resumeService = _bookingResumeService;
    if (resumeService != null) {
      try {
        final decision = await resumeService.resolveAfterAuthentication();
        if (!mounted) return;
        if (decision.target == BookingResumeTarget.professionalDetail &&
            decision.intent != null) {
          Navigator.of(context).pushReplacementNamed(
            RouteName.specialistDetails,
            arguments: decision.intent!.professionalProfileId,
          );
          return;
        }
        if (decision.target == BookingResumeTarget.patientOnboarding) {
          Navigator.of(
            context,
          ).pushReplacementNamed(RouteName.patientOnboardingSetup);
          return;
        }
        if (decision.target == BookingResumeTarget.authentication) {
          Navigator.of(context).pushReplacementNamed(RouteName.signInEmail);
          return;
        }
      } catch (_) {
        // Session restoration remains usable when booking-intent recovery fails.
      }
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(RouteName.dashboard);
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
