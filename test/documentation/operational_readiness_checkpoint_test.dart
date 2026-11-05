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
        contains('fa1a715c25ab388ba29a92172c570ba7199f669a'),
        reason: '${entry.key} must name the current mobile integration.',
      );
      expect(
        entry.value,
        contains('1e2072bf2520b387d3dcc28f32918c21a86ad880'),
        reason: '${entry.key} must name current backend main.',
      );
      expect(
        entry.value,
        contains('41977173538'),
        reason: '${entry.key} must name mobile post-merge CI.',
      );
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
    expect(handoff, contains('no budget or BigQuery billing'));
    expect(handoff, contains('Total spend remains unknown'));
    expect(handoff, contains('real-policy email is unconfirmed'));
    expect(handoff, contains('test-only canary policy'));
    expect(handoff, contains('threshold >2'));
    expect(handoff, contains('auto-closed while SQL remained stopped'));
    expect(handoff, contains('temporary policy was deleted'));
    expect(handoff, contains('does not prove service-failure'));
    expect(readiness, contains('no monthly cap was invented'));
    expect(readiness, contains('BE-P1-058 is delivered'));
    expect(readiness, contains('controlled degraded-readiness test'));
    expect(readiness, contains('Receipt of the real-policy'));
  });

  test('APP-READY-082 remains the sole next task with current evidence', () {
    final handoff = File('docs/AI_HANDOFF.md').readAsStringSync();
    final task = handoff
        .split('\n')
        .singleWhere((line) => line.startsWith('| APP-READY-082 |'));

    expect(task, contains('**NEXT**'));
    expect(task, contains('backend docs PR #194 merged at `1e2072b`'));
    expect(task, contains('controlled nine-GET degraded-readiness test'));
    expect(task, contains('admin revision `00008-cig`'));
    expect(task, contains('13 original policies remain'));
    expect(
      task,
      contains('real-policy email receipt and recovery unconfirmed'),
    );
    expect(task, contains('budget/cost ceiling'));
    expect(task, isNot(contains('af0e7ab')));
  });

  test('admin download deployment is distinct from valid-file acceptance', () {
    final handoff = currentSections['AI_HANDOFF.md']!;
    expect(handoff, contains('Web PR #11'));
    expect(handoff, contains('PR #12 added browser fixture/flow'));
    expect(handoff, contains('coverage, and PR #13 clarified'));
    expect(handoff, contains('PR #13 clarified that IAP access'));
    expect(handoff, contains('PR #15 normalized the container entrypoint'));
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
