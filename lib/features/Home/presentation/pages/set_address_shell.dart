import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/public_profile_local_store.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SetAddressShellPage extends StatefulWidget {
  const SetAddressShellPage({super.key});

  @override
  State<SetAddressShellPage> createState() => _SetAddressShellPageState();
}

class _SetAddressShellPageState extends State<SetAddressShellPage> {
  late final TextEditingController _addressController;
  String? _errorText;
  String? _preparedAddress;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text: PublicProfileLocalStore.profile.address,
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _prepareAddressDraft() {
    final address = _addressController.text.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    setState(() {
      _preparedAddress = null;
      if (address.isEmpty) {
        _errorText = 'Address is required';
        return;
      }
      if (address.length < 10) {
        _errorText = 'Enter at least 10 characters';
        return;
      }
      _errorText = null;
      _preparedAddress = address;
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
          'Set address',
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
              'Your location',
              style: TextStyle(
                fontSize: FontSizes.body3,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w700,
                color: AppColors.kBlack,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'This prepares a profile-address draft only. Saving, verification, maps, and location services still need backend rules.',
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
              label: 'Your location',
              hintText: 'Your location',
              controller: _addressController,
              keyboardType: TextInputType.streetAddress,
              textInputAction: TextInputAction.done,
              validationState:
                  _errorText == null
                      ? CarenetTextFieldValidationState.none
                      : CarenetTextFieldValidationState.invalid,
              errorText: _errorText,
              onChanged: (_) {
                if (_errorText != null || _preparedAddress != null) {
                  setState(() {
                    _errorText = null;
                    _preparedAddress = null;
                  });
                }
              },
              onFieldSubmitted: (_) => _prepareAddressDraft(),
            ),
            SizedBox(height: 18.h),
            CarenetButton(label: 'Save', onPressed: _prepareAddressDraft),
            SizedBox(height: 16.h),
            if (_preparedAddress != null)
              _PreparedAddressCard(preparedAddress: _preparedAddress!),
          ],
        ),
      ),
    );
  }
}

class _PreparedAddressCard extends StatelessWidget {
  const _PreparedAddressCard({required this.preparedAddress});

  final String preparedAddress;

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
            'Address draft prepared',
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            preparedAddress,
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue5,
              height: 1.45,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'No profile address has been saved. Backend profile persistence should replace this local draft seam.',
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
