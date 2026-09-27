import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Consultation/data/repositories/consultation_repository.dart';
import 'package:app_t/features/Consultation/domain/entities/consultation_entities.dart';
import 'package:app_t/features/Consultation/presentation/pages/consultation_shell.dart';
import 'package:app_t/features/Consultation/presentation/state/consultation_controller.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/data/repositories/financial_repository.dart';
import 'package:app_t/features/Home/data/storage/payment_checkout_intent_store.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/requestable_times.dart';
import 'package:app_t/features/Home/domain/services/appointment_experience_policy.dart';
import 'package:app_t/features/Home/domain/services/hosted_checkout_launcher.dart';
import 'package:app_t/features/Home/domain/services/money_formatter.dart';
import 'package:app_t/features/Home/domain/services/professional_time_formatter.dart';
import 'package:app_t/features/Home/presentation/state/appointment_payment_controller.dart';
import 'package:app_t/features/Home/presentation/state/appointment_experience_controller.dart';
import 'package:app_t/features/Messaging/presentation/state/messaging_controllers.dart';
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
    this.financialRepository,
    this.paymentCheckoutIntentStore,
    this.checkoutLauncher,
    this.paymentController,
    this.consultationRepository,
  });

  final String? appointmentId;
  final SchedulingRepository? schedulingRepository;
  final SessionStore? sessionStore;
  final DateTime? now;
  final FinancialRepository? financialRepository;
  final PaymentCheckoutIntentStore? paymentCheckoutIntentStore;
  final HostedCheckoutLauncher? checkoutLauncher;
  final AppointmentPaymentController? paymentController;
  final ConsultationGateway? consultationRepository;

  @override
  State<AppointmentDetailShellPage> createState() =>
      _AppointmentDetailShellPageState();
}

class _AppointmentDetailShellPageState extends State<AppointmentDetailShellPage>
    with WidgetsBindingObserver {
  AppointmentDetailController? _controller;
  AppointmentPaymentController? _paymentController;
  late final bool _ownsPaymentController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
      final canResolvePaymentDependencies =
          widget.financialRepository != null ||
          sl.isRegistered<FinancialRepository>();
      final canResolveIntentStore =
          widget.paymentCheckoutIntentStore != null ||
          sl.isRegistered<PaymentCheckoutIntentStore>();
      _ownsPaymentController =
          widget.paymentController == null &&
          canResolvePaymentDependencies &&
          canResolveIntentStore;
      _paymentController =
          widget.paymentController ??
          (canResolvePaymentDependencies && canResolveIntentStore
              ? AppointmentPaymentController(
                appointmentId: id,
                financialRepository:
                    widget.financialRepository ?? sl<FinancialRepository>(),
                sessionStore: widget.sessionStore ?? sl<SessionStore>(),
                intentStore:
                    widget.paymentCheckoutIntentStore ??
                    sl<PaymentCheckoutIntentStore>(),
                launcher:
                    widget.checkoutLauncher ??
                    const SystemHostedCheckoutLauncher(),
                now: widget.now == null ? null : () => widget.now!,
              )
              : null);
      _paymentController
        ?..addListener(_onChanged)
        ..load();
    } else {
      _ownsPaymentController = false;
    }
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller
      ?..removeListener(_onChanged)
      ..dispose();
    _paymentController?.removeListener(_onChanged);
    if (_ownsPaymentController) {
      _paymentController?.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }
    _paymentController?.onAppResumed().then((_) => _controller?.load());
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
        if (_paymentController != null) ...[
          const SizedBox(height: 6),
          _AppointmentPaymentSection(
            appointment: appointment,
            role: controller.role,
            controller: _paymentController!,
          ),
        ],
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
        if (appointment.status == AppointmentStatus.accepted ||
            appointment.status == AppointmentStatus.completed) ...[
          const SizedBox(height: 18),
          CarenetButton(
            key: const Key('appointment-open-messages'),
            label: 'Open appointment messages',
            type: CarenetButtonType.outline,
            onPressed:
                () => Navigator.of(context).pushNamed(
                  RouteName.chat,
                  arguments: AppointmentConversationRouteArgs(
                    appointmentId: appointment.id,
                  ),
                ),
          ),
        ],
        const SizedBox(height: 18),
        _AppointmentConsultationSection(
          appointment: appointment,
          repository:
              widget.consultationRepository ??
              (sl.isRegistered<ConsultationRepository>()
                  ? sl<ConsultationRepository>()
                  : null),
        ),
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

class _AppointmentConsultationSection extends StatefulWidget {
  const _AppointmentConsultationSection({
    required this.appointment,
    required this.repository,
  });

  final AppointmentSummary appointment;
  final ConsultationGateway? repository;

  @override
  State<_AppointmentConsultationSection> createState() =>
      _AppointmentConsultationSectionState();
}

