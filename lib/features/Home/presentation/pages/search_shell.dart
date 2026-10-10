import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/domain/entities/public_professional.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchShellPage extends StatefulWidget {
  const SearchShellPage({
    super.key,
    this.profileRepository,
    this.schedulingRepository,
    this.now,
  });

  final ProfileRepository? profileRepository;

  // Kept for caller compatibility while availability and booking remain owned
  // by the existing professional-detail surface.
  final SchedulingRepository? schedulingRepository;
  final DateTime? now;

  @override
  State<SearchShellPage> createState() => _SearchShellPageState();
}

class _SearchShellPageState extends State<SearchShellPage> {
  static const String _allCategory = 'All';

  final TextEditingController _searchController = TextEditingController();
  List<PublicProfessional> _professionals = const <PublicProfessional>[];
  String _selectedCategory = _allCategory;
  bool _hasLoaded = false;
  bool _initialLoading = true;
  bool _refreshing = false;
  String? _initialError;
  String? _refreshError;
  Future<void>? _activeLoad;
  int _loadGeneration = 0;

  ProfileRepository get _profileRepository =>
      widget.profileRepository ?? sl<ProfileRepository>();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    _requestLoad();
  }

  @override
  void didUpdateWidget(covariant SearchShellPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileRepository != widget.profileRepository) {
      _requestLoad(supersede: true);
    }
  }

  @override
  void dispose() {
    _loadGeneration += 1;
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    setState(() {});
  }

  Future<void> _requestLoad({bool supersede = false}) {
    final current = _activeLoad;
    if (current != null && !supersede) {
      return current;
    }

    final generation = ++_loadGeneration;
    final operation = _performLoad(generation);
    _activeLoad = operation;
    return operation;
  }

  Future<void> _performLoad(int generation) async {
    setState(() {
      if (_hasLoaded) {
        _refreshing = true;
        _refreshError = null;
      } else {
        _initialLoading = true;
        _initialError = null;
      }
    });

    try {
      final professionals = await _profileRepository.publicProfessionals();
      if (!mounted || generation != _loadGeneration) return;

      final accepted = professionals
          .where(_isUsableProfessional)
          .toList(growable: false);
      setState(() {
        _professionals = accepted;
        _hasLoaded = true;
        _initialLoading = false;
        _refreshing = false;
        _initialError = null;
        _refreshError = null;
        if (!_availableCategories(accepted).contains(_selectedCategory)) {
          _selectedCategory = _allCategory;
        }
      });
    } catch (error) {
      if (!mounted || generation != _loadGeneration) return;

      final message = _safeListingError(error);
      setState(() {
        _initialLoading = false;
        _refreshing = false;
        if (_hasLoaded) {
          _refreshError = message;
        } else {
          _initialError = message;
        }
      });
    } finally {
      if (generation == _loadGeneration) {
        _activeLoad = null;
      }
    }
  }

  bool _isUsableProfessional(PublicProfessional professional) {
    return professional.verified &&
        professional.id.trim().isNotEmpty &&
        professional.displayName.trim().isNotEmpty &&
        professional.category.trim().isNotEmpty;
  }

  String _safeListingError(Object error) {
    if (error is AuthFailure) {
      return switch (error.type) {
        AuthFailureType.missingConfiguration =>
          'This directory is unavailable right now. Please try again.',
        AuthFailureType.unauthorized => 'Please sign in again.',
        AuthFailureType.forbidden =>
          'This account cannot access this directory.',
        AuthFailureType.validation => 'Please check the details and try again.',
        AuthFailureType.server ||
        AuthFailureType.network => 'Service is unavailable. Please try again.',
        AuthFailureType.invalidCredentials ||
        AuthFailureType.unknown => 'Something went wrong. Please try again.',
      };
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredProfessionals();
    final categories = _availableCategories(_professionals);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _requestLoad,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: REdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
            children: [
              _FindCareHeading(
                refreshing: _refreshing,
                onRefresh: _activeLoad == null ? _requestLoad : null,
              ),
              SizedBox(height: 14.h),
              if (_initialLoading && !_hasLoaded)
                const _FindCareStatePanel.loading()
              else if (_initialError != null && !_hasLoaded)
                _FindCareStatePanel.failure(
                  message: _initialError!,
                  onRetry: _requestLoad,
                )
              else ...[
                if (_refreshError != null) ...[
                  _RefreshFailureBanner(
                    message: _refreshError!,
                    onRetry: _activeLoad == null ? _requestLoad : null,
                  ),
                  SizedBox(height: 14.h),
                ],
                if (_refreshing) ...[
                  const LinearProgressIndicator(),
                  SizedBox(height: 14.h),
                ],
                if (_professionals.isEmpty)
                  _FindCareStatePanel.empty(onRefresh: _requestLoad)
                else ...[
                  CarenetTextField(
                    controller: _searchController,
                    hintText:
                        'Search by professional name, category, or specialty',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isEmpty
                            ? null
                            : IconButton(
                              tooltip: 'Clear search',
                              icon: const Icon(Icons.close),
                              onPressed: _searchController.clear,
                            ),
                  ),
                  SizedBox(height: 14.h),
                  _CategorySelector(
                    categories: categories,
                    selected: _selectedCategory,
                    onSelected:
                        (category) =>
                            setState(() => _selectedCategory = category),
                  ),
                  SizedBox(height: 20.h),
                  _ResultSummary(count: results.length),
                  SizedBox(height: 12.h),
                  if (results.isEmpty)
                    _FilteredEmptyState(onReset: _resetFilters)
                  else
                    ...results.map(
                      (professional) => Padding(
                        padding: REdgeInsets.only(bottom: 12.h),
                        child: _ProfessionalResultCard(
                          professional: professional,
                          onSelected:
                              () => Navigator.pushNamed(
                                context,
                                RouteName.specialistDetails,
                                arguments: professional.id,
                              ),
                        ),
                      ),
                    ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = _allCategory;
      _searchController.clear();
    });
  }

  List<PublicProfessional> _filteredProfessionals() {
    final query = _searchController.text.trim().toLowerCase();
    return _professionals
        .where((professional) {
          final category = professional.category.trim();
          final specialty = professional.specialty?.trim() ?? '';
          final categoryMatches =
              _selectedCategory == _allCategory ||
              category.toLowerCase() == _selectedCategory.toLowerCase() ||
              specialty.toLowerCase() == _selectedCategory.toLowerCase();
          if (!categoryMatches) return false;
          if (query.isEmpty) return true;

          return professional.displayName.trim().toLowerCase().contains(
                query,
              ) ||
              category.toLowerCase().contains(query) ||
              specialty.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  List<String> _availableCategories(List<PublicProfessional> professionals) {
    final categories = <String>{_allCategory};
    for (final professional in professionals) {
      final category = professional.category.trim();
      if (category.isNotEmpty) categories.add(category);
      final specialty = professional.specialty?.trim();
      if (specialty != null && specialty.isNotEmpty) {
        categories.add(specialty);
      }
    }
    return categories.toList(growable: false);
  }
}

class _FindCareHeading extends StatelessWidget {
  const _FindCareHeading({required this.refreshing, required this.onRefresh});

  final bool refreshing;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find Care',
                style: TextStyle(
                  fontSize: FontSizes.heading3,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Browse verified healthcare professionals.',
                style: TextStyle(
                  fontSize: FontSizes.footer2,
                  fontFamily: AppFonts.montserrat,
                  color: AppColors.primaryBlue11,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: refreshing ? 'Refreshing Find Care' : 'Refresh Find Care',
          onPressed: onRefresh,
          icon:
              refreshing
                  ? SizedBox.square(
                    dimension: 20.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(Icons.refresh),
        ),
      ],
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        key: const ValueKey<String>('find-care-category-list'),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selected;
          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (_) => onSelected(category),
            selectedColor: AppColors.primaryBlue5,
            backgroundColor: AppColors.kWhite,
            labelStyle: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.kWhite : AppColors.kBlack,
              fontSize: FontSizes.footer3,
            ),
            side: BorderSide(
              color: isSelected ? AppColors.primaryBlue5 : AppColors.white04,
            ),
          );
        },
      ),
    );
  }
}

