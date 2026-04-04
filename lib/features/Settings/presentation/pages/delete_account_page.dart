import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Settings/presentation/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _hidePassword = true;
  bool _confirmedPermanentAction = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_confirmedPermanentAction) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please confirm that you understand this is permanent.',
          ),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: const Text('Delete account?'),
          content: const Text(
            'This action cannot be undone. Your account and submitted data will be permanently removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.primaryRed6),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account deletion request captured.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'Delete Account',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsInfoCard(
              icon: Icons.warning_amber_rounded,
              accentColor: AppColors.primaryRed6,
              backgroundColor: AppColors.primaryRed1,
              title: 'This action is permanent',
              description:
                  'Deleting your account removes your profile, access, and account history. Review your details carefully before continuing.',
            ),
            SizedBox(height: 16.h),
            const SettingsInfoCard(
              icon: Icons.info_outline_rounded,
              accentColor: AppColors.primaryRed6,
              backgroundColor: AppColors.kWhite,
              title: 'Before you continue',
              description:
                  'Make sure you no longer need your account access, messages, saved details, or any information associated with your profile.',
            ),
            SizedBox(height: 24.h),
            const SettingsSectionTitle(title: 'Confirm your account'),
            SizedBox(height: 12.h),
            SettingsTextField(
              label: 'Email address',
              hintText: 'Enter your email address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => _requiredValidator(value, 'Email address'),
            ),
            SizedBox(height: 16.h),
            SettingsTextField(
              label: 'Phone number',
              hintText: 'Enter your phone number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (value) => _requiredValidator(value, 'Phone number'),
            ),
            SizedBox(height: 16.h),
            SettingsTextField(
              label: 'Password',
              hintText: 'Confirm your password',
              controller: _passwordController,
              obscureText: _hidePassword,
              validator: (value) => _requiredValidator(value, 'Password'),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _hidePassword = !_hidePassword);
                },
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.white04,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryRed1,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.primaryRed2),
              ),
              child: CheckboxListTile(
                value: _confirmedPermanentAction,
                onChanged: (value) {
                  setState(() => _confirmedPermanentAction = value ?? false);
                },
                activeColor: AppColors.primaryRed6,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 4.h,
                ),
                title: Text(
                  'I understand that deleting my account is permanent.',
                  style: TextStyle(
                    fontSize: FontSizes.footer1,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFonts.montserrat,
                    color: AppColors.primaryRed9,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            SizedBox(height: 24.h),
            SettingsActionButton(
              label: 'Delete account',
              onTap: _submit,
              backgroundColor: AppColors.primaryRed6,
              textColor: AppColors.kWhite,
              borderColor: AppColors.primaryRed6,
            ),
            SizedBox(height: 12.h),
            SettingsActionButton(
              label: 'Cancel',
              onTap: () => Navigator.pop(context),
              backgroundColor: AppColors.kWhite,
              textColor: AppColors.white06,
              borderColor: AppColors.white02,
            ),
          ],
        ),
      ),
    );
  }
}
