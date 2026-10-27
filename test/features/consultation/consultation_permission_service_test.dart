import 'package:app_t/features/Consultation/domain/services/consultation_permission_service.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter.baseflow.com/permissions/methods');
  const service = DeviceConsultationPermissionService();
  late List<MethodCall> calls;
  late Map<int, PermissionStatus> statuses;
  late bool settingsOpened;
  PlatformException? failure;

  setUp(() {
    calls = [];
    statuses = {};
    settingsOpened = true;
    failure = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (failure != null) throw failure!;
          switch (call.method) {
            case 'requestPermissions':
              final ids = (call.arguments as List).cast<int>();
              return {
                for (final id in ids)
                  id: (statuses[id] ?? PermissionStatus.granted).index,
              };
            case 'checkPermissionStatus':
              return (statuses[call.arguments] ?? PermissionStatus.granted)
                  .index;
            case 'openAppSettings':
              return settingsOpened;
            default:
              fail('Unexpected permission operation: ${call.method}');
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  for (final mode in ConsultationMode.values) {
    test('$mode requests only its required media permissions', () async {
      final result = await service.request(mode);
      expect(result.microphoneReady, isTrue);
      expect(result.cameraReady, isTrue);
      expect(
        calls.map((call) => call.method),
        everyElement('requestPermissions'),
      );
      expect(
        [for (final call in calls) ...(call.arguments as List).cast<int>()],
        [
          Permission.microphone.value,
          if (mode == ConsultationMode.video) Permission.camera.value,
        ],
      );
    });

    test('$mode checks media status without requesting permissions', () async {
      statuses[Permission.camera.value] = PermissionStatus.permanentlyDenied;
      final result = await service.check(mode);
      expect(result.microphoneReady, isTrue);
      expect(
        result.camera,
        mode == ConsultationMode.video
            ? ConsultationPermissionState.permanentlyDenied
            : ConsultationPermissionState.granted,
      );
      expect(
        calls.map((call) => call.method),
        everyElement('checkPermissionStatus'),
      );
      expect(calls.map((call) => call.arguments), [
        Permission.microphone.value,
        if (mode == ConsultationMode.video) Permission.camera.value,
      ]);
    });
  }

  const mapping = {
    PermissionStatus.granted: ConsultationPermissionState.granted,
    PermissionStatus.denied: ConsultationPermissionState.denied,
    PermissionStatus.permanentlyDenied:
        ConsultationPermissionState.permanentlyDenied,
    PermissionStatus.restricted: ConsultationPermissionState.restricted,
    PermissionStatus.limited: ConsultationPermissionState.granted,
    PermissionStatus.provisional: ConsultationPermissionState.unavailable,
  };
  for (final entry in mapping.entries) {
    test('microphone ${entry.key} preserves ${entry.value}', () async {
      statuses[Permission.microphone.value] = entry.key;
      final result = await service.request(ConsultationMode.audio);
      expect(result.microphone, entry.value);
      expect(
        result.microphoneReady,
        entry.value == ConsultationPermissionState.granted,
      );
      expect(calls, hasLength(1));
      expect(calls.single.arguments, [Permission.microphone.value]);
    });
  }

  test(
    'video camera denial does not invent camera or microphone state',
    () async {
      statuses[Permission.camera.value] = PermissionStatus.denied;
      final result = await service.request(ConsultationMode.video);
      expect(result.microphoneReady, isTrue);
      expect(result.cameraReady, isFalse);
      expect(result.camera, ConsultationPermissionState.denied);
      expect(calls.map((call) => call.arguments), [
        [Permission.microphone.value],
        [Permission.camera.value],
      ]);
    },
  );

  for (final opened in [true, false]) {
    test('settings opening returns the platform result $opened', () async {
      settingsOpened = opened;
      expect(await service.openApplicationSettings(), opened);
      expect(calls, hasLength(1));
      expect(calls.single.method, 'openAppSettings');
    });
  }

  test('plugin failure is not converted to granted media access', () async {
    failure = PlatformException(code: 'controlled-unavailable');
    await expectLater(
      service.request(ConsultationMode.audio),
      throwsA(isA<PlatformException>()),
    );
    expect(calls, hasLength(1));
  });
}
