import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/search_local_store.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchShellPage extends StatefulWidget {
  const SearchShellPage({super.key});

  @override
  State<SearchShellPage> createState() => _SearchShellPageState();
}

class _SearchShellPageState extends State<SearchShellPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = SearchLocalStore.allCategory;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
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

  @override
  Widget build(BuildContext context) {
    final specialists = SearchLocalStore.filter(
      query: _searchController.text,
      category: _selectedCategory,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: ValueListenableBuilder<Set<String>>(
          valueListenable: SearchLocalStore.requestedSpecialistIds,
          builder: (context, requestedIds, _) {
            return ListView(
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
                    itemCount: SearchLocalStore.categories.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (context, index) {
                      final category = SearchLocalStore.categories[index];
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
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? AppColors.kWhite : AppColors.kBlack,
                          fontSize: FontSizes.footer3,
                        ),
                        side: BorderSide(
                          color:
                              selected
                                  ? AppColors.primaryBlue5
                                  : AppColors.white04,
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
                      '${specialists.length} found',
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
                if (specialists.isEmpty)
                  _SearchEmptyState(
                    onReset:
                        () => setState(() {
                          _selectedCategory = SearchLocalStore.allCategory;
                          _searchController.clear();
                        }),
                  )
                else
                  ...specialists.map(
                    (specialist) => Padding(
                      padding: REdgeInsets.only(bottom: 12.h),
                      child: _SpecialistCard(
                        specialist: specialist,
                        requested: requestedIds.contains(specialist.id),
                        onViewProfile:
                            () => _showSpecialistProfile(context, specialist),
                        onRequest:
                            () => SearchLocalStore.markRequested(specialist.id),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showSpecialistProfile(
    BuildContext context,
    SearchSpecialist specialist,
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

class _SpecialistCard extends StatelessWidget {
  const _SpecialistCard({
    required this.specialist,
    required this.requested,
    required this.onViewProfile,
    required this.onRequest,
  });

  final SearchSpecialist specialist;
  final bool requested;
  final VoidCallback onViewProfile;
  final VoidCallback onRequest;

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
            child: Image.asset(
              specialist.imageAsset,
              width: 72.r,
              height: 72.r,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    width: 72.r,
                    height: 72.r,
                    color: AppColors.blue02,
                    child: Icon(
                      Icons.person_outline,
                      color: AppColors.primaryBlue5,
                      size: 30.r,
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
                  specialist.name,
                  style: TextStyle(
                    fontSize: FontSizes.footer2,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kBlack,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  specialist.role,
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
                  children: [
                    _MetaLabel(icon: Icons.star, label: specialist.rating),
                    _MetaLabel(
                      icon: Icons.schedule,
                      label: specialist.availability,
                    ),
                    _MetaLabel(
                      icon: Icons.payments_outlined,
                      label: specialist.priceLabel,
                    ),
                  ],
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
                      onPressed: onRequest,
                      icon: Icon(
                        requested
                            ? Icons.check_circle_outline
                            : Icons.calendar_today_outlined,
                        size: 18.r,
                      ),
                      label: Text(requested ? 'Requested locally' : 'Schedule'),
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
