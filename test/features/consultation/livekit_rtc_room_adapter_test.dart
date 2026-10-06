import 'dart:async';
import 'dart:collection';

import 'package:app_t/features/Consultation/data/services/livekit_rtc_room_adapter.dart';
import 'package:app_t/features/Consultation/domain/entities/consultation_entities.dart';
import 'package:app_t/features/Consultation/domain/services/rtc_room_adapter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livekit_client/livekit_client.dart';

void main() {
  test('default constructor supports audio-only preview and release', () async {
    final adapter = LiveKitRtcRoomAdapter();
    expect(adapter.connectionState, RtcConnectionState.idle);
    expect(adapter.microphoneEnabled, isTrue);
    expect(adapter.cameraEnabled, isTrue);
    expect(adapter.speakerEnabled, isTrue);
    await adapter.preparePreview(videoEnabled: false);
    expect(adapter.connectionState, RtcConnectionState.previewing);
    expect(adapter.cameraEnabled, isFalse);
    expect(adapter.localVideo, isNull);
    await adapter.release();
    adapter.dispose();
  });

  test(
    'dispose contains SDK cleanup failure and reports only redacted diagnostics',
    () async {
      final reports = _captureFlutterReports();
      final uncaught = <Object>[];
      final h = _Harness();
      await h.connect();
      final room = h.rooms.single;
      late final _Gate<void> cleanup;
      runZonedGuarded<void>(() {
        room.disconnectGate = cleanup = _Gate<void>();
        h.adapter.dispose();
      }, (error, _) => uncaught.add(error));
      await cleanup.entered.future;
      final notifications = h.notifications;
      final raw = _rawCleanupError();
      cleanup.result.completeError(raw, _rawCleanupStack());
      await pumpEventQueue();
      expect(uncaught, isEmpty);
      expect(reports, hasLength(1));
      expect(reports.single.exception, isNot(same(raw)));
      _expectRedactedCleanupReport(reports.single);
      expect(h.notifications, notifications);
      expect(room.disposeCalls, 1);
    },
  );

  test(
    'late preview cleanup failure after dispose is contained without notification',
    () async {
      final reports = _captureFlutterReports();
      final uncaught = <Object>[];
      final h = _Harness();
      final creation = _Gate<LocalVideoTrack>();
      h.previewGate = creation;
      final preparing = h.adapter.preparePreview(videoEnabled: true);
      await creation.entered.future;
      runZonedGuarded<void>(() {
        h.adapter.dispose();
      }, (error, _) => uncaught.add(error));
      final notifications = h.notifications;
      final track = _Track()..disposeGate = _Gate<void>();
      creation.result.complete(track);
      await track.disposeGate!.entered.future;
      track.disposeGate!.result.completeError(
        _rawCleanupError(),
        _rawCleanupStack(),
      );
      await preparing;
      await pumpEventQueue();
      expect(uncaught, isEmpty);
      expect(reports, hasLength(1));
      _expectRedactedCleanupReport(reports.single);
      expect(h.notifications, notifications);
      expect(h.adapter.localVideo, isNull);
      expect(track.disposeCalls, 1);
    },
  );

  test(
    'dispose observes pending release without falsely resolving its failure',
    () async {
      final reports = _captureFlutterReports();
      final h = _Harness();
      await h.connect();
      final room = h.rooms.single..disconnectGate = _Gate<void>();
      final raw = _rawCleanupError();
      final releasing = h.adapter.release();
      final expectation = expectLater(releasing, throwsA(same(raw)));
      await room.disconnectGate!.entered.future;
      h.adapter.dispose();
      final notifications = h.notifications;
      room.disconnectGate!.result.completeError(raw, _rawCleanupStack());
      await expectation;
      await pumpEventQueue();
      expect(h.adapter.release(), same(releasing));
      await expectLater(h.adapter.release(), throwsA(same(raw)));
      expect(reports, hasLength(1));
      _expectRedactedCleanupReport(reports.single);
      expect(h.notifications, notifications);
      expect(room.disposeCalls, 1);
    },
  );

  test(
    'dispose contains synchronous release failure with redacted FlutterError',
    () async {
      final reports = _captureFlutterReports();
      final uncaught = <Object>[];
      final raw = _rawCleanupError();
      final adapter = _SynchronousReleaseFailureAdapter(
        raw,
        _rawCleanupStack(),
      );
      runZonedGuarded<void>(() {
        adapter.dispose();
      }, (error, _) => uncaught.add(error));
      await pumpEventQueue();
      expect(uncaught, isEmpty);
      expect(reports, hasLength(1));
      _expectRedactedCleanupReport(reports.single);
      expect(() => adapter.release(), throwsA(same(raw)));
    },
  );

  test('successful dispose cleanup emits no error report', () async {
    final reports = _captureFlutterReports();
    final h = _Harness();
    await h.connect();
    h.adapter.dispose();
    final notifications = h.notifications;
    await h.adapter.release();
    await pumpEventQueue();
    expect(reports, isEmpty);
    expect(h.notifications, notifications);
    expect(h.rooms.single.activeResources, 0);
  });

  test(
    'late preview success after release disposes without restoring state',
    () async {
      final h = _Harness();
      final creation = _Gate<LocalVideoTrack>();
      h.previewGate = creation;
      final preparation = h.adapter.preparePreview(videoEnabled: true);
      await creation.entered.future;
      final releasing = h.adapter.release();
      var released = false;
      releasing.then((_) => released = true);
      await Future<void>.value();
      expect(released, isFalse);
      final before = h.snapshot;
      final track = _Track();
      creation.result.complete(track);
      await Future.wait([preparation, releasing]);
      expect(track.disposeCalls, 1);
      expect(h.snapshot, before);
    },
  );

  test('late preview failure after release does not publish failure', () async {
    final h = _Harness();
    final creation = _Gate<LocalVideoTrack>();
    h.previewGate = creation;
    final preparation = h.adapter.preparePreview(videoEnabled: true);
    await creation.entered.future;
    final releasing = h.adapter.release();
    final before = h.snapshot;
    creation.result.completeError(StateError('camera failed'));
    await Future.wait([preparation, releasing]);
    expect(h.snapshot, before);
    expect(h.adapter.safeFailureMessage, isNull);
  });

  test(
    'new preview owns track when older camera creation completes last',
    () async {
      final h = _Harness();
      final oldCreation = _Gate<LocalVideoTrack>();
      h.previewGate = oldCreation;
      final oldPreparation = h.adapter.preparePreview(videoEnabled: true);
      await oldCreation.entered.future;
      final newCreation = _Gate<LocalVideoTrack>();
      h.previewGate = newCreation;
      final newPreparation = h.adapter.preparePreview(videoEnabled: true);
      await newCreation.entered.future;
      final newTrack = _Track();
      newCreation.result.complete(newTrack);
      await newPreparation;
      final before = h.snapshot;
      final oldTrack = _Track();
      oldCreation.result.complete(oldTrack);
      await oldPreparation;
      expect(oldTrack.disposeCalls, 1);
      expect(newTrack.disposeCalls, 0);
      expect(
        (h.adapter.localVideo as LiveKitVideoTrackHandle).track,
        same(newTrack),
      );
      expect(h.snapshot, before);
      await h.adapter.release();
      expect(newTrack.disposeCalls, 1);
    },
  );

  test('connect invalidates pending preview creation', () async {
    final h = _Harness();
    final creation = _Gate<LocalVideoTrack>();
    h.previewGate = creation;
    final preparation = h.adapter.preparePreview(videoEnabled: true);
    await creation.entered.future;
    await h.connect();
    final before = h.snapshot;
    final track = _Track();
    creation.result.complete(track);
    await preparation;
    expect(track.disposeCalls, 1);
    expect(h.snapshot, before);
    await h.adapter.release();
  });

  test('release during preview disposal prevents room construction', () async {
    final h = _Harness();
    final track = _Track();
    h.previewTrack = track;
    await h.adapter.preparePreview(videoEnabled: true);
    track.disposeGate = _Gate<void>();
    final joining = h.connect();
    await track.disposeGate!.entered.future;
    var released = false;
    final releasing = h.adapter.release().then((_) => released = true);
    await Future<void>.value();
    expect(released, isFalse);
    track.disposeGate!.result.complete();
    await Future.wait([joining, releasing]);
    expect(h.factoryCalls, 0);
    expect(track.disposeCalls, 1);
    expect(h.adapter.localVideo, isNull);
  });

  test(
    'release from connecting notification prevents SDK construction',
    () async {
      final h = _Harness();
      Future<void>? releasing;
      h.adapter.addListener(() {
        if (h.adapter.connectionState == RtcConnectionState.connecting) {
          releasing = h.adapter.release();
        }
      });
      await h.connect();
      await releasing;
      expect(h.factoryCalls, 0);
      expect(h.adapter.localVideo, isNull);
    },
  );

  test(
    'normal preview preserves capture options and disposes exactly once',
    () async {
      final h = _Harness();
      final track = _Track();
      h.previewTrack = track;
      await h.adapter.preparePreview(videoEnabled: true);
      expect(h.previewOptions!.cameraPosition, CameraPosition.front);
      expect(h.previewOptions!.maxFrameRate, 24);
      expect(h.previewOptions!.params.dimensions.width, 640);
      expect(h.previewOptions!.params.dimensions.height, 360);
      expect(
        (h.adapter.localVideo as LiveKitVideoTrackHandle).track,
        same(track),
      );
      expect(h.adapter.connectionState, RtcConnectionState.previewing);
      await h.adapter.preparePreview(videoEnabled: false);
      expect(track.disposeCalls, 1);
      expect(h.adapter.localVideo, isNull);
      await h.adapter.release();
      expect(track.disposeCalls, 1);
    },
  );

  test(
    'current room reconnect callbacks still update connection state',
    () async {
      final h = _Harness();
      await h.connect();
      final listener = h.rooms.single.listener;
      await listener.fire<RoomReconnectingEvent>(RoomReconnectingEvent());
      expect(h.adapter.connectionState, RtcConnectionState.reconnecting);
      await listener.fire<RoomReconnectedEvent>(RoomReconnectedEvent());
      expect(h.adapter.connectionState, RtcConnectionState.connected);
      await listener.fire<RoomDisconnectedEvent>(RoomDisconnectedEvent());
      expect(h.adapter.connectionState, RtcConnectionState.disconnected);
      await h.adapter.release();
    },
  );

  test(
    'release during old room cleanup prevents replacement construction',
    () async {
      final h = _Harness();
      await h.connect();
      final old = h.rooms.single;
      old.disconnectGate = _Gate<void>();
      final joining = h.connect();
      await old.disconnectGate!.entered.future;
      var released = false;
      final releasing = h.adapter.release().then((_) => released = true);
      expect(released, isFalse);
      old.disconnectGate!.result.complete();
      await Future.wait([joining, releasing]);
      expect(h.factoryCalls, 1);
      expect(old.listener.disposeCalls, 1);
      expect(old.disposeCalls, 1);
    },
  );

  for (final fails in [false, true]) {
    test(
      'release during SDK connect ignores late ${fails ? 'failure' : 'success'}',
      () async {
        final h = _Harness();
        final room = _Room(h.calls)..connectGate = _Gate<void>();
        h.nextRoom = room;
        final joining = h.connect();
        await room.connectGate!.entered.future;
        final releasing = h.adapter.release();
        await room.disconnected.future;
        var released = false;
        releasing.then((_) => released = true);
        expect(released, isFalse);
        expect(room.disposeCalls, 0);
        final before = h.snapshot;
        if (fails) {
          room.connectGate!.result.completeError(StateError('connect failed'));
        } else {
          room.connectGate!.result.complete();
        }
        await Future.wait([joining, releasing]);
        expect(h.snapshot, before);
        expect(h.calls, isNot(contains('microphone')));
        expect(h.calls, isNot(contains('camera')));
        expect(h.calls, isNot(contains('speaker')));
        expect(room.disconnectCalls, 2);
        expect(room.disposeCalls, 1);
        expect(room.listener.disposeCalls, 1);
        expect(room.activeResources, 0);
      },
    );
  }

  test('disconnect during connect drains old room before reconnect', () async {
    final h = _Harness();
    final old = _Room(h.calls)..connectGate = _Gate<void>();
    h.nextRoom = old;
    final joining = h.connect();
    await old.connectGate!.entered.future;

    final disconnecting = h.adapter.disconnect();
    await old.disconnected.future;
    old.connectGate!.result.complete();
    await Future.wait([joining, disconnecting]);

    expect(old.disposeCalls, 1);
    await h.connect();
    expect(h.rooms, hasLength(2));
    expect(h.rooms.last.connectCalls, 1);
    await h.adapter.release();
  });

  for (final stage in ['microphone', 'camera', 'speaker']) {
    test(
      'release during $stage prevents later stages and state commit',
      () async {
        final h = _Harness();
        final room = _Room(h.calls);
        final gate = _Gate<void>();
        if (stage == 'microphone') room.participant.microphoneGate = gate;
        if (stage == 'camera') room.participant.cameraGate = gate;
        if (stage == 'speaker') h.speakerGate = gate;
        h.nextRoom = room;
        final joining = h.connect();
        await gate.entered.future;
        final releasing = h.adapter.release();
        var released = false;
        releasing.then((_) => released = true);
        await Future<void>.value();
        expect(released, isFalse);
        expect(room.disposeCalls, 0);
        await room.disconnected.future;
        expect(room.disconnectCalls, 1);
        final before = h.snapshot;
        gate.result.complete();
        await Future.wait([joining, releasing]);
        expect(h.snapshot, before);
        if (stage == 'microphone') expect(h.calls, isNot(contains('camera')));
        if (stage != 'speaker') expect(h.calls, isNot(contains('speaker')));
        expect(room.activeResources, 0);
      },
    );
  }

  test('concurrent connects before first await create only one room', () async {
    final h = _Harness();
    final room = _Room(h.calls)..connectGate = _Gate<void>();
    h.nextRoom = room;
    final first = h.connect();
    final second = h.connect();
    await room.connectGate!.entered.future;
    await second;
    expect(h.factoryCalls, 1);
    expect(room.connectCalls, 1);
    room.connectGate!.result.complete();
    await first;
    await h.adapter.release();
  });

  for (final fails in [false, true]) {
    test(
      'queued audio publish reactivation is explicitly stopped after ${fails ? 'failure' : 'success'}',
      () async {
        final h = _Harness();
        final room = _Room(h.calls);
        room.participant.microphoneGate = _Gate<void>();
        room.participant.audioStartedGate = _Gate<void>();
        room.participant.failAudioPublish = fails;
        h.nextRoom = room;
        final joining = h.connect();
        await room.participant.microphoneGate!.entered.future;
        final track = h.microphones.single;
        final releasing = h.adapter.release();
        var released = false;
        releasing.then((_) => released = true);
        await room.disconnected.future;
        await track.stopped.future;
        expect(track.active, isFalse);
        expect(track.startCalls, 0);
        // Simulate SDK-side disposal before its queued publish resumes. This
        // is not adapter capture cleanup: dispose will now be a no-op.
        await track.dispose();
        expect(track.disposed, isTrue);
        final initialStops = track.stopCalls;
        room.participant.microphoneGate!.result.complete();
        await room.participant.audioStartedGate!.entered.future;
        expect(track.startCalls, 1);
        expect(track.reactivatedAfterStop, isTrue);
        expect(track.active, isTrue);
        expect(track.disposed, isTrue);
        expect(room.engineActive, isFalse);
        expect(released, isFalse);
        expect(room.disposeCalls, 0);
        room.participant.audioStartedGate!.result.complete();
        await Future.wait([joining, releasing]);
        expect(track.stopCalls, greaterThan(initialStops));
        expect(track.active, isFalse);
        expect(track.disposed, isTrue);
        expect(track.disposeCalls, 1);
        expect(room.activeResources, 0);
        expect(h.calls, isNot(contains('camera')));
        expect(h.calls, isNot(contains('speaker')));
      },
    );
  }

  test(
    'release waits for late camera allocation and its final disposal',
    () async {
      final h = _Harness();
      final room = _Room(h.calls);
      h.cameraCreationGate = _Gate<LocalVideoTrack>();
      final track = _Track()..disposeGate = _Gate<void>();
      h.nextRoom = room;
      final joining = h.connect();
      await h.cameraCreationGate!.entered.future;
      final releasing = h.adapter.release();
      var released = false;
      releasing.then((_) => released = true);
      await room.disconnected.future;
      expect(room.disconnectCalls, 1);
      expect(room.disposeCalls, 0);
      h.cameraCreationGate!.result.complete(track);
      await track.disposeGate!.entered.future;
      expect(released, isFalse);
      expect(track.active, isFalse);
      expect(h.calls, isNot(contains('camera')));
      track.disposeGate!.result.complete();
      await Future.wait([joining, releasing]);
      expect(room.activeResources, 0);
      expect(room.disposeCalls, 1);
      expect(h.adapter.localVideo, isNull);
      expect(track.disposeCalls, 1);
    },
  );

  test(
    'failed SDK publication disposes owned capture and release succeeds',
    () async {
      final h = _Harness();
      final room = _Room(h.calls);
      room.participant.cameraGate = _Gate<void>();
      room.participant.failVideoPublish = true;
      h.nextRoom = room;
      final joining = h.connect();
      await room.participant.cameraGate!.entered.future;
      final releasing = h.adapter.release();
      room.participant.cameraGate!.result.complete();
      await Future.wait([joining, releasing]);
      expect(room.disposeCalls, 1);
      expect(room.participant.activeResources, 0);
      expect(h.cameras.single.disposeCalls, 1);
      expect(h.cameras.single.active, isFalse);
      expect(room.engineActive, isFalse);
      expect(room.nativeAudioActive, isFalse);
    },
  );

  test('late preview disposal failure rejects release cleanup proof', () async {
    final h = _Harness();
    final creation = _Gate<LocalVideoTrack>();
    h.previewGate = creation;
    final preparation = h.adapter.preparePreview(videoEnabled: true);
    await creation.entered.future;
    final releasing = h.adapter.release();
    final expectation = expectLater(releasing, throwsStateError);
    final track = _Track()..disposeGate = _Gate<void>();
    creation.result.complete(track);
    await track.disposeGate!.entered.future;
    track.disposeGate!.result.completeError(
      StateError('track disposal failed'),
    );
    await preparation;
    await expectation;
    expect(track.active, isTrue);
    expect(h.adapter.localVideo, isNull);
  });

  for (final source in ['microphone', 'camera']) {
    test(
      'late $source creation after revocation disposes without publication',
      () async {
        final h = _Harness();
        final audioGate = _Gate<LocalAudioTrack>();
        final videoGate = _Gate<LocalVideoTrack>();
        if (source == 'microphone') {
          h.microphoneCreationGate = audioGate;
        } else {
          h.cameraCreationGate = videoGate;
        }
        final joining = h.connect();
        await (source == 'microphone'
            ? audioGate.entered.future
            : videoGate.entered.future);
        final releasing = h.adapter.release();
        final room = h.rooms.single;
        await room.disconnected.future;
        final before = h.snapshot;
        final audio = _AudioTrack();
        final video = _Track();
        if (source == 'microphone') {
          audioGate.result.complete(audio);
        } else {
          videoGate.result.complete(video);
        }
        await Future.wait([joining, releasing]);
        expect(h.snapshot, before);
        expect(h.calls, isNot(contains(source)));
        if (source == 'microphone') {
          expect(audio.disposeCalls, 1);
          expect(audio.active, isFalse);
          expect(h.cameras, isEmpty);
        } else {
          expect(video.disposeCalls, 1);
          expect(video.active, isFalse);
        }
        expect(room.activeResources, 0);
      },
    );

    test(
      'active $source publish failure disposes owned capture and release succeeds',
      () async {
        final h = _Harness();
        final room = _Room(h.calls);
        room.participant.failAudioPublish = source == 'microphone';
        room.participant.failVideoPublish = source == 'camera';
        h.nextRoom = room;
        await expectLater(h.connect(), throwsStateError);
        expect(h.adapter.connectionState, RtcConnectionState.failed);
        if (source == 'microphone') {
          expect(h.microphones.single.disposeCalls, 1);
          expect(h.microphones.single.active, isFalse);
        } else {
          expect(h.cameras.single.disposeCalls, 1);
          expect(h.cameras.single.active, isFalse);
        }
        await h.adapter.release();
        expect(room.activeResources, 0);
      },
    );

    test('$source creation failure permits successful release', () async {
      final h = _Harness();
      final audioGate = _Gate<LocalAudioTrack>();
      final videoGate = _Gate<LocalVideoTrack>();
      if (source == 'microphone') {
        h.microphoneCreationGate = audioGate;
      } else {
        h.cameraCreationGate = videoGate;
      }
      final joining = h.connect();
      final expectation = expectLater(joining, throwsStateError);
      await (source == 'microphone'
          ? audioGate.entered.future
          : videoGate.entered.future);
      if (source == 'microphone') {
        audioGate.result.completeError(StateError('capture denied'));
      } else {
        videoGate.result.completeError(StateError('capture denied'));
      }
      await expectation;
      await h.adapter.release();
      expect(h.calls, isNot(contains(source)));
      expect(h.rooms.single.activeResources, 0);
    });
  }

  test('media toggles re-enable with fresh adapter-owned capture', () async {
    final h = _Harness();
    await h.connect();
    final firstAudio = h.microphones.single;
    final firstVideo = h.cameras.single;
    await h.adapter.setMicrophoneEnabled(false);
    await h.adapter.setCameraEnabled(false);
    expect(firstAudio.active, isFalse);
    expect(firstVideo.active, isFalse);
    await h.adapter.setMicrophoneEnabled(true);
    await h.adapter.setCameraEnabled(true);
    expect(h.microphones.length, 2);
    expect(h.cameras.length, 2);
    expect(h.microphones.last, isNot(same(firstAudio)));
    expect(h.cameras.last, isNot(same(firstVideo)));
    expect(h.adapter.microphoneEnabled, isTrue);
    expect(h.adapter.cameraEnabled, isTrue);
    await h.adapter.release();
    expect(h.rooms.single.activeResources, 0);
  });

  test('concurrent camera enables serialize to one owned capture', () async {
    final h = _Harness();
    await h.connect(cameraEnabled: false);
    h.cameraCreationGate = _Gate<LocalVideoTrack>();
    final first = h.adapter.setCameraEnabled(true);
    final second = h.adapter.setCameraEnabled(true);
    await h.cameraCreationGate!.entered.future;
    h.cameraCreationGate!.result.complete(_Track());
    await Future.wait([first, second]);
    expect(h.cameras.length, 1);
    expect(h.calls.where((call) => call == 'camera').length, 1);
    await h.adapter.release();
  });

  test(
    'join grant cannot be bypassed by enabling camera or microphone',
    () async {
      final h = _Harness();
      await h.connect(microphoneAllowed: false, cameraAllowed: false);
      expect(h.adapter.microphoneEnabled, isFalse);
      expect(h.adapter.cameraEnabled, isFalse);

      await expectLater(
        h.adapter.setMicrophoneEnabled(true),
        throwsA(isA<StateError>()),
      );
      await expectLater(
        h.adapter.setCameraEnabled(true),
        throwsA(isA<StateError>()),
      );

      expect(h.microphones, isEmpty);
      expect(h.cameras, isEmpty);
      expect(h.calls, isNot(contains('microphone')));
      expect(h.calls, isNot(contains('camera')));
      await h.adapter.release();
    },
  );

  test(
    'externally unpublished camera is replaced with fresh owned capture',
    () async {
      final h = _Harness();
      await h.connect();
      final participant = h.rooms.single.participant;
      final original = h.cameras.single;
      await participant.removePublishedTrack(participant.video.single.sid);
      await h.adapter.setCameraEnabled(true);
      expect(h.cameras.length, 2);
      expect(h.cameras.last, isNot(same(original)));
      expect(h.adapter.cameraEnabled, isTrue);
      await h.adapter.release();
      expect(participant.activeResources, 0);
    },
  );

  test(
    'release cleans SDK publication outside adapter capture registry',
    () async {
      final h = _Harness();
      await h.connect(cameraEnabled: false);
      final room = h.rooms.single;
      final external = _Track();
      await room.participant.publishVideoTrack(external);

      await h.adapter.release();

      expect(external.stopCalls, 1);
      expect(external.disposeCalls, 1);
      expect(external.active, isFalse);
      expect(room.activeResources, 0);
      expect(room.disposeCalls, 1);
    },
  );

  test(
    'owned capture disposal failure rejects release after failed publish',
    () async {
      final h = _Harness();
      final room = _Room(h.calls);
      room.participant.failVideoPublish = true;
      room.participant.cameraGate = _Gate<void>();
      h.nextRoom = room;
      h.cameraCreationGate = _Gate<LocalVideoTrack>();
      final joining = h.connect();
      await h.cameraCreationGate!.entered.future;
      final track = _Track()..disposeGate = _Gate<void>();
      h.cameraCreationGate!.result.complete(track);
      await room.participant.cameraGate!.entered.future;
      final releasing = h.adapter.release();
      final expectation = expectLater(releasing, throwsStateError);
      room.participant.cameraGate!.result.complete();
      await track.disposeGate!.entered.future;
      track.disposeGate!.result.completeError(
        StateError('owned disposal failed'),
      );
      await joining;
      await expectation;
      expect(track.disposeCalls, 1);
      expect(room.disposeCalls, 1);
    },
  );

  test('concurrent connect during old cleanup is ignored', () async {
    final h = _Harness();
    await h.connect();
    final old = h.rooms.single..disconnectGate = _Gate<void>();
    final first = h.connect();
    await old.disconnectGate!.entered.future;
    await h.connect();
    expect(h.factoryCalls, 1);
    old.disconnectGate!.result.complete();
    await first;
    expect(h.factoryCalls, 2);
    expect(h.rooms.last.connectCalls, 1);
    await h.adapter.release();
  });

  test(
    'captured old callbacks cannot mutate replacement or released adapter',
    () async {
      final h = _Harness();
      await h.connect();
      final old = h.rooms.single;
      final notifier = old.callbacks.single;
      await h.connect();
      final replacement = h.rooms.last;
      final before = h.snapshot;
      await old.fireRetainedEvents();
      notifier();
      expect(h.snapshot, before);
      expect(old.listener.disposeCalls, 1);
      expect(replacement.listener.disposeCalls, 0);
      expect(replacement.disposeCalls, 0);
      await h.adapter.release();
      final released = h.snapshot;
      await old.fireRetainedEvents();
      notifier();
      await replacement.fireRetainedEvents();
      expect(h.snapshot, released);
    },
  );

  test('reconnect waits for old room cleanup to finish', () async {
    final h = _Harness();
    await h.connect();
    final old = h.rooms.single..disconnectGate = _Gate<void>();
    final disconnecting = h.adapter.disconnect();
    await old.disconnectGate!.entered.future;
    final reconnecting = h.connect();
    await Future<void>.value();
    expect(h.factoryCalls, 1);
    expect(old.disposeCalls, 0);
    old.disconnectGate!.result.complete();
    await Future.wait([disconnecting, reconnecting]);
    final replacement = h.rooms.last;
    expect(h.factoryCalls, 2);
    expect(old.listener.disposeCalls, 1);
    expect(old.disposeCalls, 1);
    expect(replacement.listener.disposeCalls, 0);
    expect(replacement.disposeCalls, 0);
    await h.adapter.release();
    expect(replacement.disposeCalls, 1);
  });

  test(
    'camera cannot reactivate while disconnect cleanup is pending',
    () async {
      final h = _Harness();
      await h.connect();
      final room = h.rooms.single..disconnectGate = _Gate<void>();
      final track = h.cameras.single;
      final disconnecting = h.adapter.disconnect();
      await room.disconnectGate!.entered.future;

      await h.adapter.setCameraEnabled(true);
      expect(h.cameras, hasLength(1));
      expect(track.active, isFalse);

      room.disconnectGate!.result.complete();
      await disconnecting;
      expect(h.adapter.connectionState, RtcConnectionState.disconnected);
      expect(h.cameras, hasLength(1));
      await h.adapter.release();
    },
  );

  test('active connect failure cleans resources and permits retry', () async {
    final h = _Harness();
    final room = _Room(h.calls)..connectGate = _Gate<void>();
    h.nextRoom = room;
    final joining = h.connect();
    final expectation = expectLater(joining, throwsStateError);
    await room.connectGate!.entered.future;
    room.connectGate!.result.completeError(StateError('connect failed'));
    await expectation;
    expect(h.adapter.connectionState, RtcConnectionState.failed);
    expect(
      h.adapter.safeFailureMessage,
      'Could not connect to the consultation.',
    );
    expect(room.disconnectCalls, 1);
    expect(room.disposeCalls, 1);
    await h.connect();
    expect(h.adapter.connectionState, RtcConnectionState.connected);
    await h.adapter.release();
  });

  test(
    'disconnect failure still disposes captured room and listener',
    () async {
      final h = _Harness();
      await h.connect();
      final room = h.rooms.single..disconnectGate = _Gate<void>();
      final releasing = h.adapter.release();
      final expectation = expectLater(releasing, throwsStateError);
      await room.disconnectGate!.entered.future;
      room.disconnectGate!.result.completeError(
        StateError('disconnect failed'),
      );
      await expectation;
      expect(room.listener.disposeCalls, 1);
      expect(room.disposeCalls, 1);
      expect(h.adapter.release(), same(releasing));
    },
  );

  test(
    'listener disposal failure still disconnects and disposes captured room',
    () async {
      final h = _Harness();
      await h.connect();
      final room = h.rooms.single;
      room.listener.disposeGate = _Gate<void>();
      final releasing = h.adapter.release();
      final expectation = expectLater(releasing, throwsStateError);
      await room.listener.disposeGate!.entered.future;
      room.listener.disposeGate!.result.completeError(
        StateError('listener failed'),
      );
      await expectation;
      expect(room.listener.disposeCalls, 1);
      expect(room.disconnectCalls, 1);
      expect(room.disposeCalls, 1);
    },
  );

  test(
    'stop and unpublish failures do not skip later cleanup attempts',
    () async {
      final h = _Harness();
      await h.connect();
      final room = h.rooms.single;
      final camera = h.cameras.single..failStop = true;
      room.participant.unpublishFailuresRemaining = 2;

      await expectLater(h.adapter.release(), throwsStateError);

      expect(room.listener.disposeCalls, 1);
      expect(room.disconnectCalls, 1);
      expect(room.disposeCalls, 1);
      expect(camera.disposeCalls, 1);
      expect(camera.active, isFalse);
      expect(room.activeResources, 0);
    },
  );

  for (final stage in ['microphone', 'camera', 'speaker']) {
    test(
      'late $stage control completion after release cannot mutate state',
      () async {
        final h = _Harness();
        await h.connect();
        final gate = _Gate<void>();
        final participant = h.rooms.single.participant;
        late final Future<void> control;
        if (stage == 'microphone') {
          participant.microphoneGate = gate;
          control = h.adapter.setMicrophoneEnabled(false);
        } else if (stage == 'camera') {
          participant.cameraGate = gate;
          control = h.adapter.setCameraEnabled(false);
        } else {
          h.speakerGate = gate;
          control = h.adapter.setSpeakerEnabled(false);
        }
        await gate.entered.future;
        final releasing = h.adapter.release();
        var released = false;
        releasing.then((_) => released = true);
        await Future<void>.value();
        expect(released, isFalse);
        final before = h.snapshot;
        gate.result.complete();
        await Future.wait([control, releasing]);
        expect(h.snapshot, before);
        expect(h.rooms.single.activeResources, 0);
      },
    );
  }

  test(
    'normal connect preserves SDK options and grant media restrictions',
    () async {
      final h = _Harness();
      await h.connect(microphoneAllowed: false, cameraAllowed: false);
      final options = h.options!;
      expect(options.adaptiveStream, isTrue);
      expect(options.dynacast, isTrue);
      expect(options.defaultCameraCaptureOptions.maxFrameRate, 24);
      expect(options.defaultCameraCaptureOptions.params.dimensions.width, 640);
      expect(options.defaultCameraCaptureOptions.params.dimensions.height, 360);
      expect(options.defaultVideoPublishOptions.simulcast, isTrue);
      expect(options.defaultAudioOutputOptions.speakerOn, isTrue);
      expect(h.calls, ['connect', 'speaker']);
      expect(h.cameras, isEmpty);
      expect(h.microphones, isEmpty);
      expect(h.rooms.single.participant.microphoneValue, isFalse);
      expect(h.rooms.single.participant.cameraValue, isFalse);
      expect(h.rooms.single.url, 'wss://rtc.example.invalid');
      expect(h.rooms.single.token, 'synthetic-test-token');
      expect(h.adapter.connectionState, RtcConnectionState.connected);
      expect(h.adapter.safeFailureMessage, isNull);
      final releasing = h.adapter.release();
      expect(h.adapter.release(), same(releasing));
      await releasing;
      final before = h.snapshot;
      await h.connect();
      await h.adapter.preparePreview(videoEnabled: true);
      await h.adapter.setMicrophoneEnabled(false);
      await h.adapter.setCameraEnabled(false);
      await h.adapter.setSpeakerEnabled(false);
      await h.adapter.switchCamera();
      await h.adapter.disconnect();
      expect(h.snapshot, before);
      expect(h.factoryCalls, 1);
    },
  );
}

