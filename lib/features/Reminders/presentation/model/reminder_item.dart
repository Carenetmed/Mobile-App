import 'package:flutter/foundation.dart';

enum ReminderCategory { medication, appointment, wellness, followUp }

@immutable
class ReminderItem {
  final String id;
  final String title;
  final String subtitle;
  final String scheduleLabel;
  final ReminderCategory category;
  final bool enabled;
  final bool repeats;

  const ReminderItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.scheduleLabel,
    required this.category,
    required this.enabled,
    required this.repeats,
  });

  ReminderItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? scheduleLabel,
    ReminderCategory? category,
    bool? enabled,
    bool? repeats,
  }) {
    return ReminderItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      scheduleLabel: scheduleLabel ?? this.scheduleLabel,
      category: category ?? this.category,
      enabled: enabled ?? this.enabled,
      repeats: repeats ?? this.repeats,
    );
  }
}

class ReminderEditorArgs {
  final ReminderItem? reminder;

  const ReminderEditorArgs({this.reminder});
}

const List<ReminderItem> sampleReminders = [
  ReminderItem(
    id: 'medication-morning',
    title: 'Morning medication',
    subtitle: 'Take your blood pressure tablets after breakfast.',
    scheduleLabel: 'Today, 8:00 AM',
    category: ReminderCategory.medication,
    enabled: true,
    repeats: true,
  ),
  ReminderItem(
    id: 'hydration-check',
    title: 'Hydration check-in',
    subtitle: 'Drink water and log how you feel this afternoon.',
    scheduleLabel: 'Today, 2:30 PM',
    category: ReminderCategory.wellness,
    enabled: true,
    repeats: true,
  ),
  ReminderItem(
    id: 'clinic-visit',
    title: 'Clinic follow-up',
    subtitle: 'Appointment with Dr. Uzo at the LUTH outpatient wing.',
    scheduleLabel: 'Fri, 10:15 AM',
    category: ReminderCategory.appointment,
    enabled: true,
    repeats: false,
  ),
  ReminderItem(
    id: 'lab-results',
    title: 'Review lab results',
    subtitle: 'Check your latest lab notes and ask any follow-up questions.',
    scheduleLabel: 'Sat, 6:00 PM',
    category: ReminderCategory.followUp,
    enabled: false,
    repeats: false,
  ),
];

String reminderCategoryLabel(ReminderCategory category) {
  switch (category) {
    case ReminderCategory.medication:
      return 'Medication';
    case ReminderCategory.appointment:
      return 'Appointment';
    case ReminderCategory.wellness:
      return 'Wellness';
    case ReminderCategory.followUp:
      return 'Follow Up';
  }
}
