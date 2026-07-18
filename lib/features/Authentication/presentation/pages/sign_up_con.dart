import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/model/validator.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_arguments.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FinSignUp extends StatefulWidget {
  const FinSignUp({
    super.key,
    this.initialEmail,
    this.selectedRole = SignUpRole.patient,
    this.authRepository,
  });

  final String? initialEmail;
  final SignUpRole selectedRole;
  final AuthRepository? authRepository;

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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: REdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const Spacer(),
                  Text(
                    'Create account',
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: CarenetColors.neutral700,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 48.w),
                ],
              ),
              SizedBox(height: 26.h),
              Text(
                'Secure your CareNet account',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: 25.sp,
                  fontWeight: FontWeight.w800,
                  color: CarenetColors.neutral700,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                widget.selectedRole == SignUpRole.professional
                    ? 'Create your professional account first. Your legal identity, qualifications, licence, and practice details are collected in the professional application next.'
                    : 'Create your patient account first. We will ask for care profile details only when they are needed for setup or booking.',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: 13.sp,
                  height: 1.45,
                  color: CarenetColors.neutral500,
                ),
              ),
              SizedBox(height: 18.h),
              Container(
                width: double.infinity,
                padding: REdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CarenetColors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFDCE8E4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 36.r,
                      width: 36.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F7F0),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        widget.selectedRole == SignUpRole.professional
                            ? Icons.medical_services_outlined
                            : Icons.favorite_border_rounded,
                        color: const Color(0xFF137A58),
                        size: 20.r,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.selectedRole.title} account',
                            style: TextStyle(
                              fontFamily: AppFonts.montserrat,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: CarenetColors.neutral700,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'This step only verifies your sign-in credentials.',
                            style: TextStyle(
                              fontFamily: AppFonts.montserrat,
                              fontSize: 12.sp,
                              height: 1.35,
                              color: CarenetColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 22.h),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CredentialField(
                      controller: _emailController,
                      hintText: 'Email address',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                    SizedBox(height: 14.h),
                    _CredentialField(
                      controller: _passwordController,
                      hintText: 'Password',
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _visiblePassword,
                      validator: Validators.validatePassword,
                      suffixIcon: IconButton(
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
                    _CredentialField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm password',
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _visibleConfirmPassword,
                      validator:
                          (value) => Validators.validateConfirmPassword(
                            value,
                            password: _passwordController.text,
                          ),
                      suffixIcon: IconButton(
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
              SizedBox(height: 14.h),
              Text(
                'Use at least 15 characters with numbers and special characters.',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: 12.sp,
                  height: 1.35,
                  color: CarenetColors.neutral500,
                ),
              ),
              SizedBox(height: 24.h),
              if (_authError != null) ...[
                Container(
                  width: double.infinity,
                  padding: REdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CarenetColors.error200,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: CarenetColors.error100),
                  ),
                  child: Text(
                    _authError!,
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      fontSize: 12.sp,
                      height: 1.35,
                      color: CarenetColors.error100,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
              ],
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          'By selecting Agree and continue, I agree to CareNet\'s ',
                      style: TextStyle(
                        fontFamily: AppFonts.montserrat,
                        color: CarenetColors.neutral600,
                        fontSize: 12.sp,
                        height: 1.45,
                      ),
                    ),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        fontFamily: AppFonts.montserrat,
                        fontSize: 12.sp,
                        color: CarenetColors.brand,
                        height: 1.45,
                        decoration: TextDecoration.underline,
                        decorationColor: CarenetColors.brand,
                      ),
                    ),
                    TextSpan(
                      text: ' and acknowledge the ',
                      style: TextStyle(
                        fontFamily: AppFonts.montserrat,
                        fontSize: 12.sp,
                        color: CarenetColors.neutral600,
                        height: 1.45,
                      ),
                    ),
                    TextSpan(
                      text: 'Privacy Policy.',
                      style: TextStyle(
                        fontFamily: AppFonts.montserrat,
                        fontSize: 12.sp,
                        color: CarenetColors.brand,
                        height: 1.45,
                        decoration: TextDecoration.underline,
                        decorationColor: CarenetColors.brand,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 5.h),
              CarenetButton(
                onPressed: _isSubmitting ? null : _onAgreeAndContinue,
                label:
                    _isSubmitting ? 'Creating account...' : 'Agree & continue',
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
      Navigator.of(context).popAndPushNamed(
        widget.selectedRole == SignUpRole.professional
            ? RouteName.medicalProfessional
            : RouteName.patientOnboardingSetup,
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
}

class _CredentialField extends StatelessWidget {
  const _CredentialField({
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    required this.validator,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final String? Function(String?) validator;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
        fontFamily: AppFonts.montserrat,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: CarenetColors.neutral700,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: CarenetColors.white,
        contentPadding: REdgeInsets.symmetric(horizontal: 14, vertical: 15),
        hintStyle: TextStyle(
          fontFamily: AppFonts.montserrat,
          fontSize: 14.sp,
          color: CarenetColors.neutral300,
        ),
        errorStyle: TextStyle(
          fontFamily: AppFonts.montserrat,
          fontSize: 11.sp,
          height: 1.25,
          color: CarenetColors.error100,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFFDADFE7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFFDADFE7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFF137A58), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: CarenetColors.error100),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: CarenetColors.error100),
        ),
      ),
    );
  }
}
