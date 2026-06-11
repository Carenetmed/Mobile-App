import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CarenetColors', () {
    test('primary scale matches blueprint color-palette', () {
      expect(CarenetColors.primary100, const Color(0xFFEBE5FF));
      expect(CarenetColors.primary200, const Color(0xFFCAB6FF));
      expect(CarenetColors.primary300, const Color(0xFFAB84FF));
      expect(CarenetColors.primary400, const Color(0xFF9148FF));
      expect(CarenetColors.primary500, const Color(0xFF7000DA));
      expect(CarenetColors.primary600, const Color(0xFF46008C));
      expect(CarenetColors.primary700, const Color(0xFF1F0045));
      expect(CarenetColors.brand, CarenetColors.primary500);
    });

    test('neutral scale matches blueprint grey scale', () {
      expect(CarenetColors.neutral100, const Color(0xFFE8E8E9));
      expect(CarenetColors.neutral200, const Color(0xFFC1C0C4));
      expect(CarenetColors.neutral300, const Color(0xFF9A999F));
      expect(CarenetColors.neutral400, const Color(0xFF76747C));
      expect(CarenetColors.neutral500, const Color(0xFF535159));
      expect(CarenetColors.neutral600, const Color(0xFF323136));
      expect(CarenetColors.neutral700, const Color(0xFF141416));
    });

    test('semantic colors match blueprint color-palette', () {
      expect(CarenetColors.success100, const Color(0xFF03A900));
      expect(CarenetColors.success200, const Color(0xFFEAFFF3));
      expect(CarenetColors.error100, const Color(0xFFE62F2F));
      expect(CarenetColors.error200, const Color(0xFFFFE3E0));
      expect(CarenetColors.info100, const Color(0xFF0FC2FB));
      expect(CarenetColors.info200, const Color(0xFFC7F1FF));
    });
  });
}
