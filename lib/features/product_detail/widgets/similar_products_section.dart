import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/providers/product_provider.dart';
import 'package:lets_vhandar/features/home/widgets/product_item_card.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';

import 'product_card_style.dart';

/// "Similar Products" card — a horizontal rail of products from the same
/// category (excluding the current one, de-duped by id). Returns a sliver; loads
/// with a shimmer and collapses to nothing on empty/error.
class SimilarProductsSection extends ConsumerWidget {
  const SimilarProductsSection({
    super.key,
    required this.product,
    required this.isActive,
  });

  final ProductData product;

  /// Only the focused page may host Heroes — peeking neighbour pages share the
  /// same category (same ids), so letting them all be Heroes would put duplicate
  /// tags in one route.
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (product.categoryIds?.isNotEmpty != true) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final vc = context.vColors;
    return ref.watch(similarProductsProvider(product.categoryIds!.first)).when(
          data: (products) {
            // Exclude the current product, and de-dupe by id so the same product
            // can never appear twice (a repeated id would mean two Heroes with
            // the same tag).
            final seenIds = <String>{};
            final filtered = products
                .where((p) => p.id != product.id && seenIds.add(p.id ?? ''))
                .toList();
            if (filtered.isEmpty) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }
            return SliverToBoxAdapter(
              child: Container(
                margin: productCardMargin(),
                decoration: productCardDecoration(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(kCardRadius.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          children: [
                            Container(
                              width: 3.w,
                              height: 16.h,
                              decoration: BoxDecoration(
                                color: AppColor.primary,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Similar Products',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: vc.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        height: ProductItemCard.preferredHeight,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final p = filtered[index];
                            return ProductItemCard(
                              product: p,
                              // Disable Hero here so that ONLY the tapped product
                              // from the previous screen animates to the main image.
                              // Otherwise, matching similar products will also fly
                              // across the screen at the same time.
                              enableHero: false,
                              onTap: () => context.pushNamed(
                                LVRoute.productDetailScreen.route,
                                extra: ProductDetailNavArgs(
                                  products: filtered,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => SliverToBoxAdapter(
            child: Container(
              margin: productCardMargin(),
              decoration: productCardDecoration(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kCardRadius.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          const CustomShimmer.rectangular(width: 3, height: 16),
                          SizedBox(width: 8.w),
                          const CustomShimmer.rectangular(
                              width: 120, height: 14),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    const ProductHorizontalListShimmer(itemCount: 4),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ),
          error: (e, s) =>
              const SliverToBoxAdapter(child: SizedBox.shrink()),
        );
  }
}
