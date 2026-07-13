import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeMessagesTab extends StatelessWidget {
  const HomeMessagesTab({super.key});

  static const List<_MessagePreview> _items = [
    _MessagePreview(
      sender: 'Dr. Lagbaja',
      subject: 'Reply to your care plan question',
      preview:
          'I reviewed your last update. Let us keep monitoring for 48 hours.',
      timeLabel: '2m ago',
      unread: true,
    ),
    _MessagePreview(
      sender: 'Early Riser Elite Club',
      subject: 'New circle update',
      preview:
          'The breathing-session notes are ready for everyone in the group.',
      timeLabel: '1h ago',
      unread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: REdgeInsets.only(top: 12.h, bottom: 24.h),
      itemCount: _items.length + 1,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _HomeTabIntro(
            title: 'Messages at a glance',
            body:
                'Recent conversations appear here so the Home tab stays useful even before live messaging data is connected.',
            actionLabel: 'Open full inbox',
            onPressed: () {
              Navigator.pushNamed(context, RouteName.messages);
            },
          );
        }

        final item = _items[index - 1];
        return InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            Navigator.pushNamed(context, RouteName.messages);
          },
          child: Container(
            padding: REdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.kWhite,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.white04),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.sender,
                        style: TextStyle(
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w600,
                          fontSize: FontSizes.footer2,
                          color: AppColors.kBlack,
                        ),
                      ),
                    ),
                    Text(
                      item.timeLabel,
                      style: TextStyle(
                        fontFamily: AppFonts.montserrat,
                        fontWeight: FontWeight.w400,
                        fontSize: FontSizes.footer3,
                        color: AppColors.primaryBlue11,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  item.subject,
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w600,
                    fontSize: FontSizes.body3,
                    color: AppColors.kBlack,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  item.preview,
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w400,
                    fontSize: FontSizes.footer2,
                    color: AppColors.primaryBlue11,
                    height: 1.4,
                  ),
                ),
                if (item.unread) ...[
                  SizedBox(height: 10.h),
                  Container(
                    padding: REdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue5.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      'Unread',
                      style: TextStyle(
                        fontFamily: AppFonts.montserrat,
                        fontWeight: FontWeight.w500,
                        fontSize: FontSizes.footer3,
                        color: AppColors.primaryBlue5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeTabIntro extends StatelessWidget {
  const _HomeTabIntro({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w600,
              fontSize: FontSizes.body3,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            body,
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              fontSize: FontSizes.footer2,
              color: AppColors.primaryBlue11,
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onPressed,
              child: Text(
                actionLabel,
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w600,
                  fontSize: FontSizes.footer2,
                  color: AppColors.primaryBlue5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessagePreview {
  const _MessagePreview({
    required this.sender,
    required this.subject,
    required this.preview,
    required this.timeLabel,
    required this.unread,
  });

  final String sender;
  final String subject;
  final String preview;
  final String timeLabel;
  final bool unread;
}
