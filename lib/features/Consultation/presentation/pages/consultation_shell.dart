import 'dart:async';

import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Consultation/data/repositories/consultation_repository.dart';
import 'package:app_t/features/Consultation/data/services/livekit_rtc_room_adapter.dart';
import 'package:app_t/features/Consultation/domain/entities/consultation_entities.dart';
import 'package:app_t/features/Consultation/domain/services/consultation_permission_service.dart';
import 'package:app_t/features/Consultation/domain/services/rtc_room_adapter.dart';
import 'package:app_t/features/Consultation/presentation/state/consultation_controller.dart';
import 'package:app_t/features/Consultation/presentation/widgets/rtc_video_view.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:flutter/material.dart';

class ConsultationRouteArgs {
  const ConsultationRouteArgs({required this.appointmentId});

  final String appointmentId;
}

class ConsultationShellPage extends StatefulWidget {
  const ConsultationShellPage({
    required this.appointmentId,
    this.repository,
    this.sessionStore,
    this.permissionService,
    this.room,
    this.controller,
    super.key,
  });

  final String? appointmentId;
  final ConsultationGateway? repository;
  final SessionStore? sessionStore;
  final ConsultationPermissionService? permissionService;
  final RtcRoomAdapter? room;
  final ConsultationController? controller;

  @override
  State<ConsultationShellPage> createState() => _ConsultationShellPageState();
}

class _ConsultationShellPageState extends State<ConsultationShellPage>
    with WidgetsBindingObserver {
  ConsultationController? _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final id = widget.appointmentId?.trim() ?? '';
    _ownsController = widget.controller == null;
    if (widget.controller != null) {
      _controller = widget.controller;
    } else if (id.isNotEmpty) {
      _controller = ConsultationController(
        appointmentId: id,
        repository: widget.repository ?? sl<ConsultationRepository>(),
        sessionStore: widget.sessionStore ?? sl<SessionStore>(),
        permissionService:
            widget.permissionService ?? sl<ConsultationPermissionService>(),
        room: widget.room ?? LiveKitRtcRoomAdapter(),
      );
    }
    _controller
      ?..addListener(_onChanged)
      ..initialize();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_controller?.onAppResumed());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.removeListener(_onChanged);
    if (_ownsController) {
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final active = controller?.isConnected == true;
    return PopScope(
      canPop: !active,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && controller != null) {
          await _confirmLeave(controller);
        }
      },
      child: Scaffold(
        backgroundColor: active ? const Color(0xFF0B1514) : CarenetColors.white,
        appBar:
            active
                ? null
                : AppBar(
                  title: const Text('Consultation'),
                  backgroundColor: CarenetColors.white,
                  foregroundColor: CarenetColors.black,
                  elevation: 0,
                  actions: [
                    if (controller != null)
                      IconButton(
                        tooltip: 'Refresh consultation',
                        onPressed:
                            controller.isLoading ||
                                    controller.isRefreshing ||
                                    controller.isActing
                                ? null
                                : controller.refresh,
                        icon: const Icon(Icons.refresh),
                      ),
                  ],
                ),
        body: SafeArea(
          child:
              controller == null
                  ? _Unavailable(onBack: () => Navigator.maybePop(context))
                  : _body(controller),
        ),
      ),
    );
  }

  Widget _body(ConsultationController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.projection == null) {
      return _Unavailable(
        message:
            controller.errorMessage ?? 'This consultation could not be loaded.',
        onRetry: controller.refresh,
        onBack: () => Navigator.maybePop(context),
      );
    }
    if (controller.isConnected) {
      return _ActiveConsultation(
        controller: controller,
        onLeave: () => _confirmLeave(controller),
        onEnd: () => _confirmEnd(controller),
        onReport: () => _reportIncident(controller),
      );
    }
    return _PreJoin(
      controller: controller,
      onReport: () => _reportIncident(controller),
    );
  }

  Future<void> _confirmLeave(ConsultationController controller) async {
    final leave = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Leave consultation?'),
            content: const Text(
              'You can rejoin while the backend consultation window remains open.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Stay'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Leave'),
              ),
            ],
          ),
    );
    if (leave == true) {
      await controller.leave();
      if (mounted) {
        Navigator.maybePop(context);
      }
    }
  }

  Future<void> _confirmEnd(ConsultationController controller) async {
    final end = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('End consultation?'),
            content: const Text(
              'This ends the live session for both participants. It does not complete the appointment automatically.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep session open'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('End session'),
              ),
            ],
          ),
    );
    if (end == true) {
      await controller.endConsultation();
    }
  }

  Future<void> _reportIncident(ConsultationController controller) async {
    var category = ConsultationIncidentCategory.couldNotConnect;
    final description = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Report consultation issue'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<ConsultationIncidentCategory>(
                        initialValue: category,
                        decoration: const InputDecoration(labelText: 'Issue'),
                        items:
                            ConsultationIncidentCategory.values
                                .where(
                                  (item) =>
                                      item !=
                                      ConsultationIncidentCategory.unknown,
                                )
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(_incidentLabel(item)),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => category = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: description,
                        maxLength: 500,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Details (optional)',
                          helperText: 'Do not include medical information.',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Send report'),
                    ),
                  ],
                ),
          ),
    );
    if (submitted == true) {
      await controller.reportIncident(
        category: category,
        description: description.text,
      );
    }
    description.dispose();
  }
}

