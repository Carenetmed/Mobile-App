import 'package:app_t/core/model/validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'password minimum uses NFC length rather than decomposed input length',
    () {
      final decomposed = List.filled(8, 'e\u0301').join();
      expect(decomposed.length, 16);
      expect(
        Validators.validatePassword(decomposed),
        'Password must be at least 15 characters long',
      );
    },
  );

  test('backend-valid decomposed password is accepted at the maximum', () {
    final decomposed = List.filled(128, 'e\u0301').join();
    expect(decomposed.length, 256);
    expect(Validators.validatePassword(decomposed), isNull);
    expect(
      Validators.validatePassword(List.filled(128, '\u00e9').join()),
      isNull,
    );
  });

  test('canonical equivalents agree at both length boundaries', () {
    for (final length in [14, 15, 128, 129]) {
      expect(
        Validators.validatePassword(List.filled(length, 'e\u0301').join()),
        Validators.validatePassword(List.filled(length, '\u00e9').join()),
      );
    }
  });

  test(
    'confirmation accepts NFC-equivalent passwords without changing input',
    () {
      final prefix = List.filled(14, 'x').join();
      final decomposed = '${prefix}e\u0301';
      expect(
        Validators.validateConfirmPassword(
          decomposed,
          password: '$prefix\u00e9',
        ),
        isNull,
      );
      expect(decomposed, '${prefix}e\u0301');
      expect(
        Validators.validateConfirmPassword(
          '${prefix}a',
          password: '$prefix\u00e9',
        ),
        'Passwords do not match',
      );
    },
  );

  test(
    'normalization preserves backend UTF-16 length and ASCII weak-password rules',
    () {
      expect(
        Validators.validatePassword(List.filled(7, '\u{1f600}').join()),
        isNotNull,
      );
      expect(
        Validators.validatePassword(List.filled(8, '\u{1f600}').join()),
        isNull,
      );
      expect(
        Validators.validatePassword('123456789012345'),
        'Choose a less common password',
      );
      expect(Validators.validatePassword(''), 'Please enter your password');
      expect(Validators.validatePassword(null), 'Please enter your password');
    },
  );
}
