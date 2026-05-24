import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/providers/layout_provider.dart';
import 'package:lets_vhandar/features/home/providers/category_detail_provider.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

import 'category_detail/widgets/category_product_grid.dart';
import 'category_detail/widgets/category_sort_bar.dart';
import 'category_detail/widgets/sub_category_sidebar.dart';

class CategoryDetailScreen extends ConsumerStatefulWidget {
  final String categorySlug;

  const CategoryDetailScreen({super.key, required this.categorySlug});

  @override
  ConsumerState<CategoryDetailScreen> createState() =>
      _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  onTap: () => context.pop(),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _isSearchExpanded
                      ? Container(
                          height: 44.h,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/search-active.svg',
                                width: 18.sp,
                                height: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  autofocus: true,
                                  style: TextStyle(
                                      fontSize: 13.sp, color: Colors.black87),
                                  decoration: InputDecoration(
                                    hintText: 'Search products...',
                                    hintStyle: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.black38),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
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
                            return Row(
                              children: [
                                if (imageUrl != null) ...[
                                  Container(
                                    width: 34.w,
                                    height: 34.w,
                                    decoration: BoxDecoration(
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
                                  SizedBox(width: 10.w),
                                ],
                                Expanded(
                                  child: Text(
                                    category.name ?? '',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17.sp,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
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
                        child: Container(
                          color: const Color(0xFFF5F6F8),
                          child: CategoryProductGrid(
                            categorySlug: widget.categorySlug,
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    color: const Color(0xFFF5F6F8),
                    child: CategoryProductGrid(
                        categorySlug: widget.categorySlug),
                  ),
          ),
        ],
      ),
    );
  }
}
