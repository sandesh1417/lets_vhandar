import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';

class GuestLoginWall extends StatelessWidget {
  final String title;
  final String subtitle;

  const GuestLoginWall({
    super.key,
    this.title = 'Login Required',
    this.subtitle = 'Please login or create an account to continue.',
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/vhandar-home.svg',
              width: 80.w,
              height: 80.w,
              colorFilter: ColorFilter.mode(
                AppColor.primary.withValues(alpha: 0.25),
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: vc.onSurface,
                height: 1.3,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                color: vc.onSurfaceMuted,
                height: 1.5,
              ),
            ),
            SizedBox(height: 28.h),
            CustomElevatedButton(
              width: double.infinity,
              height: 50.h,
              backgroundColor: AppColor.secondary,
              onPressed: () => context.go(LVRoute.loginScreen.route),
              text: 'Login / Sign Up',
            ),
          ],
        ),
      ),
    );
  }
}
