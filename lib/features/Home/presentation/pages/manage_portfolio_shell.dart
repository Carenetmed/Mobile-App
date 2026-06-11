import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/manage_portfolio_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum _PortfolioTab { page, circles }

class ManagePortfolioShellPage extends StatefulWidget {
  const ManagePortfolioShellPage({super.key});

  @override
  State<ManagePortfolioShellPage> createState() =>
      _ManagePortfolioShellPageState();
}

class _ManagePortfolioShellPageState extends State<ManagePortfolioShellPage> {
  _PortfolioTab _tab = _PortfolioTab.page;

  @override
  Widget build(BuildContext context) {
    const portfolio = ManagePortfolioLocalStore.portfolio;

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          'Manage Portfolio',
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
        child: ListView(
          padding: REdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
          children: [
            const _PortfolioHeader(portfolio: portfolio),
            SizedBox(height: 16.h),
            _PortfolioActions(
              onEdit: () => Navigator.pushNamed(context, RouteName.settings),
              onMessage: () => Navigator.pushNamed(context, RouteName.messages),
              onArticles:
                  () =>
                      Navigator.pushNamed(context, RouteName.publishedArticles),
            ),
            SizedBox(height: 16.h),
            _PortfolioTabs(
              selectedTab: _tab,
              onChanged: (tab) => setState(() => _tab = tab),
            ),
            SizedBox(height: 16.h),
            if (_tab == _PortfolioTab.page)
              const _PagePortfolio(portfolio: portfolio)
            else
              const _CirclesPortfolio(portfolio: portfolio),
          ],
        ),
      ),
    );
  }
}

class _PortfolioHeader extends StatelessWidget {
  const _PortfolioHeader({required this.portfolio});

  final ManagedPortfolioContent portfolio;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32.r,
            backgroundColor: AppColors.primaryBlue5,
            child: Text(
              portfolio.ownerName.characters.first,
              style: TextStyle(
                fontSize: FontSizes.body2,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w700,
                color: AppColors.kWhite,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  portfolio.ownerName,
                  style: TextStyle(
                    fontSize: FontSizes.body3,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kBlack,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '${portfolio.profileType} - ${portfolio.rating} - ${portfolio.membersLabel}',
                  style: TextStyle(
                    fontSize: FontSizes.footer4,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlue5,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  portfolio.memberSince,
                  style: TextStyle(
                    fontSize: FontSizes.footer4,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlue11,
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

class _PortfolioActions extends StatelessWidget {
  const _PortfolioActions({
    required this.onEdit,
    required this.onMessage,
    required this.onArticles,
  });

  final VoidCallback onEdit;
  final VoidCallback onMessage;
  final VoidCallback onArticles;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _ActionChipButton(
          icon: Icons.edit_outlined,
          label: 'Edit',
          onTap: onEdit,
        ),
        _ActionChipButton(
          icon: Icons.mail_outline,
          label: 'Message',
          onTap: onMessage,
        ),
        _ActionChipButton(
          icon: Icons.article_outlined,
          label: 'Articles',
          onTap: onArticles,
        ),
        const _ActionChipButton(
          icon: Icons.event_outlined,
          label: 'Events',
          disabledReason: 'Event management needs scheduling APIs.',
        ),
        const _ActionChipButton(
          icon: Icons.trending_up,
          label: 'Boost',
          disabledReason: 'Boosting needs payment and ad-review rules.',
        ),
        const _ActionChipButton(
          icon: Icons.podcasts_outlined,
          label: 'Podcast',
          disabledReason: 'Podcast management needs media APIs.',
        ),
        const _ActionChipButton(
          icon: Icons.ios_share,
          label: 'Share',
          disabledReason: 'Product-approved sharing is deferred.',
        ),
      ],
    );
  }
}

class _PortfolioTabs extends StatelessWidget {
  const _PortfolioTabs({required this.selectedTab, required this.onChanged});

  final _PortfolioTab selectedTab;
  final ValueChanged<_PortfolioTab> onChanged;

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
            label: 'Page',
            selected: selectedTab == _PortfolioTab.page,
            onTap: () => onChanged(_PortfolioTab.page),
          ),
          _TabButton(
            label: 'Circles',
            selected: selectedTab == _PortfolioTab.circles,
            onTap: () => onChanged(_PortfolioTab.circles),
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
            fontSize: FontSizes.footer3,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PagePortfolio extends StatelessWidget {
  const _PagePortfolio({required this.portfolio});

  final ManagedPortfolioContent portfolio;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Page',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            portfolio.pageTitle,
            style: TextStyle(
              fontSize: FontSizes.footer2,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            portfolio.pageSummary,
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
              height: 1.5,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            portfolio.authorName,
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue5,
            ),
          ),
          SizedBox(height: 16.h),
          const _LockedManagementTile(
            icon: Icons.post_add_outlined,
            title: 'Add new article',
            reason:
                'Article publishing needs creator content APIs, drafts, and moderation.',
          ),
          const _LockedManagementTile(
            icon: Icons.upload_file_outlined,
            title: 'Upload new podcast',
            reason: 'Podcast uploads need media processing and ownership APIs.',
          ),
          const _LockedManagementTile(
            icon: Icons.workspace_premium_outlined,
            title: 'Upgrade',
            reason: 'Upgrade needs subscription and payment rules.',
          ),
          SizedBox(height: 16.h),
          ...portfolio.articles.map(
            (article) => _ArticleCard(article: article),
          ),
        ],
      ),
    );
  }
}

class _CirclesPortfolio extends StatelessWidget {
  const _CirclesPortfolio({required this.portfolio});

  final ManagedPortfolioContent portfolio;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Circles',
      child: Column(
        children:
            portfolio.circles
                .map((circle) => _CircleCard(circle: circle))
                .toList(),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            title,
            style: TextStyle(
              fontSize: FontSizes.footer2,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class _LockedManagementTile extends StatelessWidget {
  const _LockedManagementTile({
    required this.icon,
    required this.title,
    required this.reason,
  });

  final IconData icon;
  final String title;
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: reason,
      child: Container(
        width: double.infinity,
        margin: REdgeInsets.only(bottom: 10.h),
        padding: REdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.blue02,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryBlue5, size: 20.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: FontSizes.footer3,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w700,
                      color: AppColors.kBlack,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    reason,
                    style: TextStyle(
                      fontSize: FontSizes.footer4,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryBlue11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Icon(
              Icons.lock_outline,
              color: AppColors.primaryBlue11,
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article});

  final ManagedPortfolioArticle article;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: REdgeInsets.only(bottom: 10.h),
      padding: REdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
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
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 6.h),
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
          SizedBox(height: 8.h),
          Text(
            article.author,
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleCard extends StatelessWidget {
  const _CircleCard({required this.circle});

  final ManagedPortfolioCircle circle;

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
            circle.name,
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            circle.description,
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
              height: 1.4,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            circle.membersLabel,
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.disabledReason,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final child = ActionChip(
      avatar: Icon(icon, size: 18, color: AppColors.primaryBlue5),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: isDisabled ? AppColors.blue02 : AppColors.kWhite,
      labelStyle: TextStyle(
        fontSize: FontSizes.footer4,
        fontFamily: AppFonts.montserrat,
        fontWeight: FontWeight.w600,
        color: isDisabled ? AppColors.primaryBlue11 : AppColors.primaryBlue5,
      ),
      side: BorderSide(color: AppColors.white04),
    );

    if (!isDisabled || disabledReason == null) {
      return child;
    }

    return Tooltip(message: disabledReason!, child: child);
  }
}
