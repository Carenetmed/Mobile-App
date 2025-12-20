import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- The Page Widget (Empty Chat with Dr. Uzo) ---
class ChatPageEmpty extends StatefulWidget {
  const ChatPageEmpty({super.key});

  @override
  State<ChatPageEmpty> createState() => _ChatPageEmptyState();
}

class _ChatPageEmptyState extends State<ChatPageEmpty> {
  late TextEditingController _messageController;

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () {},
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
          const Expanded(child: SizedBox()),
          _buildMessageInputBar(),
          _buildHomeIndicator(),
        ],
      ),
    );
  }

  Widget _buildMessageInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _buildHoverableIconButton(
            icon: Icons.emoji_emotions_outlined,
            onPressed: () {},
          ),
          const SizedBox(width: 12),
          _buildHoverableIconButton(
            icon: Icons.attach_file,
            isRotated: true,
            onPressed: () {},
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Message',
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.41,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
            onPressed: () {},
          ),
          const SizedBox(width: 12),
          _buildHoverableIconButton(
            icon: Icons.mic_none,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHoverableIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isRotated = false,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onPressed,
        splashColor: Colors.transparent,
        hoverColor: Colors.grey[200]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: isRotated
              ? Transform.rotate(
                  angle: 0.785398, // 45 degrees in radians
                  child: Icon(icon, color: Colors.black, size: 26),
                )
              : Icon(icon, color: Colors.black, size: 26),
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
