import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/features/home/providers/brand_provider.dart';
import 'package:lets_vhandar/features/home/providers/category_provider.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

import 'widgets/brand_card.dart';
import 'widgets/category_card.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoryProvider);
    final brandsAsync = ref.watch(brandProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        child: Column(
          children: [
            const CustomScreenHeader(title: 'Explore'),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Brands Section ---
                    brandsAsync.when(
                      data: (brands) => _buildBrandSection(context, brands),
                      loading: () => const SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator())),
                      error: (err, _) => const SizedBox.shrink(),
                    ),

                    SizedBox(height: 8.h),

                    // --- Categories Section ---
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Text(
                        'Shop by Category',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.textBlack,
                        ),
                      ),
                    ),
                    categoriesAsync.when(
                      data: (categories) =>
                          _buildCategoryGrid(context, categories),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text("Error: $err")),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandSection(BuildContext context, List<dynamic> brands) {
    if (brands.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Brands',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textBlack,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/brands'),
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            // itemCount: brands.length > 15 ? 15 : brands.length,
            itemCount: brands.length,
            separatorBuilder: (context, index) => SizedBox(width: 16.w),
            itemBuilder: (context, index) {
              final brand = brands[index];
              return SizedBox(
                width: 75.w,
                child: BrandCard(
                  name: brand.name ?? '',
                  imageUrl: brand.images?.isNotEmpty == true
                      ? brand.images!.first.url
                      : null,
                  onTap: () => navigateToSlug(context, brand.slug, isBrand: true),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Divider(color: Colors.grey.shade100, thickness: 1),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid(BuildContext context, List<dynamic> categories) {
    if (categories.isEmpty)
      return const Center(child: Text("No categories found"));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.82,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard(
          name: category.name ?? '',
          imageUrl: category.images?.isNotEmpty == true
              ? category.images!.first.url
              : null,
          onTap: () => navigateToSlug(context, category.slug, isBrand: false),
        );
      },
    );
  }
}
