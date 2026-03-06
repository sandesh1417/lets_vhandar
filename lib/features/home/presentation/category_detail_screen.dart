import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/home/providers/category_detail_provider.dart';
import 'package:lets_vhandar/features/home/widgets/product_item_card.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';

class CategoryDetailScreen extends ConsumerWidget {
  final String categorySlug;

  const CategoryDetailScreen({super.key, required this.categorySlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(categoryBySlugProvider(categorySlug));
    final subCategoriesAsync = ref.watch(subCategoriesProvider(categorySlug));
    final productsAsync = ref.watch(categoryProductsProvider(categorySlug));
    final selectedSubSlug =
        ref.watch(selectedSubCategorySlugProvider(categorySlug));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: categoryAsync.when(
          data: (category) => Text(
            category.name ?? '',
            style: TextStyle(
                color: AppColor.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const Text('Category'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 85.w, // Reduced from 100.w
            color: const Color(0xFFF8F9FA),
            child: subCategoriesAsync.when(
              data: (subs) {
                // Prepend an "All" option if needed
                return ListView.builder(
                  itemCount: subs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isSelected = selectedSubSlug == null;
                      return _buildSidebarItem(
                        context,
                        ref,
                        'All',
                        null,
                        isSelected,
                        null,
                      );
                    }
                    final sub = subs[index - 1];
                    final isSelected = selectedSubSlug == sub.slug;
                    return _buildSidebarItem(
                      context,
                      ref,
                      sub.name ?? '',
                      sub.slug!,
                      isSelected,
                      sub.images?.isNotEmpty == true
                          ? sub.images!.first.url
                          : null,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Icon(Icons.error_outline, size: 24.sp)),
            ),
          ),
          // Product Grid
          Expanded(
            child: Container(
              color: const Color(0xFFF5F6F8),
              child: productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 48.sp, color: Colors.grey),
                          SizedBox(height: 12.h),
                          Text('No products found',
                              style: TextStyle(
                                  color: AppColor.textMuted, fontSize: 14.sp)),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: EdgeInsets.all(12.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.55, // Increased vertical space
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductItemCard(
                        product: product,
                        width: double.infinity,
                        margin: EdgeInsets.zero,
                        onTap: () {
                          context.push('/productDetailScreen', extra: product);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
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
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, WidgetRef ref, String title,
      String? slug, bool isSelected, String? imageUrl) {
    return InkWell(
      onTap: () {
        ref.read(selectedSubCategorySlugProvider(categorySlug).notifier).state =
            slug;
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: 12.h, horizontal: 4.w), // Reduced padding
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: isSelected
              ? Border(
                  left: BorderSide(width: 4.w, color: AppColor.primary),
                )
              : null,
        ),
        child: Column(
          children: [
            if (imageUrl != null) ...[
              CustomImageViewer(
                path: imageUrl,
                height: 32.h, // Reduced from 40.h
                width: 32.w, // Reduced from 40.w
                fit: BoxFit.contain,
              ),
              SizedBox(height: 4.h), // Reduced from 8.h
            ] else if (slug == null) ...[
              Icon(Icons.apps,
                  color: isSelected ? AppColor.primary : Colors.grey,
                  size: 24.sp), // Reduced from 28.sp
              SizedBox(height: 4.h), // Reduced from 8.h
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp, // Reduced from 11.sp
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColor.primary : AppColor.textBlack54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
