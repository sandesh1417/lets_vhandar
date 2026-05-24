import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/features/home/widgets/home_banner_slider.dart';
import 'package:lets_vhandar/features/home/widgets/home_categories_grid.dart';
import 'package:lets_vhandar/features/home/widgets/home_category_product_list.dart';
import 'package:lets_vhandar/features/home/widgets/home_header.dart';
import 'package:lets_vhandar/features/home/widgets/home_section_title.dart';
import 'package:lets_vhandar/features/home/widgets/home_top_selling_list.dart';
import 'package:lets_vhandar/features/home/providers/banner_provider.dart';
import 'package:lets_vhandar/features/home/providers/product_provider.dart';
import 'package:lets_vhandar/features/home/providers/category_provider.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
// import 'package:lets_vhandar/features/home/widgets/home_featured_products_list.dart';

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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF0FAF5),
              Color(0xFFFCFCFC),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.4],
          ),
        ),
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
                    SizedBox(height: 32.h),
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
