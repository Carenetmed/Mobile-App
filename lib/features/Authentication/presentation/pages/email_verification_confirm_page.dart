import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Authentication/data/repositories/account_repository.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmailVerificationConfirmPage extends StatefulWidget {
  const EmailVerificationConfirmPage({
    super.key,
    required this.token,
    this.accountRepository,
  });

  final String? token;
  final AccountRepository? accountRepository;

  @override
  State<EmailVerificationConfirmPage> createState() =>
      _EmailVerificationConfirmPageState();
}

class _EmailVerificationConfirmPageState
    extends State<EmailVerificationConfirmPage> {
  bool _isSubmitting = false;
  bool _completed = false;
  String? _message;
  bool _messageIsError = false;

  AccountRepository get _accountRepository =>
      widget.accountRepository ?? sl<AccountRepository>();

  bool get _hasToken => widget.token != null && widget.token!.trim().isNotEmpty;

  Future<void> _confirmVerification() async {
    if (!_hasToken || _isSubmitting || _completed) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _message = null;
      _messageIsError = false;
    });

    try {
      await _accountRepository.confirmEmailVerification(
        token: widget.token!.trim(),
      );
      var refreshed = false;
      try {
        await _accountRepository.currentAccount();
        refreshed = true;
      } on AuthFailure {
        refreshed = false;
      } catch (_) {
        refreshed = false;
      }
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _completed = true;
        _message =
            refreshed
                ? 'Email verified. Your account status has been refreshed.'
                : 'Email verified. Please sign in again to refresh your account.';
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
        _message = 'Verification link is invalid or expired.';
        _messageIsError = true;
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
                          Center(
                            child: Container(
                              width: 64.r,
                              height: 64.r,
                              decoration: BoxDecoration(
                                color: CarenetColors.primary100,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Icon(
                                Icons.mark_email_read_outlined,
                                color: CarenetColors.brand,
                                size: 32.r,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          if (_hasToken) ...[
                            Text(
                              'Verify email',
                              style: textTheme.labelLarge?.copyWith(
                                color: CarenetColors.brand,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4.h),
                          ],
                          Text(
                            _hasToken
                                ? 'Confirm your email address'
                                : 'Verify your email',
                            style: textTheme.headlineSmall?.copyWith(
                              color: CarenetColors.neutral700,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            _hasToken
                                ? 'Confirm the secure link to verify your email and refresh your account status.'
                                : 'Open the verification link from your email to continue.',
                            style: textTheme.bodyLarge?.copyWith(
                              color: CarenetColors.neutral500,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 28.h),
                          if (!_hasToken) ...[
                            const _VerificationStatus(
                              message:
                                  'Verification link is missing or invalid. Request a new email verification link from your account.',
                              isError: true,
                            ),
                            SizedBox(height: 16.h),
                            CarenetButton(
                              label: 'Return to sign in',
                              type: CarenetButtonType.outline,
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  RouteName.signInEmail,
                                );
                              },
                            ),
                          ] else ...[
                            if (_message != null) ...[
                              _VerificationStatus(
                                message: _message!,
                                isError: _messageIsError,
                              ),
                              SizedBox(height: 16.h),
                            ],
                            if (_isSubmitting) ...[
                              Semantics(
                                label: 'Verifying email',
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
                                      ? 'Verifying email...'
                                      : 'Confirm verification',
                              onPressed:
                                  _isSubmitting || _completed
                                      ? null
                                      : _confirmVerification,
                            ),
                            if (_completed) ...[
                              SizedBox(height: 12.h),
                              CarenetButton(
                                label: 'Back to account',
                                type: CarenetButtonType.outline,
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    RouteName.account,
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
                ),
              ),
        ),
      ),
    );
  }
}

class _VerificationStatus extends StatelessWidget {
  const _VerificationStatus({required this.message, required this.isError});

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
