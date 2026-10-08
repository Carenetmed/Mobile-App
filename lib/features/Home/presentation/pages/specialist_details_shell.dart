import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/data/storage/booking_intent_store.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/public_professional.dart';
import 'package:app_t/features/Home/domain/entities/requestable_times.dart';
import 'package:app_t/features/Home/domain/services/professional_time_formatter.dart';
import 'package:app_t/features/Home/domain/services/money_formatter.dart';
import 'package:app_t/features/Home/presentation/state/professional_booking_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpecialistDetailsShellPage extends StatefulWidget {
  const SpecialistDetailsShellPage({
    this.specialistId,
    this.profileRepository,
    this.schedulingRepository,
    this.bookingIntentStore,
    this.sessionStore,
    this.onboardingRepository,
    this.controller,
    super.key,
  });

  final String? specialistId;
  final ProfileRepository? profileRepository;
  final SchedulingRepository? schedulingRepository;
  final BookingIntentStore? bookingIntentStore;
  final SessionStore? sessionStore;
  final OnboardingRepository? onboardingRepository;
  final ProfessionalBookingController? controller;

  @override
  State<SpecialistDetailsShellPage> createState() =>
      _SpecialistDetailsShellPageState();
}

class _SpecialistDetailsShellPageState
    extends State<SpecialistDetailsShellPage> {
  ProfessionalBookingController? _controller;
  bool _ownsController = false;

  bool get _hasValidId {
    final id = widget.specialistId?.trim();
    return id != null && id.isNotEmpty && id != 'me';
  }

  @override
  void initState() {
    super.initState();
    if (!_hasValidId) {
      return;
    }
    _controller =
        widget.controller ??
        ProfessionalBookingController(
          professionalProfileId: widget.specialistId!.trim(),
          profileRepository:
              widget.profileRepository ?? sl<ProfileRepository>(),
          schedulingRepository:
              widget.schedulingRepository ?? sl<SchedulingRepository>(),
          bookingIntentStore:
              widget.bookingIntentStore ?? sl<BookingIntentStore>(),
          sessionStore: widget.sessionStore ?? sl<SessionStore>(),
          onboardingRepository:
              widget.onboardingRepository ?? sl<OnboardingRepository>(),
        );
    _ownsController = widget.controller == null;
    _controller!.initialize();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FBFA),
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF102A2A)),
        ),
        title: Text(
          'Professional profile',
          style: TextStyle(
            fontFamily: AppFonts.montserrat,
            fontSize: FontSizes.footer2,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF102A2A),
          ),
        ),
        actions: [
          if (controller != null)
            IconButton(
              tooltip: 'Refresh',
              onPressed:
                  controller.isRefreshing ||
                          controller.isPreparingBooking ||
                          controller.isSubmitting
                      ? null
                      : controller.refresh,
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF155E63)),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body:
          controller == null
              ? _UnavailableProfile(onFindCare: _openFindCare)
              : SafeArea(
                top: false,
                child: AnimatedBuilder(
                  animation: controller,
                  builder:
                      (context, _) => RefreshIndicator(
                        onRefresh: controller.refresh,
                        child: _buildContent(controller),
                      ),
                ),
              ),
    );
  }

  Widget _buildContent(ProfessionalBookingController controller) {
    if (controller.isLoadingProfile && controller.professional == null) {
      return const _ScrollableState(
        icon: Icons.person_search_outlined,
        title: 'Loading professional',
        message: 'Retrieving the verified public profile.',
        loading: true,
      );
    }
    if (controller.profileNotFound) {
      return _UnavailableProfile(onFindCare: _openFindCare);
    }
    if (controller.professional == null) {
      return _ScrollableState(
        icon: Icons.cloud_off_outlined,
        title: 'Profile unavailable',
        message:
            controller.profileError ??
            'Could not load this professional. Please try again.',
        actionLabel: 'Retry',
        onAction: controller.loadProfile,
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: REdgeInsets.fromLTRB(18, 10, 18, 32),
      children: [
        _ProfileHeader(professional: controller.professional!),
        if (controller.profileError != null) ...[
          SizedBox(height: 12.h),
          _InlineNotice(
            icon: Icons.info_outline_rounded,
            message: controller.profileError!,
            actionLabel: 'Retry',
            onAction: () => controller.loadProfile(refresh: true),
          ),
        ],
        SizedBox(height: 18.h),
        _ProfileDetails(professional: controller.professional!),
        SizedBox(height: 18.h),
        _ConsultationPriceSection(professional: controller.professional!),
        SizedBox(height: 24.h),
        if (controller.professional!.bookable &&
            controller.professional!.consultationPrice?.isValidNgn == true)
          _RequestableTimesSection(
            controller: controller,
            onRequest: () => _requestAppointment(controller),
            onCancelIntent: controller.cancelIntent,
          )
        else
          const _InlineNotice(
            icon: Icons.event_busy_outlined,
            message:
                'This professional is not accepting paid appointment '
                'requests until a consultation price is published.',
          ),
      ],
    );
  }

  Future<void> _requestAppointment(
    ProfessionalBookingController controller,
  ) async {
    if (controller.isPreparingBooking || controller.isSubmitting) {
      return;
    }
    final gate = await controller.prepareBooking();
    if (!mounted) {
      return;
    }
    switch (gate) {
      case BookingGateOutcome.authenticationRequired:
        Navigator.of(context).pushNamed(RouteName.signInEmail);
        return;
      case BookingGateOutcome.onboardingRequired:
        Navigator.of(context).pushNamed(RouteName.patientOnboardingSetup);
        return;
      case BookingGateOutcome.incompatibleRole:
      case BookingGateOutcome.unavailable:
      case BookingGateOutcome.failure:
        return;
      case BookingGateOutcome.ready:
        break;
    }

    final time = controller.selectedTime;
    final timezone = controller.requestableTimes?.timezone;
    if (time == null || timezone == null) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            scrollable: true,
            title: const Text('Request this appointment?'),
            content: _ConfirmationContent(
              time: time,
              timezone: timezone,
              mode: controller.selectedMode,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Not now'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Send request'),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    final outcome = await controller.submit();
    if (!mounted) {
      return;
    }
    switch (outcome) {
      case BookingSubmissionOutcome.requested:
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder:
              (dialogContext) => AlertDialog(
                scrollable: true,
                icon: const Icon(
                  Icons.mark_email_read_outlined,
                  color: Color(0xFF18794E),
                ),
                title: const Text('Appointment request sent'),
                content: const Text(
                  'Your request is waiting for the professional to respond. '
                  'It is not confirmed yet.',
                ),
                actions: [
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('View appointments'),
                  ),
                ],
              ),
        );
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            RouteName.dashboard,
            (route) => false,
            arguments: 2,
          );
        }
        return;
      case BookingSubmissionOutcome.authenticationRequired:
        Navigator.of(context).pushNamed(RouteName.signInEmail);
        return;
      case BookingSubmissionOutcome.incompatibleRole:
      case BookingSubmissionOutcome.staleTime:
      case BookingSubmissionOutcome.professionalUnavailable:
      case BookingSubmissionOutcome.uncertain:
      case BookingSubmissionOutcome.failure:
        return;
    }
  }

  void _openFindCare() {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(RouteName.search, (route) => false);
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.professional});

  final PublicProfessional professional;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(16),
      decoration: _surfaceDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 68.r,
            height: 68.r,
            decoration: BoxDecoration(
              color: const Color(0xFFE5F4F1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.medical_services_outlined,
              size: 30.r,
              color: const Color(0xFF155E63),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  professional.displayName,
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF102A2A),
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  _professionalRole(professional),
                  style: TextStyle(
                    fontFamily: AppFonts.montserrat,
                    fontSize: 13.sp,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF526766),
                  ),
                ),
                if (professional.verified) ...[
                  SizedBox(height: 10.h),
                  const _VerifiedBadge(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails({required this.professional});

  final PublicProfessional professional;

  @override
  Widget build(BuildContext context) {
    final bio = professional.bio?.trim();
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(16),
      decoration: _surfaceDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.badge_outlined,
            label: 'Professional information',
          ),
          SizedBox(height: 14.h),
          _LabelValue(label: 'Category', value: professional.category),
          if (professional.specialty?.trim().isNotEmpty == true)
            _LabelValue(
              label: 'Specialty',
              value: professional.specialty!.trim(),
            ),
          if (bio != null && bio.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text('About', style: _labelStyle()),
            SizedBox(height: 5.h),
            Text(bio, style: _valueStyle().copyWith(height: 1.5)),
          ],
        ],
      ),
    );
  }
}

