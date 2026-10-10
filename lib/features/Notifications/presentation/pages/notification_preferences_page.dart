import 'package:app_t/core/di/injection.dart';
import 'package:app_t/features/Notifications/data/repositories/notification_repository.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/notification_models.dart';
import '../state/notification_inbox_controller.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key, this.repository});

  final NotificationRepository? repository;

  @override
  State<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  late final NotificationPreferencesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotificationPreferencesController(
      repository: widget.repository ?? sl<NotificationRepository>(),
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
      appBar: AppBar(title: const Text('Notification preferences')),
      body: SafeArea(
        top: false,
        child:
            _controller.isLoading && _controller.preferences.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: _controller.load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                    children: [
                      const Text(
                        'Your CareNet inbox always keeps transactional updates. These settings control additional push and email delivery.',
                      ),
                      if (_controller.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _controller.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed:
                              _controller.isLoading ? null : _controller.load,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry loading preferences'),
                        ),
                      ],
                      const SizedBox(height: 18),
                      ..._controller.preferences.map(_preferenceSection),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _preferenceSection(NotificationPreference preference) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFDCE8E6)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                preference.category.label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Push'),
                value: preference.pushEnabled,
                onChanged:
                    _controller.isSaving
                        ? null
                        : (value) => _controller.update(
                          preference.category,
                          pushEnabled: value,
                        ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Email'),
                value: preference.emailEnabled,
                onChanged:
                    _controller.isSaving
                        ? null
                        : (value) => _controller.update(
                          preference.category,
                          emailEnabled: value,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
