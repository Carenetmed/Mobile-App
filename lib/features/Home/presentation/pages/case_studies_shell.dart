import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/case_studies_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CaseStudiesShellPage extends StatefulWidget {
  const CaseStudiesShellPage({super.key});

  @override
  State<CaseStudiesShellPage> createState() => _CaseStudiesShellPageState();
}

class _CaseStudiesShellPageState extends State<CaseStudiesShellPage> {
  CaseStudyContent? _selectedCaseStudy;
  _CaseStudyFilter _filter = _CaseStudyFilter.all;

  @override
  Widget build(BuildContext context) {
    final selectedCaseStudy = _selectedCaseStudy;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () {
            if (selectedCaseStudy != null) {
              setState(() {
                _selectedCaseStudy = null;
              });
              return;
            }
            Navigator.of(context).maybePop();
          },
        ),
        title: Text(
          selectedCaseStudy == null ? 'Case Studies' : selectedCaseStudy.title,
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
            selectedCaseStudy == null
                ? _CaseStudiesListView(
                  filter: _filter,
                  onFilterChanged: (filter) {
                    setState(() {
                      _filter = filter;
                    });
                  },
                  onOpenCaseStudy: (caseStudy) {
                    CaseStudiesLocalStore.markRead(caseStudy.id);
                    setState(() {
                      _selectedCaseStudy = caseStudy;
                    });
                  },
                )
                : _CaseStudyDetailView(caseStudy: selectedCaseStudy),
      ),
    );
  }
}

enum _CaseStudyFilter { all, caseStudies, best }

class _CaseStudiesListView extends StatelessWidget {
  const _CaseStudiesListView({
    required this.filter,
    required this.onFilterChanged,
    required this.onOpenCaseStudy,
  });

  final _CaseStudyFilter filter;
  final ValueChanged<_CaseStudyFilter> onFilterChanged;
  final ValueChanged<CaseStudyContent> onOpenCaseStudy;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: CaseStudiesLocalStore.readCaseStudies,
      builder: (context, readCaseStudies, _) {
        final visibleCaseStudies = CaseStudiesLocalStore.caseStudies
            .where((caseStudy) {
              return switch (filter) {
                _CaseStudyFilter.all => true,
                _CaseStudyFilter.caseStudies => true,
                _CaseStudyFilter.best => caseStudy.isBest,
              };
            })
            .toList(growable: false);

        return ListView(
          padding: REdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          children: [
            _CaseStudyTabs(
              selectedFilter: filter,
              onFilterChanged: onFilterChanged,
            ),
            SizedBox(height: 12.h),
            if (visibleCaseStudies.isEmpty)
              const _EmptyCaseStudiesCard()
            else
              ...visibleCaseStudies.map(
                (caseStudy) => Padding(
                  padding: REdgeInsets.only(bottom: 12.h),
                  child: _CaseStudyCard(
                    caseStudy: caseStudy,
                    isRead: readCaseStudies.contains(caseStudy.id),
                    onOpen: () => onOpenCaseStudy(caseStudy),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CaseStudyTabs extends StatelessWidget {
  const _CaseStudyTabs({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final _CaseStudyFilter selectedFilter;
  final ValueChanged<_CaseStudyFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CaseStudyTab(
          label: 'All',
          isActive: selectedFilter == _CaseStudyFilter.all,
          onTap: () => onFilterChanged(_CaseStudyFilter.all),
        ),
        _CaseStudyTab(
          label: 'Case studies',
          isActive: selectedFilter == _CaseStudyFilter.caseStudies,
          onTap: () => onFilterChanged(_CaseStudyFilter.caseStudies),
        ),
        _CaseStudyTab(
          label: 'Best',
          isActive: selectedFilter == _CaseStudyFilter.best,
          onTap: () => onFilterChanged(_CaseStudyFilter.best),
          isLast: true,
        ),
      ],
    );
  }
}

class _CaseStudyTab extends StatelessWidget {
  const _CaseStudyTab({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isLast = false,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: REdgeInsets.only(right: isLast ? 0 : 8.w),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor:
                isActive ? AppColors.primaryBlue5 : AppColors.kWhite,
            foregroundColor:
                isActive ? AppColors.kWhite : AppColors.primaryBlue11,
            side: BorderSide(
              color: isActive ? AppColors.primaryBlue5 : AppColors.white04,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.r),
            ),
          ),
          onPressed: onTap,
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}

class _CaseStudyCard extends StatelessWidget {
  const _CaseStudyCard({
    required this.caseStudy,
    required this.isRead,
    required this.onOpen,
  });

  final CaseStudyContent caseStudy;
  final bool isRead;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: REdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.kWhite,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.white04),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 92.h,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5F0),
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.medical_information_outlined,
                color: AppColors.primaryBlue5,
                size: 32.r,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              caseStudy.title,
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w700,
                fontSize: FontSizes.body3,
                color: AppColors.kBlack,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              caseStudy.summary,
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
                _CaseStudyPill(label: caseStudy.isBest ? 'Best' : 'Case study'),
                SizedBox(width: 8.w),
                Icon(
                  Icons.schedule,
                  size: 16.r,
                  color: AppColors.primaryBlue11,
                ),
                SizedBox(width: 4.w),
                Text(
                  caseStudy.readTime,
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w500,
                    fontSize: FontSizes.footer3,
                    color: AppColors.primaryBlue11,
                  ),
                ),
                const Spacer(),
                Text(
                  isRead ? 'Read' : 'Open',
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    fontSize: FontSizes.footer3,
                    color: AppColors.primaryBlue5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CaseStudyPill extends StatelessWidget {
  const _CaseStudyPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F0),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.montserrat,
          fontWeight: FontWeight.w600,
          fontSize: FontSizes.footer3,
          color: AppColors.primaryBlue5,
        ),
      ),
    );
  }
}

