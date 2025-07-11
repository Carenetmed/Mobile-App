import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthWidget extends StatelessWidget {
  final void Function()? btnAction;
  final String assetPath;
  final String title;
  const AuthWidget({
    super.key,
    this.btnAction,
    required this.assetPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: btnAction,
      child: Container(
        padding: REdgeInsets.symmetric(horizontal: 6.w, vertical: 13.h),
        margin: REdgeInsets.only(bottom: 15.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgImage(imgName: assetPath),
            Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: FontSizes.body3,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryBlue11,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
