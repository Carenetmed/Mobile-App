import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/widgets/social_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({super.key, required this.article});

  final ArticleItem article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        surfaceTintColor: AppColors.kWhite,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.kBlack),
        ),
        title: Text(
          'Article',
          style: TextStyle(
            color: AppColors.primaryBlue5,
            fontFamily: AppFonts.montserrat,
            fontSize: FontSizes.body3,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: REdgeInsets.fromLTRB(12, 0, 12, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Image.asset(
                article.imageAsset,
                width: double.infinity,
                height: 210.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                CircleAvatar(
                  radius: 14.r,
                  backgroundImage: const AssetImage(AssetsImages.profileHandle),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    article.author,
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      fontSize: FontSizes.footer2,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white06,
                    ),
                  ),
                ),
                Text(
                  article.readTime,
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontSize: FontSizes.footer3,
                    color: AppColors.white04,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              article.title,
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w700,
                fontSize: FontSizes.body2,
                color: AppColors.white06,
                height: 1.4,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              article.body,
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w400,
                fontSize: FontSizes.footer2,
                color: AppColors.white05,
                height: 1.65,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'Comments',
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w700,
                fontSize: FontSizes.body3,
                color: AppColors.white06,
              ),
            ),
            SizedBox(height: 10.h),
            const _ArticleCommentCard(),
            SizedBox(height: 18.h),
            Text(
              'Related posts',
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w700,
                fontSize: FontSizes.body3,
                color: AppColors.white06,
              ),
            ),
            SizedBox(height: 10.h),
            ...demoSocialPosts
                .take(2)
                .map(
                  (post) => Padding(
                    padding: REdgeInsets.only(bottom: 14),
                    child: SocialPostCard(
                      post: post,
                      compact: true,
                      onCommentTap: () {},
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _ArticleCommentCard extends StatelessWidget {
  const _ArticleCommentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE9EEF5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundImage: const AssetImage(AssetsImages.profileHandle),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lagbaja Tamedu',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w600,
                    fontSize: FontSizes.footer2,
                    color: AppColors.white06,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'This was insightful. The blend of AI, robotics, and clinical workflows really is where modern care is heading.',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w400,
                    fontSize: FontSizes.footer2,
                    color: AppColors.white05,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
