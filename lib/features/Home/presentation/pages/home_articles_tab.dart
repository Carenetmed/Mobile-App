import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeArticlesTab extends StatelessWidget {
  const HomeArticlesTab({super.key});

  static const List<_ArticlePreview> _articles = [
    _ArticlePreview(
      category: 'Heart health',
      title: 'What to monitor after an intense workout',
      summary:
          'A simple checklist for recovery signs, hydration, and when to slow down before your next session.',
    ),
    _ArticlePreview(
      category: 'Nutrition',
      title: 'Five easy breakfast upgrades for steadier energy',
      summary:
          'Small ingredient swaps can keep your morning routine familiar while helping energy stay more stable.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: REdgeInsets.only(top: 12.h, bottom: 24.h),
      itemCount: _articles.length + 1,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const _ArticleHeader();
        }

        final article = _articles[index - 1];
        return Container(
          padding: REdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.kWhite,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.white04),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.category,
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w500,
                  fontSize: FontSizes.footer3,
                  color: AppColors.primaryBlue5,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                article.title,
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w600,
                  fontSize: FontSizes.body3,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                article.summary,
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  fontSize: FontSizes.footer2,
                  color: AppColors.primaryBlue11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArticleHeader extends StatelessWidget {
  const _ArticleHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Text(
        'Recommended reading lives here with stable layout and local preview data, so later article APIs can plug in without changing the tab structure.',
        style: TextStyle(
          fontFamily: AppFonts.montserrat,
          fontWeight: FontWeight.w400,
          fontSize: FontSizes.footer2,
          color: AppColors.primaryBlue11,
          height: 1.4,
        ),
      ),
    );
  }
}

class _ArticlePreview {
  const _ArticlePreview({
    required this.category,
    required this.title,
    required this.summary,
  });

  final String category;
  final String title;
  final String summary;
}
