import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/domain/entities/appointment_request_time_option.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/availability_window.dart';
import 'package:app_t/features/Home/domain/entities/public_professional.dart';
import 'package:app_t/features/Home/domain/services/appointment_request_time_options.dart';
import 'package:app_t/features/Home/presentation/state/search_local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class SpecialistDetailsShellPage extends StatefulWidget {
  const SpecialistDetailsShellPage({
    this.specialistId,
    this.profileRepository,
    this.schedulingRepository,
    this.now,
    super.key,
  });

  final String? specialistId;
  final ProfileRepository? profileRepository;
  final SchedulingRepository? schedulingRepository;
  final DateTime? now;

  @override
  State<SpecialistDetailsShellPage> createState() =>
      _SpecialistDetailsShellPageState();
}

class _SpecialistDetailsShellPageState
    extends State<SpecialistDetailsShellPage> {
  PublicProfessional? _backendProfessional;
  bool _isLoadingProfessional = false;
  String? _professionalMessage;

  ProfileRepository get _profileRepository =>
      widget.profileRepository ?? sl<ProfileRepository>();

  SchedulingRepository get _schedulingRepository =>
      widget.schedulingRepository ?? sl<SchedulingRepository>();

  bool get _hasProfileRepository =>
      widget.profileRepository != null || sl.isRegistered<ProfileRepository>();

  bool get _hasSchedulingRepository =>
      widget.schedulingRepository != null ||
      sl.isRegistered<SchedulingRepository>();

  bool get _canUseBackend =>
      widget.specialistId != null &&
      _hasProfileRepository &&
      _hasSchedulingRepository;

  @override
  void initState() {
    super.initState();
    if (_canUseBackend) {
      _loadBackendProfessional();
    }
  }

  Future<void> _loadBackendProfessional() async {
    final specialistId = widget.specialistId;
    if (specialistId == null) {
      return;
    }

    setState(() {
      _isLoadingProfessional = true;
      _professionalMessage = 'Loading verified professional...';
    });

    try {
      final professionals = await _profileRepository.publicProfessionals();
      if (!mounted) {
        return;
      }
      final match = professionals.where((item) => item.id == specialistId);
      setState(() {
        _backendProfessional = match.isEmpty ? null : match.first;
        _isLoadingProfessional = false;
        _professionalMessage =
            match.isEmpty ? 'Backend professional could not be found.' : null;
      });
    } on AuthFailure catch (failure) {
      if (!mounted) {
        return;
      }
      setState(() {
        _backendProfessional = null;
        _isLoadingProfessional = false;
        _professionalMessage = _safeProfileError(failure);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _backendProfessional = null;
        _isLoadingProfessional = false;
        _professionalMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localSpecialist = SearchLocalStore.specialistById(
      widget.specialistId,
    );

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          'Specialist Details',
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
        child:
            _canUseBackend
                ? _BackendSpecialistDetails(
                  professional: _backendProfessional,
                  isLoading: _isLoadingProfessional,
                  message: _professionalMessage,
                  schedulingRepository: _schedulingRepository,
                  now: widget.now ?? DateTime.now(),
                )
                : _LocalSpecialistDetails(specialist: localSpecialist),
      ),
    );
  }

  String _safeProfileError(AuthFailure failure) {
    return switch (failure.type) {
      AuthFailureType.missingConfiguration => 'Backend is not configured yet.',
      AuthFailureType.unauthorized => 'Please sign in again.',
      AuthFailureType.validation => 'Please check the details and try again.',
      AuthFailureType.server ||
      AuthFailureType.network => 'Service is unavailable. Please try again.',
      AuthFailureType.invalidCredentials ||
      AuthFailureType.unknown => 'Something went wrong. Please try again.',
    };
  }
}

class _BackendSpecialistDetails extends StatelessWidget {
  const _BackendSpecialistDetails({
    required this.professional,
    required this.isLoading,
    required this.message,
    required this.schedulingRepository,
    required this.now,
  });

  final PublicProfessional? professional;
  final bool isLoading;
  final String? message;
  final SchedulingRepository schedulingRepository;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    if (isLoading || message != null) {
      return ListView(
        padding: REdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
        children: [
          _StateCard(message: message ?? 'Loading verified professional...'),
        ],
      );
    }

    final item = professional;
    if (item == null) {
      return ListView(
        padding: REdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
        children: const [
          _StateCard(message: 'Backend professional could not be found.'),
        ],
      );
    }

    return ListView(
      padding: REdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
      children: [
        _BackendHeader(professional: item),
        SizedBox(height: 18.h),
        _BackendInfoSection(professional: item),
        SizedBox(height: 20.h),
        _BackendAvailabilitySection(
          professionalProfileId: item.id,
          schedulingRepository: schedulingRepository,
          now: now,
        ),
      ],
    );
  }
}

