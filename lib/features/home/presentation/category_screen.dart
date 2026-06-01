import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/features/dashboard/providers/dashboard_provider.dart';
import 'package:lets_vhandar/features/home/domain/models/category_modal.dart';
import 'package:lets_vhandar/features/home/providers/brand_provider.dart';
import 'package:lets_vhandar/features/home/providers/category_detail_provider.dart';
import 'package:lets_vhandar/features/home/providers/category_provider.dart';
import 'package:lets_vhandar/widgets/custom_image_viewer.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';
import 'package:lets_vhandar/widgets/error_state.dart';
import 'package:lets_vhandar/widgets/premium_search_bar.dart';

import 'widgets/brand_card.dart';
import 'widgets/category_card.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final vc = context.vColors;
    final tab = ref.watch(categoryScreenTabProvider);

    return CustomScaffoldWrapper(
      backgroundColor: AppColor.primary,
      isScrollable: false,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────
          Container(
            color: AppColor.primary,
            padding: EdgeInsets.only(
              top: statusBarHeight + 16.h,
              left: 16.w,
              right: 16.w,
              bottom: 16.h,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () =>
                      ref.read(dashboardIndexProvider.notifier).state = 0,
                  child: SvgPicture.asset(
                    KImageConstant.vandharIcon,
                    height: 38.h,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PremiumSearchBar(
                    controller: _searchController,
                    readOnly: true,
                    showScanIcon: true,
                    onTap: () => context.push(LVRoute.searchScreen.route),
                  ),
                ),
              ],
            ),
          ),

          // ── Tab toggle ─────────────────────────────────────────────
          Container(
            color: vc.surface,
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
            child: Row(
              children: [
                _pill('Category', tab == 0,
                    () => ref.read(categoryScreenTabProvider.notifier).state = 0),
                SizedBox(width: 8.w),
                _pill('Sub Category', tab == 1,
                    () => ref.read(categoryScreenTabProvider.notifier).state = 1),
                SizedBox(width: 8.w),
                _pill('Brand', tab == 2,
                    () => ref.read(categoryScreenTabProvider.notifier).state = 2),
              ],
            ),
          ),

          // ── Body ───────────────────────────────────────────────────
          Expanded(
            child: ColoredBox(
              color: vc.scaffoldBg,
              child: tab == 0
                  ? const _CategoryTab()
                  : tab == 1
                      ? const _SubCategoryTab()
                      : const _BrandTab(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 38.h,
          decoration: BoxDecoration(
            color: selected ? AppColor.primary : context.vColors.surfaceVariant,
            borderRadius: BorderRadius.circular(6.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? Colors.white : context.vColors.onSurfaceMuted,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Category tab ──────────────────────────────────────────────────────────
class _CategoryTab extends ConsumerStatefulWidget {
  const _CategoryTab();

  @override
  ConsumerState<_CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends ConsumerState<_CategoryTab> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(allCategoryProvider);
    final vc = context.vColors;

    return categoriesAsync.when(
      data: (categories) => RefreshIndicator(
        color: AppColor.primary,
        onRefresh: () async => ref.invalidate(allCategoryProvider),
        child: CustomScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            if (categories.isNotEmpty) ...[
              SliverPadding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 8.h),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Shop by Category',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: vc.onSurface),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 12.h,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, index) {
                      final c = categories[index];
                      return CategoryCard(
                        name: c.name ?? '',
                        imageUrl: c.images?.isNotEmpty == true
                            ? c.images!.first.url
                            : null,
                        onTap: () =>
                            navigateToSlug(context, c.slug, isBrand: false),
                      );
                    },
                    childCount: categories.length,
                  ),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 150.h),
            ),
          ],
        ),
      ),
      loading: () => const _LoadingShimmer(),
      error: (_, __) => const ErrorStateWidget(),
    );
  }
}

// ── Sub Category tab ──────────────────────────────────────────────────────
class _SubCategoryTab extends ConsumerWidget {
  const _SubCategoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoryProvider);

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) return const SizedBox.shrink();
        return ListView.builder(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 180.h),
          itemCount: categories.length,
          itemBuilder: (_, index) =>
              _SubSection(category: categories[index]),
        );
      },
      loading: () => const _LoadingShimmer(),
      error: (_, __) => const ErrorStateWidget(),
    );
  }
}

