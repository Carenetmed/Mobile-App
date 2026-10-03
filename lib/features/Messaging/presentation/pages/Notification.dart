// ignore_for_file: file_names

import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/features/Notifications/data/repositories/notification_repository.dart';
import 'package:app_t/features/Notifications/data/services/firebase_notification_transport.dart';
import 'package:app_t/features/Notifications/domain/entities/notification_models.dart';
import 'package:app_t/features/Notifications/presentation/state/notification_coordinator.dart';
import 'package:app_t/features/Notifications/presentation/state/notification_inbox_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, this.repository, this.coordinator});

  final NotificationRepository? repository;
  final NotificationCoordinator? coordinator;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationCoordinator _coordinator;
  late final NotificationInboxController _controller;

  @override
  void initState() {
    super.initState();
    _coordinator = widget.coordinator ?? sl<NotificationCoordinator>();
    _controller = NotificationInboxController(
      repository: widget.repository ?? sl<NotificationRepository>(),
      coordinator: _coordinator,
    )..addListener(_refresh);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Notifications'),
        actions: [
          if (_controller.items.any((item) => !item.isRead))
            IconButton(
              tooltip: 'Mark all as read',
              onPressed:
                  _controller.isMutating ? null : _controller.markAllRead,
              icon: const Icon(Icons.done_all),
            ),
          IconButton(
            tooltip: 'Notification preferences',
            onPressed:
                () => Navigator.pushNamed(
                  context,
                  RouteName.notificationPreferences,
                ),
            icon: const Icon(Icons.tune),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(top: false, child: _body()),
    );
  }

  Widget _body() {
    if (_controller.isLoading && _controller.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.errorMessage != null && _controller.items.isEmpty) {
      return _StateMessage(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load notifications',
        message: _controller.errorMessage!,
        actionLabel: 'Retry',
        onAction: _controller.load,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _controller.load(refresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _PermissionPanel(coordinator: _coordinator),
          if (_controller.errorMessage != null) ...[
            const SizedBox(height: 12),
            _InlineMessage(message: _controller.errorMessage!),
          ],
          const SizedBox(height: 18),
          if (_controller.items.isEmpty)
            const _EmptyInbox()
          else
            ..._controller.items.map(
              (notification) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _NotificationRow(
                  notification: notification,
                  onTap: () => _controller.open(notification),
                ),
              ),
            ),
          if (_controller.hasMore) ...[
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed:
                  _controller.isLoadingMore ? null : _controller.loadMore,
              icon:
                  _controller.isLoadingMore
                      ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.expand_more),
              label: const Text('Load older notifications'),
            ),
          ],
        ],
      ),
    );
  }
}

class _PermissionPanel extends StatelessWidget {
  const _PermissionPanel({required this.coordinator});

  final NotificationCoordinator coordinator;

  @override
  Widget build(BuildContext context) {
    if (!coordinator.pushConfigured ||
        coordinator.permission == NotificationPermissionValue.authorized ||
        coordinator.permission == NotificationPermissionValue.provisional) {
      return const SizedBox.shrink();
    }
    final denied = coordinator.permission == NotificationPermissionValue.denied;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE9F5F3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC6E2DD)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.notifications_active_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    denied ? 'Push notifications are off' : 'Stay updated',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    denied
                        ? 'Your CareNet inbox still works. Enable notifications in system settings when you want alerts.'
                        : 'Allow CareNet to alert you about appointments, messages, consultations, payments, and account security.',
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: denied
                        ? coordinator.openPermissionSettings
                        : coordinator.requestPermission,
                    icon: Icon(
                      denied
                          ? Icons.settings_outlined
                          : Icons.notifications_outlined,
                    ),
                    label: Text(
                      denied ? 'Open system settings' : 'Allow notifications',
                    ),
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

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.notification, required this.onTap});

  final CareNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notification.isRead ? Colors.white : const Color(0xFFF0F8F7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFDCE8E6)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _categoryColor(notification.category),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_categoryIcon(notification.category), size: 21),
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
                            notification.title,
                            style: TextStyle(
                              fontWeight:
                                  notification.isRead
                                      ? FontWeight.w600
                                      : FontWeight.w800,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Semantics(
                            label: 'Unread',
                            excludeSemantics: true,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue11,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(notification.body),
                    const SizedBox(height: 8),
                    Text(
                      '${notification.category.label} | ${_formatTime(notification.latestOccurredAt)}${notification.occurrenceCount > 1 ? ' | ${notification.occurrenceCount} updates' : ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    final now = DateTime.now();
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return DateFormat.jm().format(local);
    }
    return DateFormat('d MMM, h:mm a').format(local);
  }

  IconData _categoryIcon(NotificationCategory category) => switch (category) {
    NotificationCategory.appointments => Icons.event_note_outlined,
    NotificationCategory.messages => Icons.chat_bubble_outline,
    NotificationCategory.consultations => Icons.video_call_outlined,
    NotificationCategory.payments => Icons.receipt_long_outlined,
    NotificationCategory.earningsAndPayouts => Icons.account_balance_outlined,
    NotificationCategory.accountAndSecurity => Icons.shield_outlined,
    NotificationCategory.professionalVerification => Icons.verified_outlined,
  };

  Color _categoryColor(NotificationCategory category) => switch (category) {
    NotificationCategory.appointments => const Color(0xFFE8EEFF),
    NotificationCategory.messages => const Color(0xFFE9F5F3),
    NotificationCategory.consultations => const Color(0xFFF0EAFE),
    NotificationCategory.payments => const Color(0xFFFFF3D8),
    NotificationCategory.earningsAndPayouts => const Color(0xFFE7F4EA),
    NotificationCategory.accountAndSecurity => const Color(0xFFFDE8E8),
    NotificationCategory.professionalVerification => const Color(0xFFE8F5EC),
  };
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 72, horizontal: 16),
      child: Column(
        children: [
          Icon(Icons.notifications_none, size: 48),
          SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            'CareNet appointment and account updates will appear here.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
