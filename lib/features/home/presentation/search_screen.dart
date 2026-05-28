import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/home/providers/brand_provider.dart';
import 'package:lets_vhandar/features/home/providers/search_provider.dart';
import 'package:lets_vhandar/features/home/widgets/product_item_card.dart';
import 'package:lets_vhandar/features/home/widgets/search_sort_bar.dart';
import 'package:lets_vhandar/features/home/presentation/widgets/brand_card.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';
import 'package:lets_vhandar/widgets/premium_search_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                        setState(() {});
                        ref.read(searchProvider.notifier).search(value);
                      },
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
    if (state.isLoading && state.results.isEmpty) {
      return const ProductGridShimmer();
    }

    if (state.error != null) {
      return Center(
        child: Text(
          state.error!,
          style: TextStyle(color: Colors.red, fontSize: 14.sp),
        ),
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
                    ElevatedButton(
                      onPressed: () {
                        context.pushNamed(LVRoute.productSuggestionScreen.route);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF9B141),
                        foregroundColor: Colors.white,
                        minimumSize: Size(120.w, 44.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Suggest Product',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
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
        if (state.isLoading)
          SliverToBoxAdapter(
            child: LinearProgressIndicator(color: AppColor.primary),
          ),
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
                  onTap: () => context.pushNamed(
                    LVRoute.productDetailScreen.route,
                    extra: product,
                  ),
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
