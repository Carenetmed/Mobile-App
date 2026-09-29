import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';

final carenetLightColorScheme = ColorScheme.fromSeed(
  seedColor: CarenetColors.brand,
  brightness: Brightness.light,
).copyWith(
  primary: CarenetColors.brand,
  onPrimary: CarenetColors.white,
  primaryContainer: CarenetColors.primary100,
  onPrimaryContainer: CarenetColors.primary700,
  error: CarenetColors.error100,
  onError: CarenetColors.white,
);
final carenetDarkColorScheme = ColorScheme.fromSeed(
  seedColor: CarenetColors.brand,
  brightness: Brightness.dark,
).copyWith(
  primary: CarenetColors.primary200,
  onPrimary: CarenetColors.primary700,
  primaryContainer: CarenetColors.primary700,
  onPrimaryContainer: CarenetColors.primary100,
  error: CarenetColors.error200,
  onError: CarenetColors.primary700,
);

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: carenetLightColorScheme,
  scaffoldBackgroundColor: AppColors.kWhite,
  textTheme: TextTheme(
    headlineLarge: const TextStyle().copyWith(
      fontFamily: AppFonts.montserrat,
      fontSize: FontSizes.heading1,
      color: AppColors.kBlack,
    ),
    headlineMedium: const TextStyle().copyWith(
      fontFamily: AppFonts.montserrat,
      fontSize: FontSizes.heading2,
      color: AppColors.kBlack,
    ),
    headlineSmall: const TextStyle().copyWith(
      fontFamily: AppFonts.montserrat,
      fontSize: FontSizes.heading3,
      color: AppColors.kBlack,
    ),
    bodyLarge: const TextStyle().copyWith(
      fontFamily: AppFonts.montserrat,
      fontSize: FontSizes.body1,
      color: AppColors.kBlack,
    ),
    bodyMedium: const TextStyle().copyWith(
      fontFamily: AppFonts.montserrat,
      fontSize: FontSizes.body2,
      color: AppColors.kBlack,
    ),
    bodySmall: const TextStyle().copyWith(
      fontFamily: AppFonts.montserrat,
      fontSize: FontSizes.body3,
      color: AppColors.kBlack,
    ),
    labelLarge: const TextStyle().copyWith(
      fontFamily: AppFonts.montserrat,
      fontSize: FontSizes.footer1,
      color: AppColors.kBlack,
    ),
    labelMedium: const TextStyle().copyWith(
      fontFamily: AppFonts.montserrat,
      fontSize: FontSizes.footer2,
      color: AppColors.kBlack,
    ),
    labelSmall: const TextStyle().copyWith(
      fontFamily: AppFonts.montserrat,
      fontSize: FontSizes.footer3,
      color: AppColors.kBlack,
    ),
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: carenetDarkColorScheme,
  scaffoldBackgroundColor: AppColors.white06,
  textTheme: TextTheme(
    headlineLarge: const TextStyle().copyWith(
      fontFamily: AppFonts.montserrat,
      fontSize: FontSizes.heading1,
      color: AppColors.kWhite,
    ),
    headlineMedium: const TextStyle().copyWith(
      fontFamily: AppFonts.montserrat,
      fontSize: FontSizes.heading2,
      color: AppColors.kWhite,
    ),
    headlineSmall: const TextStyle().copyWith(
      fontFamily: AppFonts.montserrat,
      fontSize: FontSizes.heading3,
      color: AppColors.kWhite,
    ),
    bodyLarge: const TextStyle().copyWith(
      fontFamily: AppFonts.montserrat,
      fontSize: FontSizes.body1,
      color: AppColors.kWhite,
    ),
    bodyMedium: const TextStyle().copyWith(
      fontFamily: AppFonts.montserrat,
      fontSize: FontSizes.body2,
      color: AppColors.kWhite,
    ),
    bodySmall: const TextStyle().copyWith(
      fontFamily: AppFonts.montserrat,
      fontSize: FontSizes.body3,
      color: AppColors.kWhite,
    ),
    labelLarge: const TextStyle().copyWith(
      fontFamily: AppFonts.montserrat,
      fontSize: FontSizes.footer1,
      color: AppColors.kWhite,
    ),
    labelMedium: const TextStyle().copyWith(
      fontFamily: AppFonts.montserrat,
      fontSize: FontSizes.footer2,
      color: AppColors.kWhite,
    ),
    labelSmall: const TextStyle().copyWith(
      fontFamily: AppFonts.montserrat,
      fontSize: FontSizes.footer3,
      color: AppColors.kWhite,
    ),
  ),
);
