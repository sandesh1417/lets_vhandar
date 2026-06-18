import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_floating_badge.dart';
import 'package:lets_vhandar/features/home/providers/brand_provider.dart';
import 'package:lets_vhandar/features/home/providers/product_provider.dart';
import 'package:lets_vhandar/features/home/providers/search_history_provider.dart';
import 'package:lets_vhandar/features/home/providers/search_provider.dart';
import 'package:lets_vhandar/features/home/widgets/product_item_card.dart';
import 'package:lets_vhandar/features/home/widgets/search_sort_bar.dart';
import 'package:lets_vhandar/features/home/presentation/widgets/brand_card.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';
import 'package:lets_vhandar/widgets/error_state.dart';
import 'package:lets_vhandar/widgets/premium_search_bar.dart';
import 'package:lets_vhandar/features/profile/presentation/product_suggestion_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(searchProvider).query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String value) {
    final q = value.trim();
    if (q.isEmpty) return;
    ref.read(searchHistoryProvider.notifier).add(q);
    ref.read(searchProvider.notifier).search(q);
  }

  void _selectHistoryItem(String query) {
    _searchController.text = query;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: query.length),
    );
    _submitSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: CustomScaffoldWrapper(
        isScrollable: false,
        horizontalPadding: 0,
        floatingActionButton: CartFloatingBadge(
          onTap: () => context.push(LVRoute.cartScreen.route),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Column(
          children: [
            // ── Green header ──────────────────────────────────────────
            Container(
              color: AppColor.primary,
              padding: EdgeInsets.only(
                top: statusBarHeight + 10.h,
                left: 12.w,
                right: 16.w,
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
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: PremiumSearchBar(
                      controller: _searchController,
                      autofocus: true,
                      showScanIcon: true,
                      hintText: 'Search for products...',
                      onChanged: (value) {
                        ref.read(searchProvider.notifier).search(value);
                      },
                      onSubmitted: _submitSearch,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => showSearchSortModal(context, ref),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Body ─────────────────────────────────────────────────
            Expanded(child: _buildBody(searchState)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(SearchState state) {
    if (state.query.isEmpty) {
      return _EmptyState(onHistoryTap: _selectHistoryItem);
    }

    if (state.isLoading && state.results.isEmpty) {
      return const ProductGridShimmer();
    }

    if (state.error != null) {
      return ErrorStateWidget(
        onRetry: () => ref.read(searchProvider.notifier).search(_searchController.text),
      );
    }

    if (state.results.isEmpty && !state.isLoading) {
      return Column(
        children: [
          _BrandsRow(query: _searchController.text),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 40.h),
                    SvgPicture.asset(
                      'assets/images/no_search_results.svg',
                      height: 100.h,
                      width: 100.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Nothing here yet',
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: context.vColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Try searching again or explore our popular categories!',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: context.vColors.onSurfaceMuted,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: 120.w,
                      height: 44.h,
                      child: CustomElevatedButton(
                        onPressed: () => showProductSuggestionSheet(context),
                        backgroundColor: const Color(0xFFF9B141),
                        foregroundColor: Colors.white,
                        text: 'Suggest Product',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    final cardHeight = ProductItemCard.preferredHeight;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _BrandsRow(query: _searchController.text),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 80.h),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              mainAxisExtent: cardHeight,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = state.sortedResults[index];
                return ProductItemCard(
                  key: ValueKey(product.id),
                  product: product,
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                  width: double.infinity,
                  onTap: () {
                    ref.read(searchHistoryProvider.notifier).add(state.query);
                    context.pushNamed(
                      LVRoute.productDetailScreen.route,
                      extra: product,
                    );
                  },
                );
              },
              childCount: state.sortedResults.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Empty state: history + featured suggestions ───────────────────────────────

class _EmptyState extends ConsumerWidget {
  final ValueChanged<String> onHistoryTap;
  const _EmptyState({required this.onHistoryTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(searchHistoryProvider);
    final featuredAsync = ref.watch(featuredProductsProvider);
    final vc = context.vColors;

    return CustomScrollView(
      slivers: [
        // ── Recent searches ─────────────────────────────────────────
        if (history.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
              child: Row(
                children: [
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: vc.onSurface,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () =>
                        ref.read(searchHistoryProvider.notifier).clearAll(),
                    child: Text(
                      'Clear all',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: history
                    .map((q) => _HistoryChip(
                          query: q,
                          onTap: () => onHistoryTap(q),
                          onRemove: () => ref
                              .read(searchHistoryProvider.notifier)
                              .remove(q),
                        ))
                    .toList(),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8.h)),
          SliverToBoxAdapter(
            child: Divider(
              color: vc.divider,
              thickness: 1,
              height: 1,
            ),
          ),
        ],

        // ── Suggested: Featured products ─────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
            child: Row(
              children: [
                Text(
                  'You might like',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: vc.onSurface,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push(LVRoute.featuredProductsScreen.route),
                  child: Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        featuredAsync.when(
          loading: () => const SliverToBoxAdapter(child: ProductGridShimmer()),
          error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          data: (products) {
            final visible = products
                .where((p) =>
                    (p.quantity ?? 0) > 0 &&
                    (p.parentId == null || p.parentId!.isEmpty))
                .take(8)
                .toList();

            if (visible.isEmpty) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }

            return SliverPadding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 80.h),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.h,
                  crossAxisSpacing: 10.w,
                  mainAxisExtent: ProductItemCard.preferredHeight,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = visible[index];
                    return ProductItemCard(
                      key: ValueKey(product.id),
                      product: product,
                      margin: EdgeInsets.symmetric(
                          horizontal: 4.w, vertical: 4.h),
                      width: double.infinity,
                      onTap: () => context.pushNamed(
                        LVRoute.productDetailScreen.route,
                        extra: product,
                      ),
                    );
                  },
                  childCount: visible.length,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _HistoryChip extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _HistoryChip({
    required this.query,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: vc.surfaceVariant,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: vc.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 14.sp,
              color: vc.onSurfaceMuted,
            ),
            SizedBox(width: 5.w),
            Text(
              query,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: vc.onSurface,
              ),
            ),
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close_rounded,
                size: 14.sp,
                color: vc.onSurfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Brand row (unchanged) ─────────────────────────────────────────────────────

class _BrandsRow extends ConsumerWidget {
  final String query;
  const _BrandsRow({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandsAsync = ref.watch(brandProvider);

    return brandsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (brands) {
        final q = query.trim().toLowerCase();
        if (q.isEmpty) return const SizedBox.shrink();
        final filtered = brands
            .where((b) => (b.name ?? '').toLowerCase().contains(q))
            .toList();
        if (filtered.isEmpty) return const SizedBox.shrink();
        return Container(
          color: context.vColors.surface,
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: SizedBox(
            height: 96.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final brand = filtered[index];
                return BrandCard(
                  name: brand.name ?? '',
                  imageUrl: brand.images?.firstOrNull?.url ??
                      brand.images?.firstOrNull?.path,
                  onTap: () => context.pushNamed(
                    'brandDetailScreen',
                    pathParameters: {'slug': brand.slug ?? ''},
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
