import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/requestable_times.dart';
import 'package:app_t/features/Home/domain/services/appointment_experience_policy.dart';
import 'package:app_t/features/Home/domain/services/professional_time_formatter.dart';
import 'package:app_t/features/Home/presentation/state/appointment_experience_controller.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentsShellPage extends StatefulWidget {
  const AppointmentsShellPage({
    super.key,
    this.schedulingRepository,
    this.sessionStore,
    this.now,
    this.embedded = false,
  });

  final SchedulingRepository? schedulingRepository;
  final SessionStore? sessionStore;
  final DateTime? now;
  final bool embedded;

  @override
  State<AppointmentsShellPage> createState() => _AppointmentsShellPageState();
}

class _AppointmentsShellPageState extends State<AppointmentsShellPage> {
  late final AppointmentListController _controller;
  final AppointmentExperiencePolicy _policy =
      const AppointmentExperiencePolicy();

  DateTime get _now => widget.now ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = AppointmentListController(
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
                title: const Text('Appointments'),
                backgroundColor: CarenetColors.white,
                foregroundColor: CarenetColors.black,
                elevation: 0,
              ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _controller.load,
          child: ListView(
            key: const Key('appointments-list'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appointments',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Authoritative requests and care sessions.',
                          style: TextStyle(color: CarenetColors.neutral600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('appointments-refresh'),
                    tooltip: 'Refresh appointments',
                    onPressed:
                        _controller.isLoading || _controller.isRefreshing
                            ? null
                            : _controller.load,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_controller.isLoading)
                const _StatePanel(
                  icon: Icons.sync,
                  title: 'Loading appointments',
                  body: 'Checking the latest appointment status.',
                )
              else if (_controller.role == AppointmentViewerRole.unsupported)
                _StatePanel(
                  icon: Icons.lock_outline,
                  title: 'Appointments unavailable',
                  body:
                      _controller.errorMessage ??
                      'This account cannot access appointments.',
                )
              else if (_controller.appointments.isEmpty &&
                  _controller.errorMessage != null)
                _StatePanel(
                  icon: Icons.cloud_off_outlined,
                  title: 'Appointments could not be loaded',
                  body: _controller.errorMessage!,
                  actionLabel: 'Retry',
                  onAction: _controller.load,
                )
              else ...[
                if (_controller.errorMessage != null)
                  _InlineNotice(
                    message:
                        '${_controller.errorMessage} Your previous appointments are still shown.',
                  ),
                if (_controller.isRefreshing)
                  const LinearProgressIndicator(minHeight: 2),
                if (_controller.appointments.isEmpty)
                  _StatePanel(
                    icon: Icons.event_available_outlined,
                    title:
                        _controller.role == AppointmentViewerRole.professional
                            ? 'No appointment activity yet'
                            : 'No appointments scheduled',
                    body:
                        _controller.role == AppointmentViewerRole.professional
                            ? 'New patient requests will appear here when they arrive.'
                            : 'Find a verified professional when you are ready to request care.',
                    actionLabel:
                        _controller.role == AppointmentViewerRole.patient
                            ? 'Find care'
                            : null,
                    onAction:
                        _controller.role == AppointmentViewerRole.patient
                            ? () =>
                                Navigator.pushNamed(context, RouteName.search)
                            : null,
                  )
                else
                  ..._buildSections(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSections() {
    final widgets = <Widget>[];
    for (final section in AppointmentListSection.values) {
      final items = _policy.sortedForSection(
        appointments: _controller.appointments.where(
          (appointment) =>
              _policy.sectionFor(
                role: _controller.role,
                appointment: appointment,
                now: _now,
              ) ==
              section,
        ),
        section: section,
      );
      if (items.isEmpty) {
        continue;
      }
      if (widgets.isNotEmpty) {
        widgets.add(const SizedBox(height: 22));
      }
      widgets.add(
        Text(
          _sectionLabel(section),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      );
      widgets.add(const SizedBox(height: 10));
      widgets.addAll(
        items.map(
          (appointment) => _AppointmentListCard(
            appointment: appointment,
            role: _controller.role,
            onTap:
                () => Navigator.pushNamed(
                  context,
                  RouteName.appointmentDetail,
                  arguments: appointment.id,
                ).then((_) => _controller.load()),
          ),
        ),
      );
    }
    return widgets;
  }

  String _sectionLabel(AppointmentListSection section) {
    return switch (section) {
      AppointmentListSection.actionNeeded => 'Action needed',
      AppointmentListSection.upcoming => 'Upcoming',
      AppointmentListSection.past => 'Past',
      AppointmentListSection.closed => 'Cancelled or declined',
    };
  }
}

class AppointmentDetailShellPage extends StatefulWidget {
  const AppointmentDetailShellPage({
    super.key,
    required this.appointmentId,
    this.schedulingRepository,
    this.sessionStore,
    this.now,
  });

  final String? appointmentId;
  final SchedulingRepository? schedulingRepository;
  final SessionStore? sessionStore;
  final DateTime? now;

  @override
  State<AppointmentDetailShellPage> createState() =>
      _AppointmentDetailShellPageState();
}

class _AppointmentDetailShellPageState
    extends State<AppointmentDetailShellPage> {
  AppointmentDetailController? _controller;

  @override
  void initState() {
    super.initState();
    final id = widget.appointmentId?.trim() ?? '';
    if (id.isNotEmpty) {
      _controller = AppointmentDetailController(
        appointmentId: id,
        schedulingRepository:
            widget.schedulingRepository ?? sl<SchedulingRepository>(),
        sessionStore: widget.sessionStore ?? sl<SessionStore>(),
        now: widget.now == null ? null : () => widget.now!,
      )..addListener(_onChanged);
      _controller!.load();
    }
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller
      ?..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: CarenetColors.white,
      appBar: AppBar(
        title: const Text('Appointment details'),
        backgroundColor: CarenetColors.white,
        foregroundColor: CarenetColors.black,
        elevation: 0,
        actions: [
          if (controller != null)
            IconButton(
              tooltip: 'Refresh appointment',
              onPressed:
                  controller.isLoading ||
                          controller.isRefreshing ||
                          controller.isMutating
                      ? null
                      : controller.load,
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child:
            controller == null
                ? _notFound()
                : RefreshIndicator(
                  onRefresh: controller.load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    children: [_detailBody(controller)],
                  ),
                ),
      ),
    );
  }

  Widget _detailBody(AppointmentDetailController controller) {
    if (controller.isLoading) {
      return const _StatePanel(
        icon: Icons.sync,
        title: 'Loading appointment',
        body: 'Checking the current status.',
      );
    }
    final appointment = controller.appointment;
    if (appointment == null) {
      return _StatePanel(
        icon: Icons.event_busy_outlined,
        title: 'Appointment unavailable',
        body:
            controller.loadError ??
            'This appointment could not be found for this account.',
        actionLabel: 'Back to appointments',
        onAction: () => Navigator.of(context).maybePop(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.isRefreshing)
          const LinearProgressIndicator(minHeight: 2),
        _AppointmentStatusHeader(
          appointment: appointment,
          role: controller.role,
        ),
        const SizedBox(height: 18),
        _DetailRow(
          icon: Icons.calendar_today_outlined,
          label: 'Date and time',
          value: _appointmentDate(appointment.requestedStartAt),
        ),
        _DetailRow(
          icon: Icons.schedule_outlined,
          label: 'Duration',
          value: '${appointment.durationMinutes} minutes',
        ),
        if (appointment.createdAt != null)
          _DetailRow(
            icon: Icons.history_outlined,
            label: 'Requested',
            value: _appointmentDate(appointment.createdAt!),
          ),
        if (controller.loadError != null)
          _InlineNotice(
            message:
                '${controller.loadError} The last loaded appointment remains visible.',
          ),
        if (controller.actionMessage != null)
          _InlineNotice(message: controller.actionMessage!, positive: true),
        if (controller.actionError != null)
          _InlineNotice(message: controller.actionError!),
        const SizedBox(height: 18),
        if (controller.actions.isEmpty)
          const Text(
            'No lifecycle action is currently available.',
            style: TextStyle(color: CarenetColors.neutral600),
          )
        else
          _ActionArea(controller: controller, confirm: _confirmAction),
      ],
    );
  }

  Widget _notFound() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: _StatePanel(
        icon: Icons.event_busy_outlined,
        title: 'Appointment unavailable',
        body: 'A valid appointment identifier is required.',
        actionLabel: 'Back',
        onAction: () => Navigator.of(context).maybePop(),
      ),
    );
  }

  Future<bool> _confirmAction(AppointmentUiAction action) async {
    if (action == AppointmentUiAction.accept ||
        action == AppointmentUiAction.reschedule) {
      return true;
    }
    final label = _actionLabel(action).toLowerCase();
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('${_actionLabel(action)} appointment?'),
                content: Text(
                  'The backend will recheck whether this appointment can be $label.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Keep appointment'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(_actionLabel(action)),
                  ),
                ],
              ),
        ) ??
        false;
  }
}

class _ActionArea extends StatelessWidget {
  const _ActionArea({required this.controller, required this.confirm});