List<FlutterErrorDetails> _captureFlutterReports() {
  final previous = FlutterError.onError;
  final reports = <FlutterErrorDetails>[];
  FlutterError.onError = reports.add;
  addTearDown(() {
    FlutterError.onError = previous;
  });
  return reports;
}

StateError _rawCleanupError() => StateError(
  'synthetic-sdk-secret-token wss://private-rtc.example.invalid room-secret-id',
);

StackTrace _rawCleanupStack() =>
    StackTrace.fromString('synthetic-stack-token-frame');

void _expectRedactedCleanupReport(FlutterErrorDetails details) {
  expect(details.exception, isA<FlutterError>());
  expect(
    details.exceptionAsString(),
    'RTC media cleanup failed; completion could not be verified.',
  );
  expect(details.library, 'CareNet RTC adapter');
  expect(
    details.context?.toDescription(),
    'while releasing disposed consultation media',
  );
  expect(details.stack, isNull);
  expect(details.informationCollector, isNull);
  final diagnostic = details.toDiagnosticsNode().toStringDeep();
  for (final marker in [
    'synthetic-sdk-secret-token',
    'private-rtc.example.invalid',
    'room-secret-id',
    'synthetic-stack-token-frame',
  ]) {
    expect(diagnostic, isNot(contains(marker)));
  }
}