class _ResultSummary extends StatelessWidget {
  const _ResultSummary({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Verified professionals',
            style: TextStyle(
              fontSize: FontSizes.body3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
        ),
        Text(
          '$count found',
          style: TextStyle(
            fontSize: FontSizes.footer3,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryBlue11,
          ),
        ),
      ],
    );
  }
}

class _ProfessionalResultCard extends StatelessWidget {
  const _ProfessionalResultCard({
    required this.professional,
    required this.onSelected,
  });

  final PublicProfessional professional;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final specialty = professional.specialty?.trim();
    final bio = professional.bio?.trim();
    return Container(
      padding: REdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color: AppColors.blue02,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.medical_services_outlined,
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
                  professional.displayName.trim(),
                  style: TextStyle(
                    fontSize: FontSizes.footer2,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kBlack,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  specialty == null || specialty.isEmpty
                      ? professional.category.trim()
                      : '${professional.category.trim()} - $specialty',
                  style: TextStyle(
                    fontSize: FontSizes.footer4,
                    fontFamily: AppFonts.montserrat,
                    color: AppColors.primaryBlue11,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 7.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 15.r,
                      color: AppColors.primaryBlue5,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: FontSizes.footer4,
                        fontFamily: AppFonts.montserrat,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue5,
                      ),
                    ),
                  ],
                ),
                if (bio != null && bio.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    bio,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: FontSizes.footer4,
                      fontFamily: AppFonts.montserrat,
                      color: AppColors.kBlack,
                      height: 1.4,
                    ),
                  ),
                ],
                SizedBox(height: 10.h),
                OutlinedButton(
                  onPressed: onSelected,
                  child: Text(
                    'View profile',
                    semanticsLabel:
                        'View profile for ${professional.displayName.trim()}',
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

class _FindCareStatePanel extends StatelessWidget {
  const _FindCareStatePanel._({
    required this.icon,
    required this.title,
    required this.message,
    this.loading = false,
    this.actionLabel,
    this.onAction,
  });

  const _FindCareStatePanel.loading()
    : this._(
        icon: Icons.manage_search_outlined,
        title: 'Loading verified professionals',
        message: 'CareNet is checking the current public care directory.',
        loading: true,
      );

  factory _FindCareStatePanel.failure({
    required String message,
    required VoidCallback onRetry,
  }) {
    return _FindCareStatePanel._(
      icon: Icons.cloud_off_outlined,
      title: 'Find Care is unavailable',
      message: message,
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }

  factory _FindCareStatePanel.empty({required VoidCallback onRefresh}) {
    return _FindCareStatePanel._(
      icon: Icons.medical_services_outlined,
      title: 'No verified professionals are listed yet',
      message: 'The public care directory is currently empty.',
      actionLabel: 'Refresh',
      onAction: onRefresh,
    );
  }

  final IconData icon;
  final String title;
  final String message;
  final bool loading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        children: [
          if (loading)
            const CircularProgressIndicator()
          else
            Icon(icon, color: AppColors.primaryBlue5, size: 36.r),
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
          SizedBox(height: 6.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              color: AppColors.primaryBlue11,
              height: 1.4,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: 12.h),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _FilteredEmptyState extends StatelessWidget {
  const _FilteredEmptyState({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, color: AppColors.primaryBlue5, size: 36.r),
          SizedBox(height: 10.h),
          Text(
            'No matching professionals',
            style: TextStyle(
              fontSize: FontSizes.footer2,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Try another professional name, category, or specialty.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              color: AppColors.primaryBlue11,
            ),
          ),
          SizedBox(height: 12.h),
          OutlinedButton(
            onPressed: onReset,
            child: const Text('Clear filters'),
          ),
        ],
      ),
    );
  }
}

class _RefreshFailureBanner extends StatelessWidget {
  const _RefreshFailureBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.kLightYellow,
      borderRadius: BorderRadius.circular(8.r),
      child: ListTile(
        leading: const Icon(Icons.sync_problem_outlined),
        title: const Text('Could not refresh Find Care'),
        subtitle: Text('$message Previous results are still shown.'),
        trailing: IconButton(
          tooltip: 'Retry Find Care refresh',
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}
