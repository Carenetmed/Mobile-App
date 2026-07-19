import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/domain/entities/account_readiness.dart';
import 'package:app_t/features/Home/domain/entities/onboarding_catalog.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PatientOnboardingSetupPage extends StatefulWidget {
  const PatientOnboardingSetupPage({
    super.key,
    this.profileRepository,
    this.onboardingRepository,
  });

  final ProfileRepository? profileRepository;
  final OnboardingRepository? onboardingRepository;

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
  OnboardingCatalog? _catalog;
  OnboardingCountry? _selectedCountry;
  OnboardingRegion? _selectedState;
  PatientHealthInterest? _selectedHealthInterest;
  AccountReadiness? _readiness;
  bool _isLoadingCatalog = true;
  bool _isSaving = false;
  String? _message;
  DateTime? _dateOfBirth;

  ProfileRepository get _profileRepository =>
      widget.profileRepository ?? sl<ProfileRepository>();

  OnboardingRepository get _onboardingRepository =>
      widget.onboardingRepository ?? sl<OnboardingRepository>();

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateOfBirthController.dispose();
    _cityController.dispose();
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
            CarenetTextField(
              label: 'City',
              hintText: 'Lagos',
              controller: _cityController,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 14.h),
            _CatalogSelect<OnboardingRegion>(
              label: 'State',
              hintText: _catalogHint('Select state'),
              value: _selectedState,
              items: _catalog?.nigeriaStates ?? const <OnboardingRegion>[],
              itemLabel: (state) => state.name,
              onChanged:
                  _isCatalogReady
                      ? (state) => setState(() => _selectedState = state)
                      : null,
              validator: (state) => state == null ? 'State is required' : null,
            ),
            SizedBox(height: 14.h),
            _CatalogSelect<OnboardingCountry>(
              label: 'Country',
              hintText: _catalogHint('Select country'),
              value: _selectedCountry,
              items: _catalog?.countries ?? const <OnboardingCountry>[],
              itemLabel: (country) => country.name,
              onChanged:
                  _isCatalogReady
                      ? (country) => setState(() => _selectedCountry = country)
                      : null,
              validator:
                  (country) => country == null ? 'Country is required' : null,
            ),
            SizedBox(height: 14.h),
            _CatalogSelect<PatientHealthInterest>(
              label: 'Primary health interest',
              hintText: _catalogHint('Select interest'),
              value: _selectedHealthInterest,
              items:
                  _catalog?.patientHealthInterestCatalog ??
                  const <PatientHealthInterest>[],
              itemLabel: (interest) => interest.label,
              onChanged:
                  _isCatalogReady
                      ? (interest) =>
                          setState(() => _selectedHealthInterest = interest)
                      : null,
              validator:
                  (interest) =>
                      interest == null ? 'Health interest is required' : null,
            ),
            SizedBox(height: 16.h),
            _InfoCard(message: _readinessCopy(_readiness, 'patient')),
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

  bool get _isCatalogReady => !_isLoadingCatalog && _catalog != null;

  Future<void> _loadCatalog() async {
    try {
      final catalog = await _onboardingRepository.onboardingCatalog();
      if (!mounted) {
        return;
      }
      setState(() {
        _catalog = catalog;
        _selectedCountry = _firstLaunchCountry(catalog);
        _selectedState =
            catalog.nigeriaStates.isNotEmpty
                ? catalog.nigeriaStates.first
                : null;
        _selectedHealthInterest =
            catalog.patientHealthInterestCatalog.isNotEmpty
                ? catalog.patientHealthInterestCatalog.first
                : null;
        _isLoadingCatalog = false;
      });
      _loadReadiness();
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() {
          _message = failure.message;
          _isLoadingCatalog = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _message = 'Could not load onboarding options. Please try again.';
          _isLoadingCatalog = false;
        });
      }
    }
  }

  Future<void> _loadReadiness() async {
    try {
      final readiness = await _onboardingRepository.accountReadiness();
      if (mounted) {
        setState(() => _readiness = readiness);
      }
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() => _message = failure.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'Could not load account readiness.');
      }
    }
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
    if (!_isCatalogReady) {
      setState(() => _message = 'Onboarding options are still unavailable.');
      return;
    }
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
        state: _selectedState?.name,
        country: _selectedCountry?.name,
        healthInterests: _selectedHealthInterest?.label,
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
  const ProfessionalOnboardingSetupPage({
    super.key,
    this.profileRepository,
    this.onboardingRepository,
  });

  final ProfileRepository? profileRepository;
  final OnboardingRepository? onboardingRepository;

  @override
  State<ProfessionalOnboardingSetupPage> createState() =>
      _ProfessionalOnboardingSetupPageState();
}

