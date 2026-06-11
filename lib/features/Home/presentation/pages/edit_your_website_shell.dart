import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/public_profile_local_store.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditYourWebsiteShellPage extends StatefulWidget {
  const EditYourWebsiteShellPage({super.key});

  @override
  State<EditYourWebsiteShellPage> createState() =>
      _EditYourWebsiteShellPageState();
}

class _EditYourWebsiteShellPageState extends State<EditYourWebsiteShellPage> {
  late final TextEditingController _websiteController;
  String? _errorText;
  String? _preparedWebsite;

  @override
  void initState() {
    super.initState();
    _websiteController = TextEditingController(
      text: PublicProfileLocalStore.profile.website,
    );
  }

  @override
  void dispose() {
    _websiteController.dispose();
    super.dispose();
  }

  void _prepareWebsiteDraft() {
    final website = _websiteController.text.trim();

    setState(() {
      _preparedWebsite = null;
      if (website.isEmpty) {
        _errorText = 'Website is required';
        return;
      }
      if (!_looksLikeWebsite(website)) {
        _errorText = 'Enter a valid website';
        return;
      }
      _errorText = null;
      _preparedWebsite = website;
    });
  }

  bool _looksLikeWebsite(String value) {
    final normalized = value.toLowerCase();
    final uri = Uri.tryParse(
      normalized.startsWith('http') ? normalized : 'https://$normalized',
    );
    return uri != null &&
        uri.host.contains('.') &&
        !uri.host.startsWith('.') &&
        !uri.host.endsWith('.');
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
          'Edit your website',
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
              'Add a website',
              style: TextStyle(
                fontSize: FontSizes.body3,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w700,
                color: AppColors.kBlack,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'This prepares a website draft only. Profile persistence, verification, and account sync still need backend rules.',
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
              label: 'Your website',
              hintText: 'Your website',
              controller: _websiteController,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              validationState:
                  hasError
                      ? CarenetTextFieldValidationState.invalid
                      : CarenetTextFieldValidationState.none,
              errorText: _errorText,
              onChanged: (_) {
                if (_errorText != null || _preparedWebsite != null) {
                  setState(() {
                    _errorText = null;
                    _preparedWebsite = null;
                  });
                }
              },
              onFieldSubmitted: (_) => _prepareWebsiteDraft(),
            ),
            SizedBox(height: 18.h),
            CarenetButton(label: 'Save', onPressed: _prepareWebsiteDraft),
            SizedBox(height: 16.h),
            if (_preparedWebsite != null)
              _PreparedWebsiteCard(preparedWebsite: _preparedWebsite!),
          ],
        ),
      ),
    );
  }
}

class _PreparedWebsiteCard extends StatelessWidget {
  const _PreparedWebsiteCard({required this.preparedWebsite});

  final String preparedWebsite;

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
            'Website draft prepared',
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            preparedWebsite,
            style: TextStyle(
              fontSize: FontSizes.footer2,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'No profile website has been saved. Backend profile persistence should replace this local draft seam.',
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
