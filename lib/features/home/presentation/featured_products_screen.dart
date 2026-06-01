import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/home/providers/product_provider.dart';
import 'package:lets_vhandar/features/home/widgets/product_item_card.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_floating_badge.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';

class FeaturedProductsScreen extends ConsumerWidget {
  const FeaturedProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(featuredProductsProvider);
    final cardHeight = ProductItemCard.preferredHeight;

    return CustomScaffoldWrapper(
      isScrollable: false,
      horizontalPadding: 0,
      appBar: const CustomScreenHeader(title: 'Featured Products'),
      body: productsAsync.when(
        data: (products) {
          final visible = products
              .where((p) => !p.isOutOfStock && p.parentId == null)
              .toList();

          if (visible.isEmpty) {
            return Center(
              child: Text(
                'No featured products available',
                style: TextStyle(fontSize: 14.sp),
              ),
            );
          }

          return Stack(
            children: [
              GridView.builder(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 110.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.h,
                  crossAxisSpacing: 10.w,
                  mainAxisExtent: cardHeight,
                ),
                itemCount: visible.length,
                itemBuilder: (context, index) {
                  final product = visible[index];
                  return RepaintBoundary(
                    child: ProductItemCard(
                      key: ValueKey(product.id),
                      product: product,
                      width: double.infinity,
                      onTap: () => context.pushNamed(
                        LVRoute.productDetailScreen.route,
                        extra: product,
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 16.h,
                child: Center(
                  child: CartFloatingBadge(
                    onTap: () => context.push(LVRoute.cartScreen.route),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const ProductGridShimmer(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}
