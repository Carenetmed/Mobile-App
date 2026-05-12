import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/pages/article_detail_page.dart';
import 'package:app_t/features/Home/presentation/pages/articles_tab.dart';
import 'package:app_t/features/Home/presentation/widgets/social_widgets.dart';
import 'package:app_t/features/Messaging/presentation/pages/Messages.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommentOnFeedPage extends StatefulWidget {
  const CommentOnFeedPage({super.key});

  @override
  State<CommentOnFeedPage> createState() => _CommentOnFeedPageState();
}

class _CommentOnFeedPageState extends State<CommentOnFeedPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;
  final TextEditingController _commentController = TextEditingController();
  final List<String> _tabNames = const ['Feed', 'Messages', 'Articles'];

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: _tabNames.length, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const post = commentThreadPost;

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: REdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 16.r,
                    backgroundImage: const AssetImage(
                      AssetsImages.profileHandle,
                    ),
                  ),
                  SvgImage(imgName: AssetsImages.appLogoBlack, height: 24.h),
                  Container(
                    padding: REdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue5,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Text(
                      'Upgrade',
                      style: TextStyle(
                        color: AppColors.kWhite,
                        fontFamily: AppFonts.montserrat,
                        fontSize: FontSizes.footer3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            TabBar(
              controller: _controller,
              labelColor: AppColors.white06,
              unselectedLabelColor: AppColors.white06,
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
              labelStyle: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w500,
                fontSize: FontSizes.footer1,
              ),
              tabs: _tabNames.map((name) => Tab(text: name)).toList(),
            ),
            Expanded(
              child: TabBarView(
                controller: _controller,
                children: [
                  SingleChildScrollView(
                    padding: REdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      children: [
                        SocialPostCard(
                          post: post,
                          compact: true,
                          showCountsLabel: true,
                          showActionBar: true,
                          onCommentTap: () {},
                        ),
                        SizedBox(height: 12.h),
                        SocialCommentComposer(
                          controller: _commentController,
                          onSend: () {
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ],
                    ),
                  ),
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
