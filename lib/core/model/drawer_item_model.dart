import 'package:flutter/material.dart';

@immutable
class DrawerItem {
  final String label;
  final String assetPath;
  final void Function()? actButton;

  const DrawerItem({
    required this.label,
    required this.assetPath,
    this.actButton,
  });
}
