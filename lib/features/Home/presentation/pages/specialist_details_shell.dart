import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/search_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class SpecialistDetailsShellPage extends StatefulWidget {
  const SpecialistDetailsShellPage({this.specialistId, super.key});

  final String? specialistId;

  @override
  State<SpecialistDetailsShellPage> createState() =>
      _SpecialistDetailsShellPageState();
}

class _SpecialistDetailsShellPageState
    extends State<SpecialistDetailsShellPage> {
  int _selectedDay = 0;
  int _selectedTime = 0;

  static const List<String> _times = <String>[
    '10:00am',
    '11:00am',
    '11:30am',
    '12:00pm',
    '12:30pm',
    '1:00pm',
    '1:30pm',
  ];

  List<String> get _days {
    final today = DateUtils.dateOnly(DateTime.now());
    return List<String>.generate(6, (index) {
      final date = today.add(Duration(days: index));
      if (index == 0) {
        return 'TODAY ${date.day}';
      }
      return DateFormat('EEE d').format(date).toUpperCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final specialist = SearchLocalStore.specialistById(widget.specialistId);
    final days = _days;

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          'Specialist Details',
          style: TextStyle(
            fontSize: FontSizes.footer2,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue5,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: REdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
          children: [
            _Header(specialist: specialist),
            SizedBox(height: 18.h),
            const _InfoSection(),
            SizedBox(height: 20.h),
            _ChoiceWrap(
              title: 'CHOOSE DAY',
              values: days,
              selectedIndex: _selectedDay,
              onSelected: (index) => setState(() => _selectedDay = index),
            ),
            SizedBox(height: 18.h),
            _ChoiceWrap(
              title: 'CHOOSE TIME',
              values: _times,
              selectedIndex: _selectedTime,
              onSelected: (index) => setState(() => _selectedTime = index),
            ),
            SizedBox(height: 20.h),
            Container(
              padding: REdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.blue02,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Selected slot: ${days[_selectedDay]} at ${_times[_selectedTime]}. This is a local selection only; booking is completed in the existing appointment form.',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: FontSizes.footer4,
                  color: AppColors.primaryBlue11,
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(height: 14.h),
            FilledButton(
              onPressed: () {
                Navigator.pushNamed(context, RouteName.bookAppointment);
              },
              child: const Text('Book appointment'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.specialist});

  final SearchSpecialist specialist;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Image.asset(
            specialist.imageAsset,
            width: 76.r,
            height: 76.r,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) => Container(
                  width: 76.r,
                  height: 76.r,
                  color: AppColors.blue02,
                  child: Icon(Icons.person_outline, size: 32.r),
                ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                specialist.name,
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: FontSizes.body3,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 4.h),
              Text(specialist.role),
              SizedBox(height: 6.h),
              Text('${specialist.rating} - See reviews'),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _DetailRow(label: 'Available Time', value: 'Mon - Wed, 10.00 -14.00'),
        _DetailRow(label: 'Specialization', value: 'Medical doctor'),
        _DetailRow(label: 'Meeting Location', value: 'Zoom'),
        _DetailRow(label: 'Years experience', value: '10+'),
        _DetailRow(label: 'Phone number', value: '+234 90 1233 4567'),
        _DetailRow(label: 'Review', value: '120'),
      ],
    );
  }
}

class _ChoiceWrap extends StatelessWidget {
  const _ChoiceWrap({
    required this.title,
    required this.values,
    required this.selectedIndex,
    required this.onSelected,
  });

  final String title;
  final List<String> values;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: AppFonts.montserrat,
            fontSize: FontSizes.footer4,
            fontWeight: FontWeight.w700,
            color: AppColors.kBlack,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children:
              values.asMap().entries.map((entry) {
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: entry.key == selectedIndex,
                  selectedColor: AppColors.primaryBlue5,
                  labelStyle: TextStyle(
                    color:
                        entry.key == selectedIndex
                            ? AppColors.kWhite
                            : AppColors.kBlack,
                  ),
                  onSelected: (_) => onSelected(entry.key),
                );
              }).toList(),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130.w,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: FontSizes.footer4,
                color: AppColors.primaryBlue11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: FontSizes.footer4,
                fontWeight: FontWeight.w600,
                color: AppColors.kBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
