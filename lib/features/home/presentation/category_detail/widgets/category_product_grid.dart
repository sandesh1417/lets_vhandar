import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/providers/layout_provider.dart';
import 'package:lets_vhandar/features/home/providers/category_detail_provider.dart';
import 'package:lets_vhandar/features/home/widgets/product_grid.dart';
import 'package:lets_vhandar/widgets/custom_circular_loader.dart';

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
            color: const Color(0xFFF5F6F8),
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return _buildEmptyState();
                }
                return ProductGrid(
                  products: products,
                  isVertical: isVertical,
                  padding: EdgeInsets.all(8.w),
                );
              },
              loading: () => const Center(child: CustomCircularLoader()),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 48.sp, color: Colors.grey),
          SizedBox(height: 12.h),
          Text('No products found',
              style: TextStyle(color: AppColor.textMuted, fontSize: 14.sp)),
        ],
      ),
    );
  }
}
