import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/account_local_store.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EnterPasswordToSaveShellPage extends StatefulWidget {
  const EnterPasswordToSaveShellPage({super.key});

  @override
  State<EnterPasswordToSaveShellPage> createState() =>
      _EnterPasswordToSaveShellPageState();
}

class _EnterPasswordToSaveShellPageState
    extends State<EnterPasswordToSaveShellPage> {
  final TextEditingController _passwordController = TextEditingController();

  bool _submitted = false;
  bool _readyForBackendCheck = false;

  String? get _passwordError {
    final password = _passwordController.text;
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Enter at least 8 characters';
    }
    return null;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _preparePasswordCheck() {
    setState(() {
      _submitted = true;
      _readyForBackendCheck = _passwordError == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = AccountLocalStore.snapshot.value;
    final errorText = _submitted ? _passwordError : null;

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          'Enter password to save',
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
            _InfoPanel(email: snapshot.email),
            SizedBox(height: 16.h),
            CarenetTextField(
              label: 'Password',
              hintText: 'Enter your password',
              controller: _passwordController,
              obscureText: true,
              onChanged: (_) {
                if (_submitted) {
                  setState(() {
                    _readyForBackendCheck = false;
                  });
                }
              },
              validationState:
                  errorText == null
                      ? CarenetTextFieldValidationState.none
                      : CarenetTextFieldValidationState.invalid,
              errorText: errorText,
            ),
            SizedBox(height: 16.h),
            CarenetButton(label: 'Confirm', onPressed: _preparePasswordCheck),
            SizedBox(height: 16.h),
            _ReauthNotice(readyForBackendCheck: _readyForBackendCheck),
          ],
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your password to continue',
            style: TextStyle(
              fontSize: FontSizes.body3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'This local step prepares a password re-authentication request for $email. It does not verify the password or save account changes without the auth backend.',
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReauthNotice extends StatelessWidget {
  const _ReauthNotice({required this.readyForBackendCheck});

  final bool readyForBackendCheck;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: readyForBackendCheck ? AppColors.blue02 : AppColors.kWhite,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            readyForBackendCheck
                ? Icons.verified_user_outlined
                : Icons.lock_outline,
            color: AppColors.primaryBlue5,
            size: 20.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              readyForBackendCheck
                  ? 'Password entry is ready for backend re-authentication. No account change has been saved locally.'
                  : 'Password confirmation requires the auth backend, session checks, and audit rules before it can unlock account changes.',
              style: TextStyle(
                fontSize: FontSizes.footer4,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryBlue11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