// ── Brand tab ─────────────────────────────────────────────────────────────
class _BrandTab extends ConsumerWidget {
  const _BrandTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandsAsync = ref.watch(brandProvider);
    final vc = context.vColors;

    return brandsAsync.when(
      data: (brands) {
        if (brands.isEmpty) {
          return Center(
            child: Text('No brands found',
                style: TextStyle(fontSize: 14.sp, color: vc.onSurfaceMuted)),
          );
        }
        return RefreshIndicator(
          color: AppColor.primary,
          onRefresh: () async => ref.invalidate(brandProvider),
          child: GridView.builder(
            padding: EdgeInsets.fromLTRB(
                16.w, 16.h, 16.w,
                MediaQuery.of(context).padding.bottom + 180.h),
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.72,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
            ),
            itemCount: brands.length,
            itemBuilder: (_, index) {
              final b = brands[index];
              return BrandCard(
                name: b.name ?? '',
                imageUrl: b.images?.isNotEmpty == true
                    ? b.images!.first.url
                    : null,
                onTap: () =>
                    navigateToSlug(context, b.slug, isBrand: true),
              );
            },
          ),
        );
      },
      loading: () => const _LoadingShimmer(),
      error: (_, __) => const ErrorStateWidget(),
    );
  }
}

// ── Sub section per parent category ──────────────────────────────────────
class _SubSection extends ConsumerWidget {
  final CategoryData category;
  const _SubSection({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slug = category.slug ?? '';
    if (slug.isEmpty) return const SizedBox.shrink();

    final subsAsync = ref.watch(subCategoriesProvider(slug));
    final vc = context.vColors;

    return subsAsync.when(
      data: (subs) {
        if (subs.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 0),
          decoration: BoxDecoration(
            color: vc.surface,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category header row
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 8.h),
                child: Row(
                  children: [
                    if (category.images?.isNotEmpty == true)
                      Container(
                        width: 28.w,
                        height: 28.w,
                        margin: EdgeInsets.only(right: 8.w),
                        decoration: BoxDecoration(
                          color: context.isDark
                              ? vc.surfaceVariant
                              : const Color(0xFFE7F1ED),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6.r),
                          child: CustomImageViewer(
                            path: category.images!.first.url,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        category.name ?? '',
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: vc.onSurface),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          navigateToSlug(context, slug, isBrand: false),
                      child: Text(
                        'See All',
                        style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColor.primary),
                      ),
                    ),
                  ],
                ),
              ),
              // Subcategory slider
              SizedBox(
                height: 98.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  itemCount: subs.length,
                  separatorBuilder: (_, __) => SizedBox(width: 10.w),
                  itemBuilder: (_, i) {
                    final sub = subs[i];
                    final imgUrl = sub.images?.isNotEmpty == true
                        ? sub.images!.first.url
                        : null;
                    return GestureDetector(
                      onTap: () {
                        final parentSlug = category.slug;
                        if (parentSlug == null || parentSlug.isEmpty) return;
                        context.push(
                          '/category-detail/$parentSlug',
                          extra: {'initialSubSlug': sub.slug},
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 68.w,
                            height: 68.w,
                            decoration: BoxDecoration(
                              color: context.isDark
                                  ? vc.surfaceVariant
                                  : const Color(0xFFE7F1ED),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: CustomImageViewer(
                              path: imgUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          SizedBox(
                            width: 68.w,
                            child: Text(
                              sub.name ?? '',
                              style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w500,
                                  color: vc.onSurface),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: CustomShimmer.rectangular(width: 120.w, height: 16.h),
            ),
            SizedBox(height: 10.h),
            Row(
              children: List.generate(
                4,
                (_) => Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: Column(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: CustomShimmer.rectangular(
                          width: 64.w, height: 64.w),
                    ),
                    SizedBox(height: 4.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child:
                          CustomShimmer.rectangular(width: 52.w, height: 10.h),
                    ),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}



// ── Shimmer loading ───────────────────────────────────────────────────────
class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Featured Brands',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: context.vColors.onSurface)),
                Text('View All',
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primary)),
              ],
            ),
          ),
          const HorizontalListShimmer(),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child:
                Divider(color: context.vColors.divider, thickness: 1),
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text('Shop by Category',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: context.vColors.onSurface)),
          ),
          const GridShimmer(crossAxisCount: 4, isCircle: false),
        ],
      ),
    );
  }
}
