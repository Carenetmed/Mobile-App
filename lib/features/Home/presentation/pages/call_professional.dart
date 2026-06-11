import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/widget/vitals_box.dart';
import 'package:app_t/shared/widgets/action_container.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:app_t/shared/widgets/upgrade_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CallProfessional extends StatelessWidget {
  CallProfessional({super.key});

  final List<CallProfessionalModel> _callMeans = [
    CallProfessionalModel(
      assetPath: AssetsIcon.call,
      title: 'Voice Call',
      btnAction: null,
    ),
    CallProfessionalModel(
      assetPath: AssetsIcon.video,
      title: 'Video Call',
      btnAction: null,
    ),
    CallProfessionalModel(
      assetPath: AssetsIcon.schedule,
      title: 'Schedule a private visit or meeting',
      btnAction: null,
    ),
    CallProfessionalModel(
      assetPath: AssetsIcon.umbrella,
      title: 'Buy insurance',
      btnAction: null,
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
                    'Page',
                    style: TextStyle(
                      fontSize: FontSizes.footer2,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryBlue5,
                    ),
                  ),
                  Tooltip(
                    message: 'Additional actions unavailable',
                    child: Opacity(
                      opacity: 0.45,
                      child: SvgImage(imgName: AssetsIcon.menu),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              SizedBox(
                height: .1.sh,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment(-.4, 0),
                      child: Image.asset(AssetsImages.professionalOne),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(AssetsImages.professionalTwo),
                    ),
                    Align(
                      alignment: Alignment(.4, 0),
                      child: Image.asset(AssetsImages.professionalThree),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: REdgeInsets.symmetric(vertical: 15.h),
                alignment: Alignment.center,
                padding: REdgeInsets.symmetric(vertical: 8.h),
                color: AppColors.primaryBlue11,
                child: Text(
                  '24/7 access to Doctors and Wellness Experts',
                  style: TextStyle(
                    fontSize: FontSizes.footer2,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w500,
                    color: AppColors.kWhite,
                  ),
                ),
              ),
              SizedBox(
                height: .3.sh,
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _callMeans.length,
                  itemBuilder: (context, index) {
                    return RPadding(
                      padding: REdgeInsets.only(bottom: 15),
                      child: ListTile(
                        onTap: _callMeans[index].btnAction,
                        leading: SvgImage(imgName: _callMeans[index].assetPath),
                        title: Text(
                          _callMeans[index].title,
                          style: TextStyle(
                            color: AppColors.kBlack,
                            fontSize: FontSizes.footer2,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFonts.montserrat,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),

                        tileColor: AppColors.blue02,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: .085.sh, child: VitalsBox(btnAction: null)),
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

class CallProfessionalModel {
  final void Function()? btnAction;
  final String assetPath;
  final String title;
  CallProfessionalModel({
    this.btnAction,
    required this.assetPath,
    required this.title,
  });
}
