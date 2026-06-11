import 'package:flutter/foundation.dart';

@immutable
class BloodSugarEntry {
  const BloodSugarEntry({
    required this.reading,
    required this.context,
    required this.note,
  });

  final String reading;
  final String context;
  final String note;
}

class ReadingsLocalStore {
  ReadingsLocalStore._();

  static final ValueNotifier<BloodSugarEntry?> bloodSugarEntry =
      ValueNotifier<BloodSugarEntry?>(null);
  static final ValueNotifier<List<BloodSugarEntry>> bloodSugarHistory =
      ValueNotifier<List<BloodSugarEntry>>(<BloodSugarEntry>[]);

  static String get bloodSugarDisplay =>
      bloodSugarEntry.value == null
          ? '6mg/dl'
          : '${bloodSugarEntry.value!.reading} mg/dL';

  static void saveBloodSugar({
    required String reading,
    required String context,
    required String note,
  }) {
    final entry = BloodSugarEntry(
      reading: reading,
      context: context,
      note: note,
    );
    bloodSugarEntry.value = entry;
    bloodSugarHistory.value = <BloodSugarEntry>[
      entry,
      ...bloodSugarHistory.value,
    ];
  }

  static void deleteBloodSugarAt(int index) {
    final nextHistory = List<BloodSugarEntry>.from(bloodSugarHistory.value);
    if (index < 0 || index >= nextHistory.length) {
      return;
    }

    nextHistory.removeAt(index);
    bloodSugarHistory.value = nextHistory;
    bloodSugarEntry.value = nextHistory.isEmpty ? null : nextHistory.first;
  }

  static void reset() {
    bloodSugarEntry.value = null;
    bloodSugarHistory.value = <BloodSugarEntry>[];
  }
}
