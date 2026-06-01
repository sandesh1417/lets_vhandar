import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/providers/layout_provider.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/home/providers/category_detail_provider.dart';
import 'package:lets_vhandar/features/home/widgets/product_grid.dart';
import 'package:lets_vhandar/features/profile/presentation/product_suggestion_screen.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';

class CategoryProductGrid extends ConsumerWidget {
  final String categorySlug;

  const CategoryProductGrid({super.key, required this.categorySlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(filteredProductsProvider(categorySlug));
    final isVertical = ref.watch(appLayoutProvider);

    return Column(
      children: [
        Expanded(
          child: Container(
            color: context.vColors.scaffoldBg,
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return _buildEmptyState();
                }
                return ProductGrid(
                  products: products,
                  isVertical: isVertical,
                  padding: EdgeInsets.fromLTRB(8.w, 8.w, 8.w, 110.h),
                );
              },
              loading: () => BrandProductGridShimmer(
                padding: EdgeInsets.fromLTRB(8.w, 8.w, 8.w, 110.h),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    'Error: $err',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red, fontSize: 12.sp),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Consumer(
      builder: (context, ref, _) {
        final vc = context.vColors;
        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/no_search_results.svg',
                  width: 120.w,
                  height: 120.w,
                ),
                SizedBox(height: 20.h),
                Text(
                  'No Products Found',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: vc.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "We couldn't find any products here.\nSuggest one and we'll look into it!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: vc.onSurfaceMuted,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24.h),
                GestureDetector(
                  onTap: () {
                    final loginState = ref.read(loginProvider);
                    if (loginState.isGuest || !loginState.isLoggedIn) {
                      context.go(LVRoute.loginScreen.route);
                      return;
                    }
                    showProductSuggestionSheet(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCC00),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle_outline_rounded,
                            color: Colors.black87, size: 16.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Suggest a Product',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
