import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/providers/layout_provider.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/home/providers/category_detail_provider.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_floating_badge.dart';
import 'category_detail/widgets/category_product_grid.dart';
import 'category_detail/widgets/category_sort_bar.dart';
import 'category_detail/widgets/sub_category_sidebar.dart';

class CategoryDetailScreen extends ConsumerStatefulWidget {
  final String categorySlug;
  final String? initialSubCategorySlug;

  const CategoryDetailScreen(
      {super.key, required this.categorySlug, this.initialSubCategorySlug});

  @override
  ConsumerState<CategoryDetailScreen> createState() =>
      _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSubCategorySlug != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(selectedSubCategorySlugProvider(widget.categorySlug).notifier)
            .state = widget.initialSubCategorySlug;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCategoryInfoSheet(dynamic category) {
    final imageUrl = category.images?.firstOrNull?.url ??
        category.images?.firstOrNull?.path;
    final productsAsync =
        ref.read(categoryProductsProvider(widget.categorySlug));
    final productCount = productsAsync.valueOrNull?.length ?? 0;

    final rawDesc = ((category.description as String?) ?? '').trim();
    final desc = rawDesc
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final vc = ctx.vColors;
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: vc.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 12.h),
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                        color: vc.divider,
                        borderRadius: BorderRadius.circular(2.r)),
                  ),
                ),
                // Image
                if (imageUrl != null) ...[
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? vc.surfaceVariant
                          : const Color(0xFFE7F1ED),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: CustomImageViewer(
                        path: imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
                // Name
                Text(
                  category.name ?? '',
                  style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: vc.onSurface),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),
                // Product count badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '$productCount Products',
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primary),
                  ),
                ),
                // Description
                if (desc.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Divider(color: vc.divider),
                  SizedBox(height: 12.h),
                  Text(
                    desc,
                    style: TextStyle(
                        fontSize: 13.sp, color: vc.onSurfaceMuted, height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                ],
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final categoryAsync =
        ref.watch(categoryBySlugProvider(widget.categorySlug));
    final isVertical = ref.watch(appLayoutProvider);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return CustomScaffoldWrapper(
      isScrollable: false,
      body: Column(
        children: [
          // ── Green header ──────────────────────────────────────────
          Container(
            color: AppColor.primary,
            padding: EdgeInsets.only(
              top: statusBarHeight + 10.h,
              left: 12.w,
              right: 12.w,
              bottom: 12.h,
            ),
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.pop();
                  },
                  child: Container(
                    width: 44.w,
                    height: 44.h,
                    alignment: Alignment.center,
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _isSearchExpanded
                      ? Container(
                          height: 42.h,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: context.isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                size: 20.sp,
                                color: context.isDark
                                    ? Colors.white60
                                    : Colors.grey.shade400,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  autofocus: true,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: context.isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontFamily: 'Inter',
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search products...',
                                    hintStyle: TextStyle(
                                      fontSize: 13.sp,
                                      color: context.isDark
                                          ? Colors.white54
                                          : Colors.grey.shade400,
                                      fontFamily: 'Inter',
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    isCollapsed: true,
                                  ),
                                  onChanged: (value) {
                                    ref
                                        .read(searchQueryProvider(
                                                widget.categorySlug)
                                            .notifier)
                                        .state = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      : categoryAsync.when(
                          data: (category) {
                            final imageUrl =
                                category.images?.firstOrNull?.url ??
                                    category.images?.firstOrNull?.path;
                            return GestureDetector(
                              onTap: () => _showCategoryInfoSheet(category),
                              child: Row(
                                children: [
                                  if (imageUrl != null) ...[
                                    Container(
                                      width: 30.w,
                                      height: 30.w,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE7F1ED),
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.40),
                                          width: 1,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(7.r),
                                        child: CustomImageViewer(
                                          path: imageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                  ],
                                  Expanded(
                                    child: Text(
                                      category.name ?? '',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                ),
                SizedBox(width: 8.w),
                // Info icon — shows category details popup
                categoryAsync.maybeWhen(
                  data: (category) => GestureDetector(
                    onTap: () => _showCategoryInfoSheet(category),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: const Icon(Icons.info_outline_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => CategorySortBar.showSortModal(
                      context, ref, widget.categorySlug),
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: const Icon(Icons.tune_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_isSearchExpanded) {
                        _searchController.clear();
                        ref
                            .read(searchQueryProvider(widget.categorySlug)
                                .notifier)
                            .state = '';
                      }
                      _isSearchExpanded = !_isSearchExpanded;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      _isSearchExpanded ? Icons.close : Icons.search,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Body ─────────────────────────────────────────────────
          Expanded(
            child: isVertical
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SubCategorySidebar(categorySlug: widget.categorySlug),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              color: context.vColors.scaffoldBg,
                              child: CategoryProductGrid(
                                categorySlug: widget.categorySlug,
                              ),
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
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      Container(
                        color: context.vColors.scaffoldBg,
                        child: CategoryProductGrid(
                            categorySlug: widget.categorySlug),
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
                  ),
          ),
        ],
      ),
    );
  }
}
