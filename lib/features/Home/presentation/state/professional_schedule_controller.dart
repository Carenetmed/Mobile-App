import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:flutter/foundation.dart';

import '../../data/repositories/scheduling_repository.dart';
import '../../domain/entities/availability_window.dart';
import '../../domain/services/appointment_experience_policy.dart';
import '../../domain/services/professional_time_formatter.dart';
import 'appointment_experience_controller.dart';

class ProfessionalScheduleController extends ChangeNotifier {
  ProfessionalScheduleController({
    required SchedulingRepository schedulingRepository,
    required SessionStore sessionStore,
  }) : _schedulingRepository = schedulingRepository,
       _sessionStore = sessionStore;

  final SchedulingRepository _schedulingRepository;
  final SessionStore _sessionStore;

  List<AvailabilityWindow> windows = const <AvailabilityWindow>[];
  bool isAuthorizedProfessional = false;
  bool isLoading = false;
  bool isRefreshing = false;
  bool isMutating = false;
  String? errorMessage;
  String? successMessage;

  Future<void>? _activeLoad;
  Future<void>? _activeMutation;
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
    isLoading = windows.isEmpty;
    isRefreshing = windows.isNotEmpty;
    errorMessage = null;
    _notify();
    try {
      final session = await _sessionStore.read();
      final authorized =
          appointmentRoleFromWire(session?.user.role) ==
          AppointmentViewerRole.professional;
      if (!_accept(generation)) {
        return;
      }
      isAuthorizedProfessional = authorized;
      if (!authorized) {
        windows = const <AvailabilityWindow>[];
        errorMessage =
            'Only an authenticated professional can manage availability.';
        return;
      }
      final loaded = await _schedulingRepository.ownAvailability();
      if (_accept(generation)) {
        windows = _sorted(loaded);
      }
    } catch (error) {
      if (_accept(generation)) {
        errorMessage = _safeScheduleFailure(error);
      }
    } finally {
      if (_accept(generation)) {
        isLoading = false;
        isRefreshing = false;
        _notify();
      }
    }
  }

  String? validate(AvailabilityWindowDraft draft, {String? replacingId}) {
    if (draft.weekday < 0 || draft.weekday > 6) {
      return 'Choose a valid weekday.';
    }
    if (draft.startMinute < 0 ||
        draft.startMinute > 1439 ||
        draft.endMinute < 1 ||
        draft.endMinute > 1440 ||
        draft.endMinute <= draft.startMinute) {
      return 'End time must be after start time.';
    }
    if (!ProfessionalTimeFormatter().isValidTimezone(draft.timezone.trim())) {
      return 'Choose a valid time zone, such as Africa/Lagos.';
    }
    if (draft.active) {
      final overlaps = windows.any(
        (window) =>
            window.id != replacingId &&
            window.active &&
            window.weekday == draft.weekday &&
            draft.startMinute < window.endMinute &&
            draft.endMinute > window.startMinute,
      );
      if (overlaps) {
        return 'This time overlaps another active window.';
      }
    }
    return null;
  }

  Future<String?> save({
    String? replacingId,
    required AvailabilityWindowDraft draft,
  }) {
    final validation = validate(draft, replacingId: replacingId);
    if (validation != null) {
      return Future<String?>.value(validation);
    }
    return _mutate(
      () {
        final drafts =
            windows
                .where((window) => window.id != replacingId)
                .map(_draftFromWindow)
                .toList();
        drafts.add(
          AvailabilityWindowDraft(
            weekday: draft.weekday,
            startMinute: draft.startMinute,
            endMinute: draft.endMinute,
            timezone: draft.timezone.trim(),
            active: draft.active,
          ),
        );
        return drafts;
      },
      success:
          replacingId == null ? 'Availability added.' : 'Availability updated.',
    );
  }

  Future<String?> delete(String id) {
    if (!windows.any((window) => window.id == id)) {
      return Future<String?>.value('Availability window was not found.');
    }
    return _mutate(
      () =>
          windows
              .where((window) => window.id != id)
              .map(_draftFromWindow)
              .toList(),
      success: 'Availability removed.',
    );
  }

  Future<String?> _mutate(
    List<AvailabilityWindowDraft> Function() buildDrafts, {
    required String success,
  }) {
    final active = _activeMutation;
    if (active != null) {
      return Future<String?>.value(
        'Another availability update is in progress.',
      );
    }
    final future = _performMutation(buildDrafts, success: success);
    _activeMutation = future;
    return future.whenComplete(() {
      if (identical(_activeMutation, future)) {
        _activeMutation = null;
      }
    });
  }

  Future<String?> _performMutation(
    List<AvailabilityWindowDraft> Function() buildDrafts, {
    required String success,
  }) async {
    if (!isAuthorizedProfessional) {
      return 'Only an authenticated professional can manage availability.';
    }
    isMutating = true;
    errorMessage = null;
    successMessage = null;
    _notify();
    try {
      await _schedulingRepository.replaceOwnAvailability(
        windows: buildDrafts(),
      );
      final refreshed = await _schedulingRepository.ownAvailability();
      if (!_disposed) {
        windows = _sorted(refreshed);
        successMessage = success;
      }
      return null;
    } catch (error) {
      final message = _safeScheduleFailure(error, uncertainMutation: true);
      if (!_disposed) {
        errorMessage = message;
        try {
          final refreshed = await _schedulingRepository.ownAvailability();
          if (!_disposed) {
            windows = _sorted(refreshed);
          }
        } catch (_) {
          // Keep the last authoritative data when reconciliation also fails.
        }
      }
      return message;
    } finally {
      if (!_disposed) {
        isMutating = false;
        _notify();
      }
    }
  }

  static AvailabilityWindowDraft _draftFromWindow(AvailabilityWindow window) {
    return AvailabilityWindowDraft(
      weekday: window.weekday,
      startMinute: window.startMinute,
      endMinute: window.endMinute,
      timezone: window.timezone,
      active: window.active,
    );
  }

  static List<AvailabilityWindow> _sorted(Iterable<AvailabilityWindow> values) {
    return values.toList(growable: false)..sort((left, right) {
      final weekday = left.weekday.compareTo(right.weekday);
      if (weekday != 0) {
        return weekday;
      }
      final start = left.startMinute.compareTo(right.startMinute);
      return start != 0 ? start : left.id.compareTo(right.id);
    });
  }

  bool _accept(int generation) => !_disposed && generation == _generation;

  static String _safeScheduleFailure(
    Object error, {
    bool uncertainMutation = false,
  }) {
    if (error is! AuthFailure) {
      return 'Something went wrong. Please try again.';
    }
    return switch (error.statusCode) {
      401 => 'Your session has expired. Please sign in again.',
      403 => 'This account is not allowed to manage availability.',
      404 => 'The professional profile is no longer available.',
      409 => 'Availability changed. Refresh and try again.',
      _ => switch (error.type) {
        AuthFailureType.missingConfiguration =>
          'Schedule is unavailable right now. Please try again.',
        AuthFailureType.unauthorized =>
          'Your session has expired. Please sign in again.',
        AuthFailureType.forbidden =>
          'This account is not allowed to manage availability.',
        AuthFailureType.validation =>
          'Please check the availability and try again.',
        AuthFailureType.server || AuthFailureType.network =>
          uncertainMutation
              ? 'The result is uncertain. Refresh before trying another update.'
              : 'Service is unavailable. Please try again.',
        AuthFailureType.invalidCredentials ||
        AuthFailureType.unknown => 'Something went wrong. Please try again.',
      },
    };
  }

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
