import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/articles_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SavedArticlesShellPage extends StatefulWidget {
  const SavedArticlesShellPage({super.key});

  @override
  State<SavedArticlesShellPage> createState() => _SavedArticlesShellPageState();
}

class _SavedArticlesShellPageState extends State<SavedArticlesShellPage> {
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
          selectedArticle == null ? 'Saved Articles' : selectedArticle.title,
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
                ? _SavedArticlesListView(
                  onOpenArticle: (article) {
                    ArticlesLocalStore.markRead(article.title);
                    setState(() {
                      _selectedArticle = article;
                    });
                  },
                )
                : _SavedArticleDetailView(
                  article: selectedArticle,
                  onRemoveSaved: () {
                    ArticlesLocalStore.toggleSaved(selectedArticle.title);
                    setState(() {
                      _selectedArticle = null;
                    });
                  },
                ),
      ),
    );
  }
}

class _SavedArticlesListView extends StatelessWidget {
  const _SavedArticlesListView({required this.onOpenArticle});

  final ValueChanged<ArticleContent> onOpenArticle;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: ArticlesLocalStore.savedArticles,
      builder: (context, savedArticleTitles, _) {
        final savedArticles = ArticlesLocalStore.articles
            .where((article) => savedArticleTitles.contains(article.title))
            .toList(growable: false);

        return ListView(
          padding: REdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          children: [
            const _SavedArticlesTabs(),
            SizedBox(height: 12.h),
            if (savedArticles.isEmpty)
              _EmptySavedArticlesCard(
                onBrowseArticles: () {
                  Navigator.of(context).pushNamed(RouteName.articles);
                },
              )
            else
              ...savedArticles.map(
                (article) => Padding(
                  padding: REdgeInsets.only(bottom: 12.h),
                  child: _SavedArticleCard(
                    article: article,
                    onOpenArticle: () => onOpenArticle(article),
                    onRemoveSaved: () {
                      ArticlesLocalStore.toggleSaved(article.title);
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SavedArticlesTabs extends StatelessWidget {
  const _SavedArticlesTabs();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _SavedArticlesTab(label: 'For you', isActive: true),
        _SavedArticlesTab(label: 'Request'),
        _SavedArticlesTab(label: 'Drafts'),
      ],
    );
  }
}

class _SavedArticlesTab extends StatelessWidget {
  const _SavedArticlesTab({required this.label, this.isActive = false});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 36.h,
        margin: REdgeInsets.only(right: label == 'Drafts' ? 0 : 8.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBlue5 : AppColors.kWhite,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isActive ? AppColors.primaryBlue5 : AppColors.white04,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w600,
            fontSize: FontSizes.footer3,
            color: isActive ? AppColors.kWhite : AppColors.primaryBlue11,
          ),
        ),
      ),
    );
  }
}

class _EmptySavedArticlesCard extends StatelessWidget {
  const _EmptySavedArticlesCard({required this.onBrowseArticles});

  final VoidCallback onBrowseArticles;

  @override
  Widget build(BuildContext context) {
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
            'You have no saved articles',
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              fontSize: FontSizes.body3,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Articles saved from the reader will appear here. Account sync and published-article libraries are separate backend work.',
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              fontSize: FontSizes.footer2,
              color: AppColors.primaryBlue11,
              height: 1.4,
            ),
          ),
          SizedBox(height: 14.h),
          OutlinedButton(
            onPressed: onBrowseArticles,
            child: const Text('Browse articles'),
          ),
        ],
      ),
    );
  }
}

class _SavedArticleCard extends StatelessWidget {
  const _SavedArticleCard({
    required this.article,
    required this.onOpenArticle,
    required this.onRemoveSaved,
  });

  final ArticleContent article;
  final VoidCallback onOpenArticle;
  final VoidCallback onRemoveSaved;

  @override
  Widget build(BuildContext context) {
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
          SizedBox(height: 12.h),
          Row(
            children: [
              TextButton(onPressed: onOpenArticle, child: const Text('Read')),
              SizedBox(width: 8.w),
              OutlinedButton(
                onPressed: onRemoveSaved,
                child: const Text('Remove saved'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavedArticleDetailView extends StatelessWidget {
  const _SavedArticleDetailView({
    required this.article,
    required this.onRemoveSaved,
  });

  final ArticleContent article;
  final VoidCallback onRemoveSaved;

  @override
  Widget build(BuildContext context) {
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
              OutlinedButton(
                onPressed: onRemoveSaved,
                child: const Text('Remove saved'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
