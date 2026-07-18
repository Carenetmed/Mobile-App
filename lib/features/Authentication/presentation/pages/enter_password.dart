import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/model/validator.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EnterPasswordPage extends StatefulWidget {
  const EnterPasswordPage({super.key});

  @override
  State<EnterPasswordPage> createState() => _EnterPasswordPageState();
}

class _EnterPasswordPageState extends State<EnterPasswordPage> {
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _attemptedSubmit = false;
  bool _visiblePassword = true;
  bool _visibleConfirmPassword = true;
  String? _resetBoundaryNotice;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _passwordController.addListener(_handleInputChanged);
    _confirmPasswordController.addListener(_handleInputChanged);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_handleInputChanged);
    _confirmPasswordController.removeListener(_handleInputChanged);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleInputChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String? get _passwordError =>
      Validators.validatePassword(_passwordController.text);

  String? get _confirmPasswordError => Validators.validateConfirmPassword(
    _confirmPasswordController.text,
    password: _passwordController.text,
  );

  CarenetTextFieldValidationState _validationStateFor(String? error) {
    if (!_attemptedSubmit) {
      return CarenetTextFieldValidationState.none;
    }

    return error == null
        ? CarenetTextFieldValidationState.valid
        : CarenetTextFieldValidationState.invalid;
  }

  void _onChangePassword() {
    setState(() {
      _attemptedSubmit = true;
      _resetBoundaryNotice = null;
    });

    if (_passwordError == null && _confirmPasswordError == null) {
      setState(() {
        _resetBoundaryNotice =
            'Password reset confirmation needs the secure token from the reset email link. This screen does not have that token yet, so it cannot safely change the password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recoveryEmail = ModalRoute.of(context)?.settings.arguments as String?;

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
                'Enter password',
                style: TextStyle(
                  fontSize: FontSizes.heading3,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                recoveryEmail == null || recoveryEmail.isEmpty
                    ? 'Open the reset link from your email before changing your password'
                    : 'We sent reset instructions to $recoveryEmail',
                style: TextStyle(
                  fontSize: FontSizes.footer2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryBlue11,
                ),
              ),
              SizedBox(height: .05.sh),
              CarenetTextField(
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                hintText: 'Enter your new password',
                obscureText: _visiblePassword,
                validationState: _validationStateFor(_passwordError),
                errorText: _passwordError,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _visiblePassword = !_visiblePassword;
                    });
                  },
                  icon:
                      _visiblePassword
                          ? SvgImage(imgName: AssetsIcon.visible)
                          : const Icon(Icons.visibility_off),
                ),
              ),
              SizedBox(height: 15.h),
              CarenetTextField(
                controller: _confirmPasswordController,
                keyboardType: TextInputType.visiblePassword,
                hintText: 'Confirm password',
                obscureText: _visibleConfirmPassword,
                validationState: _validationStateFor(_confirmPasswordError),
                errorText: _confirmPasswordError,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _visibleConfirmPassword = !_visibleConfirmPassword;
                    });
                  },
                  icon:
                      _visibleConfirmPassword
                          ? SvgImage(imgName: AssetsIcon.visible)
                          : const Icon(Icons.visibility_off),
                ),
              ),
              SizedBox(height: 15.h),
              Text(
                'Your password must be at least 15 characters long including numbers and special characters. Final password change requires the secure reset token from the email link.',
                style: TextStyle(
                  fontSize: FontSizes.footer2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: .05.sh),
              if (_resetBoundaryNotice != null) ...[
                Text(
                  _resetBoundaryNotice!,
                  style: TextStyle(
                    fontSize: FontSizes.footer4,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12.h),
              ],
              CarenetButton(
                label: 'Review reset token requirement',
                onPressed: _onChangePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