class _EmptyCaseStudiesCard extends StatelessWidget {
  const _EmptyCaseStudiesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Text(
        'No case studies match this filter yet.',
        style: TextStyle(
          fontFamily: AppFonts.montserrat,
          fontWeight: FontWeight.w500,
          fontSize: FontSizes.footer2,
          color: AppColors.primaryBlue11,
        ),
      ),
    );
  }
}

class _CaseStudyDetailView extends StatelessWidget {
  const _CaseStudyDetailView({required this.caseStudy});

  final CaseStudyContent caseStudy;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: REdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      children: [
        Container(
          height: 180.h,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF5F0),
            borderRadius: BorderRadius.circular(16.r),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.medical_information_outlined,
            color: AppColors.primaryBlue5,
            size: 44.r,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          caseStudy.title,
          style: TextStyle(
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w800,
            fontSize: 22.sp,
            color: AppColors.kBlack,
            height: 1.25,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.primaryBlue5,
              child: Text(
                caseStudy.author.substring(0, 1),
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  fontSize: FontSizes.footer2,
                  color: AppColors.kWhite,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                caseStudy.author,
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w600,
                  fontSize: FontSizes.footer2,
                  color: AppColors.kBlack,
                ),
              ),
            ),
            Icon(Icons.schedule, size: 16.r, color: AppColors.primaryBlue11),
            SizedBox(width: 4.w),
            Text(
              caseStudy.readTime.replaceAll('min', 'minutes'),
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w500,
                fontSize: FontSizes.footer3,
                color: AppColors.primaryBlue11,
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),
        Text(
          caseStudy.body,
          style: TextStyle(
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w400,
            fontSize: FontSizes.footer2,
            color: AppColors.primaryBlue11,
            height: 1.55,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'This case-study library is local content for now. Later content APIs should replace the source without changing the list/detail reader flow.',
          style: TextStyle(
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w500,
            fontSize: FontSizes.footer3,
            color: AppColors.primaryBlue5,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
