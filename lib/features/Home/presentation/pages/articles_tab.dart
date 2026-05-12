import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/pages/article_detail_page.dart';
import 'package:app_t/features/Home/presentation/widgets/social_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ArticlesPage extends StatelessWidget {
  const ArticlesPage({super.key});

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
          'Articles',
          style: TextStyle(
            color: AppColors.primaryBlue5,
            fontFamily: AppFonts.montserrat,
            fontSize: FontSizes.body3,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ArticlesTab(
        embedded: false,
        onOpenArticle: (article) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ArticleDetailPage(article: article),
            ),
          );
        },
      ),
    );
  }
}

class ArticlesTab extends StatefulWidget {
  const ArticlesTab({super.key, required this.embedded, this.onOpenArticle});

  final bool embedded;
  final ValueChanged<ArticleItem>? onOpenArticle;

  @override
  State<ArticlesTab> createState() => _ArticlesTabState();
}

class _ArticlesTabState extends State<ArticlesTab> {
  String _selectedType = 'Articles';

  @override
  Widget build(BuildContext context) {
    final items = _selectedType == 'Articles' ? demoArticles : demoPodcasts;

    return Column(
      children: [
        Padding(
          padding: REdgeInsets.fromLTRB(
            widget.embedded ? 4 : 12,
            8,
            widget.embedded ? 4 : 12,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: _ArticleTypePill(
                  label: 'Articles',
                  selected: _selectedType == 'Articles',
                  onTap: () => setState(() => _selectedType = 'Articles'),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _ArticleTypePill(
                  label: 'Podcast',
                  selected: _selectedType == 'Podcast',
                  onTap: () => setState(() => _selectedType = 'Podcast'),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: REdgeInsets.fromLTRB(
            widget.embedded ? 4 : 12,
            12,
            widget.embedded ? 4 : 12,
            0,
          ),
          child: SearchBar(
            hintText: 'Search',
            leading: const Icon(Icons.search, color: AppColors.white04),
            backgroundColor: WidgetStateProperty.all(AppColors.kWhite),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            elevation: WidgetStateProperty.all(0),
            padding: WidgetStateProperty.all(
              REdgeInsets.symmetric(horizontal: 8, vertical: 2),
            ),
            textStyle: WidgetStatePropertyAll(
              TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: FontSizes.footer2,
                color: AppColors.white06,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: REdgeInsets.fromLTRB(
              widget.embedded ? 4 : 12,
              16,
              widget.embedded ? 4 : 12,
              24,
            ),
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(height: 14.h),
            itemBuilder: (context, index) {
              final article = items[index];
              return InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () {
                  final openArticle = widget.onOpenArticle;
                  if (openArticle != null) {
                    openArticle(article);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.kWhite,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE9EEF5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12.r),
                        ),
                        child: Image.asset(
                          article.imageAsset,
                          height: 170.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: REdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 12.r,
                                  backgroundImage: const AssetImage(
                                    AssetsImages.profileHandle,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    article.author,
                                    style: TextStyle(
                                      fontFamily: AppFonts.montserrat,
                                      fontWeight: FontWeight.w600,
                                      fontSize: FontSizes.footer2,
                                      color: AppColors.white06,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              article.title,
                              style: TextStyle(
                                fontFamily: AppFonts.montserrat,
                                fontWeight: FontWeight.w700,
                                fontSize: FontSizes.body3,
                                color: AppColors.white06,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              article.summary,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ArticleTypePill extends StatelessWidget {
  const _ArticleTypePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: onTap,
      child: Container(
        padding: REdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue5 : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w600,
            fontSize: FontSizes.footer2,
            color: selected ? AppColors.kWhite : AppColors.white06,
          ),
        ),
      ),
    );
  }
}
