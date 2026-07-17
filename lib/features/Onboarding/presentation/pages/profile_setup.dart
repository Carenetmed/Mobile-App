import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PatientOnboardingSetupPage extends StatefulWidget {
  const PatientOnboardingSetupPage({super.key, this.profileRepository});

  final ProfileRepository? profileRepository;

  @override
  State<PatientOnboardingSetupPage> createState() =>
      _PatientOnboardingSetupPageState();
}

class _PatientOnboardingSetupPageState
    extends State<PatientOnboardingSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController(text: 'Nigeria');
  final _healthInterestsController = TextEditingController();
  bool _isSaving = false;
  String? _message;
  DateTime? _dateOfBirth;

  ProfileRepository get _profileRepository =>
      widget.profileRepository ?? sl<ProfileRepository>();

  @override
  void dispose() {
    _nameController.dispose();
    _dateOfBirthController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _healthInterestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SetupScaffold(
      title: 'Set up your patient profile',
      subtitle:
          'Add the details CareNet needs for safer consultations and profile prompts.',
      stepLabel: 'Patient setup',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarenetTextField(
              label: 'Full name',
              hintText: 'e.g. Ada Okafor',
              controller: _nameController,
              textInputAction: TextInputAction.next,
              validator: _required('Full name is required'),
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Date of birth',
              hintText: 'Select date',
              controller: _dateOfBirthController,
              readOnly: true,
              onTap: _pickDateOfBirth,
              suffixIcon: const Icon(Icons.calendar_today_outlined),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: CarenetTextField(
                    label: 'City',
                    hintText: 'Lagos',
                    controller: _cityController,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CarenetTextField(
                    label: 'State',
                    hintText: 'Lagos',
                    controller: _stateController,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Country',
              hintText: 'Nigeria',
              controller: _countryController,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Health interests',
              hintText: 'Primary care, wellness, diabetes support',
              controller: _healthInterestsController,
              minLines: 3,
              maxLines: 4,
            ),
            _StatusText(message: _message),
            SizedBox(height: 20.h),
            CarenetButton(
              label: _isSaving ? 'Saving profile...' : 'Save and continue',
              onPressed: _isSaving ? null : _savePatientProfile,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 110),
      lastDate: DateTime(now.year - 13, now.month, now.day),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _dateOfBirth = DateTime.utc(picked.year, picked.month, picked.day);
      _dateOfBirthController.text = _formatDate(picked);
    });
  }

  Future<void> _savePatientProfile() async {
    setState(() {
      _message = null;
    });
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _isSaving = true;
    });
    try {
      await _profileRepository.updatePatientMe(
        name: _nameController.text.trim(),
        dateOfBirth: _dateOfBirth,
        city: _emptyToNull(_cityController.text),
        state: _emptyToNull(_stateController.text),
        country: _emptyToNull(_countryController.text),
        healthInterests: _emptyToNull(_healthInterestsController.text),
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).popAndPushNamed(RouteName.communityAgreement);
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() => _message = failure.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'Could not save profile. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class ProfessionalOnboardingSetupPage extends StatefulWidget {
  const ProfessionalOnboardingSetupPage({super.key, this.profileRepository});

  final ProfileRepository? profileRepository;

  @override
  State<ProfessionalOnboardingSetupPage> createState() =>
      _ProfessionalOnboardingSetupPageState();
}

