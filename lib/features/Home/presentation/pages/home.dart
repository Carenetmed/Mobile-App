import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/domain/entities/account_readiness.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/presentation/state/marketplace_home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.role,
    required this.onPrimaryAction,
    required this.onAppointments,
    required this.onReadinessAction,
    this.onAppointment,
    this.profileRepository,
    this.onboardingRepository,
    this.schedulingRepository,
    this.now,
  });

  final MarketplaceHomeRole role;
  final VoidCallback onPrimaryAction;
  final VoidCallback onAppointments;
  final ValueChanged<String>? onAppointment;
  final ValueChanged<AccountReadiness?> onReadinessAction;
  final ProfileRepository? profileRepository;
  final OnboardingRepository? onboardingRepository;
  final SchedulingRepository? schedulingRepository;
  final DateTime? now;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  MarketplaceHomeState? _state;
  bool _loading = true;
  bool _loadInProgress = false;

  ProfileRepository get _profileRepository =>
      widget.profileRepository ?? sl<ProfileRepository>();
  OnboardingRepository get _onboardingRepository =>
      widget.onboardingRepository ?? sl<OnboardingRepository>();
  SchedulingRepository get _schedulingRepository =>
      widget.schedulingRepository ?? sl<SchedulingRepository>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loadInProgress) return;
    _loadInProgress = true;
    setState(() => _loading = true);
    try {
      final state = await MarketplaceHomeCoordinator(
        role: widget.role,
        profileRepository: _profileRepository,
        onboardingRepository: _onboardingRepository,
        schedulingRepository: _schedulingRepository,
      ).load(previous: _state);
      if (!mounted) return;
      setState(() {
        _state = state;
        _loading = false;
      });
    } finally {
      _loadInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    if (_loading && state == null) {
      return const _HomeLoading();
    }

    if (state == null) {
      return _HomeFailure(onRetry: _load);
    }

    final now = widget.now ?? DateTime.now();
    final pending = state.pendingRequest();
    final upcoming = state.nextUpcoming(now);
    final isProfessional = widget.role == MarketplaceHomeRole.professional;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: REdgeInsets.fromLTRB(20.w, 18.h, 20.w, 32.h),
        children: [
          _HomeIntro(name: state.displayName, isProfessional: isProfessional),
          if (isProfessional) ...[
            SizedBox(height: 12.h),
            _ProfessionalStatus(
              status: state.professionalVerificationStatus,
              unavailable: state.failedSections.contains(
                HomeDataSection.readiness,
              ),
            ),
          ],
          SizedBox(height: 22.h),
          _PrimaryAction(
            isProfessional: isProfessional,
            onTap: widget.onPrimaryAction,
          ),
          if (state.failedSections.isNotEmpty) ...[
            SizedBox(height: 14.h),
            _PartialFailure(onRetry: _load),
          ],
          SizedBox(height: 22.h),
          _SectionHeading(
            title: 'Needs your attention',
            action: _actionLabel(state.requiredAction(now)),
          ),
          SizedBox(height: 10.h),
          _AttentionPanel(
            state: state,
            now: now,
            onReadiness: () => widget.onReadinessAction(state.readiness),
            onAppointments: widget.onAppointments,
            onPrimary: widget.onPrimaryAction,
          ),
          SizedBox(height: 24.h),
          const _SectionHeading(title: 'Appointments'),
          SizedBox(height: 10.h),
          if (state.failedSections.contains(HomeDataSection.appointments))
            _AppointmentsUnavailable(onRetry: _load)
          else if (pending == null && upcoming == null)
            _AppointmentEmpty(
              isProfessional: isProfessional,
              onPrimary: widget.onPrimaryAction,
            )
          else ...[
            if (pending != null)
              _AppointmentCard(
                eyebrow:
                    isProfessional ? 'REQUEST NEEDS REVIEW' : 'REQUEST PENDING',
                title:
                    isProfessional
                        ? 'Appointment request'
                        : 'Waiting for professional response',
                appointment: pending,
                icon: Icons.pending_actions_outlined,
                onTap: () => _openAppointment(pending.id),
              ),
            if (pending != null && upcoming != null) SizedBox(height: 10.h),
            if (upcoming != null)
              _AppointmentCard(
                eyebrow: 'UPCOMING',
                title: 'Accepted appointment',
                appointment: upcoming,
                icon: Icons.event_available_outlined,
                onTap: () => _openAppointment(upcoming.id),
              ),
          ],
        ],
      ),
    );
  }

  void _openAppointment(String appointmentId) {
    final callback = widget.onAppointment;
    if (callback != null) {
      callback(appointmentId);
      return;
    }
    widget.onAppointments();
  }
}