class _RequestableTimesSection extends StatefulWidget {
  const _RequestableTimesSection({
    required this.controller,
    required this.onRequest,
    required this.onCancelIntent,
  });

  final ProfessionalBookingController controller;
  final VoidCallback onRequest;
  final VoidCallback onCancelIntent;

  @override
  State<_RequestableTimesSection> createState() =>
      _RequestableTimesSectionState();
}

class _RequestableTimesSectionState extends State<_RequestableTimesSection> {
  RequestableTimes? _groupedResponse;
  String? _groupedTimezone;
  List<_RequestableDay> _days = const <_RequestableDay>[];
  String? _selectedDay;

  @override
  void initState() {
    super.initState();
    _syncDays();
  }

  @override
  void didUpdateWidget(covariant _RequestableTimesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncDays();
  }

  void _syncDays() {
    final response = widget.controller.requestableTimes;
    final timezone = response?.timezone?.trim();
    if (identical(response, _groupedResponse) && timezone == _groupedTimezone) {
      return;
    }
    _groupedResponse = response;
    _groupedTimezone = timezone;

    if (response == null ||
        response.times.isEmpty ||
        timezone == null ||
        timezone.isEmpty) {
      _days = const <_RequestableDay>[];
      _selectedDay = null;
      return;
    }

    final formatter = ProfessionalTimeFormatter();
    final grouped = <String, List<RequestableTime>>{};
    for (final time in response.times) {
      try {
        final day =
            formatter
                .format(
                  utcStartAt: time.startAt,
                  professionalTimezone: timezone,
                )
                .professionalDate;
        grouped.putIfAbsent(day, () => <RequestableTime>[]).add(time);
      } catch (_) {
        // The controller rejects invalid timezone contracts. Ignore any
        // individually malformed time that cannot be presented safely.
      }
    }
    _days = <_RequestableDay>[
      for (final entry in grouped.entries)
        _RequestableDay(label: entry.key, times: entry.value),
    ];

    String? selectedDay;
    final selectedTime = widget.controller.selectedTime;
    if (selectedTime != null) {
      try {
        selectedDay =
            formatter
                .format(
                  utcStartAt: selectedTime.startAt,
                  professionalTimezone: timezone,
                )
                .professionalDate;
      } catch (_) {
        selectedDay = null;
      }
    }
    final previousStillExists = _days.any((day) => day.label == _selectedDay);
    _selectedDay =
        selectedDay ??
        (previousStillExists ? _selectedDay : null) ??
        (_days.isEmpty ? null : _days.first.label);
  }

