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
        contains('9fc8f6a742d6a6a75008101fee24f6ebd0ad3e47'),
        reason: '${entry.key} must name the current mobile integration.',
      );
      expect(
        entry.value,
        contains('2d4b320771479e00ca7034a0859821a6b1fb7863'),
        reason: '${entry.key} must name current backend main.',
      );
      expect(
        entry.value,
        contains('41845757337'),
        reason: '${entry.key} must name mobile post-merge CI.',
      );
      expect(
        entry.value,
        contains('41802721952'),
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
    expect(handoff, contains('no real threshold breach'));
    expect(handoff, contains('condition-triggered alert delivery is claimed'));
    expect(readiness, contains('no monthly cap was invented'));
    expect(readiness, contains('BE-P1-058 is delivered'));
    expect(readiness, contains('condition-triggered notification-delivery'));
  });

  test('admin download deployment is distinct from valid-file acceptance', () {
    final handoff = currentSections['AI_HANDOFF.md']!;
    expect(handoff, contains('Web PR #11'));
    expect(handoff, contains('PR #12 added browser fixture/flow coverage'));
    expect(handoff, contains('4eeaf836-c946-43f6-a27d-221cb636c9a2'));
    expect(
      handoff,
      contains(
        'sha256:fdc99d7516c92928508ef01bbb1d3232d336c10438ad930fee6cb3b32add3504',
      ),
    );
    expect(handoff, contains('real-file download or valid PDF rendering'));
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