class _PreJoin extends StatelessWidget {
  const _PreJoin({required this.controller, required this.onReport});

  final ConsultationController controller;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final projection = controller.projection!;
    final isVideo = controller.mode == ConsultationMode.video;
    final isPatient =
        controller.viewerRole == ConsultationParticipantRole.patient;
    final waiting = isPatient && projection.patientWaiting;
    final canJoin = projection.canJoin || projection.canRejoin;

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          if (controller.isRefreshing)
            const LinearProgressIndicator(minHeight: 2),
          Text(
            isVideo ? 'Video consultation' : 'Audio consultation',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            _windowCopy(projection),
            style: const TextStyle(color: CarenetColors.neutral600),
          ),
          const SizedBox(height: 8),
          _ConsultationCountdown(projection: projection, active: false),
          const SizedBox(height: 20),
          if (isVideo)
            AspectRatio(
              aspectRatio: 16 / 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ColoredBox(
                  color: const Color(0xFF142320),
                  child: RtcVideoView(
                    track: controller.room.localVideo,
                    mirror: true,
                    placeholder: const Center(
                      child: Icon(
                        Icons.person_outline,
                        size: 64,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          _StatusCard(
            icon:
                waiting
                    ? Icons.hourglass_top
                    : projection.patientWaiting
                    ? Icons.person_pin_circle_outlined
                    : Icons.health_and_safety_outlined,
            title:
                waiting
                    ? 'Waiting for the professional'
                    : projection.patientWaiting
                    ? 'Patient is waiting'
                    : _statusTitle(projection),
            body:
                waiting
                    ? 'Keep this screen open. You can join after the professional admits you.'
                    : projection.patientWaiting
                    ? 'Review your setup, then admit the patient when you are ready.'
                    : _blockingCopy(projection.blockingReason),
          ),
          if (controller.errorMessage != null) ...[
            const SizedBox(height: 12),
            _Notice(controller.errorMessage!),
          ],
          if (controller.actionMessage != null) ...[
            const SizedBox(height: 12),
            _Notice(controller.actionMessage!, positive: true),
          ],
          if (controller.incidentMessage != null) ...[
            const SizedBox(height: 12),
            _Notice(controller.incidentMessage!),
          ],
          const SizedBox(height: 18),
          if (controller.permissions?.microphoneReady != true)
            FilledButton.icon(
              key: const Key('consultation-prepare-media'),
              onPressed:
                  controller.isPreparing || !controller.canPrepare
                      ? null
                      : controller.prepareMedia,
              icon: const Icon(Icons.tune),
              label: Text(
                controller.isPreparing
                    ? 'Checking device...'
                    : 'Check camera and microphone',
              ),
            ),
          if (controller.permissions?.microphone ==
              ConsultationPermissionState.permanentlyDenied)
            TextButton(
              onPressed: controller.openSettings,
              child: const Text('Open app settings'),
            ),
          if (controller.permissions?.microphoneReady == true) ...[
            _MediaControls(controller: controller, compact: false),
            const SizedBox(height: 12),
          ],
          if (isVideo &&
              controller.permissions != null &&
              controller.permissions?.cameraReady != true) ...[
            const _Notice(
              'Camera is unavailable. You may continue with audio in this video consultation.',
              positive: true,
            ),
            if (controller.permissions?.camera ==
                ConsultationPermissionState.permanentlyDenied)
              TextButton(
                onPressed: controller.openSettings,
                child: const Text('Enable camera in settings'),
              ),
            const SizedBox(height: 8),
          ],
          if (isPatient &&
              projection.canEnterWaitingRoom &&
              !projection.patientWaiting)
            FilledButton.icon(
              key: const Key('consultation-enter-waiting'),
              onPressed:
                  controller.isActing ? null : controller.enterWaitingRoom,
              icon: const Icon(Icons.meeting_room_outlined),
              label: const Text('Enter waiting room'),
            ),
          if (!isPatient && projection.canAdmit)
            FilledButton.icon(
              key: const Key('consultation-admit-patient'),
              onPressed: controller.isActing ? null : controller.admitPatient,
              icon: const Icon(Icons.how_to_reg_outlined),
              label: const Text('Admit patient'),
            ),
          if (canJoin && controller.permissions?.microphoneReady == true)
            FilledButton.icon(
              key: const Key('consultation-join'),
              onPressed: controller.isActing ? null : controller.join,
              icon: Icon(isVideo ? Icons.videocam : Icons.call),
              label: Text(
                controller.isActing
                    ? 'Connecting...'
                    : projection.canRejoin
                    ? 'Rejoin consultation'
                    : 'Join consultation',
              ),
            ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: controller.isReporting ? null : onReport,
            icon: const Icon(Icons.report_problem_outlined),
            label: const Text('Report a connection issue'),
          ),
        ],
      ),
    );
  }
}

class _ActiveConsultation extends StatelessWidget {
  const _ActiveConsultation({
    required this.controller,
    required this.onLeave,
    required this.onEnd,
    required this.onReport,
  });