  _RequestableDay? get _visibleDay {
    for (final day in _days) {
      if (day.label == _selectedDay) {
        return day;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final response = controller.requestableTimes;
    final timezone = response?.timezone;
    final visibleDay = _visibleDay;
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(16),
      decoration: _surfaceDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.event_available_outlined,
            label: 'Available appointment times',
          ),
          SizedBox(height: 8.h),
          Text(
            'Times are generated and rechecked by CareNet. '
            'Appointments are 30 minutes.',
            style: _supportStyle(),
          ),
          SizedBox(height: 14.h),
          Text('Consultation type', style: _labelStyle()),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ConsultationMode>(
              segments: const <ButtonSegment<ConsultationMode>>[
                ButtonSegment<ConsultationMode>(
                  value: ConsultationMode.video,
                  icon: Icon(Icons.videocam_outlined),
                  label: Text('Video'),
                ),
                ButtonSegment<ConsultationMode>(
                  value: ConsultationMode.audio,
                  icon: Icon(Icons.call_outlined),
                  label: Text('Audio'),
                ),
              ],
              selected: <ConsultationMode>{controller.selectedMode},
              onSelectionChanged:
                  controller.isSubmitting || controller.isPreparingBooking
                      ? null
                      : (selection) => controller.selectMode(selection.first),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Video and audio use the same consultation fee.',
            style: _supportStyle(),
          ),
          SizedBox(height: 14.h),
          if (controller.isLoadingTimes && response == null)
            const _LoadingBlock(label: 'Loading appointment times...')
          else if (response == null)
            _InlineNotice(
              icon: Icons.cloud_off_outlined,
              message:
                  controller.timesError ??
                  'Could not load appointment times. Please try again.',
              actionLabel: 'Retry',
              onAction: controller.loadTimes,
            )
          else if (response.times.isEmpty)
            _InlineNotice(
              icon: Icons.event_busy_outlined,
              message: 'No appointment times are available in this date range.',
              actionLabel:
                  controller.canLoadLaterTimes ? 'Load later times' : 'Refresh',
              onAction:
                  controller.canLoadLaterTimes
                      ? controller.loadLaterTimes
                      : () => controller.loadTimes(refresh: true),
            )
          else if (timezone == null || timezone.trim().isEmpty)
            const _InlineNotice(
              icon: Icons.schedule_outlined,
              message: 'Appointment times cannot be displayed safely.',
            )
          else ...[
            Row(
              children: [
                Icon(
                  Icons.public_outlined,
                  size: 17.r,
                  color: const Color(0xFF155E63),
                ),
                SizedBox(width: 7.w),
                Expanded(
                  child: Text(
                    'Professional timezone: $timezone',
                    style: _supportStyle().copyWith(
                      color: const Color(0xFF155E63),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (visibleDay == null)
              const _InlineNotice(
                icon: Icons.schedule_outlined,
                message: 'Appointment times cannot be displayed safely.',
              )
            else ...[
              Text('Choose a date', style: _labelStyle()),
              SizedBox(height: 8.h),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _days.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final day = _days[index];
                    return ChoiceChip(
                      label: Text(day.label),
                      selected: day.label == _selectedDay,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      onSelected:
                          controller.isSubmitting ||
                                  controller.isPreparingBooking
                              ? null
                              : (_) => setState(() {
                                _selectedDay = day.label;
                              }),
                    );
                  },
                ),
              ),
              SizedBox(height: 12.h),
            ],
            ...?visibleDay?.times.map(
              (time) => Padding(
                padding: EdgeInsets.only(bottom: 9.h),
                child: _TimeOption(
                  time: time,
                  timezone: timezone,
                  selected:
                      controller.selectedTime?.startAt.toUtc() ==
                      time.startAt.toUtc(),
                  enabled:
                      !controller.isSubmitting &&
                      !controller.isPreparingBooking,
                  onTap: () => controller.selectTime(time),
                ),
              ),
            ),
            if (controller.canLoadLaterTimes || controller.isLoadingLaterTimes)
              Padding(
                padding: REdgeInsets.only(top: 4, bottom: 9),
                child: OutlinedButton.icon(
                  onPressed:
                      controller.isLoadingLaterTimes ||
                              controller.isPreparingBooking ||
                              controller.isSubmitting
                          ? null
                          : controller.loadLaterTimes,
                  icon:
                      controller.isLoadingLaterTimes
                          ? SizedBox.square(
                            dimension: 16.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                          : const Icon(Icons.expand_more),
                  label: Text(
                    controller.isLoadingLaterTimes
                        ? 'Loading later times...'
                        : 'Load later times',
                  ),
                ),
              ),
            if (controller.bookingIntent != null) ...[
              SizedBox(height: 4.h),
              _InlineNotice(
                icon: Icons.bookmark_added_outlined,
                message:
                    'Your selected time was saved. Review it before sending '
                    'the appointment request.',
                actionLabel: controller.isPreparingBooking ? null : 'Cancel',
                onAction:
                    controller.isPreparingBooking
                        ? null
                        : widget.onCancelIntent,
              ),
            ],
            if (controller.bookingError != null) ...[
              SizedBox(height: 10.h),
              _InlineNotice(
                icon: Icons.info_outline_rounded,
                message: controller.bookingError!,
              ),
            ],
            if (controller.timesError != null) ...[
              SizedBox(height: 10.h),
              _InlineNotice(
                icon: Icons.sync_problem_outlined,
                message: controller.timesError!,
                actionLabel: controller.isPreparingBooking ? null : 'Retry',
                onAction:
                    controller.isPreparingBooking
                        ? null
                        : () => controller.loadTimes(refresh: true),
              ),
            ],
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    controller.selectedTime == null ||
                            controller.isSubmitting ||
                            controller.isPreparingBooking
                        ? null
                        : widget.onRequest,
                icon:
                    controller.isSubmitting || controller.isPreparingBooking
                        ? SizedBox.square(
                          dimension: 16.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(Icons.send_outlined),
                label: Text(
                  controller.isPreparingBooking
                      ? 'Checking account...'
                      : controller.isSubmitting
                      ? 'Sending request...'
                      : controller.bookingReadinessFailed
                      ? 'Retry account check'
                      : 'Request selected time',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RequestableDay {
  const _RequestableDay({required this.label, required this.times});

  final String label;
  final List<RequestableTime> times;
}

class _ConsultationPriceSection extends StatelessWidget {
  const _ConsultationPriceSection({required this.professional});

  final PublicProfessional professional;

  @override
  Widget build(BuildContext context) {
    final price = professional.consultationPrice;
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(16),
      decoration: _surfaceDecoration(),
      child: Row(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: const Color(0xFFE5F4F1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: Color(0xFF155E63),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Consultation fee', style: _labelStyle()),
                SizedBox(height: 4.h),
                Text(
                  price?.isValidNgn == true
                      ? formatNgnMinor(price!.amountMinor)
                      : 'Not available for booking',
                  style: _valueStyle().copyWith(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  price?.isValidNgn == true
                      ? 'Shown before you send an appointment request.'
                      : 'No fee has been published.',
                  style: _supportStyle(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeOption extends StatelessWidget {
  const _TimeOption({
    required this.time,
    required this.timezone,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final RequestableTime time;
  final String timezone;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    ProfessionalTimeLabels labels;
    try {
      labels = ProfessionalTimeFormatter().format(
        utcStartAt: time.startAt,
        professionalTimezone: timezone,
      );
    } catch (_) {
      return const _InlineNotice(
        icon: Icons.schedule_outlined,
        message: 'This appointment time cannot be displayed safely.',
      );
    }
    final localTime = labels.patientLocalTime;
    final semanticLabel =
        '${labels.professionalDate}, ${labels.professionalTime} $timezone, '
        '30 minutes${localTime == null ? '' : ', $localTime'}';
    return Semantics(
      container: true,
      label: semanticLabel,
      inMutuallyExclusiveGroup: true,
      selected: selected,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      child: ExcludeSemantics(
        child: Material(
          color: selected ? const Color(0xFFE5F4F1) : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(8.r),
            child: Ink(
              padding: REdgeInsets.symmetric(horizontal: 13, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color:
                      selected
                          ? const Color(0xFF155E63)
                          : const Color(0xFFD8E9E6),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: const Color(0xFF155E63),
                  ),
                  SizedBox(width: 11.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          labels.professionalDate,
                          style: _valueStyle().copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          '${labels.professionalTime} $timezone - 30 min',
                          style: _supportStyle(),
                        ),
                        if (localTime != null) ...[
                          SizedBox(height: 3.h),
                          Text(
                            localTime,
                            style: _supportStyle().copyWith(
                              color: const Color(0xFF155E63),
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
        ),
      ),
    );
  }
}

class _ConfirmationContent extends StatelessWidget {
  const _ConfirmationContent({
    required this.time,
    required this.timezone,
    required this.mode,
  });

  final RequestableTime time;
  final String timezone;
  final ConsultationMode mode;

  @override
  Widget build(BuildContext context) {
    final labels = ProfessionalTimeFormatter().format(
      utcStartAt: time.startAt,
      professionalTimezone: timezone,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labels.professionalDate),
        const SizedBox(height: 4),
        Text('${labels.professionalTime} $timezone - 30 minutes'),
        const SizedBox(height: 4),
        Text(
          mode == ConsultationMode.video
              ? 'Video consultation'
              : 'Audio consultation',
        ),
        if (labels.patientLocalTime != null) ...[
          const SizedBox(height: 4),
          Text(labels.patientLocalTime!),
        ],
        const SizedBox(height: 14),
        const Text(
          'This sends a request. The appointment is not confirmed until '
          'the professional accepts it.',
        ),
      ],
    );
  }
}

class _UnavailableProfile extends StatelessWidget {
  const _UnavailableProfile({required this.onFindCare});

  final VoidCallback onFindCare;

  @override
  Widget build(BuildContext context) {
    return _ScrollableState(
      icon: Icons.person_off_outlined,
      title: 'Professional unavailable',
      message:
          'This professional profile could not be found or is no longer public.',
      actionLabel: 'Back to Find Care',
      onAction: onFindCare,
    );
  }
}

class _ScrollableState extends StatelessWidget {
  const _ScrollableState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.16),
        Center(
          child:
              loading
                  ? const CircularProgressIndicator()
                  : Icon(icon, size: 44, color: const Color(0xFF155E63)),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF526766)),
        ),
        if (onAction != null && actionLabel != null) ...[
          const SizedBox(height: 18),
          Center(
            child: FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ),
        ],
      ],
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4F2),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19.r, color: const Color(0xFF155E63)),
          SizedBox(width: 9.w),
          Expanded(child: Text(message, style: _supportStyle())),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 19.r,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10.w),
          Text(label, style: _supportStyle()),
        ],
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EF),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            size: 15.r,
            color: const Color(0xFF18794E),
          ),
          SizedBox(width: 5.w),
          Text(
            'Verified',
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF18794E),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: const Color(0xFF155E63)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.montserrat,
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF102A2A),
            ),
          ),
        ),
      ],
    );
  }
}

class _LabelValue extends StatelessWidget {
  const _LabelValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 92.w, child: Text(label, style: _labelStyle())),
          Expanded(child: Text(value, style: _valueStyle())),
        ],
      ),
    );
  }
}

BoxDecoration _surfaceDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: const Color(0xFFD8E9E6)),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF155E63).withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );
}

TextStyle _labelStyle() {
  return TextStyle(
    fontFamily: AppFonts.montserrat,
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF6B7E7D),
  );
}

TextStyle _valueStyle() {
  return TextStyle(
    fontFamily: AppFonts.montserrat,
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF102A2A),
  );
}

TextStyle _supportStyle() {
  return TextStyle(
    fontFamily: AppFonts.montserrat,
    fontSize: 12.sp,
    height: 1.4,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF526766),
  );
}

String _professionalRole(PublicProfessional professional) {
  final specialty = professional.specialty?.trim();
  return specialty == null || specialty.isEmpty
      ? professional.category
      : '${professional.category} · $specialty';
}
