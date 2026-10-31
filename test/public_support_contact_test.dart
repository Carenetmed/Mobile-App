import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final html = File('hosting/public/support/index.html').readAsStringSync();

  test('long support contact can wrap inside the reading column', () {
    final css = File('hosting/public/styles.css').readAsStringSync();
    expect(css, matches(RegExp(r'main\s*\{[^}]*overflow-wrap:\s*anywhere;')));
  });

  test('support publishes only the approved accessible query-free mailto', () {
    const address = 'carenethealthplatforms@gmail.com';
    expect(
      html,
      contains('<a href="mailto:$address">$address</a>'),
    );
    expect('mailto:'.allMatches(html), hasLength(1));
    expect(html, isNot(contains('mailto:$address?')));
    expect(html, isNot(contains('subject=')));
    expect(html, isNot(contains('body=')));
    expect(html.toLowerCase(), isNot(contains('<form')));
    expect(html.toLowerCase(), isNot(contains('<script')));
    expect(html, contains('<link rel="stylesheet" href="/styles.css">'));
    expect(html, isNot(contains('Contact availability')));
  });

  test('support states ownership, limits, emergency and privacy guidance', () {
    for (final copy in <String>[
      'The CareNet team is responsible for replies.',
      'No support hours or response times are promised.',
      'CareNet is not an emergency service.',
      'Contact local emergency services or go to the nearest appropriate '
          'emergency facility for urgent help.',
      'Describe the problem without including medical details, health records, '
          'or other sensitive personal information.',
      'Never email passwords, one-time codes, verification links, reset links, '
          'or payment credentials.',
      'This support mailbox is not for medical advice or emergencies.',
      'Do not send health information through channels outside the '
          'consultation workflow.',
    ]) {
      expect(html, contains(copy));
    }
  });
}
