import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/model/validator.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/google_sign_in_provider.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_arguments.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/shared/widgets/auth_widget.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUpEmail extends StatefulWidget {
  const SignUpEmail({
    super.key,
    this.authRepository,
    this.googleIdTokenProvider,
    this.onboardingRepository,
  });

  final AuthRepository? authRepository;
  final GoogleIdTokenProvider? googleIdTokenProvider;
  final OnboardingRepository? onboardingRepository;

  @override
  State<SignUpEmail> createState() => _SignUpEmailState();
}

class _SignUpEmailState extends State<SignUpEmail> {
  late final TextEditingController _emailController;
  bool _attemptedSubmit = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _emailController.addListener(_handleInputChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_handleInputChanged);
    _emailController.dispose();
    super.dispose();
  }

  void _handleInputChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String? get _emailError => Validators.validateEmail(_emailController.text);

  GoogleIdTokenProvider get _googleIdTokenProvider =>
      widget.googleIdTokenProvider ?? sl<GoogleIdTokenProvider>();

  CarenetTextFieldValidationState get _emailValidationState {
    if (!_attemptedSubmit) {
      return CarenetTextFieldValidationState.none;
    }

    return _emailError == null
        ? CarenetTextFieldValidationState.valid
        : CarenetTextFieldValidationState.invalid;
  }

  void _onContinue() {
    setState(() {
      _attemptedSubmit = true;
    });

    if (_emailError == null) {
      Navigator.pushNamed(
        context,
        RouteName.signUpRole,
        arguments: SignUpRoleSelectionArgs(
          initialEmail: _emailController.text.trim(),
          passwordSignUp: true,
          onboardingRepository: widget.onboardingRepository,
        ),
      );
    }
  }

  void _onGoogleSignUp() {
    Navigator.pushNamed(
      context,
      RouteName.signUpRole,
      arguments: SignUpRoleSelectionArgs(
        googleSignUp: true,
        authRepository: widget.authRepository,
        googleIdTokenProvider: widget.googleIdTokenProvider,
        onboardingRepository: widget.onboardingRepository,
      ),
    );
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
                    'CREATE ACCOUNT',
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
                      'Create your CareNet account',
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
                    'Enter your email to continue.',
                    style: TextStyle(
                      fontSize: 15.sp,
                      height: 1.45,
                      fontFamily: AppFonts.montserrat,
                      color: CarenetColors.neutral500,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  CarenetTextField(
                    label: 'Email address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    hintText: 'you@example.com',
                    validationState: _emailValidationState,
                    errorText: _emailError,
                  ),
                  SizedBox(height: 18.h),
                  CarenetButton(label: 'Continue', onPressed: _onContinue),
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
                        _googleIdTokenProvider.isConfigured
                            ? _onGoogleSignUp
                            : null,
                    assetPath: AssetsIcon.google,
                    title: 'Continue with Google',
                  ),
                  SizedBox(height: 28.h),
                  CarenetButton(
                    label: 'Already have an account? Sign in',
                    onPressed: () {
                      Navigator.pushNamed(context, RouteName.signInEmail);
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