class _AppointmentConsultationSectionState
    extends State<_AppointmentConsultationSection> {
  ConsultationProjection? _projection;
  String? _error;
  bool _loading = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _AppointmentConsultationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appointment.id != widget.appointment.id ||
        oldWidget.repository != widget.repository) {
      _projection = null;
      _load();
    }
  }

  Future<void> _load() async {
    final repository = widget.repository;
    if (repository == null || _loading) {
      return;
    }
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final loaded = await repository.projection(
        appointmentId: widget.appointment.id,
      );
      if (mounted && generation == _generation) {
        setState(() => _projection = loaded);
      }
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(() {
          _error = safeConsultationFailure(error);
        });
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _generation++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projection = _projection;
    final mode = projection?.mode ?? widget.appointment.consultationMode;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDDE8E5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  mode == ConsultationMode.audio
                      ? Icons.call_outlined
                      : mode == ConsultationMode.video
                      ? Icons.videocam_outlined
                      : Icons.medical_services_outlined,
                  color: CarenetColors.brand,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    mode == ConsultationMode.audio
                        ? 'Audio consultation'
                        : mode == ConsultationMode.video
                        ? 'Video consultation'
                        : 'Consultation',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (_loading)
                  const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              projection == null
                  ? _error ?? 'Checking secure consultation access...'
                  : _consultationEntryCopy(context, projection),
              style: const TextStyle(color: CarenetColors.neutral600),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _loading ? null : _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry access check'),
              ),
            ],
            if (projection != null &&
                (projection.canEnterWaitingRoom ||
                    projection.canJoin ||
                    projection.canRejoin ||
                    projection.canAdmit ||
                    projection.patientWaiting ||
                    projection.reviewRequired)) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('appointment-join-consultation'),
                onPressed:
                    () => Navigator.of(context).pushNamed(
                      RouteName.consultation,
                      arguments: ConsultationRouteArgs(
                        appointmentId: widget.appointment.id,
                      ),
                    ),
                icon: Icon(
                  mode == ConsultationMode.audio ? Icons.call : Icons.videocam,
                ),
                label: const Text('Open consultation'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _consultationEntryCopy(
  BuildContext context,
  ConsultationProjection projection,
) {
  if (projection.reviewRequired) {
    return 'This consultation needs review. You can open it to report an issue.';
  }
  if (projection.isTerminal) {
    return 'The live consultation window is closed.';
  }
  if (projection.patientWaiting && projection.canAdmit) {
    return 'The patient is waiting. Open the consultation when you are ready to admit them.';
  }
  if (projection.canJoin || projection.canRejoin) {
    return projection.canRejoin
        ? 'The secure consultation can be rejoined.'
        : 'The secure consultation is ready to join.';
  }
  if (projection.canEnterWaitingRoom) {
    return 'The waiting room is open.';
  }
  final reason = projection.blockingReason;
  if (reason == 'JOIN_WINDOW_NOT_OPEN') {
    final opensAt = projection.joinOpensAt;
    if (opensAt == null) {
      return 'The waiting room opens 10 minutes before the appointment.';
    }
    final local = opensAt.toLocal();
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(local);
    final time = localizations.formatTimeOfDay(TimeOfDay.fromDateTime(local));
    return 'The waiting room opens $date at $time (your time).';
  }
  if (reason == 'JOIN_WINDOW_CLOSED') {
    return 'The consultation access window has closed.';
  }
  if (reason == 'PAYMENT_REQUIRED' || reason?.startsWith('PAYMENT_') == true) {
    return 'Payment must be completed before consultation access opens.';
  }
  if (reason == 'APPOINTMENT_REQUESTED') {
    return 'Consultation access opens after the professional accepts the request and payment is completed.';
  }
  return 'Consultation access is controlled by the appointment status and schedule.';
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
    final counterpart = appointment.counterpartDisplayName(
      professionalViewer: role == AppointmentViewerRole.professional,
    );
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
    final counterpart = appointment.counterpartDisplayName(
      professionalViewer: role == AppointmentViewerRole.professional,
    );
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

class _AppointmentPaymentSection extends StatelessWidget {
  const _AppointmentPaymentSection({
    required this.appointment,
    required this.role,
    required this.controller,
  });

  final AppointmentSummary appointment;
  final AppointmentViewerRole role;
  final AppointmentPaymentController controller;

  @override
  Widget build(BuildContext context) {
    final pricing = controller.view?.pricing ?? appointment.pricing;
    final payment = controller.view?.payment ?? appointment.payment;
    if (pricing == null && payment == null && controller.isLoading) {
      return const _StatePanel(
        icon: Icons.payments_outlined,
        title: 'Loading payment status',
        body: 'Checking the authoritative consultation payment.',
      );
    }
    if (pricing == null && payment == null) {
      return _StatePanel(
        icon: Icons.payments_outlined,
        title: 'Payment not yet available',
        body:
            controller.errorMessage ??
            'A payment contract has not been created for this appointment.',
        actionLabel: controller.errorMessage == null ? null : 'Retry',
        onAction: controller.errorMessage == null ? null : controller.load,
      );
    }

    final professional = role == AppointmentViewerRole.professional;
    return Container(
      key: const Key('appointment-payment-section'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CarenetColors.neutral100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E8E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payments_outlined, color: CarenetColors.brand),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Consultation payment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: 'Refresh payment status',
                onPressed:
                    controller.isLoading ||
                            controller.isRefreshing ||
                            controller.isInitializing
                        ? null
                        : () => controller.load(refreshProvider: true),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (pricing != null) ...[
            const SizedBox(height: 8),
            _PaymentMetric(
              label: professional ? 'Patient price' : 'Amount',
              value: formatNgnMinor(pricing.grossAmountMinor),
            ),
            if (professional && pricing.professionalNetMinor != null)
              _PaymentMetric(
                label: 'Your net after commission',
                value: formatNgnMinor(pricing.professionalNetMinor!),
                strong: true,
              ),
          ],
          if (payment != null) ...[
            const SizedBox(height: 10),
            _PaymentStatusBox(payment: payment, professional: professional),
          ],
          if (controller.actionMessage != null)
            _InlineNotice(message: controller.actionMessage!, positive: true),
          if (controller.errorMessage != null)
            _InlineNotice(message: controller.errorMessage!),
          if (!professional && controller.canPay) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('appointment-pay-now'),
                onPressed:
                    controller.isInitializing ? null : controller.beginCheckout,
                icon:
                    controller.isInitializing
                        ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.open_in_new),
                label: Text(
                  controller.isInitializing
                      ? 'Opening secure payment...'
                      : 'Pay now',
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Payment opens in Paystack. CareNet never handles card details.',
              style: TextStyle(color: CarenetColors.neutral600, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentMetric extends StatelessWidget {
  const _PaymentMetric({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentStatusBox extends StatelessWidget {
  const _PaymentStatusBox({required this.payment, required this.professional});

  final AppointmentPayment payment;
  final bool professional;

  @override
  Widget build(BuildContext context) {
    final label = _paymentStatusLabel(payment.status);
    final explanation = _paymentStatusExplanation(
      payment,
      professional: professional,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(explanation),
          if (payment.status == AppointmentPaymentStatus.awaitingPayment) ...[
            const SizedBox(height: 4),
            Text(
              'Pay by ${_appointmentDate(payment.dueAt)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
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

String _paymentStatusLabel(AppointmentPaymentStatus status) {
  return switch (status) {
    AppointmentPaymentStatus.awaitingPayment => 'PAYMENT DUE',
    AppointmentPaymentStatus.processing => 'PAYMENT PROCESSING',
    AppointmentPaymentStatus.succeeded => 'PAID',
    AppointmentPaymentStatus.expired => 'PAYMENT WINDOW EXPIRED',
    AppointmentPaymentStatus.refundPending => 'REFUND PENDING',
    AppointmentPaymentStatus.refunded => 'REFUNDED',
    AppointmentPaymentStatus.disputed => 'PAYMENT DISPUTED',
    AppointmentPaymentStatus.reversed => 'PAYMENT REVERSED',
    AppointmentPaymentStatus.reviewRequired => 'PAYMENT UNDER REVIEW',
    AppointmentPaymentStatus.unknown => 'PAYMENT STATUS UNAVAILABLE',
  };
}

String _paymentStatusExplanation(
  AppointmentPayment payment, {
  required bool professional,
}) {
  return switch (payment.status) {
    AppointmentPaymentStatus.awaitingPayment =>
      professional
          ? 'Waiting for the patient to complete payment. This consultation is not financially confirmed.'
          : 'The appointment was accepted, but it is not confirmed until payment succeeds.',
    AppointmentPaymentStatus.processing =>
      'Payment is being verified. Refresh before attempting another payment.',
    AppointmentPaymentStatus.succeeded =>
      payment.consultationConfirmed
          ? 'Payment was verified and the consultation is confirmed.'
          : 'Payment was received. Consultation eligibility is being reviewed.',
    AppointmentPaymentStatus.expired =>
      'The payment deadline passed. A new checkout cannot be started.',
    AppointmentPaymentStatus.refundPending =>
      'A full refund is being processed.',
    AppointmentPaymentStatus.refunded =>
      'The consultation payment was refunded.',
    AppointmentPaymentStatus.disputed =>
      'This payment is disputed. Related earnings remain held.',
    AppointmentPaymentStatus.reversed =>
      'The payment was reversed. It is not available as earnings.',
    AppointmentPaymentStatus.reviewRequired =>
      'Payment arrived after the eligible window and requires review. The consultation is not confirmed.',
    AppointmentPaymentStatus.unknown =>
      'The current payment state could not be interpreted safely.',
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
