import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:flutter/foundation.dart';

import '../../data/repositories/scheduling_repository.dart';
import '../../domain/entities/appointment_summary.dart';
import '../../domain/entities/requestable_times.dart';
import '../../domain/services/appointment_experience_policy.dart';

AppointmentViewerRole appointmentRoleFromWire(String? role) {
  return switch (role?.trim().toUpperCase()) {
    'PATIENT' => AppointmentViewerRole.patient,
    'PROFESSIONAL' => AppointmentViewerRole.professional,
    _ => AppointmentViewerRole.unsupported,
  };
}

String safeAppointmentFailure(Object error) {
  if (error is! AuthFailure) {
    return 'Something went wrong. Please try again.';
  }
  return switch (error.statusCode) {
    401 => 'Your session has expired. Please sign in again.',
    403 => 'This account is not allowed to perform that action.',
    404 => 'This appointment is no longer available.',
    409 => 'This appointment changed. Refresh and review it again.',
    _ => switch (error.type) {
      AuthFailureType.missingConfiguration => 'Backend is not configured yet.',
      AuthFailureType.unauthorized =>
        'Your session has expired. Please sign in again.',
      AuthFailureType.forbidden =>
        'This account is not allowed to perform that action.',
      AuthFailureType.validation =>
        'The appointment could not be updated. Refresh and try again.',
      AuthFailureType.server || AuthFailureType.network =>
        'The result is uncertain. Refresh before trying another action.',
      AuthFailureType.invalidCredentials ||
      AuthFailureType.unknown => 'Something went wrong. Please try again.',
    },
  };
}

class AppointmentListController extends ChangeNotifier {
  AppointmentListController({
    required SchedulingRepository schedulingRepository,
    required SessionStore sessionStore,
  }) : _schedulingRepository = schedulingRepository,
       _sessionStore = sessionStore;

  final SchedulingRepository _schedulingRepository;
  final SessionStore _sessionStore;

  List<AppointmentSummary> appointments = const <AppointmentSummary>[];
  AppointmentViewerRole role = AppointmentViewerRole.unsupported;
  bool isLoading = false;
  bool isRefreshing = false;
  String? errorMessage;

  Future<void>? _activeLoad;
  int _generation = 0;
  bool _disposed = false;

  Future<void> load() {
    final active = _activeLoad;
    if (active != null) {
      return active;
    }
    final future = _load();
    _activeLoad = future;
    return future.whenComplete(() {
      if (identical(_activeLoad, future)) {
        _activeLoad = null;
      }
    });
  }

  Future<void> _load() async {
    final generation = ++_generation;
    final hasData = appointments.isNotEmpty;
    isLoading = !hasData;
    isRefreshing = hasData;
    errorMessage = null;
    _notify();

    try {
      final session = await _sessionStore.read();
      final resolvedRole = appointmentRoleFromWire(session?.user.role);
      if (resolvedRole == AppointmentViewerRole.unsupported) {
        if (!_accept(generation)) {
          return;
        }
        role = resolvedRole;
        appointments = const <AppointmentSummary>[];
        errorMessage = 'This account cannot access appointments.';
        return;
      }

      final loaded = await _schedulingRepository.ownAppointments();
      if (!_accept(generation)) {
        return;
      }
      role = resolvedRole;
      appointments = List<AppointmentSummary>.unmodifiable(loaded);
    } catch (error) {
      if (!_accept(generation)) {
        return;
      }
      errorMessage = safeAppointmentFailure(error);
    } finally {
      if (_accept(generation)) {
        isLoading = false;
        isRefreshing = false;
        _notify();
      }
    }
  }

  bool _accept(int generation) => !_disposed && generation == _generation;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}

class AppointmentDetailController extends ChangeNotifier {
  AppointmentDetailController({
    required this.appointmentId,
    required SchedulingRepository schedulingRepository,
    required SessionStore sessionStore,
    DateTime Function()? now,
  }) : _schedulingRepository = schedulingRepository,
       _sessionStore = sessionStore,
       _now = now ?? DateTime.now;

  final String appointmentId;
  final SchedulingRepository _schedulingRepository;
  final SessionStore _sessionStore;
  final DateTime Function() _now;
  final AppointmentExperiencePolicy _policy =
      const AppointmentExperiencePolicy();

  AppointmentSummary? appointment;
  AppointmentViewerRole role = AppointmentViewerRole.unsupported;
  RequestableTimes? requestableTimes;
  RequestableTime? selectedTime;
  bool isLoading = false;
  bool isRefreshing = false;
  bool isMutating = false;
  bool isLoadingTimes = false;
  String? loadError;
  String? actionMessage;
  String? actionError;

  Future<void>? _activeLoad;
  Future<void>? _activeMutation;
  Future<void>? _activeTimesLoad;
  int _generation = 0;
  bool _disposed = false;

  List<AppointmentUiAction> get actions {
    final current = appointment;
    if (current == null) {
      return const <AppointmentUiAction>[];
    }
    return _policy.actionsFor(role: role, appointment: current, now: _now());
  }

  Future<void> load() {
    final active = _activeLoad;
    if (active != null) {
      return active;
    }
    final future = _load();
    _activeLoad = future;
    return future.whenComplete(() {
      if (identical(_activeLoad, future)) {
        _activeLoad = null;
      }
    });
  }

