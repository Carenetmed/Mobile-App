import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/features/Home/presentation/pages/manage_readings.dart';
import 'package:app_t/features/Home/presentation/pages/readings.dart';
import 'package:app_t/features/Home/presentation/widget/home_metric_card.dart';
import 'package:flutter/material.dart';

class HomeReadingsRow extends StatelessWidget {
  const HomeReadingsRow({super.key});

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          HomeMetricCard(
            title: 'Add new\nReadings',
            isAddCard: true,
            onTap: () => _openPage(context, ManageReadings()),
          ),
          const SizedBox(width: 8),
          HomeMetricCard(
            title: 'Blood Sugar',
            unit: 'mg/dl',
            assetPath: AssetsIcon.bloodSugar,
            onTap: () => _openPage(context, VitalsReading()),
          ),
          const SizedBox(width: 8),
          HomeMetricCard(
            title: 'Blood Pressure',
            unit: 'mmHg',
            assetPath: AssetsIcon.bloodPressure,
            onTap: () => _openPage(context, VitalsReading()),
          ),
          const SizedBox(width: 8),
          HomeMetricCard(
            title: 'Weight',
            unit: 'kg',
            assetPath: AssetsIcon.weight,
            onTap: () => _openPage(context, VitalsReading()),
          ),
        ],
      ),
    );
  }
}
