import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsPageScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const SettingsPageScaffold({
    required this.title,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        foregroundColor: AppColors.white06,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: FontSizes.body3,
            fontWeight: FontWeight.w700,
            fontFamily: AppFonts.montserrat,
            color: AppColors.white06,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          child: child,
        ),
      ),
    );
  }
}

class SettingsSectionTitle extends StatelessWidget {
  final String title;

  const SettingsSectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: FontSizes.footer1,
        fontWeight: FontWeight.w700,
        fontFamily: AppFonts.montserrat,
        color: AppColors.white05,
      ),
    );
  }
}

class SettingsInfoCard extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
  final String title;
  final String description;
  final Widget? footer;

  const SettingsInfoCard({
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    required this.title,
    required this.description,
    this.footer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: accentColor.withValues(alpha: .18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: accentColor, size: 22.sp),
          ),
          SizedBox(height: 14.h),
          Text(
            title,
            style: TextStyle(
              fontSize: FontSizes.body3,
              fontWeight: FontWeight.w700,
              fontFamily: AppFonts.montserrat,
              color: AppColors.white06,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            description,
            style: TextStyle(
              fontSize: FontSizes.footer1,
              fontWeight: FontWeight.w400,
              fontFamily: AppFonts.montserrat,
              color: AppColors.white05,
              height: 1.5,
            ),
          ),
          if (footer != null) ...[SizedBox(height: 12.h), footer!],
        ],
      ),
    );
  }
}

class SettingsNavigationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool destructive;

  const SettingsNavigationTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.destructive = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor =
        destructive ? AppColors.primaryRed6 : AppColors.primaryBlue6;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Ink(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.kWhite,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.white02),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, color: accentColor, size: 22.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: FontSizes.body3,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.montserrat,
                        color:
                            destructive
                                ? AppColors.primaryRed8
                                : AppColors.white06,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: FontSizes.footer1,
                        fontWeight: FontWeight.w400,
                        fontFamily: AppFonts.montserrat,
                        color: AppColors.white05,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.white04,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
