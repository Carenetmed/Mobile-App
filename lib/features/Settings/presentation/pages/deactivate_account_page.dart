import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/features/Settings/presentation/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeactivateAccountPage extends StatefulWidget {
  const DeactivateAccountPage({super.key});

  @override
  State<DeactivateAccountPage> createState() => _DeactivateAccountPageState();
}

class _DeactivateAccountPageState extends State<DeactivateAccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonDetailsController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final List<String> _reasons = <String>[
    'Need a break',
    'Privacy concerns',
    'Too many emails',
    'Other',
  ];

  bool _hidePassword = true;
  String? _selectedReason;

  @override
  void dispose() {
    _reasonDetailsController.dispose();
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
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason to continue.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bool? shouldDeactivate = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: const Text('Deactivate account?'),
          content: const Text(
            'Your profile will be hidden until you sign back in to reactivate it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep active'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Deactivate'),
            ),
          ],
        );
      },
    );

    if (shouldDeactivate != true || !mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account deactivation request captured.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'Deactivate Account',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsInfoCard(
              icon: Icons.pause_circle_outline_rounded,
              accentColor: AppColors.primaryBlue6,
              backgroundColor: AppColors.blue02,
              title: 'Take a temporary break',
              description:
                  'Deactivating your account hides your profile and activity, but keeps your information available when you come back.',
            ),
            SizedBox(height: 24.h),
            const SettingsSectionTitle(title: 'Why are you leaving?'),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children:
                  _reasons.map((reason) {
                    final bool isSelected = _selectedReason == reason;

                    return ChoiceChip(
                      label: Text(reason),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedReason = reason);
                      },
                      labelStyle: TextStyle(
                        color:
                            isSelected
                                ? AppColors.primaryBlue6
                                : AppColors.white05,
                      ),
                      backgroundColor: AppColors.kWhite,
                      selectedColor: AppColors.blue02,
                      side: BorderSide(
                        color:
                            isSelected
                                ? AppColors.primaryBlue6
                                : AppColors.white02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    );
                  }).toList(),
            ),
            SizedBox(height: 18.h),
            SettingsTextField(
              label: 'More details',
              hintText: 'Tell us what would help improve your experience',
              controller: _reasonDetailsController,
              maxLines: 4,
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
            SizedBox(height: 24.h),
            SettingsActionButton(
              label: 'Deactivate account',
              onTap: _submit,
              backgroundColor: AppColors.primaryBlue6,
              textColor: AppColors.kWhite,
              borderColor: AppColors.primaryBlue6,
            ),
            SizedBox(height: 12.h),
            SettingsActionButton(
              label: 'Keep account active',
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
