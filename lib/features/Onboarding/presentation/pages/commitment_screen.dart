import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/shared/widgets/app_button.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommunityCommitment extends StatelessWidget {
  const CommunityCommitment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RPadding(
          padding: REdgeInsets.only(top: .1.sh, left: 21.w, right: 22.w),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgImage(
                  width: 80.w,
                  height: 80.h,
                  imgName: AssetsImages.appLogo,
                ),
                SizedBox(height: .05.sh),
                Text(
                  'Our community commitment',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Carenet is a community for medical professionals and medical knowledge seekers',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    fontSize: 24.sp,
                  ),
                ),
                SizedBox(height: .06.sh),
                Text(
                  'To ensure that everyone can belong, we are\nasking you to comit to the following:',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'I agree to treat everyone in the Carenet\ncommunity - regardless of their race, gender,\nreligion, national origin, political affiliation,\nethnicity, skin color or age - with respect, and\nwithout judgement or bias',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                  ),
                ),
                RPadding(
                  padding: REdgeInsets.symmetric(vertical: .055.sh),
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
                    ).popAndPushNamed(RouteName.notificationAgreement);
                  },
                  btnName: 'Agree & Continue',
                ),
                SizedBox(height: 5.h),
                CarenetButtonOutline(
                  btnAction: () => Navigator.of(context).maybePop(),
                  btnName: 'Decline',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
