import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/account_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PasswordShellPage extends StatelessWidget {
  const PasswordShellPage({super.key});

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
          'Password',
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
            _PasswordSummary(passwordHint: snapshot.passwordHint),
            SizedBox(height: 16.h),
            const _LockedPasswordAction(),
          ],
        ),
      ),
    );
  }
}

class _PasswordSummary extends StatelessWidget {
  const _PasswordSummary({required this.passwordHint});

  final String passwordHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.password_outlined,
            color: AppColors.primaryBlue5,
            size: 28.r,
          ),
          SizedBox(height: 12.h),
          Text(
            'Password',
            style: TextStyle(
              fontSize: FontSizes.body3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your password helps to keep your account secure and makes it easy to log into your account',
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
              height: 1.5,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            passwordHint,
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedPasswordAction extends StatelessWidget {
  const _LockedPasswordAction();

  @override
  Widget build(BuildContext context) {
    const reason =
        'Password changes need backend re-authentication, current-password verification, session invalidation, and account recovery rules.';

    return Tooltip(
      message: reason,
      child: Container(
        width: double.infinity,
        padding: REdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.kWhite,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.white04),
        ),
        child: Row(
          children: [
            Icon(
              Icons.edit_outlined,
              color: AppColors.primaryBlue5,
              size: 22.r,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit password',
                    style: TextStyle(
                      fontSize: FontSizes.footer3,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w700,
                      color: AppColors.kBlack,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    reason,
                    style: TextStyle(
                      fontSize: FontSizes.footer4,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryBlue11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Icon(
              Icons.lock_outline,
              color: AppColors.primaryBlue11,
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }
}
