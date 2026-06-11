import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/communities_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

@immutable
class CommunityProfileRouteArgs {
  const CommunityProfileRouteArgs({
    required this.profile,
    this.isOwner = false,
  });

  final CommunityProfile profile;
  final bool isOwner;
}

class CommunityProfilePage extends StatelessWidget {
  const CommunityProfilePage({
    required this.profile,
    this.isOwner = false,
    super.key,
  });

  final CommunityProfile profile;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
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
          profile.membership.name,
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
        child: SingleChildScrollView(
          padding: REdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileHero(profile: profile),
              if (isOwner) ...[
                SizedBox(height: 16.h),
                _ProfileSection(
                  title: 'Owner note',
                  child: Text(
                    'This community was created locally in the current frontend slice. Posts, member permissions, and moderation are intentionally deferred until backend-backed community management exists.',
                    style: TextStyle(
                      fontSize: FontSizes.footer3,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryBlue11,
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                _ProfileSection(
                  title: 'Settings',
                  child: Column(
                    children: const [
                      _OwnerActionTile(
                        icon: Icons.star_border,
                        title: 'Add to favourites',
                        description: 'Local preference sync is deferred.',
                      ),
                      _OwnerActionTile(
                        icon: Icons.ios_share,
                        title: 'Share Circle',
                        description: 'Product-approved sharing is deferred.',
                      ),
                      _OwnerActionTile(
                        icon: Icons.admin_panel_settings_outlined,
                        title: 'Circle permissions',
                        description:
                            'Roles and permissions need backend support.',
                      ),
                      _OwnerActionTile(
                        icon: Icons.group_add_outlined,
                        title: 'Add members',
                        description:
                            'Invitations wait for delivery and contacts APIs.',
                      ),
                      _OwnerActionTile(
                        icon: Icons.edit_outlined,
                        title: 'Edit circle details',
                        description:
                            'Editing waits for community profile APIs.',
                      ),
                      _OwnerActionTile(
                        icon: Icons.delete_outline,
                        title: 'Delete Circle',
                        description:
                            'Destructive community actions are deferred.',
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 16.h),
              _ProfileSection(
                title: 'Description',
                child: Text(
                  profile.description,
                  style: TextStyle(
                    fontSize: FontSizes.footer3,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryBlue11,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              _ProfileSection(
                title: profile.membership.members,
                child: Column(
                  children:
                      profile.memberPreviews
                          .map((member) => _MemberTile(member: member))
                          .toList(),
                ),
              ),
              SizedBox(height: 16.h),
              _ProfileSection(
                title: 'Community articles',
                child: Column(
                  children:
                      profile.articlePreviews
                          .map((article) => _ArticleCard(article: article))
                          .toList(),
                ),
              ),
              SizedBox(height: 16.h),
              _ProfileSection(
                title: 'Coming events',
                child: Column(
                  children:
                      profile.comingEvents
                          .map((event) => _EventCard(event: event))
                          .toList(),
                ),
              ),
              SizedBox(height: 16.h),
              _ProfileSection(
                title: 'Recent events',
                child: Column(
                  children:
                      profile.recentEvents
                          .map((event) => _EventCard(event: event))
                          .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnerActionTile extends StatelessWidget {
  const _OwnerActionTile({
    required this.icon,
    required this.title,
    required this.description,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : AppColors.primaryBlue5;

    return Tooltip(
      message: description,
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
            Icon(icon, color: color, size: 20.r),
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
                      color: isDestructive ? Colors.red : AppColors.kBlack,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
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

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});

  final CommunityProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: AppColors.primaryBlue5,
            child: Text(
              profile.membership.name.characters.first,
              style: TextStyle(
                fontSize: FontSizes.body2,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w700,
                color: AppColors.kWhite,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            profile.membership.name,
            style: TextStyle(
              fontSize: FontSizes.heading3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            profile.membership.members,
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryBlue5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            profile.membership.description,
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.child});

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

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});

  final CommunityMemberPreview member;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.primaryBlue5,
            child: Text(
              member.name.characters.first,
              style: TextStyle(
                fontSize: FontSizes.footer4,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w700,
                color: AppColors.kWhite,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: TextStyle(
                    fontSize: FontSizes.footer3,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kBlack,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  member.note,
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
          Container(
            padding: REdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.kWhite,
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              member.role,
              style: TextStyle(
                fontSize: FontSizes.footer4,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article});

  final CommunityArticlePreview article;

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
          Container(
            padding: REdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.kWhite,
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              article.category,
              style: TextStyle(
                fontSize: FontSizes.footer4,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue5,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            article.title,
            style: TextStyle(
              fontSize: FontSizes.footer2,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            article.excerpt,
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
              height: 1.4,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            '${article.dateLabel}  •  ${article.readTimeLabel}',
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryBlue5,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final CommunityEventPreview event;

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
            event.trackLabel,
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            event.title,
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            event.scheduleLabel,
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
            ),
          ),
        ],
      ),
    );
  }
}
