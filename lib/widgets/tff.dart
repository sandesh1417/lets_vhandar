import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/color_constant.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final String? errorText;
  final String? labelText;
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
  final int? maxLines;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final Color? fillColor;
  final bool? filled;
  final EdgeInsetsGeometry? contentPadding;
  final bool autofocus;
  final bool? enabled;

  const CustomTextField({
    required this.hintText,
    this.labelText,
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
    this.maxLines = 1,
    this.textInputAction,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.fillColor,
    this.filled,
    this.contentPadding,
    this.autofocus = false,
    this.enabled,
  });

  final AutovalidateMode? autovalidateMode;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      readOnly: widget.isReadOnly ?? false,
      textAlignVertical: TextAlignVertical.center,
      controller: widget.controller,
      obscureText: widget.obscureText ?? false,
      keyboardType: widget.keyBoardType ?? TextInputType.emailAddress,
      maxLines: widget.obscureText == true ? 1 : widget.maxLines,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      focusNode: widget.focusNode,
      inputFormatters: widget.textInputFormatter != null
          ? [widget.textInputFormatter!]
          : null,
      onChanged: widget.onChanged ?? (v) {},
      style: TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w500,
        fontSize: 16.sp,
      ),
      decoration: InputDecoration(
        filled: widget.filled,
        fillColor: widget.fillColor,
        contentPadding: widget.contentPadding ??
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        isDense: true,
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14.sp,
        ),
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
        border: widget.border ??
            OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.r)),
                borderSide: BorderSide(color: AppColor.border)),
        enabledBorder: widget.enabledBorder,
        focusedBorder: widget.focusedBorder,
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
      autovalidateMode:
          widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
      validator: widget.validator,
    );
  }
}
