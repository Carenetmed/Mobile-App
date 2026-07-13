import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/account_local_store.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddEmailShellPage extends StatefulWidget {
  const AddEmailShellPage({super.key});

  @override
  State<AddEmailShellPage> createState() => _AddEmailShellPageState();
}

class _AddEmailShellPageState extends State<AddEmailShellPage> {
  final TextEditingController _emailController = TextEditingController();

  bool _submitted = false;
  String? _readyEmailAddress;

  String? get _emailError {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      return 'Email address is required';
    }
    if (!email.contains('@') || !email.contains('.')) {
      return 'Enter a valid email address';
    }
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _prepareVerification() {
    setState(() {
      _submitted = true;
      if (_emailError == null) {
        _readyEmailAddress = _emailController.text.trim();
      } else {
        _readyEmailAddress = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = AccountLocalStore.snapshot.value;
    final errorText = _submitted ? _emailError : null;

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
          'Add email address',
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
            _InfoPanel(currentEmailAddress: snapshot.email),
            SizedBox(height: 16.h),
            CarenetTextField(
              label: 'Email address',
              hintText: 'Enter email address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) {
                if (_submitted) {
                  setState(() {
                    _readyEmailAddress = null;
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
            SizedBox(height: 10.h),
            CarenetButton(
              label: 'Review current email',
              type: CarenetButtonType.outline,
              onPressed: () {
                Navigator.pushNamed(context, RouteName.editEmail);
              },
            ),
            SizedBox(height: 10.h),
            CarenetButton(
              label: 'Change existing email',
              type: CarenetButtonType.outline,
              onPressed: () {
                Navigator.pushNamed(context, RouteName.changeEmail);
              },
            ),
            SizedBox(height: 16.h),
            _VerificationNotice(readyEmailAddress: _readyEmailAddress),
          ],
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.currentEmailAddress});

  final String currentEmailAddress;

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
            'Email address',
            style: TextStyle(
              fontSize: FontSizes.body3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your email helps secure your account and supports sign-in and recovery. It is not changed here until verification and auth backend rules exist.',
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
            'Current: $currentEmailAddress',
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
  const _VerificationNotice({required this.readyEmailAddress});

  final String? readyEmailAddress;

  @override
  Widget build(BuildContext context) {
    final ready = readyEmailAddress != null;

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
            ready ? Icons.mark_email_read_outlined : Icons.lock_outline,
            color: AppColors.primaryBlue5,
            size: 20.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              ready
                  ? '$readyEmailAddress is ready for email verification. The account email address is not changed until real verification and account persistence exist.'
                  : 'Saving an email address needs verification, auth backend support, and account persistence, so this slice only prepares the local verification draft.',
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
