import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Home extends StatelessWidget {
  const Home({
    super.key,
    required this.isProfessional,
    required this.onPrimaryAction,
    required this.onAppointments,
  });

  final bool isProfessional;
  final VoidCallback onPrimaryAction;
  final VoidCallback onAppointments;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListView(
        padding: REdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
        children: [
          Text(
            isProfessional ? 'Professional workspace' : 'Your care',
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontSize: FontSizes.heading3,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            isProfessional
                ? 'Manage your availability and appointment requests from one place.'
                : 'Find verified care and keep track of your appointments.',
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontSize: FontSizes.body3,
              height: 1.45,
              color: AppColors.primaryBlue11,
            ),
          ),
          SizedBox(height: 24.h),
          _HomeAction(
            icon:
                isProfessional
                    ? Icons.calendar_month_outlined
                    : Icons.search_outlined,
            title: isProfessional ? 'Manage schedule' : 'Find care',
            subtitle:
                isProfessional
                    ? 'Review and update backend availability.'
                    : 'Search verified professionals and view availability.',
            onTap: onPrimaryAction,
          ),
          SizedBox(height: 12.h),
          _HomeAction(
            icon: Icons.event_note_outlined,
            title: 'Appointments',
            subtitle:
                isProfessional
                    ? 'Review requests and manage accepted consultations.'
                    : 'Review requests, upcoming care, and appointment status.',
            onTap: onAppointments,
          ),
          SizedBox(height: 24.h),
          Container(
            padding: REdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.blue02,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.white04),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.chat_bubble_outline, color: AppColors.primaryBlue11),
                SizedBox(width: 12.w),
                const Expanded(
                  child: Text(
                    'Appointment conversations will appear in Messages when secure messaging is available for eligible consultations.',
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

class _HomeAction extends StatelessWidget {
  const _HomeAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.kWhite,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: REdgeInsets.all(16.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.white04),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue11, size: 28.r),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppFonts.montserrat,
                        fontSize: FontSizes.body3,
                        fontWeight: FontWeight.w700,
                        color: AppColors.kBlack,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: AppFonts.montserrat,
                        fontSize: FontSizes.footer2,
                        height: 1.35,
                        color: AppColors.primaryBlue11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
