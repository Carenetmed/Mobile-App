import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppointmentsShellPage extends StatefulWidget {
  const AppointmentsShellPage({
    super.key,
    this.schedulingRepository,
    this.sessionStore,
    this.now,
  });

  final SchedulingRepository? schedulingRepository;
  final SessionStore? sessionStore;
  final DateTime? now;

  @override
  State<AppointmentsShellPage> createState() => _AppointmentsShellPageState();
}

class _AppointmentsShellPageState extends State<AppointmentsShellPage> {
  late final Future<List<AppointmentSummary>> _appointmentsFuture;
  late final Future<AuthSessionModel?> _sessionFuture;

  SchedulingRepository get _schedulingRepository =>
      widget.schedulingRepository ?? sl<SchedulingRepository>();

  SessionStore get _sessionStore => widget.sessionStore ?? sl<SessionStore>();

  DateTime get _now => widget.now ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _schedulingRepository.ownAppointments();
    _sessionFuture = _sessionStore.read();
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
                'Backend appointment requests and statuses appear here when your session can read them.',
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
              FutureBuilder<List<AppointmentSummary>>(
                future: _appointmentsFuture,
                builder: (context, snapshot) {
                  final state = snapshot.connectionState;
                  if (state == ConnectionState.waiting ||
                      state == ConnectionState.active) {
                    return const _AppointmentStateCard(
                      message: 'Loading appointments...',
                    );
                  }

                  if (snapshot.hasError) {
                    return _AppointmentStateCard(
                      message: _safeAppointmentsError(snapshot.error),
                    );
                  }

                  final appointments =
                      snapshot.data ?? const <AppointmentSummary>[];
                  if (appointments.isEmpty) {
                    return const _AppointmentStateCard(
                      message: 'No backend appointments are available yet.',
                    );
                  }

                  final upcoming = appointments
                      .where(_isUpcomingAppointment)
                      .map(_AppointmentItem.fromSummary)
                      .toList(growable: false);
                  final recent = appointments
                      .where(
                        (appointment) => !_isUpcomingAppointment(appointment),
                      )
                      .map(_AppointmentItem.fromSummary)
                      .toList(growable: false);

                  return FutureBuilder<AuthSessionModel?>(
                    future: _sessionFuture,
                    builder: (context, sessionSnapshot) {
                      final role = sessionSnapshot.data?.user.role;
                      final roleKnown =
                          sessionSnapshot.connectionState ==
                              ConnectionState.done &&
                          role != null;
                      final isProfessional =
                          role?.toUpperCase() == 'PROFESSIONAL';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel(label: 'Upcoming'),
                          SizedBox(height: 10.h),
                          if (upcoming.isEmpty)
                            const _AppointmentStateCard(
                              message: 'No upcoming backend appointments.',
                            )
                          else
                            ...upcoming.map(
                              (item) => _AppointmentCard(
                                item: item,
                                schedulingRepository: _schedulingRepository,
                                allowCancellation: roleKnown && !isProfessional,
                                allowProfessionalLifecycle:
                                    roleKnown && isProfessional,
                                allowProfessionalCompletion: false,
                                now: _now,
                              ),
                            ),
                          SizedBox(height: 24.h),
                          _SectionLabel(label: 'Recent'),
                          SizedBox(height: 10.h),
                          if (recent.isEmpty)
                            const _AppointmentStateCard(
                              message: 'No recent backend appointments.',
                            )
                          else
                            ...recent.map(
                              (item) => _AppointmentCard(
                                item: item,
                                schedulingRepository: _schedulingRepository,
                                allowCancellation: false,
                                allowProfessionalLifecycle: false,
                                allowProfessionalCompletion:
                                    roleKnown && isProfessional,
                                now: _now,
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isUpcomingAppointment(AppointmentSummary appointment) {
    if (appointment.status == AppointmentStatus.cancelled ||
        appointment.status == AppointmentStatus.declined ||
        appointment.status == AppointmentStatus.completed) {
      return false;
    }
    return appointment.requestedStartAt.isAfter(_now) ||
        appointment.requestedStartAt.isAtSameMomentAs(_now);
  }

  static String _safeAppointmentsError(Object? error) {
    if (error is AuthFailure) {
      return switch (error.type) {
        AuthFailureType.missingConfiguration =>
          'Backend is not configured yet.',
        AuthFailureType.unauthorized => 'Please sign in again.',
        AuthFailureType.validation => 'Please check the details and try again.',
        AuthFailureType.server ||
        AuthFailureType.network => 'Service is unavailable. Please try again.',
        AuthFailureType.invalidCredentials ||
        AuthFailureType.unknown => 'Something went wrong. Please try again.',
      };
    }
    return 'Something went wrong. Please try again.';
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

class _AppointmentCard extends StatefulWidget {
  const _AppointmentCard({
    required this.item,
    required this.schedulingRepository,
    required this.allowCancellation,
    required this.allowProfessionalLifecycle,
    required this.allowProfessionalCompletion,
    required this.now,
  });

  final _AppointmentItem item;
  final SchedulingRepository schedulingRepository;
  final bool allowCancellation;
  final bool allowProfessionalLifecycle;
  final bool allowProfessionalCompletion;
  final DateTime now;

  @override
  State<_AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<_AppointmentCard> {
  late _AppointmentItem _item = widget.item;
  bool _isCancelling = false;
  bool _isAccepting = false;
  bool _isDeclining = false;
  bool _isCompleting = false;
  String? _actionMessage;

  @override
  void didUpdateWidget(covariant _AppointmentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _item = widget.item;
      _isCancelling = false;
      _isAccepting = false;
      _isDeclining = false;
      _isCompleting = false;
      _actionMessage = null;
    }
  }

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
                  _item.title,
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
                  _item.status,
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
            '${_item.date} - ${_item.time}',
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            _item.mode,
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
            ),
          ),
          if (widget.allowCancellation && _item.canCancel) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: CarenetButton(
                label:
                    _isCancelling
                        ? 'Cancelling appointment...'
                        : 'Cancel appointment',
                type: CarenetButtonType.outline,
                onPressed: _isCancelling ? null : _cancelAppointment,
              ),
            ),
          ],
          if (widget.allowProfessionalLifecycle && _item.canAcceptDecline) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: CarenetButton(
                    label: _isAccepting ? 'Accepting...' : 'Accept',
                    onPressed:
                        _isBusy ? null : () => _professionalDecision(true),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: CarenetButton(
                    label: _isDeclining ? 'Declining...' : 'Decline',
                    type: CarenetButtonType.outline,
                    onPressed:
                        _isBusy ? null : () => _professionalDecision(false),
                  ),
                ),
              ],
            ),
          ],
          if (widget.allowProfessionalCompletion &&
              _item.canComplete(widget.now)) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: CarenetButton(
                label: _isCompleting ? 'Completing appointment...' : 'Complete',
                onPressed: _isBusy ? null : _completeAppointment,
              ),
            ),
          ],
          if (_actionMessage != null) ...[
            SizedBox(height: 8.h),
            Text(
              _actionMessage!,
              style: TextStyle(
                fontSize: FontSizes.footer4,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue11,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool get _isBusy =>
      _isCancelling || _isAccepting || _isDeclining || _isCompleting;

  Future<void> _cancelAppointment() async {
    setState(() {
      _isCancelling = true;
      _actionMessage = null;
    });

    try {
      final cancelled = await widget.schedulingRepository.cancelAppointment(
        appointmentId: _item.id,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _item = _AppointmentItem.fromSummary(cancelled);
        _isCancelling = false;
        _actionMessage =
            'Cancellation updated. Backend status: ${cancelled.status.wireName}.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isCancelling = false;
        _actionMessage = _AppointmentsShellPageState._safeAppointmentsError(
          error,
        );
      });
    }
  }

  Future<void> _professionalDecision(bool accept) async {
    setState(() {
      _isAccepting = accept;
      _isDeclining = !accept;
      _actionMessage = null;
    });

    try {
      final updated =
          accept
              ? await widget.schedulingRepository.acceptAppointment(
                appointmentId: _item.id,
              )
              : await widget.schedulingRepository.declineAppointment(
                appointmentId: _item.id,
              );
      if (!mounted) {
        return;
      }
      setState(() {
        _item = _AppointmentItem.fromSummary(updated);
        _isAccepting = false;
        _isDeclining = false;
        _actionMessage =
            'Appointment updated. Backend status: ${updated.status.wireName}.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isAccepting = false;
        _isDeclining = false;
        _actionMessage = _AppointmentsShellPageState._safeAppointmentsError(
          error,
        );
      });
    }
  }

  Future<void> _completeAppointment() async {
    setState(() {
      _isCompleting = true;
      _actionMessage = null;
    });

    try {
      final completed = await widget.schedulingRepository.completeAppointment(
        appointmentId: _item.id,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _item = _AppointmentItem.fromSummary(completed);
        _isCompleting = false;
        _actionMessage =
            'Appointment completed. Backend status: ${completed.status.wireName}.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isCompleting = false;
        _actionMessage = _AppointmentsShellPageState._safeAppointmentsError(
          error,
        );
      });
    }
  }
}

