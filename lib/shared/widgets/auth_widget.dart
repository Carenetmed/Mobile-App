import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
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
    final isEnabled = btnAction != null;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: title,
      onTap: btnAction,
      excludeSemantics: true,
      child: Opacity(
        opacity: isEnabled ? 1 : 0.55,
        child: InkWell(
          onTap: btnAction,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 48),
            padding: REdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            margin: REdgeInsets.only(bottom: 15.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                width: 1,
                color:
                    isEnabled ? CarenetColors.brand : CarenetColors.neutral500,
              ),
            ),
            child: Row(
              children: [
                SvgImage(imgName: assetPath),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: FontSizes.body3,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w400,
                      color:
                          isEnabled
                              ? CarenetColors.brand
                              : CarenetColors.neutral500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
