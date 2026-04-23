import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationCenterPage extends StatefulWidget {
  final VoidCallback? onBackTap;

  const NotificationCenterPage({super.key, this.onBackTap});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  static const List<String> _tabs = [
    'All',
    'Events',
    'Appointment',
    'Messages',
    'Payment',
  ];

  late String _selectedTab;

  final List<_NotificationItemData> _items = const [
    _NotificationItemData(
      icon: Icons.calendar_today_outlined,
      title: 'Your appointment is booked',
      subtitle: 'See details',
    ),
    _NotificationItemData(
      icon: Icons.calendar_month_outlined,
      title: '360 Club event is coming up today by 6pm',
      subtitle: 'You subscribed to this event. See details to not miss it',
      isHighlighted: true,
    ),
    _NotificationItemData(
      icon: Icons.cake_outlined,
      title: 'It\'s Dr. Uzo\'s Birthday today.',
      subtitle: 'Wish her well!',
    ),
    _NotificationItemData(
      icon: Icons.people_outline,
      title: '5 Specialists are having free consultations now',
      subtitle: 'Take advantage',
    ),
    _NotificationItemData(
      icon: Icons.info_outline,
      title: 'Your emergency request is approved.',
      subtitle: 'Ambulance is on the way!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedTab = 'Events';
  }

  void _handleBack() {
    if (widget.onBackTap != null) {
      widget.onBackTap!();
      return;
    }

    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: REdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                IconButton(
                  onPressed: _handleBack,
                  icon: const Icon(Icons.arrow_back, color: AppColors.kBlack),
                ),
                Expanded(
                  child: Text(
                    'Notifications',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      fontSize: FontSizes.footer2,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryBlue5,
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: AppColors.blue02,
                  child: const Icon(
                    Icons.person_outline,
                    color: AppColors.primaryBlue6,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48.h,
            child: ListView.separated(
              padding: REdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (_, __) => SizedBox(width: 16.w),
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isSelected = _selectedTab == tab;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTab = tab;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tab,
                        style: TextStyle(
                          fontFamily: AppFonts.montserrat,
                          fontSize: FontSizes.footer4,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w400,
                          color:
                              isSelected
                                  ? AppColors.primaryBlue5
                                  : AppColors.white06,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 2.h,
                        width: 42.w,
                        color:
                            isSelected
                                ? AppColors.primaryBlue5
                                : Colors.transparent,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: REdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              itemCount: _items.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final item = _items[index];
                return Container(
                  padding: REdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        item.isHighlighted
                            ? const Color(0xFFD5E4F8)
                            : const Color(0xFFF5F5FA),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 32.h,
                        width: 32.w,
                        decoration: BoxDecoration(
                          color: AppColors.kWhite,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          item.icon,
                          size: 18,
                          color: AppColors.white06,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontFamily: AppFonts.montserrat,
                                fontSize: FontSizes.footer3,
                                fontWeight: FontWeight.w500,
                                color: AppColors.white06,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              item.subtitle,
                              style: TextStyle(
                                fontFamily: AppFonts.montserrat,
                                fontSize: FontSizes.footer4,
                                fontWeight: FontWeight.w400,
                                color: AppColors.white04,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isHighlighted;

  const _NotificationItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isHighlighted = false,
  });
}
