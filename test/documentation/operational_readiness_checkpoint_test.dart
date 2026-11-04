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
        contains('040cbd7d033b2cdb7e969623f8e55a38a3b3d9f2'),
        reason: '${entry.key} must name the current mobile integration.',
      );
      expect(
        entry.value,
        contains('2d4b320771479e00ca7034a0859821a6b1fb7863'),
        reason: '${entry.key} must name current backend main.',
      );
      expect(
        entry.value,
        contains('41798115546'),
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
    expect(handoff, contains('real file download or valid PDF rendering'));
    expect(handoff, contains('63-byte smoke PDF'));
  });
}

String _before(String text, String marker) {
  final index = text.indexOf(marker);
  if (index < 0) return text;
  return text.substring(0, index);
}
