import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_floating_badge.dart';
import 'package:lets_vhandar/features/dashboard/providers/dashboard_provider.dart';
import 'package:lets_vhandar/core/providers/layout_provider.dart';
import 'package:lets_vhandar/features/home/providers/category_detail_provider.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

import 'category_detail/widgets/category_product_grid.dart';
import 'category_detail/widgets/category_search_app_bar.dart';
import 'category_detail/widgets/category_sort_bar.dart';
import 'category_detail/widgets/sub_category_horizontal_bar.dart';
import 'category_detail/widgets/sub_category_sidebar.dart';

class CategoryDetailScreen extends ConsumerWidget {
  final String categorySlug;

  const CategoryDetailScreen({super.key, required this.categorySlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(categoryBySlugProvider(categorySlug));
    final isVertical = ref.watch(appLayoutProvider);

    return CustomScaffoldWrapper(
      isScrollable: false,
      appBar: CategorySearchAppBar(
        categorySlug: categorySlug,
        categoryName: categoryAsync.when(
          data: (category) => category.name ?? '',
          loading: () => 'Loading...',
          error: (_, __) => 'Category',
        ),
      ),
      body: isVertical
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vertical Sidebar
                SubCategorySidebar(categorySlug: categorySlug),

                // Main Content (Sort + Grid)
                Expanded(
                  child: Column(
                    children: [
                      CategorySortBar(categorySlug: categorySlug),
                      Expanded(
                        child: CategoryProductGrid(categorySlug: categorySlug),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                // Sort Bar at top
                CategorySortBar(categorySlug: categorySlug),

                // Main Product Grid
                Expanded(
                  child: CategoryProductGrid(categorySlug: categorySlug),
                ),
              ],
            ),
      floatingActionButton: CartFloatingBadge(
        onTap: () {
          ref.read(dashboardIndexProvider.notifier).state = 3;
          context.go('/dashboardScreen');
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isVertical) SubCategoryHorizontalBar(categorySlug: categorySlug),
            const SizedBox(height: 12), // Small extra spacing to match dashboard feel
          ],
        ),
      ),
    );
  }
}
