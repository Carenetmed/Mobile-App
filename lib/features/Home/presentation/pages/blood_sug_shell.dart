import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/readings_local_store.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BloodSugShellPage extends StatefulWidget {
  const BloodSugShellPage({super.key});

  @override
  State<BloodSugShellPage> createState() => _BloodSugShellPageState();
}

class _BloodSugShellPageState extends State<BloodSugShellPage> {
  static const List<String> _contexts = <String>[
    'Before meal',
    'After meal',
    'Bedtime',
  ];

  final TextEditingController _readingController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _selectedContext;
  String? _readingError;
  String? _contextError;
  BloodSugarEntry? _savedEntry;

  @override
  void dispose() {
    _readingController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String? _validateReading(String value) {
    if (value.trim().isEmpty) {
      return 'Blood sugar reading is required';
    }

    final reading = double.tryParse(value.trim());
    if (reading == null) {
      return 'Enter a numeric reading';
    }

    if (reading <= 0) {
      return 'Reading must be greater than zero';
    }

    return null;
  }

  bool get _canSave {
    return _validateReading(_readingController.text) == null &&
        _selectedContext != null;
  }

  String get _trendSummary {
    final history = ReadingsLocalStore.bloodSugarHistory.value;
    if (history.length < 2) {
      return 'Add one more reading to see a trend summary.';
    }

    final latest = double.tryParse(history.first.reading);
    final previous = double.tryParse(history[1].reading);
    if (latest == null || previous == null) {
      return 'Trend will appear once saved readings stay numeric.';
    }

    final delta = latest - previous;
    if (delta == 0) {
      return 'Stable versus your previous reading.';
    }

    final direction = delta > 0 ? 'up' : 'down';
    return '${delta.abs().toStringAsFixed(0)} mg/dL $direction from the previous reading.';
  }

  void _onSave() {
    final readingError = _validateReading(_readingController.text);
    final contextError =
        _selectedContext == null ? 'Choose when the reading was taken' : null;

    setState(() {
      _readingError = readingError;
      _contextError = contextError;
    });

    if (readingError != null || contextError != null) {
      return;
    }

    setState(() {
      _savedEntry = BloodSugarEntry(
        reading: _readingController.text.trim(),
        context: _selectedContext!,
        note: _noteController.text.trim(),
      );
      _readingError = null;
      _contextError = null;
    });
    ReadingsLocalStore.saveBloodSugar(
      reading: _savedEntry!.reading,
      context: _savedEntry!.context,
      note: _savedEntry!.note,
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
          'Blood Sugar',
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
                'Log your first blood sugar reading.',
                style: TextStyle(
                  fontSize: FontSizes.body2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'This is local app state for now, but it gives the readings lane a real capture surface. Device sync and backend history can plug into this flow later.',
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
                label: 'Blood sugar reading',
                hintText: 'Enter mg/dL',
                controller: _readingController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) {
                  setState(() {
                    _readingError = null;
                  });
                },
                validationState:
                    _readingError == null
                        ? CarenetTextFieldValidationState.none
                        : CarenetTextFieldValidationState.invalid,
                errorText: _readingError,
              ),
              SizedBox(height: 20.h),
              Text(
                'When was this reading taken?',
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
                    _contexts.map((contextLabel) {
                      final isSelected = _selectedContext == contextLabel;
                      return ChoiceChip(
                        label: Text(contextLabel),
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
                            _selectedContext = contextLabel;
                            _contextError = null;
                          });
                        },
                      );
                    }).toList(),
              ),
              if (_contextError != null) ...[
                SizedBox(height: 8.h),
                Text(
                  _contextError!,
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
                label: 'Optional note',
                hintText: 'Example: felt dizzy before lunch',
                controller: _noteController,
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: 24.h),
              CarenetButton(
                label: 'Save reading',
                onPressed: _canSave ? _onSave : _onSave,
              ),
              SizedBox(height: 24.h),
              ValueListenableBuilder<List<BloodSugarEntry>>(
                valueListenable: ReadingsLocalStore.bloodSugarHistory,
                builder: (context, history, child) {
                  return Container(
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
                          'Trend and history',
                          style: TextStyle(
                            fontSize: FontSizes.footer3,
                            fontFamily: AppFonts.montserrat,
                            fontWeight: FontWeight.w700,
                            color: AppColors.kBlack,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _trendSummary,
                          style: TextStyle(
                            fontSize: FontSizes.footer3,
                            fontFamily: AppFonts.montserrat,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primaryBlue11,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        if (history.isEmpty)
                          Text(
                            'No saved blood sugar readings yet.',
                            style: TextStyle(
                              fontSize: FontSizes.footer3,
                              fontFamily: AppFonts.montserrat,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primaryBlue11,
                            ),
                          )
                        else
                          Column(
                            children:
                                history.take(3).map((entry) {
                                  final index = history.indexOf(entry);
                                  return Padding(
                                    padding: REdgeInsets.only(bottom: 8.h),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${entry.reading} mg/dL',
                                                style: TextStyle(
                                                  fontSize: FontSizes.footer2,
                                                  fontFamily:
                                                      AppFonts.montserrat,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primaryBlue5,
                                                ),
                                              ),
                                              SizedBox(height: 2.h),
                                              Text(
                                                entry.context,
                                                style: TextStyle(
                                                  fontSize: FontSizes.footer3,
                                                  fontFamily:
                                                      AppFonts.montserrat,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors.kBlack,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          tooltip:
                                              'Delete ${entry.reading} mg/dL entry',
                                          onPressed: () {
                                            ReadingsLocalStore.deleteBloodSugarAt(
                                              index,
                                            );
                                            setState(() {
                                              _savedEntry =
                                                  ReadingsLocalStore
                                                      .bloodSugarEntry
                                                      .value;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                          ),
                                          color: AppColors.primaryBlue11,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 24.h),
              if (_savedEntry != null)
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
                        'Latest local entry',
                        style: TextStyle(
                          fontSize: FontSizes.footer3,
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w700,
                          color: AppColors.kBlack,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '${_savedEntry!.reading} mg/dL',
                        style: TextStyle(
                          fontSize: FontSizes.body2,
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue5,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Captured: ${_savedEntry!.context}',
                        style: TextStyle(
                          fontSize: FontSizes.footer3,
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w500,
                          color: AppColors.kBlack,
                        ),
                      ),
                      if (_savedEntry!.note.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Text(
                          'Note: ${_savedEntry!.note}',
                          style: TextStyle(
                            fontSize: FontSizes.footer3,
                            fontFamily: AppFonts.montserrat,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primaryBlue11,
                            height: 1.4,
                          ),
                        ),
                      ],
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
