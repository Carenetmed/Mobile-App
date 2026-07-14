import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/domain/entities/appointment_request_time_option.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/availability_window.dart';
import 'package:app_t/features/Home/domain/entities/public_professional.dart';
import 'package:app_t/features/Home/domain/services/appointment_request_time_options.dart';
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
  final SchedulingRepository? schedulingRepository;
  final DateTime? now;

  @override
  State<SearchShellPage> createState() => _SearchShellPageState();
}

class _SearchShellPageState extends State<SearchShellPage> {
  static const String _allCategory = 'All';

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = _allCategory;
  List<PublicProfessional> _publicProfessionals = const <PublicProfessional>[];
  String? _publicListingMessage;
  bool _isLoadingPublicProfessionals = true;

  ProfileRepository get _profileRepository =>
      widget.profileRepository ?? sl<ProfileRepository>();

  SchedulingRepository get _schedulingRepository =>
      widget.schedulingRepository ?? sl<SchedulingRepository>();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    _loadPublicProfessionals();
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    setState(() {});
  }

  Future<void> _loadPublicProfessionals() async {
    setState(() {
      _isLoadingPublicProfessionals = true;
      _publicListingMessage = 'Loading verified professionals...';
    });

    try {
      final professionals = await _profileRepository.publicProfessionals();
      if (!mounted) {
        return;
      }
      setState(() {
        _publicProfessionals = professionals;
        _isLoadingPublicProfessionals = false;
        _publicListingMessage =
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
        _publicListingMessage = _safePublicListingError(failure);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _publicProfessionals = const <PublicProfessional>[];
        _isLoadingPublicProfessionals = false;
        _publicListingMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  String _safePublicListingError(AuthFailure failure) {
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
    final professionals = _resolveProfessionals(
      query: _searchController.text,
      category: _selectedCategory,
    );
    final categories = _resolveCategories();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: ListView(
          padding: REdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
          children: [
            Text(
              'Search specialists',
              style: TextStyle(
                fontSize: FontSizes.heading3,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w700,
                color: AppColors.kBlack,
              ),
            ),
            SizedBox(height: 14.h),
            if (_publicListingMessage != null) ...[
              _PublicListingStateCard(message: _publicListingMessage!),
              SizedBox(height: 14.h),
            ],
            CarenetTextField(
              controller: _searchController,
              hintText: 'Search by specialist or condition',
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
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? AppColors.kWhite : AppColors.kBlack,
                      fontSize: FontSizes.footer3,
                    ),
                    side: BorderSide(
                      color:
                          selected ? AppColors.primaryBlue5 : AppColors.white04,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Available specialists',
                    style: TextStyle(
                      fontSize: FontSizes.body3,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w700,
                      color: AppColors.kBlack,
                    ),
                  ),
                ),
                Text(
                  '${professionals.length} found',
                  style: TextStyle(
                    fontSize: FontSizes.footer3,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlue11,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (_isLoadingPublicProfessionals)
              const SizedBox.shrink()
            else if (professionals.isEmpty)
              _SearchEmptyState(
                onReset:
                    () => setState(() {
                      _selectedCategory = _allCategory;
                      _searchController.clear();
                    }),
              )
            else
              ...professionals.map(
                (professional) => Padding(
                  padding: REdgeInsets.only(bottom: 12.h),
                  child: _SpecialistCard(
                    professional: professional,
                    onViewProfile:
                        () => _showSpecialistProfile(context, professional),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<_SearchProfessionalView> _resolveProfessionals({
    required String query,
    required String category,
  }) {
    return _publicProfessionals
        .map(_SearchProfessionalView.fromPublic)
        .where((professional) => professional.matches(query, category))
        .toList(growable: false);
  }

  List<String> _resolveCategories() {
    final categories = <String>{_allCategory};
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

  void _showSpecialistProfile(
    BuildContext context,
    _SearchProfessionalView specialist,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder:
          (context) => Padding(
            padding: REdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  specialist.name,
                  style: TextStyle(
                    fontSize: FontSizes.body2,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kBlack,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  specialist.role,
                  style: TextStyle(
                    fontSize: FontSizes.footer2,
                    fontFamily: AppFonts.montserrat,
                    color: AppColors.primaryBlue11,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  specialist.summary,
                  style: TextStyle(
                    fontSize: FontSizes.footer2,
                    fontFamily: AppFonts.montserrat,
                    color: AppColors.kBlack,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16.h),
                _PublicAvailabilitySection(
                  professionalProfileId: specialist.id,
                  schedulingRepository: _schedulingRepository,
                  now: widget.now ?? DateTime.now(),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class _PublicAvailabilitySection extends StatefulWidget {
  const _PublicAvailabilitySection({
    required this.professionalProfileId,
    required this.schedulingRepository,
    required this.now,
  });

  final String professionalProfileId;
  final SchedulingRepository schedulingRepository;
  final DateTime now;

  @override
  State<_PublicAvailabilitySection> createState() =>
      _PublicAvailabilitySectionState();
}

class _PublicAvailabilitySectionState
    extends State<_PublicAvailabilitySection> {
  static const AppointmentRequestTimeOptions _timeOptions =
      AppointmentRequestTimeOptions();

  late final Future<List<AvailabilityWindow>> _availabilityFuture;
  AppointmentRequestTimeOption? _selectedOption;
  bool _isRequestingAppointment = false;
  String? _requestMessage;

  @override
  void initState() {
    super.initState();
    _availabilityFuture = widget.schedulingRepository.publicAvailability(
      professionalProfileId: widget.professionalProfileId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AvailabilityWindow>>(
      future: _availabilityFuture,
      builder: (context, snapshot) {
        final state = snapshot.connectionState;
        if (state == ConnectionState.waiting ||
            state == ConnectionState.active) {
          return const _AvailabilityStateCard(
            message: 'Loading public availability...',
          );
        }

        if (snapshot.hasError) {
          return _AvailabilityStateCard(
            message: _safeAvailabilityError(snapshot.error),
          );
        }

        final windows = snapshot.data ?? const <AvailabilityWindow>[];
        if (windows.isEmpty) {
          return const _AvailabilityStateCard(
            message: 'No public availability is available yet.',
          );
        }

        final requestOptions = _timeOptions.generate(
          windows: windows,
          now: widget.now,
        );
        _selectedOption ??=
            requestOptions.isEmpty ? null : requestOptions.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Public availability',
              style: TextStyle(
                fontSize: FontSizes.footer3,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w700,
                color: AppColors.kBlack,
              ),
            ),
            SizedBox(height: 8.h),
            ...windows.map(
              (window) => Padding(
                padding: REdgeInsets.only(bottom: 6.h),
                child: _AvailabilityWindowRow(window: window),
              ),
            ),
            SizedBox(height: 12.h),
            if (requestOptions.isEmpty)
              const _AvailabilityStateCard(
                message: 'No requestable times in the next seven days.',
              )
            else ...[
              Text(
                'Request appointment',
                style: TextStyle(
                  fontSize: FontSizes.footer3,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children:
                    requestOptions
                        .map(
                          (option) => ChoiceChip(
                            label: Text(_optionLabel(option)),
                            selected: option == _selectedOption,
                            onSelected:
                                _isRequestingAppointment
                                    ? null
                                    : (_) => setState(() {
                                      _selectedOption = option;
                                      _requestMessage = null;
                                    }),
                          ),
                        )
                        .toList(),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      _isRequestingAppointment || _selectedOption == null
                          ? null
                          : _requestAppointment,
                  child: Text(
                    _isRequestingAppointment
                        ? 'Sending request...'
                        : 'Request selected time',
                  ),
                ),
              ),
            ],
            if (_requestMessage != null) ...[
              SizedBox(height: 8.h),
              _AvailabilityStateCard(message: _requestMessage!),
            ],
          ],
        );
      },
    );
  }

  Future<void> _requestAppointment() async {
    final option = _selectedOption;
    if (option == null) {
      return;
    }

    setState(() {
      _isRequestingAppointment = true;
      _requestMessage = null;
    });

    try {
      final appointment = await widget.schedulingRepository.requestAppointment(
        professionalProfileId: widget.professionalProfileId,
        requestedStartAt: option.requestedStartAt,
        durationMinutes: option.durationMinutes,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isRequestingAppointment = false;
        _requestMessage =
            'Request sent. Backend status: ${appointment.status.wireName}.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isRequestingAppointment = false;
        _requestMessage = _safeAppointmentRequestError(error);
      });
    }
  }

  static String _optionLabel(AppointmentRequestTimeOption option) {
    final date = option.requestedStartAt;
    final dateLabel =
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}';
    return '$dateLabel ${option.timeRangeLabel} '
        '(${option.durationMinutes} min)';
  }

  static String _safeAvailabilityError(Object? error) {
    if (error is AuthFailure) {
      return switch (error.type) {
        AuthFailureType.missingConfiguration =>
          'Backend is not configured yet.',
        AuthFailureType.unauthorized => 'Please sign in again.',
        AuthFailureType.validation =>
          'Please choose an available time and try again.',
        AuthFailureType.server ||
        AuthFailureType.network => 'Service is unavailable. Please try again.',
        AuthFailureType.invalidCredentials ||
        AuthFailureType.unknown => 'Something went wrong. Please try again.',
      };
    }
    return 'Something went wrong. Please try again.';
  }

  static String _safeAppointmentRequestError(Object? error) {
    if (error is AuthFailure) {
      return switch (error.type) {
        AuthFailureType.missingConfiguration =>
          'Backend is not configured yet.',
        AuthFailureType.unauthorized => 'Please sign in again.',
        AuthFailureType.validation =>
          'Please choose an available time and try again.',
        AuthFailureType.server ||
        AuthFailureType.network => 'Service is unavailable. Please try again.',
        AuthFailureType.invalidCredentials ||
        AuthFailureType.unknown => 'Something went wrong. Please try again.',
      };
    }
    return 'Something went wrong. Please try again.';
  }
}

class _AvailabilityWindowRow extends StatelessWidget {
  const _AvailabilityWindowRow({required this.window});

  final AvailabilityWindow window;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Text(
        'Day ${window.weekday}: ${_timeLabel(window.startMinute)} - ${_timeLabel(window.endMinute)} (${window.timezone})',
        style: TextStyle(
          fontSize: FontSizes.footer4,
          fontFamily: AppFonts.montserrat,
          fontWeight: FontWeight.w600,
          color: AppColors.kBlack,
          height: 1.35,
        ),
      ),
    );
  }

  String _timeLabel(int minuteOfDay) {
    final hours = minuteOfDay ~/ 60;
    final minutes = minuteOfDay % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}

class _AvailabilityStateCard extends StatelessWidget {
  const _AvailabilityStateCard({required this.message});

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

class _SpecialistCard extends StatelessWidget {
  const _SpecialistCard({
    required this.professional,
    required this.onViewProfile,
  });

  final _SearchProfessionalView professional;
  final VoidCallback onViewProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              width: 72.r,
              height: 72.r,
              color: AppColors.blue02,
              child: Icon(
                Icons.verified_user_outlined,
                color: AppColors.primaryBlue5,
                size: 30.r,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  professional.name,
                  style: TextStyle(
                    fontSize: FontSizes.footer2,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kBlack,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  professional.role,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: FontSizes.footer4,
                    fontFamily: AppFonts.montserrat,
                    color: AppColors.primaryBlue11,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 4.h,
                  children:
                      professional.metaLabels
                          .map(
                            (label) => _MetaLabel(
                              icon: label.icon,
                              label: label.label,
                            ),
                          )
                          .toList(),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 6.h,
                  children: [
                    OutlinedButton(
                      onPressed: onViewProfile,
                      child: const Text('View profile'),
                    ),
                    FilledButton.icon(
                      onPressed: null,
                      icon: Icon(Icons.calendar_today_outlined, size: 18.r),
                      label: const Text('Booking deferred'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchProfessionalView {
  const _SearchProfessionalView({
    required this.id,
    required this.name,
    required this.role,
    required this.categories,
    required this.summary,
    required this.metaLabels,
  });

  factory _SearchProfessionalView.fromPublic(PublicProfessional professional) {
    final category = professional.category.trim();
    final specialty = professional.specialty?.trim();
    final categories = <String>[
      if (category.isNotEmpty) category,
      if (specialty != null && specialty.isNotEmpty) specialty,
    ];
    return _SearchProfessionalView(
      id: professional.id,
      name: professional.displayName,
      role:
          specialty == null || specialty.isEmpty
              ? category
              : '$category - $specialty',
      categories: categories,
      summary:
          professional.bio?.trim().isNotEmpty == true
              ? professional.bio!.trim()
              : 'Verified professional profile.',
      metaLabels: const <_ProfessionalMetaLabel>[
        _ProfessionalMetaLabel(
          icon: Icons.verified_outlined,
          label: 'Verified',
        ),
      ],
    );
  }

  final String id;
  final String name;
  final String role;
  final List<String> categories;
  final String summary;
  final List<_ProfessionalMetaLabel> metaLabels;

  bool matches(String query, String category) {
    final normalizedQuery = query.trim().toLowerCase();
    final categoryMatches =
        category == _SearchShellPageState._allCategory ||
        categories.any((item) => item.toLowerCase() == category.toLowerCase());

    if (!categoryMatches) {
      return false;
    }
    if (normalizedQuery.isEmpty) {
      return true;
    }

    return name.toLowerCase().contains(normalizedQuery) ||
        role.toLowerCase().contains(normalizedQuery) ||
        summary.toLowerCase().contains(normalizedQuery) ||
        categories.any((item) => item.toLowerCase().contains(normalizedQuery));
  }
}

class _ProfessionalMetaLabel {
  const _ProfessionalMetaLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _PublicListingStateCard extends StatelessWidget {
  const _PublicListingStateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
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
          height: 1.35,
        ),
      ),
    );
  }
}

class _MetaLabel extends StatelessWidget {
  const _MetaLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.r, color: AppColors.primaryBlue5),
        SizedBox(width: 3.w),
        Text(
          label,
          style: TextStyle(
            fontSize: FontSizes.footer4,
            fontFamily: AppFonts.montserrat,
            color: AppColors.kBlack,
          ),
        ),
      ],
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, color: AppColors.primaryBlue5, size: 36.r),
          SizedBox(height: 10.h),
          Text(
            'No specialists found',
            style: TextStyle(
              fontSize: FontSizes.footer2,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Try another specialist, condition, or category.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              color: AppColors.primaryBlue11,
            ),
          ),
          SizedBox(height: 12.h),
          TextButton(onPressed: onReset, child: const Text('Reset search')),
        ],
      ),
    );
  }
}

class DashboardShellScaffold extends StatelessWidget {
  const DashboardShellScaffold({
    super.key,
    required this.title,
    required this.headline,
    required this.body,
    required this.icon,
  });

  final String title;
  final String headline;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: REdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: FontSizes.heading3,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w700,
                color: AppColors.kBlack,
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: Center(
                child: Container(
                  width: double.infinity,
                  padding: REdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: AppColors.kWhite,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.white04),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 40.r, color: AppColors.primaryBlue5),
                      SizedBox(height: 16.h),
                      Text(
                        headline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: FontSizes.body2,
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w600,
                          color: AppColors.kBlack,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        body,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: FontSizes.footer2,
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primaryBlue11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
