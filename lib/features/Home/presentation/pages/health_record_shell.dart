import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/readings_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HealthRecordShellPage extends StatelessWidget {
  const HealthRecordShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: Text(
          'Health Record',
          style: TextStyle(
            color: AppColors.primaryBlue5,
            fontSize: FontSizes.footer2,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder<BloodSugarEntry?>(
          valueListenable: ReadingsLocalStore.bloodSugarEntry,
          builder: (context, entry, _) {
            final records = _buildRecords(entry);
            return ListView(
              padding: REdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              children: [
                Text(
                  'Health File',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    fontSize: FontSizes.heading3,
                    color: AppColors.kBlack,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Your readings',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w500,
                    fontSize: FontSizes.footer2,
                    color: AppColors.primaryBlue11,
                  ),
                ),
                SizedBox(height: 16.h),
                ...records.map(
                  (record) => Padding(
                    padding: REdgeInsets.only(bottom: 12.h),
                    child: _HealthRecordCard(record: record),
                  ),
                ),
                SizedBox(height: 4.h),
                Tooltip(
                  message: 'Download waits for backend history/export support.',
                  child: Opacity(
                    opacity: 0.45,
                    child: IgnorePointer(
                      child: OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Download'),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<_HealthRecordItem> _buildRecords(BloodSugarEntry? bloodSugar) {
    return <_HealthRecordItem>[
      const _HealthRecordItem(
        title: 'Blood Pressure',
        value: '92/120 mg/dL',
        status: 'Normal',
        detail: '12:38pm | 20/05/2025',
        icon: Icons.monitor_heart_outlined,
      ),
      const _HealthRecordItem(
        title: 'Weight',
        value: '70 Kg',
        status: '65 BMI',
        detail: '128 KCal',
        icon: Icons.scale_outlined,
      ),
      _HealthRecordItem(
        title: 'Blood Sugar',
        value:
            bloodSugar == null
                ? ReadingsLocalStore.bloodSugarDisplay
                : '${bloodSugar.reading} mg/dL',
        status: bloodSugar == null ? 'Local baseline' : bloodSugar.context,
        detail:
            bloodSugar == null
                ? 'Add a blood sugar reading to update this record'
                : (bloodSugar.note.isEmpty
                    ? 'Latest local entry'
                    : bloodSugar.note),
        icon: Icons.bloodtype_outlined,
      ),
      const _HealthRecordItem(
        title: 'Blood Oxygen',
        value: '98%',
        status: 'Range: 91-99%',
        detail: 'Average: 97%',
        icon: Icons.air_outlined,
      ),
      const _HealthRecordItem(
        title: 'Steps',
        value: '241 steps',
        status: 'Goal: 8000/day',
        detail: 'Range: 3000-4000 | Time: 3 mins',
        icon: Icons.directions_walk,
      ),
      const _HealthRecordItem(
        title: 'Heart Rate',
        value: '74 bpm',
        status: 'Rate range: 56-111 bpm',
        detail: 'Resting rate: 23 bpm | Stress level: High',
        icon: Icons.favorite_border,
      ),
      const _HealthRecordItem(
        title: 'Temperature',
        value: '37C',
        status: 'Average: 32',
        detail: 'Range: 32-40',
        icon: Icons.thermostat_outlined,
      ),
      const _HealthRecordItem(
        title: 'Sleep Rate',
        value: '8h 7min',
        status: 'Deep Sleep 1h 20min',
        detail: 'REM: 3h 26min | Awake: 1h 13min',
        icon: Icons.bedtime_outlined,
      ),
    ];
  }
}

class _HealthRecordItem {
  const _HealthRecordItem({
    required this.title,
    required this.value,
    required this.status,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String value;
  final String status;
  final String detail;
  final IconData icon;
}

class _HealthRecordCard extends StatelessWidget {
  const _HealthRecordCard({required this.record});

  final _HealthRecordItem record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: AppColors.blue02,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(record.icon, color: AppColors.primaryBlue5, size: 24.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    fontSize: FontSizes.footer2,
                    color: AppColors.kBlack,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  record.value,
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    fontSize: FontSizes.body3,
                    color: AppColors.primaryBlue5,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  record.status,
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w500,
                    fontSize: FontSizes.footer3,
                    color: AppColors.kBlack,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  record.detail,
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w400,
                    fontSize: FontSizes.footer4,
                    color: AppColors.primaryBlue11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
