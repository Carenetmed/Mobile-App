// ignore_for_file: file_names

import 'dart:async';

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/presentation/carenet_presentation.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Messaging/data/repositories/messaging_repository.dart';
import 'package:app_t/features/Messaging/data/services/messaging_realtime_client.dart';
import 'package:app_t/features/Messaging/domain/entities/messaging_models.dart';
import 'package:app_t/features/Messaging/presentation/state/messaging_controllers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({
    super.key,
    this.embedded = false,
    this.repository,
    this.realtime,
  });

  final bool embedded;
  final MessagingRepository? repository;
  final MessagingRealtimeConnection? realtime;

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with WidgetsBindingObserver {
  ConversationListController? _controller;
  MessagingRealtimeConnection? _realtime;
  StreamSubscription<MessagingRealtimeHint>? _hintSubscription;
  StreamSubscription<bool>? _stateSubscription;
  StreamSubscription<MessagingRealtimeIdentity>? _recoverySubscription;
  Timer? _recoveryCooldown;
  bool _recovering = false;
  int _lifecycleVersion = 0;
  bool _backgrounded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final repository =
        widget.repository ??
        (sl.isRegistered<MessagingRepository>()
            ? sl<MessagingRepository>()
            : null);
    if (repository != null) {
      _controller =
          ConversationListController(repository: repository)
            ..addListener(_onChanged)
            ..load();
      _startRealtime(repository);
    }
  }

  Future<void> _startRealtime(MessagingRepository repository) async {
    try {
      final session = await repository.requireSession();
      final identity = session.realtimeIdentity;
      if (!mounted || identity == null) {
        return;
      }
      final realtime = widget.realtime ?? sl<MessagingRealtimeConnection>();
      _realtime = realtime;
      _hintSubscription = realtime.hints.listen((_) {
        if (mounted && !_backgrounded) {
          _controller?.load(refresh: true);
        }
      });
      _stateSubscription = realtime.connectionState.listen((connected) {
        if (mounted && !_backgrounded && connected) {
          _controller?.load(refresh: true);
        }
      });
      _recoverySubscription = realtime.recoveryRequests.listen((expected) {
        if (expected.matches(identity)) {
          unawaited(_recoverThroughHttp(repository, expected));
        }
      });
      if (_backgrounded) await realtime.suspend();
      if (!mounted) return;
      await realtime.start(identity);
    } catch (_) {
      // HTTP remains authoritative through resume and explicit refresh.
    }
  }

  Future<void> _recoverThroughHttp(
    MessagingRepository repository,
    MessagingRealtimeIdentity expected,
  ) async {
    if (!mounted || _backgrounded || _recovering || _recoveryCooldown != null) {
      return;
    }
    _recovering = true;
    final version = _lifecycleVersion;
    _recoveryCooldown = Timer(const Duration(seconds: 30), () {
      _recoveryCooldown = null;
    });
    try {
      final session = await repository.requireSession().timeout(
        const Duration(seconds: 5),
      );
      if (!mounted ||
          _backgrounded ||
          version != _lifecycleVersion ||
          session.realtimeIdentity?.matches(expected) != true) {
        return;
      }
      // Repository HTTP execution owns 401 refresh and all account authority.
      await _controller?.load(refresh: true);
    } catch (_) {
      // Explicit refresh/resume remain available; never infer a session failure.
    } finally {
      _recovering = false;
    }
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onAppResumed();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _backgrounded = true;
      _lifecycleVersion++;
      _recoveryCooldown?.cancel();
      _recoveryCooldown = null;
      _realtime?.suspend();
    }
  }

  Future<void> _onAppResumed() async {
    _backgrounded = false;
    await _controller?.load(refresh: true);
    if (mounted && !_backgrounded) {
      await _realtime?.resume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hintSubscription?.cancel();
    _stateSubscription?.cancel();
    _recoverySubscription?.cancel();
    _recoveryCooldown?.cancel();
    _lifecycleVersion++;
    _realtime?.dispose();
    _controller
      ?..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar:
          widget.embedded
              ? null
              : AppBar(
                backgroundColor: Colors.white,
                foregroundColor: CarenetColors.black,
                elevation: 0,
                title: const Text('Messages'),
              ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh:
              controller == null
                  ? () async {}
                  : () => controller.load(refresh: true),
          child: ListView(
            key: const Key('conversation-list'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
            children: [
              _header(),
              const SizedBox(height: 18),
              if (controller == null)
                const _StatePanel(
                  key: Key('messages-empty'),
                  icon: Icons.forum_outlined,
                  title: 'No appointment conversations yet',
                  body:
                      'Conversations appear here after an eligible appointment is accepted.',
                )
              else if (controller.isLoading)
                const _StatePanel(
                  key: Key('messages-loading'),
                  icon: Icons.sync,
                  title: 'Loading conversations',
                  body: 'Checking your appointment conversations.',
                )
              else if (controller.conversations.isEmpty)
                _emptyOrError(controller)
              else ...[
                if (controller.isRefreshing)
                  const LinearProgressIndicator(minHeight: 2),
                if (controller.errorMessage != null)
                  _InlineNotice(
                    message:
                        '${controller.errorMessage} Your previous conversations remain visible.',
                  ),
                ...controller.conversations.map(_conversationCard),
                if (controller.hasMore)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: OutlinedButton.icon(
                      key: const Key('messages-load-more'),
                      onPressed:
                          controller.isLoadingMore ? null : controller.loadMore,
                      icon: const Icon(Icons.expand_more),
                      label: Text(
                        controller.isLoadingMore
                            ? 'Loading conversations...'
                            : 'Load earlier conversations',
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final controller = _controller;
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Messages',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4),
              Text(
                'Private conversations linked to your appointments.',
                style: TextStyle(color: CarenetColors.neutral600),
              ),
            ],
          ),
        ),
        IconButton(
          key: const Key('messages-refresh'),
          tooltip: 'Refresh conversations',
          onPressed:
              controller == null ||
                      controller.isLoading ||
                      controller.isRefreshing
                  ? null
                  : () => controller.load(refresh: true),
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _emptyOrError(ConversationListController controller) {
    final error = controller.errorMessage;
    if (error != null) {
      return _StatePanel(
        key: const Key('messages-error'),
        icon: Icons.cloud_off_outlined,
        title: 'Conversations unavailable',
        body: error,
        actionLabel: 'Retry',
        onAction: controller.load,
      );
    }
    return const _StatePanel(
      key: Key('messages-empty'),
      icon: Icons.forum_outlined,
      title: 'No appointment conversations yet',
      body:
          'Conversations appear here after an eligible appointment is accepted.',
    );
  }

  Widget _conversationCard(ConversationSummary conversation) {
    final message = conversation.lastMessage;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          key: Key('conversation-${conversation.conversationId}'),
          borderRadius: BorderRadius.circular(8),
          onTap:
              conversation.isReadableLifecycle
                  ? () => Navigator.of(context).pushNamed(
                    RouteName.chat,
                    arguments: AppointmentConversationRouteArgs(
                      conversationId: conversation.conversationId,
                      appointmentId: conversation.appointmentId,
                    ),
                  )
                  : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFE8F3EF),
                  foregroundColor: const Color(0xFF176B55),
                  child: Text(
                    _initials(conversation.counterpart.displayName),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.counterpart.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _relativeTime(conversation.lastActivityAt),
                            style: const TextStyle(
                              color: CarenetColors.neutral600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_roleLabel(conversation.counterpart.role)} | ${_statusLabel(conversation.appointmentStatus)}',
                        style: const TextStyle(
                          color: Color(0xFF176B55),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              message?.preview ??
                                  'No messages have been sent yet.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color:
                                    message == null
                                        ? CarenetColors.neutral600
                                        : CarenetColors.black,
                              ),
                            ),
                          ),
                          if (conversation.unreadCount > 0) ...[
                            const SizedBox(width: 10),
                            Container(
                              key: Key(
                                'conversation-unread-${conversation.conversationId}',
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                              ),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Color(0xFF176B55),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                conversation.unreadCount > 99
                                    ? '99+'
                                    : '${conversation.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({
    super.key,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3E9E6)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: const Color(0xFF176B55)),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: CarenetColors.neutral600),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(message),
    );
  }
}

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty);
  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}

String _roleLabel(String role) {
  return role.toUpperCase() == 'PROFESSIONAL' ? 'Professional' : 'Patient';
}

String _statusLabel(String status) {
  return switch (status.toUpperCase()) {
    'ACCEPTED' => 'Accepted appointment',
    'COMPLETED' => 'Completed appointment',
    'REQUESTED' => 'Awaiting acceptance',
    'CANCELLED' => 'Cancelled appointment',
    _ => 'Appointment',
  };
}

String _relativeTime(DateTime value) {
  final local = value.toLocal();
  final now = DateTime.now();
  if (DateUtils.isSameDay(local, now)) {
    return DateFormat('h:mm a', CareNetPresentation.dateLocale).format(local);
  }
  if (local.year == now.year) {
    return DateFormat('d MMM', CareNetPresentation.dateLocale).format(local);
  }
  return DateFormat('d MMM y', CareNetPresentation.dateLocale).format(local);
}
