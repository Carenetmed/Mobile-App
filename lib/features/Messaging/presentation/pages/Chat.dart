// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ChatPageVariant { seededConversation, unavailableNotice }

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    this.variant = ChatPageVariant.seededConversation,
  });

  final ChatPageVariant variant;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final TextEditingController _messageController;

  bool get _showsConversation =>
      widget.variant == ChatPageVariant.seededConversation;

  bool get _showsUnavailableNotice =>
      widget.variant == ChatPageVariant.unavailableNotice;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFD1D5DB),
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text(
              'Dr. Uzo',
              style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.41,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _showsUnavailableNotice
                    ? _buildUnavailableNotice()
                    : _buildConversationBody(),
          ),
          _buildMessageInputBar(),
          _buildHomeIndicator(),
        ],
      ),
    );
  }

  Widget _buildConversationBody() {
    if (!_showsConversation) {
      return const SizedBox();
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Hello Dr. Uzo Amaka.\nHow are you doing today?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.41,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Read 08:08PM',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Hello Dr. Uzo Amaka,\nHow are you doing today?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.41,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '09:08PM Read',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnavailableNotice() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black,
              fontFamily: 'SF Pro Text',
              letterSpacing: -0.3,
            ),
            children: [
              TextSpan(
                text:
                    'Dr. Uzo is currently not available. You may not receive replies to your messages on time your messages be left unattended to.\n',
              ),
              TextSpan(text: 'For quick replies, you may want to do '),
              TextSpan(
                text: 'express contact',
                style: TextStyle(
                  color: Color(0xFF007AFF),
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
              TextSpan(text: ' or check Dr. Uzo\'s\n'),
              TextSpan(
                text: 'schedule',
                style: TextStyle(
                  color: Color(0xFF007AFF),
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
              TextSpan(text: ' for available Date'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 0.5)),
      ),
      child: Row(
        children: [
          _buildHoverableIconButton(
            icon: Icons.emoji_emotions_outlined,
            tooltip: 'Emoji unavailable until messaging is connected',
          ),
          const SizedBox(width: 12),
          _buildHoverableIconButton(
            icon: Icons.attach_file,
            isRotated: true,
            tooltip: 'Attachments unavailable until messaging is connected',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: false,
              decoration: InputDecoration(
                hintText: 'Message',
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.41,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
              ),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.41,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildHoverableIconButton(
            icon: Icons.camera_alt_outlined,
            tooltip: 'Camera unavailable until messaging is connected',
          ),
          const SizedBox(width: 12),
          _buildHoverableIconButton(
            icon: Icons.mic_none,
            tooltip: 'Voice messages unavailable until messaging is connected',
          ),
        ],
      ),
    );
  }

  Widget _buildHoverableIconButton({
    required IconData icon,
    required String tooltip,
    VoidCallback? onPressed,
    bool isRotated = false,
  }) {
    final iconColor = onPressed == null ? Colors.black26 : Colors.black;
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor:
            onPressed == null
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click,
        child: InkWell(
          onTap: onPressed,
          splashColor: Colors.transparent,
          hoverColor: Colors.grey[200]?.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child:
                isRotated
                    ? Transform.rotate(
                      angle: 0.785398,
                      child: Icon(icon, color: iconColor, size: 26),
                    )
                    : Icon(icon, color: iconColor, size: 26),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeIndicator() {
    return Container(
      height: 5,
      width: 134,
      margin: const EdgeInsets.only(bottom: 8, top: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
