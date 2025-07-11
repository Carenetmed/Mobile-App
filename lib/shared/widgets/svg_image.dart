import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgImage extends StatelessWidget {
  final double? width;
  final double? height;
  final String imgName;
  const SvgImage({super.key, this.width, this.height, required this.imgName});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      imgName,
      width: width,
      height: height,
      fit: BoxFit.fitHeight,
    );
  }
}