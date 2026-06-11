import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManageReadings extends StatefulWidget {
  const ManageReadings({super.key});

  @override
  State<ManageReadings> createState() => _ManageReadingsState();
}

class _ManageReadingsState extends State<ManageReadings> {
  static const String _guidedReading = 'Blood Sugar';

  final List<String> options = [
    'Steps',
    'Blood Sugar',
    'Weight',
    'Oxygen Level',
    'Heart Rate',
    'Temperature',
    'Respiration Rate',
    'Body Mass Index',
    'Bone Mass',
    'Body Fat',
    'Body Water',
    'Visceral Fat Rating',
  ];

  Set<String> selectedOptions = {};

  void _completeSelection() {
    if (selectedOptions.contains(_guidedReading)) {
      Navigator.pushNamed(context, RouteName.addDevice);
      return;
    }
    Navigator.pop(context);
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
                    icon: Icon(Icons.arrow_back),
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
                    onTap: _completeSelection,
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
              Container(
                width: double.infinity,
                padding: REdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.blue02,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: AppColors.white04),
                ),
                child: Text(
                  'Blood Sugar is the first guided readings lane. Selecting it continues into device/setup onboarding; the other reading types stay local until their slices are built.',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w400,
                    fontSize: FontSizes.footer3,
                    color: AppColors.primaryBlue11,
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = selectedOptions.contains(option);

                    return CheckboxListTile(
                      title: Text(
                        option,
                        style: TextStyle(
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w500,
                          fontSize: FontSizes.footer2,
                        ),
                      ),
                      checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      activeColor: AppColors.primaryBlue6,
                      fillColor: WidgetStatePropertyAll(AppColors.primaryBlue6),
                      tileColor: AppColors.blue02,

                      secondary: Container(
                        height: 36.h,
                        width: 43.w,
                        // padding: EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.kWhite,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),

                      value: isSelected,
                      onChanged: (bool? checked) {
                        setState(() {
                          if (checked == true) {
                            selectedOptions.add(option);
                          } else {
                            selectedOptions.remove(option);
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.trailing,
                    );
                  },
                ),

                // ListView.builder(
                //   itemCount: options.length,
                //   itemBuilder: (context, index) {
                //     final option = options[index];
                //     return CustomRadioListTile(
                //       title: option,
                //       value: option,
                //       groupValue: selectedValue,
                //       onChanged: (value) => setState(() => selectedValue = value!),
                //
                //     );
                //   },
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
