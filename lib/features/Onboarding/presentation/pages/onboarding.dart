import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Onboarding/presentation/widget/onboarding_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late PageController _pageController;
  int _currentPage = 0;
  int _lastPage = 2;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _pageController.addListener(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> onboardingPage = [
    OnboardingElement(
      assetName: AssetsImages.onboardingOne,
      title: 'Where Knowledge Meets Collaboration',
      subTitle:
          'Discover a space where medical and non-\nmedical professionals connect, learn, and grow\ntogether',
    ),
    OnboardingElement(
      assetName: AssetsImages.onboardingTwo,
      title: 'Explore, Mentor & Evolve',
      subTitle:
          'Dive into case studies, expand your expertise, and find\nmentors who elevate your journey',
    ),
    OnboardingElement(
      assetName: AssetsImages.onboardingThree,
      title: 'Join a Community That\nInspires Progress',
      subTitle:
          'Share insights, exchange ideas, and drive impactful\nconversations that shape the future',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() => _currentPage = page);
              },
              children: onboardingPage,
            ),
            Align(
              alignment: Alignment(0, .43),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                  onboardingPage.length,
                  (index) => Container(
                    width: 8.w,
                    height: 8.h,
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    decoration: BoxDecoration(
                      color:
                          _currentPage == index
                              ? AppColors.primaryBlue6
                              : AppColors.blue02,
                      borderRadius: BorderRadius.circular(6.w),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment(.85, -.95),
              child: GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    _lastPage,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.bounceIn,
                  );
                },
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.kBlack,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment(0, .67),
              child:
                  _currentPage == 0
                      ? TextButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            AppColors.primaryBlue6,
                          ),
                          elevation: WidgetStatePropertyAll(0),
                          padding: WidgetStatePropertyAll(
                            EdgeInsets.symmetric(
                              horizontal: .09.sw,
                              vertical: 10.h,
                            ),
                          ),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontSize: FontSizes.body3,
                            color: AppColors.kWhite,
                            fontFamily: AppFonts.montserrat,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                      : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                Colors.transparent,
                              ),
                              elevation: WidgetStatePropertyAll(0),
                              padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                  horizontal: .14.sw,
                                  vertical: 8.h,
                                ),
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                            child: Text(
                              'Go back',
                              style: TextStyle(
                                fontSize: FontSizes.body3,
                                color: AppColors.primaryBlue10,
                                fontFamily: AppFonts.montserrat,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              if (_currentPage < _lastPage) {
                                _pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                Navigator.of(
                                  context,
                                ).pushReplacementNamed(RouteName.signUpPhone);
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                AppColors.primaryBlue6,
                              ),
                              elevation: WidgetStatePropertyAll(0),
                              padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                  horizontal: .14.sw,
                                  vertical: 8.h,
                                ),
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                            child: Text(
                              _currentPage == _lastPage
                                  ? 'Get started'
                                  : 'Next',
                              style: TextStyle(
                                fontSize: FontSizes.body3,
                                color: AppColors.kWhite,
                                fontFamily: AppFonts.montserrat,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
