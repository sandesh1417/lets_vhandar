import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/features/home/widgets/home_banner_slider.dart';
import 'package:lets_vhandar/features/home/widgets/home_categories_grid.dart';
import 'package:lets_vhandar/features/home/widgets/home_category_product_list.dart';
import 'package:lets_vhandar/features/home/widgets/home_header.dart';
import 'package:lets_vhandar/features/home/widgets/home_section_title.dart';
import 'package:lets_vhandar/features/home/widgets/home_featured_brands_list.dart';
import 'package:lets_vhandar/features/home/widgets/home_top_selling_list.dart';
import 'package:lets_vhandar/features/home/providers/banner_provider.dart';
import 'package:lets_vhandar/features/home/providers/product_provider.dart';
import 'package:lets_vhandar/features/home/providers/category_provider.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
// import 'package:lets_vhandar/features/home/widgets/home_featured_products_list.dart';

class _SuggestProductCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF1A2E25) : const Color(0xFFE8F5EF),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "didn't find what you\nwere looking for?",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    color: context.isDark ? const Color(0xFFB2DFCB) : const Color(0xFF1A3D2E),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Suggest something & we'll look into it",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    color: vc.onSurfaceMuted,
                  ),
                ),
                SizedBox(height: 20.h),
                OutlinedButton(
                  onPressed: () =>
                      context.push(LVRoute.productSuggestionScreen.route),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.secondary,
                    side: BorderSide(color: AppColor.secondary, width: 1.5),
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Suggest a Product',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          SvgPicture.asset(
            'assets/images/suggest_product.svg',
            width: 110.w,
            height: 110.w,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColor.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Container(
        color: context.vColors.scaffoldBg,
        child: RefreshIndicator(
          color: AppColor.primary,
          onRefresh: () async {
            ref.invalidate(bannerProvider);
            ref.invalidate(featuredProductsProvider);
            ref.invalidate(homeCategoryProvider);
            ref.invalidate(allCategoryProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              const HomeHeader(),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    const HomeBannerSlider(),
                    SizedBox(height: 16.h),
                    const HomeSectionTitle(
                      title: 'Featured Products',
                      subtitle: 'Hand-picked for you today',
                    ),
                    const HomeFeaturedProductsList(),
                    SizedBox(height: 16.h),
                    const HomeSectionTitle(
                      title: 'Shop by Category',
                      subtitle: 'Find exactly what you need',
                    ),
                    const HomeCategoriesGrid(),
                    SizedBox(height: 16.h),
                    const HomeCategoryProductList(),
                    SizedBox(height: 16.h),
                    HomeSectionTitle(
                      title: 'Featured Brands',
                      subtitle: 'Top brands we carry',
                      onSeeAll: () => context.push('/brands'),
                    ),
                    const HomeFeaturedBrandsList(),
                    SizedBox(height: 24.h),
                    _SuggestProductCard(),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 150.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
