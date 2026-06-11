// ignore_for_file: file_names

import 'package:flutter/material.dart';

@immutable
class VitalsModel {
  final String title;
  final String reading;
  final Widget suffixIcon;

  const VitalsModel({
    required this.title,
    required this.reading,
    required this.suffixIcon,
  });
}
