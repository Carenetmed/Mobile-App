import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Onboarding/presentation/widget/onboarding_element.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
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
  final int _lastPage = 2;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
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
                              ? CarenetColors.brand
                              : CarenetColors.primary100,
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
                  setState(() => _currentPage = _lastPage);
                  _pageController.animateToPage(
                    _lastPage,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
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
                      ? SizedBox(
                        width: 180.w,
                        child: CarenetButton(
                          label: 'Next',
                          onPressed: () {
                            _pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      )
                      : Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: CarenetButton(
                                label: 'Go back',
                                onPressed: () {
                                  _pageController.previousPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                type: CarenetButtonType.outline,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: CarenetButton(
                                label:
                                    _currentPage == _lastPage
                                        ? 'Get started'
                                        : 'Next',
                                onPressed: () {
                                  if (_currentPage < _lastPage) {
                                    _pageController.nextPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  } else {
                                    Navigator.of(context).pushReplacementNamed(
                                      RouteName.signUpPhone,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
