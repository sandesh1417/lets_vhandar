import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/providers/connectivity_provider.dart';
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
    final isOffline = ref.watch(connectivityProvider).maybeWhen(
          data: (online) => !online,
          orElse: () => false,
        );

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
              child: isOffline
                  ? const _OfflineBody()
                  : tab == 0
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
      loading: () => Container(
        margin: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 0),
        decoration: BoxDecoration(
          color: context.vColors.surface,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: icon + label + "See All" placeholder
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 8.h),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: CustomShimmer.rectangular(
                        width: 28.w, height: 28.w),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: CustomShimmer.rectangular(
                          width: 100.w, height: 14.h),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: CustomShimmer.rectangular(
                        width: 40.w, height: 12.h),
                  ),
                ],
              ),
            ),
            // Horizontal items row
            SizedBox(
              height: 98.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                itemCount: 5,
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemBuilder: (_, __) => Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: CustomShimmer.rectangular(
                          width: 68.w, height: 68.w),
                    ),
                    SizedBox(height: 4.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: CustomShimmer.rectangular(
                          width: 52.w, height: 9.h),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
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
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Shop by Category" label placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: CustomShimmer.rectangular(width: 140.w, height: 16.h),
          ),
          SizedBox(height: 14.h),
          // 4-col grid matching CategoryCard (aspectRatio 0.68)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.68,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: 16,
            itemBuilder: (_, __) => Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: const CustomShimmer.rectangular(
                        width: double.infinity),
                  ),
                ),
                SizedBox(height: 6.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: CustomShimmer.rectangular(
                      width: double.infinity, height: 9.h),
                ),
                SizedBox(height: 3.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child:
                      CustomShimmer.rectangular(width: 30.w, height: 9.h),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineBody extends StatelessWidget {
  const _OfflineBody();

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 36.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/offline.svg',
              width: 100.w,
              height: 100.w,
            ),
            SizedBox(height: 16.h),
            Text(
              'Oops!',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w900,
                color: AppColor.primary,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'No Internet Connection',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: vc.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please check your Wi-Fi or mobile data\nand try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: vc.onSurfaceMuted,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
