import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/domain/entities/professional_profile.dart';
import 'package:app_t/features/Home/presentation/state/public_profile_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManageProfileShellPage extends StatefulWidget {
  const ManageProfileShellPage({super.key, this.profileRepository});

  final ProfileRepository? profileRepository;

  @override
  State<ManageProfileShellPage> createState() => _ManageProfileShellPageState();
}

class _ManageProfileShellPageState extends State<ManageProfileShellPage> {
  ProfessionalProfile? _professionalProfile;
  bool _isLoadingProfile = true;
  String? _profileError;
  bool _profileLoadCompleted = false;

  ProfileRepository get _profileRepository =>
      widget.profileRepository ?? sl<ProfileRepository>();

  @override
  void initState() {
    super.initState();
    _loadProfessionalProfile();
  }

  Future<void> _loadProfessionalProfile() async {
    setState(() {
      _isLoadingProfile = true;
      _profileError = null;
    });

    try {
      final profile = await _profileRepository.professionalMe();
      if (!mounted) {
        return;
      }
      setState(() {
        _professionalProfile = profile;
        _profileLoadCompleted = true;
      });
    } on AuthFailure catch (failure) {
      if (!mounted) {
        return;
      }
      setState(() {
        _profileError = _safeProfileError(failure);
        _profileLoadCompleted = true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _profileError = 'Something went wrong. Please try again.';
        _profileLoadCompleted = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  String _safeProfileError(AuthFailure failure) {
    return switch (failure.type) {
      AuthFailureType.missingConfiguration => 'Backend is not configured yet.',
      AuthFailureType.unauthorized => 'Please sign in again.',
      AuthFailureType.validation => 'Please check the details and try again.',
      AuthFailureType.server ||
      AuthFailureType.network => 'Service is unavailable. Please try again.',
      AuthFailureType.invalidCredentials ||
      AuthFailureType.unknown => 'Something went wrong. Please try again.',
    };
  }

  @override
  Widget build(BuildContext context) {
    const profile = PublicProfileLocalStore.profile;
    final professional = _professionalProfile;

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
          'Manage Profile',
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
            _ProfileHeader(profile: profile, professional: professional),
            SizedBox(height: 16.h),
            _ProfileReadStateBanner(
              isLoading: _isLoadingProfile,
              error: _profileError,
              isEmpty:
                  _profileLoadCompleted &&
                  !_isLoadingProfile &&
                  _profileError == null &&
                  professional == null,
            ),
            SizedBox(height: 16.h),
            _ManageActions(
              onEditBasic:
                  () => Navigator.pushNamed(context, RouteName.editYourName),
              onMessagePreview:
                  () => Navigator.pushNamed(context, RouteName.messages),
            ),
            SizedBox(height: 16.h),
            _BasicSection(
              profile: profile,
              professional: professional,
              onEditAddress:
                  () => Navigator.pushNamed(context, RouteName.setAddress),
              onEditWebsite:
                  () => Navigator.pushNamed(context, RouteName.editYourWebsite),
            ),
            SizedBox(height: 16.h),
            _AboutSection(
              profile: profile,
              professional: professional,
              onEdit:
                  () => Navigator.pushNamed(context, RouteName.addDescription),
            ),
            SizedBox(height: 16.h),
            const _BusinessSection(),
            SizedBox(height: 16.h),
            _ArticlesSection(
              profile: profile,
              onManage:
                  () => Navigator.pushNamed(context, RouteName.managePortfolio),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile, required this.professional});

  final PublicProfileContent profile;
  final ProfessionalProfile? professional;

  @override
  Widget build(BuildContext context) {
    final displayName = professional?.displayName.trim();
    final category = professional?.category.trim();
    final title =
        displayName == null || displayName.isEmpty
            ? 'Old People Circle'
            : displayName;
    final subtitle =
        category == null || category.isEmpty
            ? 'Circle - ${profile.rating} - 120 members - ${profile.memberSince}'
            : category;

    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 34.r,
            backgroundColor: AppColors.primaryBlue5,
            child: Text(
              title.characters.first,
              style: TextStyle(
                fontSize: FontSizes.body2,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w700,
                color: AppColors.kWhite,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: FontSizes.body2,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kBlack,
                  ),
                ),
              ),
              const Icon(Icons.verified, color: Colors.blueAccent, size: 18),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
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

class _ProfileReadStateBanner extends StatelessWidget {
  const _ProfileReadStateBanner({
    required this.isLoading,
    required this.error,
    required this.isEmpty,
  });

  final bool isLoading;
  final String? error;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final message =
        isLoading
            ? 'Loading professional profile...'
            : error ??
                (isEmpty
                    ? 'Professional profile has not been created yet.'
                    : null);
    if (message == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: FontSizes.footer4,
          fontFamily: AppFonts.montserrat,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBlue5,
        ),
      ),
    );
  }
}

class _ManageActions extends StatelessWidget {
  const _ManageActions({
    required this.onEditBasic,
    required this.onMessagePreview,
  });

  final VoidCallback onEditBasic;
  final VoidCallback onMessagePreview;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _ActionChipButton(
          icon: Icons.edit_outlined,
          label: 'Edit',
          onTap: onEditBasic,
        ),
        _ActionChipButton(
          icon: Icons.mail_outline,
          label: 'Message',
          onTap: onMessagePreview,
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

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: FontSizes.footer2,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kBlack,
                  ),
                ),
              ),
              if (actionLabel != null)
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue5,
                    padding: EdgeInsets.zero,
                    minimumSize: Size(48.w, 32.h),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    actionLabel!,
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
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class _BasicSection extends StatelessWidget {
  const _BasicSection({
    required this.profile,
    required this.professional,
    required this.onEditAddress,
    required this.onEditWebsite,
  });

  final PublicProfileContent profile;
  final ProfessionalProfile? professional;
  final VoidCallback onEditAddress;
  final VoidCallback onEditWebsite;

  @override
  Widget build(BuildContext context) {
    final displayName = professional?.displayName.trim();
    final category = professional?.category.trim();
    final specialty = professional?.specialty?.trim();

    return _Section(
      title: 'Basic',
      actionLabel: 'Edit address',
      onAction: onEditAddress,
      child: Column(
        children: [
          _InfoRow(
            label: 'Personal name',
            value:
                displayName == null || displayName.isEmpty
                    ? 'Dr. ${profile.name}'
                    : displayName,
          ),
          _InfoRow(
            label: 'Business name',
            value:
                displayName == null || displayName.isEmpty
                    ? 'Lagbaja Eye Clinic & Consulting firm'
                    : displayName,
          ),
          _InfoRow(
            label: 'Category',
            value:
                category == null || category.isEmpty ? profile.role : category,
          ),
          if (specialty != null && specialty.isNotEmpty)
            _InfoRow(label: 'Specialty', value: specialty),
          _InfoRow(label: 'Contact Address', value: profile.address),
          _InfoRow(label: 'Website', value: profile.website),
          _InlineActionRow(label: 'Edit website', onPressed: onEditWebsite),
          _InfoRow(label: 'Email address', value: profile.email),
          const _InfoRow(label: 'Phone number', value: '090 123 456 78'),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({
    required this.profile,
    required this.professional,
    required this.onEdit,
  });

  final PublicProfileContent profile;
  final ProfessionalProfile? professional;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final bio = professional?.bio?.trim();

    return _Section(
      title: 'About',
      actionLabel: 'Edit description',
      onAction: onEdit,
      child: Text(
        bio == null || bio.isEmpty ? profile.about : bio,
        style: TextStyle(
          fontSize: FontSizes.footer3,
          fontFamily: AppFonts.montserrat,
          fontWeight: FontWeight.w400,
          color: AppColors.primaryBlue11,
          height: 1.5,
        ),
      ),
    );
  }
}

class _BusinessSection extends StatelessWidget {
  const _BusinessSection();

  static const List<String> _days = <String>[
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Business',
      actionLabel: 'Edit hours',
      onAction: () {
        Navigator.pushNamed(context, RouteName.selectedDates);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule',
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Consultation and meetings schedule',
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
            ),
          ),
          SizedBox(height: 12.h),
          ..._days.map(
            (day) => _InfoRow(label: day, value: 'Available 24 hours'),
          ),
          SizedBox(height: 8.h),
          const _LockedRow(
            label: 'Add members',
            reason: 'Member management needs backend roles and invites.',
          ),
          const _LockedRow(
            label: 'Edit group details',
            reason: 'Business profile editing needs profile APIs.',
          ),
        ],
      ),
    );
  }
}

class _ArticlesSection extends StatelessWidget {
  const _ArticlesSection({required this.profile, required this.onManage});

  final PublicProfileContent profile;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Articles',
      actionLabel: 'Manage',
      onAction: onManage,
      child: Column(
        children:
            profile.articles
                .map((article) => _ArticlePreview(article: article))
                .toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: FontSizes.footer3,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w600,
                color: AppColors.kBlack,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          SizedBox(
            width: 112.w,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: FontSizes.footer4,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryBlue11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineActionRow extends StatelessWidget {
  const _InlineActionRow({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue5,
          padding: REdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

class _LockedRow extends StatelessWidget {
  const _LockedRow({required this.label, required this.reason});

  final String label;
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: reason,
      child: Container(
        margin: REdgeInsets.only(top: 8.h),
        padding: REdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.blue02,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, size: 18),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: FontSizes.footer3,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kBlack,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                reason,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: FontSizes.footer4,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryBlue11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticlePreview extends StatelessWidget {
  const _ArticlePreview({required this.article});

  final PublicProfileArticle article;

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
            article.category,
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
            '${article.author} - ${article.date} - ${article.readTime}',
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