  final AppointmentDetailController controller;
  final Future<bool> Function(AppointmentUiAction action) confirm;

  @override
  Widget build(BuildContext context) {
    final actions = controller.actions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available actions',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        if (actions.contains(AppointmentUiAction.reschedule)) ...[
          CarenetButton(
            label:
                controller.isLoadingTimes
                    ? 'Loading available times...'
                    : 'Choose a new time',
            type: CarenetButtonType.outline,
            onPressed:
                controller.isMutating || controller.isLoadingTimes
                    ? null
                    : controller.loadRescheduleTimes,
          ),
          if (controller.requestableTimes != null)
            _RescheduleTimes(controller: controller),
          const SizedBox(height: 10),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              actions
                  .where((action) => action != AppointmentUiAction.reschedule)
                  .map(
                    (action) => OutlinedButton.icon(
                      key: Key('appointment-action-${action.name}'),
                      onPressed:
                          controller.isMutating
                              ? null
                              : () async {
                                if (await confirm(action)) {
                                  await controller.perform(action);
                                }
                              },
                      icon: Icon(_actionIcon(action)),
                      label: Text(_actionLabel(action)),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}

class _RescheduleTimes extends StatelessWidget {
  const _RescheduleTimes({required this.controller});

  final AppointmentDetailController controller;

  @override
  Widget build(BuildContext context) {
    final response = controller.requestableTimes!;
    final timezone = response.timezone;
    final times = response.times;
    if (timezone == null ||
        timezone.trim().isEmpty ||
        !ProfessionalTimeFormatter().isValidTimezone(timezone)) {
      return const _InlineNotice(
        message: 'Available times cannot be displayed safely right now.',
      );
    }
    if (times.isEmpty) {
      return const _InlineNotice(
        message: 'No requestable times are currently available.',
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Professional timezone: $timezone',
            style: const TextStyle(color: CarenetColors.neutral600),
          ),
          const SizedBox(height: 8),
          ...times
              .take(20)
              .map(
                (time) => ListTile(
                  selected: identical(controller.selectedTime, time),
                  onTap:
                      controller.isMutating
                          ? null
                          : () => controller.selectTime(time),
                  leading: Icon(
                    identical(controller.selectedTime, time)
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: CarenetColors.brand,
                  ),
                  title: Text(
                    _requestableTimeLabel(time, timezone),
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: const Text('30 minutes'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
          CarenetButton(
            label:
                controller.isMutating
                    ? 'Requesting new time...'
                    : 'Request selected time',
            onPressed:
                controller.selectedTime == null || controller.isMutating
                    ? null
                    : () => controller.perform(AppointmentUiAction.reschedule),
          ),
        ],
      ),
    );
  }
}

class _AppointmentListCard extends StatelessWidget {
  const _AppointmentListCard({
    required this.appointment,
    required this.role,
    required this.onTap,
  });

  final AppointmentSummary appointment;
  final AppointmentViewerRole role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final counterpart =
        role == AppointmentViewerRole.professional ? 'Patient' : 'Professional';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        key: Key('appointment-${appointment.id}'),
        onTap: onTap,
        leading: const CircleAvatar(
          child: Icon(Icons.medical_services_outlined),
        ),
        title: Text('Appointment with $counterpart'),
        subtitle: Text(_appointmentDate(appointment.requestedStartAt)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _statusLabel(appointment.status),
              style: const TextStyle(
                color: CarenetColors.brand,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }
}

class _AppointmentStatusHeader extends StatelessWidget {
  const _AppointmentStatusHeader({
    required this.appointment,
    required this.role,
  });

  final AppointmentSummary appointment;
  final AppointmentViewerRole role;

  @override
  Widget build(BuildContext context) {
    final counterpart =
        role == AppointmentViewerRole.professional ? 'Patient' : 'Professional';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CarenetColors.primary100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _statusLabel(appointment.status),
            style: const TextStyle(
              color: CarenetColors.brand,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appointment with $counterpart',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(_statusExplanation(appointment.status)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: CarenetColors.brand),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: CarenetColors.neutral600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

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
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.message, this.positive = false});

  final String message;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: positive ? CarenetColors.primary100 : CarenetColors.neutral100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message),
    );
  }
}

String _appointmentDate(DateTime value) {
  if (value.millisecondsSinceEpoch <= 0) {
    return 'Time unavailable';
  }
  return DateFormat('EEE, d MMM y, h:mm a').format(value.toLocal());
}

String _requestableTimeLabel(RequestableTime value, String timezone) {
  final labels = ProfessionalTimeFormatter().format(
    utcStartAt: value.startAt,
    professionalTimezone: timezone,
  );
  final local = labels.patientLocalTime;
  return '${labels.professionalDate}, ${labels.professionalTime}'
      '${local == null ? '' : ' ($local)'}';
}

String _statusLabel(AppointmentStatus status) {
  return switch (status) {
    AppointmentStatus.requested => 'REQUEST SENT',
    AppointmentStatus.accepted => 'ACCEPTED',
    AppointmentStatus.declined => 'DECLINED',
    AppointmentStatus.cancelled => 'CANCELLED',
    AppointmentStatus.completed => 'COMPLETED',
    AppointmentStatus.unknown => 'STATUS UNAVAILABLE',
  };
}

String _statusExplanation(AppointmentStatus status) {
  return switch (status) {
    AppointmentStatus.requested =>
      'The request is waiting for the professional to respond.',
    AppointmentStatus.accepted => 'The appointment has been accepted.',
    AppointmentStatus.declined => 'The professional declined this request.',
    AppointmentStatus.cancelled => 'This appointment was cancelled.',
    AppointmentStatus.completed => 'This appointment is complete.',
    AppointmentStatus.unknown =>
      'The current appointment status could not be interpreted safely.',
  };
}

String _actionLabel(AppointmentUiAction action) {
  return switch (action) {
    AppointmentUiAction.accept => 'Accept',
    AppointmentUiAction.decline => 'Decline',
    AppointmentUiAction.cancel => 'Cancel',
    AppointmentUiAction.reschedule => 'Reschedule',
    AppointmentUiAction.complete => 'Complete',
  };
}

IconData _actionIcon(AppointmentUiAction action) {
  return switch (action) {
    AppointmentUiAction.accept => Icons.check,
    AppointmentUiAction.decline => Icons.close,
    AppointmentUiAction.cancel => Icons.event_busy_outlined,
    AppointmentUiAction.reschedule => Icons.edit_calendar_outlined,
    AppointmentUiAction.complete => Icons.task_alt,
  };
}
