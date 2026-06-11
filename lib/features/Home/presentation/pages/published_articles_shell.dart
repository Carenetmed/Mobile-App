import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/manage_portfolio_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum _PublishedArticlesTab { forYou, requests, drafts }

class PublishedArticlesShellPage extends StatefulWidget {
  const PublishedArticlesShellPage({super.key});

  @override
  State<PublishedArticlesShellPage> createState() =>
      _PublishedArticlesShellPageState();
}

class _PublishedArticlesShellPageState
    extends State<PublishedArticlesShellPage> {
  _PublishedArticlesTab _tab = _PublishedArticlesTab.forYou;
  ManagedPortfolioArticle? _selectedArticle;

  @override
  Widget build(BuildContext context) {
    final selectedArticle = _selectedArticle;

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (selectedArticle != null) {
              setState(() => _selectedArticle = null);
              return;
            }
            Navigator.of(context).maybePop();
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          selectedArticle == null ? 'Published Articles' : 'Article details',
          style: TextStyle(
            fontSize: FontSizes.footer2,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue5,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child:
            selectedArticle == null
                ? _PublishedArticlesList(
                  selectedTab: _tab,
                  onTabChanged: (tab) => setState(() => _tab = tab),
                  onOpenArticle:
                      (article) => setState(() => _selectedArticle = article),
                )
                : _PublishedArticleDetail(article: selectedArticle),
      ),
    );
  }
}

class _PublishedArticlesList extends StatelessWidget {
  const _PublishedArticlesList({
    required this.selectedTab,
    required this.onTabChanged,
    required this.onOpenArticle,
  });

  final _PublishedArticlesTab selectedTab;
  final ValueChanged<_PublishedArticlesTab> onTabChanged;
  final ValueChanged<ManagedPortfolioArticle> onOpenArticle;

  @override
  Widget build(BuildContext context) {
    final articles = ManagePortfolioLocalStore.portfolio.articles;

    return ListView(
      padding: REdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
      children: [
        _Tabs(selectedTab: selectedTab, onChanged: onTabChanged),
        SizedBox(height: 16.h),
        if (selectedTab == _PublishedArticlesTab.forYou) ...[
          _CreatorLibraryHeader(articleCount: articles.length),
          SizedBox(height: 12.h),
          if (articles.isEmpty)
            const _EmptyPublishedArticles()
          else
            ...articles.map(
              (article) => _PublishedArticleCard(
                article: article,
                onOpen: () => onOpenArticle(article),
              ),
            ),
        ] else
          _DeferredTabState(tab: selectedTab),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.selectedTab, required this.onChanged});

  final _PublishedArticlesTab selectedTab;
  final ValueChanged<_PublishedArticlesTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'For you',
            selected: selectedTab == _PublishedArticlesTab.forYou,
            onTap: () => onChanged(_PublishedArticlesTab.forYou),
          ),
          _TabButton(
            label: 'Request',
            selected: selectedTab == _PublishedArticlesTab.requests,
            onTap: () => onChanged(_PublishedArticlesTab.requests),
          ),
          _TabButton(
            label: 'Drafts',
            selected: selectedTab == _PublishedArticlesTab.drafts,
            onTap: () => onChanged(_PublishedArticlesTab.drafts),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: selected ? AppColors.kWhite : Colors.transparent,
          foregroundColor:
              selected ? AppColors.primaryBlue5 : AppColors.primaryBlue11,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: FontSizes.footer4,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CreatorLibraryHeader extends StatelessWidget {
  const _CreatorLibraryHeader({required this.articleCount});

  final int articleCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Creator article library',
            style: TextStyle(
              fontSize: FontSizes.footer2,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '$articleCount locally known article${articleCount == 1 ? '' : 's'} ready for review. Publishing, drafts, requests, analytics, and moderation stay backend-gated.',
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _PublishedArticleCard extends StatelessWidget {
  const _PublishedArticleCard({required this.article, required this.onOpen});

  final ManagedPortfolioArticle article;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: REdgeInsets.only(bottom: 10.h),
      padding: REdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.status,
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            article.title,
            style: TextStyle(
              fontSize: FontSizes.footer2,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            article.summary,
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
              height: 1.4,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  article.author,
                  style: TextStyle(
                    fontSize: FontSizes.footer4,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue5,
                  ),
                ),
              ),
              TextButton(onPressed: onOpen, child: const Text('Open')),
            ],
          ),
        ],
      ),
    );
  }
}

class _PublishedArticleDetail extends StatelessWidget {
  const _PublishedArticleDetail({required this.article});

  final ManagedPortfolioArticle article;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: REdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
      children: [
        Container(
          width: double.infinity,
          padding: REdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.kWhite,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.white04),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.status,
                style: TextStyle(
                  fontSize: FontSizes.footer4,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue5,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                article.title,
                style: TextStyle(
                  fontSize: FontSizes.body3,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'By ${article.author}',
                style: TextStyle(
                  fontSize: FontSizes.footer4,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue5,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                article.summary,
                style: TextStyle(
                  fontSize: FontSizes.footer3,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryBlue11,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 16.h),
              const _LockedCreatorActions(),
            ],
          ),
        ),
      ],
    );
  }
}

class _LockedCreatorActions extends StatelessWidget {
  const _LockedCreatorActions();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Publishing controls locked',
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Edit, publish, delete, comments, analytics, and subscriber access need creator content APIs before they can be enabled.',
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
              height: 1.4,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: const [
              _LockedChip(label: 'Edit'),
              _LockedChip(label: 'Analytics'),
              _LockedChip(label: 'Comments'),
              _LockedChip(label: 'Delete'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LockedChip extends StatelessWidget {
  const _LockedChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        Icons.lock_outline,
        size: 16.r,
        color: AppColors.primaryBlue11,
      ),
      label: Text(label),
      backgroundColor: AppColors.kWhite,
      labelStyle: TextStyle(
        fontSize: FontSizes.footer4,
        fontFamily: AppFonts.montserrat,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryBlue11,
      ),
      side: BorderSide(color: AppColors.white04),
    );
  }
}

class _DeferredTabState extends StatelessWidget {
  const _DeferredTabState({required this.tab});

  final _PublishedArticlesTab tab;

  @override
  Widget build(BuildContext context) {
    final title =
        tab == _PublishedArticlesTab.requests
            ? 'No article requests'
            : 'Drafts are not available yet';
    final body =
        tab == _PublishedArticlesTab.requests
            ? 'Request review and collaborator workflows need creator backend rules.'
            : 'Draft persistence and publishing workflow rules are deferred.';

    return _StateCard(title: title, body: body, icon: Icons.lock_outline);
  }
}

class _EmptyPublishedArticles extends StatelessWidget {
  const _EmptyPublishedArticles();

  @override
  Widget build(BuildContext context) {
    return _StateCard(
      title: 'You have no published articles',
      body:
          'Start writing articles or upload after creator publishing APIs, draft persistence, and moderation rules exist.',
      icon: Icons.article_outlined,
      action: TextButton(
        onPressed:
            () => Navigator.pushNamed(context, RouteName.managePortfolio),
        child: const Text('Back to portfolio'),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.title,
    required this.body,
    required this.icon,
    this.action,
  });

  final String title;
  final String body;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34.r, color: AppColors.primaryBlue5),
          SizedBox(height: 12.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: FontSizes.footer2,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
              height: 1.45,
            ),
          ),
          if (action != null) ...[SizedBox(height: 10.h), action!],
        ],
      ),
    );
  }
}
