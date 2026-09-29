import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/model/validator.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResetPasswordConfirmPage extends StatefulWidget {
  const ResetPasswordConfirmPage({
    super.key,
    required this.token,
    this.authRepository,
  });

  final String? token;
  final AuthRepository? authRepository;

  @override
  State<ResetPasswordConfirmPage> createState() =>
      _ResetPasswordConfirmPageState();
}

class _ResetPasswordConfirmPageState extends State<ResetPasswordConfirmPage> {
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _attemptedSubmit = false;
  bool _isSubmitting = false;
  bool _completed = false;
  bool _visiblePassword = false;
  bool _visibleConfirmPassword = false;
  String? _message;
  bool _messageIsError = false;

  AuthRepository get _authRepository =>
      widget.authRepository ?? sl<AuthRepository>();

  bool get _hasToken => widget.token != null && widget.token!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _passwordController.addListener(_handleInputChanged);
    _confirmPasswordController.addListener(_handleInputChanged);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_handleInputChanged);
    _confirmPasswordController.removeListener(_handleInputChanged);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleInputChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String? get _passwordError =>
      Validators.validatePassword(_passwordController.text);

  String? get _confirmPasswordError => Validators.validateConfirmPassword(
    _confirmPasswordController.text,
    password: _passwordController.text,
  );

  CarenetTextFieldValidationState _validationStateFor(String? error) {
    if (!_attemptedSubmit) {
      return CarenetTextFieldValidationState.none;
    }
    return error == null
        ? CarenetTextFieldValidationState.valid
        : CarenetTextFieldValidationState.invalid;
  }

  Future<void> _confirmReset() async {
    setState(() {
      _attemptedSubmit = true;
      _message = null;
      _messageIsError = false;
    });

    if (!_hasToken || _passwordError != null || _confirmPasswordError != null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _authRepository.confirmPasswordReset(
        token: widget.token!.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _completed = true;
        _message =
            'Password updated. Please sign in again with your new password.';
        _messageIsError = false;
      });
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _message = failure.message;
        _messageIsError = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _message = 'Reset link is invalid or expired.';
        _messageIsError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _hasToken && !_isSubmitting && !_completed;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: REdgeInsets.only(left: 15.w, right: 15.w, top: .04.sh),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_ios),
              ),
              SizedBox(height: .02.sh),
              Text(
                'Reset password',
                style: TextStyle(
                  fontSize: FontSizes.heading3,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _hasToken
                    ? 'Enter a new password to finish your reset'
                    : 'Open the reset link from your email to continue',
                style: TextStyle(
                  fontSize: FontSizes.footer2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryBlue11,
                ),
              ),
              SizedBox(height: .05.sh),
              if (!_hasToken) ...[
                _StatusText(
                  message:
                      'Reset link is missing or invalid. Request a new password reset email.',
                  isError: true,
                ),
                SizedBox(height: 12.h),
                CarenetButton(
                  label: 'Request new reset email',
                  type: CarenetButtonType.outline,
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      RouteName.enterEmail,
                    );
                  },
                ),
              ] else ...[
                CarenetTextField(
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  hintText: 'Enter your new password',
                  obscureText: !_visiblePassword,
                  validationState: _validationStateFor(_passwordError),
                  errorText: _passwordError,
                  suffixIcon: IconButton(
                    tooltip:
                        _visiblePassword ? 'Hide password' : 'Show password',
                    onPressed: () {
                      setState(() {
                        _visiblePassword = !_visiblePassword;
                      });
                    },
                    icon: Icon(
                      _visiblePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
                CarenetTextField(
                  controller: _confirmPasswordController,
                  keyboardType: TextInputType.visiblePassword,
                  hintText: 'Confirm password',
                  obscureText: !_visibleConfirmPassword,
                  validationState: _validationStateFor(_confirmPasswordError),
                  errorText: _confirmPasswordError,
                  suffixIcon: IconButton(
                    tooltip:
                        _visibleConfirmPassword
                            ? 'Hide confirm password'
                            : 'Show confirm password',
                    onPressed: () {
                      setState(() {
                        _visibleConfirmPassword = !_visibleConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _visibleConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
                Text(
                  'The reset token is used only for this request and is not stored by the app.',
                  style: TextStyle(
                    fontSize: FontSizes.footer2,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w400,
                    color: AppColors.kBlack,
                    height: 1.4,
                  ),
                ),
                if (_message != null) ...[
                  SizedBox(height: 15.h),
                  _StatusText(message: _message!, isError: _messageIsError),
                ],
                SizedBox(height: .05.sh),
                CarenetButton(
                  label:
                      _isSubmitting
                          ? 'Updating password...'
                          : 'Update password',
                  onPressed: canSubmit ? _confirmReset : null,
                ),
                if (_completed) ...[
                  SizedBox(height: 12.h),
                  CarenetButton(
                    label: 'Back to sign in',
                    type: CarenetButtonType.outline,
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        RouteName.signInEmail,
                        (_) => false,
                      );
                    },
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(
        fontSize: FontSizes.footer4,
        fontFamily: AppFonts.montserrat,
        fontWeight: FontWeight.w500,
        color: isError ? Colors.redAccent : AppColors.primaryBlue5,
        height: 1.4,
      ),
    );
  }
}
