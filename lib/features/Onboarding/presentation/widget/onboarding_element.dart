import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingElement extends StatelessWidget {
  final String assetName;
  final String title;
  final String subTitle;
  const OnboardingElement({
    required this.assetName,
    required this.title,
    required this.subTitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RPadding(
      padding: REdgeInsets.only(top: .15.sh),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgImage(width: .65.sw, height: .23.sh, imgName: assetName),
          SizedBox(height: .1.sh),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              color: AppColors.kBlack,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            subTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.kBlack,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
