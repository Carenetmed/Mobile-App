import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class SchedulesShellPage extends StatefulWidget {
  const SchedulesShellPage({super.key});

  @override
  State<SchedulesShellPage> createState() => _SchedulesShellPageState();
}

class _SchedulesShellPageState extends State<SchedulesShellPage> {
  late DateTime _selectedDate;
  bool _detailsExpanded = true;

  bool _isToday(DateTime date) {
    return DateUtils.isSameDay(date, DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: CarenetColors.white,
      appBar: AppBar(
        backgroundColor: CarenetColors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: CarenetColors.black),
        ),
        centerTitle: true,
        title: Text(
          'Task Reminder',
          style: TextStyle(
            fontFamily: AppFonts.montserrat,
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: CarenetColors.brand,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: CarenetColors.neutral200),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime(now.year - 1),
                lastDate: DateTime(now.year + 2, 12, 31),
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Schedule for ${DateFormat('MMMM d, y').format(_selectedDate)}',
              key: const Key('schedule-selected-date'),
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: CarenetColors.neutral700,
              ),
            ),
            SizedBox(height: 16.h),
            if (_isToday(_selectedDate))
              _ScheduleCard(
                selectedDate: _selectedDate,
                detailsExpanded: _detailsExpanded,
                onToggleDetails: () {
                  setState(() {
                    _detailsExpanded = !_detailsExpanded;
                  });
                },
              )
            else
              const _NoScheduleCard(),
            SizedBox(height: 16.h),
            const CarenetButton(label: 'Add reminder', onPressed: null),
            SizedBox(height: 10.h),
            Text(
              'Adding, editing, deleting, sharing, and delivering reminders require scheduling and notification backend contracts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: 12.sp,
                height: 1.45,
                color: CarenetColors.neutral500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.selectedDate,
    required this.detailsExpanded,
    required this.onToggleDetails,
  });

  final DateTime selectedDate;
  final bool detailsExpanded;
  final VoidCallback onToggleDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CarenetColors.white,
        border: Border.all(color: CarenetColors.neutral200),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggleDetails,
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Doctors Without Border Event',
                          style: TextStyle(
                            fontFamily: AppFonts.montserrat,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: CarenetColors.neutral700,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: CarenetColors.success200,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Active',
                            style: TextStyle(
                              fontFamily: AppFonts.montserrat,
                              fontSize: 12.sp,
                              color: CarenetColors.success100,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    detailsExpanded ? Icons.expand_less : Icons.expand_more,
                    color: CarenetColors.neutral500,
                  ),
                ],
              ),
            ),
          ),
          if (detailsExpanded) ...[
            const Divider(height: 1, color: CarenetColors.neutral200),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  const _DetailRow(label: 'Frequency', value: 'Once'),
                  SizedBox(height: 10.h),
                  _DetailRow(
                    label: 'Starts',
                    value:
                        '${DateFormat('EEEE, MMMM d, y').format(selectedDate)} 11:00 AM',
                  ),
                  SizedBox(height: 10.h),
                  _DetailRow(
                    label: 'Ends',
                    value:
                        '${DateFormat('EEEE, MMMM d, y').format(selectedDate)} 11:59 PM',
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Share'),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      IconButton(
                        tooltip: 'Delete unavailable',
                        onPressed: null,
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NoScheduleCard extends StatelessWidget {
  const _NoScheduleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: CarenetColors.neutral100,
        border: Border.all(color: CarenetColors.neutral200),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 34.r,
            color: CarenetColors.neutral400,
          ),
          SizedBox(height: 10.h),
          Text(
            'No local schedule for this date',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: CarenetColors.neutral700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Schedule persistence and delivery remain backend-gated.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontSize: 12.sp,
              color: CarenetColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 76.w,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontSize: 12.sp,
              color: CarenetColors.neutral500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: CarenetColors.neutral700,
            ),
          ),
        ),
      ],
    );
  }
}
