import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

class CustomCircularLoader extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const CustomCircularLoader({
    super.key,
    this.size = 24.0,
    this.strokeWidth = 3.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.w,
      height: size.w,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColor.primary),
        strokeCap: StrokeCap.round,
      ),
    );
  }
}
