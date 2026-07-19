import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/model/sign_in_model.dart';
import 'package:app_t/core/model/validator.dart';
import 'package:app_t/core/theme/textStyle.dart';
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
    final List<AuthenticationModel> signUp = [
      AuthenticationModel(
        assetPath: AssetsIcon.phone,
        title: 'Continue with Phone',
        btnAction: () {
          Navigator.pushNamed(context, RouteName.signUpPhone);
        },
      ),
      AuthenticationModel(
        assetPath: AssetsIcon.google,
        title: 'Continue with Google',
        btnAction: _googleIdTokenProvider.isConfigured ? _onGoogleSignUp : null,
      ),
      AuthenticationModel(
        assetPath: AssetsIcon.facebook,
        title: 'Continue with Facebook',
      ),
      AuthenticationModel(
        assetPath: AssetsIcon.apple,
        title: 'Continue with Apple',
      ),
    ];
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: RPadding(
          padding: REdgeInsets.only(left: 15.w, right: 15.w, top: .04.sh),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'Sign up with email',
                  style: TextStyle(
                    fontSize: FontSizes.footer2,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryBlue5,
                  ),
                ),
              ),
              SizedBox(height: .05.sh),
              CarenetTextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                hintText: 'Email',
                validationState: _emailValidationState,
                errorText: _emailError,
              ),
              SizedBox(height: 15.h),
              CarenetButton(label: 'Continue', onPressed: _onContinue),
              Padding(
                padding: REdgeInsets.only(bottom: .052.sh, top: .15.sh),
                child: Center(
                  child: Text(
                    'or',
                    style: TextStyle(
                      fontSize: FontSizes.body3,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w500,
                      color: AppColors.kBlack,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: .27.sh,
                child: ListView.builder(
                  itemCount: signUp.length,
                  itemBuilder: (context, index) {
                    return AuthWidget(
                      btnAction: signUp[index].btnAction,
                      assetPath: signUp[index].assetPath,
                      title: signUp[index].title,
                    );
                  },
                ),
              ),
              SizedBox(height: .045.sh),
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
    );
  }
}
