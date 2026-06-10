import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/profile/presentation/product_suggestion_screen.dart';

class HomeSuggestCard extends StatelessWidget {
  const HomeSuggestCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color:
            context.isDark ? const Color(0xFF1A2E25) : const Color(0xFFE8F5EF),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "Didn't find ",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          color: context.isDark
                              ? const Color(0xFFB2DFCB)
                              : const Color(0xFF1A3D2E),
                          height: 1.3,
                        ),
                      ),
                    ),
                    Image.asset(
                      KImageConstant.sadFaceGif,
                      width: 28.w,
                      height: 28.w,
                    ),
                  ],
                ),
                Text(
                  'what you were looking for?',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    color: context.isDark
                        ? const Color(0xFFB2DFCB)
                        : const Color(0xFF1A3D2E),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Suggest something & we'll look into it",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    color: vc.onSurfaceMuted,
                  ),
                ),
                SizedBox(height: 20.h),
                OutlinedButton(
                  onPressed: () => showProductSuggestionSheet(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.secondary,
                    side: BorderSide(color: AppColor.secondary, width: 1.5),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Suggest a Product',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          SvgPicture.asset(
            'assets/images/suggest_product.svg',
            width: 110.w,
            height: 110.w,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
