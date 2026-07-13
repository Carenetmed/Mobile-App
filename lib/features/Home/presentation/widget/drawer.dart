import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/model/drawer_item_model.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/widget/icon_listile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarenetDraw extends StatelessWidget {
  const CarenetDraw({super.key});

  final String user = 'Dr. Lagbaja Tamedu';
  final int following = 22;
  final int followers = 252;

  @override
  Widget build(BuildContext context) {
    final drawerItems = <DrawerItem>[
      DrawerItem(
        label: 'Dashboard',
        assetPath: AssetsIcon.home,
        actButton: () => Navigator.of(context).pop(),
      ),
      DrawerItem(
        label: 'Profile',
        assetPath: AssetsIcon.personOutline,
        actButton: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, RouteName.account);
        },
      ),
      DrawerItem(label: 'Readings', assetPath: AssetsIcon.content),
      DrawerItem(
        label: 'Reminders',
        assetPath: AssetsIcon.clock,
        actButton: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, RouteName.reminder);
        },
      ),
      DrawerItem(
        label: 'Schedule',
        assetPath: AssetsIcon.calendar,
        actButton: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, RouteName.schedules);
        },
      ),
      DrawerItem(
        label: 'Providers',
        assetPath: AssetsIcon.umbrellaOutline,
        actButton: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, RouteName.findMentor);
        },
      ),
      DrawerItem(label: 'Switch to professional', assetPath: AssetsIcon.trophy),
      DrawerItem(label: 'Articles', assetPath: AssetsIcon.notepad),
      DrawerItem(label: 'Messages', assetPath: AssetsIcon.mail),
      DrawerItem(label: 'Events', assetPath: AssetsIcon.mic),
    ];

    return Drawer(
      backgroundColor: AppColors.kWhite,
      width: .63.sw,
      child: RPadding(
        padding: REdgeInsets.symmetric(horizontal: 12.w, vertical: .05.sh),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(AssetsImages.firePlace),
                IconButton(
                  tooltip: 'Profile information unavailable',
                  onPressed: null,
                  icon: Icon(Icons.info_outline, size: 13),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Text(
              user,
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: FontSizes.body3,
                fontWeight: FontWeight.w700,
              ),
            ),
            // SizedBox(
            //   height: 3.h,
            // ),
            Text(
              'Resident Doctor at LUTH',
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: FontSizes.footer2,
                fontWeight: FontWeight.w400,
                color: AppColors.white06,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 20.w,
              runSpacing: 8.h,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${following.toString()}k ',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: FontSizes.footer3,
                          fontFamily: AppFonts.montserrat,
                          color: AppColors.white06,
                        ),
                      ),
                      TextSpan(
                        text: 'Following',
                        style: TextStyle(
                          fontFamily: AppFonts.montserrat,
                          fontSize: FontSizes.footer2,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white06,
                        ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${followers.toString()}k ',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: FontSizes.footer3,
                          fontFamily: AppFonts.montserrat,
                          color: AppColors.white06,
                        ),
                      ),
                      TextSpan(
                        text: 'Followers',
                        style: TextStyle(
                          fontFamily: AppFonts.montserrat,
                          fontSize: FontSizes.footer2,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white06,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            RPadding(
              padding: REdgeInsets.only(
                top: 16.h,
                // bottom: .01.sh
              ),
              child: Divider(thickness: 1, color: AppColors.kPink),
            ),
            SizedBox(height: 25.h),
            SizedBox(
              height: .45.sh,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                // clipBehavior: Clip.hardEdge,
                physics: NeverScrollableScrollPhysics(),
                itemCount: drawerItems.length,
                itemBuilder: (context, index) {
                  return IconListile(
                    btnAction: drawerItems[index].actButton,
                    assetPath: drawerItems[index].assetPath,
                    label: drawerItems[index].label,
                  );
                },
              ),
            ),
            SizedBox(height: .02.sh),
            IconListile(
              label: 'Settings & Privacy',
              assetPath: AssetsIcon.settings,
            ),
            IconListile(label: 'Rate the App', assetPath: AssetsIcon.star),
            IconListile(label: 'Need help?', assetPath: AssetsIcon.help),
            SizedBox(height: .02.sh),
            IconListile(label: 'Mode', assetPath: AssetsIcon.sunny),
          ],
        ),
      ),
    );
  }
}
