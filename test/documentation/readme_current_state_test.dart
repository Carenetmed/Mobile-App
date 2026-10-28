import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String readme;
  late String normalizedReadme;

  setUpAll(() {
    readme = File('README.md').readAsStringSync();
    normalizedReadme = readme.replaceAll(RegExp(r'\s+'), ' ').trim();
  });

  test('README names the active role-aware marketplace contract', () {
    expect(
      normalizedReadme,
      contains('Patients: Home, Find Care, Appointments, Messages.'),
    );
    expect(
      normalizedReadme,
      contains('Professionals: Home, Schedule, Appointments, Messages.'),
    );
    expect(normalizedReadme, contains('The backend remains authoritative'));
    expect(
      normalizedReadme,
      contains('Notifications and Account actions in the header'),
    );
  });

  test('README does not restore obsolete frontend-only claims', () {
    expect(readme, isNot(contains('frontend-ready application surface')));
    expect(
      readme,
      isNot(
        contains(
          'Real authentication, account persistence, server-backed health records',
        ),
      ),
    );
    expect(readme, isNot(contains('pull request into `main`')));
  });

  test('README keeps release limits and local links explicit', () {
    expect(
      normalizedReadme,
      contains('Implemented source is not the same as production readiness.'),
    );
    expect(
      normalizedReadme,
      contains('they are not active Phase 1 product authority'),
    );
    expect(
      normalizedReadme,
      contains('Android is the first distributable platform'),
    );
    expect(
      normalizedReadme,
      contains(
        'final signing and provider acceptance require Apple credentials',
      ),
    );
    expect(normalizedReadme, contains('Paystack activation gate'));
    expect(normalizedReadme, contains('feature/frontend-milestone'));
    expect(
      normalizedReadme,
      contains('Never replace missing provider configuration'),
    );
    expect(normalizedReadme, contains('Do not commit API secrets'));
    expect(normalizedReadme, contains('private proof artifacts'));

    final links =
        RegExp(
          r'\[[^\]]+\]\((docs/[^)]+)\)',
        ).allMatches(readme).map((match) => match.group(1)!).toSet();

    expect(links, isNotEmpty);
    for (final path in links) {
      expect(
        File(path).existsSync(),
        isTrue,
        reason: 'Missing README link: $path',
      );
    }
  });

  test('README does not overstate route history as runtime authority', () {
    expect(readme, contains('Route declarations and disposition history'));
    expect(readme, isNot(contains('Canonical engineering references include')));
  });
}
