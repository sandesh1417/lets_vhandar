import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/home/providers/brand_provider.dart';
import 'package:lets_vhandar/features/home/providers/category_provider.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:lets_vhandar/widgets/custom_segmented_tab_bar.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoryProvider);
    final brandsAsync = ref.watch(brandProvider);

    return Container(
      color: const Color(0xFFF5F6F8), // Matching CartScreen background
      child: Column(
        children: [
          const CustomScreenHeader(
            title: 'Categories & Brands',
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const CustomSegmentedTabBar(
                    tabLabels: ['Categories', 'Brands'],
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // --- Categories Tab ---
                        categoriesAsync.when(
                          data: (categories) => Column(
                            children: [
                              // _buildSectionTitle('Categories'),
                              Expanded(
                                  child:
                                      _buildCategoryGrid(context, categories)),
                            ],
                          ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, _) => Center(child: Text("Error: $err")),
                        ),

                        // --- Brands Tab ---
                        brandsAsync.when(
                          data: (brands) => Column(
                            children: [
                              // _buildSectionTitle('Brands'),
                              Expanded(child: _buildBrandGrid(context, brands)),
                            ],
                          ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, _) => Center(child: Text("Error: $err")),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, top: 12.h, bottom: 4.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, List<dynamic> categories) {
    if (categories.isEmpty)
      return const Center(child: Text("No categories found"));

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 14.w,
        mainAxisSpacing: 18.h,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return InkWell(
          onTap: () => context.push('/category-detail/${category.slug}'),
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            children: [
              Container(
                height: 90.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: CustomImageViewer(
                    path: category.images?.isNotEmpty == true
                        ? category.images!.first.url
                        : null,
                    borderRadius: 12.r,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  category.name ?? '',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textBlack,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBrandGrid(BuildContext context, List<dynamic> brands) {
    if (brands.isEmpty) return const Center(child: Text("No brands found"));

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: brands.length,
      itemBuilder: (context, index) {
        final brand = brands[index];
        return InkWell(
          onTap: () => context.push('/brand-detail/${brand.slug}'),
          borderRadius: BorderRadius.circular(12.r),
          child: Column(
            children: [
              Container(
                height: 65.h,
                width: 65.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: CustomImageViewer(
                    path: brand.images?.isNotEmpty == true
                        ? brand.images!.first.url
                        : null,
                    borderRadius: 30.r,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                brand.name ?? '',
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textBlack54,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
