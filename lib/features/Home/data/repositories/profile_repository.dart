import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';

import '../../domain/entities/patient_profile.dart';
import '../../domain/entities/professional_profile.dart';
import '../../domain/entities/public_professional.dart';
import '../services/profile_api_client.dart';

class ProfileRepository {
  const ProfileRepository({
    required ProfileApiClient apiClient,
    required SessionStore sessionStore,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore;

  final ProfileApiClient _apiClient;
  final SessionStore _sessionStore;

  Future<PatientProfile?> patientMe() async {
    final current = await _requireSession();
    return _apiClient.patientMe(accessToken: current.accessToken);
  }

  Future<PatientProfile> updatePatientMe({
    required String name,
    int? age,
    String? location,
  }) async {
    final current = await _requireSession();
    return _apiClient.updatePatientMe(
      accessToken: current.accessToken,
      name: name,
      age: age,
      location: location,
    );
  }

  Future<ProfessionalProfile?> professionalMe() async {
    final current = await _requireSession();
    return _apiClient.professionalMe(accessToken: current.accessToken);
  }

  Future<ProfessionalProfile> updateProfessionalMe({
    required String displayName,
    required String category,
    String? specialty,
    String? bio,
  }) async {
    final current = await _requireSession();
    return _apiClient.updateProfessionalMe(
      accessToken: current.accessToken,
      displayName: displayName,
      category: category,
      specialty: specialty,
      bio: bio,
    );
  }

  Future<List<PublicProfessional>> publicProfessionals() {
    return _apiClient.publicProfessionals();
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
