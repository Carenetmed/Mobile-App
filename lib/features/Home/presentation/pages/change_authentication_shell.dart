import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChangeAuthenticationShellPage extends StatelessWidget {
  const ChangeAuthenticationShellPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Two-step verification',
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
            const _VerificationSummary(),
            SizedBox(height: 16.h),
            CarenetButton(
              label: 'Review turn-on setup',
              onPressed: () {
                Navigator.pushNamed(context, RouteName.turnOnAuthentication);
              },
            ),
            SizedBox(height: 16.h),
            const _LockedSecurityAction(
              icon: Icons.pin_outlined,
              title: 'Change PIN',
              reason:
                  'PIN changes need backend re-authentication, session checks, and secure storage.',
            ),
            const _LockedSecurityAction(
              icon: Icons.lock_open_outlined,
              title: 'Turn off',
              reason:
                  'Turning off two-step verification needs backend identity verification and audit rules.',
              isDestructive: true,
            ),
            const _LockedSecurityAction(
              icon: Icons.info_outline,
              title: 'Learn more',
              reason:
                  'Security help copy needs product-approved account safety guidance.',
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationSummary extends StatelessWidget {
  const _VerificationSummary();

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
            Icons.verified_user_outlined,
            color: AppColors.primaryBlue5,
            size: 28.r,
          ),
          SizedBox(height: 12.h),
          Text(
            'Two-step verification',
            style: TextStyle(
              fontSize: FontSizes.body3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Two-step verification helps you to keep your account safe from unauthorized access. You will need to create a PIN and enter it again anytime you are switching device.',
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
              height: 1.5,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: REdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.kWhite,
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              'Protected locally',
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
    );
  }
}

class _LockedSecurityAction extends StatelessWidget {
  const _LockedSecurityAction({
    required this.icon,
    required this.title,
    required this.reason,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String reason;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final iconColor = isDestructive ? Colors.red : AppColors.primaryBlue5;

    return Tooltip(
      message: reason,
      child: Container(
        width: double.infinity,
        margin: REdgeInsets.only(bottom: 10.h),
        padding: REdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.kWhite,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.white04),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: FontSizes.footer3,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w700,
                      color: isDestructive ? Colors.red : AppColors.kBlack,
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
