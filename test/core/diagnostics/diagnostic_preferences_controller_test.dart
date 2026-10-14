import 'dart:async';

import 'package:app_t/core/diagnostics/diagnostic_consent_store.dart';
import 'package:app_t/core/diagnostics/diagnostic_consent_tile.dart';
import 'package:app_t/core/diagnostics/diagnostic_preferences_controller.dart';
import 'package:app_t/core/diagnostics/release_health_coordinator.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Consent implements DiagnosticConsentStore {
  String? generation;
  int writes = 0;
  bool fail = false;
  Completer<void>? write;
  Completer<bool>? read;
  @override
  Future<bool> isEnabledFor(String value) async =>
      read == null ? generation == value : await read!.future;
  @override
  Future<void> enableFor(String value) async {
    writes++;
    if (write != null) await write!.future;
    if (fail) throw StateError('private storage error');
    generation = value;
  }

  @override
  Future<void> disableFor(String value) async {
    writes++;
    if (write != null) await write!.future;
    if (fail) throw StateError('private storage error');
    if (generation == value) generation = null;
  }
}

class _Coordinator implements ReleaseHealthCoordinator {
  bool suspended = false;
  int cancellations = 0;
  @override
  void suspendReporting() {
    suspended = true;
    cancelPending();
  }

  @override
  void cancelPending() => cancellations++;
  @override
  void resumeReporting() => suspended = false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AuthSessionModel _session(String id) => AuthSessionModel.fromJson({
  'accessToken': 'synthetic-$id',
  'refreshToken': 'synthetic-refresh',
  'user': {'id': id, 'role': 'PATIENT', 'status': 'ACTIVE'},
});

void main() {
  late InMemorySessionStore sessions;
  late _Consent consent;
  late _Coordinator coordinator;
  late DiagnosticPreferencesController controller;

  setUp(() async {
    sessions = InMemorySessionStore();
    await sessions.save(_session('a'));
    consent = _Consent();
    coordinator = _Coordinator();
    controller = DiagnosticPreferencesController(
      sessions: sessions,
      consent: consent,
      coordinator: coordinator,
      operationTimeout: const Duration(milliseconds: 20),
    );
  });
  tearDown(() => controller.dispose());

  test(
    'defaults off; explicit on and off persist to current session',
    () async {
      expect(controller.enabled, isFalse);
      expect(coordinator.suspended, isTrue);
      await controller.initialize();
      expect(controller.enabled, isFalse);
      await controller.setEnabled(true);
      expect(controller.enabled, isTrue);
      expect(coordinator.suspended, isFalse);
      consent.write = Completer<void>();
      final off = controller.setEnabled(false);
      expect(controller.enabled, isFalse);
      expect(coordinator.suspended, isTrue);
      expect(coordinator.cancellations, greaterThan(0));
      await Future<void>.delayed(Duration.zero);
      consent.write!.complete();
      await off;
      expect(consent.generation, isNull);
      expect(controller.message, isNull);
    },
  );

  test('restores only authoritative session consent', () async {
    consent.generation = (await sessions.capture())!.generation;
    await controller.initialize();
    expect(controller.enabled, isTrue);
    await sessions.save(_session('a'));
    controller.sessionChanged();
    expect(controller.enabled, isFalse);
    await controller.initialize();
    expect(controller.enabled, isFalse);
    expect(coordinator.suspended, isTrue);
  });

  test('account change before toggle cannot grant new account', () async {
    await controller.initialize();
    await sessions.save(_session('b'));
    await controller.setEnabled(true);
    expect(consent.writes, 0);
    expect(controller.enabled, isFalse);
    expect(controller.canChange, isFalse);
  });

  test('account change during write ignores late result', () async {
    await controller.initialize();
    consent.write = Completer<void>();
    final enable = controller.setEnabled(true);
    await Future<void>.delayed(Duration.zero);
    await sessions.save(_session('b'));
    consent.write!.complete();
    await enable;
    expect(controller.enabled, isFalse);
    expect(coordinator.suspended, isTrue);
    expect(
      await consent.isEnabledFor((await sessions.capture())!.generation),
      isFalse,
    );
  });

  test('failed enable and off show safe unsaved state', () async {
    await controller.initialize();
    consent.fail = true;
    await controller.setEnabled(true);
    expect(controller.enabled, isFalse);
    expect(controller.message, isNotNull);
    expect(controller.message, isNot(contains('private')));
    consent.fail = false;
    await controller.setEnabled(true);
    consent.fail = true;
    await controller.setEnabled(false);
    expect(controller.enabled, isFalse);
    expect(coordinator.suspended, isTrue);
    expect(controller.message, isNotNull);
    await controller.initialize();
    expect(controller.enabled, isFalse);
    expect(coordinator.suspended, isTrue);
  });

  test('hanging write deadline does not unlock or queue retry', () async {
    await controller.initialize();
    consent.write = Completer<void>();
    await controller.setEnabled(true);
    expect(controller.busy, isFalse);
    expect(controller.canChange, isFalse);
    await controller.setEnabled(true);
    await controller.initialize();
    expect(consent.writes, 1);
    consent.write!.complete();
    await Future<void>.delayed(Duration.zero);
    expect(controller.canChange, isTrue);
    expect(controller.enabled, isFalse);
    expect(coordinator.suspended, isTrue);
  });

  test(
    'off during enable cancels immediately and ignores late grant',
    () async {
      await controller.initialize();
      consent.write = Completer<void>();
      final enabling = controller.setEnabled(true);
      await Future<void>.delayed(Duration.zero);
      await controller.setEnabled(false);
      expect(coordinator.suspended, isTrue);
      consent.write!.complete();
      await enabling;
      await controller.initialize();
      expect(controller.enabled, isFalse);
      expect(consent.writes, 1);
      consent.write = null;
      await controller.setEnabled(false);
      expect(consent.generation, isNull);
    },
  );

  test('hanging initialize is bounded and ignores late true', () async {
    consent.read = Completer<bool>();
    await controller.initialize();
    expect(controller.busy, isFalse);
    expect(controller.message, isNotNull);
    consent.read!.complete(true);
    await Future<void>.delayed(Duration.zero);
    expect(controller.enabled, isFalse);
    expect(coordinator.suspended, isTrue);
  });

  test('reopening preferences does not override an unsaved opt-out', () async {
    await controller.initialize();
    await controller.setEnabled(true);
    consent.fail = true;
    await controller.setEnabled(false);
    expect(consent.generation, isNotNull);
    consent.fail = false;
    await controller.initialize();
    expect(controller.enabled, isFalse);
    expect(coordinator.suspended, isTrue);
  });

  test(
    'disposing settled enabled preferences does not revoke consent',
    () async {
      await controller.initialize();
      await controller.setEnabled(true);
      controller.dispose();
      expect(coordinator.suspended, isFalse);
      controller = DiagnosticPreferencesController(
        sessions: sessions,
        consent: consent,
        coordinator: coordinator,
      );
    },
  );

  test(
    'disposal invalidates pending completion without notifications',
    () async {
      await controller.initialize();
      consent.write = Completer<void>();
      final enabling = controller.setEnabled(true);
      await Future<void>.delayed(Duration.zero);
      var notifications = 0;
      controller.addListener(() => notifications++);
      controller.dispose();
      consent.write!.complete();
      await enabling;
      expect(notifications, 0);
      expect(coordinator.suspended, isTrue);
      // Prevent tearDown from disposing the same ChangeNotifier again.
      controller = DiagnosticPreferencesController(
        sessions: sessions,
        consent: consent,
        coordinator: coordinator,
      );
    },
  );

  testWidgets('tile toggles and remains readable at enlarged text', (
    tester,
  ) async {
    await controller.initialize();
    await tester.binding.setSurfaceSize(const Size(320, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(3.2)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: DiagnosticConsentTile(controller: controller),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Share technical diagnostics'), findsOneWidget);
    expect(
      find.textContaining('No health information or messages.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(controller.enabled, isTrue);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );
    consent.fail = true;
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Sharing is paused in this app session.'),
      findsOneWidget,
    );
    expect(find.textContaining('private storage'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