class _SynchronousReleaseFailureAdapter extends LiveKitRtcRoomAdapter {
  _SynchronousReleaseFailureAdapter(this.error, this.stack);
  final Object error;
  final StackTrace stack;
  @override
  Future<void> release() => Error.throwWithStackTrace(error, stack);
}

class _Gate<T> {
  final entered = Completer<void>();
  final result = Completer<T>();

  Future<T> wait() {
    if (!entered.isCompleted) entered.complete();
    return result.future;
  }
}

class _Harness {
  _Harness() {
    adapter = LiveKitRtcRoomAdapter(
      roomFactory: (value) {
        options = value;
        factoryCalls++;
        final room = nextRoom ?? _Room(calls);
        nextRoom = null;
        rooms.add(room);
        return room;
      },
      cameraTrackFactory: (value) async {
        previewOptions = value;
        final state = adapter.connectionState;
        if (state == RtcConnectionState.connecting ||
            state == RtcConnectionState.connected ||
            state == RtcConnectionState.reconnecting) {
          final track =
              cameraCreationGate == null
                  ? _Track()
                  : await cameraCreationGate!.wait();
          cameras.add(track as _Track);
          return track;
        }
        return previewGate == null ? previewTrack! : await previewGate!.wait();
      },
      microphoneTrackFactory: (value) async {
        microphoneOptions = value;
        final track =
            microphoneCreationGate == null
                ? _AudioTrack()
                : await microphoneCreationGate!.wait();
        microphones.add(track as _AudioTrack);
        return track;
      },
      setSpeakerOutputPreferred: (enabled) async {
        calls.add('speaker');
        if (speakerGate != null) await speakerGate!.wait();
      },
    );
    adapter.addListener(() => notifications++);
  }

