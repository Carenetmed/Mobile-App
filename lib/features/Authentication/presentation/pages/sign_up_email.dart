import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/model/sign_in_model.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Authentication/presentation/widget/bordered_keyboard_input.dart';
import 'package:app_t/shared/widgets/app_button.dart';
import 'package:app_t/shared/widgets/auth_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUpEmail extends StatelessWidget {
  SignUpEmail({super.key});

  @override
  Widget build(BuildContext context) {
    List<AuthenticationModel> _signUp = [
      AuthenticationModel(
        assetPath: AssetsIcon.phone,
        title: 'Continue with Phone',
        btnAction: () {
          Navigator.pushNamed(context, RouteName.signUpPhone);
        },
      ),
      AuthenticationModel(assetPath: AssetsIcon.google, title: 'Continue with Google'),
      AuthenticationModel(
        assetPath: AssetsIcon.facebook,
        title: 'Continue with Facebook',
      ),
      AuthenticationModel(assetPath: AssetsIcon.apple, title: 'Continue with Apple'),
    ];
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: RPadding(
          padding: REdgeInsets.only(left: 15.w, right: 15.w, top: .04.sh),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'Sign up with email',
                  style: TextStyle(
                    fontSize: FontSizes.footer2,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryBlue5,
                  ),
                ),
              ),
              SizedBox(height: .05.sh),
              TextInput(
                keyboardType: TextInputType.emailAddress,
                hintText: 'Email',
              ),
              SizedBox(height: 15.h),
              CarenetButtonFilled(btnAction: () {}, btnName: 'Continue'),
              Padding(
                padding: REdgeInsets.only(bottom: .052.sh, top: .15.sh),
                child: Center(
                  child: Text(
                    'or',
                    style: TextStyle(
                      fontSize: FontSizes.body3,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w500,
                      color: AppColors.kBlack,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: .27.sh,
                child: ListView.builder(
                  itemCount: _signUp.length,
                  itemBuilder: (context, index) {
                    return AuthWidget(
                      btnAction: _signUp[index].btnAction,
                      assetPath: _signUp[index].assetPath,
                      title: _signUp[index].title,
                    );
                  },
                ),
              ),
              SizedBox(height: .045.sh),

              CarenetButtonOutline(
                btnAction: () {},
                btnName: 'Already have an account? Sign in',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