class _AppointmentItem {
  const _AppointmentItem({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.mode,
    required this.status,
    required this.statusValue,
    required this.requestedStartAt,
    required this.durationMinutes,
  });

  factory _AppointmentItem.fromSummary(AppointmentSummary summary) {
    return _AppointmentItem(
      id: summary.id,
      title: 'Appointment with ${summary.professionalProfileId}',
      date: _dateLabel(summary.requestedStartAt),
      time: _timeLabel(summary.requestedStartAt),
      mode: 'Backend appointment request',
      status: summary.status.wireName,
      statusValue: summary.status,
      requestedStartAt: summary.requestedStartAt,
      durationMinutes: summary.durationMinutes,
    );
  }

  final String id;
  final String title;
  final String date;
  final String time;
  final String mode;
  final String status;
  final AppointmentStatus statusValue;
  final DateTime requestedStartAt;
  final int durationMinutes;

  bool get canCancel =>
      statusValue == AppointmentStatus.requested ||
      statusValue == AppointmentStatus.accepted;

  bool get canAcceptDecline => statusValue == AppointmentStatus.requested;

  bool canComplete(DateTime now) {
    if (statusValue != AppointmentStatus.accepted) {
      return false;
    }
    final scheduledEndAt = requestedStartAt.add(
      Duration(minutes: durationMinutes),
    );
    return scheduledEndAt.isBefore(now) || scheduledEndAt.isAtSameMomentAs(now);
  }

  static String _dateLabel(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static String _timeLabel(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

class _AppointmentStateCard extends StatelessWidget {
  const _AppointmentStateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: FontSizes.footer3,
          fontFamily: AppFonts.montserrat,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBlue11,
          height: 1.35,
        ),
      ),
    );
  }
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
