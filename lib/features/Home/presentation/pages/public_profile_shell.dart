import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/public_profile_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PublicProfileShellPage extends StatelessWidget {
  const PublicProfileShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    const profile = PublicProfileLocalStore.profile;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF007AFF),
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: REdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          children: [
            const _ProfileHeader(profile: profile),
            SizedBox(height: 12.h),
            _ProfileActions(
              onMessage:
                  () => Navigator.of(context).pushNamed(RouteName.messages),
              onSchedule:
                  () => Navigator.of(
                    context,
                  ).pushNamed(RouteName.bookAppointment),
            ),
            SizedBox(height: 12.h),
            const _ProfileArticles(profile: profile),
            SizedBox(height: 12.h),
            const _ProfileSpecializations(profile: profile),
            SizedBox(height: 12.h),
            const _ProfileContact(profile: profile),
            SizedBox(height: 12.h),
            const _ProfileAbout(profile: profile),
            SizedBox(height: 12.h),
            ...profile.sections.map(
              (section) => Padding(
                padding: REdgeInsets.only(bottom: 12.h),
                child: _ProfileTextSection(section: section),
              ),
            ),
            const _ProfileBoundaryNote(),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final PublicProfileContent profile;

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
        children: [
          CircleAvatar(
            radius: 44.r,
            backgroundColor: AppColors.primaryBlue5,
            child: Text(
              profile.name.substring(0, 1),
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w800,
                fontSize: 28.sp,
                color: AppColors.kWhite,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w800,
                    fontSize: FontSizes.body3,
                    color: AppColors.kBlack,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.verified, color: AppColors.primaryBlue5, size: 18.r),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            profile.role,
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w500,
              fontSize: FontSizes.footer2,
              color: AppColors.primaryBlue11,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _ProfileMetaPill(icon: Icons.star, label: profile.rating),
              _ProfileMetaPill(icon: Icons.place, label: profile.location),
              _ProfileMetaPill(icon: Icons.event, label: profile.memberSince),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileMetaPill extends StatelessWidget {
  const _ProfileMetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F0),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.r, color: AppColors.primaryBlue5),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w600,
              fontSize: FontSizes.footer3,
              color: AppColors.primaryBlue11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActions extends StatelessWidget {
  const _ProfileActions({required this.onMessage, required this.onSchedule});

  final VoidCallback onMessage;
  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: [
          ElevatedButton.icon(
            onPressed: onMessage,
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Message'),
          ),
          OutlinedButton.icon(
            onPressed: onSchedule,
            icon: const Icon(Icons.calendar_month_outlined),
            label: const Text('Schedule'),
          ),
          Tooltip(
            message:
                'Portfolio opens after creator portfolio APIs are defined.',
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.work_outline),
              label: const Text('Portfolio'),
            ),
          ),
          Tooltip(
            message: 'Podcast profile content waits for media APIs.',
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.podcasts_outlined),
              label: const Text('Podcast'),
            ),
          ),
          Tooltip(
            message: 'Sharing waits for product-approved share behavior.',
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.ios_share_outlined),
              label: const Text('Share'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileArticles extends StatelessWidget {
  const _ProfileArticles({required this.profile});

  final PublicProfileContent profile;

  @override
  Widget build(BuildContext context) {
    return _ProfileSectionCard(
      title: 'Articles',
      child: Column(
        children: profile.articles
            .map(
              (article) => Padding(
                padding: REdgeInsets.only(bottom: 10.h),
                child: _ProfileArticleCard(article: article),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _ProfileArticleCard extends StatelessWidget {
  const _ProfileArticleCard({required this.article});

  final PublicProfileArticle article;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SmallLabel(article.category),
          SizedBox(height: 8.h),
          Text(
            article.title,
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              fontSize: FontSizes.footer2,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            article.summary,
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              fontSize: FontSizes.footer3,
              color: AppColors.primaryBlue11,
              height: 1.4,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${article.author} • ${article.date} • ${article.readTime}',
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w500,
              fontSize: FontSizes.footer4,
              color: AppColors.primaryBlue11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSpecializations extends StatelessWidget {
  const _ProfileSpecializations({required this.profile});

  final PublicProfileContent profile;

  @override
  Widget build(BuildContext context) {
    return _ProfileSectionCard(
      title: 'Specialization',
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: profile.specializations
            .map((label) => _SmallLabel(label))
            .toList(growable: false),
      ),
    );
  }
}

class _ProfileContact extends StatelessWidget {
  const _ProfileContact({required this.profile});

  final PublicProfileContent profile;

  @override
  Widget build(BuildContext context) {
    return _ProfileSectionCard(
      title: 'Contact',
      child: Column(
        children: [
          _ContactRow(icon: Icons.schedule, label: 'Open now - 24/7'),
          _ContactRow(icon: Icons.email_outlined, label: profile.email),
          _ContactRow(icon: Icons.language, label: profile.website),
          _ContactRow(icon: Icons.place_outlined, label: profile.address),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.r, color: AppColors.primaryBlue5),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w500,
                fontSize: FontSizes.footer2,
                color: AppColors.primaryBlue11,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAbout extends StatelessWidget {
  const _ProfileAbout({required this.profile});

  final PublicProfileContent profile;

  @override
  Widget build(BuildContext context) {
    return _ProfileSectionCard(
      title: 'About me',
      child: Text(
        profile.about,
        style: TextStyle(
          fontFamily: AppFonts.montserrat,
          fontWeight: FontWeight.w400,
          fontSize: FontSizes.footer2,
          color: AppColors.primaryBlue11,
          height: 1.45,
        ),
      ),
    );
  }
}

class _ProfileTextSection extends StatelessWidget {
  const _ProfileTextSection({required this.section});

  final PublicProfileSection section;

  @override
  Widget build(BuildContext context) {
    return _ProfileSectionCard(
      title: section.title,
      child: Text(
        section.body,
        style: TextStyle(
          fontFamily: AppFonts.montserrat,
          fontWeight: FontWeight.w400,
          fontSize: FontSizes.footer2,
          color: AppColors.primaryBlue11,
          height: 1.45,
        ),
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

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
            title,
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w800,
              fontSize: FontSizes.body3,
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

class _SmallLabel extends StatelessWidget {
  const _SmallLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F0),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.montserrat,
          fontWeight: FontWeight.w700,
          fontSize: FontSizes.footer3,
          color: AppColors.primaryBlue5,
        ),
      ),
    );
  }
}

class _ProfileBoundaryNote extends StatelessWidget {
  const _ProfileBoundaryNote();

  @override
  Widget build(BuildContext context) {
    return Text(
      'This public profile uses local content for now. Later profile, creator portfolio, media, sharing, and scheduling APIs should replace the data source without changing this read-only profile surface.',
      style: TextStyle(
        fontFamily: AppFonts.montserrat,
        fontWeight: FontWeight.w500,
        fontSize: FontSizes.footer3,
        color: AppColors.primaryBlue5,
        height: 1.4,
      ),
    );
  }
}
