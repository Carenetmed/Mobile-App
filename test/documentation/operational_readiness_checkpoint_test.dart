import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, String> currentSections;

  setUpAll(() {
    const files = <String, (String, String)>{
      'AI_HANDOFF.md': ('docs/AI_HANDOFF.md', '\n## APP-READY-086'),
      'CODEBASE_STATUS.md': ('docs/CODEBASE_STATUS.md', '\n## APP-READY-090'),
      'DOC_SYNC.md': ('docs/DOC_SYNC.md', '\n## APP-READY-084'),
      'PHASE_1_OPERATIONAL_READINESS.md': (
        'docs/PHASE_1_OPERATIONAL_READINESS.md',
        '\n## Scope And Authority',
      ),
      'README.md': ('docs/README.md', '\nHistorical:'),
    };

    currentSections = {
      for (final entry in files.entries)
        entry.key: _before(
          File(entry.value.$1).readAsStringSync(),
          entry.value.$2,
        ),
    };
  });

  test('current docs agree on merged mobile and backend checkpoints', () {
    for (final entry in currentSections.entries) {
      expect(
        entry.value,
        contains('e3ccafbc7dd2e831f4fc035166ee1d160443dacf'),
        reason: '${entry.key} must name the current merged integration.',
      );
      expect(
        entry.value,
        contains('83f2dfb095b022f1d9dc41952ae0ec13b4557180'),
        reason: '${entry.key} must retain the APP-P1-007B merge checkpoint.',
      );
      expect(entry.value, contains('bc757266fbb322d55f7aa47fe3eb39f97387b839'));
      expect(entry.value, contains('43155362903'));
      expect(entry.value, contains('2026-11-09T23:41:46.171Z'));
      expect(
        entry.value,
        contains('00a7021b60c620e1f4fae25fbce405ce17f322ad'),
        reason: '${entry.key} must retain the prior checkpoint for provenance.',
      );
      expect(entry.value, contains('3d447f7d1e78c1bd32007b3038bef4b6b204c9b9'));
      expect(entry.value, contains('43148540818'));
      expect(entry.value, contains('43148540838'));
      expect(entry.value, contains('1,423 tests'));
      expect(entry.value, contains('42570975195'));
      expect(entry.value, contains('42572846070'));
      expect(
        entry.value,
        contains('431094b429581e62e5f5f21acdaae693031b7859'),
        reason:
            '${entry.key} must name the current backend education contract source.',
      );
      expect(entry.value, contains('1e2072bf2520b387d3dcc28f32918c21a86ad880'));
      expect(
        entry.value,
        contains('42091108978'),
        reason: '${entry.key} must name APP-READY-101 PR-head CI.',
      );
      expect(
        entry.value,
        contains('42093709035'),
        reason: '${entry.key} must name current merged-result CI.',
      );
      expect(
        entry.value,
        contains('42081173591'),
        reason: '${entry.key} must name the reviewed PR-head CI.',
      );
      expect(
        entry.value,
        contains('42084055217'),
        reason: '${entry.key} must name current merged-result CI.',
      );
      expect(entry.value, contains('1,366 tests'));
      expect(
        entry.value,
        contains('carenet-admin-staging-00008-cig'),
        reason: '${entry.key} must name the current admin revision.',
      );
      expect(
        entry.value,
        isNot(contains('carenet-admin-staging-00006-55n')),
        reason: '${entry.key} must not report the superseded admin revision.',
      );
      expect(
        entry.value,
        contains('41982963454'),
        reason: '${entry.key} must name backend post-merge CI.',
      );
    }
  });

  test('billing and monitoring evidence does not overstate readiness', () {
    final handoff = currentSections['AI_HANDOFF.md']!;
    final readiness = currentSections['PHASE_1_OPERATIONAL_READINESS.md']!;

    expect(handoff, contains('Billing Budgets API are enabled'));
    expect(
      handoff,
      contains(r'project-scoped $31.75 USD monthly budget alert'),
    );
    expect(
      handoff,
      contains('billing export exists and actual spend remains unknown'),
    );
    expect(handoff, contains('does not cap or stop spending'));
    expect(handoff, contains('actual spend remains unknown'));
    expect(handoff, contains('Gmail confirms the real-policy'));
    expect(handoff, contains('APP-READY-097 - Sanitized Release-Health'));
    expect(handoff, contains('not proof of deployed admission, log retention'));
    expect(
      File('docs/PHASE_1_RELEASE_HEALTH.md').readAsStringSync(),
      contains('The default-off case'),
    );
    expect(handoff, contains('GET /health/ready'));
    expect(handoff, contains('returned HTTP 200'));
    expect(
      handoff,
      contains('test-only canary on staging-admin request metrics'),
    );
    expect(handoff, contains('threshold >2'));
    expect(handoff, contains('auto-closed while SQL remained stopped'));
    expect(handoff, contains('temporary policy was deleted'));
    expect(handoff, contains('not delivery for every policy'));
    expect(handoff, contains('Fourteen monitoring policies'));
    expect(handoff, contains('five-minute HTTPS uptime check'));
    expect(handoff, contains('all three regions'));
    expect(handoff, contains('liveness policy'));
    expect(readiness, contains('This is an alert, not a spend'));
    expect(readiness, contains('A project-scoped monthly budget alert is'));
    expect(readiness, contains('50%, 90%, and 100% current-spend email'));
    expect(readiness, contains('BE-P1-058 is delivered'));
    expect(readiness, contains('seven-day transaction-log retention'));
    expect(readiness, contains('2026-11-09T20:28:51.567Z'));
    expect(readiness, contains('earlier 503 exercise was controlled'));
    expect(readiness, contains('Gmail confirms the real-policy'));
    expect(readiness, contains('Three have controlled exact-policy'));
    expect(readiness, contains('eleven are configuration-only'));
    expect(readiness, contains('production liveness policy\'s complete'));
    expect(readiness, contains('evaluation window has not been exercised'));
    expect(readiness, contains('temporary 60-second policy'));
    expect(readiness, contains('2026-11-05T19:57:33Z'));
    expect(readiness, contains('2026-11-05T19:58:15Z'));
    expect(readiness, contains('Missing metrics in the original policies'));
    expect(readiness, contains('11,457.57 ms'));
    expect(readiness, contains('service recovered'));
    expect(readiness, contains('metric was missing'));
    expect(readiness, contains('leave `evaluationMissingData` unset'));
    expect(readiness, contains('Four of the'));
    expect(readiness, contains('nine use 60 minutes'));
    expect(readiness, contains('policies explicitly list an'));
    for (final policy in <String>[
      'API server errors',
      'Database memory pressure',
      'Database disk pressure',
      'RTC scheduler dispatch failed',
      'Sanitized mobile release-health report',
      'API p95 latency',
      'API gateway liveness',
      'Notification deliveries overdue or abandoned',
      'Notification observer execution failed',
      'RTC execution failed',
      'Notification events overdue or abandoned',
      'Database CPU pressure',
      'Staging job failure',
      'Notification reminders overdue or abandoned',
    ]) {
      expect(readiness, contains('| $policy |'));
    }
  });

  test('APP-READY-082 remains the sole next task with current evidence', () {
    final handoff = File('docs/AI_HANDOFF.md').readAsStringSync();
    final task = handoff
        .split('\n')
        .singleWhere((line) => line.startsWith('| APP-READY-082 |'));

    expect(task, contains('**NEXT**'));
    expect(task, contains('`e3ccafbc`'));
    expect(task, contains('1,423 tests'));
    expect(task, contains('not running'));
    expect(task, contains('five-minute PITR cut-point'));
    expect(task, contains('continuous RPO/SLO'));
    expect(task, contains('timed out'));
    expect(task, contains('3/14'));
    expect(task, contains('public content stays disabled'));

    final readiness =
        File('docs/PHASE_1_OPERATIONAL_READINESS.md').readAsStringSync();
    expect(handoff, contains('APP-READY-101 merged through PR #281'));
    expect(handoff, contains('42091108978'));
    expect(handoff, contains('42093709035'));
    expect(handoff, contains('APP-READY-100 merged through PR #280'));
    expect(handoff, contains('42081173591'));
    expect(handoff, contains('42084055217'));
    expect(handoff, contains('`1e2072bf2520b387d3dcc28f32918c21a86ad880`'));
    expect(handoff, contains('carenet-admin-staging-00008-cig'));
    expect(handoff, contains('all 14 persistent policies are enabled'));
    expect(handoff, contains('exact-policy email proof exists for only 3/14'));
    expect(handoff, contains('actual spend was'));
    expect(handoff, contains('not read here'));
    expect(readiness, contains('fresh samples passed in all three regions'));
    expect(readiness, contains('production policy\'s 20-minute alignment'));
    expect(readiness, contains('Gmail confirms the real-policy'));
    expect(readiness, contains('one `GET /health/ready` returned'));
    expect(readiness, contains('Actual current spend has'));
    expect(readiness, contains('not been read in this checkpoint'));
    expect(readiness, contains('Nov 12 controlled database recovery proof'));
    expect(readiness, contains('five-minute PITR cut point'));
    expect(readiness, contains('2026-11-09T23:41:46.171Z'));
    expect(readiness, contains('SQL users API confirmed'));
    expect(readiness, contains('source was not running'));
    expect(readiness, contains('inventory timed out'));
    expect(readiness, contains('connector enforcement `REQUIRED`'));
    expect(readiness, contains('`requireSsl=false`'));
    expect(readiness, contains('public IPv4 enabled, no private IP, zero'));
    expect(readiness, contains('2026-10-27T18:00:00Z'));
  });

  test('admin download deployment is distinct from valid-file acceptance', () {
    final handoff = currentSections['AI_HANDOFF.md']!;
    expect(handoff, contains('Web PR #11'));
    expect(handoff, contains('PR #12 added browser fixture/flow'));
    expect(handoff, contains('coverage, and PR #13 clarified'));
    expect(handoff, contains('PR #13 clarified that IAP access'));
    expect(handoff, contains('PR #15 normalized the container entrypoint'));
    expect(handoff, contains('Web PR #16 then'));
    expect(handoff, contains('2a3f299f6cc00779b2d7625a0c60339e83551595'));
    expect(handoff, contains('42000423597'));
    expect(handoff, contains('not proof that Chromium visually rendered'));
    expect(handoff, contains('did not change or redeploy'));
    expect(handoff, contains('post-merge CI'));
    expect(handoff, contains('41927227034'));
    expect(handoff, contains('operator visual confirmation'));
    expect(handoff, contains('This is not independent'));
    expect(handoff, contains('byte-integrity or valid-PDF proof'));
    expect(handoff, contains('caace09e-6c85-4a48-b05e-d62b66575785'));
    expect(
      handoff,
      contains(
        'sha256:bcf9814146b3cdf2008487ef61623d331ab0d18859574e753a4ad33041e61cc7',
      ),
    );
    expect(handoff, contains('100% traffic'));
    expect(handoff, contains('CI container smoke served `/admin`'));
    expect(handoff, contains('63-byte smoke PDF'));
  });

  test(
    'published support and mailbox evidence do not imply response promises',
    () {
      final handoff = currentSections['AI_HANDOFF.md']!;
      final readiness = currentSections['PHASE_1_OPERATIONAL_READINESS.md']!;

      expect(
        handoff,
        contains('https://project-a96784ee-811c-46ab-a7b.web.app'),
      );
      expect(
        handoff,
        contains('owner confirmed the one approved plain-text mailbox test'),
      );
      expect(readiness, contains('owner confirmed it arrived in the support'));
      expect(readiness, contains('No response hours or times are promised'));
    },
  );
}

String _before(String text, String marker) {
  final index = text.indexOf(marker);
  if (index < 0) return text;
  return text.substring(0, index);
}
