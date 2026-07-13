import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/articles_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ArticlesShellPage extends StatefulWidget {
  const ArticlesShellPage({super.key});

  @override
  State<ArticlesShellPage> createState() => _ArticlesShellPageState();
}

class _ArticlesShellPageState extends State<ArticlesShellPage> {
  ArticleContent? _selectedArticle;

  @override
  Widget build(BuildContext context) {
    final selectedArticle = _selectedArticle;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () {
            if (selectedArticle != null) {
              setState(() {
                _selectedArticle = null;
              });
              return;
            }
            Navigator.of(context).maybePop();
          },
        ),
        title: Text(
          selectedArticle == null ? 'Articles' : selectedArticle.title,
          style: const TextStyle(
            color: Color(0xFF007AFF),
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child:
            selectedArticle == null
                ? _ArticlesListView(
                  articles: ArticlesLocalStore.articles,
                  onOpenArticle: (article) {
                    ArticlesLocalStore.markRead(article.title);
                    setState(() {
                      _selectedArticle = article;
                    });
                  },
                )
                : _ArticleDetailView(
                  article: selectedArticle,
                  onToggleSaved: () {
                    setState(() {
                      ArticlesLocalStore.toggleSaved(selectedArticle.title);
                    });
                  },
                ),
      ),
    );
  }
}

class _ArticlesListView extends StatelessWidget {
  const _ArticlesListView({
    required this.articles,
    required this.onOpenArticle,
  });

  final List<ArticleContent> articles;
  final ValueChanged<ArticleContent> onOpenArticle;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: ArticlesLocalStore.savedArticles,
      builder: (context, savedArticles, _) {
        return ValueListenableBuilder<Set<String>>(
          valueListenable: ArticlesLocalStore.readArticles,
          builder: (context, readArticles, __) {
            return ListView.separated(
              padding: REdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              itemCount: articles.length + 1,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    padding: REdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: AppColors.kWhite,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.white04),
                    ),
                    child: Text(
                      'Recommended reading lives here with stable layout and local article content, so later content APIs can replace the data source without changing the reader flow.',
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

                final article = articles[index - 1];
                final isSaved = savedArticles.contains(article.title);
                final isRead = readArticles.contains(article.title);
                return InkWell(
                  onTap: () => onOpenArticle(article),
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    padding: REdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: AppColors.kWhite,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.white04),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                article.category,
                                style: TextStyle(
                                  fontFamily: AppFonts.montserrat,
                                  fontWeight: FontWeight.w500,
                                  fontSize: FontSizes.footer3,
                                  color: AppColors.primaryBlue5,
                                ),
                              ),
                            ),
                            if (isSaved)
                              Text(
                                'Saved',
                                style: TextStyle(
                                  fontFamily: AppFonts.montserrat,
                                  fontWeight: FontWeight.w600,
                                  fontSize: FontSizes.footer4,
                                  color: AppColors.primaryBlue5,
                                ),
                              ),
                          ],
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
                        SizedBox(height: 12.h),
                        Text(
                          isRead ? 'Read article' : 'Open article',
                          style: TextStyle(
                            fontFamily: AppFonts.montserrat,
                            fontWeight: FontWeight.w600,
                            fontSize: FontSizes.footer3,
                            color: AppColors.primaryBlue5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ArticleDetailView extends StatelessWidget {
  const _ArticleDetailView({
    required this.article,
    required this.onToggleSaved,
  });

  final ArticleContent article;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: ArticlesLocalStore.savedArticles,
      builder: (context, savedArticles, _) {
        final isSaved = savedArticles.contains(article.title);
        return ListView(
          padding: REdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          children: [
            Container(
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
                      fontWeight: FontWeight.w700,
                      fontSize: FontSizes.body2,
                      color: AppColors.kBlack,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    article.body,
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w400,
                      fontSize: FontSizes.footer2,
                      color: AppColors.primaryBlue11,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'This article is local content for now. Later content APIs should replace the article source without changing the list/detail reader flow.',
                    style: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w400,
                      fontSize: FontSizes.footer3,
                      color: AppColors.primaryBlue5,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  OutlinedButton(
                    onPressed: onToggleSaved,
                    child: Text(isSaved ? 'Saved locally' : 'Save article'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
