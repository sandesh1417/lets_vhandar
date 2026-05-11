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
    // Compact card content breakdown:
    //   image:    75.h
    //   padding:  6.w * 2
    //   name:     28.h (approx for 2 lines)
    //   unit:     22.h
    //   price:    32.h
    //   buffer:   15.w
    // Compact card height to ensure consistency and prevent overflow
    final double cardHeight = 185.h;

    return GridView.builder(
      padding: padding ?? EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 80.h),
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
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
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
