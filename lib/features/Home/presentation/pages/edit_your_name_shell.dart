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

class EditYourNameShellPage extends StatefulWidget {
  const EditYourNameShellPage({super.key, this.profileRepository});

  final ProfileRepository? profileRepository;

  @override
  State<EditYourNameShellPage> createState() => _EditYourNameShellPageState();
}

class _EditYourNameShellPageState extends State<EditYourNameShellPage> {
  late final TextEditingController _nameController;
  String? _errorText;
  String? _profileStateMessage;
  String? _savedName;
  ProfessionalProfile? _professionalProfile;
  bool _isLoadingProfile = true;
  bool _isSaving = false;

  ProfileRepository get _profileRepository =>
      widget.profileRepository ?? sl<ProfileRepository>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadProfessionalProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
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
        _nameController.text = profile.displayName;
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

  Future<void> _saveDisplayName() async {
    final name = _nameController.text.trim().replaceAll(RegExp(r'\s+'), ' ');

    setState(() {
      _savedName = null;
      if (name.isEmpty) {
        _errorText = 'Name is required';
        return;
      }
      if (name.length < 3) {
        _errorText = 'Enter at least 3 characters';
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
        displayName: name,
        category: currentProfile.category,
        specialty: currentProfile.specialty,
        bio: currentProfile.bio,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _professionalProfile = updated;
        _nameController.text = updated.displayName;
        _savedName = updated.displayName;
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
    final hasError = _errorText != null;

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: Semantics(
          label: 'Back',
          button: true,
          onTap: () {
            Navigator.of(context).maybePop();
          },
          child: ExcludeSemantics(
            child: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Edit your name',
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
              'Enter a new name to continue',
              style: TextStyle(
                fontSize: FontSizes.body3,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w700,
                color: AppColors.kBlack,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Save your professional display name only. Category, specialty, website, address, verification, and account settings stay separate.',
              style: TextStyle(
                fontSize: FontSizes.footer4,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryBlue11,
                height: 1.45,
              ),
            ),
            SizedBox(height: 18.h),
            if (_profileStateMessage != null) ...[
              _ProfileStateMessage(message: _profileStateMessage!),
              SizedBox(height: 14.h),
            ],
            CarenetTextField(
              label: 'Your name',
              hintText: 'Your name',
              controller: _nameController,
              textInputAction: TextInputAction.done,
              validationState:
                  hasError
                      ? CarenetTextFieldValidationState.invalid
                      : CarenetTextFieldValidationState.none,
              errorText: _errorText,
              onChanged: (_) {
                if (_errorText != null || _savedName != null) {
                  setState(() {
                    _errorText = null;
                    _savedName = null;
                  });
                }
              },
              onFieldSubmitted: (_) {
                if (!_isLoadingProfile && !_isSaving) {
                  _saveDisplayName();
                }
              },
            ),
            SizedBox(height: 18.h),
            CarenetButton(
              label: _isSaving ? 'Saving...' : 'Save',
              onPressed:
                  _isLoadingProfile || _isSaving ? null : _saveDisplayName,
            ),
            SizedBox(height: 16.h),
            if (_savedName != null) _SavedNameCard(savedName: _savedName!),
          ],
        ),
      ),
    );
  }
}

class _ProfileStateMessage extends StatelessWidget {
  const _ProfileStateMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(12.r),
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
          fontWeight: FontWeight.w500,
          color: AppColors.primaryBlue11,
          height: 1.45,
        ),
      ),
    );
  }
}

class _SavedNameCard extends StatelessWidget {
  const _SavedNameCard({required this.savedName});

  final String savedName;

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
            'Display name saved',
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            savedName,
            style: TextStyle(
              fontSize: FontSizes.footer2,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Only your professional display name was updated. Category, specialty, website, address, availability, and verification remain separate.',
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