  late final LiveKitRtcRoomAdapter adapter;
  final calls = <String>[];
  final rooms = <_Room>[];
  _Room? nextRoom;
  RoomOptions? options;
  CameraCaptureOptions? previewOptions;
  AudioCaptureOptions? microphoneOptions;
  final cameras = <_Track>[];
  final microphones = <_AudioTrack>[];
  _Track? previewTrack;
  _Gate<LocalVideoTrack>? previewGate;
  _Gate<LocalVideoTrack>? cameraCreationGate;
  _Gate<LocalAudioTrack>? microphoneCreationGate;
  _Gate<void>? speakerGate;
  int factoryCalls = 0;
  int notifications = 0;

  List<Object?> get snapshot => [
    adapter.connectionState,
    adapter.localVideo,
    adapter.remoteVideo,
    adapter.microphoneEnabled,
    adapter.cameraEnabled,
    adapter.speakerEnabled,
    adapter.remoteParticipantPresent,
    adapter.remoteMicrophoneEnabled,
    adapter.remoteCameraEnabled,
    adapter.safeFailureMessage,
    notifications,
  ];

  Future<void> connect({
    bool microphoneAllowed = true,
    bool cameraAllowed = true,
    bool microphoneEnabled = true,
    bool cameraEnabled = true,
  }) => adapter.connect(
    grant: ConsultationJoinGrant(
      provider: 'livekit',
      serverUrl: Uri.parse('wss://rtc.example.invalid'),
      token: 'synthetic-test-token',
      expiresAt: DateTime.utc(2030),
      participantRole: ConsultationParticipantRole.patient,
      microphoneAllowed: microphoneAllowed,
      cameraAllowed: cameraAllowed,
      sessionId: 'synthetic-session',
      replacedPriorDevice: false,
    ),
    microphoneEnabled: microphoneEnabled,
    cameraEnabled: cameraEnabled,
  );
}

