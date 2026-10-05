import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/domain/entities/availability_window.dart';
import 'package:app_t/features/Home/presentation/state/professional_schedule_controller.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:flutter/material.dart';

class SelectedDatesShellPage extends StatefulWidget {
  const SelectedDatesShellPage({
    super.key,
    this.schedulingRepository,
    this.sessionStore,
    this.initialDate,
    this.embedded = false,
  });

  final SchedulingRepository? schedulingRepository;
  final SessionStore? sessionStore;
  final DateTime? initialDate;
  final bool embedded;

  @override
  State<SelectedDatesShellPage> createState() => _SelectedDatesShellPageState();
}

class _SelectedDatesShellPageState extends State<SelectedDatesShellPage> {
  late final ProfessionalScheduleController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfessionalScheduleController(
      schedulingRepository:
          widget.schedulingRepository ?? sl<SchedulingRepository>(),
      sessionStore: widget.sessionStore ?? sl<SessionStore>(),
    )..addListener(_onChanged);
    _controller.load();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CarenetColors.white,
      appBar:
          widget.embedded
              ? null
              : AppBar(
                title: const Text('Schedule'),
                backgroundColor: CarenetColors.white,
                foregroundColor: CarenetColors.black,
                elevation: 0,
              ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _controller.load,
          child: ListView(
            key: const Key('professional-schedule'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly availability',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Recurring windows define when patients may be offered requestable times.',
                          style: TextStyle(color: CarenetColors.neutral600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh availability',
                    onPressed:
                        _controller.isLoading ||
                                _controller.isRefreshing ||
                                _controller.isMutating
                            ? null
                            : _controller.load,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_controller.isLoading)
                const _ScheduleState(
                  icon: Icons.sync,
                  title: 'Loading availability',
                  body: 'Checking your recurring schedule.',
                )
              else if (!_controller.isAuthorizedProfessional)
                _ScheduleState(
                  icon: Icons.lock_outline,
                  title: 'Schedule unavailable',
                  body:
                      _controller.errorMessage ??
                      'Only a professional account can manage availability.',
                )
              else ...[
                if (_controller.isRefreshing)
                  const LinearProgressIndicator(minHeight: 2),
                if (_controller.errorMessage != null)
                  _ScheduleNotice(message: _controller.errorMessage!),
                if (_controller.successMessage != null)
                  _ScheduleNotice(
                    message: _controller.successMessage!,
                    positive: true,
                  ),
                CarenetButton(
                  label:
                      _controller.isMutating
                          ? 'Updating availability...'
                          : 'Add availability window',
                  onPressed:
                      _controller.isMutating ? null : () => _editWindow(),
                ),
                const SizedBox(height: 16),
                if (_controller.windows.isEmpty)
                  const _ScheduleState(
                    icon: Icons.calendar_month_outlined,
                    title: 'No recurring availability',
                    body:
                        'Add a weekly window before patients can receive requestable times.',
                  )
                else
                  ..._controller.windows.map(_windowCard),
                const SizedBox(height: 12),
                const _ScheduleNotice(
                  message:
                      'These hours show when you are generally available. Patients can request appointment times that fit your schedule.',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _windowCard(AvailabilityWindow window) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        key: Key('availability-${window.id}'),
        leading: CircleAvatar(
          backgroundColor: CarenetColors.primary100,
          child: Text(_weekdayShort(window.weekday)),
        ),
        title: Text(
          '${_weekdayLabel(window.weekday)} - ${window.active ? 'Active' : 'Inactive'}',
        ),
        subtitle: Text(
          '${_timeLabel(window.startMinute)} - ${_timeLabel(window.endMinute)}\n${window.timezone}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Edit availability',
              onPressed:
                  _controller.isMutating
                      ? null
                      : () => _editWindow(existing: window),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Remove availability',
              onPressed:
                  _controller.isMutating ? null : () => _deleteWindow(window),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editWindow({AvailabilityWindow? existing}) async {
    final result = await showDialog<AvailabilityWindowDraft>(
      context: context,
      builder: (_) => _AvailabilityEditor(existing: existing),
    );
    if (result == null || !mounted) {
      return;
    }
    final error = await _controller.save(
      replacingId: existing?.id,
      draft: result,
    );
    if (error != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _deleteWindow(AvailabilityWindow window) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Remove availability?'),
                content: Text(
                  '${_weekdayLabel(window.weekday)} ${_timeLabel(window.startMinute)} - ${_timeLabel(window.endMinute)} will no longer produce requestable times.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Keep'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Remove'),
                  ),
                ],
              ),
        ) ??
        false;
    if (!confirmed) {
      return;
    }
    final error = await _controller.delete(window.id);
    if (error != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}

class _AvailabilityEditor extends StatefulWidget {
  const _AvailabilityEditor({this.existing});

  final AvailabilityWindow? existing;

  @override
  State<_AvailabilityEditor> createState() => _AvailabilityEditorState();
}

class _AvailabilityEditorState extends State<_AvailabilityEditor> {
  late int _weekday = widget.existing?.weekday ?? 1;
  late TimeOfDay _start = _fromMinutes(widget.existing?.startMinute ?? 540);
  late TimeOfDay _end = _fromMinutes(widget.existing?.endMinute ?? 1020);
  late bool _active = widget.existing?.active ?? true;
  late final TextEditingController _timezone = TextEditingController(
    text:
        widget.existing?.timezone.trim().isNotEmpty == true
            ? widget.existing!.timezone
            : 'Africa/Lagos',
  );
  String? _error;

  @override
  void dispose() {
    _timezone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existing == null ? 'Add availability' : 'Edit availability',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              initialValue: _weekday,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Weekday'),
              items: List<DropdownMenuItem<int>>.generate(
                7,
                (day) => DropdownMenuItem<int>(
                  value: day,
                  child: Text(_weekdayLabel(day)),
                ),
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _weekday = value);
                }
              },
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final stackButtons =
                    MediaQuery.sizeOf(context).width < 388 ||
                    MediaQuery.textScalerOf(context).scale(16) > 20;
                final startButton = OutlinedButton(
                  onPressed: () => _pickTime(start: true),
                  child: Text(
                    'Start ${_start.format(context)}',
                    textAlign: TextAlign.center,
                  ),
                );
                final endButton = OutlinedButton(
                  onPressed: () => _pickTime(start: false),
                  child: Text(
                    'End ${_end.format(context)}',
                    textAlign: TextAlign.center,
                  ),
                );

                if (stackButtons) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      startButton,
                      const SizedBox(height: 8),
                      endButton,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: startButton),
                    const SizedBox(width: 8),
                    Expanded(child: endButton),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _timezone,
              decoration: const InputDecoration(
                labelText: 'IANA timezone',
                hintText: 'Africa/Lagos',
              ),
              autocorrect: false,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              value: _active,
              onChanged: (value) => setState(() => _active = value),
            ),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: CarenetColors.error100),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }

  Future<void> _pickTime({required bool start}) async {
    final value = await showTimePicker(
      context: context,
      initialTime: start ? _start : _end,
    );
    if (value != null && mounted) {
      setState(() {
        if (start) {
          _start = value;
        } else {
          _end = value;
        }
        _error = null;
      });
    }
  }

  void _submit() {
    final startMinute = _minutes(_start);
    final endMinute = _minutes(_end);
    if (endMinute <= startMinute) {
      setState(() => _error = 'End time must be after start time.');
      return;
    }
    Navigator.pop(
      context,
      AvailabilityWindowDraft(
        weekday: _weekday,
        startMinute: startMinute,
        endMinute: endMinute,
        timezone: _timezone.text.trim(),
        active: _active,
      ),
    );
  }
}

class _ScheduleState extends StatelessWidget {
  const _ScheduleState({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CarenetColors.neutral100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: CarenetColors.brand),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: CarenetColors.neutral600),
          ),
        ],
      ),
    );
  }
}

class _ScheduleNotice extends StatelessWidget {
  const _ScheduleNotice({required this.message, this.positive = false});

  final String message;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: positive ? CarenetColors.primary100 : CarenetColors.neutral100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message),
    );
  }
}

int _minutes(TimeOfDay value) => value.hour * 60 + value.minute;

TimeOfDay _fromMinutes(int value) {
  return TimeOfDay(hour: value ~/ 60, minute: value % 60);
}

String _weekdayLabel(int weekday) {
  return switch (weekday) {
    0 => 'Sunday',
    1 => 'Monday',
    2 => 'Tuesday',
    3 => 'Wednesday',
    4 => 'Thursday',
    5 => 'Friday',
    6 => 'Saturday',
    _ => 'Unknown day',
  };
}

String _weekdayShort(int weekday) {
  final label = _weekdayLabel(weekday);
  return label == 'Unknown day' ? '?' : label.substring(0, 2);
}

String _timeLabel(int minuteOfDay) {
  if (minuteOfDay < 0 || minuteOfDay > 1440) {
    return 'Time unavailable';
  }
  if (minuteOfDay == 1440) {
    return '24:00';
  }
  final hours = minuteOfDay ~/ 60;
  final minutes = minuteOfDay % 60;
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
}
