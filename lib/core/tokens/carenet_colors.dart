import 'package:flutter/material.dart';

/// Shared CareNet marketplace colors.
abstract final class CarenetColors {
  // --- Primary (healthcare green) ---

  static const Color primary100 = Color(0xFFE7F3EC);
  static const Color primary200 = Color(0xFFC4E2D0);
  static const Color primary300 = Color(0xFF92C9AA);
  static const Color primary400 = Color(0xFF4D9A70);
  static const Color primary500 = Color(0xFF054F31);
  static const Color primary600 = Color(0xFF043F27);
  static const Color primary700 = Color(0xFF022D1B);

  /// Brand green — alias for [primary500].
  static const Color brand = primary500;

  // --- Neutral (blueprint "grey") ---

  static const Color neutral100 = Color(0xFFE8E8E9);
  static const Color neutral200 = Color(0xFFC1C0C4);
  static const Color neutral300 = Color(0xFF9A999F);
  static const Color neutral400 = Color(0xFF76747C);
  static const Color neutral500 = Color(0xFF535159);
  static const Color neutral600 = Color(0xFF323136);
  static const Color neutral700 = Color(0xFF141416);

  // --- Semantic ---

  static const Color success100 = Color(0xFF176B45);
  static const Color success200 = Color(0xFFE7F3EC);
  static const Color error100 = Color(0xFFB3261E);
  static const Color error200 = Color(0xFFFCE8E6);
  static const Color info100 = Color(0xFF155E75);
  static const Color info200 = Color(0xFFE6F4F6);

  // --- Base ---

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
