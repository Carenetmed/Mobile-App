import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';

class MessageCardWidget extends StatelessWidget {
  final String name;
  final String profession;
  final String avatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final bool isDark;
  final VoidCallback onTap;

  const MessageCardWidget({
    super.key,
    required this.name,
    required this.profession,
    required this.avatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE8F4F8),
                    border: Border.all(
                      color: Color(0xFFD0E8F2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      avatar,
                      style: TextStyle(fontSize: 28.sp),
                    ),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14.w,
                      height: 14.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4CAF50),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontFamily: AppFonts.montserrat,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.kBlack
                                    : AppColors.kBlack,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              profession,
                              style: TextStyle(
                                fontFamily: AppFonts.montserrat,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? AppColors.white04
                                    : AppColors.white04,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _formatTime(lastMessageTime),
                        style: TextStyle(
                          fontFamily: AppFonts.montserrat,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: isDark ? AppColors.white05 : AppColors.white05,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppFonts.montserrat,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? AppColors.white05
                                : AppColors.white05,
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed5,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: TextStyle(
                              fontFamily: AppFonts.montserrat,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}
