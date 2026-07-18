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
      title: 'Your care profile',
      subtitle:
          'Add the basics now, or browse first and complete required details when you book.',
      stepLabel: 'Patient setup - optional for browsing',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PatientSetupSummary(),
            SizedBox(height: 22.h),
            const _SectionHeader('Basics'),
            CarenetTextField(
              label: 'Full name',
              hintText: 'e.g. Ada Okafor',
              controller: _nameController,
              textInputAction: TextInputAction.next,
              validator: _required('Full name is required'),
            ),
            SizedBox(height: 8.h),
            const _FieldHelp(
              'Use the name you want CareNet professionals to see before a consultation.',
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
            SizedBox(height: 8.h),
            const _FieldHelp(
              'This is optional now, but may be required before your first consultation.',
            ),
            SizedBox(height: 14.h),
            const _SectionHeader('Location'),
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
            SizedBox(height: 22.h),
            const _SectionHeader('Care interests'),
            CarenetTextField(
              label: 'What are you looking for?',
              hintText: 'Primary care, wellness, diabetes support',
              controller: _healthInterestsController,
              minLines: 3,
              maxLines: 4,
            ),
            SizedBox(height: 8.h),
            const _FieldHelp(
              'Share only what helps personalize discovery. Do not enter emergency details here.',
            ),
            _StatusText(message: _message),
            SizedBox(height: 20.h),
            CarenetButton(
              label: _isSaving ? 'Saving profile...' : 'Save and continue',
              onPressed: _isSaving ? null : _savePatientProfile,
            ),
            SizedBox(height: 10.h),
            CarenetButton(
              label: 'Skip for now',
              type: CarenetButtonType.outline,
              onPressed: _isSaving ? null : _skipPatientProfile,
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

  void _skipPatientProfile() {
    Navigator.of(context).popAndPushNamed(RouteName.communityAgreement);
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
      title: 'Apply as a professional',
      subtitle:
          'Complete the details CareNet needs before document review. Your profile is not public until verification is approved.',
      stepLabel: 'Professional application',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ProfessionalApplicationIntro(),
            SizedBox(height: 22.h),
            const _ApplicationProgress(
              currentStep: 1,
              totalSteps: 2,
              label: 'Profile details before evidence upload',
            ),
            SizedBox(height: 22.h),
            const _SectionHeader('Identity'),
            const _PrivacyLabel('Private for review'),
            CarenetTextField(
              label: 'Legal name',
              hintText: 'Name on your license',
              controller: _legalNameController,
              textInputAction: TextInputAction.next,
              validator: _required('Legal name is required'),
            ),
            SizedBox(height: 8.h),
            const _FieldHelp(
              'Use the legal name that appears on your licence or registration record.',
            ),
            SizedBox(height: 14.h),
            const _PrivacyLabel('Shown publicly after approval'),
            CarenetTextField(
              label: 'Public professional name',
              hintText: 'Dr. Ada Okafor',
              controller: _displayNameController,
              textInputAction: TextInputAction.next,
              validator: _required('Public professional name is required'),
            ),
            SizedBox(height: 8.h),
            const _FieldHelp(
              'This is the name patients will see only after CareNet approves your profile.',
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Profession/category',
              hintText: 'Doctor, Nurse, Pharmacist',
              controller: _categoryController,
              textInputAction: TextInputAction.next,
              validator: _required('Profession/category is required'),
            ),
            SizedBox(height: 8.h),
            const _FieldHelp(
              'Use your regulated healthcare profession. Catalog selection is deferred until profession lists are available.',
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
            const _PrivacyLabel('Private for review'),
            CarenetTextField(
              label: 'License or registration number',
              hintText: 'MDCN-12345',
              controller: _licenseNumberController,
              textInputAction: TextInputAction.next,
              validator: _required('License number is required'),
            ),
            SizedBox(height: 8.h),
            const _FieldHelp(
              'CareNet uses this for credential review. It is not shown to patients from this form.',
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Licensing council/body',
              hintText: 'MDCN, NMCN, PCN',
              controller: _licensingCouncilController,
              textInputAction: TextInputAction.next,
              validator: _required('Licensing council is required'),
            ),
            SizedBox(height: 8.h),
            const _FieldHelp(
              'Examples include MDCN, NMCN, PCN, or another Nigerian regulator/council.',
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
            const _PrivacyLabel('Reviewed before public listing'),
            CarenetTextField(
              label: 'Practice or facility name',
              hintText: 'Care Clinic',
              controller: _practiceNameController,
              textInputAction: TextInputAction.next,
              validator: _required('Practice name is required'),
            ),
            SizedBox(height: 8.h),
            const _FieldHelp(
              'Use the facility, clinic, or practice patients should associate with your work after approval.',
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
                  'Next you will upload licence, identity, or certification documents. This saves your profile details only; approval and public listing require backend verification.',
            ),
            _StatusText(message: _message),
            SizedBox(height: 20.h),
            CarenetButton(
              label:
                  _isSaving
                      ? 'Saving application...'
                      : 'Save application and upload evidence',
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

class _PatientSetupSummary extends StatelessWidget {
  const _PatientSetupSummary();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _PatientSetupPoint(
          icon: Icons.manage_accounts_outlined,
          title: 'Create a useful care profile',
          body:
              'Professionals see your saved basics when a consultation needs them.',
        ),
        _PatientSetupPoint(
          icon: Icons.lock_outline,
          title: 'Keep sensitive care steps gated',
          body: 'Booking, consent, and verified contact checks stay separate.',
        ),
        _PatientSetupPoint(
          icon: Icons.explore_outlined,
          title: 'Browse before completing everything',
          body: 'Skipping does not mark your profile ready for booking.',
        ),
      ],
    );
  }
}

class _PatientSetupPoint extends StatelessWidget {
  const _PatientSetupPoint({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CarenetColors.info200,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: CarenetColors.neutral700, size: 18.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: CarenetColors.neutral700,
                    fontFamily: AppFonts.montserrat,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  body,
                  style: TextStyle(
                    color: CarenetColors.neutral500,
                    fontFamily: AppFonts.montserrat,
                    fontSize: 12.sp,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalApplicationIntro extends StatelessWidget {
  const _ProfessionalApplicationIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _PatientSetupPoint(
          icon: Icons.badge_outlined,
          title: 'Tell us who you are',
          body:
              'Legal identity and public display name stay separate for review.',
        ),
        _PatientSetupPoint(
          icon: Icons.verified_user_outlined,
          title: 'Prepare regulated credentials',
          body:
              'Licence, council, qualifications, and experience are required before evidence upload.',
        ),
        _PatientSetupPoint(
          icon: Icons.business_outlined,
          title: 'Confirm your practice details',
          body:
              'CareNet reviews these details before any public listing or patient booking.',
        ),
      ],
    );
  }
}

class _ApplicationProgress extends StatelessWidget {
  const _ApplicationProgress({
    required this.currentStep,
    required this.totalSteps,
    required this.label,
  });

  final int currentStep;
  final int totalSteps;
  final String label;

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: CarenetColors.neutral100,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: CarenetColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step $currentStep of $totalSteps',
            style: TextStyle(
              color: CarenetColors.brand,
              fontFamily: AppFonts.montserrat,
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              color: CarenetColors.neutral700,
              fontFamily: AppFonts.montserrat,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.h,
              backgroundColor: CarenetColors.neutral200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                CarenetColors.brand,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyLabel extends StatelessWidget {
  const _PrivacyLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, color: CarenetColors.neutral400, size: 14.r),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              color: CarenetColors.neutral500,
              fontFamily: AppFonts.montserrat,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldHelp extends StatelessWidget {
  const _FieldHelp(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: CarenetColors.neutral400,
        fontFamily: AppFonts.montserrat,
        fontSize: 11.sp,
        height: 1.35,
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
