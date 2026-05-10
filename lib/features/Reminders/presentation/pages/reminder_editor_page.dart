import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Reminders/presentation/model/reminder_item.dart';
import 'package:app_t/features/Reminders/presentation/widgets/reminders_widgets.dart';
import 'package:app_t/features/Settings/presentation/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReminderEditorPage extends StatefulWidget {
  final ReminderItem? reminder;

  const ReminderEditorPage({super.key, this.reminder});

  @override
  State<ReminderEditorPage> createState() => _ReminderEditorPageState();
}

class _ReminderEditorPageState extends State<ReminderEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;
  late final TextEditingController _scheduleController;
  late ReminderCategory _selectedCategory;
  late bool _enabled;
  late bool _repeats;

  bool get _isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    final reminder = widget.reminder;
    _titleController = TextEditingController(text: reminder?.title ?? '');
    _detailsController = TextEditingController(text: reminder?.subtitle ?? '');
    _scheduleController = TextEditingController(
      text: reminder?.scheduleLabel ?? 'Tomorrow, 9:00 AM',
    );
    _selectedCategory = reminder?.category ?? ReminderCategory.medication;
    _enabled = reminder?.enabled ?? true;
    _repeats = reminder?.repeats ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  void _saveReminder() {
    final title = _titleController.text.trim();
    final subtitle = _detailsController.text.trim();
    final schedule = _scheduleController.text.trim();

    if (title.isEmpty || subtitle.isEmpty || schedule.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all reminder details.')),
      );
      return;
    }

    final result = ReminderItem(
      id:
          widget.reminder?.id ??
          '${_selectedCategory.name}-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      subtitle: subtitle,
      scheduleLabel: schedule,
      category: _selectedCategory,
      enabled: _enabled,
      repeats: _repeats,
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return RemindersPageScaffold(
      title: _isEditing ? 'Edit Reminder' : 'Create Reminder',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reminder setup',
            style: TextStyle(
              fontSize: FontSizes.footer1,
              fontWeight: FontWeight.w700,
              fontFamily: AppFonts.montserrat,
              color: AppColors.white05,
            ),
          ),
          SizedBox(height: 12.h),
          SettingsTextField(
            label: 'Reminder title',
            hintText: 'Enter a short title',
            controller: _titleController,
          ),
          SizedBox(height: 14.h),
          SettingsTextField(
            label: 'Details',
            hintText: 'Explain what should happen when the reminder shows',
            controller: _detailsController,
            maxLines: 3,
          ),
          SizedBox(height: 14.h),
          SettingsTextField(
            label: 'Schedule',
            hintText: 'Example: Tomorrow, 9:00 AM',
            controller: _scheduleController,
          ),
          SizedBox(height: 18.h),
          Text(
            'Category',
            style: TextStyle(
              fontSize: FontSizes.footer1,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.montserrat,
              color: AppColors.white06,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children:
                ReminderCategory.values.map((category) {
                  final selected = _selectedCategory == category;
                  return ChoiceChip(
                    label: Text(reminderCategoryLabel(category)),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: AppColors.primaryBlue6,
                    backgroundColor: AppColors.kWhite,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.kWhite : AppColors.white05,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                      side: BorderSide(
                        color:
                            selected
                                ? AppColors.primaryBlue6
                                : AppColors.white02,
                      ),
                    ),
                  );
                }).toList(),
          ),
          SizedBox(height: 18.h),
          SwitchListTile.adaptive(
            value: _enabled,
            onChanged: (value) {
              setState(() {
                _enabled = value;
              });
            },
            activeThumbColor: AppColors.kWhite,
            activeTrackColor: AppColors.primaryBlue6,
            contentPadding: EdgeInsets.zero,
            title: const Text('Reminder enabled'),
            subtitle: const Text(
              'Turn this off if you want to keep it saved but silent.',
            ),
          ),
          SwitchListTile.adaptive(
            value: _repeats,
            onChanged: (value) {
              setState(() {
                _repeats = value;
              });
            },
            activeThumbColor: AppColors.kWhite,
            activeTrackColor: AppColors.primaryBlue6,
            contentPadding: EdgeInsets.zero,
            title: const Text('Repeat reminder'),
            subtitle: const Text(
              'Use this for medications and regular check-ins.',
            ),
          ),
          SizedBox(height: 18.h),
          SettingsActionButton(
            label: _isEditing ? 'Save changes' : 'Create reminder',
            onTap: _saveReminder,
            backgroundColor: AppColors.primaryBlue6,
            textColor: AppColors.kWhite,
            borderColor: AppColors.primaryBlue6,
          ),
        ],
      ),
    );
  }
}
