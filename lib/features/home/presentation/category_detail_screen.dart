import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/providers/layout_provider.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/home/domain/models/sub_category_modal.dart';
import 'package:lets_vhandar/features/home/providers/category_detail_provider.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_floating_badge.dart';
import 'category_detail/widgets/category_product_grid.dart';
import 'category_detail/widgets/category_sort_bar.dart';
import 'category_detail/widgets/sub_category_sidebar.dart';
import 'package:lets_vhandar/widgets/app_bottom_sheet.dart';
import 'package:lets_vhandar/widgets/app_refresh_indicator.dart';

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

  String _stripHtml(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    return raw
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Widget _sheetHandle(BuildContext ctx) {
    final vc = ctx.vColors;
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12.h),
        width: 36.w,
        height: 4.h,
        decoration: BoxDecoration(
            color: vc.divider, borderRadius: BorderRadius.circular(2.r)),
      ),
    );
  }

  void _showCategorySheet(dynamic category) {
    final _imgs = category.images as List?;
    final _firstImg = (_imgs != null && _imgs.isNotEmpty) ? _imgs.first : null;
    final imageUrl = _firstImg?.url ?? _firstImg?.path;
    final productCount = ref
            .read(categoryProductsProvider(widget.categorySlug))
            .valueOrNull
            ?.length ??
        0;
    final catDesc = _stripHtml(category.description as String?);

    showAppSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      builder: (ctx) {
        final vc = ctx.vColors;
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: vc.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _sheetHandle(ctx),
                  if (imageUrl != null) ...[
                    Container(
                      width: 88.w,
                      height: 88.w,
                      decoration: BoxDecoration(
                        color: context.isDark
                            ? vc.surfaceVariant
                            : const Color(0xFFE7F1ED),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: CustomImageViewer(
                            path: imageUrl, fit: BoxFit.contain),
                      ),
                    ),
                    SizedBox(height: 12.h),
                  ],
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: AppColor.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    category.name ?? '',
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: vc.onSurface),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '$productCount Products',
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.primary),
                    ),
                  ),
                  if (catDesc.isNotEmpty) ...[
                    SizedBox(height: 14.h),
                    Text(
                      catDesc,
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: vc.onSurfaceMuted,
                          height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    SizedBox(height: 8.h),
                    Text(
                      'No description available.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: vc.onSurfaceMuted.withValues(alpha: 0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showInfoSheet(dynamic category) {
    final selectedSlug =
        ref.read(selectedSubCategorySlugProvider(widget.categorySlug));
    if (selectedSlug == null) {
      _showCategorySheet(category);
      return;
    }

    // Use list data as fallback while the detail fetch completes
    final subCategories =
        ref.read(subCategoriesProvider(widget.categorySlug)).valueOrNull ?? [];
    SubCategoryData? listSub;
    try {
      listSub = subCategories.firstWhere((s) => s.slug == selectedSlug);
    } catch (_) {}

    if (listSub == null) {
      _showCategorySheet(category);
      return;
    }

    // Kick off a fresh detail fetch so we get the full description field
    final detailFuture =
        ref.read(subCategoryBySlugProvider(selectedSlug).future);

    showAppSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      builder: (ctx) {
        final vc = ctx.vColors;
        return SafeArea(
          child: FutureBuilder<SubCategoryData?>(
            future: detailFuture,
            builder: (ctx2, snapshot) {
              // Merge: prefer detail data, fall back to list data
              final sub = snapshot.data ?? listSub!;
              final subDesc = _stripHtml(sub.description);
              final subImageUrl =
                  sub.images?.firstOrNull?.url ?? sub.images?.firstOrNull?.path;

              return SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: vc.surface,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24.r)),
                  ),
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _sheetHandle(ctx2),
                      if (subImageUrl != null) ...[
                        Container(
                          width: 72.w,
                          height: 72.w,
                          decoration: BoxDecoration(
                            color: context.isDark
                                ? vc.surfaceVariant
                                : const Color(0xFFFFF6E6),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14.r),
                            child: CustomImageViewer(
                                path: subImageUrl, fit: BoxFit.contain),
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],
                      Text(
                        'Subcategory',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: AppColor.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        sub.name ?? '',
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: vc.onSurface),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 14.h),
                      Divider(color: vc.divider),
                      SizedBox(height: 12.h),
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          subDesc.isEmpty)
                        SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColor.primary,
                          ),
                        )
                      else if (subDesc.isNotEmpty)
                        Text(
                          subDesc,
                          style: TextStyle(
                              fontSize: 13.sp,
                              color: vc.onSurfaceMuted,
                              height: 1.6),
                          textAlign: TextAlign.center,
                        )
                      else
                        Text(
                          'No description available.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: vc.onSurfaceMuted.withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              );
            },
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
                              onTap: () => _showCategorySheet(category),
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
                    onTap: () => _showInfoSheet(category),
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
            child: AppRefreshIndicator(
              topOffset: 12.h,
              onRefresh: () async {
                ref.invalidate(categoryProductsProvider(widget.categorySlug));
                ref.invalidate(categoryBySlugProvider(widget.categorySlug));
                ref.invalidate(subCategoriesProvider(widget.categorySlug));
                await ref
                    .read(categoryProductsProvider(widget.categorySlug).future);
              },
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
                                    onTap: () =>
                                        context.push(LVRoute.cartScreen.route),
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
                              onTap: () =>
                                  context.push(LVRoute.cartScreen.route),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
