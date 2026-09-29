import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CarenetColors', () {
    test('primary scale uses the healthcare green marketplace brand', () {
      expect(CarenetColors.primary100, const Color(0xFFE7F3EC));
      expect(CarenetColors.primary200, const Color(0xFFC4E2D0));
      expect(CarenetColors.primary300, const Color(0xFF92C9AA));
      expect(CarenetColors.primary400, const Color(0xFF4D9A70));
      expect(CarenetColors.primary500, const Color(0xFF054F31));
      expect(CarenetColors.primary600, const Color(0xFF043F27));
      expect(CarenetColors.primary700, const Color(0xFF022D1B));
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

    test('semantic status colors stay distinct and readable', () {
      expect(CarenetColors.success100, const Color(0xFF176B45));
      expect(CarenetColors.success200, const Color(0xFFE7F3EC));
      expect(CarenetColors.error100, const Color(0xFFB3261E));
      expect(CarenetColors.error200, const Color(0xFFFCE8E6));
      expect(CarenetColors.info100, const Color(0xFF155E75));
      expect(CarenetColors.info200, const Color(0xFFE6F4F6));
    });
  });
}
