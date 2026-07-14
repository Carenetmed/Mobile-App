import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppointmentsShellPage extends StatelessWidget {
  const AppointmentsShellPage({super.key});

  static const List<_AppointmentItem> _upcoming = <_AppointmentItem>[
    _AppointmentItem(
      title: 'Private consult with Dr. Lagbaja',
      date: 'Tue, 28 May',
      time: '10:30 AM',
      mode: 'Video visit',
      status: 'Booked',
    ),
  ];

  static const List<_AppointmentItem> _history = <_AppointmentItem>[
    _AppointmentItem(
      title: 'Nutrition follow-up',
      date: 'Mon, 13 May',
      time: '4:00 PM',
      mode: 'In person',
      status: 'Completed',
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
          'Appointments',
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
                'Keep your care schedule in one place.',
                style: TextStyle(
                  fontSize: FontSizes.body2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'This is local/mock scheduling state for now, but it gives appointment notifications a real home and a clean handoff into booking.',
                style: TextStyle(
                  fontSize: FontSizes.footer2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryBlue11,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: CarenetButton(
                  label: 'Book appointment',
                  onPressed: () {
                    Navigator.pushNamed(context, RouteName.bookAppointment);
                  },
                ),
              ),
              SizedBox(height: 24.h),
              _SectionLabel(label: 'Upcoming'),
              SizedBox(height: 10.h),
              ..._upcoming.map((item) => _AppointmentCard(item: item)),
              SizedBox(height: 24.h),
              _SectionLabel(label: 'Recent'),
              SizedBox(height: 10.h),
              ..._history.map((item) => _AppointmentCard(item: item)),
            ],
          ),
        ),
      ),
    );
  }
}

class BookAppointmentShellPage extends StatefulWidget {
  const BookAppointmentShellPage({super.key});

  @override
  State<BookAppointmentShellPage> createState() =>
      _BookAppointmentShellPageState();
}

class _BookAppointmentShellPageState extends State<BookAppointmentShellPage> {
  static const List<String> _visitTypes = <String>['Video visit', 'In person'];

  final TextEditingController _clinicianController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  String? _selectedVisitType;
  String? _clinicianError;
  String? _dateError;
  String? _reasonError;
  String? _visitTypeError;
  _BookedAppointmentDraft? _bookedDraft;

  @override
  void dispose() {
    _clinicianController.dispose();
    _dateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  String? _validateRequired(String value, String fieldName) {
    if (value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  void _submit() {
    final clinicianError = _validateRequired(
      _clinicianController.text,
      'Clinician',
    );
    final dateError = _validateRequired(_dateController.text, 'Preferred date');
    final reasonError = _validateRequired(
      _reasonController.text,
      'Reason for visit',
    );
    final visitTypeError =
        _selectedVisitType == null ? 'Visit type is required' : null;

    setState(() {
      _clinicianError = clinicianError;
      _dateError = dateError;
      _reasonError = reasonError;
      _visitTypeError = visitTypeError;
    });

    if (clinicianError != null ||
        dateError != null ||
        reasonError != null ||
        visitTypeError != null) {
      return;
    }

    setState(() {
      _bookedDraft = _BookedAppointmentDraft(
        clinician: _clinicianController.text.trim(),
        preferredDate: _dateController.text.trim(),
        reason: _reasonController.text.trim(),
        visitType: _selectedVisitType!,
        status: 'Backend request not sent',
      );
    });
  }

  void _cancelDraft() {
    setState(() {
      _bookedDraft = null;
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
          'Book Appointment',
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
                'Booking starts here.',
                style: TextStyle(
                  fontSize: FontSizes.body2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Appointment request wiring is backend-gated. You can review details here, but nothing is submitted or confirmed until the real request flow is connected.',
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
                label: 'Clinician',
                hintText: 'Example: Dr. Lagbaja',
                controller: _clinicianController,
                onChanged: (_) => setState(() => _clinicianError = null),
                validationState:
                    _clinicianError == null
                        ? CarenetTextFieldValidationState.none
                        : CarenetTextFieldValidationState.invalid,
                errorText: _clinicianError,
              ),
              SizedBox(height: 20.h),
              Text(
                'Visit type',
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
                    _visitTypes.map((visitType) {
                      final isSelected = _selectedVisitType == visitType;
                      return ChoiceChip(
                        label: Text(visitType),
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
                            _selectedVisitType = visitType;
                            _visitTypeError = null;
                          });
                        },
                      );
                    }).toList(),
              ),
              if (_visitTypeError != null) ...[
                SizedBox(height: 8.h),
                Text(
                  _visitTypeError!,
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
                label: 'Preferred date',
                hintText: 'Example: Fri, 31 May',
                controller: _dateController,
                onChanged: (_) => setState(() => _dateError = null),
                validationState:
                    _dateError == null
                        ? CarenetTextFieldValidationState.none
                        : CarenetTextFieldValidationState.invalid,
                errorText: _dateError,
              ),
              SizedBox(height: 20.h),
              CarenetTextField(
                label: 'Reason for visit',
                hintText: 'Briefly describe what you need help with',
                controller: _reasonController,
                onChanged: (_) => setState(() => _reasonError = null),
                validationState:
                    _reasonError == null
                        ? CarenetTextFieldValidationState.none
                        : CarenetTextFieldValidationState.invalid,
                errorText: _reasonError,
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: CarenetButton(
                  label: 'Review request details',
                  onPressed: _submit,
                ),
              ),
              SizedBox(height: 24.h),
              if (_bookedDraft != null)
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
                        'Request details',
                        style: TextStyle(
                          fontSize: FontSizes.footer3,
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w700,
                          color: AppColors.kBlack,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _bookedDraft!.clinician,
                        style: TextStyle(
                          fontSize: FontSizes.footer2,
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue5,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _bookedDraft!.status,
                        style: TextStyle(
                          fontSize: FontSizes.footer4,
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue5,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '${_bookedDraft!.visitType} • ${_bookedDraft!.preferredDate}',
                        style: TextStyle(
                          fontSize: FontSizes.footer3,
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w500,
                          color: AppColors.kBlack,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _bookedDraft!.reason,
                        style: TextStyle(
                          fontSize: FontSizes.footer3,
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primaryBlue11,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'No appointment request has been sent yet. Choose a backend availability slot in the upcoming request flow before this can be submitted.',
                        style: TextStyle(
                          fontSize: FontSizes.footer4,
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryBlue11,
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: CarenetButton(
                          label: 'Clear details',
                          type: CarenetButtonType.outline,
                          onPressed: _cancelDraft,
                        ),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: FontSizes.footer2,
        fontFamily: AppFonts.montserrat,
        fontWeight: FontWeight.w700,
        color: AppColors.kBlack,
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.item});

  final _AppointmentItem item;

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: FontSizes.footer2,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kBlack,
                  ),
                ),
              ),
              Container(
                padding: REdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue7,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    fontSize: FontSizes.footer4,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '${item.date} • ${item.time}',
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            item.mode,
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentItem {
  const _AppointmentItem({
    required this.title,
    required this.date,
    required this.time,
    required this.mode,
    required this.status,
  });

  final String title;
  final String date;
  final String time;
  final String mode;
  final String status;
}

class _BookedAppointmentDraft {
  const _BookedAppointmentDraft({
    required this.clinician,
    required this.preferredDate,
    required this.reason,
    required this.visitType,
    required this.status,
  });

  final String clinician;
  final String preferredDate;
  final String reason;
  final String visitType;
  final String status;
}
