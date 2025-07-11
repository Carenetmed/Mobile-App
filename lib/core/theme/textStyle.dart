import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FontSizes {
  static final footer4 = 8.sp;
  static final footer3 = 10.0.sp;
  static final footer2 = 12.0.sp;
  static final footer1 = 14.0.sp;
  static final body3 = 16.0.sp;
  static final body2 = 18.0.sp;
  static final body1 = 24.0.sp;
  static final heading3 = 28.0.sp;
  static final heading2 = 32.0.sp;
  static final heading1 = 40.0.sp;
}

class TextStyles {
  static TextStyle? regular1({required BuildContext context}) {
    return Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w400,
        );
  }

  static TextStyle? medium1({required BuildContext context}) {
    return Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w500,
        );
  }

  static TextStyle? bold1({required BuildContext context}) {
    return Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
        );
  }

  static TextStyle? regular2({required BuildContext context}) {
    return Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w400,
        );
  }

  static TextStyle? medium2({required BuildContext context}) {
    return Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
        );
  }

  static TextStyle? bold2({required BuildContext context}) {
    return Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        );
  }

  static TextStyle? regular3({required BuildContext context}) {
    return Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w400,
        );
  }

  static TextStyle? medium3({required BuildContext context}) {
    return Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        );
  }

  static TextStyle? bold3({required BuildContext context}) {
    return Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        );
  }

  static TextStyle? regular4({required BuildContext context}) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w400,
        );
  }

  static TextStyle? medium4({required BuildContext context}) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
        );
  }

  static TextStyle? bold4({required BuildContext context}) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
        );
  }

  static TextStyle? regular5({required BuildContext context}) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
        );
  }

  static TextStyle? medium5({required BuildContext context}) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        );
  }

  static TextStyle? bold5({required BuildContext context}) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
        );
  }

  static TextStyle? regular6({required BuildContext context}) {
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w400,
        );
  }

  static TextStyle? medium6({required BuildContext context}) {
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        );
  }

  static TextStyle? bold6({required BuildContext context}) {
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w700,
        );
  }

  static TextStyle? regular7({required BuildContext context}) {
    return Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w400,
        );
  }

  static TextStyle? medium7({required BuildContext context}) {
    return Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w500,
        );
  }

  static TextStyle? bold7({required BuildContext context}) {
    return Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        );
  }

  static TextStyle? regular8({required BuildContext context}) {
    return Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w400,
        );
  }

  static TextStyle? medium8({required BuildContext context}) {
    return Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w500,
        );
  }

  static TextStyle? bold8({required BuildContext context}) {
    return Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
        );
  }

  static TextStyle? regular9({required BuildContext context}) {
    return Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w400,
        );
  }

  static TextStyle? medium9({required BuildContext context}) {
    return Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w500,
        );
  }

  static TextStyle? bold9({required BuildContext context}) {
    return Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
        );
  }
}
