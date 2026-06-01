import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

class LocationNotServiceableScreen extends StatelessWidget {
  const LocationNotServiceableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return CustomScaffoldWrapper(
      isScrollable: true,
      horizontalPadding: 24,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.location_off_rounded,
              size: 80.sp, color: vc.onSurfaceMuted),
          SizedBox(height: 20.h),
          Text(
            'Location not serviceable',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: vc.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Our team is working tirelessly to bring fast deliveries to your location. Try a different address.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: vc.onSurfaceMuted,
              height: 1.5,
            ),
          ),
          SizedBox(height: 28.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Try Changing Location',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
