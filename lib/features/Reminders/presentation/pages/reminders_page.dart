import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Reminders/presentation/model/reminder_item.dart';
import 'package:app_t/features/Reminders/presentation/widgets/reminders_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  ReminderCategory? _selectedCategory;
  late List<ReminderItem> _reminders;

  @override
  void initState() {
    super.initState();
    _reminders = List<ReminderItem>.from(sampleReminders);
  }

  Future<void> _openReminderEditor([ReminderItem? reminder]) async {
    final result = await Navigator.of(context).pushNamed(
      RouteName.reminderEditor,
      arguments: ReminderEditorArgs(reminder: reminder),
    );

    if (result is! ReminderItem) return;

    setState(() {
      final index = _reminders.indexWhere((item) => item.id == result.id);
      if (index == -1) {
        _reminders = [result, ..._reminders];
      } else {
        _reminders[index] = result;
      }
    });
  }

  void _toggleReminder(ReminderItem reminder, bool value) {
    setState(() {
      _reminders =
          _reminders
              .map(
                (item) =>
                    item.id == reminder.id
                        ? item.copyWith(enabled: value)
                        : item,
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleReminders =
        _selectedCategory == null
            ? _reminders
            : _reminders
                .where((reminder) => reminder.category == _selectedCategory)
                .toList();

    return RemindersPageScaffold(
      title: 'Reminders',
      floatingAction: FloatingActionButton.extended(
        onPressed: _openReminderEditor,
        label: const Text('Create reminder'),
        icon: const Icon(Icons.add_alert_outlined),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ReminderOverviewCard(
            title: 'Stay on top of your care plan',
            description:
                'Manage medication alerts, follow-up prompts, and personal wellness reminders in one place.',
          ),
          SizedBox(height: 18.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ReminderFilterChip(
                  label: 'All',
                  selected: _selectedCategory == null,
                  onTap: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                ),
                SizedBox(width: 8.w),
                ...ReminderCategory.values.indexed.expand((entry) {
                  final index = entry.$1;
                  final category = entry.$2;

                  return [
                    ReminderFilterChip(
                      label: reminderCategoryLabel(category),
                      selected: _selectedCategory == category,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                    if (index != ReminderCategory.values.length - 1)
                      SizedBox(width: 8.w),
                  ];
                }),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          if (visibleReminders.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: Colors.black12),
              ),
              child: const Text(
                'No reminders match this filter yet. Create one to keep the section active.',
              ),
            )
          else
            ...visibleReminders.indexed.expand((entry) {
              final index = entry.$1;
              final reminder = entry.$2;

              return [
                ReminderListCard(
                  reminder: reminder,
                  onToggle: (value) => _toggleReminder(reminder, value),
                  onTap: () => _openReminderEditor(reminder),
                ),
                if (index != visibleReminders.length - 1)
                  SizedBox(height: 12.h),
              ];
            }),
        ],
      ),
    );
  }
}
