import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';

import '../../domain/entities/appointment_summary.dart';
import '../../domain/entities/availability_window.dart';
import '../services/scheduling_api_client.dart';

class SchedulingRepository {
  const SchedulingRepository({
    required SchedulingApiClient apiClient,
    required SessionStore sessionStore,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore;

  final SchedulingApiClient _apiClient;
  final SessionStore _sessionStore;

  Future<List<AvailabilityWindow>> publicAvailability({
    required String professionalProfileId,
  }) {
    return _apiClient.publicAvailability(
      professionalProfileId: professionalProfileId,
    );
  }

  Future<List<AvailabilityWindow>> ownAvailability() async {
    final current = await _requireSession();
    return _apiClient.ownAvailability(accessToken: current.accessToken);
  }

  Future<List<AvailabilityWindow>> replaceOwnAvailability({
    required List<AvailabilityWindowDraft> windows,
  }) async {
    final current = await _requireSession();
    return _apiClient.replaceOwnAvailability(
      accessToken: current.accessToken,
      windows: windows,
    );
  }

  Future<AppointmentSummary> requestAppointment({
    required String professionalProfileId,
    required DateTime requestedStartAt,
    required int durationMinutes,
  }) async {
    final current = await _requireSession();
    return _apiClient.requestAppointment(
      accessToken: current.accessToken,
      professionalProfileId: professionalProfileId,
      requestedStartAt: requestedStartAt,
      durationMinutes: durationMinutes,
    );
  }

  Future<List<AppointmentSummary>> ownAppointments() async {
    final current = await _requireSession();
    return _apiClient.ownAppointments(accessToken: current.accessToken);
  }

  Future<AppointmentSummary> acceptAppointment({
    required String appointmentId,
  }) async {
    final current = await _requireSession();
    return _apiClient.acceptAppointment(
      accessToken: current.accessToken,
      appointmentId: appointmentId,
    );
  }

  Future<AppointmentSummary> declineAppointment({
    required String appointmentId,
  }) async {
    final current = await _requireSession();
    return _apiClient.declineAppointment(
      accessToken: current.accessToken,
      appointmentId: appointmentId,
    );
  }

  Future<AppointmentSummary> cancelAppointment({
    required String appointmentId,
  }) async {
    final current = await _requireSession();
    return _apiClient.cancelAppointment(
      accessToken: current.accessToken,
      appointmentId: appointmentId,
    );
  }

  Future<AppointmentSummary> completeAppointment({
    required String appointmentId,
  }) async {
    final current = await _requireSession();
    return _apiClient.completeAppointment(
      accessToken: current.accessToken,
      appointmentId: appointmentId,
    );
  }

  Future<AppointmentSummary> rescheduleAppointment({
    required String appointmentId,
    required DateTime requestedStartAt,
    required int durationMinutes,
  }) async {
    final current = await _requireSession();
    return _apiClient.rescheduleAppointment(
      accessToken: current.accessToken,
      appointmentId: appointmentId,
      requestedStartAt: requestedStartAt,
      durationMinutes: durationMinutes,
    );
  }

  Future<AuthSessionModel> _requireSession() async {
    final current = await _sessionStore.read();
    if (current == null) {
      throw const AuthFailure(
        type: AuthFailureType.unauthorized,
        message: 'Please sign in again.',
      );
    }
    return current;
  }
}