class _HomeIntro extends StatelessWidget {
  const _HomeIntro({required this.name, required this.isProfessional});

  final String name;
  final bool isProfessional;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting(),
          style: _text(
            FontSizes.footer1,
            FontWeight.w600,
            AppColors.primaryBlue6,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _text(FontSizes.heading3, FontWeight.w700, AppColors.blue01),
        ),
        SizedBox(height: 7.h),
        Text(
          isProfessional
              ? 'Keep your practice ready and consultations moving.'
              : 'Your next step in care, clearly in view.',
          style: _text(
            FontSizes.body3,
            FontWeight.w400,
            AppColors.white05,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _ProfessionalStatus extends StatelessWidget {
  const _ProfessionalStatus({required this.status, required this.unavailable});

  final String status;
  final bool unavailable;

  @override
  Widget build(BuildContext context) {
    final verified = status == 'VERIFIED';
    final label =
        unavailable && status == 'UNKNOWN'
            ? 'Verification status unavailable'
            : switch (status) {
              'VERIFIED' => 'Verified professional',
              'PENDING' || 'UNDER_REVIEW' => 'Verification under review',
              'NOT_SUBMITTED' => 'Verification not submitted',
              'REJECTED' => 'Verification needs attention',
              _ => 'Verification status unavailable',
            };
    return Row(
      children: [
        Icon(
          verified ? Icons.verified : Icons.shield_outlined,
          size: 18.r,
          color: verified ? AppColors.kGreen : AppColors.primaryBlue6,
        ),
        SizedBox(width: 7.w),
        Expanded(
          child: Text(
            label,
            style: _text(
              FontSizes.footer2,
              FontWeight.w600,
              verified ? AppColors.kGreen : AppColors.primaryBlue6,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.isProfessional, required this.onTap});

  final bool isProfessional;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryBlue6,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: REdgeInsets.all(18.r),
          child: Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: AppColors.kWhite.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  isProfessional
                      ? Icons.calendar_month_outlined
                      : Icons.manage_search_outlined,
                  color: AppColors.kWhite,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isProfessional ? 'Manage schedule' : 'Find care',
                      style: _text(
                        FontSizes.body3,
                        FontWeight.w700,
                        AppColors.kWhite,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      isProfessional
                          ? 'Set when patients can request care'
                          : 'Search verified healthcare professionals',
                      style: _text(
                        FontSizes.footer2,
                        FontWeight.w400,
                        AppColors.kWhite,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: AppColors.kWhite),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.action});

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: _text(FontSizes.body3, FontWeight.w700, AppColors.blue01),
          ),
        ),
        if (action != null)
          Text(
            action!,
            style: _text(
              FontSizes.footer2,
              FontWeight.w600,
              AppColors.primaryBlue6,
            ),
          ),
      ],
    );
  }
}

class _AttentionPanel extends StatelessWidget {
  const _AttentionPanel({
    required this.state,
    required this.now,
    required this.onReadiness,
    required this.onAppointments,
    required this.onPrimary,
  });

  final MarketplaceHomeState state;
  final DateTime now;
  final VoidCallback onReadiness;
  final VoidCallback onAppointments;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final action = state.requiredAction(now);
    final content = _attentionContent(action, state);
    final callback = switch (action) {
      HomeRequiredAction.completeProfile ||
      HomeRequiredAction.submitVerification ||
      HomeRequiredAction.reviewVerification => onReadiness,
      HomeRequiredAction.respondToRequest ||
      HomeRequiredAction.upcomingAppointment => onAppointments,
      HomeRequiredAction.configureAvailability ||
      HomeRequiredAction.findCare => onPrimary,
      _ => null,
    };

