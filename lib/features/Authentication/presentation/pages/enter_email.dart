import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/model/validator.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EnterEmailPage extends StatefulWidget {
  const EnterEmailPage({super.key});

  @override
  State<EnterEmailPage> createState() => _EnterEmailPageState();
}

class _EnterEmailPageState extends State<EnterEmailPage> {
  late final TextEditingController _emailController;
  bool _attemptedSubmit = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _emailController.addListener(_handleInputChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_handleInputChanged);
    _emailController.dispose();
    super.dispose();
  }

  void _handleInputChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String? get _emailError => Validators.validateEmail(_emailController.text);

  CarenetTextFieldValidationState get _emailValidationState {
    if (!_attemptedSubmit) {
      return CarenetTextFieldValidationState.none;
    }

    return _emailError == null
        ? CarenetTextFieldValidationState.valid
        : CarenetTextFieldValidationState.invalid;
  }

  void _onContinue() {
    setState(() {
      _attemptedSubmit = true;
    });

    if (_emailError == null) {
      Navigator.pushNamed(
        context,
        RouteName.enterPassword,
        arguments: _emailController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: REdgeInsets.only(left: 15.w, right: 15.w, top: .04.sh),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
              SizedBox(height: .02.sh),
              Text(
                'Enter email',
                style: TextStyle(
                  fontSize: FontSizes.heading3,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Enter your email address to continue',
                style: TextStyle(
                  fontSize: FontSizes.footer2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryBlue11,
                ),
              ),
              SizedBox(height: .05.sh),
              CarenetTextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                hintText: 'Email address',
                validationState: _emailValidationState,
                errorText: _emailError,
              ),
              SizedBox(height: .05.sh),
              CarenetButton(label: 'Continue', onPressed: _onContinue),
            ],
          ),
        ),
      ),
    );
  }
}
