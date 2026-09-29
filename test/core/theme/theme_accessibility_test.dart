import 'package:app_t/core/theme/theme.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color foreground, Color background) {
  final light = foreground.computeLuminance();
  final dark = background.computeLuminance();
  final lighter = light > dark ? light : dark;
  final darker = light > dark ? dark : light;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  test('light marketplace theme uses green with accessible contrast', () {
    expect(carenetLightColorScheme.primary, CarenetColors.brand);
    expect(
      _contrast(
        carenetLightColorScheme.onPrimary,
        carenetLightColorScheme.primary,
      ),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(
        carenetLightColorScheme.onPrimaryContainer,
        carenetLightColorScheme.primaryContainer,
      ),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('dark marketplace primary pair has accessible contrast', () {
    expect(carenetDarkColorScheme.primary, CarenetColors.primary200);
    expect(
      _contrast(
        carenetDarkColorScheme.onPrimary,
        carenetDarkColorScheme.primary,
      ),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('semantic status pairs meet normal-text contrast', () {
    expect(
      _contrast(CarenetColors.success100, CarenetColors.success200),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(CarenetColors.error100, CarenetColors.error200),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(CarenetColors.info100, CarenetColors.info200),
      greaterThanOrEqualTo(4.5),
    );
  });
}
