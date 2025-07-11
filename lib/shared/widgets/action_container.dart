import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/model/action_item_model.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActionContainer extends StatefulWidget {
  const ActionContainer({super.key});

  @override
  State<ActionContainer> createState() => _ActionContainerState();
}

class _ActionContainerState extends State<ActionContainer> {
  final List<ActionItem> actionItems = [
    ActionItem(
      text: 'Find a Mentor',
      assetPath: AssetsIcon.search,
      actButton: null,
    ),
    ActionItem(
      text: 'Professional\nDevelopment',
      assetPath: AssetsIcon.person,
      actButton: null,
    ),
    ActionItem(
      text: 'Live Session',
      assetPath: AssetsIcon.live,
      actButton: null,
    ),
    ActionItem(
      text: 'Messages',
      assetPath: AssetsIcon.message,
      actButton: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: .1.sh,
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: actionItems.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: actionItems[index].actButton,
            child: Container(
              // height: 98.h,
              width: 98.w,
              padding: REdgeInsets.symmetric(horizontal: 3),
              margin: REdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: AppColors.primaryBlue1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgImage(imgName: actionItems[index].assetPath),
                    SizedBox(height: 3.h),
                    Text(
                      textAlign: TextAlign.center,
                      actionItems[index].text,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: FontSizes.footer2,
                        fontFamily: AppFonts.montserrat,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
