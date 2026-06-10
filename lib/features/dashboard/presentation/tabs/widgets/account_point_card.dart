import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';

class AccountPointCard extends StatelessWidget {
  final int points;

  const AccountPointCard({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: vc.divider)),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            KImageConstant.pointsBadge,
            width: 34.w,
            height: 34.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  KImageConstant.vhandarPoints,
                  height: 22.h,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                ),
                SizedBox(height: 5.h),
                Text(
                  'Earn rewards on every order',
                  style: TextStyle(
                    color: vc.onSurfaceMuted,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$points pts',
              style: TextStyle(
                color: AppColor.primary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