class _BackendHeader extends StatelessWidget {
  const _BackendHeader({required this.professional});

  final PublicProfessional professional;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 76.r,
          height: 76.r,
          decoration: BoxDecoration(
            color: AppColors.blue02,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.verified_user_outlined,
            size: 32.r,
            color: AppColors.primaryBlue5,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                professional.displayName,
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: FontSizes.body3,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 4.h),
              Text(_roleLabel(professional)),
              SizedBox(height: 6.h),
              Text(professional.verified ? 'Verified' : 'Not verified'),
            ],
          ),
        ),
      ],
    );
  }

  String _roleLabel(PublicProfessional professional) {
    final specialty = professional.specialty?.trim();
    if (specialty == null || specialty.isEmpty) {
      return professional.category;
    }
    return '${professional.category} - $specialty';
  }
}

class _BackendInfoSection extends StatelessWidget {
  const _BackendInfoSection({required this.professional});

  final PublicProfessional professional;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(label: 'Specialization', value: professional.category),
        if (professional.specialty != null &&
            professional.specialty!.trim().isNotEmpty)
          _DetailRow(label: 'Specialty', value: professional.specialty!.trim()),
        _DetailRow(
          label: 'Profile summary',
          value:
              professional.bio?.trim().isNotEmpty == true
                  ? professional.bio!.trim()
                  : 'No public profile summary yet.',
        ),
        const _DetailRow(
          label: 'Meeting Location',
          value: 'Backend scheduling',
        ),
      ],
    );
  }
}

class _BackendAvailabilitySection extends StatefulWidget {
  const _BackendAvailabilitySection({
    required this.professionalProfileId,
    required this.schedulingRepository,
    required this.now,
  });

  final String professionalProfileId;
  final SchedulingRepository schedulingRepository;
  final DateTime now;

  @override
  State<_BackendAvailabilitySection> createState() =>
      _BackendAvailabilitySectionState();
}

