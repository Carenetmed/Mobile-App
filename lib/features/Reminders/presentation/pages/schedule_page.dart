import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Reminders/presentation/widgets/reminder_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  static const List<String> _weekBadges = ['5', '6', '7', '8', '9', '10'];

  static const List<List<ReminderDayCellData>> _rows = [
    [
      ReminderDayCellData('27'),
      ReminderDayCellData('28'),
      ReminderDayCellData('29'),
      ReminderDayCellData('30'),
      ReminderDayCellData('31'),
      ReminderDayCellData('1', saturday: true),
      ReminderDayCellData('2', sunday: true),
    ],
    [
      ReminderDayCellData('3'),
      ReminderDayCellData('4'),
      ReminderDayCellData('5'),
      ReminderDayCellData('6'),
      ReminderDayCellData('7', selected: true, saturday: true),
      ReminderDayCellData('8', saturday: true),
      ReminderDayCellData('9', sunday: true),
    ],
    [
      ReminderDayCellData('10'),
      ReminderDayCellData('11'),
      ReminderDayCellData('12', outlined: true),
      ReminderDayCellData('13'),
      ReminderDayCellData('14'),
      ReminderDayCellData('15', saturday: true),
      ReminderDayCellData('16', sunday: true),
    ],
    [
      ReminderDayCellData('17'),
      ReminderDayCellData('18'),
      ReminderDayCellData('19'),
      ReminderDayCellData('20'),
      ReminderDayCellData('21'),
      ReminderDayCellData('22', saturday: true),
      ReminderDayCellData('23', sunday: true),
    ],
    [
      ReminderDayCellData('24'),
      ReminderDayCellData('25'),
      ReminderDayCellData('26'),
      ReminderDayCellData('27'),
      ReminderDayCellData('28'),
      ReminderDayCellData('1', saturday: true),
      ReminderDayCellData('2', sunday: true),
    ],
    [
      ReminderDayCellData('3'),
      ReminderDayCellData('4'),
      ReminderDayCellData('5'),
      ReminderDayCellData('6'),
      ReminderDayCellData('7'),
      ReminderDayCellData('8', saturday: true),
      ReminderDayCellData('9', sunday: true),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return ReminderScaffold(
      title: 'Task Reminder',
      trailing: const ReminderOverflowButton(),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
        child: Column(
          children: [
            ReminderCalendar(
              headerText: 'February',
              rows: _rows,
              weekBadges: _weekBadges,
              headerColor: AppColors.primaryBlue8,
              weekBadgeColor: AppColors.primaryBlue8,
              weekBadgeTextColor: AppColors.kWhite,
            ),
            SizedBox(height: 16.h),
            ReminderTaskCard(
              onAddReminder:
                  () => Navigator.of(context).pushNamed(RouteName.addReminder),
            ),
          ],
        ),
      ),
    );
  }
}
