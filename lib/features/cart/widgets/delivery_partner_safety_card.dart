import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

class DeliveryPartnerSafetyCard extends StatelessWidget {
  const DeliveryPartnerSafetyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          leading: Icon(Icons.two_wheeler_outlined,
              color: AppColor.primary, size: 28.sp),
          title: Text(
            'Delivery Partner\'s Safety',
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textBlack87),
          ),
          subtitle: Text(
            'Learn more about how we ensure their safety',
            style: TextStyle(fontSize: 12.sp, color: AppColor.textMuted),
          ),
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
              child: Column(
                children: [
                  Icon(Icons.shield_outlined,
                      size: 60.sp, color: Colors.green.shade200),
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
                        TextStyle(fontSize: 12.sp, color: AppColor.textMuted),
                  ),
                  SizedBox(height: 16.h),
                  _buildSafetyPoint(Icons.speed,
                      'Delivery partners ride safely at an average speed of 15kmph per delivery'),
                  SizedBox(height: 8.h),
                  _buildSafetyPoint(Icons.timer_off_outlined,
                      'No penalties for late deliveries & no incentives for on-time deliveries'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyPoint(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColor.primary, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColor.greenTxtColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
