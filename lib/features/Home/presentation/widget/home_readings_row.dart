import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Home/presentation/model/reading_metric.dart';
import 'package:app_t/features/Home/presentation/widget/home_metric_card.dart';
import 'package:flutter/material.dart';

class HomeReadingsRow extends StatelessWidget {
  const HomeReadingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final homeMetrics = readingMetrics.take(3).toList();

    return SizedBox(
      height: 92,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          HomeMetricCard(
            title: 'Add new\nReadings',
            isAddCard: true,
            onTap:
                () => Navigator.of(context).pushNamed(RouteName.manageReadings),
          ),
          const SizedBox(width: 8),
          ...homeMetrics.indexed.expand((entry) {
            final index = entry.$1;
            final metric = entry.$2;

            return [
              HomeMetricCard(
                title: metric.title,
                unit: metric.unit,
                assetPath: metric.iconAssetPath,
                onTap:
                    () => Navigator.of(context).pushNamed(
                      RouteName.readingMetricDetail,
                      arguments: ReadingMetricRouteArgs(metric.id),
                    ),
              ),
              if (index != homeMetrics.length - 1) const SizedBox(width: 8),
            ];
          }),
        ],
      ),
    );
  }
}
