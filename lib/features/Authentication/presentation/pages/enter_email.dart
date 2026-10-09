import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/model/validator.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EnterEmailPage extends StatefulWidget {
  const EnterEmailPage({super.key, this.authRepository});

  final AuthRepository? authRepository;

  @override
  State<EnterEmailPage> createState() => _EnterEmailPageState();
}

class _EnterEmailPageState extends State<EnterEmailPage> {
  late final TextEditingController _emailController;
  bool _attemptedSubmit = false;
  bool _isSubmitting = false;
  bool _resetRequested = false;
  String? _authError;

  AuthRepository get _authRepository =>
      widget.authRepository ?? sl<AuthRepository>();

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
      setState(() {
        _resetRequested = false;
        _authError = null;
      });
    }
  }

  String? get _emailError => Validators.validateEmail(_emailController.text);

  CarenetTextFieldValidationState get _emailValidationState {
    if (!_attemptedSubmit) {
      return CarenetTextFieldValidationState.none;
    }

    return _emailError == null
        ? CarenetTextFieldValidationState.valid
        : CarenetTextFieldValidationState.invalid;
  }

  Future<void> _onContinue() async {
    setState(() {
      _attemptedSubmit = true;
      _authError = null;
    });

    if (_emailError != null || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final email = _emailController.text.trim();
      await _authRepository.requestPasswordReset(email: email);
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _resetRequested = true;
      });
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _authError = failure.message;
        _isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _authError = 'Something went wrong. Please try again.';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          const _RecoveryIcon(icon: Icons.lock_reset),
                          SizedBox(height: 20.h),
                          Semantics(
                            header: true,
                            child: Text(
                              'Reset your password',
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
                            'Enter the email linked to your account. We will show the same confirmation either way to protect account privacy.',
                            style: textTheme.bodyLarge?.copyWith(
                              color: CarenetColors.neutral500,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 28.h),
                          CarenetTextField(
                            label: 'Email address',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _onContinue(),
                            hintText: 'you@example.com',
                            prefixIcon: const Icon(Icons.email_outlined),
                            validationState: _emailValidationState,
                            errorText: _emailError,
                          ),
                          if (_authError != null) ...[
                            SizedBox(height: 16.h),
                            _RecoveryStatus(
                              message: _authError!,
                              isError: true,
                            ),
                          ],
                          if (_resetRequested) ...[
                            SizedBox(height: 16.h),
                            const _RecoveryStatus(
                              message:
                                  'If an account exists for that email, reset instructions will arrive shortly. Open the link in the email to choose a new password.',
                              isError: false,
                            ),
                          ],
                          SizedBox(height: 20.h),
                          if (_isSubmitting) ...[
                            Semantics(
                              label: 'Sending reset link',
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
                                    ? 'Sending reset link...'
                                    : _resetRequested
                                    ? 'Send another reset link'
                                    : 'Send reset link',
                            onPressed: _isSubmitting ? null : _onContinue,
                          ),
                          SizedBox(height: 12.h),
                          TextButton(
                            onPressed:
                                _isSubmitting
                                    ? null
                                    : () => Navigator.of(context).maybePop(),
                            style: TextButton.styleFrom(
                              minimumSize: Size.fromHeight(48.h),
                              foregroundColor: CarenetColors.brand,
                            ),
                            child: const Text('Back to sign in'),
                          ),
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

class _RecoveryIcon extends StatelessWidget {
  const _RecoveryIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 64.r,
        height: 64.r,
        decoration: BoxDecoration(
          color: CarenetColors.primary100,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(icon, color: CarenetColors.brand, size: 32.r),
      ),
    );
  }
}

class _RecoveryStatus extends StatelessWidget {
  const _RecoveryStatus({required this.message, required this.isError});

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
