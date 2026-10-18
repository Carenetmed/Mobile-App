import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Authentication/data/repositories/account_repository.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_user.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditEmailShellPage extends StatefulWidget {
  const EditEmailShellPage({super.key, this.accountRepository});

  final AccountRepository? accountRepository;

  @override
  State<EditEmailShellPage> createState() => _EditEmailShellPageState();
}

class _EditEmailShellPageState extends State<EditEmailShellPage> {
  AuthUser? _account;
  bool _isLoadingAccount = true;
  bool _accountLoadInFlight = false;
  bool _isRequestingVerification = false;
  String? _accountError;
  String? _verificationMessage;
  bool _verificationMessageIsError = false;

  AccountRepository get _accountRepository =>
      widget.accountRepository ?? sl<AccountRepository>();

  @override
  void initState() {
    super.initState();
    _loadCurrentAccount();
  }

  Future<void> _loadCurrentAccount() async {
    if (_accountLoadInFlight) return;
    _accountLoadInFlight = true;
    if (mounted) {
      setState(() {
        _isLoadingAccount = true;
        _accountError = null;
      });
    }

    try {
      final account = await _accountRepository.currentAccount();
      if (!mounted) return;
      setState(() {
        _account = account;
        _accountError = null;
        _isLoadingAccount = false;
      });
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _accountError = failure.message;
        _isLoadingAccount = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _accountError = 'Could not load your account details.';
        _isLoadingAccount = false;
      });
    } finally {
      _accountLoadInFlight = false;
    }
  }

  Future<void> _requestVerification() async {
    final account = _account;
    if (_isRequestingVerification || account == null || account.emailVerified) {
      return;
    }

    setState(() {
      _isRequestingVerification = true;
      _verificationMessage = null;
      _verificationMessageIsError = false;
    });

    try {
      await _accountRepository.requestEmailVerification();
      if (!mounted) return;
      setState(() {
        _isRequestingVerification = false;
        _verificationMessage =
            'The verification request was accepted. Check ${account.email} and its spam folder.';
        _verificationMessageIsError = false;
      });
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _isRequestingVerification = false;
        _verificationMessage = failure.message;
        _verificationMessageIsError = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isRequestingVerification = false;
        _verificationMessage = 'Could not request a verification link.';
        _verificationMessageIsError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = _account;

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          'Email address',
          style: TextStyle(
            fontSize: FontSizes.footer2,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue5,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh email status',
            onPressed: _isLoadingAccount ? null : _loadCurrentAccount,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: REdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
          children: [
            if (account != null)
              _EmailSummaryCard(
                email: account.email,
                verified: account.emailVerified,
              )
            else
              _AccountLoadState(
                isLoading: _isLoadingAccount,
                error: _accountError,
                onRetry: _isLoadingAccount ? null : _loadCurrentAccount,
              ),
            if (account != null && _accountError != null) ...[
              SizedBox(height: 12.h),
              _InlineAccountError(
                message: _accountError!,
                onRetry: _isLoadingAccount ? null : _loadCurrentAccount,
              ),
            ],
            if (account != null && !account.emailVerified) ...[
              SizedBox(height: 16.h),
              Text(
                'Verify this address to secure your account. We will request a link for the email shown above.',
                style: TextStyle(
                  fontSize: FontSizes.footer3,
                  fontFamily: AppFonts.montserrat,
                  color: AppColors.primaryBlue11,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 16.h),
              CarenetButton(
                label: _isRequestingVerification
                    ? 'Requesting link...'
                    : 'Send verification email',
                onPressed: _isRequestingVerification
                    ? null
                    : _requestVerification,
              ),
            ],
            if (account != null && account.emailVerified) ...[
              SizedBox(height: 16.h),
              Text(
                'This email address is verified.',
                style: TextStyle(
                  fontSize: FontSizes.footer3,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue5,
                ),
              ),
            ],
            if (_verificationMessage != null) ...[
              SizedBox(height: 10.h),
              Semantics(
                liveRegion: true,
                child: Text(
                  _verificationMessage!,
                  style: TextStyle(
                    fontSize: FontSizes.footer4,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w500,
                    color: _verificationMessageIsError
                        ? Colors.redAccent
                        : AppColors.primaryBlue5,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmailSummaryCard extends StatelessWidget {
  const _EmailSummaryCard({required this.email, required this.verified});

  final String email;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email',
            style: TextStyle(
              fontSize: FontSizes.body3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Email helps you access your account. Your email address is not visible to others unless you add it to your profile.',
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
              height: 1.5,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  email,
                  style: TextStyle(
                    fontSize: FontSizes.footer3,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue5,
                  ),
                ),
              ),
              Container(
                padding: REdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.kWhite,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.white04),
                ),
                child: Text(
                  verified ? 'Verified' : 'Not verified',
                  style: TextStyle(
                    fontSize: FontSizes.footer4,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w600,
                    color: verified ? AppColors.primaryBlue5 : Colors.deepOrange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountLoadState extends StatelessWidget {
  const _AccountLoadState({
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          error ?? 'Could not load your account details.',
          style: TextStyle(
            fontSize: FontSizes.footer3,
            fontFamily: AppFonts.montserrat,
            color: Colors.redAccent,
          ),
        ),
        SizedBox(height: 12.h),
        CarenetButton(label: 'Retry', onPressed: onRetry),
      ],
    );
  }
}

class _InlineAccountError extends StatelessWidget {
  const _InlineAccountError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              color: Colors.redAccent,
            ),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
