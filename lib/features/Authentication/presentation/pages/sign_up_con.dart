import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/config/carenet_public_links.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/model/validator.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_arguments.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/presentation/services/booking_resume_navigator.dart';
import 'package:app_t/features/Onboarding/domain/services/onboarding_readiness_route_resolver.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FinSignUp extends StatefulWidget {
  const FinSignUp({
    super.key,
    this.initialEmail,
    this.selectedRole = SignUpRole.patient,
    this.authRepository,
    this.onboardingRepository,
    this.publicLinkLauncher,
  });

  final String? initialEmail;
  final SignUpRole selectedRole;
  final AuthRepository? authRepository;
  final OnboardingRepository? onboardingRepository;
  final PublicLinkLauncher? publicLinkLauncher;

  @override
  State<FinSignUp> createState() => _FinSignUpState();
}

class _FinSignUpState extends State<FinSignUp> {
  bool _visiblePassword = true;
  bool _visibleConfirmPassword = true;

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _authError;

  AuthRepository get _authRepository =>
      widget.authRepository ?? sl<AuthRepository>();

  OnboardingRepository get _onboardingRepository =>
      widget.onboardingRepository ?? sl<OnboardingRepository>();

  static const _routeResolver = OnboardingReadinessRouteResolver();

  Future<void> _openPublicLink(Uri uri) async {
    final launcher = widget.publicLinkLauncher ?? CareNetPublicLinks.launch;
    final opened = await launcher(uri);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open this page. Please try again.'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: REdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              SizedBox(height: 8.h),
              Text(
                'SECURE ACCOUNT',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: CarenetColors.primary500,
                ),
              ),
              SizedBox(height: 8.h),
              Semantics(
                header: true,
                child: Text(
                  'Secure your ${widget.selectedRole.title.toLowerCase()} account',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontSize: 26.sp,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: CarenetColors.primary700,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Create your login now. Your profile details are collected in the next role-specific step.',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: 14.sp,
                  height: 1.45,
                  color: CarenetColors.neutral500,
                ),
              ),
              SizedBox(height: 28.h),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CarenetTextField(
                      label: 'Email address',
                      hintText: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      validator: Validators.validateEmail,
                    ),
                    SizedBox(height: 14.h),
                    CarenetTextField(
                      label: 'Password',
                      hintText: 'At least 15 characters',
                      controller: _passwordController,
                      obscureText: _visiblePassword,
                      validator: Validators.validatePassword,
                      suffixIcon: IconButton(
                        tooltip:
                            _visiblePassword
                                ? 'Show password'
                                : 'Hide password',
                        onPressed: () {
                          setState(() {
                            _visiblePassword = !_visiblePassword;
                          });
                        },
                        icon: Icon(
                          _visiblePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    CarenetTextField(
                      label: 'Confirm password',
                      hintText: 'Enter it again',
                      controller: _confirmPasswordController,
                      obscureText: _visibleConfirmPassword,
                      validator:
                          (value) => Validators.validateConfirmPassword(
                            value,
                            password: _passwordController.text,
                          ),
                      suffixIcon: IconButton(
                        tooltip:
                            _visibleConfirmPassword
                                ? 'Show confirm password'
                                : 'Hide confirm password',
                        onPressed: () {
                          setState(() {
                            _visibleConfirmPassword = !_visibleConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _visibleConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: REdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: CarenetColors.primary100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Account type: ${widget.selectedRole.title}',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: CarenetColors.primary700,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Use 15 to 128 characters. Longer passphrases are supported.',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: 13.sp,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                  color: CarenetColors.neutral500,
                ),
              ),
              SizedBox(height: 24.h),
              if (_authError != null) ...[
                Semantics(
                  liveRegion: true,
                  label: _authError,
                  excludeSemantics: true,
                  child: Container(
                    width: double.infinity,
                    padding: REdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CarenetColors.error200,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      _authError!,
                      style: TextStyle(
                        fontFamily: AppFonts.montserrat,
                        fontSize: 13.sp,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: CarenetColors.error100,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
              ],
              Text(
                'By continuing, you agree to CareNet\'s Terms of Service and acknowledge the Privacy Policy.',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  color: CarenetColors.neutral500,
                  fontSize: 12.sp,
                  height: 1.45,
                ),
              ),
              Wrap(
                spacing: 8.w,
                children: [
                  TextButton(
                    key: const Key('sign-up-terms-link'),
                    onPressed: () => _openPublicLink(CareNetPublicLinks.terms),
                    child: const Text('Terms of Service'),
                  ),
                  TextButton(
                    key: const Key('sign-up-privacy-link'),
                    onPressed:
                        () => _openPublicLink(CareNetPublicLinks.privacy),
                    child: const Text('Privacy Policy'),
                  ),
                ],
              ),

              SizedBox(height: 5.h),
              CarenetButton(
                onPressed: _isSubmitting ? null : _onAgreeAndContinue,
                label:
                    _isSubmitting ? 'Creating account...' : ' Agree & continue',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onAgreeAndContinue() async {
    setState(() {
      _authError = null;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _authRepository.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: widget.selectedRole.backendValue,
      );
      if (!mounted) {
        return;
      }
      final routeName = await _resolveNextRoute();
      if (!mounted) {
        return;
      }
      await BookingResumeNavigator.afterAuthentication(
        context,
        fallbackRoute: routeName,
      );
    } on AuthFailure catch (failure) {
      if (!mounted) {
        return;
      }
      setState(() {
        _authError = failure.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _authError = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<String> _resolveNextRoute() async {
    try {
      final readiness = await _onboardingRepository.accountReadiness();
      return _routeResolver.resolve(
        readiness: readiness,
        fallbackRole: widget.selectedRole.backendValue,
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
      return _routeResolver.fallbackForRole(widget.selectedRole.backendValue);
    }
  }
}
