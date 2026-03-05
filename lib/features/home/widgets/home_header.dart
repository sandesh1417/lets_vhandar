import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/app_style.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 140.h,
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColor.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  SvgPicture.asset(
                    KImageConstant.vandharIcon,
                    height: 40.h,
                    colorFilter: const ColorFilter.mode(
                        Colors.yellow, BlendMode.srcIn), // Yellow V logo
                  ),
                  // Location Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Delivery in ',
                            style: KTextStyle.roboto14white4W,
                          ),
                          Text(
                            '19 Mins',
                            style: KTextStyle.roboto16white7W
                                .copyWith(fontSize: 18.sp),
                          ),
                          SizedBox(width: 4.w),
                          const Icon(Icons.timer,
                              color: Colors.white, size: 16),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Baneshwor - Baneshwor, Kathma..',
                            style: KTextStyle.roboto14white4W
                                .copyWith(fontSize: 12.sp),
                          ),
                          Icon(Icons.keyboard_arrow_down,
                              color: Colors.white, size: 16.sp),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // Search Bar
        Positioned(
          bottom: -25.h,
          left: 0,
          right: 0,
          child: Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for Vhandar products',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon:
                    const Icon(Icons.qr_code_scanner, color: Colors.black),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15.h),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
