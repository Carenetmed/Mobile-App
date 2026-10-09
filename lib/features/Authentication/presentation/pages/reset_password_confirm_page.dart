import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/model/validator.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
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
      setState(() {
        if (_messageIsError) {
          _message = null;
          _messageIsError = false;
        }
      });
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

    if (!_hasToken ||
        _isSubmitting ||
        _completed ||
        _passwordError != null ||
        _confirmPasswordError != null) {
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

  void _backToSignIn() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteName.signInEmail,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _hasToken && !_isSubmitting && !_completed;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFA),
      body: SafeArea(
        child: LayoutBuilder(
          builder:
              (context, constraints) => SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 36.h,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              tooltip: 'Back',
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(Icons.arrow_back),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Center(
                            child: Container(
                              width: 64.r,
                              height: 64.r,
                              decoration: BoxDecoration(
                                color: CarenetColors.primary100,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Icon(
                                Icons.lock_reset,
                                color: CarenetColors.brand,
                                size: 32.r,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Semantics(
                            header: true,
                            child: Text(
                              'Reset password',
                              style: textTheme.headlineSmall?.copyWith(
                                color: CarenetColors.neutral700,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            _hasToken
                                ? 'Choose a new password for your account.'
                                : 'Open the password reset link from your email to continue.',
                            style: textTheme.bodyLarge?.copyWith(
                              color: CarenetColors.neutral500,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 28.h),
                          if (!_hasToken) ...[
                            const _ResetStatus(
                              message:
                                  'Reset link is missing or invalid. Request a new password reset email.',
                              isError: true,
                            ),
                            SizedBox(height: 16.h),
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
                              label: 'New password',
                              controller: _passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.next,
                              hintText: 'Enter your new password',
                              obscureText: !_visiblePassword,
                              validationState: _validationStateFor(
                                _passwordError,
                              ),
                              errorText: _passwordError,
                              suffixIcon: IconButton(
                                tooltip:
                                    _visiblePassword
                                        ? 'Hide password'
                                        : 'Show password',
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
                            SizedBox(height: 16.h),
                            CarenetTextField(
                              label: 'Confirm new password',
                              controller: _confirmPasswordController,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _confirmReset(),
                              hintText: 'Re-enter your new password',
                              obscureText: !_visibleConfirmPassword,
                              validationState: _validationStateFor(
                                _confirmPasswordError,
                              ),
                              errorText: _confirmPasswordError,
                              suffixIcon: IconButton(
                                tooltip:
                                    _visibleConfirmPassword
                                        ? 'Hide confirm password'
                                        : 'Show confirm password',
                                onPressed: () {
                                  setState(() {
                                    _visibleConfirmPassword =
                                        !_visibleConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  _visibleConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Use at least 15 characters. Avoid common passwords.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: CarenetColors.neutral500,
                                height: 1.45,
                              ),
                            ),
                            if (_message != null) ...[
                              SizedBox(height: 16.h),
                              _ResetStatus(
                                message: _message!,
                                isError: _messageIsError,
                              ),
                            ],
                            SizedBox(height: 20.h),
                            if (_isSubmitting) ...[
                              Semantics(
                                label: 'Updating password',
                                liveRegion: true,
                                child: LinearProgressIndicator(
                                  color: CarenetColors.brand,
                                  backgroundColor: CarenetColors.primary100,
                                ),
                              ),
                              SizedBox(height: 12.h),
                            ],
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
                                onPressed: _backToSignIn,
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}

class _ResetStatus extends StatelessWidget {
  const _ResetStatus({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final foreground =
        isError ? CarenetColors.error100 : CarenetColors.success100;
    final background =
        isError ? CarenetColors.error200 : CarenetColors.success200;

    return Semantics(
      container: true,
      liveRegion: true,
      label: message,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: foreground,
              size: 22.r,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: foreground,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
