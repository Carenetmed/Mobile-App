import 'dart:async';

import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Consultation/data/repositories/consultation_repository.dart';
import 'package:app_t/features/Consultation/domain/entities/consultation_entities.dart';
import 'package:app_t/features/Consultation/domain/services/consultation_permission_service.dart';
import 'package:app_t/features/Consultation/domain/services/rtc_room_adapter.dart';
import 'package:app_t/features/Consultation/presentation/pages/consultation_shell.dart';
import 'package:app_t/features/Consultation/presentation/state/consultation_controller.dart';
import 'package:app_t/features/Home/domain/entities/appointment_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('consultation failures never expose unclassified backend details', () {
    expect(
      safeConsultationFailure(
        const AuthFailure(
          type: AuthFailureType.validation,
          message: 'internal provider response',
        ),
      ),
      'Something went wrong. Please try again.',
    );
  });

  test(
    'patient uses backend waiting, grant, and same device session',
    () async {
      final store = InMemorySessionStore()..save(_session(role: 'PATIENT'));
      final gateway = _Gateway(_projection(canEnterWaitingRoom: true));
      final room = _Room();
      final controller = ConsultationController(
        appointmentId: 'appointment-1',
        repository: gateway,
        sessionStore: store,
        permissionService: _Permissions(),
        room: room,
        deviceSessionId: 'device-session-stable',
        pollingInterval: const Duration(days: 1),
        now: () => DateTime.utc(2026, 7, 30, 10),
      );

      await controller.initialize();
      expect(controller.viewerRole, ConsultationParticipantRole.patient);
      expect(gateway.projectionCalls, 1);

      await controller.prepareMedia();
      expect(room.previewCalls, 1);
      await controller.enterWaitingRoom();
      expect(gateway.waitingCalls, 1);

      gateway.value = _projection(
        canJoin: true,
        patientWaiting: true,
        patientAdmitted: true,
      );
      await controller.refresh();
      await controller.join();

      expect(gateway.joinCalls, 1);
      expect(gateway.deviceSessionIds, <String>['device-session-stable']);
      expect(room.connectCalls, 1);
      expect(room.lastGrant?.token, 'provider-token');
      controller.dispose();
    },
  );

  test(
    'repeated action is serialized and account change fails closed',
    () async {
      final store = InMemorySessionStore()..save(_session(role: 'PATIENT'));
      final waiting = Completer<ConsultationProjection>();
      final gateway = _Gateway(_projection(canEnterWaitingRoom: true))
        ..waitingCompleter = waiting;
      final controller = ConsultationController(
        appointmentId: 'appointment-1',
        repository: gateway,
        sessionStore: store,
        permissionService: _Permissions(),
        room: _Room(),
        pollingInterval: const Duration(days: 1),
      );
      await controller.initialize();

      final first = controller.enterWaitingRoom();
      final second = controller.enterWaitingRoom();
      await Future<void>.delayed(Duration.zero);
      expect(gateway.waitingCalls, 1);
      waiting.complete(_projection(patientWaiting: true));
      await Future.wait(<Future<void>>[first, second]);

      await store.save(_session(role: 'PATIENT', userId: 'other-user'));
      await controller.enterWaitingRoom();
      expect(gateway.waitingCalls, 1);
      expect(
        controller.errorMessage,
        'This account cannot access this consultation.',
      );
      controller.dispose();
    },
  );

  test('unsupported role fails closed without loading projection', () async {
    final store = InMemorySessionStore()..save(_session(role: 'ADMIN'));
    final gateway = _Gateway(_projection());
    final controller = ConsultationController(
      appointmentId: 'appointment-1',
      repository: gateway,
      sessionStore: store,
      permissionService: _Permissions(),
      room: _Room(),
    );

    await controller.initialize();

    expect(controller.viewerRole, ConsultationParticipantRole.unknown);
    expect(controller.projection, isNull);
    expect(gateway.projectionCalls, 0);
    expect(controller.errorMessage, contains('cannot access'));
    controller.dispose();
  });

  testWidgets('prejoin exposes only backend-authorized waiting action', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final store = InMemorySessionStore()..save(_session(role: 'PATIENT'));
    final controller = ConsultationController(
      appointmentId: 'appointment-1',
      repository: _Gateway(_projection(canEnterWaitingRoom: true)),
      sessionStore: store,
      permissionService: _Permissions(),
      room: _Room(),
      pollingInterval: const Duration(days: 1),
    );
    await controller.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: ConsultationShellPage(
          appointmentId: 'appointment-1',
          controller: controller,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Video consultation'), findsOneWidget);
    expect(find.byKey(const Key('consultation-enter-waiting')), findsOneWidget);
    expect(find.byKey(const Key('consultation-join')), findsNothing);
    expect(find.textContaining('payment', findRichText: true), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });

  test('expired join grant never reaches the RTC provider', () async {
    final store = InMemorySessionStore()..save(_session(role: 'PATIENT'));
    final gateway = _Gateway(_projection(canJoin: true))
      ..grantExpiresAt = DateTime.utc(2026, 7, 30, 9, 59);
    final room = _Room();
    final controller = ConsultationController(
      appointmentId: 'appointment-1',
      repository: gateway,
      sessionStore: store,
      permissionService: _Permissions(),
      room: room,
      now: () => DateTime.utc(2026, 7, 30, 10),
      pollingInterval: const Duration(days: 1),
    );

    await controller.initialize();
    await controller.prepareMedia();
    await controller.join();

    expect(gateway.joinCalls, 1);
    expect(room.connectCalls, 0);
    expect(controller.errorMessage, contains('grant expired'));
    controller.dispose();
  });

  test('foreground microphone revocation disconnects an active room', () async {
    final store = InMemorySessionStore()..save(_session(role: 'PATIENT'));
    final gateway = _Gateway(_projection(canJoin: true));
    final permissions = _Permissions();
    final room = _Room();
    final controller = ConsultationController(
      appointmentId: 'appointment-1',
      repository: gateway,
      sessionStore: store,
      permissionService: permissions,
      room: room,
      now: () => DateTime.utc(2026, 7, 30, 10),
      pollingInterval: const Duration(days: 1),
    );

    await controller.initialize();
    await controller.prepareMedia();
    await controller.join();
    expect(controller.isConnected, isTrue);

    permissions.checkResult = const ConsultationPermissionResult(
      microphone: ConsultationPermissionState.denied,
      camera: ConsultationPermissionState.granted,
    );
    await controller.onAppResumed();

    expect(controller.isConnected, isFalse);
    expect(controller.errorMessage, contains('Microphone access was removed'));
    controller.dispose();
  });

  test('join grant for another participant role fails closed', () async {
    final store = InMemorySessionStore()..save(_session(role: 'PATIENT'));
    final gateway = _Gateway(_projection(canJoin: true))
      ..grantRole = ConsultationParticipantRole.professional;
    final room = _Room();
    final controller = ConsultationController(
      appointmentId: 'appointment-1',
      repository: gateway,
      sessionStore: store,
      permissionService: _Permissions(),
      room: room,
      now: () => DateTime.utc(2026, 7, 30, 10),
      pollingInterval: const Duration(days: 1),
    );

    await controller.initialize();
    await controller.prepareMedia();
    await controller.join();

    expect(room.connectCalls, 0);
    expect(controller.errorMessage, contains('did not match this account'));
    controller.dispose();
  });
}

