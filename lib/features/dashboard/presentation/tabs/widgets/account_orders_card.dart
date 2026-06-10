import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';

class AccountOrdersCard extends StatelessWidget {
  const AccountOrdersCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            KImageConstant.deliveryInformation,
            width: 34.w,
            height: 34.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Orders',
                  style: TextStyle(
                    color: vc.onSurface,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'View all your purchases, manage your orders or start a return.',
                  style: TextStyle(
                    color: vc.onSurfaceMuted,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.chevron_right_rounded, color: vc.onSurfaceMuted, size: 20.sp),
        ],
      ),
    );
  }
}
