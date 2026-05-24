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
  final List<String>? autofillHints;
  final String? prefixText;

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
    this.autofillHints,
    this.prefixText,
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
      autofillHints: widget.autofillHints,
      inputFormatters: widget.textInputFormatter != null
          ? [widget.textInputFormatter!]
          : null,
      onChanged: widget.onChanged ?? (v) {},
      style: TextStyle(
        color: const Color(0xFF1A1A1A),
        fontWeight: FontWeight.w500,
        fontSize: 15.sp,
      ),
      decoration: InputDecoration(
        filled: widget.filled ?? true,
        fillColor: widget.fillColor ?? const Color(0xFFF7F8F8),
        contentPadding: widget.contentPadding ??
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        isDense: true,
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: const Color(0xFFADB5B2),
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: widget.prefixIcon,
        prefixIconConstraints:
            BoxConstraints(minWidth: 48.w, minHeight: 0),
        prefixText: widget.prefixText,
        prefixStyle: TextStyle(
          color: const Color(0xFF1A1A1A),
          fontWeight: FontWeight.w500,
          fontSize: 15.sp,
        ),
        suffixIcon: widget.obscureText != null
            ? GestureDetector(
                onTap: widget.onObscurePressed ?? () {},
                child: !widget.obscureText!
                    ? Icon(
                        Icons.visibility_off_outlined,
                        color: const Color(0xFF9AA5A1),
                        size: 18.sp,
                      )
                    : Icon(
                        Icons.visibility_outlined,
                        color: const Color(0xFF9AA5A1),
                        size: 18.sp,
                      ),
              )
            : widget.suffixIcon,
        border: widget.border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.r)),
              borderSide: const BorderSide(color: Color(0xFFE2E8E5)),
            ),
        enabledBorder: widget.enabledBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.r)),
              borderSide: const BorderSide(color: Color(0xFFE2E8E5)),
            ),
        focusedBorder: widget.focusedBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.r)),
              borderSide: const BorderSide(
                  color: Color(0xFF2D3748), width: 1.5),
            ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.r)),
          borderSide: BorderSide(color: AppColor.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.r)),
          borderSide: BorderSide(color: AppColor.error, width: 1.5),
        ),
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: const Color(0xFF8C9A95),
          fontWeight: FontWeight.w400,
          fontSize: 14.sp,
        ),
        floatingLabelStyle: TextStyle(
          color: const Color(0xFF2D3748),
          fontWeight: FontWeight.w600,
          fontSize: 13.sp,
        ),
      ),
      cursorColor: const Color(0xFF2D3748),
      autovalidateMode:
          widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
      validator: widget.validator,
    );
  }
}
