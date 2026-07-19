import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/model/validator.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_arguments.dart';
import 'package:app_t/features/Authentication/presentation/widget/bordered_keyboard_input.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Onboarding/domain/services/onboarding_readiness_route_resolver.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FinSignUp extends StatefulWidget {
  const FinSignUp({
    super.key,
    this.initialEmail,
    this.selectedRole = SignUpRole.patient,
    this.authRepository,
    this.onboardingRepository,
  });

  final String? initialEmail;
  final SignUpRole selectedRole;
  final AuthRepository? authRepository;
  final OnboardingRepository? onboardingRepository;

  @override
  State<FinSignUp> createState() => _FinSignUpState();
}

class _FinSignUpState extends State<FinSignUp> {
  // TextEditingController _dateController = TextEditingController();

  bool _visiblePassword = true;
  bool _visibleConfirmPassword = true;

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _dateController;
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

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _dateController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: REdgeInsets.symmetric(horizontal: 15.w, vertical: .06.sh),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).maybePop();
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  const Spacer(),
                  Text(
                    'Finish signing up',
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              SizedBox(height: 20.h),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BorderedTextInput(
                      keyboardType1: TextInputType.name,
                      keyboardType2: TextInputType.name,
                      hintText1: 'First name',
                      hintText2: 'Last name',
                      controller1: _firstNameController,
                      controller2: _lastNameController,
                      suffixIcon2: SizedBox(),

                      validator1: Validators.validateFirstName,
                      validator2: Validators.validateLastNAme,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Please make sure it matches the name on your government ID',
                      style: TextStyle(
                        fontFamily: AppFonts.montserrat,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 50.h),
                    BorderedTextInput(
                      keyboardType2: TextInputType.emailAddress,
                      suffixIcon1: Icon(Icons.keyboard_arrow_down_rounded),
                      controller1: _dateController,
                      controller2: _emailController,
                      validator1: Validators.validateBirthday,
                      validator2: Validators.validateEmail,
                      suffixIcon2: SizedBox(),
                      readOnly1: true,
                      onTap1: () async {
                        final picker = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(3000),
                        );
                        if (picker != null) {
                          setState(() {
                            _dateController.text =
                                picker.toString().split(' ')[0];
                          });
                        }
                      },
                      hintText1: 'Birthday',
                      hintText2: 'Email address',
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Your birthday wont be shared with other people who use this\nservice',
                      style: TextStyle(
                        fontFamily: AppFonts.montserrat,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 50.h),
                    BorderedTextInput(
                      keyboardType1: TextInputType.visiblePassword,
                      keyboardType2: TextInputType.visiblePassword,
                      obscureText1: _visiblePassword,
                      obscureText2: _visibleConfirmPassword,
                      controller1: _passwordController,
                      controller2: _confirmPasswordController,
                      validator1: Validators.validatePassword,
                      validator2:
                          (value) => Validators.validateConfirmPassword(
                            value,
                            password: _passwordController.text,
                          ),
                      hintText1: 'Password',
                      hintText2: 'Confirm password',
                      suffixIcon1: IconButton(
                        onPressed: () {
                          setState(() {
                            _visiblePassword = !_visiblePassword;
                          });
                        },
                        icon:
                            _visiblePassword
                                ? SvgImage(imgName: AssetsIcon.visible)
                                : Icon(Icons.visibility_off),
                      ),
                      suffixIcon2: IconButton(
                        onPressed: () {
                          setState(() {
                            _visibleConfirmPassword = !_visibleConfirmPassword;
                          });
                        },
                        icon:
                            _visibleConfirmPassword
                                ? SvgImage(imgName: AssetsIcon.visible)
                                : Icon(Icons.visibility_off),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Account type: ${widget.selectedRole.title}',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue5,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Your password must be at least 15 characters long including\nnumbers and special characters.',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 50.h),
              if (_authError != null) ...[
                Text(
                  _authError!,
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.red.shade700,
                  ),
                ),
                SizedBox(height: 12.h),
              ],
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          'By selecting Agree and continue, I agree to Carenet\'s',
                      style: TextStyle(
                        fontFamily: AppFonts.montserrat,
                        color: AppColors.kBlack,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: ' Terms of\nService,',
                      style: TextStyle(
                        fontFamily: AppFonts.montserrat,
                        fontSize: 12.sp,
                        color: AppColors.primaryBlue5,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primaryBlue5,
                      ),
                    ),
                    TextSpan(
                      text: 'and I acknowledge the',
                      style: TextStyle(
                        fontFamily: AppFonts.montserrat,
                        fontSize: 12.sp,
                        color: AppColors.kBlack,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: 'Privacy Policy.',
                      style: TextStyle(
                        fontFamily: AppFonts.montserrat,
                        fontSize: 12.sp,
                        color: AppColors.primaryBlue5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
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
      Navigator.of(context).popAndPushNamed(routeName);
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
