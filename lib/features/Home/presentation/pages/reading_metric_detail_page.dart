import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/model/reading_metric.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReadingMetricDetailPage extends StatelessWidget {
  final ReadingMetric metric;

  const ReadingMetricDetailPage({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: REdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: Text(
                        metric.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: FontSizes.footer2,
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryBlue5,
                        ),
                      ),
                    ),
                    SizedBox(width: 48.w),
                  ],
                ),
                SizedBox(height: 24.h),
                Container(
                  width: double.infinity,
                  padding: REdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.blue02,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 36.h,
                        width: 36.w,
                        padding: REdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.kWhite,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Image.asset(
                          metric.iconAssetPath,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        'Current reading',
                        style: TextStyle(
                          fontFamily: AppFonts.montserrat,
                          fontSize: FontSizes.footer3,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white04,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: metric.reading,
                              style: TextStyle(
                                fontFamily: AppFonts.montserrat,
                                fontSize: FontSizes.body1,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBlue10,
                              ),
                            ),
                            TextSpan(
                              text: ' ${metric.unit}',
                              style: TextStyle(
                                fontFamily: AppFonts.montserrat,
                                fontSize: FontSizes.footer1,
                                fontWeight: FontWeight.w500,
                                color: AppColors.white05,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        metric.helperText,
                        style: TextStyle(
                          fontFamily: AppFonts.montserrat,
                          fontSize: FontSizes.footer3,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white05,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'Quick insight',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontSize: FontSizes.footer1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: REdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.primaryBlue1),
                  ),
                  child: Text(
                    metric.insight,
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      fontSize: FontSizes.footer2,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white06,
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'What you can do next',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontSize: FontSizes.footer1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10.h),
                _ActionTile(
                  title: 'Update reading',
                  subtitle:
                      'Log another value for ${metric.title.toLowerCase()}',
                  onTap: () {
                    Navigator.of(context).pushNamed(RouteName.manageReadings);
                  },
                ),
                SizedBox(height: 10.h),
                _ActionTile(
                  title: 'See all readings',
                  subtitle: 'Return to the overview for the full health record',
                  onTap: () {
                    Navigator.of(context).pushNamed(RouteName.readings);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: double.infinity,
        padding: REdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.kWhite,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.primaryBlue1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      fontSize: FontSizes.footer2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      fontSize: FontSizes.footer3,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white05,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}
