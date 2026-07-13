import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/account_local_store.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddPhoneNumberShellPage extends StatefulWidget {
  const AddPhoneNumberShellPage({super.key});

  @override
  State<AddPhoneNumberShellPage> createState() =>
      _AddPhoneNumberShellPageState();
}

class _AddPhoneNumberShellPageState extends State<AddPhoneNumberShellPage> {
  final TextEditingController _phoneController = TextEditingController();

  bool _submitted = false;
  String? _readyPhoneNumber;

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

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _prepareVerification() {
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
          'Add phone number',
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
            _InfoPanel(currentPhoneNumber: snapshot.phoneNumber),
            SizedBox(height: 16.h),
            CarenetTextField(
              label: 'Phone number',
              hintText: 'Enter phone number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              onChanged: (_) {
                if (_submitted) {
                  setState(() {
                    _readyPhoneNumber = null;
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
            CarenetButton(
              label: 'Prepare verification',
              onPressed: _prepareVerification,
            ),
            if (_readyPhoneNumber != null) ...[
              SizedBox(height: 12.h),
              CarenetButton(
                label: 'Open confirmation step',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteName.confirmPhoneNumber,
                    arguments: _readyPhoneNumber,
                  );
                },
              ),
            ],
            SizedBox(height: 16.h),
            _VerificationNotice(readyPhoneNumber: _readyPhoneNumber),
          ],
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.currentPhoneNumber});

  final String currentPhoneNumber;

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
            'Phone number',
            style: TextStyle(
              fontSize: FontSizes.body3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Phone helps you access your account. Your phone number is not visible to others unless you add it to your profile.',
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
            'Current: $currentPhoneNumber',
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue5,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationNotice extends StatelessWidget {
  const _VerificationNotice({required this.readyPhoneNumber});

  final String? readyPhoneNumber;

  @override
  Widget build(BuildContext context) {
    final ready = readyPhoneNumber != null;

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
            ready ? Icons.mark_chat_read_outlined : Icons.lock_outline,
            color: AppColors.primaryBlue5,
            size: 20.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              ready
                  ? '$readyPhoneNumber is ready for SMS verification. The account phone number is not changed until real OTP verification exists.'
                  : 'Saving a phone number needs SMS/OTP verification and auth backend support, so this slice only prepares the local verification draft.',
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
