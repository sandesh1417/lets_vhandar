import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';


class ProductWhyShopSection extends StatelessWidget {
  const ProductWhyShopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColor.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why shop from Vhandar?',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: context.vColors.onSurface,
            ),
          ),
          SizedBox(height: 14.h),
          _buildItem(context,
            'assets/images/why_delivery.svg',
            'Express Delivery',
            'Delivered to your doorstep from nearby dark stores.',
          ),
          _buildItem(context,
            'assets/images/why_price.svg',
            'Best Prices & Offers',
            'Direct deals from manufacturers — lowest prices guaranteed.',
          ),
          _buildItem(context,
            'assets/images/why_assortment.svg',
            'Wide Assortment',
            '5000+ products across all major categories.',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String svgAsset, String title, String subtitle,
      {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            svgAsset,
            width: 36.w,
            height: 36.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: context.vColors.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: context.vColors.onSurfaceMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
