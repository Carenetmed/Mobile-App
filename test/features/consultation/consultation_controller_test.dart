import 'dart:async';
import 'dart:ui' as ui;

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
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final role in ['PATIENT', 'PROFESSIONAL']) {
    testWidgets('audio preference is truthful and accessible for $role', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final mode in ConsultationMode.values) {
        final store = InMemorySessionStore();
        await store.save(_session(role: role));
        final room = _Room();
        final gateway = _Gateway(_projection(canJoin: true, mode: mode))
          ..grantRole =
              role == 'PROFESSIONAL'
                  ? ConsultationParticipantRole.professional
                  : ConsultationParticipantRole.patient;
        final controller = ConsultationController(
          appointmentId: 'appointment-1',
          repository: gateway,
          sessionStore: store,
          permissionService: _Permissions(),
          room: room,
          pollingInterval: const Duration(days: 1),
          now: () => DateTime.utc(2026, 7, 30, 10),
        );
        await controller.initialize();
        await controller.prepareMedia();
        await controller.join();
        expect(controller.isConnected, isTrue);
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 568),
                textScaler: TextScaler.linear(3.2),
              ),
              child: ConsultationShellPage(
                appointmentId: 'appointment-1',
                controller: controller,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final audio = find.bySemanticsLabel('Prefer speaker');
        expect(audio, findsOneWidget);
        final status = tester.getRect(
          find.byKey(const Key('consultation-active-status')),
        );
        final media = tester.getRect(
          find.byKey(const Key('consultation-media-stage')),
        );
        final controls = tester.getRect(
          find.byKey(const Key('consultation-call-controls')),
        );
        expect(status.bottom, lessThanOrEqualTo(media.top));
        expect(media.bottom, lessThanOrEqualTo(controls.top));
        expect(media.height, greaterThan(0));
        expect(controls.bottom, lessThanOrEqualTo(568));
        await tester.ensureVisible(audio);
        await tester.pumpAndSettle();
        expect(find.text('Preferred'), findsOneWidget);
        expect(
          tester
              .getSemantics(audio)
              .getSemanticsData()
              .flagsCollection
              .isToggled,
          ui.Tristate.isTrue,
        );
        expect(tester.getRect(audio).left, greaterThanOrEqualTo(0));
        expect(tester.getRect(audio).right, lessThanOrEqualTo(320));
        expect(tester.getRect(audio).bottom, lessThanOrEqualTo(568));
        await tester.tap(find.byTooltip('Use automatic audio routing'));
        await tester.pumpAndSettle();
        expect(room.speakerEnabled, isFalse);
        expect(find.text('Automatic'), findsOneWidget);
        expect(find.text('Earpiece'), findsNothing);
        expect(find.textContaining('Bluetooth connected'), findsNothing);
        expect(
          tester
              .getSemantics(audio)
              .getSemanticsData()
              .flagsCollection
              .isToggled,
          ui.Tristate.isFalse,
        );
        expect(
          tester
              .getSemantics(audio)
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isTrue,
        );
        tester.binding.renderViews.single.owner!.semanticsOwner!.performAction(
          tester.getSemantics(audio).id,
          SemanticsAction.tap,
        );
        await tester.pumpAndSettle();
        expect(room.speakerEnabled, isTrue);
        expect(find.text('Preferred'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        controller.dispose();
      }
      semantics.dispose();
    });
  }

  test(
    'refresh cannot rebind an open consultation to another account',
    () async {
      final h = _authorityHarness();
      addTearDown(h.controller.dispose);
      await h.controller.initialize();
      await h.store.save(_session(role: 'PATIENT', userId: 'other-user'));
      await h.controller.refresh();
      expect(h.gateway.projectionCalls, 1);
      expect(h.controller.projection, isNull);
      expect(h.room.releaseCalls, greaterThan(0));
      expect(h.controller.errorMessage, contains('cannot access'));
    },
  );

  test(
    'permission completion after account change cannot start preview',
    () async {
      final h = _authorityHarness();
      addTearDown(h.controller.dispose);
      await h.controller.initialize();
      final held = Completer<ConsultationPermissionResult>();
      h.permissions.requestCompleter = held;
      final preparation = h.controller.prepareMedia();
      await Future<void>.delayed(Duration.zero);
      await h.store.save(_session(role: 'PATIENT', userId: 'other-user'));
      held.complete(_grantedPermissions);
      await preparation;
      expect(h.room.previewCalls, 0);
      expect(h.controller.permissions, isNull);
      expect(h.controller.projection, isNull);
    },
  );

  test(
    'join grant completion after account change cannot connect media',
    () async {
      final h = _authorityHarness();
      addTearDown(h.controller.dispose);
      await h.controller.initialize();
      await h.controller.prepareMedia();
      final held = Completer<void>();
      h.gateway.joinHold = held;
      final join = h.controller.join();
      await Future<void>.delayed(Duration.zero);
      expect(h.gateway.joinCalls, 1);
      await h.store.save(_session(role: 'PATIENT', userId: 'other-user'));
      held.complete();
      await join;
      expect(h.room.connectCalls, 0);
      expect(h.controller.projection, isNull);
      expect(h.room.releaseCalls, greaterThan(0));
    },
  );

  test(
    'late waiting-room response cannot restore prior account state',
    () async {
      final h = _authorityHarness();
      addTearDown(h.controller.dispose);
      await h.controller.initialize();
      final held = Completer<ConsultationProjection>();
      h.gateway.waitingCompleter = held;
      final waiting = h.controller.enterWaitingRoom();
      await Future<void>.delayed(Duration.zero);
      await h.store.save(_session(role: 'PATIENT', userId: 'other-user'));
      held.complete(_projection(patientWaiting: true));
      await waiting;
      expect(h.controller.projection, isNull);
      expect(h.controller.actionMessage, isNull);
    },
  );

  test(
    'media control after account change releases rather than enabling media',
    () async {
      final h = _authorityHarness();
      addTearDown(h.controller.dispose);
      await h.controller.initialize();
      await h.store.save(_session(role: 'PATIENT', userId: 'other-user'));
      await h.controller.setMicrophoneEnabled(false);
      expect(h.room.microphoneEnabled, isTrue);
      expect(h.room.releaseCalls, greaterThan(0));
      expect(h.controller.projection, isNull);
    },
  );

  for (final changesAccount in <bool>[false, true]) {
    test(
      'failed delayed permission request ${changesAccount ? 'revokes changed authority' : 'preserves same-account error'}',
      () async {
        final h = _authorityHarness();
        addTearDown(h.controller.dispose);
        await h.controller.initialize();
        await h.controller.prepareMedia();
        final held = Completer<ConsultationPermissionResult>();
        h.permissions.requestCompleter = held;
        final preparation = h.controller.prepareMedia();
        await Future<void>.delayed(Duration.zero);
        if (changesAccount) {
          await h.store.save(_session(role: 'PATIENT', userId: 'other-user'));
        }
        held.completeError(
          const AuthFailure(
            type: AuthFailureType.network,
            message: 'internal permission failure',
          ),
        );
        await preparation;
        expect(h.room.previewCalls, 1);
        expect(h.room.releaseCalls, changesAccount ? 1 : 0);
        expect(h.controller.projection, changesAccount ? isNull : isNotNull);
        expect(h.controller.permissions, changesAccount ? isNull : isNotNull);
        expect(
          h.controller.errorMessage,
          changesAccount
              ? 'This account cannot access this consultation.'
              : 'Network error. Check your connection and try again.',
        );
      },
    );

    test(
      'failed delayed join grant ${changesAccount ? 'revokes changed authority' : 'preserves same-account error'}',
      () async {
        final h = _authorityHarness();
        addTearDown(h.controller.dispose);
        await h.controller.initialize();
        await h.controller.prepareMedia();
        final held = Completer<void>();
        h.gateway.joinHold = held;
        final join = h.controller.join();
        await Future<void>.delayed(Duration.zero);
        expect(h.gateway.joinCalls, 1);
        if (changesAccount) {
          await h.store.save(_session(role: 'PATIENT', userId: 'other-user'));
        }
        held.completeError(
          const AuthFailure(
            type: AuthFailureType.server,
            message: 'internal grant failure',
          ),
        );
        await join;
        expect(h.room.connectCalls, 0);
        expect(h.room.releaseCalls, changesAccount ? 1 : 0);
        expect(h.controller.projection, changesAccount ? isNull : isNotNull);
        expect(h.controller.permissions, changesAccount ? isNull : isNotNull);
        expect(
          h.controller.errorMessage,
          changesAccount
              ? 'This account cannot access this consultation.'
              : 'Consultation service is temporarily unavailable.',
        );
      },
    );
  }

  test('end disconnect cannot restore state after revocation', () async {
    final h = _authorityHarness();
    addTearDown(h.controller.dispose);
    await h.controller.initialize();
    final held = Completer<void>();
    h.room.disconnectHold = held;
    final ending = h.controller.endConsultation();
    await h.room.disconnectStarted.future;
    await h.store.save(_session(role: 'PATIENT', userId: 'other-user'));
    await h.controller.refresh();
    expect(h.controller.projection, isNull);
    held.complete();
    await ending;
    expect(h.gateway.endCalls, 1);
    expect(h.room.releaseCalls, 1);
    expect(h.controller.projection, isNull);
    expect(h.controller.actionMessage, isNull);
    expect(h.controller.errorMessage, contains('cannot access'));
  });

  test('pending session read cannot bypass a later revocation', () async {
    final h = _authorityHarness();
    addTearDown(h.controller.dispose);
    await h.controller.initialize();
    final waitingResponse = Completer<ConsultationProjection>();
    h.gateway.waitingCompleter = waitingResponse;
    final waiting = h.controller.enterWaitingRoom();
    await Future<void>.delayed(Duration.zero);
    expect(h.gateway.waitingCalls, 1);
    final heldRead = Completer<AuthSessionModel?>();
    h.store.nextRead = heldRead;
    waitingResponse.complete(_projection(patientWaiting: true));
    await h.store.heldReadStarted.future;
    await h.store.save(_session(role: 'PATIENT', userId: 'other-user'));
    await h.controller.refresh();
    await h.store.save(_session(role: 'PATIENT'));
    heldRead.complete(_session(role: 'PATIENT'));
    await waiting;
    expect(h.controller.projection, isNull);
    expect(h.controller.actionMessage, isNull);
    expect(h.room.releaseCalls, 1);
    expect(h.controller.errorMessage, contains('cannot access'));
  });

  for (final signsOut in <bool>[true, false]) {
    test(
      '${signsOut ? 'signout' : 'same-account role change'} revokes prepared media',
      () async {
        final h = _authorityHarness();
        addTearDown(h.controller.dispose);
        await h.controller.initialize();
        await h.controller.prepareMedia();
        if (signsOut) {
          await h.store.clear();
        } else {
          await h.store.save(_session(role: 'PROFESSIONAL'));
        }
        await h.controller.refresh();
        expect(h.gateway.projectionCalls, 1);
        expect(h.controller.viewerRole, ConsultationParticipantRole.patient);
        expect(h.controller.projection, isNull);
        expect(h.controller.permissions, isNull);
        expect(h.room.releaseCalls, 1);
        expect(h.controller.isConnected, isFalse);
        expect(
          h.controller.errorMessage,
          signsOut
              ? 'Your session has expired. Please sign in again.'
              : 'This account cannot access this consultation.',
        );
      },
    );
  }

  test('returning to the original account cannot reset revocation', () async {
    final h = _authorityHarness();
    addTearDown(h.controller.dispose);
    await h.controller.initialize();
    await h.controller.prepareMedia();
    await h.store.save(_session(role: 'PATIENT', userId: 'other-user'));
    await h.controller.refresh();
    await h.store.save(_session(role: 'PATIENT'));
    await h.controller.refresh();
    await h.controller.prepareMedia();
    await h.controller.join();
    expect(h.gateway.projectionCalls, 1);
    expect(h.gateway.joinCalls, 0);
    expect(h.room.previewCalls, 1);
    expect(h.room.connectCalls, 0);
    expect(h.room.releaseCalls, 1);
    expect(h.controller.projection, isNull);
    expect(h.controller.permissions, isNull);
    expect(h.controller.errorMessage, contains('cannot access'));
  });

  test('concurrent authority failures share pending media cleanup', () async {
    final h = _authorityHarness();
    addTearDown(h.controller.dispose);
    await h.controller.initialize();
    await h.controller.prepareMedia();
    final held = Completer<void>();
    h.room.releaseHold = held;
    await h.store.clear();
    var refreshCompleted = false;
    var controlCompleted = false;
    final refresh = h.controller.refresh().then((_) {
      refreshCompleted = true;
    });
    await h.room.releaseStarted.future;
    final control = h.controller.setSpeakerEnabled(false).then((_) {
      controlCompleted = true;
    });
    await Future<void>.delayed(Duration.zero);
    expect(h.room.releaseCalls, 1);
    expect(refreshCompleted, isFalse);
    expect(controlCompleted, isFalse);
    expect(h.controller.projection, isNull);
    expect(h.controller.permissions, isNull);
    held.complete();
    await Future.wait(<Future<void>>[refresh, control]);
    expect(h.room.releaseCalls, 1);
    expect(h.room.speakerEnabled, isTrue);
    expect(refreshCompleted, isTrue);
    expect(controlCompleted, isTrue);
  });

  test('stale account cannot enable a muted microphone', () async {
    final h = _authorityHarness();
    addTearDown(h.controller.dispose);
    await h.controller.initialize();
    await h.controller.setMicrophoneEnabled(false);
    expect(h.room.microphoneEnabled, isFalse);
    expect(h.controller.microphoneEnabled, isFalse);
    await h.store.save(_session(role: 'PATIENT', userId: 'other-user'));
    await h.controller.setMicrophoneEnabled(true);
    expect(h.room.microphoneEnabled, isFalse);
    expect(h.controller.microphoneEnabled, isFalse);
    expect(h.room.releaseCalls, 1);
    expect(h.controller.projection, isNull);
  });

  for (final operation in <String>[
    'resume camera disable',
    'resume microphone disconnect',
    'leave disconnect',
  ]) {
    for (final fails in <bool>[false, true]) {
      for (final changesAccount in <bool>[false, true]) {
        test(
          '$operation held ${fails ? 'error' : 'success'} ${changesAccount ? 'revokes changed authority' : 'preserves same-account outcome'}',
          () async {
            final h = _authorityHarness();
            addTearDown(h.controller.dispose);
            await h.controller.initialize();
            await h.controller.prepareMedia();
            await h.controller.join();
            expect(h.controller.isConnected, isTrue);
            final held = Completer<void>();
            if (operation == 'resume camera disable') {
              h.permissions.checkResult = const ConsultationPermissionResult(
                microphone: ConsultationPermissionState.granted,
                camera: ConsultationPermissionState.denied,
              );
              h.room.cameraHold = held;
            } else {
              h.room.disconnectHold = held;
              if (operation == 'resume microphone disconnect') {
                h.permissions.checkResult = const ConsultationPermissionResult(
                  microphone: ConsultationPermissionState.denied,
                  camera: ConsultationPermissionState.granted,
                );
              }
            }
            final completion =
                operation == 'leave disconnect'
                    ? h.controller.leave()
                    : h.controller.onAppResumed();
            await (operation == 'resume camera disable'
                ? h.room.cameraStarted.future
                : h.room.disconnectStarted.future);
            if (changesAccount) {
              await h.store.save(
                _session(role: 'PATIENT', userId: 'other-user'),
              );
            }
            if (fails) {
              held.completeError(
                const AuthFailure(
                  type: AuthFailureType.network,
                  message: 'internal media failure',
                ),
              );
            } else {
              held.complete();
            }
            await completion;
            expect(h.room.releaseCalls, changesAccount ? 1 : 0);
            expect(
              h.controller.projection,
              changesAccount ? isNull : isNotNull,
            );
            expect(
              h.controller.permissions,
              changesAccount ? isNull : isNotNull,
            );
            expect(h.gateway.projectionCalls, changesAccount || fails ? 2 : 3);
            if (changesAccount) {
              expect(h.controller.actionMessage, isNull);
              expect(
                h.controller.errorMessage,
                'This account cannot access this consultation.',
              );
              expect(h.controller.isConnected, isFalse);
            } else if (fails) {
              expect(h.controller.actionMessage, isNull);
              expect(
                h.controller.errorMessage,
                'Network error. Check your connection and try again.',
              );
              expect(h.controller.isConnected, isTrue);
            } else if (operation == 'resume camera disable') {
              expect(h.controller.cameraEnabled, isFalse);
              expect(h.room.cameraEnabled, isFalse);
              expect(h.controller.actionMessage, contains('Camera access'));
              expect(h.controller.errorMessage, isNull);
            } else if (operation == 'resume microphone disconnect') {
              expect(h.controller.isConnected, isFalse);
              expect(
                h.controller.errorMessage,
                contains('Microphone access was removed'),
              );
            } else {
              expect(h.controller.isConnected, isFalse);
              expect(h.controller.actionMessage, 'You left the consultation.');
              expect(h.controller.errorMessage, isNull);
            }
            if (operation == 'resume camera disable' &&
                (changesAccount || fails)) {
              expect(h.controller.cameraEnabled, isTrue);
            }
          },
        );
      }
    }
  }

  for (final initiallyBound in <bool>[false, true]) {
    test(
      '${initiallyBound ? 'bound' : 'initial'} session read failure blocks refresh and permits retry',
      () async {
        final h = _authorityHarness();
        addTearDown(h.controller.dispose);
        if (initiallyBound) {
          await h.controller.initialize();
          await h.controller.prepareMedia();
        }
        final held = Completer<AuthSessionModel?>();
        h.store.nextRead = held;
        final refresh = h.controller.refresh();
        await h.store.heldReadStarted.future;
        held.completeError(
          const AuthFailure(
            type: AuthFailureType.network,
            message: 'internal session read failure',
          ),
        );
        await refresh;
        expect(h.gateway.projectionCalls, initiallyBound ? 1 : 0);
        expect(h.room.releaseCalls, 0);
        expect(h.controller.projection, initiallyBound ? isNotNull : isNull);
        expect(
          h.controller.errorMessage,
          'Network error. Check your connection and try again.',
        );
        await h.controller.refresh();
        expect(h.gateway.projectionCalls, initiallyBound ? 2 : 1);
        expect(h.controller.viewerRole, ConsultationParticipantRole.patient);
        expect(h.controller.projection, isNotNull);
        expect(h.controller.errorMessage, isNull);
      },
    );
  }

  test('late session read failure cannot deliver waiting state', () async {
    final h = _authorityHarness();
    addTearDown(h.controller.dispose);
    await h.controller.initialize();
    final response = Completer<ConsultationProjection>();
    h.gateway.waitingCompleter = response;
    final waiting = h.controller.enterWaitingRoom();
    await Future<void>.delayed(Duration.zero);
    expect(h.gateway.waitingCalls, 1);
    final held = Completer<AuthSessionModel?>();
    h.store.nextRead = held;
    response.complete(_projection(patientWaiting: true));
    await h.store.heldReadStarted.future;
    held.completeError(
      const AuthFailure(
        type: AuthFailureType.network,
        message: 'internal late read failure',
      ),
    );
    await waiting;
    expect(h.controller.projection?.patientWaiting, isFalse);
    expect(h.controller.actionMessage, isNull);
    expect(h.room.releaseCalls, 0);
    expect(
      h.controller.errorMessage,
      'Network error. Check your connection and try again.',
    );
    await h.controller.enterWaitingRoom();
    expect(h.controller.projection?.patientWaiting, isTrue);
    expect(h.controller.actionMessage, 'You are in the waiting room.');
  });

  test('resume refresh cannot overwrite an authority error', () async {
    final h = _authorityHarness();
    addTearDown(h.controller.dispose);
    await h.controller.initialize();
    await h.controller.prepareMedia();
    await h.controller.join();
    h.permissions.checkResult = const ConsultationPermissionResult(
      microphone: ConsultationPermissionState.denied,
      camera: ConsultationPermissionState.granted,
    );
    final held = Completer<ConsultationProjection>();
    h.gateway.projectionCompleter = held;
    final resume = h.controller.onAppResumed();
    await h.gateway.heldProjectionStarted.future;
    await h.store.save(_session(role: 'PATIENT', userId: 'other-user'));
    held.complete(_projection(canJoin: true));
    await resume;
    expect(h.room.releaseCalls, 1);
    expect(h.controller.projection, isNull);
    expect(h.controller.permissions, isNull);
    expect(
      h.controller.errorMessage,
      'This account cannot access this consultation.',
    );
  });

  test('resume catches failed authority cleanup without escaping', () async {
    final h = _authorityHarness();
    addTearDown(h.controller.dispose);
    await h.controller.initialize();
    await h.controller.prepareMedia();
    final held = Completer<void>();
    h.room.releaseHold = held;
    await h.store.clear();
    final resume = h.controller.onAppResumed();
    await h.room.releaseStarted.future;
    held.completeError(StateError('internal cleanup failure'));
    await resume;
    expect(h.controller.projection, isNull);
    expect(h.controller.permissions, isNull);
    expect(
      h.controller.errorMessage,
      'Something went wrong. Please try again.',
    );
    h.room.releaseHold = null;
  });

  test('dispose contains a held late async release failure', () async {
    final reports = _captureDisposalReports();
    final h = _authorityHarness();
    await h.controller.initialize();
    await h.controller.prepareMedia();
    final projection = h.controller.projection;
    final permissions = h.controller.permissions;
    var notifications = 0;
    h.controller.addListener(() => notifications++);
    final held = Completer<void>();
    h.room.releaseHold = held;
    expect(h.controller.dispose, returnsNormally);
    await h.room.releaseStarted.future;
    expect(reports.errors, isEmpty);
    held.completeError(
      StateError(_unsafeCleanupDetails),
      StackTrace.fromString(_unsafeCleanupDetails),
    );
    await reports.reported;
    _expectRedactedDisposalFailure(reports.errors.single);
    expect(h.room.releaseCalls, 1);
    expect(h.room.connectionState, RtcConnectionState.previewing);
    expect(h.controller.projection, same(projection));
    expect(h.controller.permissions, same(permissions));
    await h.controller.refresh();
    await h.controller.prepareMedia();
    expect(h.gateway.projectionCalls, 1);
    expect(h.room.previewCalls, 1);
    expect(notifications, 0);
  });

  test('dispose contains a synchronous release failure', () async {
    final reports = _captureDisposalReports();
    final h = _authorityHarness(roomOverride: _SynchronouslyFailingRoom());
    await h.controller.initialize();
    var notifications = 0;
    h.controller.addListener(() => notifications++);
    expect(h.controller.dispose, returnsNormally);
    await reports.reported;
    _expectRedactedDisposalFailure(reports.errors.single);
    expect(h.room.releaseCalls, 1);
    await h.controller.refresh();
    expect(h.gateway.projectionCalls, 1);
    expect(notifications, 0);
  });

  test('dispose contains repeated release after failed revocation', () async {
    final reports = _captureDisposalReports();
    final h = _authorityHarness();
    await h.controller.initialize();
    await h.controller.prepareMedia();
    final held = Completer<void>();
    h.room.releaseHold = held;
    await h.store.clear();
    final resume = h.controller.onAppResumed();
    await h.room.releaseStarted.future;
    held.completeError(StateError(_unsafeCleanupDetails));
    await resume;
    expect(h.room.releaseCalls, 1);
    expect(h.controller.projection, isNull);
    expect(h.controller.permissions, isNull);
    expect(reports.errors, isEmpty);
    var notifications = 0;
    h.controller.addListener(() => notifications++);
    expect(h.controller.dispose, returnsNormally);
    await reports.reported;
    _expectRedactedDisposalFailure(reports.errors.single);
    expect(h.room.releaseCalls, 2);
    expect(h.room.connectionState, RtcConnectionState.previewing);
    expect(h.controller.projection, isNull);
    expect(h.controller.permissions, isNull);
    expect(notifications, 0);
  });

  test('dispose waits for an in-flight revocation release', () async {
    final h = _authorityHarness();
    await h.controller.initialize();
    await h.controller.prepareMedia();
    final held = Completer<void>();
    h.room.releaseHold = held;
    await h.store.clear();
    final resume = h.controller.onAppResumed();
    await h.room.releaseStarted.future;

    h.controller.dispose();
    await Future<void>.delayed(Duration.zero);
    expect(h.room.releaseCalls, 1);

    held.complete();
    await resume;
    await Future<void>.delayed(Duration.zero);
    expect(h.room.releaseCalls, 1);
  });

  test(
    'synchronous revocation failure remains latched after account return',
    () async {
      final reports = _captureDisposalReports();
      final h = _authorityHarness(roomOverride: _SynchronouslyFailingRoom());
      await h.controller.initialize();
      await h.controller.prepareMedia();
      await h.store.save(_session(role: 'PATIENT', userId: 'other-user'));
      await h.controller.refresh();
      expect(h.controller.projection, isNull);
      expect(h.controller.permissions, isNull);
      expect(h.room.releaseCalls, 1);
      await h.store.save(_session(role: 'PATIENT'));
      await h.controller.refresh();
      await h.controller.prepareMedia();
      await h.controller.join();
      expect(h.gateway.projectionCalls, 1);
      expect(h.gateway.joinCalls, 0);
      expect(h.room.previewCalls, 1);
      expect(h.room.connectCalls, 0);
      expect(h.room.releaseCalls, 1);
      expect(h.controller.projection, isNull);
      expect(h.controller.permissions, isNull);
      expect(
        h.controller.errorMessage,
        'Something went wrong. Please try again.',
      );
      h.controller.dispose();
      await reports.reported;
      _expectRedactedDisposalFailure(reports.errors.single);
    },
  );

  test('cleanup reentry observes the latch before adapter execution', () async {
    final reports = _captureDisposalReports();
    final room = _ReentrantReleaseRoom();
    final h = _authorityHarness(roomOverride: room);
    await h.controller.initialize();
    final held = Completer<void>();
    room.releaseHold = held;
    late final Future<void> reentry;
    var readsDuringReentry = -1;
    var reentryCompleted = false;
    room.onRelease = () {
      final readsBefore = h.store.readCalls;
      reentry = h.controller.setSpeakerEnabled(false).then((_) {
        reentryCompleted = true;
      });
      readsDuringReentry = h.store.readCalls - readsBefore;
    };
    await h.store.save(_session(role: 'PATIENT', userId: 'other-user'));
    final refresh = h.controller.refresh();
    await room.releaseStarted.future;
    expect(readsDuringReentry, 0);
    expect(reentryCompleted, isFalse);
    expect(room.releaseCalls, 1);
    expect(h.controller.projection, isNull);
    held.completeError(StateError(_unsafeCleanupDetails));
    await Future.wait(<Future<void>>[refresh, reentry]);
    expect(reentryCompleted, isTrue);
    expect(room.releaseCalls, 1);
    expect(room.speakerEnabled, isTrue);
    expect(h.controller.projection, isNull);
    h.controller.dispose();
    await reports.reported;
    _expectRedactedDisposalFailure(reports.errors.single);
  });

  test(
    'async revocation failure remains latched after account return',
    () async {
      final reports = _captureDisposalReports();
      final h = _authorityHarness();
      await h.controller.initialize();
      await h.controller.prepareMedia();
      final held = Completer<void>();
      h.room.releaseHold = held;
      await h.store.save(_session(role: 'PATIENT', userId: 'other-user'));
      final refresh = h.controller.refresh();
      await h.room.releaseStarted.future;
      held.completeError(StateError(_unsafeCleanupDetails));
      await refresh;
      await h.store.save(_session(role: 'PATIENT'));
      await h.controller.refresh();
      await h.controller.prepareMedia();
      await h.controller.join();
      expect(h.gateway.projectionCalls, 1);
      expect(h.gateway.joinCalls, 0);
      expect(h.room.previewCalls, 1);
      expect(h.room.connectCalls, 0);
      expect(h.room.releaseCalls, 1);
      expect(h.room.connectionState, RtcConnectionState.previewing);
      expect(h.controller.projection, isNull);
      expect(h.controller.permissions, isNull);
      expect(
        h.controller.errorMessage,
        'Something went wrong. Please try again.',
      );
      h.controller.dispose();
      await reports.reported;
      _expectRedactedDisposalFailure(reports.errors.single);
    },
  );

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
    final semantics = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(320, 568));
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
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
          ),
          child: ConsultationShellPage(
            appointmentId: 'appointment-1',
            controller: controller,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Video consultation'), findsOneWidget);
    final countdown = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          (widget.properties.label ==
                  'The scheduled join opening time has arrived.' ||
              widget.properties.label?.startsWith('Waiting room opens in ') ==
                  true),
    );
    await tester.scrollUntilVisible(
      countdown,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(countdown, findsOneWidget);
    expect(
      tester
          .getSemantics(countdown)
          .getSemanticsData()
          .flagsCollection
          .isLiveRegion,
      isFalse,
    );

    final waiting = find.byKey(const Key('consultation-enter-waiting'));
    await tester.scrollUntilVisible(
      waiting,
      160,
      scrollable: find.byType(Scrollable).first,
    );
    expect(waiting.hitTestable(), findsOneWidget);
    expect(find.byKey(const Key('consultation-join')), findsNothing);
    expect(find.textContaining('payment', findRichText: true), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    semantics.dispose();
  });

  testWidgets('active call controls fit compact large-text layouts', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final mode in ConsultationMode.values) {
      final store = InMemorySessionStore()..save(_session(role: 'PATIENT'));
      final gateway = _Gateway(_projection(canJoin: true, mode: mode));
      final room = _Room();
      final controller = ConsultationController(
        appointmentId: 'appointment-1',
        repository: gateway,
        sessionStore: store,
        permissionService: _Permissions(),
        room: room,
        pollingInterval: const Duration(days: 1),
        now: () => DateTime.utc(2026, 7, 30, 10),
      );
      await controller.initialize();
      await controller.prepareMedia();
      await controller.join();

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 568),
              textScaler: TextScaler.linear(2),
            ),
            child: ConsultationShellPage(
              appointmentId: 'appointment-1',
              controller: controller,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.isConnected, isTrue);
      final waitingStatus = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Waiting for the other participant',
      );
      expect(waitingStatus, findsOneWidget);
      expect(
        tester
            .getSemantics(waitingStatus)
            .getSemanticsData()
            .flagsCollection
            .isLiveRegion,
        isTrue,
      );
      room.connectionState = RtcConnectionState.reconnecting;
      room.notifyListeners();
      await tester.pumpAndSettle();
      final reconnectingStatus = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Reconnecting securely...',
      );
      expect(reconnectingStatus, findsOneWidget);
      expect(
        tester
            .getSemantics(reconnectingStatus)
            .getSemanticsData()
            .flagsCollection
            .isLiveRegion,
        isTrue,
      );
      room.connectionState = RtcConnectionState.connected;
      room.notifyListeners();
      await tester.pumpAndSettle();

      for (final label in <String>['Mute', 'Prefer speaker', 'Leave']) {
        final control = find.bySemanticsLabel(label);
        expect(control, findsOneWidget);
        expect(
          tester
              .getSemantics(control)
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isTrue,
        );
      }
      if (mode == ConsultationMode.video) {
        final camera = find.bySemanticsLabel('Camera off');
        expect(camera, findsOneWidget);
        expect(
          tester
              .getSemantics(camera)
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isTrue,
        );
      } else {
        expect(find.bySemanticsLabel('Camera off'), findsNothing);
      }
      expect(tester.takeException(), isNull);

      if (mode == ConsultationMode.video) {
        await tester.tap(find.bySemanticsLabel('Leave'));
        await tester.pumpAndSettle();
        expect(
          find.text('You can rejoin while the consultation is still open.'),
          findsOneWidget,
        );
        expect(find.textContaining('backend'), findsNothing);
        await tester.tap(find.text('Stay'));
        await tester.pumpAndSettle();
      }

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    }

    semantics.dispose();
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
  Completer<ConsultationProjection>? projectionCompleter;
  final heldProjectionStarted = Completer<void>();
  Completer<ConsultationProjection>? waitingCompleter;
  Completer<void>? joinHold;
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
    final held = projectionCompleter;
    if (held != null) {
      projectionCompleter = null;
      heldProjectionStarted.complete();
      return held.future;
    }
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
    await joinHold?.future;
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
  Completer<ConsultationPermissionResult>? requestCompleter;
  ConsultationPermissionResult checkResult;

  @override
  Future<ConsultationPermissionResult> check(ConsultationMode mode) async {
    return checkResult;
  }

  @override
  Future<bool> openApplicationSettings() async => true;

  @override
  Future<ConsultationPermissionResult> request(ConsultationMode mode) async {
    if (requestCompleter != null) return requestCompleter!.future;
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
  int releaseCalls = 0;
  int connectCalls = 0;
  Completer<void>? disconnectHold;
  Completer<void>? releaseHold;
  Completer<void>? cameraHold;
  final disconnectStarted = Completer<void>();
  final releaseStarted = Completer<void>();
  final cameraStarted = Completer<void>();
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
    if (!disconnectStarted.isCompleted) disconnectStarted.complete();
    await disconnectHold?.future;
    connectionState = RtcConnectionState.disconnected;
    notifyListeners();
  }

  @override
  Future<void> release() async {
    releaseCalls++;
    if (!releaseStarted.isCompleted) releaseStarted.complete();
    await releaseHold?.future;
    connectionState = RtcConnectionState.disconnected;
  }

  @override
  Future<void> setCameraEnabled(bool enabled) async {
    if (!cameraStarted.isCompleted) cameraStarted.complete();
    await cameraHold?.future;
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

const _unsafeCleanupDetails =
    'raw SDK cleanup test-jwt-sensitive wss://private-room.example.test';

({List<FlutterErrorDetails> errors, Future<void> reported})
_captureDisposalReports() {
  final previous = FlutterError.onError;
  final errors = <FlutterErrorDetails>[];
  final reported = Completer<void>();
  FlutterError.onError = (details) {
    errors.add(details);
    if (!reported.isCompleted) reported.complete();
  };
  addTearDown(() => FlutterError.onError = previous);
  return (errors: errors, reported: reported.future);
}

void _expectRedactedDisposalFailure(FlutterErrorDetails details) {
  expect(details.exception, isA<StateError>());
  expect(
    details.exceptionAsString(),
    'Bad state: Consultation media cleanup failed; resource release is unverified.',
  );
  expect(details.library, 'consultation');
  expect(
    details.context.toString(),
    'while disposing a consultation controller',
  );
  expect(details.stack, isNull);
  expect(details.informationCollector, isNull);
  expect(details.toString(), isNot(contains('raw SDK')));
  expect(details.toString(), isNot(contains('test-jwt-sensitive')));
  expect(details.toString(), isNot(contains('wss://')));
}

class _SynchronouslyFailingRoom extends _Room {
  @override
  Future<void> release() {
    releaseCalls++;
    throw StateError(_unsafeCleanupDetails);
  }
}

class _ReentrantReleaseRoom extends _Room {
  void Function()? onRelease;

  @override
  Future<void> release() {
    releaseCalls++;
    final callback = onRelease;
    onRelease = null;
    callback?.call();
    if (!releaseStarted.isCompleted) releaseStarted.complete();
    return releaseHold!.future;
  }
}

class _AuthoritySessionStore extends InMemorySessionStore {
  int readCalls = 0;
  Completer<AuthSessionModel?>? nextRead;
  final heldReadStarted = Completer<void>();

  @override
  Future<AuthSessionModel?> read() {
    readCalls++;
    final held = nextRead;
    if (held == null) return super.read();
    nextRead = null;
    heldReadStarted.complete();
    return held.future;
  }
}

({
  ConsultationController controller,
  _AuthoritySessionStore store,
  _Gateway gateway,
  _Room room,
  _Permissions permissions,
})
_authorityHarness({_Room? roomOverride}) {
  final store = _AuthoritySessionStore()..save(_session(role: 'PATIENT'));
  final gateway = _Gateway(
    _projection(canJoin: true, canEnterWaitingRoom: true),
  );
  final room = roomOverride ?? _Room();
  final permissions = _Permissions();
  final controller = ConsultationController(
    appointmentId: 'appointment-1',
    repository: gateway,
    sessionStore: store,
    permissionService: permissions,
    room: room,
    pollingInterval: const Duration(days: 1),
    now: () => DateTime.utc(2026, 7, 30, 10),
  );
  return (
    controller: controller,
    store: store,
    gateway: gateway,
    room: room,
    permissions: permissions,
  );
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
  ConsultationMode mode = ConsultationMode.video,
  bool canEnterWaitingRoom = false,
  bool canJoin = false,
  bool canAdmit = false,
  bool canRejoin = false,
  bool patientWaiting = false,
  bool patientAdmitted = false,
}) {
  return ConsultationProjection(
    appointmentId: 'appointment-1',
    mode: mode,
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
