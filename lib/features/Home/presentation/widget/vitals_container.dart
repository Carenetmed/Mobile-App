import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VitalsContainer extends StatelessWidget {
  final String title;
  final String reading;
  final Widget suffixIcon;
  const VitalsContainer({
    super.key,
    required this.title,
    required this.reading,
    required this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 198.h,
      width: 196.w,
      padding: REdgeInsets.symmetric(horizontal: 7.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.r),
        border: Border.all(width: .5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: FontSizes.footer2,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white06,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              suffixIcon,
              // SvgImage(imgName: AssetsIcon.mail)
            ],
          ),
          SizedBox(height: 5.h),
          Text(
            reading,
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.white06,
            ),
          ),
        ],
      ),
    );
  }
}
