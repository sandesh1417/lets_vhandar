import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

class AccountSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const AccountSection({
    super.key,
    this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title == null
            ? const SizedBox()
            : Padding(
                padding: EdgeInsets.only(left: 24.w, bottom: 16.h, top: 16.h),
                child: Text(
                  title!.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColor.border.withValues(alpha: 0.55),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
