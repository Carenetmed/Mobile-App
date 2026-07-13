import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_session.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.authRepository});

  final AuthRepository? authRepository;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Matches Figma prototype timeout (0.8s) on splash screen.
  static const Duration _splashDuration = Duration(milliseconds: 800);

  AuthRepository get _authRepository =>
      widget.authRepository ?? sl<AuthRepository>();

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
    final routeName =
        _hasUsableSession(session) ? RouteName.dashboard : RouteName.onboarding;
    Navigator.of(context).pushReplacementNamed(routeName);
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