class _Room implements Room {
  _Room(this.calls) : participant = _Participant(calls);

  final List<String> calls;
  final _Participant participant;
  final listener = _Listener();
  final callbacks = <void Function()>[];
  final disconnected = Completer<void>();
  LocalParticipant? _attachedParticipant;
  bool nativeAudioActive = false;
  bool engineActive = false;
  bool _disposed = false;
  int get activeResources =>
      (nativeAudioActive ? 1 : 0) +
      (engineActive ? 1 : 0) +
      participant.activeResources;
  _Gate<void>? connectGate;
  _Gate<void>? disconnectGate;
  int connectCalls = 0;
  int disconnectCalls = 0;
  int disposeCalls = 0;
  String? url;
  String? token;

  @override
  LocalParticipant? get localParticipant => _attachedParticipant;
  @override
  UnmodifiableMapView<String, RemoteParticipant> get remoteParticipants =>
      UnmodifiableMapView(<String, RemoteParticipant>{});
  @override
  void addListener(void Function() callback) => callbacks.add(callback);
  @override
  void removeListener(void Function() callback) => callbacks.remove(callback);
  @override
  EventsListener<RoomEvent> createListener({bool synchronized = false}) =>
      listener;
  @override
  Future<void> connect(
    String url,
    String token, {
    ConnectOptions? connectOptions,
    RoomOptions? roomOptions,
    FastConnectOptions? fastConnectOptions,
  }) async {
    this.url = url;
    this.token = token;
    connectCalls++;
    calls.add('connect');
    // SDK connect may allocate after an early disconnect, even on failure.
    try {
      if (connectGate != null) await connectGate!.wait();
    } finally {
      nativeAudioActive = true;
      engineActive = true;
      _attachedParticipant = participant;
    }
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
    if (!disconnected.isCompleted) disconnected.complete();
    if (disconnectGate != null) await disconnectGate!.wait();
    await participant.unpublishAllTracks();
    _attachedParticipant = null;
    engineActive = false;
    nativeAudioActive = false;
  }

