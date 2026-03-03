import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/app_style.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20.h),
              _buildBanner(),
              SizedBox(height: 20.h),
              _buildSectionTitle('Explore By Categories'),
              _buildCategoriesGrid(),
              SizedBox(height: 20.h),
              _buildSectionTitle('Top Selling'),
              _buildTopSellingList(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 140.h,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
          left: 16.w,
          right: 16.w,
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

  Widget _buildBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      height: 140.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1F3A2F), // Dark green banner bg
        borderRadius: BorderRadius.circular(16.r),
        image: const DecorationImage(
          image: NetworkImage(
              "https://via.placeholder.com/350x150"), // Placeholder banner image
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Simulated content based on image
          Positioned(
            left: 20.w,
            top: 20.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F3A2F),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'Best deals',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  width: 150.w,
                  child: Text(
                    'Get 1 Tender Coconut at ₹19',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Valid on Fruits & Veggies\norders over ₹99',
                  style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                ),
              ],
            ),
          ),
          // Coconut image placeholder would be part of the background or positioned image
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F3A2F)),
          ),
          Text(
            'See All >',
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
        childAspectRatio: 0.8,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9), // Light green bg
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Icon(Icons.category,
                      color: AppColor.primary.withOpacity(0.5), size: 30.sp),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Category',
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopSellingList() {
    return SizedBox(
      height: 180.h,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 120.w,
            margin: EdgeInsets.only(right: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 100.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(12.r)),
                      ),
                      child: Center(
                        child: Icon(Icons.image,
                            color: Colors.grey.shade300, size: 40.sp),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12.r),
                              bottomRight: Radius.circular(12.r)),
                        ),
                        child: Column(
                          children: [
                            Text('SAVE',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.bold)),
                            Text('₹10',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Product Name',
                          style: TextStyle(
                              fontSize: 12.sp, fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: 4.h),
                      Text('₹99',
                          style: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