class _BackendAvailabilitySectionState
    extends State<_BackendAvailabilitySection> {
  static const AppointmentRequestTimeOptions _timeOptions =
      AppointmentRequestTimeOptions();

  late final Future<List<AvailabilityWindow>> _availabilityFuture;
  AppointmentRequestTimeOption? _selectedOption;
  bool _isRequestingAppointment = false;
  String? _requestMessage;

  @override
  void initState() {
    super.initState();
    _availabilityFuture = widget.schedulingRepository.publicAvailability(
      professionalProfileId: widget.professionalProfileId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AvailabilityWindow>>(
      future: _availabilityFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active) {
          return const _StateCard(message: 'Loading public availability...');
        }

        if (snapshot.hasError) {
          return _StateCard(message: _safeAvailabilityError(snapshot.error));
        }

        final windows = snapshot.data ?? const <AvailabilityWindow>[];
        if (windows.isEmpty) {
          return const _StateCard(
            message: 'No public availability is available yet.',
          );
        }

        final requestOptions = _timeOptions.generate(
          windows: windows,
          now: widget.now,
        );
        _selectedOption ??=
            requestOptions.isEmpty ? null : requestOptions.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Public availability',
              style: TextStyle(
                fontSize: FontSizes.footer3,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w700,
                color: AppColors.kBlack,
              ),
            ),
            SizedBox(height: 8.h),
            ...windows.map(
              (window) => Padding(
                padding: REdgeInsets.only(bottom: 6.h),
                child: _AvailabilityWindowRow(window: window),
              ),
            ),
            SizedBox(height: 12.h),
            if (requestOptions.isEmpty)
              const _StateCard(
                message: 'No requestable times in the next seven days.',
              )
            else ...[
              Text(
                'Request appointment',
                style: TextStyle(
                  fontSize: FontSizes.footer3,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children:
                    requestOptions
                        .map(
                          (option) => ChoiceChip(
                            label: Text(_optionLabel(option)),
                            selected: option == _selectedOption,
                            onSelected:
                                _isRequestingAppointment
                                    ? null
                                    : (_) => setState(() {
                                      _selectedOption = option;
                                      _requestMessage = null;
                                    }),
                          ),
                        )
                        .toList(),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      _isRequestingAppointment || _selectedOption == null
                          ? null
                          : _requestAppointment,
                  child: Text(
                    _isRequestingAppointment
                        ? 'Sending request...'
                        : 'Request selected time',
                  ),
                ),
              ),
            ],
            if (_requestMessage != null) ...[
              SizedBox(height: 8.h),
              _StateCard(message: _requestMessage!),
            ],
          ],
        );
      },
    );
  }

  Future<void> _requestAppointment() async {
    final option = _selectedOption;
    if (option == null) {
      return;
    }

    setState(() {
      _isRequestingAppointment = true;
      _requestMessage = null;
    });

    try {
      final appointment = await widget.schedulingRepository.requestAppointment(
        professionalProfileId: widget.professionalProfileId,
        requestedStartAt: option.requestedStartAt,
        durationMinutes: option.durationMinutes,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isRequestingAppointment = false;
        _requestMessage =
            'Request sent. Backend status: ${appointment.status.wireName}.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isRequestingAppointment = false;
        _requestMessage = _safeAppointmentRequestError(error);
      });
    }
  }

  static String _optionLabel(AppointmentRequestTimeOption option) {
    final date = option.requestedStartAt;
    final dateLabel =
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}';
    return '$dateLabel ${option.timeRangeLabel} '
        '(${option.durationMinutes} min)';
  }

  static String _safeAvailabilityError(Object? error) {
    if (error is AuthFailure) {
      return switch (error.type) {
        AuthFailureType.missingConfiguration =>
          'Backend is not configured yet.',
        AuthFailureType.unauthorized => 'Please sign in again.',
        AuthFailureType.validation =>
          'Please choose an available time and try again.',
        AuthFailureType.server ||
        AuthFailureType.network => 'Service is unavailable. Please try again.',
        AuthFailureType.invalidCredentials ||
        AuthFailureType.unknown => 'Something went wrong. Please try again.',
      };
    }
    return 'Something went wrong. Please try again.';
  }

  static String _safeAppointmentRequestError(Object? error) {
    if (error is AuthFailure) {
      return switch (error.type) {
        AuthFailureType.missingConfiguration =>
          'Backend is not configured yet.',
        AuthFailureType.unauthorized => 'Please sign in again.',
        AuthFailureType.validation =>
          'Please choose an available time and try again.',
        AuthFailureType.server ||
        AuthFailureType.network => 'Service is unavailable. Please try again.',
        AuthFailureType.invalidCredentials ||
        AuthFailureType.unknown => 'Something went wrong. Please try again.',
      };
    }
    return 'Something went wrong. Please try again.';
  }
}

class _LocalSpecialistDetails extends StatefulWidget {
  const _LocalSpecialistDetails({required this.specialist});

  final SearchSpecialist specialist;

  @override
  State<_LocalSpecialistDetails> createState() =>
      _LocalSpecialistDetailsState();
}

class _LocalSpecialistDetailsState extends State<_LocalSpecialistDetails> {
  int _selectedDay = 0;
  int _selectedTime = 0;

  static const List<String> _times = <String>[
    '10:00am',
    '11:00am',
    '11:30am',
    '12:00pm',
    '12:30pm',
    '1:00pm',
    '1:30pm',
  ];

