import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/theme/textStyle.dart';
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
    if (!_hasToken) {
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
    final canSubmit = _hasToken && !_isSubmitting && !_completed;

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          'Verify email',
          style: TextStyle(
            fontSize: FontSizes.footer2,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue5,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: REdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
          children: [
            Text(
              _hasToken
                  ? 'Confirm your email address'
                  : 'Open the verification link from your email to continue',
              style: TextStyle(
                fontSize: FontSizes.heading3,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w700,
                color: AppColors.kBlack,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'The verification token is used only for this request and is not stored by the app.',
              style: TextStyle(
                fontSize: FontSizes.footer2,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryBlue11,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
            if (!_hasToken) ...[
              _StatusText(
                message:
                    'Verification link is missing or invalid. Request a new email verification link from your account.',
                isError: true,
              ),
              SizedBox(height: 12.h),
              CarenetButton(
                label: 'Back to account email',
                type: CarenetButtonType.outline,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, RouteName.editEmail);
                },
              ),
            ] else ...[
              if (_message != null) ...[
                _StatusText(message: _message!, isError: _messageIsError),
                SizedBox(height: 16.h),
              ],
              CarenetButton(
                label:
                    _isSubmitting
                        ? 'Verifying email...'
                        : 'Confirm verification',
                onPressed: canSubmit ? _confirmVerification : null,
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
