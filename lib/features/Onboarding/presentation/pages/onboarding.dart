import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: REdgeInsets.fromLTRB(22, 18, 22, 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 1.sh - 100.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TrustMark(),
                SizedBox(height: 28.h),
                const _CareIllustration(),
                SizedBox(height: 22.h),
                Text(
                  'Find verified care with confidence',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontSize: 29.sp,
                    height: 1.12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF102A2A),
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'Browse trusted professionals, create an account when you are ready, and complete only the setup your care path needs.',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontSize: 14.sp,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                    color: CarenetColors.neutral500,
                  ),
                ),
                SizedBox(height: 16.h),
                const _AssuranceStrip(),
                SizedBox(height: 18.h),
                CarenetButton(
                  label: 'Browse verified care',
                  onPressed:
                      () => Navigator.pushNamed(context, RouteName.search),
                ),
                SizedBox(height: 8.h),
                CarenetButton(
                  label: 'Create account',
                  type: CarenetButtonType.outline,
                  onPressed:
                      () => Navigator.pushNamed(context, RouteName.signUpRole),
                ),
                SizedBox(height: 6.h),
                Center(
                  child: TextButton(
                    onPressed:
                        () =>
                            Navigator.pushNamed(context, RouteName.signInEmail),
                    child: Text(
                      'Already have an account? Sign in',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.montserrat,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF155E63),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustMark extends StatelessWidget {
  const _TrustMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: const Color(0xFF155E63),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.health_and_safety_outlined,
            color: Colors.white,
            size: 21.sp,
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          'CareNet',
          style: TextStyle(
            fontFamily: AppFonts.montserrat,
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF102A2A),
          ),
        ),
      ],
    );
  }
}

class _CareIllustration extends StatelessWidget {
  const _CareIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFD9E9E6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF155E63).withValues(alpha: 0.08),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _ClinicianAvatar(),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Line(width: 124.w, color: const Color(0xFF155E63)),
                    SizedBox(height: 8.h),
                    _Line(width: 168.w, color: const Color(0xFFD7E4E2)),
                  ],
                ),
              ),
              const _VerifiedBadge(),
            ],
          ),
          SizedBox(height: 18.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: const [
              _Pill(label: 'Verified professionals'),
              _Pill(label: 'Appointments'),
              _Pill(label: 'Private setup'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClinicianAvatar extends StatelessWidget {
  const _ClinicianAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54.w,
      height: 54.w,
      decoration: BoxDecoration(
        color: const Color(0xFFE5F4F1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        Icons.medical_services_outlined,
        color: const Color(0xFF155E63),
        size: 27.sp,
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34.w,
      height: 34.w,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EF),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        Icons.verified_outlined,
        color: const Color(0xFF18794E),
        size: 20.sp,
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.width, required this.color});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 8.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAF8),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.montserrat,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF155E63),
        ),
      ),
    );
  }
}

class _AssuranceStrip extends StatelessWidget {
  const _AssuranceStrip();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _AssuranceRow(
          icon: Icons.search_outlined,
          title: 'Browse before signing up',
          subtitle: 'Public verified-care surfaces stay open for discovery.',
        ),
        _AssuranceRow(
          icon: Icons.badge_outlined,
          title: 'Professionals apply for review',
          subtitle:
              'Credentials and documents are handled as a serious application.',
        ),
      ],
    );
  }
}

class _AssuranceRow extends StatelessWidget {
  const _AssuranceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF155E63), size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF102A2A),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontSize: 12.sp,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: CarenetColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