class _ProfessionalOnboardingSetupPageState
    extends State<ProfessionalOnboardingSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _legalNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _yearsController = TextEditingController();
  final _practiceNameController = TextEditingController();
  final _practiceAddressController = TextEditingController();
  final _practiceCityController = TextEditingController();
  OnboardingCatalog? _catalog;
  OnboardingCountry? _selectedCountry;
  OnboardingRegion? _selectedState;
  ProfessionalCatalogItem? _selectedProfession;
  AccountReadiness? _readiness;
  bool _isLoadingCatalog = true;
  bool _isSaving = false;
  String? _message;

  ProfileRepository get _profileRepository =>
      widget.profileRepository ?? sl<ProfileRepository>();

  OnboardingRepository get _onboardingRepository =>
      widget.onboardingRepository ?? sl<OnboardingRepository>();

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  @override
  void dispose() {
    _legalNameController.dispose();
    _displayNameController.dispose();
    _specialtyController.dispose();
    _licenseNumberController.dispose();
    _qualificationsController.dispose();
    _yearsController.dispose();
    _practiceNameController.dispose();
    _practiceAddressController.dispose();
    _practiceCityController.dispose();
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
            _CatalogSelect<ProfessionalCatalogItem>(
              label: 'Profession/category',
              hintText: _catalogHint('Select profession'),
              value: _selectedProfession,
              items:
                  _catalog?.professionalCatalog ??
                  const <ProfessionalCatalogItem>[],
              itemLabel: (profession) => profession.label,
              onChanged:
                  _isCatalogReady
                      ? (profession) =>
                          setState(() => _selectedProfession = profession)
                      : null,
              validator:
                  (profession) =>
                      profession == null
                          ? 'Profession/category is required'
                          : null,
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
            _ReadOnlyValue(
              label: 'Licensing council/body',
              value: _selectedProfession?.regulatorName,
              emptyText: _catalogHint('Selected from profession'),
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
              ],
            ),
            SizedBox(height: 14.h),
            _CatalogSelect<OnboardingRegion>(
              label: 'Practice state',
              hintText: _catalogHint('Select state'),
              value: _selectedState,
              items: _catalog?.nigeriaStates ?? const <OnboardingRegion>[],
              itemLabel: (state) => state.name,
              onChanged:
                  _isCatalogReady
                      ? (state) => setState(() => _selectedState = state)
                      : null,
              validator:
                  (state) =>
                      state == null ? 'Practice state is required' : null,
            ),
            SizedBox(height: 14.h),
            _CatalogSelect<OnboardingCountry>(
              label: 'Practice country',
              hintText: _catalogHint('Select country'),
              value: _selectedCountry,
              items: _catalog?.countries ?? const <OnboardingCountry>[],
              itemLabel: (country) => country.name,
              onChanged:
                  _isCatalogReady
                      ? (country) => setState(() => _selectedCountry = country)
                      : null,
              validator:
                  (country) =>
                      country == null ? 'Practice country is required' : null,
            ),
            SizedBox(height: 16.h),
            const _InfoCard(
              message:
                  'Next you will upload license, identity, or certification documents. CareNet will not mark your profile verified from this form alone.',
            ),
            SizedBox(height: 12.h),
            _InfoCard(message: _readinessCopy(_readiness, 'professional')),
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

  bool get _isCatalogReady => !_isLoadingCatalog && _catalog != null;

  Future<void> _loadCatalog() async {
    try {
      final catalog = await _onboardingRepository.onboardingCatalog();
      if (!mounted) {
        return;
      }
      setState(() {
        _catalog = catalog;
        _selectedCountry = _firstLaunchCountry(catalog);
        _selectedState =
            catalog.nigeriaStates.isNotEmpty
                ? catalog.nigeriaStates.first
                : null;
        _selectedProfession =
            catalog.professionalCatalog.isNotEmpty
                ? catalog.professionalCatalog.first
                : null;
        _isLoadingCatalog = false;
      });
      _loadReadiness();
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() {
          _message = failure.message;
          _isLoadingCatalog = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _message = 'Could not load onboarding options. Please try again.';
          _isLoadingCatalog = false;
        });
      }
    }
  }

  Future<void> _loadReadiness() async {
    try {
      final readiness = await _onboardingRepository.accountReadiness();
      if (mounted) {
        setState(() => _readiness = readiness);
      }
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() => _message = failure.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'Could not load account readiness.');
      }
    }
  }

  Future<void> _saveProfessionalProfile() async {
    setState(() {
      _message = null;
    });
    if (!_isCatalogReady || _selectedProfession == null) {
      setState(() => _message = 'Onboarding options are still unavailable.');
      return;
    }
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
        category: _selectedProfession!.label,
        specialty: _emptyToNull(_specialtyController.text),
        licenseNumber: _licenseNumberController.text.trim(),
        licensingCouncil: _selectedProfession!.regulatorCode,
        qualifications: _qualificationsController.text.trim(),
        yearsOfExperience: int.parse(_yearsController.text.trim()),
        practiceName: _practiceNameController.text.trim(),
        practiceAddress: _emptyToNull(_practiceAddressController.text),
        practiceCity: _practiceCityController.text.trim(),
        practiceState: _selectedState?.name,
        practiceCountry: _selectedCountry?.name,
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

class _CatalogSelect<T> extends StatelessWidget {
  const _CatalogSelect({
    required this.label,
    required this.hintText,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    required this.validator,
  });

  final String label;
  final String hintText;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?) validator;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(6.r),
      borderSide: const BorderSide(color: CarenetColors.neutral200),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w400,
            color: CarenetColors.neutral700,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<T>(
          initialValue: items.contains(value) ? value : null,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
          validator: validator,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 16.sp,
              fontFamily: AppFonts.montserrat,
              color: CarenetColors.neutral300,
            ),
            filled: true,
            fillColor:
                onChanged == null
                    ? CarenetColors.neutral100
                    : CarenetColors.white,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(color: CarenetColors.info100),
            ),
            disabledBorder: border,
            errorBorder: border.copyWith(
              borderSide: const BorderSide(color: CarenetColors.error100),
            ),
            focusedErrorBorder: border.copyWith(
              borderSide: const BorderSide(color: CarenetColors.error100),
            ),
            errorStyle: TextStyle(
              fontSize: 10.sp,
              fontFamily: AppFonts.montserrat,
              color: CarenetColors.error100,
            ),
          ),
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: AppFonts.montserrat,
            color: CarenetColors.neutral700,
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyValue extends StatelessWidget {
  const _ReadOnlyValue({
    required this.label,
    required this.value,
    required this.emptyText,
  });

  final String label;
  final String? value;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final display =
        value?.trim().isNotEmpty == true ? value!.trim() : emptyText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w400,
            color: CarenetColors.neutral700,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: CarenetColors.neutral100,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: CarenetColors.neutral200),
          ),
          child: Text(
            display,
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: AppFonts.montserrat,
              color:
                  value?.trim().isNotEmpty == true
                      ? CarenetColors.neutral700
                      : CarenetColors.neutral300,
            ),
          ),
        ),
      ],
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

OnboardingCountry? _firstLaunchCountry(OnboardingCatalog catalog) {
  for (final country in catalog.countries) {
    if (country.code == catalog.launchCountry) {
      return country;
    }
  }
  return catalog.countries.isNotEmpty ? catalog.countries.first : null;
}

String _catalogHint(String fallback) {
  return fallback;
}

String _readinessCopy(AccountReadiness? readiness, String role) {
  final current = readiness;
  if (current == null) {
    return 'Checking account readiness before profile submission.';
  }
  if (role == 'professional' && current.professional != null) {
    final missing = current.professional!.requiredProfileFields.length;
    return missing == 0
        ? 'Your professional profile fields are ready for document review.'
        : '$missing professional profile fields still need confirmation.';
  }
  if (role == 'patient' && current.patient != null) {
    final missing = current.patient!.requiredFields.length;
    return missing == 0
        ? 'Your patient profile is ready to continue.'
        : '$missing patient profile fields still need confirmation.';
  }
  return 'Next step: ${current.nextAction.replaceAll('_', ' ').toLowerCase()}.';
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
