import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/features/home/providers/brand_provider.dart';
import 'package:lets_vhandar/features/home/providers/category_provider.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';

import 'package:lets_vhandar/widgets/premium_search_bar.dart';

import 'widgets/brand_card.dart';
import 'widgets/category_card.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(allCategoryProvider);
    final brandsAsync = ref.watch(brandProvider);

    return CustomScaffoldWrapper(
      backgroundColor: AppColor.primary,
      isScrollable: false,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // ── Green header: logo + search ────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 12.h),
            child: Row(
              children: [
                SvgPicture.asset(
                  KImageConstant.vandharIcon,
                  height: 36.h,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PremiumSearchBar(
                    controller: _searchController,
                    hintText: "Search for categories...",
                    showScanIcon: true,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim().toLowerCase();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── White rounded content panel ────────────────────────────
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
              child: Container(
                color: const Color(0xFFFBFBFB),
                child: categoriesAsync.when(
                  data: (categories) {
                    return brandsAsync.when(
                      data: (brands) {
                        final filteredBrands = _searchQuery.isEmpty
                            ? brands
                            : brands
                                .where((brand) => (brand.name ?? '')
                                    .toLowerCase()
                                    .contains(_searchQuery))
                                .toList();

                        final filteredCategories = _searchQuery.isEmpty
                            ? categories
                            : categories
                                .where((cat) => (cat.name ?? '')
                                    .toLowerCase()
                                    .contains(_searchQuery))
                                .toList();

                        if (filteredBrands.isEmpty &&
                            filteredCategories.isEmpty) {
                          return const Center(
                            child: Text(
                              "No matching categories or brands found",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }

                        return RefreshIndicator(
                          color: AppColor.primary,
                          onRefresh: () async {
                            ref.invalidate(allCategoryProvider);
                            ref.invalidate(brandProvider);
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (filteredBrands.isNotEmpty) ...[
                                  _buildBrandSection(context, filteredBrands),
                                  SizedBox(height: 8.h),
                                ],
                                if (filteredCategories.isNotEmpty) ...[
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 8.h),
                                    child: Text(
                                      'Shop by Category',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.textBlack,
                                      ),
                                    ),
                                  ),
                                  _buildCategoryGrid(
                                      context, filteredCategories),
                                ],
                                SizedBox(height: 32.h),
                              ],
                            ),
                          ),
                        );
                      },
                      loading: () => _buildLoadingShimmer(),
                      error: (err, _) => Center(child: Text("Error: $err")),
                    );
                  },
                  loading: () => _buildLoadingShimmer(),
                  error: (err, _) => Center(child: Text("Error: $err")),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
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
                Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primary,
                  ),
                ),
              ],
            ),
          ),
          const HorizontalListShimmer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Divider(color: Colors.grey.shade100, thickness: 1),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              'Shop by Category',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textBlack,
              ),
            ),
          ),
          const GridShimmer(crossAxisCount: 4, isCircle: false),
        ],
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
                  onTap: () =>
                      navigateToSlug(context, brand.slug, isBrand: true),
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
    if (categories.isEmpty) {
      return const Center(child: Text("No categories found"));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.68,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 12.h,
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
