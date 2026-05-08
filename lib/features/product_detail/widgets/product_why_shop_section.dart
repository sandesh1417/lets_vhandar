import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

class ProductWhyShopSection extends StatelessWidget {
  const ProductWhyShopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColor.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why shop from Vhandar?',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.textBlack,
            ),
          ),
          SizedBox(height: 14.h),
          _buildItem(
            Icons.delivery_dining_outlined,
            'Superfast Delivery',
            'Delivered to your doorstep from nearby dark stores.',
          ),
          _buildItem(
            Icons.sell_outlined,
            'Best Prices & Offers',
            'Direct deals from manufacturers — lowest prices guaranteed.',
          ),
          _buildItem(
            Icons.category_outlined,
            'Wide Assortment',
            '5000+ products across all major categories.',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, String subtitle,
      {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: AppColor.primary, size: 20.sp),
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
                    color: AppColor.textBlack,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColor.textMuted,
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
