
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BorderedTextInput extends StatelessWidget {
  final TextInputType? keyboardType1;
  final TextInputType? keyboardType2;
  final String? hintText1;
  final String? hintText2;
  final Widget? suffixIcon1;
  final Widget? suffixIcon2;
  final bool readOnly1;
  final bool readOnly2;
  final void Function()? onTap1;
  final void Function(String)? onFieldSubmitted1;
  final void Function(String)? onChanged1;
  final void Function()? onTap2;
  final void Function(String)? onFieldSubmitted2;
  final void Function(String)? onChanged2;
  final TextEditingController? controller1;
  final TextEditingController? controller2;
  final  bool obscureText1;
  final  bool obscureText2;
  final String? Function(String?)? validator1;
  final String? Function(String?)? validator2;

  const BorderedTextInput({
    super.key,
     this.keyboardType1,
     this.keyboardType2,
    required this.hintText1,
    required this.hintText2,
    this.readOnly1 = false,
    this.readOnly2 = false,
    this.suffixIcon1,
    this.suffixIcon2, this.onTap1, this.onFieldSubmitted1, this.onChanged1, this.onTap2, this.onFieldSubmitted2, this.onChanged2, this.controller1, this.controller2,
     this.obscureText1 = false,
     this.obscureText2 = false, this.validator1, this.validator2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 1),
          borderRadius: BorderRadius.circular(8.r)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextFormField(
            keyboardType: keyboardType1,
            obscureText: obscureText1,
            controller: controller1,
            validator: validator1,
            readOnly: readOnly1,
            onChanged: onChanged1,
            onFieldSubmitted: onFieldSubmitted1,
            onTap: onTap1,
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              suffixIcon: suffixIcon1,
              constraints: BoxConstraints(maxHeight: 40.h),
              contentPadding:  REdgeInsets.only(
                left: 8.r,
                right: 8.r,
              ),
              hintText: hintText1,
              hintStyle: TextStyle(
                fontSize: 16.sp,
                color: AppColors.white04,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w400,
              ),
              errorStyle: TextStyle(
              fontSize: FontSizes.footer2,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
            ),
              border: InputBorder.none,
            ),
          ),
          const Divider(
            thickness: 1.8,
          ),
          TextFormField(
            keyboardType: keyboardType2,
            validator: validator2,
            obscureText: obscureText2,
            controller: controller2,
            readOnly: readOnly2,
            onChanged: onChanged2,
            onFieldSubmitted: onFieldSubmitted2,
            onTap: onTap2,
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              suffixIcon: suffixIcon2,
              constraints: BoxConstraints(maxHeight: 40.h),
              contentPadding: REdgeInsets.only(
                left: 8.r,
                right: 8.r,
              ),
              hintText: hintText2,
              hintStyle: TextStyle(
                fontSize: 16.sp,
                color: AppColors.white04,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w400,
              ),
              errorStyle: TextStyle(
                fontSize: FontSizes.footer2,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
            ),
          )
        ],
      ),
    );
  }
}


class TextInput extends StatelessWidget {
  final TextInputType keyboardType;
  final String hintText;
  final Widget? suffixIcon;
  final void Function()? onTap;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final  bool obscureText;
  final String? Function(String?)? validator;
  const TextInput({super.key, required this.keyboardType, required this.hintText, this.suffixIcon, this.onTap, this.onFieldSubmitted, this.onChanged, this.controller,  this.obscureText = false, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onTap: onTap,
      style: TextStyle(
        fontSize: 16.sp,
        fontFamily: AppFonts.montserrat,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(

        suffixIcon: suffixIcon,
        // constraints: BoxConstraints(maxHeight: 40.h),
        contentPadding:  REdgeInsets.only(
          left: 8.r,
          right: 8.r,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 16.sp,
          color: AppColors.white04,
          fontFamily: AppFonts.montserrat,
          fontWeight: FontWeight.w400,
        ),
        errorStyle: TextStyle(
          fontSize: FontSizes.footer2,
          fontFamily: AppFonts.montserrat,
          fontWeight: FontWeight.w400,
        ),
        border: InputBorder.none,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(width: 1)
        ),
      ),
    );
  }
}
