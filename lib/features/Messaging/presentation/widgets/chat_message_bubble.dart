import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';

class ChatMessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime timestamp;
  final bool isDark;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.timestamp,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 0.75.sw,
          ),
          decoration: BoxDecoration(
            color: isMe
                ? AppColors.primaryBlue6
                : isDark
                    ? Color(0xFFF0F0F0)
                    : Color(0xFFF5F5F5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
              bottomLeft: Radius.circular(isMe ? 12.r : 0),
              bottomRight: Radius.circular(isMe ? 0 : 12.r),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message,
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: isMe ? Colors.white : AppColors.kBlack,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w300,
                  color: isMe ? Colors.white70 : AppColors.white04,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