  @override
  Future<bool> dispose() async {
    disposeCalls++;
    if (_disposed) return false;
    _disposed = true;
    await participant.unpublishAllTracks();
    _attachedParticipant = null;
    engineActive = false;
    nativeAudioActive = false;
    return true;
  }

  Future<void> fireRetainedEvents() async {
    await listener.fire<RoomReconnectingEvent>(RoomReconnectingEvent());
    await listener.fire<RoomReconnectedEvent>(RoomReconnectedEvent());
    await listener.fire<RoomDisconnectedEvent>(RoomDisconnectedEvent());
    await listener.fire<ParticipantEvent>(_ParticipantEvent());
    await listener.fire<TrackSubscribedEvent>(_SubscribedEvent());
    await listener.fire<TrackUnsubscribedEvent>(_UnsubscribedEvent());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Participant implements LocalParticipant {
  _Participant(this.calls);
  final List<String> calls;
  _Gate<void>? microphoneGate;
  _Gate<void>? audioStartedGate;
  _Gate<void>? cameraGate;
  bool failVideoPublish = false;
  bool failAudioPublish = false;
  int unpublishFailuresRemaining = 0;
  bool microphoneValue = false;
  bool cameraValue = false;
  final audio = <LocalTrackPublication<LocalAudioTrack>>[];
  final video = <LocalTrackPublication<LocalVideoTrack>>[];
  final created = <_ResourceTrack>[];
  int get activeResources => created.where((track) => track.active).length;
  @override
  List<LocalTrackPublication<LocalAudioTrack>> get audioTrackPublications =>
      audio;
  @override
  List<LocalTrackPublication<LocalVideoTrack>> get videoTrackPublications =>
      video;
  @override
  Future<LocalTrackPublication<LocalAudioTrack>> publishAudioTrack(
    LocalAudioTrack track, {
    AudioPublishOptions? publishOptions,
  }) async {
    calls.add('microphone');
    created.add(track as _ResourceTrack);
    if (microphoneGate != null) await microphoneGate!.wait();
    await track.start();
    if (audioStartedGate != null) await audioStartedGate!.wait();
    if (failAudioPublish) throw StateError('audio publish failed');
    final publication = _Publication<LocalAudioTrack>(
      track,
      TrackSource.microphone,
    );
    audio.add(publication);
    microphoneValue = true;
    return publication;
  }

  @override
  Future<LocalTrackPublication<LocalVideoTrack>> publishVideoTrack(
    LocalVideoTrack track, {
    VideoPublishOptions? publishOptions,
  }) async {
    calls.add('camera');
    created.add(track as _ResourceTrack);
    if (cameraGate != null) await cameraGate!.wait();
    (track as _ResourceTrack).active = true;
    if (failVideoPublish) throw StateError('publish failed after capture');
    final publication = _Publication<LocalVideoTrack>(
      track,
      TrackSource.camera,
    );
    video.add(publication);
    cameraValue = true;
    return publication;
  }

  @override
  Future<void> removePublishedTrack(
    String trackSid, {
    bool notify = true,
  }) async {
    final publications = [...audio, ...video];
    for (final publication in publications) {
      if (publication.sid != trackSid) continue;
      audio.remove(publication);
      video.remove(publication);
      final isCamera = publication.source == TrackSource.camera;
      final gate = isCamera ? cameraGate : microphoneGate;
      if (gate != null) await gate.wait();
      await publication.track?.dispose();
      if (isCamera) {
        cameraValue = false;
      } else {
        microphoneValue = false;
      }
    }
  }

  @override
  Future<void> unpublishAllTracks({
    bool notify = true,
    bool? stopOnUnpublish,
  }) async {
    if (unpublishFailuresRemaining > 0) {
      unpublishFailuresRemaining--;
      throw StateError('unpublish failed');
    }
    for (final publication in [...audio, ...video]) {
      await removePublishedTrack(publication.sid, notify: notify);
    }
    audio.clear();
    video.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ResourceTrack {
  bool active = true;
  bool disposed = false;
}

class _Track extends _ResourceTrack implements LocalVideoTrack {
  int disposeCalls = 0;
  int stopCalls = 0;
  _Gate<void>? disposeGate;
  bool failStop = false;
  @override
  Future<bool> dispose() async {
    if (disposed) return false;
    disposeCalls++;
    if (disposeGate != null) await disposeGate!.wait();
    active = false;
    disposed = true;
    return true;
  }

  @override
  bool get muted => false;
  @override
  Future<bool> stop() async {
    stopCalls++;
    if (failStop) throw StateError('stop failed');
    active = false;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _AudioTrack extends _ResourceTrack implements LocalAudioTrack {
  int disposeCalls = 0;
  int stopCalls = 0;
  int startCalls = 0;
  bool reactivatedAfterStop = false;
  final stopped = Completer<void>();
  @override
  Future<bool> start() async {
    startCalls++;
    reactivatedAfterStop = stopCalls > 0;
    // SDK Track.start has no disposed guard.
    active = true;
    return true;
  }

  @override
  Future<bool> stop() async {
    stopCalls++;
    active = false;
    if (!stopped.isCompleted) stopped.complete();
    return true;
  }

  @override
  Future<bool> dispose() async {
    if (disposed) return false;
    disposeCalls++;
    active = false;
    disposed = true;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Publication<T extends LocalTrack> implements LocalTrackPublication<T> {
  _Publication(this.track, this.source);
  @override
  final T track;
  @override
  final TrackSource source;
  static int _nextSid = 0;
  @override
  final String sid = 'publication-${++_nextSid}';
  @override
  bool get muted => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Listener implements EventsListener<RoomEvent> {
  final callbacks = <Type, FutureOr<void> Function(dynamic)>{};
  int disposeCalls = 0;
  _Gate<void>? disposeGate;
  @override
  CancelListenFunc on<E>(
    FutureOr<void> Function(E) then, {
    bool Function(E)? filter,
  }) {
    callbacks[E] = (dynamic event) => then(event as E);
    return () async {};
  }

  Future<void> fire<E>(E event) async => await callbacks[E]!(event);
  @override
  Future<bool> dispose() async {
    disposeCalls++;
    if (disposeGate != null) await disposeGate!.wait();
    // Retain callbacks deliberately to simulate work captured before cancellation.
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ParticipantEvent implements ParticipantEvent {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SubscribedEvent implements TrackSubscribedEvent {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnsubscribedEvent implements TrackUnsubscribedEvent {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
