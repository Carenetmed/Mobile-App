import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/pages/article_detail_page.dart';
import 'package:app_t/features/Home/presentation/pages/articles_tab.dart';
import 'package:app_t/features/Home/presentation/pages/feed_tab.dart';
import 'package:app_t/features/Messaging/presentation/pages/Messages.dart';
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
  final List<String> _tabNames = const ['Feed', 'Messages', 'Articles'];

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: _tabNames.length, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: REdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder:
                      (context) => GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 15.r,
                          child: const Image(
                            image: AssetImage(AssetsImages.profileHandle),
                          ),
                        ),
                      ),
                ),
                SvgImage(imgName: AssetsImages.appLogoBlack, height: 24.h),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(5.r),
                  child: Container(
                    padding: REdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5.5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue5,
                      borderRadius: BorderRadius.circular(5.r),
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
                ),
              ],
            ),
            SizedBox(height: 8.h),
            TabBar(
              controller: _controller,
              dividerColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              labelPadding: REdgeInsets.symmetric(horizontal: 18.w),
              tabs:
                  _tabNames
                      .map(
                        (tab) => Tab(
                          child: Text(
                            tab,
                            style: TextStyle(
                              fontFamily: AppFonts.montserrat,
                              fontWeight: FontWeight.w500,
                              fontSize: FontSizes.footer1,
                              color: AppColors.white06,
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
                  const FeedTab(),
                  const MessagesTabContent(embedded: true),
                  ArticlesTab(
                    embedded: true,
                    onOpenArticle: (article) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ArticleDetailPage(article: article),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
