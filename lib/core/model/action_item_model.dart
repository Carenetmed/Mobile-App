import 'package:flutter/material.dart';

@immutable
class ActionItem {
  final String text;
  final String assetPath;
  final void Function()? actButton;

  const ActionItem({
    required this.text,
    required this.assetPath,
    this.actButton,
  });
}
