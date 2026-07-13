import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/features/Home/presentation/pages/home_articles_tab.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/pages/feed_tab.dart';
import 'package:app_t/features/Home/presentation/pages/home_messages_tab.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late final TabController _controller;
  final List<String> _tabNames = ['Feed', 'Messages', 'Articles'];

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RPadding(
        padding: REdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (context) {
                    return GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 15,
                        child: Image(
                          image: AssetImage(AssetsImages.profileHandle),
                        ),
                      ),
                    );
                  },
                ),
                SvgImage(imgName: AssetsImages.appLogoBlack),
                Container(
                  padding: REdgeInsets.all(5.5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue5,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Upgrade',
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      color: AppColors.white01,
                      fontWeight: FontWeight.w500,
                      fontSize: FontSizes.footer3,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            TabBar(
              dividerHeight: 0,
              controller: _controller,
              indicator: BoxDecoration(color: Colors.transparent),
              dividerColor: Colors.transparent,
              // tabAlignment: TabAlignment.center,
              padding: REdgeInsets.symmetric(horizontal: 20.w),
              tabs:
                  _tabNames
                      .map(
                        (tab) => Tab(
                          child: Text(
                            tab,
                            style: TextStyle(
                              fontFamily: AppFonts.montserrat,
                              fontWeight: FontWeight.w500,
                              fontSize: FontSizes.body2,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
            Expanded(
              child: TabBarView(
                controller: _controller,
                children: [
                  FeedTab(),
                  const HomeMessagesTab(),
                  const HomeArticlesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
