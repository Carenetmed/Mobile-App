import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfessionScreen extends StatelessWidget {
  ProfessionScreen({super.key});

  final List profession = [
    'Doctor',
    'Paramedic',
    'Nurse',
    'Pharmacist',
    'Pathologist',
    'Surgeon',
    'Medical lab scientist',
    'Midwife',
    'Biochemist',
    'Radioligist',
    "Anesthesiologist",
    "Physiotherapist",
    "Dentist",
    "Optometrist",
    "Occupational Therapist",
    "Paramedic",
    "Psychiatrist",
    "Dermatologist",
    "Pediatrician",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RPadding(
          padding: REdgeInsets.symmetric(horizontal: 16.w, vertical: 25.h),
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
                    'Welcome shall we meet you',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryBlue5,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: REdgeInsets.all(4),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.kBlack,
                        fontFamily: AppFonts.montserrat,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: .1.sh),
              SizedBox(
                height: .62.sh,
                child: ListView.builder(
                  itemCount: profession.length,
                  itemBuilder:
                      (context, index) => GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 48.h,
                          width: double.infinity,
                          margin: REdgeInsets.only(bottom: 5.h),
                          decoration: BoxDecoration(
                            color: AppColors.blue03,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(width: 1),
                          ),
                          child: Center(
                            child: Text(
                              profession[index],
                              style: TextStyle(
                                fontSize: FontSizes.body3,
                                fontFamily: AppFonts.montserrat,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                ),
              ),
              SizedBox(height: 20.h),
              CarenetButtonFilled(
                btnAction: () {
                  Navigator.of(context).pushNamed(RouteName.medicalEdit);
                },
                btnName: 'Continue',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
