import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/color_constant.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final String? errorText;
  final String labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool? obscureText;
  final bool? isReadOnly;
  final Function(String)? onChanged;
  final Function()? onObscurePressed;
  final TextEditingController? controller;
  final TextInputType? keyBoardType;
  final TextInputFormatter? textInputFormatter;
  final String? Function(String?)? validator;

  const CustomTextField({
    required this.hintText,
    required this.labelText,
    this.prefixIcon,
    this.onChanged,
    this.suffixIcon,
    this.obscureText,
    this.onObscurePressed,
    this.controller,
    this.errorText,
    this.keyBoardType,
    super.key,
    this.isReadOnly = false,
    this.textInputFormatter,
    this.validator,
    this.autovalidateMode,
  });

  final AutovalidateMode? autovalidateMode;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: widget.isReadOnly ?? false,
      textAlignVertical: TextAlignVertical.center,
      controller: widget.controller,
      obscureText: widget.obscureText ?? false,
      keyboardType: widget.keyBoardType ?? TextInputType.emailAddress,
      inputFormatters: widget.textInputFormatter != null
          ? [widget.textInputFormatter!]
          : null,
      onChanged: widget.onChanged ?? (v) {},
      style: TextStyle(color: AppColor.black),
      decoration: InputDecoration(
        contentPadding: widget.prefixIcon == null
            ? EdgeInsets.symmetric(horizontal: 12.w)
            : null,
        isDense: true,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: AppColor.hintText),
        prefixIcon: widget.prefixIcon != null
            ? SizedBox(child: widget.prefixIcon)
            : null,
        suffixIcon: widget.obscureText != null
            ? GestureDetector(
                onTap: widget.onObscurePressed ?? () {},
                child: !widget.obscureText!
                    ? Icon(
                        Icons.visibility_off_outlined,
                        color: AppColor.icon,
                        size: 16.sp,
                      )
                    : Icon(
                        Icons.visibility_outlined,
                        color: AppColor.icon,
                        size: 16.sp,
                      ),
              )
            : widget.suffixIcon,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.r)),
            borderSide: BorderSide(color: AppColor.border)),
        labelStyle: TextStyle(color: AppColor.error),
      ),
      autovalidateMode:
          widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
      validator: widget.validator,
    );
  }
}
