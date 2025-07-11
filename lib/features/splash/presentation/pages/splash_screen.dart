import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacementNamed(RouteName.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgImage(
                width: 144.w,
                height: 144.h,
                imgName: AssetsImages.appLogo,
              ),
              RPadding(
                child: Text(
                  'CARENET',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    color: AppColors.kBlack,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 3.h),
              ),
              Text(
                'HEALTH SERVICES',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  color: AppColors.kBlack,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
