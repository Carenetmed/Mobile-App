import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Authentication/data/repositories/account_repository.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/presentation/state/account_local_store.dart';
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
  bool _isRequestingVerification = false;
  String? _verificationMessage;
  bool _verificationMessageIsError = false;

  AccountRepository get _accountRepository =>
      widget.accountRepository ?? sl<AccountRepository>();

  Future<void> _requestVerification() async {
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
            'Verification email requested. Confirming it still needs the secure token from the email link.';
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
        _verificationMessage = 'Could not request verification email.';
        _verificationMessageIsError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = AccountLocalStore.snapshot.value;

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
          'Email address',
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
            _EmailSummaryCard(email: snapshot.email),
            SizedBox(height: 16.h),
            CarenetButton(
              label:
                  _isRequestingVerification
                      ? 'Sending verification...'
                      : 'Send verification email',
              onPressed:
                  _isRequestingVerification ? null : _requestVerification,
            ),
            if (_verificationMessage != null) ...[
              SizedBox(height: 10.h),
              Text(
                _verificationMessage!,
                style: TextStyle(
                  fontSize: FontSizes.footer4,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w500,
                  color:
                      _verificationMessageIsError
                          ? Colors.redAccent
                          : AppColors.primaryBlue5,
                  height: 1.4,
                ),
              ),
            ],
            SizedBox(height: 16.h),
            CarenetButton(
              label: 'Edit email',
              onPressed: () {
                Navigator.pushNamed(context, RouteName.changeEmail);
              },
            ),
            SizedBox(height: 10.h),
            CarenetButton(
              label: 'Remove email',
              type: CarenetButtonType.outline,
              onPressed: null,
            ),
            SizedBox(height: 10.h),
            CarenetButton(
              label: 'Review password step',
              type: CarenetButtonType.outline,
              onPressed: () {
                Navigator.pushNamed(context, RouteName.enterPasswordToSave);
              },
            ),
            SizedBox(height: 16.h),
            const _LockedNotice(),
          ],
        ),
      ),
    );
  }
}

class _EmailSummaryCard extends StatelessWidget {
  const _EmailSummaryCard({required this.email});

  final String email;

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
                  'Verified',
                  style: TextStyle(
                    fontSize: FontSizes.footer4,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue5,
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

class _LockedNotice extends StatelessWidget {
  const _LockedNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, color: AppColors.primaryBlue5, size: 20.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Removing an email needs re-authentication, recovery rules, and account persistence, so removal stays locked until the auth backend exists.',
              style: TextStyle(
                fontSize: FontSizes.footer4,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryBlue11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
