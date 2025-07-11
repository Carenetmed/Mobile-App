import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BorderedListile extends StatelessWidget {
  final VoidCallback btnAction1;
  final String title1;
  final String subtitle1;
  final VoidCallback btnAction2;
  final String title2;
  final String subtitle2;
  const BorderedListile({
    super.key,
    required this.btnAction1,
    required this.title1,
    required this.subtitle1,
    required this.btnAction2,
    required this.title2,
    required this.subtitle2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: btnAction1,
            title: Text(
              title1,
              style: TextStyle(
                fontSize: FontSizes.footer2,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w400,
                color: AppColors.white04,
              ),
            ),
            subtitle: Text(
              subtitle1,
              style: TextStyle(
                fontSize: FontSizes.body3,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w400,
              ),
            ),
            trailing: Icon(Icons.add, color: AppColors.white04),
            // shape: Border.all(),
          ),
          Divider(thickness: 1.8),
          ListTile(
            onTap: btnAction2,
            title: Text(
              title2,
              style: TextStyle(
                fontSize: FontSizes.footer2,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w400,
                color: AppColors.white04,
              ),
            ),
            subtitle: Text(
              subtitle2,
              style: TextStyle(
                fontSize: FontSizes.body3,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w400,
              ),
            ),
            trailing: Icon(Icons.add, color: AppColors.white04),
            // shape: Border.all(),
          ),
        ],
      ),
    );
  }
}
