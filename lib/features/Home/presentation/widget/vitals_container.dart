import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VitalsContainer extends StatelessWidget {
  final String title;
  final String reading;
  final Widget suffixIcon;
  final VoidCallback? onTap;
  const VitalsContainer({
    super.key,
    required this.title,
    required this.reading,
    required this.suffixIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        height: 198.h,
        width: 196.w,
        padding: REdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(width: .5, color: AppColors.primaryBlue1),
          color: AppColors.kWhite,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: FontSizes.footer2,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white06,
                    ),
                  ),
                ),
                suffixIcon,
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              reading,
              style: TextStyle(
                fontSize: FontSizes.body3,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue10,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Tap to view more details',
              style: TextStyle(
                fontSize: FontSizes.footer3,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w400,
                color: AppColors.white05,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
