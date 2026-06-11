import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/public_profile_local_store.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddDescriptionShellPage extends StatefulWidget {
  const AddDescriptionShellPage({super.key});

  @override
  State<AddDescriptionShellPage> createState() =>
      _AddDescriptionShellPageState();
}

class _AddDescriptionShellPageState extends State<AddDescriptionShellPage> {
  late final TextEditingController _descriptionController;
  String? _errorText;
  String? _preparedDescription;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: PublicProfileLocalStore.profile.about,
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _prepareDescriptionDraft() {
    final description = _descriptionController.text.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    setState(() {
      _preparedDescription = null;
      if (description.isEmpty) {
        _errorText = 'Description is required';
        return;
      }
      if (description.length < 20) {
        _errorText = 'Enter at least 20 characters';
        return;
      }
      _errorText = null;
      _preparedDescription = description;
    });
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
              'This prepares profile copy only. Publishing, moderation, and profile persistence still need backend rules.',
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
                if (_errorText != null || _preparedDescription != null) {
                  setState(() {
                    _errorText = null;
                    _preparedDescription = null;
                  });
                }
              },
            ),
            SizedBox(height: 18.h),
            CarenetButton(label: 'Save', onPressed: _prepareDescriptionDraft),
            SizedBox(height: 16.h),
            if (_preparedDescription != null)
              _PreparedDescriptionCard(
                preparedDescription: _preparedDescription!,
              ),
          ],
        ),
      ),
    );
  }
}

class _PreparedDescriptionCard extends StatelessWidget {
  const _PreparedDescriptionCard({required this.preparedDescription});

  final String preparedDescription;

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
            'Description draft prepared',
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            preparedDescription,
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
            'No profile description has been saved. Backend profile persistence should replace this local draft seam.',
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
