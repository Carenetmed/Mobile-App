import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReminderDayCellData {
  const ReminderDayCellData(
    this.label, {
    this.selected = false,
    this.outlined = false,
    this.dimmed = false,
    this.saturday = false,
    this.sunday = false,
  });

  final String label;
  final bool selected;
  final bool outlined;
  final bool dimmed;
  final bool saturday;
  final bool sunday;
}

class ReminderScaffold extends StatelessWidget {
  const ReminderScaffold({
    required this.title,
    required this.body,
    this.trailing,
    super.key,
  });

  final String title;
  final Widget body;
  final Widget? trailing;

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
        toolbarHeight: 48.h,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: AppColors.white06,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: AppFonts.montserrat,
            fontSize: FontSizes.footer2,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryBlue6,
          ),
        ),
        actions: [
          if (trailing != null)
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Center(child: trailing),
            )
          else
            SizedBox(width: 44.w),
        ],
      ),
      body: SafeArea(top: false, child: body),
    );
  }
}

class ReminderOverflowButton extends StatelessWidget {
  const ReminderOverflowButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.apps_rounded, color: AppColors.white06, size: 22.sp);
  }
}

class ReminderSaveButton extends StatelessWidget {
  const ReminderSaveButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF007BFF),
          foregroundColor: AppColors.kWhite,
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        child: Text(
          'Save',
          style: TextStyle(
            fontFamily: AppFonts.montserrat,
            fontSize: FontSizes.footer1,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class ReminderCalendar extends StatelessWidget {
  const ReminderCalendar({
    required this.headerText,
    required this.rows,
    required this.weekBadges,
    this.headerColor = AppColors.primaryBlue3,
    this.headerTextColor = AppColors.kWhite,
    this.weekBadgeColor = AppColors.primaryBlue1,
    this.weekBadgeTextColor = AppColors.primaryBlue8,
    super.key,
  });

  final String headerText;
  final List<List<ReminderDayCellData>> rows;
  final List<String> weekBadges;
  final Color headerColor;
  final Color headerTextColor;
  final Color weekBadgeColor;
  final Color weekBadgeTextColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 24.h,
          decoration: BoxDecoration(
            color: headerColor,
            borderRadius: BorderRadius.circular(4.r),
          ),
          alignment: Alignment.center,
          child: Text(
            headerText,
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontSize: FontSizes.footer1,
              fontWeight: FontWeight.w400,
              color: headerTextColor,
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28.w,
              child: Column(
                children: [
                  SizedBox(height: 18.h),
                  for (final badge in weekBadges) ...[
                    _WeekBadge(
                      label: badge,
                      backgroundColor: weekBadgeColor,
                      textColor: weekBadgeTextColor,
                    ),
                    SizedBox(height: 8.h),
                  ],
                ],
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                children: [
                  const _WeekHeader(),
                  SizedBox(height: 8.h),
                  for (final row in rows) ...[
                    _CalendarRow(days: row),
                    SizedBox(height: 8.h),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ReminderEmptyStateCard extends StatelessWidget {
  const ReminderEmptyStateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 192.h),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.blue02),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Text(
        'You have no reminders. Add reminders now',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: AppFonts.montserrat,
          fontSize: FontSizes.footer1,
          fontWeight: FontWeight.w400,
          color: AppColors.white05,
        ),
      ),
    );
  }
}

class ReminderAddFab extends StatelessWidget {
  const ReminderAddFab({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 44.w,
        height: 44.w,
        child: Material(
          color: AppColors.primaryBlue6,
          borderRadius: BorderRadius.circular(10.r),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10.r),
            child: Icon(Icons.add, color: AppColors.kWhite, size: 24.sp),
          ),
        ),
      ),
    );
  }
}

class ReminderFormCard extends StatelessWidget {
  const ReminderFormCard({
    required this.title,
    required this.value,
    this.linkText,
    this.height,
    this.expand = false,
    super.key,
  });

  final String title;
  final String value;
  final String? linkText;
  final double? height;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: height ?? 0),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white01,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: AppColors.blue02),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontSize: FontSizes.footer2,
              fontWeight: FontWeight.w500,
              color: AppColors.white06,
            ),
          ),
          if (value.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: FontSizes.footer3,
                fontWeight: FontWeight.w400,
                color: AppColors.white05,
              ),
            ),
          ],
          if (linkText != null) ...[
            SizedBox(height: 8.h),
            Text(
              linkText!,
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: FontSizes.footer3,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryBlue6,
              ),
            ),
          ],
          if (expand) SizedBox(height: 240.h),
        ],
      ),
    );
  }
}

class ReminderTaskCard extends StatelessWidget {
  const ReminderTaskCard({required this.onAddReminder, super.key});

