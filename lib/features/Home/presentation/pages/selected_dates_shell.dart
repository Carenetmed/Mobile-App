import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/domain/entities/availability_window.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectedDatesShellPage extends StatefulWidget {
  const SelectedDatesShellPage({
    super.key,
    this.schedulingRepository,
    this.initialDate,
  });

  final SchedulingRepository? schedulingRepository;
  final DateTime? initialDate;

  @override
  State<SelectedDatesShellPage> createState() => _SelectedDatesShellPageState();
}

class _SelectedDatesShellPageState extends State<SelectedDatesShellPage> {
  static const String _defaultTimezone = 'Africa/Lagos';

  late DateTime _selectedDate;
  bool _allDay = true;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  String? _validationError;
  String? _loadError;
  String? _saveError;
  String? _successMessage;
  bool _isLoading = true;
  bool _isSaving = false;
  List<AvailabilityWindow> _windows = const <AvailabilityWindow>[];

  SchedulingRepository get _schedulingRepository =>
      widget.schedulingRepository ?? sl<SchedulingRepository>();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDate ?? DateTime.now();
    _selectedDate = DateTime(initial.year, initial.month, initial.day);
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
      _successMessage = null;
    });

    try {
      final windows = await _schedulingRepository.ownAvailability();
      if (!mounted) {
        return;
      }
      setState(() {
        _windows = windows;
        _isLoading = false;
      });
    } on AuthFailure catch (failure) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = _safeSchedulingError(failure);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAvailability() async {
    if (!_allDay && _minutes(_endTime) <= _minutes(_startTime)) {
      setState(() {
        _validationError = 'End time must be after start time';
        _saveError = null;
        _successMessage = null;
      });
      return;
    }

    final weekday = _selectedDate.weekday;
    final draft = AvailabilityWindowDraft(
      weekday: weekday,
      startMinute: _allDay ? 0 : _minutes(_startTime),
      endMinute: _allDay ? 24 * 60 : _minutes(_endTime),
      timezone: _defaultTimezone,
      active: true,
    );
    final preserved =
        _windows.where((window) => window.weekday != weekday).map((window) {
          return AvailabilityWindowDraft(
            weekday: window.weekday,
            startMinute: window.startMinute,
            endMinute: window.endMinute,
            timezone: window.timezone,
            active: window.active,
          );
        }).toList();
    final replacement = <AvailabilityWindowDraft>[...preserved, draft]..sort(
      (a, b) =>
          a.weekday == b.weekday
              ? a.startMinute.compareTo(b.startMinute)
              : a.weekday.compareTo(b.weekday),
    );

    setState(() {
      _isSaving = true;
      _validationError = null;
      _saveError = null;
      _successMessage = null;
    });

    try {
      final windows = await _schedulingRepository.replaceOwnAvailability(
        windows: replacement,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _windows = windows;
        _isSaving = false;
        _successMessage = 'Availability saved from backend.';
      });
    } on AuthFailure catch (failure) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saveError = _safeSchedulingError(failure);
        _isSaving = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saveError = 'Something went wrong. Please try again.';
        _isSaving = false;
      });
    }
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

  String _safeSchedulingError(AuthFailure failure) {
    return switch (failure.type) {
      AuthFailureType.missingConfiguration => 'Backend is not configured yet.',
      AuthFailureType.unauthorized => 'Please sign in again.',
      AuthFailureType.validation =>
        'Please check the availability and try again.',
      AuthFailureType.server ||
      AuthFailureType.network => 'Service is unavailable. Please try again.',
      AuthFailureType.invalidCredentials ||
      AuthFailureType.unknown => 'Something went wrong. Please try again.',
    };
  }

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
      _validationError = null;
      _saveError = null;
      _successMessage = null;
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
            _AvailabilityStateBanner(
              isLoading: _isLoading,
              loadError: _loadError,
              saveError: _saveError,
              successMessage: _successMessage,
            ),
            SizedBox(height: 12.h),
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
                    _validationError = null;
                    _saveError = null;
                    _successMessage = null;
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
            SizedBox(height: 4.h),
            Text(
              'Timezone: $_defaultTimezone',
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: 12.sp,
                color: CarenetColors.neutral600,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('All day'),
              value: _allDay,
              activeThumbColor: CarenetColors.brand,
              onChanged:
                  _isSaving
                      ? null
                      : (value) {
                        setState(() {
                          _allDay = value;
                          _validationError = null;
                          _saveError = null;
                          _successMessage = null;
                        });
                      },
            ),
            if (!_allDay)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSaving ? null : () => _pickTime(isStart: true),
                      child: Text('Starts ${_startTime.format(context)}'),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSaving ? null : () => _pickTime(isStart: false),
                      child: Text('Ends ${_endTime.format(context)}'),
                    ),
                  ),
                ],
              ),
            if (_validationError != null) ...[
              SizedBox(height: 8.h),
              Text(
                _validationError!,
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: 12.sp,
                  color: CarenetColors.error100,
                ),
              ),
            ],
            SizedBox(height: 16.h),
            CarenetButton(
              label: _isSaving ? 'Saving availability...' : 'Save availability',
              onPressed: _isSaving ? null : _saveAvailability,
            ),
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: CarenetColors.neutral100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Saving replaces the backend weekly availability set while preserving other existing weekdays from the latest backend read.',
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
            _AvailabilityList(
              isLoading: _isLoading,
              loadError: _loadError,
              windows: _windows,
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityStateBanner extends StatelessWidget {
  const _AvailabilityStateBanner({
    required this.isLoading,
    required this.loadError,
    required this.saveError,
    required this.successMessage,
  });

  final bool isLoading;
  final String? loadError;
  final String? saveError;
  final String? successMessage;

  @override
  Widget build(BuildContext context) {
    final message =
        isLoading
            ? 'Loading backend availability...'
            : loadError ?? saveError ?? successMessage;
    if (message == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color:
            successMessage != null && loadError == null && saveError == null
                ? CarenetColors.primary100
                : CarenetColors.neutral100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontFamily: AppFonts.montserrat,
          fontSize: 12.sp,
          height: 1.45,
          color: CarenetColors.neutral700,
        ),
      ),
    );
  }
}

