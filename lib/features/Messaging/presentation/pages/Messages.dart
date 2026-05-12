import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

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
        title: Text(
          'Messages',
          style: TextStyle(
            color: AppColors.primaryBlue5,
            fontFamily: AppFonts.montserrat,
            fontSize: FontSizes.body3,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: REdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16.r,
              backgroundImage: const AssetImage(AssetsImages.profileHandle),
            ),
          ),
        ],
      ),
      body: const MessagesTabContent(embedded: false),
    );
  }
}

class MessagesTabContent extends StatefulWidget {
  const MessagesTabContent({super.key, required this.embedded});

  final bool embedded;

  @override
  State<MessagesTabContent> createState() => _MessagesTabContentState();
}

class _MessagesTabContentState extends State<MessagesTabContent> {
  String _selectedTab = 'Messages';

  final List<String> _tabs = const [
    'All',
    'Events',
    'Appointment',
    'Messages',
    'Payment',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: widget.embedded ? 8.h : 0),
        SizedBox(
          height: 42.h,
          child: ListView.separated(
            padding: REdgeInsets.symmetric(
              horizontal: widget.embedded ? 2 : 12,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: _tabs.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final tab = _tabs[index];
              final isSelected = _selectedTab == tab;
              return InkWell(
                borderRadius: BorderRadius.circular(999.r),
                onTap: () => setState(() => _selectedTab = tab),
                child: Container(
                  padding: REdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.primaryBlue5
                            : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    tab,
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      fontSize: FontSizes.footer2,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.kWhite : AppColors.white06,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView(
            padding: REdgeInsets.fromLTRB(
              widget.embedded ? 2 : 12,
              14,
              widget.embedded ? 2 : 12,
              24,
            ),
            children: [
              _MessageCard(
                onTap: () {
                  Navigator.of(context).pushNamed(RouteName.message);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: REdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.kWhite,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE9EEF5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundImage: const AssetImage(AssetsImages.profileHandle),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. Lagbaja has replied your message.',
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      fontSize: FontSizes.footer1,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white06,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Reply him now',
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      fontSize: FontSizes.footer2,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white04,
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