  final ConsultationController controller;
  final VoidCallback onLeave;
  final VoidCallback onEnd;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final isVideo = controller.mode == ConsultationMode.video;
    final isProfessional =
        controller.viewerRole == ConsultationParticipantRole.professional;
    return Stack(
      children: [
        Positioned.fill(
          child:
              isVideo
                  ? RtcVideoView(
                    track: controller.room.remoteVideo,
                    placeholder: _RemotePlaceholder(
                      present: controller.room.remoteParticipantPresent,
                    ),
                  )
                  : _AudioStage(
                    present: controller.room.remoteParticipantPresent,
                  ),
        ),
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LiveStatus(
                      reconnecting:
                          controller.room.connectionState ==
                          RtcConnectionState.reconnecting,
                      participantPresent:
                          controller.room.remoteParticipantPresent,
                    ),
                    const SizedBox(height: 6),
                    _ConsultationCountdown(
                      projection: controller.projection!,
                      active: true,
                    ),
                    if (controller.room.remoteParticipantPresent) ...[
                      const SizedBox(height: 6),
                      _RemoteMediaStatus(
                        microphoneEnabled:
                            controller.room.remoteMicrophoneEnabled,
                        cameraEnabled:
                            !isVideo || controller.room.remoteCameraEnabled,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Report issue',
                onPressed: onReport,
                icon: const Icon(Icons.report_problem_outlined),
              ),
            ],
          ),
        ),
        if (isVideo)
          Positioned(
            right: 14,
            bottom: 116,
            width: 112,
            height: 156,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ColoredBox(
                color: const Color(0xFF22312F),
                child: RtcVideoView(
                  track: controller.room.localVideo,
                  mirror: true,
                ),
              ),
            ),
          ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 16,
          child: _CallControls(
            controller: controller,
            endLabel: isProfessional ? 'End' : 'Leave',
            onEnd: isProfessional ? onEnd : onLeave,
          ),
        ),
      ],
    );
  }
}

class _MediaControls extends StatelessWidget {
  const _MediaControls({required this.controller, required this.compact});