class _AvailabilityList extends StatelessWidget {
  const _AvailabilityList({
    required this.isLoading,
    required this.loadError,
    required this.windows,
  });

  final bool isLoading;
  final String? loadError;
  final List<AvailabilityWindow> windows;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Text('Loading...');
    }
    if (loadError != null) {
      return const Text('Backend availability could not be loaded.');
    }
    if (windows.isEmpty) {
      return const Text('No backend availability is saved yet.');
    }

    final sorted = <AvailabilityWindow>[...windows]..sort(
      (a, b) =>
          a.weekday == b.weekday
              ? a.startMinute.compareTo(b.startMinute)
              : a.weekday.compareTo(b.weekday),
    );

    return Column(
      children:
          sorted.map((window) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_weekdayLabel(window.weekday)),
              subtitle: Text(window.timezone),
              trailing: Text(
                window.active
                    ? '${_timeLabel(window.startMinute)} - ${_timeLabel(window.endMinute)}'
                    : 'Inactive',
              ),
            );
          }).toList(),
    );
  }

  String _weekdayLabel(int weekday) {
    const labels = <int, String>{
      DateTime.monday: 'Monday',
      DateTime.tuesday: 'Tuesday',
      DateTime.wednesday: 'Wednesday',
      DateTime.thursday: 'Thursday',
      DateTime.friday: 'Friday',
      DateTime.saturday: 'Saturday',
      DateTime.sunday: 'Sunday',
    };
    return labels[weekday] ?? 'Day $weekday';
  }

  String _timeLabel(int minuteOfDay) {
    final hours = minuteOfDay ~/ 60;
    final minutes = minuteOfDay % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