class _Gateway implements ConsultationGateway {
  _Gateway(this.value);

  ConsultationProjection value;
  Completer<ConsultationProjection>? waitingCompleter;
  int projectionCalls = 0;
  int waitingCalls = 0;
  int admitCalls = 0;
  int joinCalls = 0;
  int endCalls = 0;
  int incidentCalls = 0;
  DateTime grantExpiresAt = DateTime.utc(2026, 7, 30, 10, 5);
  ConsultationParticipantRole grantRole = ConsultationParticipantRole.patient;
  final List<String> deviceSessionIds = <String>[];

  @override
  Future<ConsultationProjection> projection({
    required String appointmentId,
  }) async {
    projectionCalls++;
    return value;
  }

  @override
  Future<ConsultationProjection> enterWaitingRoom({
    required String appointmentId,
  }) async {
    waitingCalls++;
    final completer = waitingCompleter;
    if (completer != null) {
      waitingCompleter = null;
      return completer.future;
    }
    value = _projection(patientWaiting: true);
    return value;
  }

  @override
  Future<ConsultationProjection> admitPatient({
    required String appointmentId,
  }) async {
    admitCalls++;
    return value;
  }

  @override
  Future<ConsultationJoinGrant> joinGrant({
    required String appointmentId,
    required String deviceSessionId,
    required bool cameraEnabled,
  }) async {
    joinCalls++;
    deviceSessionIds.add(deviceSessionId);
    return ConsultationJoinGrant(
      provider: 'LIVEKIT',
      serverUrl: Uri.parse('wss://rtc.example.test'),
      token: 'provider-token',
      expiresAt: grantExpiresAt,
      participantRole: grantRole,
      microphoneAllowed: true,
      cameraAllowed: true,
      sessionId: 'session-1',
      replacedPriorDevice: false,
    );
  }

  @override
  Future<ConsultationProjection> endConsultation({
    required String appointmentId,
  }) async {
    endCalls++;
    return _projection(status: ConsultationSessionStatus.ended);
  }