  Future<void> _load() async {
    final generation = ++_generation;
    isLoading = appointment == null;
    isRefreshing = appointment != null;
    loadError = null;
    _notify();

    try {
      final session = await _sessionStore.read();
      final resolvedRole = appointmentRoleFromWire(session?.user.role);
      if (resolvedRole == AppointmentViewerRole.unsupported) {
        if (!_accept(generation)) {
          return;
        }
        role = resolvedRole;
        appointment = null;
        loadError = 'This account cannot access appointments.';
        return;
      }
      final appointments = await _schedulingRepository.ownAppointments();
      final found =
          appointments.where((item) => item.id == appointmentId).firstOrNull;
      if (!_accept(generation)) {
        return;
      }
      role = resolvedRole;
      appointment = found;
      if (found == null) {
        loadError = 'This appointment is no longer available.';
      }
    } catch (error) {
      if (_accept(generation)) {
        if (error is AuthFailure && error.statusCode == 404) {
          appointment = null;
        }
        loadError = safeAppointmentFailure(error);
      }
    } finally {
      if (_accept(generation)) {
        isLoading = false;
        isRefreshing = false;
        _notify();
      }
    }
  }

  Future<void> loadRescheduleTimes() {
    final current = appointment;
    if (current == null || !actions.contains(AppointmentUiAction.reschedule)) {
      return Future<void>.value();
    }
    final active = _activeTimesLoad;
    if (active != null) {
      return active;
    }
    final future = _loadRescheduleTimes(current.professionalProfileId);
    _activeTimesLoad = future;
    return future.whenComplete(() {
      if (identical(_activeTimesLoad, future)) {
        _activeTimesLoad = null;
      }
    });
  }

  Future<void> _loadRescheduleTimes(String professionalProfileId) async {
    isLoadingTimes = true;
    actionError = null;
    actionMessage = null;
    _notify();
    try {
      final loaded = await _schedulingRepository.publicRequestableTimes(
        professionalProfileId: professionalProfileId,
      );
      if (_disposed ||
          appointment?.professionalProfileId != professionalProfileId) {
        return;
      }
      requestableTimes = loaded;
      if (!loaded.times.contains(selectedTime)) {
        selectedTime = null;
      }
    } catch (error) {
      if (!_disposed) {
        actionError = safeAppointmentFailure(error);
      }
    } finally {
      if (!_disposed) {
        isLoadingTimes = false;
        _notify();
      }
    }
  }

  void selectTime(RequestableTime time) {
    final times = requestableTimes?.times ?? const <RequestableTime>[];
    if (!times.contains(time) || isMutating) {
      return;
    }
    selectedTime = time;
    actionError = null;
    _notify();
  }

  Future<void> perform(AppointmentUiAction action) {
    final active = _activeMutation;
    if (active != null) {
      return active;
    }
    if (!actions.contains(action)) {
      actionError = 'That action is not available for this appointment.';
      _notify();
      return Future<void>.value();
    }
    if (action == AppointmentUiAction.reschedule && selectedTime == null) {
      actionError = 'Choose a currently available time first.';
      _notify();
      return Future<void>.value();
    }
    final future = _perform(action);
    _activeMutation = future;
    return future.whenComplete(() {
      if (identical(_activeMutation, future)) {
        _activeMutation = null;
      }
    });
  }

  Future<void> _perform(AppointmentUiAction action) async {
    final current = appointment;
    if (current == null) {
      return;
    }
    isMutating = true;
    actionError = null;
    actionMessage = null;
    _notify();

    try {
      switch (action) {
        case AppointmentUiAction.accept:
          await _schedulingRepository.acceptAppointment(
            appointmentId: current.id,
          );
        case AppointmentUiAction.decline:
          await _schedulingRepository.declineAppointment(
            appointmentId: current.id,
          );
        case AppointmentUiAction.cancel:
          await _schedulingRepository.cancelAppointment(
            appointmentId: current.id,
          );
        case AppointmentUiAction.complete:
          await _schedulingRepository.completeAppointment(
            appointmentId: current.id,
          );
        case AppointmentUiAction.reschedule:
          await _schedulingRepository.rescheduleAppointment(
            appointmentId: current.id,
            requestedStartAt: selectedTime!.startAt,
            durationMinutes: 30,
          );
      }
      if (_disposed) {
        return;
      }
      actionMessage = switch (action) {
        AppointmentUiAction.accept => 'Appointment accepted.',
        AppointmentUiAction.decline => 'Appointment declined.',
        AppointmentUiAction.cancel => 'Appointment cancelled.',
        AppointmentUiAction.reschedule =>
          'New time requested. The appointment is awaiting a response.',
        AppointmentUiAction.complete => 'Appointment completed.',
      };
      requestableTimes = null;
      selectedTime = null;
    } catch (error) {
      if (!_disposed) {
        actionError = safeAppointmentFailure(error);
      }
    } finally {
      if (!_disposed) {
        isMutating = false;
        _notify();
        await load();
      }
    }
  }

  bool _accept(int generation) => !_disposed && generation == _generation;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
