import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/model/vitalsModel.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/readings_local_store.dart';
import 'package:app_t/features/Home/presentation/widget/vitals_box.dart';
import 'package:app_t/features/Home/presentation/widget/vitals_container.dart';
import 'package:app_t/shared/widgets/action_container.dart';
import 'package:app_t/shared/widgets/complete_profile_alert.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:app_t/shared/widgets/upgrade_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VitalsReading extends StatelessWidget {
  const VitalsReading({super.key});

  List<VitalsModel> _buildVitals() => [
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
      reading: ReadingsLocalStore.bloodSugarDisplay,
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

  void _openManageReadings(BuildContext context) {
    Navigator.pushNamed(context, RouteName.manageReadings);
  }

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
                  Opacity(
                    opacity: 0.45,
                    child: IgnorePointer(
                      child: SvgImage(imgName: AssetsIcon.menu),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              CompleteProfileAlert(),

              SizedBox(height: 16.h),

              SizedBox(
                height: .68.sh,
                child: ValueListenableBuilder<BloodSugarEntry?>(
                  valueListenable: ReadingsLocalStore.bloodSugarEntry,
                  builder: (context, _, __) {
                    final vitals = _buildVitals();
                    return GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: vitals.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 16.h,
                        crossAxisSpacing: 8.w,
                        crossAxisCount: 2,
                      ),
                      itemBuilder: (context, index) {
                        return VitalsContainer(
                          title: vitals[index].title,
                          reading: vitals[index].reading,
                          suffixIcon: vitals[index].suffixIcon,
                        );
                      },
                    );
                  },
                ),
              ),
              Row(
                children: [
                  VitalsBox(
                    height: .085.sh,
                    btnAction: () => _openManageReadings(context),
                  ),
                  SizedBox(width: 5.w),
                  Tooltip(
                    message:
                        'Download export is intentionally deferred until the add-reading flow is implemented.',
                    child: Semantics(
                      label: 'Download readings, deferred until a later phase',
                      child: Opacity(
                        opacity: 0.45,
                        child: IgnorePointer(
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
                      ),
                    ),
                  ),
                ],
              ),
              ValueListenableBuilder<BloodSugarEntry?>(
                valueListenable: ReadingsLocalStore.bloodSugarEntry,
                builder: (context, entry, child) {
                  if (entry == null) {
                    return SizedBox(height: 25.h);
                  }
                  return Padding(
                    padding: REdgeInsets.only(top: 18.h),
                    child: Container(
                      width: double.infinity,
                      padding: REdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: AppColors.blue02,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColors.white04),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latest blood sugar entry',
                            style: TextStyle(
                              fontSize: FontSizes.footer3,
                              fontFamily: AppFonts.montserrat,
                              fontWeight: FontWeight.w700,
                              color: AppColors.kBlack,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            '${entry.reading} mg/dL • ${entry.context}',
                            style: TextStyle(
                              fontSize: FontSizes.footer2,
                              fontFamily: AppFonts.montserrat,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue5,
                            ),
                          ),
                          if (entry.note.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              entry.note,
                              style: TextStyle(
                                fontSize: FontSizes.footer3,
                                fontFamily: AppFonts.montserrat,
                                fontWeight: FontWeight.w400,
                                color: AppColors.primaryBlue11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
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
