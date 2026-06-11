import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/pages/community_profile_page.dart';
import 'package:app_t/features/Home/presentation/state/communities_local_store.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateCommunityPage extends StatefulWidget {
  const CreateCommunityPage({super.key});

  @override
  State<CreateCommunityPage> createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  static const List<String> _privacyOptions = <String>['Public', 'Private'];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _inviteController = TextEditingController();

  String? _selectedPrivacy;
  String? _nameError;
  String? _descriptionError;
  String? _privacyError;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _inviteController.dispose();
    super.dispose();
  }

  String? _validateRequired(String value, String fieldName) {
    if (value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  void _submit() {
    final nameError = _validateRequired(_nameController.text, 'Community name');
    final descriptionError = _validateRequired(
      _descriptionController.text,
      'Community description',
    );
    final privacyError =
        _selectedPrivacy == null ? 'Privacy is required' : null;

    setState(() {
      _nameError = nameError;
      _descriptionError = descriptionError;
      _privacyError = privacyError;
    });

    if (nameError != null || descriptionError != null || privacyError != null) {
      return;
    }

    final invites =
        _inviteController.text
            .split(',')
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList();
    final profile = CommunitiesLocalStore.createCommunity(
      CreatedCommunityDraft(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        privacy: _selectedPrivacy!,
        invites: invites,
      ),
    );

    Navigator.pushReplacementNamed(
      context,
      RouteName.communityProfile,
      arguments: CommunityProfileRouteArgs(profile: profile, isOwner: true),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Create Community',
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
        child: SingleChildScrollView(
          padding: REdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: REdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue5,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default cover',
                      style: TextStyle(
                        fontSize: FontSizes.footer2,
                        fontFamily: AppFonts.montserrat,
                        fontWeight: FontWeight.w700,
                        color: AppColors.kWhite,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Cover image upload is intentionally deferred until media picking and backend storage exist. New communities use a local default cover for now.',
                      style: TextStyle(
                        fontSize: FontSizes.footer3,
                        fontFamily: AppFonts.montserrat,
                        fontWeight: FontWeight.w400,
                        color: AppColors.kWhite,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              CarenetTextField(
                label: 'Community name',
                hintText: 'Example: Heart Health Circle',
                controller: _nameController,
                onChanged: (_) => setState(() => _nameError = null),
                validationState:
                    _nameError == null
                        ? CarenetTextFieldValidationState.none
                        : CarenetTextFieldValidationState.invalid,
                errorText: _nameError,
              ),
              SizedBox(height: 20.h),
              CarenetTextField(
                label: 'Describe your community briefly',
                hintText: 'What is this community for?',
                controller: _descriptionController,
                onChanged: (_) => setState(() => _descriptionError = null),
                validationState:
                    _descriptionError == null
                        ? CarenetTextFieldValidationState.none
                        : CarenetTextFieldValidationState.invalid,
                errorText: _descriptionError,
              ),
              SizedBox(height: 20.h),
              Text(
                'Privacy',
                style: TextStyle(
                  fontSize: FontSizes.footer2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children:
                    _privacyOptions.map((privacy) {
                      final isSelected = _selectedPrivacy == privacy;
                      return ChoiceChip(
                        label: Text(privacy),
                        selected: isSelected,
                        selectedColor: AppColors.primaryBlue7,
                        backgroundColor: AppColors.blue02,
                        labelStyle: TextStyle(
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w500,
                          fontSize: FontSizes.footer4,
                          color:
                              isSelected
                                  ? AppColors.primaryBlue5
                                  : AppColors.kBlack,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedPrivacy = privacy;
                            _privacyError = null;
                          });
                        },
                      );
                    }).toList(),
              ),
              if (_privacyError != null) ...[
                SizedBox(height: 8.h),
                Text(
                  _privacyError!,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w400,
                    color: Colors.red,
                  ),
                ),
              ],
              SizedBox(height: 20.h),
              CarenetTextField(
                label: 'Invite people who should join',
                hintText: 'Optional: comma-separated names or emails',
                controller: _inviteController,
              ),
              SizedBox(height: 12.h),
              Text(
                'Invites stay local in this slice. Real invitations can plug into contacts and backend delivery later.',
                style: TextStyle(
                  fontSize: FontSizes.footer4,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryBlue11,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: CarenetButton(label: 'Create', onPressed: _submit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
