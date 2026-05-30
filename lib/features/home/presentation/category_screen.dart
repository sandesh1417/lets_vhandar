import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/features/dashboard/providers/dashboard_provider.dart';
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
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(allCategoryProvider);
    final brandsAsync = ref.watch(brandProvider);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return CustomScaffoldWrapper(
      backgroundColor: AppColor.primary,
      isScrollable: false,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // ── Green header: logo + search ────────────────────────────
          Container(
            color: AppColor.primary,
            padding: EdgeInsets.only(
              top: statusBarHeight + 16.h,
              left: 16.w,
              right: 16.w,
              bottom: 12.h,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => ref.read(dashboardIndexProvider.notifier).state = 0,
                  child: SvgPicture.asset(
                    KImageConstant.vandharIcon,
                    height: 38.h,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PremiumSearchBar(
                    controller: TextEditingController(),
                    hintText: "Search for products...",
                    readOnly: true,
                    showScanIcon: true,
                    onTap: () => context.pushNamed(LVRoute.searchScreen.route),
                  ),
                ),
              ],
            ),
          ),

          // ── Content panel ──────────────────────────────────────────
          Expanded(
            child: Container(
              color: context.vColors.scaffoldBg,
              child: categoriesAsync.when(
                data: (categories) {
                  return brandsAsync.when(
                    data: (brands) {
                      return RefreshIndicator(
                        color: AppColor.primary,
                        onRefresh: () async {
                          ref.invalidate(allCategoryProvider);
                          ref.invalidate(brandProvider);
                        },
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (brands.isNotEmpty) ...[
                                _buildBrandSection(context, brands),
                                SizedBox(height: 8.h),
                              ],
                              if (categories.isNotEmpty) ...[
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 8.h),
                                  child: Text(
                                    'Shop by Category',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: context.vColors.onSurface,
                                    ),
                                  ),
                                ),
                                _buildCategoryGrid(context, categories),
                              ],
                              SizedBox(
                                  height: MediaQuery.of(context).padding.bottom +
                                      150.h),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => _buildLoadingShimmer(context),
                    error: (err, _) => Center(child: Text('Error: $err')),
                  );
                },
                loading: () => _buildLoadingShimmer(context),
                error: (err, _) => Center(child: Text("Error: $err")),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
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
                    color: context.vColors.onSurface,
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
            child: Divider(color: context.vColors.divider, thickness: 1),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              'Shop by Category',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: context.vColors.onSurface,
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
                  color: context.vColors.onSurface,
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
          child: Divider(color: context.vColors.divider, thickness: 1),
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
