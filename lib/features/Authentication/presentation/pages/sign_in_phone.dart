import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/model/sign_in_model.dart';
import 'package:app_t/core/model/validator.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/shared/widgets/auth_widget.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignInPhone extends StatefulWidget {
  const SignInPhone({super.key});

  @override
  State<SignInPhone> createState() => _SignInPhoneState();
}

class _SignInPhoneState extends State<SignInPhone> {
  late final TextEditingController _countryController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  bool _attemptedSubmit = false;
  bool _visiblePassword = true;

  @override
  void initState() {
    super.initState();
    _countryController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _countryController.addListener(_handleInputChanged);
    _phoneController.addListener(_handleInputChanged);
    _passwordController.addListener(_handleInputChanged);
  }

  @override
  void dispose() {
    _countryController.removeListener(_handleInputChanged);
    _phoneController.removeListener(_handleInputChanged);
    _passwordController.removeListener(_handleInputChanged);
    _countryController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
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

  String? get _passwordError => Validators.validateRequiredField(
    _passwordController.text,
    fieldName: 'Password',
  );

  bool get _canContinue =>
      _countryError == null && _phoneError == null && _passwordError == null;

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
      Navigator.pushNamed(context, RouteName.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final signInOptions = [
      AuthenticationModel(
        assetPath: AssetsIcon.mail,
        title: 'Continue with Email',
        btnAction: () {
          Navigator.pushNamed(context, RouteName.signInEmail);
        },
      ),
      AuthenticationModel(
        assetPath: AssetsIcon.google,
        title: 'Continue with Google',
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
                  'Sign in with phone',
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
              CarenetTextField(
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                hintText: 'Password',
                obscureText: _visiblePassword,
                validationState: _validationStateFor(_passwordError),
                errorText: _passwordError,
                suffixIcon: IconButton(
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
              SizedBox(height: 15.h),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, RouteName.enterEmail);
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: FontSizes.footer2,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryBlue5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: .03.sh),
              CarenetButton(label: 'Continue', onPressed: _onContinue),
              Center(
                child: Padding(
                  padding: REdgeInsets.symmetric(vertical: .03.sh),
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
                  itemCount: signInOptions.length,
                  itemBuilder: (context, index) {
                    return AuthWidget(
                      btnAction: signInOptions[index].btnAction,
                      assetPath: signInOptions[index].assetPath,
                      title: signInOptions[index].title,
                    );
                  },
                ),
              ),
              SizedBox(height: .045.sh),
              CarenetButton(
                label: 'Don\'t have an account? Sign up',
                onPressed: () {
                  Navigator.pushNamed(context, RouteName.signUpPhone);
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