    return Container(
      padding: REdgeInsets.all(17.r),
      decoration: BoxDecoration(
        color: content.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: content.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(content.icon, color: content.foreground, size: 25.r),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: _text(
                    FontSizes.body3,
                    FontWeight.w700,
                    AppColors.blue01,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  content.body,
                  style: _text(
                    FontSizes.footer1,
                    FontWeight.w400,
                    AppColors.white05,
                    height: 1.4,
                  ),
                ),
                if (callback != null && content.button != null) ...[
                  SizedBox(height: 13.h),
                  TextButton.icon(
                    onPressed: callback,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: content.foreground,
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    iconAlignment: IconAlignment.end,
                    label: Text(content.button!),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.eyebrow,
    required this.title,
    required this.appointment,
    required this.icon,
    required this.onTap,
  });

  final String eyebrow;
  final String title;
  final AppointmentSummary appointment;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.kWhite,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: REdgeInsets.all(16.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.blue03),
          ),
          child: Row(
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: AppColors.blue02,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: AppColors.primaryBlue6),
              ),
              SizedBox(width: 13.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: _text(
                        FontSizes.footer3,
                        FontWeight.w700,
                        AppColors.primaryBlue6,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      title,
                      style: _text(
                        FontSizes.footer1,
                        FontWeight.w700,
                        AppColors.blue01,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      appointment.counterpart?.displayName.trim().isNotEmpty ==
                              true
                          ? appointment.counterpart!.displayName.trim()
                          : 'Appointment participant',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _text(
                        FontSizes.footer2,
                        FontWeight.w600,
                        AppColors.blue01,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _dateLabel(appointment.requestedStartAt),
                      style: _text(
                        FontSizes.footer2,
                        FontWeight.w400,
                        AppColors.white05,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.white04),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentEmpty extends StatelessWidget {
  const _AppointmentEmpty({
    required this.isProfessional,
    required this.onPrimary,
  });

  final bool isProfessional;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.blue03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.event_busy_outlined, color: AppColors.white04),
          SizedBox(height: 10.h),
          Text(
            isProfessional
                ? 'No appointment activity yet'
                : 'No appointments scheduled',
            style: _text(FontSizes.footer1, FontWeight.w700, AppColors.blue01),
          ),
          SizedBox(height: 5.h),
          Text(
            isProfessional
                ? 'Keep your availability current so eligible patients can request care.'
                : 'Find a verified professional when you are ready to request care.',
            style: _text(
              FontSizes.footer2,
              FontWeight.w400,
              AppColors.white05,
              height: 1.4,
            ),
          ),
          SizedBox(height: 10.h),
          TextButton(
            onPressed: onPrimary,
            child: Text(isProfessional ? 'Manage availability' : 'Find care'),
          ),
        ],
      ),
    );
  }
}

class _AppointmentsUnavailable extends StatelessWidget {
  const _AppointmentsUnavailable({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.blue03),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_busy_outlined, color: AppColors.white04),
          SizedBox(width: 12.w),
          const Expanded(
            child: Text('Appointments are unavailable right now.'),
          ),
          IconButton(
            tooltip: 'Retry appointments',
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: REdgeInsets.all(20.r),
      children: [
        const LinearProgressIndicator(),
        SizedBox(height: 20.h),
        Text(
          'Loading your care workspace...',
          style: _text(FontSizes.body3, FontWeight.w600, AppColors.blue01),
        ),
      ],
    );
  }
}

