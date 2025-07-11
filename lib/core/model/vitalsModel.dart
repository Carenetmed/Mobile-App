import 'package:flutter/material.dart';

@immutable
class VitalsModel{
  final String title;
  final String reading;
  final Widget suffixIcon;

  VitalsModel({required this.title, required this.reading, required this.suffixIcon});
}