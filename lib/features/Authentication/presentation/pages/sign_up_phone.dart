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
import 'package:app_t/shared/widgets/auth_widget.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUpPhone extends StatefulWidget {
  const SignUpPhone({
    super.key,
    this.authRepository,
    this.googleIdTokenProvider,
  });

  final AuthRepository? authRepository;
  final GoogleIdTokenProvider? googleIdTokenProvider;

  @override
  State<SignUpPhone> createState() => _SignUpPhoneState();
}

class _SignUpPhoneState extends State<SignUpPhone> {
  late final TextEditingController _countryController;
  late final TextEditingController _phoneController;
  bool _attemptedSubmit = false;

  @override
  void initState() {
    super.initState();
    _countryController = TextEditingController();
    _phoneController = TextEditingController();
    _countryController.addListener(_handleInputChanged);
    _phoneController.addListener(_handleInputChanged);
  }

  @override
  void dispose() {
    _countryController.removeListener(_handleInputChanged);
    _phoneController.removeListener(_handleInputChanged);
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleInputChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String? get _countryError => Validators.validateRequiredField(
    _countryController.text,
    fieldName: 'Country/Region',
  );

  String? get _phoneError => Validators.validatePhone(_phoneController.text);

  bool get _canContinue => _countryError == null && _phoneError == null;

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

  void _onContinue() {
    setState(() {
      _attemptedSubmit = true;
    });

    if (_canContinue) {
      Navigator.pushNamed(context, RouteName.signUpRole);
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<AuthenticationModel> signUp = [
      AuthenticationModel(
        assetPath: AssetsIcon.mail,
        title: 'Continue with Email',
        btnAction: () {
          Navigator.pushNamed(context, RouteName.signUpEmail);
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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: REdgeInsets.only(left: 15.w, right: 15.w, top: .04.sh),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'Sign up with phone',
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
                controller: _countryController,
                hintText: 'Country/Region',
                validationState: _validationStateFor(_countryError),
                errorText: _countryError,
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 24.sp,
                ),
              ),
              SizedBox(height: 15.h),
              CarenetTextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                hintText: 'Phone Number',
                validationState: _validationStateFor(_phoneError),
                errorText: _phoneError,
              ),
              SizedBox(height: 15.h),
              Text(
                'We will call or text to confirm your number. Standard message\nand data rates apply',
                style: TextStyle(
                  fontSize: FontSizes.footer2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: .05.sh),
              CarenetButton(label: 'Continue', onPressed: _onContinue),
              Center(
                child: Padding(
                  padding: REdgeInsets.symmetric(vertical: .06.sh),
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
                  Navigator.pushNamed(context, RouteName.signInPhone);
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
