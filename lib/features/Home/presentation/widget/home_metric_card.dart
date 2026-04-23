import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeMetricCard extends StatelessWidget {
  final String title;
  final String? unit;
  final String? assetPath;
  final VoidCallback? onTap;
  final bool isAddCard;

  const HomeMetricCard({
    super.key,
    required this.title,
    this.unit,
    this.assetPath,
    this.onTap,
    this.isAddCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        height: 76,
        width: 88,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.kWhite,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: AppColors.primaryBlue1, width: .8),
        ),
        child:
            isAddCard
                ? _AddReadingCardBody(title: title)
                : _MetricCardBody(
                  title: title,
                  unit: unit ?? '--',
                  assetPath: assetPath,
                ),
      ),
    );
  }
}

class _AddReadingCardBody extends StatelessWidget {
  final String title;

  const _AddReadingCardBody({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          height: 24,
          width: 24,
          decoration: const BoxDecoration(
            color: AppColors.primaryBlue7,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: AppColors.primaryRed7, size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w500,
            fontSize: 7,
            color: AppColors.kBlack,
          ),
        ),
      ],
    );
  }
}

class _MetricCardBody extends StatelessWidget {
  final String title;
  final String unit;
  final String? assetPath;

  const _MetricCardBody({
    required this.title,
    required this.unit,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                unit,
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: 7,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white04,
                ),
              ),
            ),
            if (assetPath != null)
              Container(
                height: 18,
                width: 18,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.blue02,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Image.asset(assetPath!, fit: BoxFit.contain),
              ),
          ],
        ),
        Text(
          '--',
          style: TextStyle(
            fontFamily: AppFonts.montserrat,
            fontSize: 8,
            fontWeight: FontWeight.w500,
            color: AppColors.white03,
          ),
        ),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppFonts.montserrat,
            fontSize: 7,
            fontWeight: FontWeight.w500,
            color: AppColors.white06,
          ),
        ),
      ],
    );
  }
}
