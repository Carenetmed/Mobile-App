import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreatePinShellPage extends StatefulWidget {
  const CreatePinShellPage({super.key});

  @override
  State<CreatePinShellPage> createState() => _CreatePinShellPageState();
}

class _CreatePinShellPageState extends State<CreatePinShellPage> {
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
    return null;
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _preparePin() {
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
            const _PinSummary(),
            SizedBox(height: 16.h),
            CarenetTextField(
              label: 'PIN',
              hintText: 'Enter 6-digit PIN',
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
            CarenetButton(label: 'Next', onPressed: _preparePin),
            SizedBox(height: 16.h),
            _PinNotice(readyForSecureStorage: _readyForSecureStorage),
            if (_readyForSecureStorage) ...[
              SizedBox(height: 12.h),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteName.confirmPinSave,
                    arguments: _pinController.text.trim(),
                  );
                },
                child: const Text('Review confirmation step'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PinSummary extends StatelessWidget {
  const _PinSummary();

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
            'Create a 6-digit PIN that you can remember',
            style: TextStyle(
              fontSize: FontSizes.body3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'This local step validates the PIN format only. Secure storage, confirmation, and account activation need backend/session support.',
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

class _PinNotice extends StatelessWidget {
  const _PinNotice({required this.readyForSecureStorage});

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
            readyForSecureStorage ? Icons.pin_outlined : Icons.lock_outline,
            color: AppColors.primaryBlue5,
            size: 20.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              readyForSecureStorage
                  ? 'PIN format is ready for secure backend storage. No PIN has been saved locally and two-step verification is not enabled.'
                  : 'Creating a PIN requires secure storage, confirmation, session checks, and audit rules before it can enable two-step verification.',
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
