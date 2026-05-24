import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

class DeliveryPartnerSafetyCard extends StatelessWidget {
  const DeliveryPartnerSafetyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          leading: SvgPicture.asset(
            'assets/icons/vhandar_delivery_information.svg',
            width: 28.w,
            height: 28.w,
          ),
          title: Text(
            'Delivery Partner\'s Safety',
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textBlack),
          ),
          subtitle: Text(
            'Learn more about how we ensure their safety',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
          ),
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/icons/vhandar_rider.svg',
                    width: 140.w,
                    height: 130.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Here\'s How We Do It',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textBlack),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'At Vhandar, Rider\'s safety is our responsibility',
                    style:
                        TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  _buildSafetyPoint(
                    'assets/icons/vhandar_speed.svg',
                    'Delivery partners ride safely at an average speed of 15kmph per delivery',
                  ),
                  SizedBox(height: 8.h),
                  _buildSafetyPoint(
                    'assets/icons/vhandar_clock.svg',
                    'No penalties for late deliveries & no incentives for on-time deliveries',
                  ),
                  SizedBox(height: 8.h),
                  _buildSafetyPoint(
                    'assets/icons/vhandar_announce.svg',
                    'Delivery partners are not informed about promised delivery time',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyPoint(String svgPath, String text) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(svgPath, width: 20.w, height: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColor.textBlack,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
