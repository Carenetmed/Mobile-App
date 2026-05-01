import 'package:app_t/core/constants/app_assets.dart';
import 'package:flutter/foundation.dart';

@immutable
class ReadingMetric {
  final String id;
  final String title;
  final String reading;
  final String unit;
  final String iconAssetPath;
  final String helperText;
  final String insight;

  const ReadingMetric({
    required this.id,
    required this.title,
    required this.reading,
    required this.unit,
    required this.iconAssetPath,
    required this.helperText,
    required this.insight,
  });
}

class ReadingMetricRouteArgs {
  final String metricId;

  const ReadingMetricRouteArgs(this.metricId);
}

const List<ReadingMetric> readingMetrics = [
  ReadingMetric(
    id: 'blood_pressure',
    title: 'Blood Pressure',
    reading: '118/76',
    unit: 'mmHg',
    iconAssetPath: AssetsIcon.bloodPressure,
    helperText: 'Latest reading logged this week',
    insight: 'This sits in a healthy resting range for most adults.',
  ),
  ReadingMetric(
    id: 'weight',
    title: 'Weight',
    reading: '56',
    unit: 'kg',
    iconAssetPath: AssetsIcon.weight,
    helperText: 'Updated from your last check-in',
    insight: 'Weight has stayed steady compared with your previous entry.',
  ),
  ReadingMetric(
    id: 'blood_sugar',
    title: 'Blood Sugar',
    reading: '6.0',
    unit: 'mg/dl',
    iconAssetPath: AssetsIcon.bloodSugar,
    helperText: 'Recorded after your last meal',
    insight: 'Keep tracking around the same time each day for useful trends.',
  ),
  ReadingMetric(
    id: 'oxygen_level',
    title: 'Oxygen Level',
    reading: '98',
    unit: 'mg/dl',
    iconAssetPath: AssetsIcon.oxygenLevel,
    helperText: 'No concerning changes detected',
    insight: 'Your oxygen level looks stable based on the latest reading.',
  ),
  ReadingMetric(
    id: 'steps',
    title: 'Steps',
    reading: '4,820',
    unit: 'steps',
    iconAssetPath: AssetsIcon.steps,
    helperText: 'Today so far',
    insight:
        'You are on track to beat yesterday’s total if activity continues.',
  ),
];

ReadingMetric metricById(String id) {
  return readingMetrics.firstWhere(
    (metric) => metric.id == id,
    orElse: () => readingMetrics.first,
  );
}
