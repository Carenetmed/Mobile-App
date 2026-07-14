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

class AddDescriptionShellPage extends StatefulWidget {
  const AddDescriptionShellPage({super.key, this.profileRepository});

  final ProfileRepository? profileRepository;

  @override
  State<AddDescriptionShellPage> createState() =>
      _AddDescriptionShellPageState();
}

class _AddDescriptionShellPageState extends State<AddDescriptionShellPage> {
  late final TextEditingController _descriptionController;
  String? _errorText;
  String? _profileStateMessage;
  String? _savedDescription;
  ProfessionalProfile? _professionalProfile;
  bool _isLoadingProfile = true;
  bool _isSaving = false;

  ProfileRepository get _profileRepository =>
      widget.profileRepository ?? sl<ProfileRepository>();

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _loadProfessionalProfile();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
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
        final bio = profile.bio?.trim();
        if (bio != null && bio.isNotEmpty) {
          _descriptionController.text = bio;
        }
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

  Future<void> _saveDescription() async {
    final description = _descriptionController.text.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    setState(() {
      _savedDescription = null;
      if (description.isEmpty) {
        _errorText = 'Description is required';
        return;
      }
      if (description.length < 20) {
        _errorText = 'Enter at least 20 characters';
        return;
      }
      _errorText = null;
    });

    if (_errorText != null) {
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
        category: currentProfile.category,
        specialty: currentProfile.specialty,
        bio: description,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _professionalProfile = updated;
        _descriptionController.text = updated.bio ?? description;
        _savedDescription = updated.bio ?? description;
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

  String _safeProfileError(AuthFailure failure) {
    return switch (failure.type) {
      AuthFailureType.missingConfiguration => 'Backend is not configured yet.',
      AuthFailureType.unauthorized => 'Please sign in again.',
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
          'Add description',
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
              'Description',
              style: TextStyle(
                fontSize: FontSizes.body3,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w700,
                color: AppColors.kBlack,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Save bio changes to your professional profile. Publishing, moderation, and wider profile fields remain separate.',
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
              label: 'Description',
              hintText: 'Describe your professional profile',
              controller: _descriptionController,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              minLines: 5,
              maxLines: 8,
              validationState:
                  _errorText == null
                      ? CarenetTextFieldValidationState.none
                      : CarenetTextFieldValidationState.invalid,
              errorText: _errorText,
              onChanged: (_) {
                if (_errorText != null || _savedDescription != null) {
                  setState(() {
                    _errorText = null;
                    _savedDescription = null;
                  });
                }
              },
            ),
            SizedBox(height: 18.h),
            CarenetButton(
              label: _isSaving ? 'Saving...' : 'Save',
              onPressed: canSave ? _saveDescription : null,
            ),
            SizedBox(height: 16.h),
            if (_savedDescription != null)
              _SavedDescriptionCard(savedDescription: _savedDescription!),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedDescriptionCard extends StatelessWidget {
  const _SavedDescriptionCard({required this.savedDescription});

  final String savedDescription;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description saved',
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            savedDescription,
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryBlue5,
              height: 1.45,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Only your professional bio was updated. Name, category, website, address, availability, and verification remain separate.',
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