  final ConsultationController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final video = controller.mode == ConsultationMode.video;
    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: [
        FilterChip(
          key: const Key('consultation-microphone-toggle'),
          selected: controller.microphoneEnabled,
          onSelected: controller.setMicrophoneEnabled,
          avatar: Icon(
            controller.microphoneEnabled ? Icons.mic : Icons.mic_off,
            size: 18,
          ),
          label: Text(controller.microphoneEnabled ? 'Mic on' : 'Mic off'),
        ),
        if (video)
          FilterChip(
            key: const Key('consultation-camera-toggle'),
            selected: controller.cameraEnabled,
            onSelected: controller.setCameraEnabled,
            avatar: Icon(
              controller.cameraEnabled ? Icons.videocam : Icons.videocam_off,
              size: 18,
            ),
            label: Text(controller.cameraEnabled ? 'Camera on' : 'Camera off'),
          ),
        if (video && controller.cameraEnabled)
          IconButton(
            tooltip: 'Switch camera',
            onPressed: controller.switchCamera,
            icon: const Icon(Icons.cameraswitch_outlined),
          ),
      ],
    );
  }
}

class _CallControls extends StatelessWidget {
  const _CallControls({
    required this.controller,
    required this.endLabel,
    required this.onEnd,
  });

  final ConsultationController controller;
  final String endLabel;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xE61A2423),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _CallButton(
              label: controller.microphoneEnabled ? 'Mute' : 'Unmute',
              icon: controller.microphoneEnabled ? Icons.mic : Icons.mic_off,
              onPressed:
                  () => controller.setMicrophoneEnabled(
                    !controller.microphoneEnabled,
                  ),
            ),
            if (controller.mode == ConsultationMode.video)
              _CallButton(
                label: controller.cameraEnabled ? 'Camera off' : 'Camera on',
                icon:
                    controller.cameraEnabled
                        ? Icons.videocam
                        : Icons.videocam_off,
                onPressed:
                    () =>
                        controller.setCameraEnabled(!controller.cameraEnabled),
              ),
            _CallButton(
              label: controller.room.speakerEnabled ? 'Speaker' : 'Earpiece',
              icon:
                  controller.room.speakerEnabled
                      ? Icons.volume_up
                      : Icons.hearing,
              onPressed:
                  () => controller.setSpeakerEnabled(
                    !controller.room.speakerEnabled,
                  ),
            ),
            _CallButton(
              label: endLabel,
              icon: Icons.call_end,
              destructive: true,
              onPressed: onEnd,
            ),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.filled(
            tooltip: label,
            style: IconButton.styleFrom(
              backgroundColor:
                  destructive ? const Color(0xFFD84545) : Colors.white12,
              foregroundColor: Colors.white,
            ),
            onPressed: onPressed,
            icon: Icon(icon),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _LiveStatus extends StatelessWidget {
  const _LiveStatus({
    required this.reconnecting,
    required this.participantPresent,
  });

  final bool reconnecting;
  final bool participantPresent;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xD916211F),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            reconnecting
                ? 'Reconnecting securely...'
                : participantPresent
                ? 'Consultation in progress'
                : 'Waiting for the other participant',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _RemoteMediaStatus extends StatelessWidget {
  const _RemoteMediaStatus({
    required this.microphoneEnabled,
    required this.cameraEnabled,
  });

  final bool microphoneEnabled;
  final bool cameraEnabled;

  @override
  Widget build(BuildContext context) {
    final messages = <String>[
      if (!microphoneEnabled) 'Other participant muted',
      if (!cameraEnabled) 'Other participant camera off',
    ];
    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xD916211F),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            messages.join(' | '),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

class _RemotePlaceholder extends StatelessWidget {
  const _RemotePlaceholder({required this.present});

  final bool present;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0B1514),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundColor: Color(0xFF203A35),
              child: Icon(Icons.person_outline, size: 54, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              present ? 'Camera is off' : 'Waiting for the other participant',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioStage extends StatelessWidget {
  const _AudioStage({required this.present});

  final bool present;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0B1514),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 58,
              backgroundColor: Color(0xFF1F5147),
              child: Icon(Icons.call, size: 52, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              present ? 'Connected' : 'Waiting for the other participant',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E9E7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: CarenetColors.brand),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: const TextStyle(color: CarenetColors.neutral600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.message, {this.positive = false});

  final String message;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: positive ? const Color(0xFFEAF7F1) : const Color(0xFFFFF2EA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(padding: const EdgeInsets.all(12), child: Text(message)),
    );
  }
}

class _ConsultationCountdown extends StatefulWidget {
  const _ConsultationCountdown({
    required this.projection,
    required this.active,
  });

  final ConsultationProjection projection;
  final bool active;

  @override
  State<_ConsultationCountdown> createState() => _ConsultationCountdownState();
}

class _ConsultationCountdownState extends State<_ConsultationCountdown> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target =
        widget.active
            ? widget.projection.scheduledEndsAt
            : widget.projection.joinOpensAt;
    if (target == null) {
      return const SizedBox.shrink();
    }
    final difference = target.difference(_now.toUtc());
    final past = difference.isNegative;
    final absolute = past ? -difference : difference;
    final hours = absolute.inHours;
    final minutes = absolute.inMinutes.remainder(60);
    final seconds = absolute.inSeconds.remainder(60);
    final value =
        hours > 0
            ? '${hours}h ${minutes}m'
            : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final text =
        widget.active
            ? past
                ? 'Scheduled time ended. Backend grace rules still apply.'
                : 'Scheduled time remaining: $value'
            : past
            ? 'The scheduled join opening time has arrived.'
            : 'Waiting room opens in $value';
    return Semantics(
      liveRegion: true,
      label: text,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.active ? const Color(0xD916211F) : Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Text(
            text,
            style: TextStyle(
              color: widget.active ? Colors.white : CarenetColors.neutral600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({this.message, this.onRetry, required this.onBack});

  final String? message;
  final VoidCallback? onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              message ?? 'A valid appointment is required.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (onRetry != null)
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            TextButton(onPressed: onBack, child: const Text('Back')),
          ],
        ),
      ),
    );
  }
}