class _ProfessionalOnboardingSetupPageState
    extends State<ProfessionalOnboardingSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _legalNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _licensingCouncilController = TextEditingController(text: 'MDCN');
  final _qualificationsController = TextEditingController();
  final _yearsController = TextEditingController();
  final _practiceNameController = TextEditingController();
  final _practiceAddressController = TextEditingController();
  final _practiceCityController = TextEditingController();
  final _practiceStateController = TextEditingController();
  final _practiceCountryController = TextEditingController(text: 'Nigeria');
  bool _isSaving = false;
  String? _message;

  ProfileRepository get _profileRepository =>
      widget.profileRepository ?? sl<ProfileRepository>();

  @override
  void dispose() {
    _legalNameController.dispose();
    _displayNameController.dispose();
    _categoryController.dispose();
    _specialtyController.dispose();
    _licenseNumberController.dispose();
    _licensingCouncilController.dispose();
    _qualificationsController.dispose();
    _yearsController.dispose();
    _practiceNameController.dispose();
    _practiceAddressController.dispose();
    _practiceCityController.dispose();
    _practiceStateController.dispose();
    _practiceCountryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SetupScaffold(
      title: 'Professional verification profile',
      subtitle:
          'These details support credential review. Public listing still waits for manual verification.',
      stepLabel: 'Professional setup',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader('Identity'),
            CarenetTextField(
              label: 'Legal name',
              hintText: 'Name on your license',
              controller: _legalNameController,
              textInputAction: TextInputAction.next,
              validator: _required('Legal name is required'),
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Public professional name',
              hintText: 'Dr. Ada Okafor',
              controller: _displayNameController,
              textInputAction: TextInputAction.next,
              validator: _required('Public professional name is required'),
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Profession/category',
              hintText: 'Doctor, Nurse, Pharmacist',
              controller: _categoryController,
              textInputAction: TextInputAction.next,
              validator: _required('Profession/category is required'),
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Specialty',
              hintText: 'Cardiology, Pediatrics, Public health',
              controller: _specialtyController,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 24.h),
            const _SectionHeader('Credentials'),
            CarenetTextField(
              label: 'License or registration number',
              hintText: 'MDCN-12345',
              controller: _licenseNumberController,
              textInputAction: TextInputAction.next,
              validator: _required('License number is required'),
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Licensing council/body',
              hintText: 'MDCN, NMCN, PCN',
              controller: _licensingCouncilController,
              textInputAction: TextInputAction.next,
              validator: _required('Licensing council is required'),
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Qualifications',
              hintText: 'MBBS, FWACP',
              controller: _qualificationsController,
              textInputAction: TextInputAction.next,
              validator: _required('Qualifications are required'),
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Years of experience',
              hintText: '8',
              controller: _yearsController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: _yearsValidator,
            ),
            SizedBox(height: 24.h),
            const _SectionHeader('Practice'),
            CarenetTextField(
              label: 'Practice or facility name',
              hintText: 'Care Clinic',
              controller: _practiceNameController,
              textInputAction: TextInputAction.next,
              validator: _required('Practice name is required'),
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Practice address',
              hintText: 'Street address',
              controller: _practiceAddressController,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: CarenetTextField(
                    label: 'Practice city',
                    hintText: 'Ikeja',
                    controller: _practiceCityController,
                    textInputAction: TextInputAction.next,
                    validator: _required('Practice city is required'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CarenetTextField(
                    label: 'Practice state',
                    hintText: 'Lagos',
                    controller: _practiceStateController,
                    textInputAction: TextInputAction.next,
                    validator: _required('Practice state is required'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Practice country',
              hintText: 'Nigeria',
              controller: _practiceCountryController,
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: 16.h),
            const _InfoCard(
              message:
                  'Next you will upload license, identity, or certification documents. CareNet will not mark your profile verified from this form alone.',
            ),
            _StatusText(message: _message),
            SizedBox(height: 20.h),
            CarenetButton(
              label: _isSaving ? 'Saving profile...' : 'Save and verify',
              onPressed: _isSaving ? null : _saveProfessionalProfile,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfessionalProfile() async {
    setState(() {
      _message = null;
    });
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _isSaving = true;
    });
    try {
      await _profileRepository.updateProfessionalMe(
        legalName: _legalNameController.text.trim(),
        displayName: _displayNameController.text.trim(),
        category: _categoryController.text.trim(),
        specialty: _emptyToNull(_specialtyController.text),
        licenseNumber: _licenseNumberController.text.trim(),
        licensingCouncil: _licensingCouncilController.text.trim(),
        qualifications: _qualificationsController.text.trim(),
        yearsOfExperience: int.parse(_yearsController.text.trim()),
        practiceName: _practiceNameController.text.trim(),
        practiceAddress: _emptyToNull(_practiceAddressController.text),
        practiceCity: _practiceCityController.text.trim(),
        practiceState: _practiceStateController.text.trim(),
        practiceCountry: _emptyToNull(_practiceCountryController.text),
      );
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
      ).popAndPushNamed(RouteName.professionalVerificationDocuments);
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() => _message = failure.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'Could not save profile. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _SetupScaffold extends StatelessWidget {
  const _SetupScaffold({
    required this.title,
    required this.subtitle,
    required this.stepLabel,
    required this.child,
  });

  final String title;
  final String subtitle;
  final String stepLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CarenetColors.neutral100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
              SizedBox(height: 8.h),
              Text(
                stepLabel,
                style: TextStyle(
                  color: CarenetColors.brand,
                  fontFamily: AppFonts.montserrat,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: TextStyle(
                  color: CarenetColors.neutral700,
                  fontFamily: AppFonts.montserrat,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                subtitle,
                style: TextStyle(
                  color: CarenetColors.neutral500,
                  fontFamily: AppFonts.montserrat,
                  fontSize: 14.sp,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 22.h),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: CarenetColors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: CarenetColors.neutral200),
                ),
                child: Padding(padding: EdgeInsets.all(16.r), child: child),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        label,
        style: TextStyle(
          color: CarenetColors.neutral700,
          fontFamily: AppFonts.montserrat,
          fontSize: 17.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: CarenetColors.primary100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: CarenetColors.neutral700,
          fontFamily: AppFonts.montserrat,
          fontSize: 12.sp,
          height: 1.35,
        ),
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final text = message;
    if (text == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.only(top: 14.h),
      child: Text(
        text,
        style: TextStyle(
          color: CarenetColors.error100,
          fontFamily: AppFonts.montserrat,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}

String? Function(String?) _required(String message) {
  return (value) => value == null || value.trim().isEmpty ? message : null;
}

String? _yearsValidator(String? value) {
  final text = value?.trim() ?? '';
  final years = int.tryParse(text);
  if (years == null) {
    return 'Years of experience is required';
  }
  if (years < 0 || years > 80) {
    return 'Enter 0 to 80 years';
  }
  return null;
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
