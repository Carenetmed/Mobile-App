import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/model/validator.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EnterEmailPage extends StatefulWidget {
  const EnterEmailPage({super.key, this.authRepository});

  final AuthRepository? authRepository;

  @override
  State<EnterEmailPage> createState() => _EnterEmailPageState();
}

class _EnterEmailPageState extends State<EnterEmailPage> {
  late final TextEditingController _emailController;
  bool _attemptedSubmit = false;
  bool _isSubmitting = false;
  bool _resetRequested = false;
  String? _authError;

  AuthRepository get _authRepository =>
      widget.authRepository ?? sl<AuthRepository>();

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
      setState(() {
        _resetRequested = false;
      });
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

  Future<void> _onContinue() async {
    setState(() {
      _attemptedSubmit = true;
      _authError = null;
    });

    if (_emailError != null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final email = _emailController.text.trim();
      await _authRepository.requestPasswordReset(email: email);
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _resetRequested = true;
      });
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _authError = failure.message;
        _isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _authError = 'Something went wrong. Please try again.';
        _isSubmitting = false;
      });
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
                tooltip: 'Back',
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
                'Enter your email address to request a password reset link',
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
              if (_authError != null) ...[
                Text(
                  _authError!,
                  style: TextStyle(
                    fontSize: FontSizes.footer4,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent,
                  ),
                ),
                SizedBox(height: 12.h),
              ],
              if (_resetRequested) ...[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    'If an account exists for that email, reset instructions will arrive shortly. Open the link in the email to choose a new password.',
                  ),
                ),
                SizedBox(height: 12.h),
              ],
              CarenetButton(
                label:
                    _isSubmitting
                        ? 'Sending reset link...'
                        : _resetRequested
                        ? 'Send another reset link'
                        : 'Send reset link',
                onPressed: _isSubmitting ? null : _onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
