import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/public_profile_local_store.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditYourNameShellPage extends StatefulWidget {
  const EditYourNameShellPage({super.key});

  @override
  State<EditYourNameShellPage> createState() => _EditYourNameShellPageState();
}

class _EditYourNameShellPageState extends State<EditYourNameShellPage> {
  late final TextEditingController _nameController;
  String? _errorText;
  String? _preparedName;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: 'Dr. ${PublicProfileLocalStore.profile.name}',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _prepareNameDraft() {
    final name = _nameController.text.trim().replaceAll(RegExp(r'\s+'), ' ');

    setState(() {
      _preparedName = null;
      if (name.isEmpty) {
        _errorText = 'Name is required';
        return;
      }
      if (name.length < 3) {
        _errorText = 'Enter at least 3 characters';
        return;
      }
      _errorText = null;
      _preparedName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null;

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
              'This prepares a profile-name draft only. Profile persistence, verification, and account sync still need backend rules.',
              style: TextStyle(
                fontSize: FontSizes.footer4,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryBlue11,
                height: 1.45,
              ),
            ),
            SizedBox(height: 18.h),
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
                if (_errorText != null || _preparedName != null) {
                  setState(() {
                    _errorText = null;
                    _preparedName = null;
                  });
                }
              },
              onFieldSubmitted: (_) => _prepareNameDraft(),
            ),
            SizedBox(height: 18.h),
            CarenetButton(label: 'Save', onPressed: _prepareNameDraft),
            SizedBox(height: 16.h),
            if (_preparedName != null)
              _PreparedNameCard(preparedName: _preparedName!),
          ],
        ),
      ),
    );
  }
}

class _PreparedNameCard extends StatelessWidget {
  const _PreparedNameCard({required this.preparedName});

  final String preparedName;

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
            'Name draft prepared',
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            preparedName,
            style: TextStyle(
              fontSize: FontSizes.footer2,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'No profile name has been saved. Backend profile persistence should replace this local draft seam.',
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
