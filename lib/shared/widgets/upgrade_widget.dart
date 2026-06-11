import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UpgradeWidget extends StatelessWidget {
  const UpgradeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: .31.sh,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: .25.sh,
            width: double.infinity,
            color: AppColors.white06,
            child: Image.asset(fit: BoxFit.contain, AssetsImages.upgrade),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: REdgeInsets.all(8),
              margin: REdgeInsets.only(right: 6, top: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppColors.primaryBlue5,
              ),
              child: Text(
                'Upgrade Now',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  color: AppColors.white01,
                  fontWeight: FontWeight.w500,
                  fontSize: FontSizes.body3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
