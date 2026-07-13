import 'package:flutter/material.dart';

@immutable
class AuthenticationModel {
  final void Function()? btnAction;
  final String assetPath;
  final String title;

  const AuthenticationModel({
    this.btnAction,
    required this.assetPath,
    required this.title,
  });
}
