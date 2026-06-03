import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/home/domain/models/category_modal.dart';
import 'package:lets_vhandar/features/home/providers/category_provider.dart';
import 'package:lets_vhandar/features/home/providers/product_provider.dart';
import 'package:lets_vhandar/features/home/widgets/home_section_title.dart';
import 'package:lets_vhandar/features/home/widgets/product_item_card.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';

class HomeCategoryProductList extends ConsumerWidget {
  const HomeCategoryProductList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(homeCategoryProvider);

    return categoriesAsync.when(
      data: (categories) {
        return Column(
          children: categories.map((category) {
            return _CategorySection(category: category);
          }).toList(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

class _CategorySection extends ConsumerWidget {
  final CategoryData category;

  const _CategorySection({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsByCategoryProvider(category.id!));

    return productsAsync.when(
      data: (products) {
        final visible = products
            .where((p) => !p.isOutOfStock && p.parentId == null)
            .toList();
        if (visible.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeSectionTitle(
              title: category.name ?? '',
              onSeeAll: () {
                context.push('/category-detail/${category.slug}');
              },
            ),
            SizedBox(
              height: ProductItemCard.preferredHeight,
              child: ListView.builder(
                padding: EdgeInsets.only(left: 16.w, right: 4.w),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: visible.length,
                itemBuilder: (context, index) {
                  return RepaintBoundary(
                    child: ProductItemCard(
                      product: visible[index],
                      onTap: () {
                        context.push(LVRoute.productDetailScreen.route,
                            extra: visible[index]);
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
          ],
        );
      },
      loading: () => const _CategoryLoadingSkeleton(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

class _CategoryLoadingSkeleton extends StatelessWidget {
  const _CategoryLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: const CustomShimmer.rectangular(
            width: 150,
            height: 20,
          ),
        ),
        SizedBox(height: 6.h),
        const ProductHorizontalListShimmer(itemCount: 3),
        SizedBox(height: 20.h),
      ],
    );
  }
}
