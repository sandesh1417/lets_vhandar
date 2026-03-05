import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/app_style.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/features/home/providers/banner_provider.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 40.h),
          _buildBanner(),
          SizedBox(height: 24.h),
          _buildSectionTitle('Explore By Categories'),
          _buildCategoriesGrid(),
          SizedBox(height: 20.h),
          _buildSectionTitle('Top Selling'),
          _buildTopSellingList(),
          SizedBox(height: 20.h),
        ],
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
    final bannerAsync = ref.watch(bannerProvider);

    return bannerAsync.when(
      data: (banners) {
        if (banners.isEmpty) return const SizedBox.shrink();
        return Column(
          children: [
            SizedBox(
              height: 140.h,
              child: PageView.builder(
                controller: _pageController,
                itemCount: banners.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: CustomImageViewer(
                      path: banner.images?.first.url,
                      borderRadius: 16.r,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                banners.length,
                (index) => Container(
                  width: 8.w,
                  height: 8.w,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? AppColor.primary
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => Container(
        height: 140.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Text(
              title,
              style: KTextStyle.roboto16black5W
                  .copyWith(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text('See All', style: TextStyle(color: AppColor.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 0.w),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 15.h,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              height: 60.h,
              width: 60.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Icon(Icons.category_outlined,
                    color: Colors.grey, size: 24.sp),
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'Cat $index',
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
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
        padding: EdgeInsets.symmetric(horizontal: 0.w),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 140.w,
            margin: EdgeInsets.only(right: 12.w, bottom: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
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
