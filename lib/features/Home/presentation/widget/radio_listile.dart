// ignore_for_file: deprecated_member_use

import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomRadioListTile extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final void Function(String?) onChanged;
  const CustomRadioListTile({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RPadding(
      padding: REdgeInsets.only(bottom: 8.0),
      child: ListTile(
        contentPadding: REdgeInsets.only(right: 14, left: 16),
        tileColor: AppColors.blue02,
        title: Text(
          title,
          style: TextStyle(
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w500,
            fontSize: FontSizes.footer2,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
        trailing: Container(
          height: 36.h,
          width: 43.w,
          // padding: EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.kWhite,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Radio(
            value: value,
            activeColor: AppColors.primaryBlue6,
            fillColor: WidgetStatePropertyAll(AppColors.primaryBlue6),
            groupValue: groupValue,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
