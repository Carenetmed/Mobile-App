import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectedDatesShellPage extends StatefulWidget {
  const SelectedDatesShellPage({super.key});

  @override
  State<SelectedDatesShellPage> createState() => _SelectedDatesShellPageState();
}

class _SelectedDatesShellPageState extends State<SelectedDatesShellPage> {
  late DateTime _selectedDate;
  bool _allDay = true;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  String? _error;
  bool _prepared = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  String _dateLabel(DateTime date) {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  int _minutes(TimeOfDay time) => time.hour * 60 + time.minute;

  Future<void> _pickTime({required bool isStart}) async {
    final current = isStart ? _startTime : _endTime;
    final value = await showTimePicker(context: context, initialTime: current);
    if (value == null || !mounted) {
      return;
    }
    setState(() {
      if (isStart) {
        _startTime = value;
      } else {
        _endTime = value;
      }
      _prepared = false;
      _error = null;
    });
  }

  void _prepareDraft() {
    if (!_allDay && _minutes(_endTime) <= _minutes(_startTime)) {
      setState(() {
        _error = 'End time must be after start time';
        _prepared = false;
      });
      return;
    }
    setState(() {
      _error = null;
      _prepared = true;
    });
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
          'Edit business hours',
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
                    _prepared = false;
                  });
                },
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              _dateLabel(_selectedDate),
              key: const Key('selected-business-date'),
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: CarenetColors.neutral700,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('All day'),
              value: _allDay,
              activeThumbColor: CarenetColors.brand,
              onChanged: (value) {
                setState(() {
                  _allDay = value;
                  _prepared = false;
                  _error = null;
                });
              },
            ),
            if (!_allDay)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickTime(isStart: true),
                      child: Text('Starts ${_startTime.format(context)}'),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickTime(isStart: false),
                      child: Text('Ends ${_endTime.format(context)}'),
                    ),
                  ),
                ],
              ),
            if (_error != null) ...[
              SizedBox(height: 8.h),
              Text(
                _error!,
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: 12.sp,
                  color: CarenetColors.error100,
                ),
              ),
            ],
            SizedBox(height: 16.h),
            CarenetButton(label: 'Prepare hours', onPressed: _prepareDraft),
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color:
                    _prepared
                        ? CarenetColors.primary100
                        : CarenetColors.neutral100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                _prepared
                    ? 'Business hours draft prepared for ${_dateLabel(_selectedDate)}. No profile schedule has been saved.'
                    : 'Choose a date and hours. Profile persistence and upgrade-dependent hour sets remain backend-gated.',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: 12.sp,
                  height: 1.45,
                  color: CarenetColors.neutral600,
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'Weekly availability',
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: CarenetColors.neutral700,
              ),
            ),
            SizedBox(height: 8.h),
            for (final day in const <String>[
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday',
              'Saturday',
            ])
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(day),
                trailing: const Text('Closed'),
              ),
          ],
        ),
      ),
    );
  }
}