class _HomeFailure extends StatelessWidget {
  const _HomeFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: REdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 36),
            SizedBox(height: 12.h),
            const Text('Home could not be loaded safely.'),
            SizedBox(height: 12.h),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartialFailure extends StatelessWidget {
  const _PartialFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.kLightYellow,
      borderRadius: BorderRadius.circular(8.r),
      child: ListTile(
        leading: const Icon(Icons.sync_problem_outlined),
        title: const Text('Some information is unavailable'),
        subtitle: const Text('What loaded successfully is still shown.'),
        trailing: IconButton(
          tooltip: 'Refresh Home',
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}

class _AttentionContent {
  const _AttentionContent({
    required this.title,
    required this.body,
    required this.icon,
    required this.background,
    required this.border,
    required this.foreground,
    this.button,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color background;
  final Color border;
  final Color foreground;
  final String? button;
}

_AttentionContent _attentionContent(
  HomeRequiredAction action,
  MarketplaceHomeState state,
) {
  const blue = _AttentionContent(
    title: 'You are all caught up',
    body: 'There is no immediate action required.',
    icon: Icons.check_circle_outline,
    background: AppColors.blue02,
    border: AppColors.blue03,
    foreground: AppColors.primaryBlue6,
  );
  return switch (action) {
    HomeRequiredAction.completeProfile => const _AttentionContent(
      title: 'Complete your profile',
      body: 'A complete profile is required before the next care step.',
      icon: Icons.person_outline,
      background: AppColors.kLightYellow,
      border: Color(0xFFF4D58D),
      foreground: Color(0xFF8A5A00),
      button: 'Continue setup',
    ),
    HomeRequiredAction.submitVerification => const _AttentionContent(
      title: 'Submit verification evidence',
      body: 'Your professional application needs the required evidence.',
      icon: Icons.verified_user_outlined,
      background: AppColors.kLightYellow,
      border: Color(0xFFF4D58D),
      foreground: Color(0xFF8A5A00),
      button: 'Open verification',
    ),
    HomeRequiredAction.reviewVerification => const _AttentionContent(
      title: 'Verification needs attention',
      body: 'Review the current verification status and required evidence.',
      icon: Icons.report_outlined,
      background: AppColors.kLightRed,
      border: Color(0xFFF4A8A2),
      foreground: AppColors.kRed,
      button: 'Review verification',
    ),
    HomeRequiredAction.awaitVerification => const _AttentionContent(
      title: 'Verification is under review',
      body: 'No action is required while the submitted evidence is reviewed.',
      icon: Icons.hourglass_top_outlined,
      background: AppColors.blue02,
      border: AppColors.blue03,
      foreground: AppColors.primaryBlue6,
    ),
    HomeRequiredAction.respondToRequest => _AttentionContent(
      title:
          state.role == MarketplaceHomeRole.professional
              ? 'Appointment request waiting'
              : 'Request sent',
      body:
          state.role == MarketplaceHomeRole.professional
              ? 'Review the pending request in Appointments.'
              : 'The professional has not responded to this request yet.',
      icon: Icons.pending_actions_outlined,
      background: AppColors.blue02,
      border: AppColors.blue03,
      foreground: AppColors.primaryBlue6,
      button:
          state.role == MarketplaceHomeRole.professional
              ? 'Review request'
              : 'View request',
    ),
    HomeRequiredAction.configureAvailability => const _AttentionContent(
      title: 'Add your availability',
      body: 'No active availability is currently published for requests.',
      icon: Icons.calendar_month_outlined,
      background: AppColors.kLightYellow,
      border: Color(0xFFF4D58D),
      foreground: Color(0xFF8A5A00),
      button: 'Manage availability',
    ),
    HomeRequiredAction.upcomingAppointment => const _AttentionContent(
      title: 'Upcoming appointment',
      body: 'An accepted appointment is coming up. Review its current details.',
      icon: Icons.event_available_outlined,
      background: AppColors.kLightGreen,
      border: Color(0xFF8BD7B5),
      foreground: AppColors.kGreen,
      button: 'View appointment',
    ),
    HomeRequiredAction.findCare => const _AttentionContent(
      title: 'Ready when you need care',
      body: 'Search verified professionals and review their availability.',
      icon: Icons.manage_search_outlined,
      background: AppColors.blue02,
      border: AppColors.blue03,
      foreground: AppColors.primaryBlue6,
      button: 'Find care',
    ),
    HomeRequiredAction.none => blue,
  };
}

String _actionLabel(HomeRequiredAction action) {
  return switch (action) {
    HomeRequiredAction.none => 'READY',
    HomeRequiredAction.awaitVerification => 'IN REVIEW',
    _ => 'ACTION',
  };
}

String _dateLabel(DateTime value) {
  final local = value.toLocal();
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '${months[local.month - 1]} ${local.day} at $hour:$minute $period';
}

TextStyle _text(double size, FontWeight weight, Color color, {double? height}) {
  return TextStyle(
    fontFamily: AppFonts.montserrat,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );
}
