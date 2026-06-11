import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/widget/vitals_box.dart';
import 'package:app_t/shared/widgets/action_container.dart';
import 'package:app_t/shared/widgets/complete_profile_alert.dart';
import 'package:app_t/shared/widgets/upgrade_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeedTab extends StatelessWidget {
  const FeedTab({super.key});
  final String user = 'Thomas';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $user',
          style: TextStyle(
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w700,
            fontSize: FontSizes.body2,
          ),
        ),
        RPadding(
          padding: REdgeInsets.only(top: 8, bottom: 5),
          child: Text(
            'How are you today?',
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w500,
              fontSize: FontSizes.footer2,
            ),
          ),
        ),
        CompleteProfileAlert(),
        Padding(
          padding: REdgeInsets.only(top: 12, bottom: 25),
          child: SizedBox(
            height: .085.sh,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return VitalsBox(
                  btnAction:
                      () => Navigator.pushNamed(
                        context,
                        RouteName.manageReadings,
                      ),
                );
              },
            ),
          ),
        ),
        SearchBar(
          hintText: 'What would you like to know?',
          backgroundColor: WidgetStateProperty.all(AppColors.kWhite),
          hintStyle: WidgetStateProperty.all(
            TextStyle(
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.white03,
              fontSize: FontSizes.footer3,
            ),
          ),
          leading: Icon(Icons.search),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
          side: WidgetStateProperty.all(BorderSide(width: 1)),
          padding: WidgetStateProperty.all(
            REdgeInsets.symmetric(horizontal: 8),
          ),
          textStyle: WidgetStateProperty.all(
            TextStyle(
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              fontSize: FontSizes.footer3,
            ),
          ),
          keyboardType: TextInputType.text,
        ),
        SizedBox(height: 17.h),
        UpgradeWidget(),
        SizedBox(height: 16.h),
        ActionContainer(),
      ],
    );
  }
}
