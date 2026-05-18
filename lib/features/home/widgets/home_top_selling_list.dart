import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/home/providers/product_provider.dart';
import 'package:lets_vhandar/features/home/widgets/product_item_card.dart';

import 'package:lets_vhandar/widgets/custom_shimmer.dart';

class HomeFeaturedProductsList extends ConsumerWidget {
  const HomeFeaturedProductsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(featuredProductsProvider);

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: ProductItemCard.preferredHeight,

          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductItemCard(
                product: product,
                onTap: () {
                  context.pushNamed(
                    LVRoute.productDetailScreen.route,
                    extra: product,
                  );
                },
              );
            },
          ),
        );
      },
      loading: () => const ProductHorizontalListShimmer(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
