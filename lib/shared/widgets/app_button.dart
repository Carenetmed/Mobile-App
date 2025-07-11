import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarenetButtonFilled extends StatelessWidget {
  final VoidCallback btnAction;
  final String btnName;

  const CarenetButtonFilled(
      {required this.btnAction, required this.btnName, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: btnAction,
      child: Container(
        height: 48.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue6,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            btnName,
            style: TextStyle(
              fontSize: FontSizes.body3,
              color: AppColors.kWhite,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class CarenetButtonOutline extends StatelessWidget {
  final VoidCallback btnAction;
  final String btnName;
  const CarenetButtonOutline(
      {required this.btnAction, required this.btnName, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: btnAction,
      child: Container(
        height: 48.h,
        width: double.infinity,
        decoration: BoxDecoration(
            color: AppColors.kWhite,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all( width: 1)),
        child: Center(
          child: Text(
            btnName,
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
