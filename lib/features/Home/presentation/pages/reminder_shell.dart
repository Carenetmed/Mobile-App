import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReminderShellPage extends StatefulWidget {
  const ReminderShellPage({super.key});

  @override
  State<ReminderShellPage> createState() => _ReminderShellPageState();
}

class _ReminderShellPageState extends State<ReminderShellPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  String get _selectedDateLabel {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const weekdays = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${weekdays[_selectedDate.weekday - 1]}, '
        '${months[_selectedDate.month - 1]} ${_selectedDate.day}, '
        '${_selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1);
    final lastDate = DateTime(now.year + 2, 12, 31);

    return Scaffold(
      backgroundColor: CarenetColors.white,
      appBar: AppBar(
        backgroundColor: CarenetColors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: CarenetColors.black),
        ),
        centerTitle: true,
        title: Text(
          'Reminder',
          style: TextStyle(
            fontFamily: AppFonts.montserrat,
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: CarenetColors.brand,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
          children: [
            Text(
              _selectedDateLabel,
              key: const Key('reminder-selected-date'),
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: CarenetColors.neutral700,
              ),
            ),
            SizedBox(height: 12.h),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: CarenetColors.neutral200),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: firstDate,
                lastDate: lastDate,
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ),
            SizedBox(height: 28.h),
            Icon(
              Icons.notifications_none_outlined,
              size: 44.r,
              color: CarenetColors.neutral400,
            ),
            SizedBox(height: 12.h),
            Text(
              'You have no reminders for this date.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: CarenetColors.neutral700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Adding reminders will be enabled when reminder persistence and notification delivery are connected.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                height: 1.45,
                color: CarenetColors.neutral500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