  List<String> get _days {
    final today = DateUtils.dateOnly(DateTime.now());
    return List<String>.generate(6, (index) {
      final date = today.add(Duration(days: index));
      if (index == 0) {
        return 'TODAY ${date.day}';
      }
      return DateFormat('EEE d').format(date).toUpperCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _days;

    return ListView(
      padding: REdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
      children: [
        _LocalHeader(specialist: widget.specialist),
        SizedBox(height: 18.h),
        const _LocalInfoSection(),
        SizedBox(height: 20.h),
        _ChoiceWrap(
          title: 'CHOOSE DAY',
          values: days,
          selectedIndex: _selectedDay,
          onSelected: (index) => setState(() => _selectedDay = index),
        ),
        SizedBox(height: 18.h),
        _ChoiceWrap(
          title: 'CHOOSE TIME',
          values: _times,
          selectedIndex: _selectedTime,
          onSelected: (index) => setState(() => _selectedTime = index),
        ),
        SizedBox(height: 20.h),
        Container(
          padding: REdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.blue02,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            'Selected slot: ${days[_selectedDay]} at ${_times[_selectedTime]}. This is a local selection only; booking is completed in the existing appointment form.',
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontSize: FontSizes.footer4,
              color: AppColors.primaryBlue11,
              height: 1.4,
            ),
          ),
        ),
        SizedBox(height: 14.h),
        FilledButton(
          onPressed: () {
            Navigator.pushNamed(context, RouteName.bookAppointment);
          },
          child: const Text('Book appointment'),
        ),
      ],
    );
  }
}

class _LocalHeader extends StatelessWidget {
  const _LocalHeader({required this.specialist});

  final SearchSpecialist specialist;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Image.asset(
            specialist.imageAsset,
            width: 76.r,
            height: 76.r,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) => Container(
                  width: 76.r,
                  height: 76.r,
                  color: AppColors.blue02,
                  child: Icon(Icons.person_outline, size: 32.r),
                ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                specialist.name,
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: FontSizes.body3,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 4.h),
              Text(specialist.role),
              SizedBox(height: 6.h),
              Text('${specialist.rating} - See reviews'),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocalInfoSection extends StatelessWidget {
  const _LocalInfoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _DetailRow(label: 'Available Time', value: 'Mon - Wed, 10.00 -14.00'),
        _DetailRow(label: 'Specialization', value: 'Medical doctor'),
        _DetailRow(label: 'Meeting Location', value: 'Zoom'),
        _DetailRow(label: 'Years experience', value: '10+'),
        _DetailRow(label: 'Phone number', value: '+234 90 1233 4567'),
        _DetailRow(label: 'Review', value: '120'),
      ],
    );
  }
}

class _AvailabilityWindowRow extends StatelessWidget {
  const _AvailabilityWindowRow({required this.window});

  final AvailabilityWindow window;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Text(
        'Day ${window.weekday}: ${_timeLabel(window.startMinute)} - ${_timeLabel(window.endMinute)} (${window.timezone})',
        style: TextStyle(
          fontSize: FontSizes.footer4,
          fontFamily: AppFonts.montserrat,
          fontWeight: FontWeight.w600,
          color: AppColors.kBlack,
          height: 1.35,
        ),
      ),
    );
  }

  String _timeLabel(int minuteOfDay) {
    final hours = minuteOfDay ~/ 60;
    final minutes = minuteOfDay % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.message});

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
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBlue11,
          height: 1.35,
        ),
      ),
    );
  }
}

class _ChoiceWrap extends StatelessWidget {
  const _ChoiceWrap({
    required this.title,
    required this.values,
    required this.selectedIndex,
    required this.onSelected,
  });

  final String title;
  final List<String> values;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: AppFonts.montserrat,
            fontSize: FontSizes.footer4,
            fontWeight: FontWeight.w700,
            color: AppColors.kBlack,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children:
              values.asMap().entries.map((entry) {
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: entry.key == selectedIndex,
                  selectedColor: AppColors.primaryBlue5,
                  labelStyle: TextStyle(
                    color:
                        entry.key == selectedIndex
                            ? AppColors.kWhite
                            : AppColors.kBlack,
                  ),
                  onSelected: (_) => onSelected(entry.key),
                );
              }).toList(),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130.w,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: FontSizes.footer4,
                color: AppColors.primaryBlue11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: FontSizes.footer4,
                fontWeight: FontWeight.w600,
                color: AppColors.kBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
