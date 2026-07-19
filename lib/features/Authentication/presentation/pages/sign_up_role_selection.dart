import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/google_sign_in_provider.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_arguments.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Onboarding/domain/services/onboarding_readiness_route_resolver.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUpRoleSelectionPage extends StatefulWidget {
  const SignUpRoleSelectionPage({
    super.key,
    this.initialEmail,
    this.googleSignUp = false,
    this.authRepository,
    this.googleIdTokenProvider,
    this.onboardingRepository,
  });

  final String? initialEmail;
  final bool googleSignUp;
  final AuthRepository? authRepository;
  final GoogleIdTokenProvider? googleIdTokenProvider;
  final OnboardingRepository? onboardingRepository;

  @override
  State<SignUpRoleSelectionPage> createState() =>
      _SignUpRoleSelectionPageState();
}

class _SignUpRoleSelectionPageState extends State<SignUpRoleSelectionPage> {
  bool _isSubmitting = false;
  String? _error;

  AuthRepository get _authRepository =>
      widget.authRepository ?? sl<AuthRepository>();

  GoogleIdTokenProvider get _googleIdTokenProvider =>
      widget.googleIdTokenProvider ?? sl<GoogleIdTokenProvider>();

  OnboardingRepository get _onboardingRepository =>
      widget.onboardingRepository ?? sl<OnboardingRepository>();

  static const _routeResolver = OnboardingReadinessRouteResolver();

  Future<void> _continueAs(SignUpRole role) async {
    if (!widget.googleSignUp) {
      Navigator.pushNamed(
        context,
        RouteName.finishSignUp,
        arguments: FinishSignUpArgs(
          initialEmail: widget.initialEmail,
          role: role,
          onboardingRepository: widget.onboardingRepository,
        ),
      );
      return;
    }

    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final idToken = await _googleIdTokenProvider.signInIdToken();
      await _authRepository.googleSignIn(
        idToken: idToken,
        role: role.backendValue,
      );
      if (!mounted) {
        return;
      }
      final routeName = await _resolveNextRoute(role);
      if (!mounted) {
        return;
      }
      Navigator.pushNamed(context, routeName);
    } on AuthFailure catch (failure) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = failure.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Google sign-up failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<String> _resolveNextRoute(SignUpRole role) async {
    try {
      final readiness = await _onboardingRepository.accountReadiness();
      return _routeResolver.resolve(
        readiness: readiness,
        fallbackRole: role.backendValue,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created. We could not check the next setup step. Please continue setup.',
            ),
          ),
        );
      }
      return _routeResolver.fallbackForRole(role.backendValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: REdgeInsets.symmetric(horizontal: 18.w, vertical: 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_ios),
              ),
              SizedBox(height: 24.h),
              Text(
                'Choose account type',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                widget.googleSignUp
                    ? 'Choose the account type for this Google sign-up. CareNet will still collect required profile details after account creation.'
                    : 'CareNet uses different onboarding for patients and medical professionals.',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 32.h),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.red.shade700,
                  ),
                ),
                SizedBox(height: 14.h),
              ],
              _RoleCard(
                title: 'I need medical guidance',
                subtitle:
                    'Create a patient account for consultations, content, and health support.',
                onTap:
                    _isSubmitting
                        ? null
                        : () => _continueAs(SignUpRole.patient),
              ),
              SizedBox(height: 14.h),
              _RoleCard(
                title: 'I am a medical professional',
                subtitle:
                    'Create a professional account for profile setup and credential verification.',
                onTap:
                    _isSubmitting
                        ? null
                        : () => _continueAs(SignUpRole.professional),
              ),
              const Spacer(),
              CarenetButton(
                label: 'Already have an account? Sign in',
                type: CarenetButtonType.outline,
                onPressed:
                    () => Navigator.pushNamed(context, RouteName.signInEmail),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: REdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryBlue5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.account_circle_outlined, color: AppColors.primaryBlue5),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.kBlack,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.kBlack,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right, color: AppColors.primaryBlue5),
          ],
        ),
      ),
    );
  }
}
