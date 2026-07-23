import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/domain/entities/account_readiness.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:app_t/features/Home/domain/entities/availability_window.dart';
import 'package:app_t/features/Home/domain/entities/patient_profile.dart';
import 'package:app_t/features/Home/domain/entities/professional_profile.dart';

enum MarketplaceHomeRole { patient, professional }

enum HomeDataSection { profile, readiness, appointments, availability }

enum HomeRequiredAction {
  completeProfile,
  submitVerification,
  reviewVerification,
  awaitVerification,
  respondToRequest,
  configureAvailability,
  upcomingAppointment,
  findCare,
  none,
}

class MarketplaceHomeState {
  const MarketplaceHomeState({
    required this.role,
    this.patientProfile,
    this.professionalProfile,
    this.readiness,
    this.appointments = const <AppointmentSummary>[],
    this.availability = const <AvailabilityWindow>[],
    this.failedSections = const <HomeDataSection>{},
  });

  final MarketplaceHomeRole role;
  final PatientProfile? patientProfile;
  final ProfessionalProfile? professionalProfile;
  final AccountReadiness? readiness;
  final List<AppointmentSummary> appointments;
  final List<AvailabilityWindow> availability;
  final Set<HomeDataSection> failedSections;

  String get displayName {
    final name =
        role == MarketplaceHomeRole.patient
            ? patientProfile?.name
            : professionalProfile?.displayName;
    final clean = name?.trim() ?? '';
    return clean.isEmpty
        ? (role == MarketplaceHomeRole.patient ? 'Patient' : 'Professional')
        : clean;
  }

  AppointmentSummary? pendingRequest() {
    return _firstSorted(
      appointments.where(
        (appointment) => appointment.status == AppointmentStatus.requested,
      ),
    );
  }

  AppointmentSummary? nextUpcoming(DateTime now) {
    return _firstSorted(
      appointments.where(
        (appointment) =>
            appointment.status == AppointmentStatus.accepted &&
            appointment.requestedStartAt.isAfter(now),
      ),
    );
  }

  bool get hasActiveAvailability => availability.any((window) => window.active);

  bool get patientSetupRequired {
    final patient = readiness?.patient;
    if (patient == null) return false;
    final status = patient.profileStatus.trim().toUpperCase();
    return status != 'COMPLETE' ||
        patient.requiredFields.isNotEmpty ||
        readiness!.requiredActions.isNotEmpty ||
        readiness!.nextAction.trim().toUpperCase() == 'PATIENT_SETUP';
  }

  String get professionalVerificationStatus {
    return (readiness?.professional?.verificationStatus ??
            professionalProfile?.verificationStatus ??
            'UNKNOWN')
        .trim()
        .toUpperCase();
  }

  bool get professionalProfileRequired {
    final professional = readiness?.professional;
    if (professional == null) return false;
    final next = readiness!.nextAction.trim().toUpperCase();
    return professional.requiredProfileFields.isNotEmpty ||
        next == 'PROFESSIONAL_RESUME_APPLICATION';
  }

  HomeRequiredAction requiredAction(DateTime now) {
    if (role == MarketplaceHomeRole.patient) {
      if (patientSetupRequired) return HomeRequiredAction.completeProfile;
      if (pendingRequest() != null) return HomeRequiredAction.respondToRequest;
      if (nextUpcoming(now) != null) {
        return HomeRequiredAction.upcomingAppointment;
      }
      return HomeRequiredAction.findCare;
    }

    if (professionalProfileRequired) return HomeRequiredAction.completeProfile;
    switch (professionalVerificationStatus) {
      case 'NOT_SUBMITTED':
        return HomeRequiredAction.submitVerification;
      case 'REJECTED':
        return HomeRequiredAction.reviewVerification;
      case 'PENDING':
      case 'UNDER_REVIEW':
        return HomeRequiredAction.awaitVerification;
    }
    if (pendingRequest() != null) return HomeRequiredAction.respondToRequest;
    if (!failedSections.contains(HomeDataSection.availability) &&
        !hasActiveAvailability) {
      return HomeRequiredAction.configureAvailability;
    }
    if (nextUpcoming(now) != null) {
      return HomeRequiredAction.upcomingAppointment;
    }
    return HomeRequiredAction.none;
  }

  AppointmentSummary? _firstSorted(Iterable<AppointmentSummary> candidates) {
    final sorted =
        candidates.toList()..sort((left, right) {
          final byTime = left.requestedStartAt.compareTo(
            right.requestedStartAt,
          );
          return byTime != 0 ? byTime : left.id.compareTo(right.id);
        });
    return sorted.firstOrNull;
  }
}

class MarketplaceHomeCoordinator {
  const MarketplaceHomeCoordinator({
    required this.role,
    required this.profileRepository,
    required this.onboardingRepository,
    required this.schedulingRepository,
  });

  final MarketplaceHomeRole role;
  final ProfileRepository profileRepository;
  final OnboardingRepository onboardingRepository;
  final SchedulingRepository schedulingRepository;

  Future<MarketplaceHomeState> load() async {
    PatientProfile? patientProfile;
    ProfessionalProfile? professionalProfile;
    AccountReadiness? readiness;
    var appointments = const <AppointmentSummary>[];
    var availability = const <AvailabilityWindow>[];
    final failed = <HomeDataSection>{};

    await Future.wait<void>([
      () async {
        try {
          if (role == MarketplaceHomeRole.patient) {
            patientProfile = await profileRepository.patientMe();
          } else {
            professionalProfile = await profileRepository.professionalMe();
          }
        } catch (_) {
          failed.add(HomeDataSection.profile);
        }
      }(),
      () async {
        try {
          readiness = await onboardingRepository.accountReadiness();
        } catch (_) {
          failed.add(HomeDataSection.readiness);
        }
      }(),
      () async {
        try {
          appointments = await schedulingRepository.ownAppointments();
        } catch (_) {
          failed.add(HomeDataSection.appointments);
        }
      }(),
      if (role == MarketplaceHomeRole.professional)
        () async {
          try {
            availability = await schedulingRepository.ownAvailability();
          } catch (_) {
            failed.add(HomeDataSection.availability);
          }
        }(),
    ]);

    return MarketplaceHomeState(
      role: role,
      patientProfile: patientProfile,
      professionalProfile: professionalProfile,
      readiness: readiness,
      appointments: appointments,
      availability: availability,
      failedSections: failed,
    );
  }
}
