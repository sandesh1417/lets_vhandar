import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/features/home/domain/models/category_modal.dart';
import 'package:lets_vhandar/features/home/providers/category_provider.dart';
import 'package:lets_vhandar/features/home/providers/product_provider.dart';
import 'package:lets_vhandar/features/home/widgets/home_section_title.dart';
import 'package:lets_vhandar/features/home/widgets/product_item_card.dart';

class HomeCategoryProductList extends ConsumerWidget {
  const HomeCategoryProductList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoryProvider);

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
        if (products.isEmpty) return const SizedBox.shrink();

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
              height: 200.h,
              child: ListView.builder(
                padding: EdgeInsets.only(left: 16.w, right: 4.w),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductItemCard(
                    product: products[index],
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
          child: Container(
            width: 150.w,
            height: 20.h,
            color: Colors.grey.shade200,
          ),
        ),
        SizedBox(
          height: 240.h,
          child: ListView.builder(
            padding: EdgeInsets.only(left: 16.w),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) => Container(
              width: 140.w,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}
