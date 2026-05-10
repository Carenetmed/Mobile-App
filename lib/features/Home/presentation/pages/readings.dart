import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/model/reading_metric.dart';
import 'package:app_t/features/Home/presentation/widget/vitals_container.dart';
import 'package:app_t/shared/widgets/complete_profile_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VitalsReading extends StatelessWidget {
  const VitalsReading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: REdgeInsets.symmetric(horizontal: 15.w),
          physics: const BouncingScrollPhysics(),
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
                    icon: const Icon(Icons.arrow_back),
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
                  const SizedBox(width: 48),
                ],
              ),
              SizedBox(height: 15.h),
              CompleteProfileAlert(),
              SizedBox(height: 16.h),
              Text(
                'Health records overview',
                style: TextStyle(
                  fontSize: FontSizes.body3,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Review your most important readings and open any one for more context.',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  fontSize: FontSizes.footer2,
                  color: AppColors.white05,
                ),
              ),
              SizedBox(height: 16.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: readingMetrics.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 16.h,
                  crossAxisSpacing: 8.w,
                  crossAxisCount: 2,
                  childAspectRatio: 1.25,
                ),
                itemBuilder: (context, index) {
                  final metric = readingMetrics[index];

                  return VitalsContainer(
                    title: metric.title,
                    reading: '${metric.reading} ${metric.unit}',
                    suffixIcon: Image.asset(
                      height: 16.h,
                      width: 16.w,
                      fit: BoxFit.fill,
                      metric.iconAssetPath,
                    ),
                    onTap:
                        () => Navigator.of(context).pushNamed(
                          RouteName.readingMetricDetail,
                          arguments: ReadingMetricRouteArgs(metric.id),
                        ),
                  );
                },
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(RouteName.manageReadings);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add new readings'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Readings download will be available soon',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_downward_rounded),
                    label: const Text('Download readings'),
                  ),
                ],
              ),
              SizedBox(height: 25.h),
            ],
          ),
        ),
      ),
    );
  }
}
