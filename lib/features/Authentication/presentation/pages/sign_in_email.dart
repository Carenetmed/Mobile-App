import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/model/validator.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/google_sign_in_provider.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/presentation/services/booking_resume_navigator.dart';
import 'package:app_t/shared/widgets/auth_widget.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignInEmail extends StatefulWidget {
  const SignInEmail({
    super.key,
    this.authRepository,
    this.googleIdTokenProvider,
  });

  final AuthRepository? authRepository;
  final GoogleIdTokenProvider? googleIdTokenProvider;

  @override
  State<SignInEmail> createState() => _SignInEmailState();
}

class _SignInEmailState extends State<SignInEmail> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _attemptedSubmit = false;
  bool _visiblePassword = true;
  bool _isSubmitting = false;
  String? _authError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailController.addListener(_handleInputChanged);
    _passwordController.addListener(_handleInputChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_handleInputChanged);
    _passwordController.removeListener(_handleInputChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleInputChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String? get _emailError => Validators.validateEmail(_emailController.text);

  String? get _passwordError => Validators.validateRequiredField(
    _passwordController.text,
    fieldName: 'Password',
  );

  AuthRepository get _authRepository =>
      widget.authRepository ?? sl<AuthRepository>();

  GoogleIdTokenProvider get _googleIdTokenProvider =>
      widget.googleIdTokenProvider ?? sl<GoogleIdTokenProvider>();

  CarenetTextFieldValidationState _validationStateFor(String? error) {
    if (!_attemptedSubmit) {
      return CarenetTextFieldValidationState.none;
    }

    return error == null
        ? CarenetTextFieldValidationState.valid
        : CarenetTextFieldValidationState.invalid;
  }

  Future<void> _onContinue() async {
    setState(() {
      _attemptedSubmit = true;
      _authError = null;
    });

    if (_emailError != null || _passwordError != null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _authRepository.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) {
        return;
      }
      await BookingResumeNavigator.afterAuthentication(
        context,
        fallbackRoute: RouteName.dashboard,
        resolveReadinessWhenNoIntent: true,
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

  Future<void> _onGoogleSignIn() async {
    setState(() {
      _authError = null;
      _isSubmitting = true;
    });

    try {
      final idToken = await _googleIdTokenProvider.signInIdToken();
      await _authRepository.googleSignIn(idToken: idToken);
      if (!mounted) {
        return;
      }
      await BookingResumeNavigator.afterAuthentication(
        context,
        fallbackRoute: RouteName.dashboard,
        resolveReadinessWhenNoIntent: true,
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
        _authError = 'Google sign-in failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFA),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: REdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIGN IN',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w800,
                      color: CarenetColors.primary500,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Semantics(
                    header: true,
                    child: Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 26.sp,
                        height: 1.2,
                        fontFamily: AppFonts.montserrat,
                        fontWeight: FontWeight.w800,
                        color: CarenetColors.primary700,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Sign in to continue to your CareNet account.',
                    style: TextStyle(
                      fontSize: 15.sp,
                      height: 1.45,
                      fontFamily: AppFonts.montserrat,
                      color: CarenetColors.neutral500,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  AutofillGroup(
                    child: Column(
                      children: [
                        CarenetTextField(
                          label: 'Email address',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          hintText: 'you@example.com',
                          validationState: _validationStateFor(_emailError),
                          errorText: _emailError,
                        ),
                        SizedBox(height: 18.h),
                        CarenetTextField(
                          label: 'Password',
                          controller: _passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          hintText: 'Enter your password',
                          obscureText: _visiblePassword,
                          validationState: _validationStateFor(_passwordError),
                          errorText: _passwordError,
                          onFieldSubmitted: (_) {
                            if (!_isSubmitting) _onContinue();
                          },
                    suffixIcon: IconButton(
                      tooltip:
                          _visiblePassword ? 'Show password' : 'Hide password',
                      onPressed: () {
                        setState(() {
                          _visiblePassword = !_visiblePassword;
                        });
                      },
                      icon:
                          _visiblePassword
                              ? SvgImage(imgName: AssetsIcon.visible)
                              : const Icon(Icons.visibility_off),
                    ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed:
                          _isSubmitting
                              ? null
                              : () => Navigator.pushNamed(
                                context,
                                RouteName.enterEmail,
                              ),
                      style: TextButton.styleFrom(
                        minimumSize: Size(0, 48.h),
                        padding: REdgeInsets.symmetric(horizontal: 4),
                        tapTargetSize: MaterialTapTargetSize.padded,
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w600,
                          color: CarenetColors.primary500,
                        ),
                      ),
                    ),
                  ),
                  if (_authError != null) ...[
                    Semantics(
                      liveRegion: true,
                      child: Container(
                        width: double.infinity,
                        padding: REdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CarenetColors.error200,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: CarenetColors.error100,
                              size: 20.r,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                _authError!,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  height: 1.4,
                                  fontFamily: AppFonts.montserrat,
                                  color: CarenetColors.error100,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                  CarenetButton(
                    label: _isSubmitting ? 'Signing in...' : 'Continue',
                    onPressed: _isSubmitting ? null : _onContinue,
                  ),
                  Padding(
                    padding: REdgeInsets.only(bottom: 12.h, top: 28.h),
                    child: Center(
                      child: Text(
                        'Or continue securely with',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.4,
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w500,
                          color: CarenetColors.neutral500,
                        ),
                      ),
                    ),
                  ),
                  AuthWidget(
                    btnAction:
                        _isSubmitting || !_googleIdTokenProvider.isConfigured
                            ? null
                            : _onGoogleSignIn,
                    assetPath: AssetsIcon.google,
                    title: 'Continue with Google',
                  ),
                  if (!_googleIdTokenProvider.isConfigured)
                    Padding(
                      padding: REdgeInsets.only(top: 8.h),
                      child: Text(
                        'Google sign-in is temporarily unavailable.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.4,
                          fontFamily: AppFonts.montserrat,
                          color: CarenetColors.neutral500,
                        ),
                      ),
                    ),
                  SizedBox(height: 28.h),
                  CarenetButton(
                    label: 'Don\'t have an account? Sign up',
                    onPressed: () {
                      Navigator.pushNamed(context, RouteName.signUpEmail);
                    },
                    type: CarenetButtonType.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
