import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum CarenetTextFieldValidationState { none, valid, invalid }

class CarenetTextField extends StatefulWidget {
  const CarenetTextField({
    this.label,
    this.hintText,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.minLines,
    this.maxLines = 1,
    this.autovalidateMode,
    this.validationState = CarenetTextFieldValidationState.none,
    this.errorText,
    super.key,
  });

  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final int? minLines;
  final int? maxLines;
  final AutovalidateMode? autovalidateMode;
  final CarenetTextFieldValidationState validationState;
  final String? errorText;

  @override
  State<CarenetTextField> createState() => _CarenetTextFieldState();
}

class _CarenetTextFieldState extends State<CarenetTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late bool _ownsController;
  late bool _ownsFocusNode;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _controller.addListener(_handleStateChange);
    _focusNode.addListener(_handleStateChange);
  }

  @override
  void didUpdateWidget(covariant CarenetTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleStateChange);
      if (_ownsController) {
        _controller.dispose();
      }
      final nextOwnsController = widget.controller == null;
      _controller = widget.controller ?? TextEditingController();
      _controller.addListener(_handleStateChange);
      _ownsController = nextOwnsController;
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleStateChange);
      if (_ownsFocusNode) {
        _focusNode.dispose();
      }
      final nextOwnsFocusNode = widget.focusNode == null;
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_handleStateChange);
      _ownsFocusNode = nextOwnsFocusNode;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleStateChange);
    _focusNode.removeListener(_handleStateChange);
    if (_ownsController) {
      _controller.dispose();
    }
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _hasValue => _controller.text.isNotEmpty;

  _CarenetTextFieldColors get _colors {
    if (!widget.enabled) {
      return const _CarenetTextFieldColors(
        fill: CarenetColors.neutral100,
        border: CarenetColors.neutral200,
        text: CarenetColors.neutral300,
        hint: CarenetColors.neutral300,
        icon: CarenetColors.neutral500,
      );
    }

    switch (widget.validationState) {
      case CarenetTextFieldValidationState.valid:
        return const _CarenetTextFieldColors(
          fill: CarenetColors.white,
          border: CarenetColors.success100,
          text: CarenetColors.success100,
          hint: CarenetColors.success100,
          icon: CarenetColors.success100,
        );
      case CarenetTextFieldValidationState.invalid:
        return const _CarenetTextFieldColors(
          fill: CarenetColors.white,
          border: CarenetColors.error100,
          text: CarenetColors.error100,
          hint: CarenetColors.error100,
          icon: CarenetColors.error100,
        );
      case CarenetTextFieldValidationState.none:
        if (_hovered || _focusNode.hasFocus) {
          return const _CarenetTextFieldColors(
            fill: CarenetColors.white,
            border: CarenetColors.info100,
            text: CarenetColors.neutral700,
            hint: CarenetColors.neutral300,
            icon: CarenetColors.info100,
          );
        }
        return _CarenetTextFieldColors(
          fill: CarenetColors.white,
          border: CarenetColors.neutral200,
          text: _hasValue ? CarenetColors.neutral700 : CarenetColors.neutral300,
          hint: CarenetColors.neutral300,
          icon: CarenetColors.neutral300,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(6.r),
      borderSide: BorderSide(color: colors.border, width: 1),
    );
    final label = widget.label;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w400,
                color: CarenetColors.neutral700,
              ),
            ),
            SizedBox(height: 8.h),
          ],
          IconTheme(
            data: IconThemeData(color: colors.icon, size: 24.r),
            child: TextFormField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              obscureText: widget.obscureText,
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              autofillHints: widget.autofillHints,
              validator: widget.validator,
              onTap: widget.onTap,
              onChanged: widget.onChanged,
              onFieldSubmitted: widget.onFieldSubmitted,
              autovalidateMode: widget.autovalidateMode,
              cursorColor: colors.border,
              style: TextStyle(
                fontSize: 16.sp,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w400,
                color: colors.text,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: colors.hint,
                ),
                errorText:
                    widget.validationState ==
                            CarenetTextFieldValidationState.invalid
                        ? widget.errorText
                        : null,
                errorStyle: TextStyle(
                  fontSize: 10.sp,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: CarenetColors.error100,
                ),
                filled: true,
                fillColor: colors.fill,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                prefixIcon: widget.prefixIcon,
                prefixIconConstraints: BoxConstraints(
                  minWidth: 24.w,
                  minHeight: 24.h,
                ),
                suffixIcon: widget.suffixIcon,
                suffixIconConstraints: BoxConstraints(
                  minWidth: 24.w,
                  minHeight: 24.h,
                ),
                enabledBorder: border,
                focusedBorder: border,
                disabledBorder: border,
                border: border,
                errorBorder: border,
                focusedErrorBorder: border,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarenetTextFieldColors {
  const _CarenetTextFieldColors({
    required this.fill,
    required this.border,
    required this.text,
    required this.hint,
    required this.icon,
  });

  final Color fill;
  final Color border;
  final Color text;
  final Color hint;
  final Color icon;
}
