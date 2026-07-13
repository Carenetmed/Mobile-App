import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:flutter/material.dart';

/// Legacy API — delegates to [CarenetButton]. Prefer [CarenetButton] in new code.
class CarenetButtonFilled extends StatelessWidget {
  const CarenetButtonFilled({
    required this.btnAction,
    required this.btnName,
    super.key,
  });

  final VoidCallback btnAction;
  final String btnName;

  @override
  Widget build(BuildContext context) {
    return CarenetButton(
      label: btnName,
      onPressed: btnAction,
      type: CarenetButtonType.primary,
    );
  }
}

/// Legacy API — delegates to [CarenetButton]. Prefer [CarenetButton] in new code.
class CarenetButtonOutline extends StatelessWidget {
  const CarenetButtonOutline({
    required this.btnAction,
    required this.btnName,
    super.key,
  });

  final VoidCallback btnAction;
  final String btnName;

  @override
  Widget build(BuildContext context) {
    return CarenetButton(
      label: btnName,
      onPressed: btnAction,
      type: CarenetButtonType.outline,
    );
  }
}
