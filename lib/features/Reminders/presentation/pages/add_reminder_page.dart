import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Reminders/presentation/widgets/reminder_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddReminderPage extends StatelessWidget {
  const AddReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ReminderScaffold(
      title: 'Add Reminder',
      trailing: ReminderSaveButton(
        onTap: () => Navigator.of(context).pushNamed(RouteName.schedule),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 24.h),
        child: Column(
          children: [
            const ReminderFormCard(
              title: 'Reminder Type',
              value: 'Tap to select',
              height: 72,
            ),
            SizedBox(height: 10.h),
            const ReminderFormCard(
              title: 'Frequency',
              value: 'Once',
              height: 72,
            ),
            SizedBox(height: 10.h),
            const ReminderFormCard(
              title: 'Alert Time',
              value: '12:25 AM',
              linkText: 'Add another alert',
              height: 104,
            ),
            SizedBox(height: 10.h),
            const ReminderFormCard(
              title: 'Start Date',
              value: 'Feb 08 2025',
              height: 72,
            ),
            SizedBox(height: 10.h),
            const ReminderFormCard(
              title: 'End Date',
              value: 'Feb 08 2025',
              height: 72,
            ),
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              height: 472.h,
              child: const ReminderFormCard(
                title: 'Add Notes',
                value: '',
                expand: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
