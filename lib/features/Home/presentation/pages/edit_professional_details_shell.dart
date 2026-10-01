import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/domain/entities/professional_profile.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfessionalDetailsShellPage extends StatefulWidget {
  const EditProfessionalDetailsShellPage({super.key, this.profileRepository});

  final ProfileRepository? profileRepository;

  @override
  State<EditProfessionalDetailsShellPage> createState() =>
      _EditProfessionalDetailsShellPageState();
}

class _EditProfessionalDetailsShellPageState
    extends State<EditProfessionalDetailsShellPage> {
  late final TextEditingController _categoryController;
  late final TextEditingController _specialtyController;
  String? _categoryErrorText;
  String? _profileStateMessage;
  _SavedProfessionalDetails? _savedDetails;
  ProfessionalProfile? _professionalProfile;
  bool _isLoadingProfile = true;
  bool _isSaving = false;

  ProfileRepository get _profileRepository =>
      widget.profileRepository ?? sl<ProfileRepository>();

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController();
    _specialtyController = TextEditingController();
    _loadProfessionalProfile();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  Future<void> _loadProfessionalProfile() async {
    setState(() {
      _isLoadingProfile = true;
      _profileStateMessage = 'Loading professional profile...';
    });

    try {
      final profile = await _profileRepository.professionalMe();
      if (!mounted) {
        return;
      }
      setState(() {
        _professionalProfile = profile;
        _isLoadingProfile = false;
        if (profile == null) {
          _profileStateMessage =
              'Professional profile has not been created yet.';
          return;
        }
        _categoryController.text = profile.category;
        _specialtyController.text = profile.specialty ?? '';
        _profileStateMessage = null;
      });
    } on AuthFailure catch (failure) {
      if (!mounted) {
        return;
      }
      setState(() {
        _professionalProfile = null;
        _isLoadingProfile = false;
        _profileStateMessage = _safeProfileError(failure);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _professionalProfile = null;
        _isLoadingProfile = false;
        _profileStateMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  Future<void> _saveProfessionalDetails() async {
    final category = _normalizeSingleLine(_categoryController.text);
    final specialty = _normalizeSingleLine(_specialtyController.text);
    final specialtyPayload = specialty.isEmpty ? null : specialty;

    setState(() {
      _savedDetails = null;
      if (category.isEmpty) {
        _categoryErrorText = 'Category is required';
        return;
      }
      _categoryErrorText = null;
    });

    if (_categoryErrorText != null) {
      return;
    }

    final currentProfile = _professionalProfile;
    if (currentProfile == null) {
      setState(() {
        _profileStateMessage = 'Professional profile has not been created yet.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _profileStateMessage = null;
    });

    try {
      final updated = await _profileRepository.updateProfessionalMe(
        displayName: currentProfile.displayName,
        category: category,
        specialty: specialtyPayload,
        bio: currentProfile.bio,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _professionalProfile = updated;
        _categoryController.text = updated.category;
        _specialtyController.text = updated.specialty ?? '';
        _savedDetails = _SavedProfessionalDetails(
          category: updated.category,
          specialty: updated.specialty,
        );
      });
    } on AuthFailure catch (failure) {
      if (!mounted) {
        return;
      }
      setState(() {
        _profileStateMessage = _safeProfileError(failure);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _profileStateMessage = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _normalizeSingleLine(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _safeProfileError(AuthFailure failure) {
    return switch (failure.type) {
      AuthFailureType.missingConfiguration => 'Backend is not configured yet.',
      AuthFailureType.unauthorized => 'Please sign in again.',
      AuthFailureType.forbidden => 'This account cannot edit this profile.',
      AuthFailureType.validation => 'Please check the details and try again.',
      AuthFailureType.server ||
      AuthFailureType.network => 'Service is unavailable. Please try again.',
      AuthFailureType.invalidCredentials ||
      AuthFailureType.unknown => 'Something went wrong. Please try again.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final canSave =
        !_isLoadingProfile && !_isSaving && _professionalProfile != null;

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
          'Professional details',
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
          padding: REdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
          children: [
            Text(
              'Category and specialty',
              style: TextStyle(
                fontSize: FontSizes.body3,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w700,
                color: AppColors.kBlack,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Save your professional category and optional specialty only. Name, bio, website, address, verification, availability, and account settings stay separate.',
              style: TextStyle(
                fontSize: FontSizes.footer4,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryBlue11,
                height: 1.45,
              ),
            ),
            if (_profileStateMessage != null) ...[
              SizedBox(height: 14.h),
              _ProfileStateCard(message: _profileStateMessage!),
            ],
            SizedBox(height: 18.h),
            CarenetTextField(
              label: 'Category',
              hintText: 'Professional category',
              controller: _categoryController,
              textInputAction: TextInputAction.next,
              validationState:
                  _categoryErrorText == null
                      ? CarenetTextFieldValidationState.none
                      : CarenetTextFieldValidationState.invalid,
              errorText: _categoryErrorText,
              onChanged: (_) {
                if (_categoryErrorText != null || _savedDetails != null) {
                  setState(() {
                    _categoryErrorText = null;
                    _savedDetails = null;
                  });
                }
              },
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Specialty',
              hintText: 'Optional specialty',
              controller: _specialtyController,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                if (_savedDetails != null) {
                  setState(() {
                    _savedDetails = null;
                  });
                }
              },
              onFieldSubmitted: (_) {
                if (canSave) {
                  _saveProfessionalDetails();
                }
              },
            ),
            SizedBox(height: 18.h),
            CarenetButton(
              label: _isSaving ? 'Saving...' : 'Save',
              onPressed: canSave ? _saveProfessionalDetails : null,
            ),
            SizedBox(height: 16.h),
            if (_savedDetails != null)
              _SavedProfessionalDetailsCard(savedDetails: _savedDetails!),
          ],
        ),
      ),
    );
  }
}

class _ProfileStateCard extends StatelessWidget {
  const _ProfileStateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: FontSizes.footer4,
          fontFamily: AppFonts.montserrat,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBlue5,
          height: 1.45,
        ),
      ),
    );
  }
}

class _SavedProfessionalDetailsCard extends StatelessWidget {
  const _SavedProfessionalDetailsCard({required this.savedDetails});

  final _SavedProfessionalDetails savedDetails;

  @override
  Widget build(BuildContext context) {
    final specialty = savedDetails.specialty?.trim();

    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Professional details saved',
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            savedDetails.category,
            style: TextStyle(
              fontSize: FontSizes.footer2,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue5,
            ),
          ),
          if (specialty != null && specialty.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              specialty,
              style: TextStyle(
                fontSize: FontSizes.footer3,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryBlue11,
              ),
            ),
          ],
          SizedBox(height: 8.h),
          Text(
            'Only your professional category and specialty were updated. Display name, bio, website, address, availability, and verification remain separate.',
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedProfessionalDetails {
  const _SavedProfessionalDetails({required this.category, this.specialty});

  final String category;
  final String? specialty;
}
