import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/search_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FindMentorShellPage extends StatefulWidget {
  const FindMentorShellPage({super.key});

  @override
  State<FindMentorShellPage> createState() => _FindMentorShellPageState();
}

class _FindMentorShellPageState extends State<FindMentorShellPage> {
  String _selectedCategory = SearchLocalStore.allCategory;

  @override
  Widget build(BuildContext context) {
    final mentors = SearchLocalStore.filter(
      query: '',
      category: _selectedCategory,
    );

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
                      color: selected ? AppColors.kWhite : AppColors.kBlack,
                      fontSize: FontSizes.footer3,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
            ...mentors.map(
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
