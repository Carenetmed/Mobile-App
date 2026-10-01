import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/domain/entities/public_professional.dart';
import 'package:app_t/features/Home/presentation/state/search_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FindMentorShellPage extends StatefulWidget {
  const FindMentorShellPage({super.key, this.profileRepository});

  final ProfileRepository? profileRepository;

  @override
  State<FindMentorShellPage> createState() => _FindMentorShellPageState();
}

class _FindMentorShellPageState extends State<FindMentorShellPage> {
  String _selectedCategory = SearchLocalStore.allCategory;
  List<PublicProfessional> _publicProfessionals = const <PublicProfessional>[];
  bool _isLoadingPublicProfessionals = false;
  String? _publicProfessionalsMessage;

  ProfileRepository get _profileRepository =>
      widget.profileRepository ?? sl<ProfileRepository>();

  bool get _hasProfileRepository =>
      widget.profileRepository != null || sl.isRegistered<ProfileRepository>();

  bool get _canUseBackend => _hasProfileRepository;

  @override
  void initState() {
    super.initState();
    if (_canUseBackend) {
      _loadPublicProfessionals();
    }
  }

  Future<void> _loadPublicProfessionals() async {
    setState(() {
      _isLoadingPublicProfessionals = true;
      _publicProfessionalsMessage = 'Loading verified professionals...';
    });

    try {
      final professionals = await _profileRepository.publicProfessionals();
      if (!mounted) {
        return;
      }
      setState(() {
        _publicProfessionals = professionals;
        _isLoadingPublicProfessionals = false;
        _publicProfessionalsMessage =
            professionals.isEmpty
                ? 'No verified professionals are available yet.'
                : null;
      });
    } on AuthFailure catch (failure) {
      if (!mounted) {
        return;
      }
      setState(() {
        _publicProfessionals = const <PublicProfessional>[];
        _isLoadingPublicProfessionals = false;
        _publicProfessionalsMessage = _safePublicProfessionalsError(failure);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _publicProfessionals = const <PublicProfessional>[];
        _isLoadingPublicProfessionals = false;
        _publicProfessionalsMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localMentors = SearchLocalStore.filter(
      query: '',
      category: _selectedCategory,
    );
    final backendMentors = _resolvePublicMentors();
    final categories = _resolveCategories();

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          'Find a Mentor',
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
          padding: REdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
          children: [
            SizedBox(
              height: 38.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final selected = category == _selectedCategory;
                  return ChoiceChip(
                    label: Text(category),
                    selected: selected,
                    onSelected:
                        (_) => setState(() => _selectedCategory = category),
                    selectedColor: AppColors.primaryBlue5,
                    backgroundColor: AppColors.kWhite,
                    labelStyle: TextStyle(
                      fontFamily: AppFonts.montserrat,
                      color: selected ? AppColors.kWhite : AppColors.kBlack,
                      fontSize: FontSizes.footer3,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
            if (_canUseBackend)
              ..._backendContent(context, backendMentors)
            else
              ...localMentors.map(
                (mentor) => Padding(
                  padding: REdgeInsets.only(bottom: 12.h),
                  child: _MentorCard(
                    mentor: mentor,
                    onViewDetails: () {
                      Navigator.pushNamed(
                        context,
                        RouteName.specialistDetails,
                        arguments: mentor.id,
                      );
                    },
                    onBook: () {
                      Navigator.pushNamed(context, RouteName.bookAppointment);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _backendContent(
    BuildContext context,
    List<PublicProfessional> mentors,
  ) {
    if (_publicProfessionalsMessage != null) {
      return <Widget>[
        _FindMentorStateCard(message: _publicProfessionalsMessage!),
        SizedBox(height: 12.h),
      ];
    }

    if (_isLoadingPublicProfessionals) {
      return <Widget>[
        const _FindMentorStateCard(
          message: 'Loading verified professionals...',
        ),
        SizedBox(height: 12.h),
      ];
    }

    if (mentors.isEmpty) {
      return <Widget>[
        const _FindMentorStateCard(
          message: 'No verified professionals match this filter yet.',
        ),
        SizedBox(height: 12.h),
      ];
    }

    return mentors
        .map(
          (mentor) => Padding(
            padding: REdgeInsets.only(bottom: 12.h),
            child: _PublicMentorCard(
              mentor: mentor,
              onViewDetails: () {
                Navigator.pushNamed(
                  context,
                  RouteName.specialistDetails,
                  arguments: mentor.id,
                );
              },
            ),
          ),
        )
        .toList(growable: false);
  }

  List<PublicProfessional> _resolvePublicMentors() {
    return _publicProfessionals
        .where((mentor) {
          if (_selectedCategory == SearchLocalStore.allCategory) {
            return true;
          }
          final category = mentor.category.trim();
          final specialty = mentor.specialty?.trim();
          return category == _selectedCategory ||
              specialty == _selectedCategory;
        })
        .toList(growable: false);
  }

  List<String> _resolveCategories() {
    if (!_canUseBackend) {
      return SearchLocalStore.categories;
    }
    final categories = <String>{SearchLocalStore.allCategory};
    for (final professional in _publicProfessionals) {
      final category = professional.category.trim();
      if (category.isNotEmpty) {
        categories.add(category);
      }
      final specialty = professional.specialty?.trim();
      if (specialty != null && specialty.isNotEmpty) {
        categories.add(specialty);
      }
    }
    return categories.toList(growable: false);
  }

  String _safePublicProfessionalsError(AuthFailure failure) {
    return switch (failure.type) {
      AuthFailureType.missingConfiguration => 'Backend is not configured yet.',
      AuthFailureType.unauthorized => 'Please sign in again.',
      AuthFailureType.forbidden => 'This account cannot access this directory.',
      AuthFailureType.validation => 'Please check the details and try again.',
      AuthFailureType.server ||
      AuthFailureType.network => 'Service is unavailable. Please try again.',
      AuthFailureType.invalidCredentials ||
      AuthFailureType.unknown => 'Something went wrong. Please try again.',
    };
  }
}

class _PublicMentorCard extends StatelessWidget {
  const _PublicMentorCard({required this.mentor, required this.onViewDetails});

  final PublicProfessional mentor;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  color: AppColors.kWhite,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.primaryBlue5,
                  size: 28.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mentor.displayName,
                      style: TextStyle(
                        fontSize: FontSizes.footer2,
                        fontFamily: AppFonts.montserrat,
                        fontWeight: FontWeight.w700,
                        color: AppColors.kBlack,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _roleLabel(mentor),
                      style: TextStyle(
                        fontSize: FontSizes.footer4,
                        fontFamily: AppFonts.montserrat,
                        color: AppColors.primaryBlue11,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      mentor.verified ? 'Verified' : 'Not verified',
                      style: TextStyle(
                        fontSize: FontSizes.footer4,
                        fontFamily: AppFonts.montserrat,
                        color: AppColors.primaryBlue11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (mentor.bio?.trim().isNotEmpty == true) ...[
            SizedBox(height: 12.h),
            Text(
              mentor.bio!.trim(),
              style: TextStyle(
                fontSize: FontSizes.footer4,
                fontFamily: AppFonts.montserrat,
                color: AppColors.kBlack,
                height: 1.4,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewDetails,
                  child: const Text('View details'),
                ),
              ),
              SizedBox(width: 8.w),
              const Expanded(
                child: FilledButton(
                  onPressed: null,
                  child: Text('Booking in details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _roleLabel(PublicProfessional mentor) {
    final specialty = mentor.specialty?.trim();
    if (specialty == null || specialty.isEmpty) {
      return mentor.category;
    }
    return '${mentor.category} - $specialty';
  }
}

class _FindMentorStateCard extends StatelessWidget {
  const _FindMentorStateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
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
          color: AppColors.primaryBlue11,
          height: 1.35,
        ),
      ),
    );
  }
}

class _MentorCard extends StatelessWidget {
  const _MentorCard({
    required this.mentor,
    required this.onViewDetails,
    required this.onBook,
  });

  final SearchSpecialist mentor;
  final VoidCallback onViewDetails;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.asset(
                  mentor.imageAsset,
                  width: 64.r,
                  height: 64.r,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        width: 64.r,
                        height: 64.r,
                        color: AppColors.kWhite,
                        child: Icon(
                          Icons.person_outline,
                          color: AppColors.primaryBlue5,
                          size: 28.r,
                        ),
                      ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mentor.name,
                      style: TextStyle(
                        fontSize: FontSizes.footer2,
                        fontFamily: AppFonts.montserrat,
                        fontWeight: FontWeight.w700,
                        color: AppColors.kBlack,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      mentor.role,
                      style: TextStyle(
                        fontSize: FontSizes.footer4,
                        fontFamily: AppFonts.montserrat,
                        color: AppColors.primaryBlue11,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14.r, color: Colors.amber),
                        SizedBox(width: 4.w),
                        Text(mentor.rating),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Available time:',
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              color: AppColors.primaryBlue11,
            ),
          ),
          SizedBox(height: 8.h),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Saturday')),
              Chip(label: Text('10:00am')),
              Chip(label: Text('12:00pm')),
              Chip(label: Text('02:00pm')),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewDetails,
                  child: const Text('View details'),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: FilledButton(
                  onPressed: onBook,
                  child: const Text('Book Appointment'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
