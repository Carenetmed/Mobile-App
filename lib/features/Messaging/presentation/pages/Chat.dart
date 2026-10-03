// ignore_for_file: file_names

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/features/Messaging/data/repositories/messaging_repository.dart';
import 'package:app_t/features/Messaging/data/services/messaging_realtime_client.dart';
import 'package:app_t/features/Messaging/domain/entities/messaging_models.dart';
import 'package:app_t/features/Messaging/presentation/state/messaging_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.arguments, this.repository, this.realtime});

  final AppointmentConversationRouteArgs? arguments;
  final MessagingRepository? repository;
  final MessagingRealtimeConnection? realtime;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  AppointmentChatController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final args = widget.arguments;
    if (args != null) {
      _controller = AppointmentChatController(
        repository: widget.repository ?? sl<MessagingRepository>(),
        realtime:
            widget.realtime ??
            MessagingRealtimeClient(config: sl<CareNetApiConfig>()),
        conversationId: args.conversationId,
        appointmentId: args.appointmentId,
      )..addListener(_onChanged);
      _controller!.load();
    }
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller?.markVisibleRead();
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller?.onAppResumed();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller
      ?..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final counterpart = controller?.counterpart;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title:
            counterpart == null
                ? const Text('Appointment conversation')
                : _ConversationTitle(
                  participant: counterpart,
                  connected: controller?.realtimeConnected == true,
                ),
        actions: [
          if (controller?.summary?.appointmentId != null)
            IconButton(
              key: const Key('chat-open-appointment'),
              tooltip: 'Open appointment',
              onPressed:
                  () => Navigator.of(context).pushNamed(
                    RouteName.appointmentDetail,
                    arguments: controller!.summary!.appointmentId,
                  ),
              icon: const Icon(Icons.event_note_outlined),
            ),
        ],
      ),
      body:
          controller == null
              ? _Unavailable(onBack: () => Navigator.of(context).maybePop())
              : _body(controller),
    );
  }

  Widget _body(AppointmentChatController controller) {
    if (controller.isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text('Loading conversation'),
          ],
        ),
      );
    }
    if (controller.detail == null || controller.currentUserId == null) {
      return _Unavailable(
        message:
            controller.errorMessage ??
            'This appointment conversation is unavailable.',
        onRetry: controller.load,
        onBack: () => Navigator.of(context).maybePop(),
      );
    }

    return Column(
      children: [
        if (controller.isRefreshing)
          const LinearProgressIndicator(minHeight: 2),
        if (controller.errorMessage != null)
          _Notice(message: controller.errorMessage!),
        if (!controller.writable)
          _Notice(
            key: const Key('chat-read-only'),
            message: controller.readOnlyReason,
            icon: Icons.lock_outline,
          ),
        if (controller.hasMoreBefore)
          TextButton.icon(
            key: const Key('chat-load-older'),
            onPressed: controller.isLoadingOlder ? null : controller.loadOlder,
            icon: const Icon(Icons.expand_less),
            label: Text(
              controller.isLoadingOlder
                  ? 'Loading earlier messages...'
                  : 'Load earlier messages',
            ),
          ),
        Expanded(
          child: Chat(
            currentUserId: controller.currentUserId!,
            resolveUser:
                (id) async => User(id: id, name: _nameFor(id, controller)),
            chatController: controller.flyerController,
            onMessageSend: controller.writable ? controller.send : null,
            backgroundColor: const Color(0xFFF7F9F8),
            builders: Builders(
              composerBuilder:
                  (_) =>
                      controller.writable
                          ? Composer(
                            hintText: 'Message about this appointment',
                            sendButtonVisibilityMode:
                                SendButtonVisibilityMode.disabled,
                            sendButtonDisabled: controller.isSending,
                            attachmentIcon: const SizedBox.shrink(),
                            gap: 0,
                          )
                          : _ReadOnlyComposer(
                            reason: controller.readOnlyReason,
                          ),
              emptyChatListBuilder:
                  (_) => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No messages yet. Keep this conversation focused on the appointment.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              textMessageBuilder:
                  (
                    context,
                    message,
                    index, {
                    required isSentByMe,
                    groupStatus,
                  }) => _TextBubble(
                    message: message,
                    sentByMe: isSentByMe,
                    onRetry:
                        message.status == MessageStatus.error
                            ? () {
                              final clientMessageId =
                                  message.metadata?['clientMessageId'];
                              if (clientMessageId is String) {
                                controller.retry(clientMessageId);
                              }
                            }
                            : null,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  String _nameFor(String id, AppointmentChatController controller) {
    if (id == controller.currentUserId) {
      return 'You';
    }
    return controller.counterpart?.displayName ?? 'Appointment participant';
  }
}

class _ConversationTitle extends StatelessWidget {
  const _ConversationTitle({
    required this.participant,
    required this.connected,
  });

  final MessagingParticipant participant;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: const Color(0xFFE8F3EF),
          child: Text(
            participant.displayName.trim().isEmpty
                ? '?'
                : participant.displayName.trim()[0].toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF176B55),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                participant.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                connected ? 'Live updates connected' : 'Recovering updates',
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyComposer extends StatelessWidget {
  const _ReadOnlyComposer({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        color: Colors.white,
        child: Row(
          children: [
            const Icon(Icons.lock_outline, size: 18),
            const SizedBox(width: 9),
            Expanded(child: Text(reason)),
          ],
        ),
      ),
    );
  }
}

class _TextBubble extends StatelessWidget {
  const _TextBubble({
    required this.message,
    required this.sentByMe,
    this.onRetry,
  });

  final TextMessage message;
  final bool sentByMe;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final status = message.status;
    final statusLabel = switch (status) {
      MessageStatus.sending => 'Sending',
      MessageStatus.error => 'Not sent',
      MessageStatus.seen => 'Seen',
      _ => null,
    };
    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        child: Column(
          crossAxisAlignment:
              sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color:
                    sentByMe
                        ? const Color(0xFF176B55)
                        : const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(8),
                border:
                    sentByMe
                        ? null
                        : Border.all(color: const Color(0xFFE1E7E4)),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: sentByMe ? Colors.white : Colors.black,
                  height: 1.35,
                ),
              ),
            ),
            if (statusLabel != null)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(statusLabel, style: const TextStyle(fontSize: 11)),
              ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: const Color(0xFFFFF7E5),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 9),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({
    required this.onBack,
    this.message = 'A valid appointment conversation is required.',
    this.onRetry,
  });

  final String message;
  final VoidCallback onBack;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.forum_outlined, size: 44),
            const SizedBox(height: 14),
            const Text(
              'Conversation unavailable',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                if (onRetry != null)
                  FilledButton(onPressed: onRetry, child: const Text('Retry')),
                OutlinedButton(
                  onPressed: onBack,
                  child: const Text('Back to messages'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
