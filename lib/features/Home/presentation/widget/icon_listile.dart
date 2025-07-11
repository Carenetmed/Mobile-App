import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IconListile extends StatelessWidget {
  final void Function()? btnAction;
  final String assetPath;
  final String label;
  const IconListile({
    super.key,
    required this.assetPath,
    required this.label,
    this.btnAction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: btnAction,
      child: RPadding(
        padding: REdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgImage(imgName: assetPath),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                fontSize: FontSizes.footer1,
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.montserrat,
                color: AppColors.white06,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
