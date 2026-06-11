import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddDeviceShellPage extends StatelessWidget {
  const AddDeviceShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          'Add Device',
          style: TextStyle(
            fontSize: FontSizes.footer2,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue5,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: REdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set up your first guided reading lane.',
                style: TextStyle(
                  fontSize: FontSizes.body2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'The blueprint shows this phase continuing through device onboarding before export. For now we are starting with blood sugar so future device pairing or manual capture can plug in here cleanly.',
                style: TextStyle(
                  fontSize: FontSizes.footer2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryBlue11,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),
              Container(
                width: double.infinity,
                padding: REdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  color: AppColors.blue02,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.white04),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bloodtype_outlined,
                          color: AppColors.primaryBlue5,
                          size: 22.r,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Blood Sugar',
                            style: TextStyle(
                              fontSize: FontSizes.footer2,
                              fontFamily: AppFonts.montserrat,
                              fontWeight: FontWeight.w700,
                              color: AppColors.kBlack,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Continue into the first reading-specific screen now. Device pairing details can slot in here later without rebuilding the flow.',
                      style: TextStyle(
                        fontSize: FontSizes.footer3,
                        fontFamily: AppFonts.montserrat,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryBlue11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, RouteName.bloodSug);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue5,
                    foregroundColor: AppColors.kWhite,
                    padding: REdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(
                    'Continue to Blood Sugar',
                    style: TextStyle(
                      fontSize: FontSizes.footer3,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
