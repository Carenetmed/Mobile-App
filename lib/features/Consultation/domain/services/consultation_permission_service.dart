import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:permission_handler/permission_handler.dart';

enum ConsultationPermissionState {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  unavailable,
}

class ConsultationPermissionResult {
  const ConsultationPermissionResult({
    required this.microphone,
    required this.camera,
  });

  final ConsultationPermissionState microphone;
  final ConsultationPermissionState camera;

  bool get microphoneReady => microphone == ConsultationPermissionState.granted;

  bool get cameraReady => camera == ConsultationPermissionState.granted;
}

abstract class ConsultationPermissionService {
  Future<ConsultationPermissionResult> request(ConsultationMode mode);

  Future<ConsultationPermissionResult> check(ConsultationMode mode);

  Future<bool> openApplicationSettings();
}

class DeviceConsultationPermissionService
    implements ConsultationPermissionService {
  const DeviceConsultationPermissionService();

  @override
  Future<ConsultationPermissionResult> request(ConsultationMode mode) async {
    final microphone = await Permission.microphone.request();
    final camera =
        mode == ConsultationMode.video
            ? await Permission.camera.request()
            : PermissionStatus.granted;
    return ConsultationPermissionResult(
      microphone: _state(microphone),
      camera: _state(camera),
    );
  }

  @override
  Future<ConsultationPermissionResult> check(ConsultationMode mode) async {
    final microphone = await Permission.microphone.status;
    final camera =
        mode == ConsultationMode.video
            ? await Permission.camera.status
            : PermissionStatus.granted;
    return ConsultationPermissionResult(
      microphone: _state(microphone),
      camera: _state(camera),
    );
  }

  @override
  Future<bool> openApplicationSettings() => openAppSettings();
}

ConsultationPermissionState _state(PermissionStatus status) {
  if (status.isGranted || status.isLimited) {
    return ConsultationPermissionState.granted;
  }
  if (status.isPermanentlyDenied) {
    return ConsultationPermissionState.permanentlyDenied;
  }
  if (status.isRestricted) {
    return ConsultationPermissionState.restricted;
  }
  if (status.isDenied) {
    return ConsultationPermissionState.denied;
  }
  return ConsultationPermissionState.unavailable;
}
