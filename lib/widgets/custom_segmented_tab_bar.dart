import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

class CustomSegmentedTabBar extends StatelessWidget {
  final List<String> tabLabels;
  final TabController? controller;
  final ValueChanged<int>? onTap;

  const CustomSegmentedTabBar({
    super.key,
    required this.tabLabels,
    this.controller,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F3),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: TabBar(
        controller: controller,
        onTap: onTap,
        dividerColor: Colors.transparent, // Removes the bottom line
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          color: AppColor.primary,
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColor.textBlack54,
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        tabs: tabLabels.map((label) => Tab(text: label)).toList(),
      ),
    );
  }
}
