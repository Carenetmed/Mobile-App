import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConfirmPinSaveShellPage extends StatefulWidget {
  const ConfirmPinSaveShellPage({this.draftPin, super.key});

  final String? draftPin;

  @override
  State<ConfirmPinSaveShellPage> createState() =>
      _ConfirmPinSaveShellPageState();
}

class _ConfirmPinSaveShellPageState extends State<ConfirmPinSaveShellPage> {
  final TextEditingController _pinController = TextEditingController();

  bool _submitted = false;
  bool _readyForSecureStorage = false;

  String? get _pinError {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      return 'PIN is required';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      return 'Enter a 6-digit PIN';
    }
    final draftPin = widget.draftPin;
    if (draftPin != null && pin != draftPin) {
      return 'PINs do not match';
    }
    return null;
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _prepareConfirmation() {
    setState(() {
      _submitted = true;
      _readyForSecureStorage = _pinError == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final errorText = _submitted ? _pinError : null;

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
          'Two-step verification',
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
            const _ConfirmPinSummary(),
            SizedBox(height: 16.h),
            CarenetTextField(
              label: 'Confirm your PIN',
              hintText: '*  *  *      *   *   *',
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              onChanged: (_) {
                if (_submitted) {
                  setState(() {
                    _readyForSecureStorage = false;
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
            CarenetButton(label: 'Save', onPressed: _prepareConfirmation),
            SizedBox(height: 16.h),
            _ConfirmPinNotice(readyForSecureStorage: _readyForSecureStorage),
          ],
        ),
      ),
    );
  }
}

class _ConfirmPinSummary extends StatelessWidget {
  const _ConfirmPinSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirm your PIN',
            style: TextStyle(
              fontSize: FontSizes.body3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Re-enter the same 6-digit PIN before this can be handed to secure backend storage.',
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

class _ConfirmPinNotice extends StatelessWidget {
  const _ConfirmPinNotice({required this.readyForSecureStorage});

  final bool readyForSecureStorage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: readyForSecureStorage ? AppColors.blue02 : AppColors.kWhite,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            readyForSecureStorage
                ? Icons.verified_user_outlined
                : Icons.lock_outline,
            color: AppColors.primaryBlue5,
            size: 20.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              readyForSecureStorage
                  ? 'PIN confirmation is ready for secure backend storage. No PIN has been saved locally and two-step verification is not enabled.'
                  : 'Saving a confirmed PIN still requires secure storage, session checks, audit rules, recovery rules, and account persistence.',
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
