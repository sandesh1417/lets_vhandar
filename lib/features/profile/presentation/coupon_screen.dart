import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

class CouponScreen extends StatelessWidget {
  const CouponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomScreenHeader(title: 'Coupon Code & Discount'),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                KImageConstant.couponCode,
                width: 120.w,
                height: 120.w,
              ),
              SizedBox(height: 24.h),
              Text(
                'No Coupons Available',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: vc.onSurface,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Your available coupon codes and\ndiscount offers will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: vc.onSurfaceMuted,
                  fontFamily: 'Inter',
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