String _windowCopy(ConsultationProjection projection) {
  final opens = projection.joinOpensAt;
  final closes = projection.closesAt;
  if (opens == null || closes == null) {
    return 'Access follows the appointment consultation window.';
  }
  final localOpens = opens.toLocal();
  final localCloses = closes.toLocal();
  return 'Join access is controlled by the appointment schedule (${_date(localOpens)} to ${_date(localCloses)}).';
}

String _date(DateTime value) {
  final local = value.toLocal();
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day}/${local.month}/${local.year} ${local.hour}:$minute';
}

String _statusTitle(ConsultationProjection projection) {
  if (projection.reviewRequired) {
    return 'Consultation needs review';
  }
  if (projection.isTerminal) {
    return 'Consultation closed';
  }
  if (projection.canJoin || projection.canRejoin) {
    return 'Ready to join';
  }
  return 'Consultation not open yet';
}

String _blockingCopy(String? reason) {
  if (reason == null || reason.isEmpty) {
    return 'Refresh near the appointment time to check access.';
  }
  if (reason == 'JOIN_WINDOW_NOT_OPEN') {
    return 'The waiting room opens 10 minutes before the appointment.';
  }
  if (reason == 'JOIN_WINDOW_CLOSED') {
    return 'The consultation access window has closed.';
  }
  if (reason.startsWith('PAYMENT_') || reason == 'PAYMENT_REQUIRED') {
    return 'Payment must be completed before this consultation can begin.';
  }
  if (reason.startsWith('APPOINTMENT_')) {
    return 'The appointment status does not currently allow consultation access.';
  }
  if (reason.startsWith('SESSION_')) {
    return 'The consultation session is not currently available.';
  }
  return 'Consultation access is not currently available.';
}

String _incidentLabel(ConsultationIncidentCategory category) {
  return switch (category) {
    ConsultationIncidentCategory.couldNotConnect => 'Could not connect',
    ConsultationIncidentCategory.microphonePermission =>
      'Microphone permission',
    ConsultationIncidentCategory.cameraPermission => 'Camera permission',
    ConsultationIncidentCategory.noAudio => 'No audio',
    ConsultationIncidentCategory.noVideo => 'No video',
    ConsultationIncidentCategory.disconnectedRepeatedly =>
      'Repeated disconnection',
    ConsultationIncidentCategory.otherParticipantAbsent =>
      'Other participant absent',
    ConsultationIncidentCategory.endedUnexpectedly => 'Ended unexpectedly',
    ConsultationIncidentCategory.unknown => 'Other issue',
  };
}
