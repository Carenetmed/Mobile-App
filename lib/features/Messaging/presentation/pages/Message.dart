import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: AppColors.kWhite,
        surfaceTintColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.kBlack, size: 24),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16.r,
              backgroundImage: const AssetImage(AssetsImages.profileHandle),
            ),
            SizedBox(width: 8.w),
            Text(
              'Dr. Lagbaja',
              style: TextStyle(
                color: AppColors.white06,
                fontFamily: AppFonts.montserrat,
                fontSize: FontSizes.footer1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: REdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: const [
                _MessageBubble(
                  text: 'Hello Dr. Lagbaja.\nHow are you doing today?',
                  metadata: 'Read 08:08PM',
                  fromDoctor: false,
                ),
                _MessageBubble(
                  text:
                      'Hello. I am doing well.\nPlease let me know how I can help.',
                  metadata: '09:08PM Read',
                  fromDoctor: true,
                ),
              ],
            ),
          ),
          _MessageInputBar(controller: _messageController),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.text,
    required this.metadata,
    required this.fromDoctor,
  });

  final String text;
  final String metadata;
  final bool fromDoctor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromDoctor ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: REdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment:
              fromDoctor ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: 0.72.sw),
              padding: REdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color:
                    fromDoctor
                        ? const Color(0xFFF2EAFE)
                        : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: AppColors.white06,
                  fontFamily: AppFonts.montserrat,
                  fontSize: FontSizes.footer2,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                textAlign: fromDoctor ? TextAlign.right : TextAlign.left,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              metadata,
              style: TextStyle(
                color: AppColors.white04,
                fontFamily: AppFonts.montserrat,
                fontSize: FontSizes.footer3,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  const _MessageInputBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.fromLTRB(8, 8, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_emotions_outlined, color: AppColors.kBlack),
          SizedBox(width: 12.w),
          Transform.rotate(
            angle: 0.785398,
            child: const Icon(Icons.attach_file, color: AppColors.kBlack),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Message',
                hintStyle: TextStyle(
                  color: AppColors.white04,
                  fontFamily: AppFonts.montserrat,
                  fontSize: FontSizes.footer2,
                ),
                contentPadding: REdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          const Icon(Icons.camera_alt_outlined, color: AppColors.kBlack),
          SizedBox(width: 12.w),
          const Icon(Icons.mic_none, color: AppColors.kBlack),
        ],
      ),
    );
  }
}

class ChatPageUnavailable extends StatelessWidget {
  const ChatPageUnavailable({super.key});

  @override
  Widget build(BuildContext context) {
    return const MessagePage();
  }
}
