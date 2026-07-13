import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/account_local_store.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConfirmPhoneNumberShellPage extends StatefulWidget {
  const ConfirmPhoneNumberShellPage({this.initialPhoneNumber, super.key});

  final String? initialPhoneNumber;

  @override
  State<ConfirmPhoneNumberShellPage> createState() =>
      _ConfirmPhoneNumberShellPageState();
}

class _ConfirmPhoneNumberShellPageState
    extends State<ConfirmPhoneNumberShellPage> {
  late final TextEditingController _phoneController;

  bool _submitted = false;
  String? _readyPhoneNumber;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(
      text: widget.initialPhoneNumber ?? '',
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? get _phoneError {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      return 'Phone number is required';
    }
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  void _prepareCodeVerification() {
    setState(() {
      _submitted = true;
      if (_phoneError == null) {
        _readyPhoneNumber = _phoneController.text.trim();
      } else {
        _readyPhoneNumber = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = AccountLocalStore.snapshot.value;
    final errorText = _submitted ? _phoneError : null;

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
          'Confirm phone number',
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
            Container(
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
                    'Enter your phone number to continue',
                    style: TextStyle(
                      fontSize: FontSizes.body3,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w700,
                      color: AppColors.kBlack,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'This step prepares the phone number for backend code verification. It does not send an OTP or change your saved account phone number.',
                    style: TextStyle(
                      fontSize: FontSizes.footer3,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryBlue11,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Current saved phone: ${snapshot.phoneNumber}',
                    style: TextStyle(
                      fontSize: FontSizes.footer4,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            CarenetTextField(
              label: 'Name',
              hintText: 'Enter phone number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              onChanged: (_) {
                if (_submitted) {
                  setState(() => _readyPhoneNumber = null);
                }
              },
              validationState:
                  errorText == null
                      ? CarenetTextFieldValidationState.none
                      : CarenetTextFieldValidationState.invalid,
              errorText: errorText,
            ),
            SizedBox(height: 18.h),
            CarenetButton(label: 'Next', onPressed: _prepareCodeVerification),
            SizedBox(height: 16.h),
            _PhoneConfirmationNotice(phoneNumber: _readyPhoneNumber),
            SizedBox(height: 18.h),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(
                'Change your email address',
                style: TextStyle(
                  fontSize: FontSizes.footer3,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneConfirmationNotice extends StatelessWidget {
  const _PhoneConfirmationNotice({required this.phoneNumber});

  final String? phoneNumber;

  @override
  Widget build(BuildContext context) {
    final ready = phoneNumber != null;

    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: ready ? AppColors.blue02 : AppColors.kWhite,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            ready ? Icons.sms_outlined : Icons.lock_outline,
            color: AppColors.primaryBlue5,
            size: 20.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              ready
                  ? '$phoneNumber is ready for backend OTP verification. The saved account phone number is unchanged until real code confirmation exists.'
                  : 'Code verification needs OTP delivery, rate limiting, and account-session updates. This local route only prepares the phone number for that backend step.',
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
