import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmergencyShellPage extends StatelessWidget {
  const EmergencyShellPage({super.key});

  static const List<_EmergencyUpdate> _updates = <_EmergencyUpdate>[
    _EmergencyUpdate(
      title: 'Ambulance approved',
      detail: 'Dispatch is on the way to your pinned location.',
    ),
    _EmergencyUpdate(
      title: 'Circle notified',
      detail: 'Your trusted contacts were alerted automatically.',
    ),
  ];

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
          'Emergency',
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
              Text(
                'Emergency support is now in one place.',
                style: TextStyle(
                  fontSize: FontSizes.body2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'This local emergency slice gives urgent notifications a real destination and a clean next action into distress reporting.',
                style: TextStyle(
                  fontSize: FontSizes.footer2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryBlue11,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),
              Container(
                width: double.infinity,
                padding: REdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  color: AppColors.blue02,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.white04),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current status',
                      style: TextStyle(
                        fontSize: FontSizes.footer3,
                        fontFamily: AppFonts.montserrat,
                        fontWeight: FontWeight.w700,
                        color: AppColors.kBlack,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Ambulance is on the way',
                      style: TextStyle(
                        fontSize: FontSizes.footer2,
                        fontFamily: AppFonts.montserrat,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue5,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Use the distress call form if the situation changes or responders need updated details.',
                      style: TextStyle(
                        fontSize: FontSizes.footer3,
                        fontFamily: AppFonts.montserrat,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryBlue11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: CarenetButton(
                  label: 'Open distress call',
                  onPressed: () {
                    Navigator.pushNamed(context, RouteName.distressCall);
                  },
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Latest updates',
                style: TextStyle(
                  fontSize: FontSizes.footer2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 10.h),
              ..._updates.map((update) => _EmergencyUpdateCard(update: update)),
            ],
          ),
        ),
      ),
    );
  }
}

class DistressCallPage extends StatefulWidget {
  const DistressCallPage({super.key});

  @override
  State<DistressCallPage> createState() => _DistressCallPageState();
}

class _DistressCallPageState extends State<DistressCallPage> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  String? _locationError;
  String? _detailsError;
  _DistressDraft? _draft;

  @override
  void dispose() {
    _locationController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  String? _validateRequired(String value, String fieldName) {
    if (value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  void _submit() {
    final locationError = _validateRequired(
      _locationController.text,
      'Location',
    );
    final detailsError = _validateRequired(
      _detailsController.text,
      'Emergency details',
    );

    setState(() {
      _locationError = locationError;
      _detailsError = detailsError;
    });

    if (locationError != null || detailsError != null) {
      return;
    }

    setState(() {
      _draft = _DistressDraft(
        location: _locationController.text.trim(),
        details: _detailsController.text.trim(),
        status: 'Saved locally',
      );
    });
  }

  void _sendToDispatch() {
    final draft = _draft;
    if (draft == null) {
      return;
    }

    setState(() {
      _draft = draft.copyWith(status: 'Queued for dispatch');
    });
  }

  void _clearUpdate() {
    setState(() {
      _draft = null;
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
          'Distress Call',
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
              Text(
                'Share updated emergency details.',
                style: TextStyle(
                  fontSize: FontSizes.body2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'This is local form state for now, but it gives the emergency lane a real way to capture location and situation changes before backend escalation exists.',
                style: TextStyle(
                  fontSize: FontSizes.footer2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryBlue11,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),
              CarenetTextField(
                label: 'Location',
                hintText: 'Example: 14 Palm Street, Lagos',
                controller: _locationController,
                onChanged: (_) => setState(() => _locationError = null),
                validationState:
                    _locationError == null
                        ? CarenetTextFieldValidationState.none
                        : CarenetTextFieldValidationState.invalid,
                errorText: _locationError,
              ),
              SizedBox(height: 20.h),
              CarenetTextField(
                label: 'Emergency details',
                hintText: 'Describe what responders should know',
                controller: _detailsController,
                onChanged: (_) => setState(() => _detailsError = null),
                validationState:
                    _detailsError == null
                        ? CarenetTextFieldValidationState.none
                        : CarenetTextFieldValidationState.invalid,
                errorText: _detailsError,
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: CarenetButton(
                  label: 'Save distress update',
                  onPressed: _submit,
                ),
              ),
              SizedBox(height: 24.h),
              if (_draft != null)
                Container(
                  width: double.infinity,
                  padding: REdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    color: AppColors.blue02,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.white04),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latest distress update',
                        style: TextStyle(
                          fontSize: FontSizes.footer3,
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w700,
                          color: AppColors.kBlack,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _draft!.location,
                        style: TextStyle(
                          fontSize: FontSizes.footer2,
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue5,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _draft!.status,
                        style: TextStyle(
                          fontSize: FontSizes.footer4,
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue5,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _draft!.details,
                        style: TextStyle(
                          fontSize: FontSizes.footer3,
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primaryBlue11,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: CarenetButton(
                              label: 'Send to dispatch',
                              onPressed: _sendToDispatch,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: CarenetButton(
                              label: 'Clear update',
                              type: CarenetButtonType.outline,
                              onPressed: _clearUpdate,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyUpdateCard extends StatelessWidget {
  const _EmergencyUpdateCard({required this.update});

  final _EmergencyUpdate update;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: REdgeInsets.only(bottom: 12.h),
      padding: REdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            update.title,
            style: TextStyle(
              fontSize: FontSizes.footer2,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            update.detail,
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyUpdate {
  const _EmergencyUpdate({required this.title, required this.detail});

  final String title;
  final String detail;
}

class _DistressDraft {
  const _DistressDraft({
    required this.location,
    required this.details,
    required this.status,
  });

  final String location;
  final String details;
  final String status;

  _DistressDraft copyWith({String? location, String? details, String? status}) {
    return _DistressDraft(
      location: location ?? this.location,
      details: details ?? this.details,
      status: status ?? this.status,
    );
  }
}
