import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:pinput/pinput.dart';

class PinputExample extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final GlobalKey<FormState> formKey;
  final Function(String) onCompleted;
  final String? Function(String?)? validator;

  const PinputExample({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.formKey,
    required this.onCompleted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTheme = PinTheme(
      width: 56.w,
      height: 58.h,
      textStyle: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        color: AppColor.primary,
      ),
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColor.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
    );

    final focusedTheme = defaultTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColor.primary, width: 2),
      ),
    );

    final submittedTheme = defaultTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColor.primary, width: 1.5),
      ),
    );

    final errorTheme = defaultTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.redAccent, width: 1.5),
      ),
    );

    return Form(
      key: formKey,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Pinput(
          length: 5,
          controller: controller,
          focusNode: focusNode,
          defaultPinTheme: defaultTheme,
          focusedPinTheme: focusedTheme,
          submittedPinTheme: submittedTheme,
          errorPinTheme: errorTheme,
          separatorBuilder: (_) => SizedBox(width: 10.w),
          validator: validator,
          hapticFeedbackType: HapticFeedbackType.lightImpact,
          onCompleted: onCompleted,
          cursor: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10.h),
                width: 20.w,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
