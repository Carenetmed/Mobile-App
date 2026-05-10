import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/model/reading_metric.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManageReadings extends StatefulWidget {
  const ManageReadings({super.key});

  @override
  State<ManageReadings> createState() => _ManageReadingsState();
}

class _ManageReadingsState extends State<ManageReadings> {
  late final Set<String> _selectedOptions;

  @override
  void initState() {
    super.initState();
    _selectedOptions = {'blood_pressure', 'blood_sugar', 'weight'};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RPadding(
          padding: REdgeInsets.symmetric(horizontal: 16.0),
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
                    'Manage Readings',
                    style: TextStyle(
                      fontSize: FontSizes.footer2,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryBlue5,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reading preferences saved'),
                        ),
                      );
                    },
                    child: Container(
                      padding: REdgeInsets.symmetric(
                        vertical: 5.5.h,
                        horizontal: 7.w,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue5,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text(
                        'Done',
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
              SizedBox(height: .02.sh),
              Text(
                'Choose which health records you want to keep handy in your readings section.',
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: FontSizes.footer2,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white05,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.separated(
                  itemCount: readingMetrics.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final metric = readingMetrics[index];
                    final isSelected = _selectedOptions.contains(metric.id);

                    return CheckboxListTile(
                      title: Text(
                        metric.title,
                        style: TextStyle(
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w500,
                          fontSize: FontSizes.footer2,
                        ),
                      ),
                      subtitle: Text(
                        metric.helperText,
                        style: TextStyle(
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w400,
                          fontSize: FontSizes.footer3,
                          color: AppColors.white05,
                        ),
                      ),
                      checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      activeColor: AppColors.primaryBlue6,
                      fillColor: const WidgetStatePropertyAll(
                        AppColors.primaryBlue6,
                      ),
                      tileColor: AppColors.blue02,
                      contentPadding: REdgeInsets.symmetric(horizontal: 12.w),
                      secondary: Container(
                        height: 40.h,
                        width: 40.w,
                        padding: REdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.kWhite,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Image.asset(
                          metric.iconAssetPath,
                          fit: BoxFit.contain,
                        ),
                      ),
                      value: isSelected,
                      onChanged: (bool? checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedOptions.add(metric.id);
                          } else {
                            _selectedOptions.remove(metric.id);
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.trailing,
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(RouteName.readings);
                  },
                  child: const Text('Open readings overview'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
