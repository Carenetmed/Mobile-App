import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/shared/widgets/app_button.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MedicalAgreement extends StatelessWidget {
  const MedicalAgreement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RPadding(
          padding: REdgeInsets.only(top: .11.sh, left: 21.w, right: 22.w),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgImage(
                  width: 80.w,
                  height: 80.h,
                  imgName: AssetsImages.pinStack,
                ),
                SizedBox(height: .05.sh),
                Text(
                  'Thank you for choosing to care!',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Are you a medical\nprofessional?',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    fontSize: 24.sp,
                  ),
                ),
                SizedBox(height: .06.sh),
                Text(
                  'We would like to know if you work in any\nmedical field.',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'This will allow us understand how we can\nbest serve you, including contents and\ncommunities you can join',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                  ),
                ),
                RPadding(
                  padding: REdgeInsets.only(top: .055.sh, bottom: .1.sh),
                  child: Text.rich(
                    TextSpan(
                      text: 'Learn more',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primaryBlue5,
                        fontSize: 16.sp,
                        color: AppColors.primaryBlue5,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFonts.montserrat,
                      ),
                    ),
                  ),
                ),
                CarenetButtonFilled(
                  btnAction: () {
                    Navigator.of(
                      context,
                    ).pushNamed(RouteName.medicalProfessional);
                  },
                  btnName: 'Yes',
                ),
                SizedBox(height: 5.h),
                CarenetButtonOutline(
                  btnAction: () {
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(RouteName.dashboard);
                  },
                  btnName: 'No, skip',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
