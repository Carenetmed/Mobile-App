import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Reminders/presentation/widgets/reminder_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

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
      ReminderDayCellData('3', dimmed: true),
      ReminderDayCellData('4', dimmed: true),
      ReminderDayCellData('5', dimmed: true),
      ReminderDayCellData('6', dimmed: true),
      ReminderDayCellData('7', selected: true, saturday: true),
      ReminderDayCellData('8', saturday: true),
      ReminderDayCellData('9', sunday: true),
    ],
    [
      ReminderDayCellData('10', dimmed: true),
      ReminderDayCellData('11', dimmed: true),
      ReminderDayCellData('12', dimmed: true),
      ReminderDayCellData('13', dimmed: true),
      ReminderDayCellData('14', dimmed: true),
      ReminderDayCellData('15', saturday: true),
      ReminderDayCellData('16', sunday: true),
    ],
    [
      ReminderDayCellData('17', dimmed: true),
      ReminderDayCellData('18', dimmed: true),
      ReminderDayCellData('19', dimmed: true),
      ReminderDayCellData('20', dimmed: true),
      ReminderDayCellData('21', dimmed: true),
      ReminderDayCellData('22', saturday: true),
      ReminderDayCellData('23', sunday: true),
    ],
    [
      ReminderDayCellData('24', dimmed: true),
      ReminderDayCellData('25', dimmed: true),
      ReminderDayCellData('26', dimmed: true),
      ReminderDayCellData('27', dimmed: true),
      ReminderDayCellData('28', dimmed: true),
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
      title: 'Reminder',
      trailing: const ReminderOverflowButton(),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
        child: Column(
          children: [
            ReminderCalendar(
              headerText: 'Friday, February, 07, 2025',
              rows: _rows,
              weekBadges: _weekBadges,
            ),
            SizedBox(height: 18.h),
            const ReminderEmptyStateCard(),
            SizedBox(height: 28.h),
            ReminderAddFab(
              onTap:
                  () => Navigator.of(context).pushNamed(RouteName.addReminder),
            ),
          ],
        ),
      ),
    );
  }
}