  final VoidCallback onAddReminder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          const _AlarmBadge(),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            color: AppColors.kWhite,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Doctors Without Border Event',
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      fontSize: FontSizes.footer2,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue6,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onAddReminder,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.white06,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(
                    Icons.add_circle_outline_rounded,
                    size: 18.sp,
                    color: AppColors.primaryBlue6,
                  ),
                  label: Text(
                    'Add reminder',
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white06,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _ActionPill(
                  label: 'Active',
                  backgroundColor: AppColors.kWhite,
                  textColor: AppColors.white06,
                  icon: Icons.radio_button_checked_rounded,
                  iconColor: AppColors.primaryBlue6,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _ActionPill(
                  label: 'Delete',
                  backgroundColor: AppColors.primaryRed6,
                  textColor: AppColors.kWhite,
                  icon: Icons.delete_outline_rounded,
                  iconColor: AppColors.kWhite,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _ActionPill(
                  label: 'Edit',
                  backgroundColor: AppColors.primaryBlue8,
                  textColor: AppColors.kWhite,
                  icon: Icons.edit_outlined,
                  iconColor: AppColors.kWhite,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _ActionPill(
                  label: 'Share',
                  backgroundColor: const Color(0xFF34C759),
                  textColor: AppColors.kWhite,
                  icon: Icons.ios_share_rounded,
                  iconColor: AppColors.kWhite,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _TaskInfoCard(
                    title: 'Frequency',
                    lines: const ['Once', 'Daily'],
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _TaskInfoCard(
                    title: 'Starts in',
                    lines: const ['05:40:59', 'Today, 11:59 PM'],
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _TaskInfoCard(
                    title: 'Ends in',
                    lines: const [
                      '05:40:59',
                      'Wednesday,',
                      'February 12,',
                      '2025 11:59 PM',
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.kWhite,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: AppColors.primaryBlue1),
            ),
            child: Text(
              'Notes',
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: FontSizes.footer2,
                fontWeight: FontWeight.w400,
                color: AppColors.white04,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekBadge extends StatelessWidget {
  const _WeekBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.montserrat,
          fontSize: FontSizes.footer2,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader();

  @override
  Widget build(BuildContext context) {
    const labels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return Row(
      children: [
        for (final label in labels)
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: FontSizes.footer2,
                fontWeight: FontWeight.w400,
                color:
                    label == 'Sa'
                        ? AppColors.primaryBlue6
                        : label == 'Su'
                        ? AppColors.primaryRed6
                        : AppColors.white04,
              ),
            ),
          ),
      ],
    );
  }
}

class _CalendarRow extends StatelessWidget {
  const _CalendarRow({required this.days});

  final List<ReminderDayCellData> days;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: days
          .map((day) => Expanded(child: Center(child: _CalendarCell(day: day))))
          .toList(growable: false),
    );
  }
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({required this.day});

  final ReminderDayCellData day;

  @override
  Widget build(BuildContext context) {
    final bool filled = day.selected;
    final Color textColor =
        filled
            ? AppColors.kWhite
            : day.sunday
            ? AppColors.primaryRed6
            : day.saturday
            ? AppColors.primaryBlue6
            : day.dimmed
            ? AppColors.white02
            : AppColors.white05;

    return Container(
      width: 24.w,
      height: 28.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? AppColors.primaryBlue6 : Colors.transparent,
        borderRadius: BorderRadius.circular(4.r),
        border: day.outlined ? Border.all(color: AppColors.primaryBlue6) : null,
      ),
      child: Text(
        day.label,
        style: TextStyle(
          fontFamily: AppFonts.montserrat,
          fontSize: FontSizes.footer2,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
      ),
    );
  }
}

class _AlarmBadge extends StatelessWidget {
  const _AlarmBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88.w,
      height: 88.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: const BoxDecoration(
              color: Color(0xFF464BD8),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            right: 10.w,
            bottom: 18.h,
            child: Container(
              width: 42.w,
              height: 42.w,
              decoration: const BoxDecoration(
                color: Color(0xFF514DDF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: 36.w,
            height: 36.w,
            decoration: const BoxDecoration(
              color: Color(0xFF2AEFC8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.alarm_rounded,
              size: 22.sp,
              color: AppColors.primaryBlue8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: 8.sp,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Icon(icon, size: 16.sp, color: iconColor),
        ],
      ),
    );
  }
}

class _TaskInfoCard extends StatelessWidget {
  const _TaskInfoCard({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: AppColors.primaryBlue1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontSize: FontSizes.footer1,
              fontWeight: FontWeight.w500,
              color: AppColors.white06,
            ),
          ),
          SizedBox(height: 10.h),
          for (final line in lines) ...[
            Text(
              line,
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: FontSizes.footer3,
                fontWeight: FontWeight.w400,
                color: AppColors.white05,
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ],
      ),
    );
  }
}
