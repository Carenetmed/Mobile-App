import 'dart:async';

import 'package:app_t/core/config/app_environment.dart';
import 'package:app_t/core/diagnostics/diagnostic_consent_store.dart';
import 'package:app_t/core/diagnostics/release_health_api_client.dart';
import 'package:app_t/core/diagnostics/release_health_coordinator.dart';
import 'package:app_t/core/diagnostics/release_health_metadata.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _Consent implements DiagnosticConsentStore {
  String? generation;
  @override
  Future<bool> isEnabledFor(String value) async => value == generation;
  @override
  Future<void> enableFor(String value) async => generation = value;
  @override
  Future<void> disableFor(String value) async {
    if (generation == value) generation = null;
  }
}

class _Transport implements ReleaseHealthTransport {
  int calls = 0;
  String? token;
  CancelToken? cancellation;
  Completer<DiagnosticSubmissionResult>? pending;
  @override
  Future<DiagnosticSubmissionResult> send({
    required SafeDiagnosticReport report,
    required String accessToken,
    CancelToken? cancelToken,
  }) async {
    calls++;
    token = accessToken;
    cancellation = cancelToken;
    return pending == null
        ? DiagnosticSubmissionResult.accepted
        : await pending!.future;
  }
}

AuthSessionModel _session(String id) => AuthSessionModel.fromJson({
  'accessToken': 'synthetic-$id',
  'refreshToken': 'synthetic-refresh',
  'user': {'id': id, 'role': 'PATIENT', 'status': 'ACTIVE'},
});

void main() {
  late InMemorySessionStore sessions;
  late _Consent consent;
  late _Transport transport;
  late ReleaseHealthCoordinator coordinator;
  late Future<ReleaseHealthMetadata> Function() metadata;
  ReleaseHealthMetadata release() => ReleaseHealthMetadata(
    version: '1.0.0',
    buildNumber: '1',
    environment: CareNetEnvironment.staging,
  );

  setUp(() async {
    sessions = InMemorySessionStore();
    consent = _Consent();
    transport = _Transport();
    metadata = () async => release();
    coordinator = ReleaseHealthCoordinator(
      sessions: sessions,
      consent: consent,
      transport: transport,
      metadata: () => metadata(),
    );
    await sessions.save(_session('a'));
  });
  tearDown(() => coordinator.dispose());

  Future<void> enable() async =>
      consent.enableFor((await sessions.capture())!.generation);

  test('default off never sends', () async {
    await coordinator.report(DiagnosticCode.frameworkFailure);
    expect(transport.calls, 0);
  });
  test('consented current session sends using its latest token', () async {
    await enable();
    await coordinator.report(DiagnosticCode.frameworkFailure);
    expect(transport.calls, 1);
    expect(transport.token, 'synthetic-a');
  });
  test('logout prevents reporting without changing session', () async {
    await enable();
    await sessions.clear();
    await coordinator.report(DiagnosticCode.frameworkFailure);
    expect(transport.calls, 0);
    expect(await sessions.capture(), isNull);
  });
  test('new login cannot reuse consent even for same account', () async {
    await enable();
    await sessions.save(_session('a'));
    await coordinator.report(DiagnosticCode.frameworkFailure);
    expect(transport.calls, 0);
  });

  test('token refresh keeps consent but uses the replacement token', () async {
    await enable();
    final snapshot = (await sessions.capture())!;
    final replacement = AuthSessionModel.fromJson({
      ...snapshot.session.toJson(),
      'accessToken': 'synthetic-rotated-token',
    });
    expect(
      await sessions.replaceSnapshotIfCurrent(snapshot, replacement),
      isTrue,
    );
    await coordinator.report(DiagnosticCode.frameworkFailure);
    expect(transport.calls, 1);
    expect(transport.token, 'synthetic-rotated-token');
  });
  test('account switch during metadata load fails closed', () async {
    await enable();
    final pending = Completer<ReleaseHealthMetadata>();
    metadata = () => pending.future;
    final report = coordinator.report(DiagnosticCode.frameworkFailure);
    await Future<void>.delayed(Duration.zero);
    await sessions.save(_session('b'));
    pending.complete(release());
    await report;
    expect(transport.calls, 0);
  });
  test('opt out invalidates a pending metadata load', () async {
    await enable();
    final pending = Completer<ReleaseHealthMetadata>();
    metadata = () => pending.future;
    final report = coordinator.report(DiagnosticCode.frameworkFailure);
    await Future<void>.delayed(Duration.zero);
    coordinator.cancelPending();
    pending.complete(release());
    await report;
    expect(transport.calls, 0);
  });
  test('disposed coordinator ignores late completion', () async {
    await enable();
    final pending = Completer<ReleaseHealthMetadata>();
    metadata = () => pending.future;
    final report = coordinator.report(DiagnosticCode.frameworkFailure);
    await Future<void>.delayed(Duration.zero);
    coordinator.dispose();
    pending.complete(release());
    await report;
    expect(transport.calls, 0);
  });
  test('concurrent calls and repeated codes are not queued', () async {
    await enable();
    transport.pending = Completer<DiagnosticSubmissionResult>();
    final report = coordinator.report(DiagnosticCode.frameworkFailure);
    await Future<void>.delayed(Duration.zero);
    await coordinator.report(DiagnosticCode.asynchronousFailure);
    expect(transport.calls, 1);
    transport.pending!.complete(DiagnosticSubmissionResult.accepted);
    await report;
    await coordinator.report(DiagnosticCode.frameworkFailure);
    expect(transport.calls, 1);
  });
  test('cancellation reaches the current transport', () async {
    await enable();
    transport.pending = Completer<DiagnosticSubmissionResult>();
    final report = coordinator.report(DiagnosticCode.frameworkFailure);
    await Future<void>.delayed(Duration.zero);
    coordinator.cancelPending();
    expect(transport.cancellation!.isCancelled, isTrue);
    transport.pending!.complete(DiagnosticSubmissionResult.cancelled);
    await report;
  });
  test('metadata failure is swallowed without submission or logout', () async {
    await enable();
    metadata = () async => throw StateError('synthetic-private-content');
    await coordinator.report(DiagnosticCode.frameworkFailure);
    expect(transport.calls, 0);
    expect((await sessions.capture())!.session.user.id, 'a');
  });

  test('suspension blocks later reports until explicitly resumed', () async {
    await enable();
    coordinator.suspendReporting();
    await coordinator.report(DiagnosticCode.frameworkFailure);
    expect(transport.calls, 0);
    coordinator.resumeReporting();
    await coordinator.report(DiagnosticCode.frameworkFailure);
    expect(transport.calls, 1);
  });

  testWidgets('timed out plugin retains capacity until actual settlement', (
    tester,
  ) async {
    await enable();
    final pending = Completer<ReleaseHealthMetadata>();
    var loads = 0;
    metadata = () {
      loads++;
      return pending.future;
    };
    final first = coordinator.report(DiagnosticCode.frameworkFailure);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await first;
    await coordinator.report(DiagnosticCode.asynchronousFailure);
    expect(loads, 1);
    expect(transport.calls, 0);
    pending.complete(release());
    await tester.pump();
    metadata = () async => release();
    await coordinator.report(DiagnosticCode.asynchronousFailure);
    expect(transport.calls, 1);
  });
}
