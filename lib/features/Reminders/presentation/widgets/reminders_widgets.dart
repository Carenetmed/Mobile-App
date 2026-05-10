import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Reminders/presentation/model/reminder_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RemindersPageScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? floatingAction;

  const RemindersPageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.floatingAction,
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
      floatingActionButton: floatingAction,
    );
  }
}

class ReminderOverviewCard extends StatelessWidget {
  final String title;
  final String description;

  const ReminderOverviewCard({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.primaryBlue1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: AppColors.kWhite,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              color: AppColors.primaryBlue6,
              size: 22.sp,
            ),
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
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class ReminderFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ReminderFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Ink(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue6 : AppColors.kWhite,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: selected ? AppColors.primaryBlue6 : AppColors.white02,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: FontSizes.footer1,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.montserrat,
            color: selected ? AppColors.kWhite : AppColors.white05,
          ),
        ),
      ),
    );
  }
}

class ReminderListCard extends StatelessWidget {
  final ReminderItem reminder;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;

  const ReminderListCard({
    super.key,
    required this.reminder,
    required this.onToggle,
    required this.onTap,
  });

  Color _categoryColor(ReminderCategory category) {
    switch (category) {
      case ReminderCategory.medication:
        return AppColors.primaryBlue6;
      case ReminderCategory.appointment:
        return AppColors.kGreen;
      case ReminderCategory.wellness:
        return AppColors.kBlue;
      case ReminderCategory.followUp:
        return AppColors.kPink;
    }
  }

  IconData _categoryIcon(ReminderCategory category) {
    switch (category) {
      case ReminderCategory.medication:
        return Icons.medication_outlined;
      case ReminderCategory.appointment:
        return Icons.calendar_today_outlined;
      case ReminderCategory.wellness:
        return Icons.favorite_border_rounded;
      case ReminderCategory.followUp:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _categoryColor(reminder.category);

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      _categoryIcon(reminder.category),
                      color: accent,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title,
                          style: TextStyle(
                            fontSize: FontSizes.body3,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppFonts.montserrat,
                            color: AppColors.white06,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          reminderCategoryLabel(reminder.category),
                          style: TextStyle(
                            fontSize: FontSizes.footer3,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.montserrat,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: reminder.enabled,
                    activeTrackColor: AppColors.primaryBlue6,
                    activeThumbColor: AppColors.kWhite,
                    onChanged: onToggle,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                reminder.subtitle,
                style: TextStyle(
                  fontSize: FontSizes.footer1,
                  fontWeight: FontWeight.w400,
                  fontFamily: AppFonts.montserrat,
                  color: AppColors.white05,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _ReminderPill(
                    icon: Icons.schedule_rounded,
                    label: reminder.scheduleLabel,
                  ),
                  _ReminderPill(
                    icon:
                        reminder.repeats
                            ? Icons.repeat_rounded
                            : Icons.event_available_rounded,
                    label: reminder.repeats ? 'Repeats' : 'One-time',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ReminderPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: AppColors.primaryBlue6),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontWeight: FontWeight.w500,
              fontFamily: AppFonts.montserrat,
              color: AppColors.white06,
            ),
          ),
        ],
      ),
    );
  }
}
