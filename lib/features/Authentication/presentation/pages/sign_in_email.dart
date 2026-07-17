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
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
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
      Navigator.pushNamed(context, RouteName.dashboard);
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
      Navigator.pushNamed(context, RouteName.dashboard);
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
    final showGoogleAuthUi = GoogleAuthUiConfig.isEnabled;
    final signInOptions = [
      AuthenticationModel(
        assetPath: AssetsIcon.phone,
        title: 'Continue with Phone',
        btnAction: () {
          Navigator.pushNamed(context, RouteName.signInPhone);
        },
      ),
      if (showGoogleAuthUi)
        AuthenticationModel(
          assetPath: AssetsIcon.google,
          title: 'Continue with Google',
          btnAction:
              _isSubmitting || !_googleIdTokenProvider.isConfigured
                  ? null
                  : _onGoogleSignIn,
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
          padding: REdgeInsets.only(left: 15.w, right: 15.w, top: .04.sh),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'Sign in with Email',
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
                validationState: _validationStateFor(_emailError),
                errorText: _emailError,
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
              if (_authError != null) ...[
                Text(
                  _authError!,
                  style: TextStyle(
                    fontSize: FontSizes.body3,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w400,
                    color: Colors.red.shade700,
                  ),
                ),
                SizedBox(height: 12.h),
              ],
              CarenetButton(
                label: _isSubmitting ? 'Signing in...' : 'Continue',
                onPressed: _isSubmitting ? null : _onContinue,
              ),
              RPadding(
                padding: REdgeInsets.only(top: 15.h, bottom: .05.sh),
                child: Center(
                  child: Text(
                    'Other sign in options',
                    style: TextStyle(
                      fontSize: FontSizes.footer2,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryBlue5,
                    ),
                  ),
                ),
              ),
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
              SizedBox(height: .03.sh),
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
                  Navigator.pushNamed(context, RouteName.signUpEmail);
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
