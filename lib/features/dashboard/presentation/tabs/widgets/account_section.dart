import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';

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
    final vc = context.vColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: EdgeInsets.only(left: 24.w, bottom: 16.h, top: 16.h),
            child: Text(
              title!.toUpperCase(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: vc.onSurfaceMuted,
                letterSpacing: 1.2,
              ),
            ),
          ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: vc.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: vc.divider),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
