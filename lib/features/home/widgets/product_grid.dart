import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/widgets/product_item_card.dart';

/// A shared, responsive product grid used across Search, Category, and Brand screens.
/// Uses [mainAxisExtent] instead of [childAspectRatio] so that card height is
/// absolute and independent of the available width — preventing overflow on
/// narrow layouts (sidebar) and vacant space on wide layouts.
class ProductGrid extends StatelessWidget {
  final List<ProductData> products;
  final bool isVertical;
  final EdgeInsetsGeometry? padding;

  const ProductGrid({
    super.key,
    required this.products,
    this.isVertical = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Card content breakdown (all values from ProductItemCard):
    //   image:    80.h
    //   padding:  8.w * 2 (top + bottom of text section)
    //   name:     30.h
    //   gap:       4.h
    //   unit:     30.h
    //   gap:       6.h
    //   price row: ~35.h  (price text + ADD button)
    // Total ≈ 80 + 16 + 30 + 4 + 30 + 6 + 35 = 201
    // Add a small buffer for shadows and rounding.
    final double cardHeight = 80.h + 30.h + 30.h + 35.h + 4.h + 6.h + 20.w;

    return GridView.builder(
      padding: padding ?? EdgeInsets.all(12.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        mainAxisExtent: cardHeight,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductItemCard(
          key: ValueKey(product.id),
          product: product,
          margin: EdgeInsets.zero,
          width: double.infinity,
          onTap: () {
            context.pushNamed(
              LVRoute.productDetailScreen.route,
              extra: product,
            );
          },
        );
      },
    );
  }
}
