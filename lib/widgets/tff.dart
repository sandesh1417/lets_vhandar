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

  const CustomTextField(
      {required this.hintText,
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
      this.textInputFormatter});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
          color: (widget.errorText == null)
              ? Colors.transparent
              : AppColor.error.withOpacity(0),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4.r), topRight: Radius.circular(4.r))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              // color: AppColor.white.withOpacity(0.2),
              border: Border.all(
                color: (widget.errorText == null)
                    ? AppColor.border
                    : AppColor.error,
              ),
              // boxShadow: [
              //   BoxShadow(
              //       offset: const Offset(2, 6),
              //       blurRadius: 6,
              //       color: Colors.black.withOpacity(0.07))
              // ],
            ),
            height: 50.h,
            child: Center(
              child: TextField(
                readOnly: widget.isReadOnly ?? false,
                textAlignVertical: TextAlignVertical.center,
                controller: widget.controller,
                obscureText: widget.obscureText ?? false,
                keyboardType: widget.keyBoardType,
                inputFormatters: widget.textInputFormatter != null
                    ? [widget.textInputFormatter!]
                    : null,
                onChanged: widget.onChanged ?? (v) {},
                style: TextStyle(color: AppColor.white),
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
                  border: InputBorder.none,
                  labelStyle: TextStyle(color: AppColor.error),
                ),
              ),
            ),
          ),
          // SizedBox(
          //   height: 4.h,
          // ),
          (widget.errorText == null)
              ? const SizedBox()
              : SizedBox(
                  width: double.maxFinite,
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.h, top: 2.h, bottom: 2.h),
                    child: Text(
                      (widget.errorText == null)
                          ? widget.labelText
                          : widget.errorText ?? "error",
                      style: TextStyle(
                          color: (widget.errorText == null)
                              ? AppColor.white
                              : AppColor.error,
                          fontSize: 10.sp),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
