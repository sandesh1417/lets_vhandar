import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';

class CancellationPolicyCard extends StatelessWidget {
  const CancellationPolicyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cancellation Policy',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: vc.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Orders cannot be cancelled once packed for delivery. In case of unexpected delays, a refund will be provided, if applicable.',
            style: TextStyle(
              fontSize: 12.sp,
              color: vc.onSurfaceMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
