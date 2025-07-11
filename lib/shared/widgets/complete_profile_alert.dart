import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompleteProfileAlert extends StatefulWidget {
  CompleteProfileAlert({super.key});

  @override
  State<CompleteProfileAlert> createState() => _CompleteProfileAlertState();
}

class _CompleteProfileAlertState extends State<CompleteProfileAlert> {
  bool profileCompleted = true;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: profileCompleted,
      child: Container(
        padding: REdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
        width: double.infinity,
        color: AppColors.primaryBlue11,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Please complete your info.',
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w500,
                fontSize: FontSizes.footer2,
                color: AppColors.kWhite,
              ),
            ),

            InkWell(
              onTap: () {
                setState(() {
                  profileCompleted = !profileCompleted;
                });
              },
              child: Container(
                padding: REdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue5,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'Okay',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    color: AppColors.white01,
                    fontWeight: FontWeight.w500,
                    fontSize: FontSizes.footer3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
