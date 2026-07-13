import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Blueprint `screens/buttons/` — Primary + Outline (Secondary), Large size.
enum CarenetButtonType { primary, outline }

/// Large only in Phase 1 task 1.2; medium/small reserved for later.
enum CarenetButtonSize { large }

class CarenetButton extends StatelessWidget {
  const CarenetButton({
    required this.label,
    required this.onPressed,
    this.type = CarenetButtonType.primary,
    this.size = CarenetButtonSize.large,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final CarenetButtonType type;
  final CarenetButtonSize size;

  bool get _enabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle();
    final textStyle = TextStyle(
      fontSize: 16.sp,
      fontFamily: AppFonts.montserrat,
      fontWeight: FontWeight.w400,
      color: style.foreground,
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: label,
      child: Material(
        color: style.background,
        elevation: 0,
        borderRadius: BorderRadius.circular(8.r),
        child: InkWell(
          onTap: _enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(8.r),
          splashColor: style.splash,
          highlightColor: style.highlight,
          child: Ink(
            height: 48.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: BorderRadius.circular(8.r),
              border: style.border,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Center(
              child: Text(label, style: textStyle, textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }

  _CarenetButtonStyle _resolveStyle() {
    switch (type) {
      case CarenetButtonType.primary:
        if (!_enabled) {
          return const _CarenetButtonStyle(
            background: CarenetColors.neutral100,
            foreground: CarenetColors.neutral300,
            splash: Colors.transparent,
            highlight: Colors.transparent,
          );
        }
        return _CarenetButtonStyle(
          background: CarenetColors.brand,
          foreground: CarenetColors.white,
          splash: CarenetColors.primary400.withValues(alpha: 0.24),
          highlight: CarenetColors.primary600.withValues(alpha: 0.12),
        );
      case CarenetButtonType.outline:
        if (!_enabled) {
          return const _CarenetButtonStyle(
            background: CarenetColors.white,
            foreground: CarenetColors.neutral300,
            border: Border.fromBorderSide(
              BorderSide(color: CarenetColors.neutral200, width: 1),
            ),
            splash: Colors.transparent,
            highlight: Colors.transparent,
          );
        }
        return _CarenetButtonStyle(
          background: CarenetColors.white,
          foreground: CarenetColors.brand,
          border: Border.all(color: CarenetColors.brand, width: 1),
          splash: CarenetColors.primary100.withValues(alpha: 0.8),
          highlight: CarenetColors.primary100,
        );
    }
  }
}

class _CarenetButtonStyle {
  const _CarenetButtonStyle({
    required this.background,
    required this.foreground,
    this.border,
    this.splash = CarenetColors.primary100,
    this.highlight = CarenetColors.primary100,
  });

  final Color background;
  final Color foreground;
  final BoxBorder? border;
  final Color splash;
  final Color highlight;
}
