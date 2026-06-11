import 'package:flutter/material.dart';

/// Color tokens from blueprint `screens/color-palette/screen.json`.
///
/// Primary scale: `primary/100`–`primary/700` (brand at 500 = `#7000DA`).
/// Neutral scale: blueprint `grey/100`–`grey/700` (documented as neutral in design docs).
abstract final class CarenetColors {
  // --- Primary (purple) ---

  static const Color primary100 = Color(0xFFEBE5FF);
  static const Color primary200 = Color(0xFFCAB6FF);
  static const Color primary300 = Color(0xFFAB84FF);
  static const Color primary400 = Color(0xFF9148FF);
  static const Color primary500 = Color(0xFF7000DA);
  static const Color primary600 = Color(0xFF46008C);
  static const Color primary700 = Color(0xFF1F0045);

  /// Brand purple — alias for [primary500].
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

  static const Color success100 = Color(0xFF03A900);
  static const Color success200 = Color(0xFFEAFFF3);
  static const Color error100 = Color(0xFFE62F2F);
  static const Color error200 = Color(0xFFFFE3E0);
  static const Color info100 = Color(0xFF0FC2FB);
  static const Color info200 = Color(0xFFC7F1FF);

  // --- Base ---

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
