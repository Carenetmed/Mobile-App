import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VitalsBox extends StatelessWidget {
  final double? height;
  final void Function()? btnAction;
  const VitalsBox({super.key, required this.btnAction, this.height});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: btnAction,
      child: Container(
        height: height,
        padding: REdgeInsets.symmetric(horizontal: 25),
        margin: REdgeInsets.only(right: 7),
        decoration: BoxDecoration(
          border: Border.all(width: .5),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryBlue7,
                borderRadius: BorderRadius.circular(15),
              ),

              child: Icon(Icons.add, color: AppColors.primaryRed7),
            ),
            SizedBox(height: 4.h),
            Text(
              textAlign: TextAlign.center,
              'Add new\nReadings',
              style: TextStyle(
                color: AppColors.kBlack,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w500,
                fontSize: FontSizes.footer4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
