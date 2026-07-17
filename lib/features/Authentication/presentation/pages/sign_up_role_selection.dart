import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_arguments.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUpRoleSelectionPage extends StatelessWidget {
  const SignUpRoleSelectionPage({super.key, this.initialEmail});

  final String? initialEmail;

  void _continueAs(BuildContext context, SignUpRole role) {
    Navigator.pushNamed(
      context,
      RouteName.finishSignUp,
      arguments: FinishSignUpArgs(initialEmail: initialEmail, role: role),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: REdgeInsets.symmetric(horizontal: 18.w, vertical: 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_ios),
              ),
              SizedBox(height: 24.h),
              Text(
                'Choose account type',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'CareNet uses different onboarding for patients and medical professionals.',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 32.h),
              _RoleCard(
                title: 'I need medical guidance',
                subtitle:
                    'Create a patient account for consultations, content, and health support.',
                onTap: () => _continueAs(context, SignUpRole.patient),
              ),
              SizedBox(height: 14.h),
              _RoleCard(
                title: 'I am a medical professional',
                subtitle:
                    'Create a professional account for profile setup and credential verification.',
                onTap: () => _continueAs(context, SignUpRole.professional),
              ),
              const Spacer(),
              CarenetButton(
                label: 'Already have an account? Sign in',
                type: CarenetButtonType.outline,
                onPressed:
                    () => Navigator.pushNamed(context, RouteName.signInEmail),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: REdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryBlue5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.account_circle_outlined, color: AppColors.primaryBlue5),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.kBlack,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.kBlack,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right, color: AppColors.primaryBlue5),
          ],
        ),
      ),
    );
  }
}
