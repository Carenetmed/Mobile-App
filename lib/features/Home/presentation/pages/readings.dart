import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/model/vitalsModel.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/widget/vitals_box.dart';
import 'package:app_t/features/Home/presentation/widget/vitals_container.dart';
import 'package:app_t/shared/widgets/action_container.dart';
import 'package:app_t/shared/widgets/complete_profile_alert.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:app_t/shared/widgets/upgrade_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VitalsReading extends StatelessWidget {
  VitalsReading({super.key});

  final List<VitalsModel> _vitals = [
    VitalsModel(
      title: 'Blood Pressure',
      reading: '--mg/Hgl',
      suffixIcon: Image.asset(
        height: 16.h,
        width: 16.w,
        fit: BoxFit.fill,

        AssetsIcon.bloodPressure,
      ),
    ),
    VitalsModel(
      title: 'Weight',
      reading: '56Kg',
      suffixIcon: Image.asset(
        height: 16.h,
        width: 16.w,
        fit: BoxFit.fill,
        AssetsIcon.weight,
      ),
    ),
    VitalsModel(
      title: 'Blood Sugar',
      reading: '6mg/dl',
      suffixIcon: Image.asset(
        height: 16.h,
        width: 16.w,

        fit: BoxFit.fill,
        AssetsIcon.bloodSugar,
      ),
    ),
    VitalsModel(
      title: 'Oxygen Level',
      reading: '--mg/dl',
      suffixIcon: Image.asset(
        height: 16.h,
        width: 16.w,

        fit: BoxFit.fill,
        AssetsIcon.oxygenLevel,
      ),
    ),
    VitalsModel(
      title: 'Steps',
      reading: '--Steps',
      suffixIcon: Image.asset(
        height: 16.h,
        width: 16.w,

        fit: BoxFit.fill,
        AssetsIcon.steps,
      ),
    ),
    VitalsModel(
      title: 'Heart Rate',
      reading: '--BPM',
      suffixIcon: SvgImage(imgName: AssetsIcon.heartRate),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: REdgeInsets.symmetric(horizontal: 15.w),
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                  Text(
                    'Readings',
                    style: TextStyle(
                      fontSize: FontSizes.footer2,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryBlue5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: SvgImage(imgName: AssetsIcon.menu),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              CompleteProfileAlert(),

              SizedBox(height: 16.h),

              SizedBox(
                height: .68.sh,
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _vitals.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 16.h,
                    crossAxisSpacing: 8.w,
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (context, index) {
                    return VitalsContainer(
                      title: _vitals[index].title,
                      reading: _vitals[index].reading,
                      suffixIcon: _vitals[index].suffixIcon,
                    );
                  },
                ),
              ),
              Row(
                children: [
                  VitalsBox(height: .085.sh, btnAction: () {}),
                  SizedBox(width: 5.w),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      height: .085.sh,
                      padding: REdgeInsets.symmetric(
                        horizontal: 30.w,
                        vertical: 8.h,
                      ),
                      margin: REdgeInsets.only(right: 7),
                      decoration: BoxDecoration(
                        border: Border.all(width: .5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_downward_rounded),
                          SizedBox(height: 4.h),
                          Text(
                            textAlign: TextAlign.center,
                            'Download\nReadings',
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
                  ),
                ],
              ),
              SizedBox(height: 25.h),
              UpgradeWidget(),
              SizedBox(height: 20.h),
              ActionContainer(),
            ],
          ),
        ),
      ),
    );
  }
}
