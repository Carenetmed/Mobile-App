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
        actButton: () {
          Navigator.of(context).pop();
        },
      ),
      DrawerItem(label: 'Profile', assetPath: AssetsIcon.personOutline),
      DrawerItem(
        label: 'Readings',
        assetPath: AssetsIcon.content,
        actButton: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(RouteName.readings);
        },
      ),
      DrawerItem(
        label: 'Reminders',
        assetPath: AssetsIcon.clock,
        actButton: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(RouteName.reminders);
        },
      ),
      DrawerItem(
        label: 'Schedule',
        assetPath: AssetsIcon.calendar,
        actButton: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(RouteName.schedule);
        },
      ),
      DrawerItem(label: 'provider', assetPath: AssetsIcon.umbrella_outline),
      DrawerItem(label: 'Premium', assetPath: AssetsIcon.trophy),
      DrawerItem(
        label: 'Articles',
        assetPath: AssetsIcon.notepad,
        actButton: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(RouteName.articles);
        },
      ),
      DrawerItem(
        label: 'Messages',
        assetPath: AssetsIcon.mail,
        actButton: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(RouteName.messages);
        },
      ),
      DrawerItem(label: 'Events', assetPath: AssetsIcon.mic),
    ];

    return Drawer(
      backgroundColor: AppColors.kWhite,
      width: .63.sw,
      child: Padding(
        padding: REdgeInsets.symmetric(horizontal: 12.w, vertical: .05.sh),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(AssetsImages.firePlace),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.info_outline, size: 13),
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
            Row(
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
                SizedBox(width: 20.w),
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
            Padding(
              padding: REdgeInsets.only(top: 16.h),
              child: Divider(thickness: 1, color: AppColors.kPink),
            ),
            SizedBox(height: 25.h),
            SizedBox(
              height: .45.sh,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: drawerItems.length,
                itemBuilder: (context, index) {
                  final item = drawerItems[index];
                  return IconListile(
                    btnAction: item.actButton,
                    assetPath: item.assetPath,
                    label: item.label,
                  );
                },
              ),
            ),
            SizedBox(height: .02.sh),
            IconListile(
              label: 'Settings & Privacy',
              assetPath: AssetsIcon.settings,
              btnAction: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(RouteName.settings);
              },
            ),
            const IconListile(
              label: 'Rate the App',
              assetPath: AssetsIcon.star,
            ),
            const IconListile(label: 'Need help?', assetPath: AssetsIcon.help),
            SizedBox(height: .02.sh),
            const IconListile(label: 'Mode', assetPath: AssetsIcon.sunny),
          ],
        ),
      ),
    );
  }
}