  @override
  Future<ConsultationIncidentReceipt> reportIncident({
    required String appointmentId,
    required ConsultationIncidentCategory category,
    String? description,
  }) async {
    incidentCalls++;
    return ConsultationIncidentReceipt(
      id: 'incident-1',
      status: 'OPEN',
      createdAt: DateTime.utc(2026, 7, 30),
    );
  }
}

class _Permissions implements ConsultationPermissionService {
  _Permissions({
    ConsultationPermissionResult? requestResult,
    ConsultationPermissionResult? checkResult,
  }) : requestResult = requestResult ?? _grantedPermissions,
       checkResult = checkResult ?? requestResult ?? _grantedPermissions;

  ConsultationPermissionResult requestResult;
  ConsultationPermissionResult checkResult;

  @override
  Future<ConsultationPermissionResult> check(ConsultationMode mode) async {
    return checkResult;
  }

  @override
  Future<bool> openApplicationSettings() async => true;

  @override
  Future<ConsultationPermissionResult> request(ConsultationMode mode) async {
    return requestResult;
  }
}

const _grantedPermissions = ConsultationPermissionResult(
  microphone: ConsultationPermissionState.granted,
  camera: ConsultationPermissionState.granted,
);

class _Room extends RtcRoomAdapter {
  @override
  RtcConnectionState connectionState = RtcConnectionState.idle;
  @override
  bool microphoneEnabled = true;
  @override
  bool cameraEnabled = true;
  @override
  bool speakerEnabled = true;
  @override
  bool remoteParticipantPresent = false;
  @override
  bool remoteMicrophoneEnabled = false;
  @override
  bool remoteCameraEnabled = false;
  @override
  RtcVideoTrackHandle? localVideo;
  @override
  RtcVideoTrackHandle? remoteVideo;
  @override
  String? safeFailureMessage;

  int previewCalls = 0;
  int connectCalls = 0;
  ConsultationJoinGrant? lastGrant;

  @override
  Future<void> preparePreview({required bool videoEnabled}) async {
    previewCalls++;
    connectionState = RtcConnectionState.previewing;
    cameraEnabled = videoEnabled;
    notifyListeners();
  }

  @override
  Future<void> connect({
    required ConsultationJoinGrant grant,
    required bool microphoneEnabled,
    required bool cameraEnabled,
  }) async {
    connectCalls++;
    lastGrant = grant;
    this.microphoneEnabled = microphoneEnabled;
    this.cameraEnabled = cameraEnabled;
    connectionState = RtcConnectionState.connected;
    notifyListeners();
  }

  @override
  Future<void> disconnect() async {
    connectionState = RtcConnectionState.disconnected;
    notifyListeners();
  }

  @override
  Future<void> release() async {}

  @override
  Future<void> setCameraEnabled(bool enabled) async {
    cameraEnabled = enabled;
    notifyListeners();
  }

  @override
  Future<void> setMicrophoneEnabled(bool enabled) async {
    microphoneEnabled = enabled;
    notifyListeners();
  }

  @override
  Future<void> setSpeakerEnabled(bool enabled) async {
    speakerEnabled = enabled;
    notifyListeners();
  }

  @override
  Future<void> switchCamera() async {}
}

AuthSessionModel _session({required String role, String userId = 'user-1'}) {
  return AuthSessionModel.fromJson(<String, dynamic>{
    'accessToken': 'access-token',
    'refreshToken': 'refresh-token',
    'tokenType': 'Bearer',
    'expiresIn': 900,
    'user': <String, dynamic>{
      'id': userId,
      'email': '$userId@example.test',
      'role': role,
      'status': 'ACTIVE',
      'emailVerified': true,
    },
  });
}

ConsultationProjection _projection({
  ConsultationSessionStatus status = ConsultationSessionStatus.pending,
  bool canEnterWaitingRoom = false,
  bool canJoin = false,
  bool canAdmit = false,
  bool canRejoin = false,
  bool patientWaiting = false,
  bool patientAdmitted = false,
}) {
  return ConsultationProjection(
    appointmentId: 'appointment-1',
    mode: ConsultationMode.video,
    sessionStatus: status,
    joinOpensAt: DateTime.utc(2026, 7, 30, 9, 50),
    lateJoinDeadlineAt: DateTime.utc(2026, 7, 30, 10, 15),
    scheduledEndsAt: DateTime.utc(2026, 7, 30, 10, 30),
    closesAt: DateTime.utc(2026, 7, 30, 10, 40),
    canEnterWaitingRoom: canEnterWaitingRoom,
    canJoin: canJoin,
    canAdmit: canAdmit,
    canRejoin: canRejoin,
    patientWaiting: patientWaiting,
    patientAdmitted: patientAdmitted,
    patientPresent: false,
    professionalPresent: false,
    reviewRequired: false,
  );
}
