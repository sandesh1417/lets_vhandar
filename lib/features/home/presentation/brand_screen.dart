import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/utils/utils.dart';
import 'package:lets_vhandar/features/home/presentation/widgets/brand_card.dart';
import 'package:lets_vhandar/features/home/providers/brand_provider.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';
import 'package:lets_vhandar/widgets/error_state.dart';
import 'package:lets_vhandar/widgets/premium_search_bar.dart';
import 'package:lets_vhandar/widgets/app_refresh_indicator.dart';

class BrandScreen extends ConsumerStatefulWidget {
  const BrandScreen({super.key});

  @override
  ConsumerState<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends ConsumerState<BrandScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brandsAsync = ref.watch(brandProvider);

    final statusBarHeight = MediaQuery.of(context).padding.top;

    return CustomScaffoldWrapper(
      backgroundColor: context.vColors.scaffoldBg,
      isScrollable: false,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // ── Green header: back + logo + search ─────────────────────
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
                  onTap: () => context.pop(),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
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
                    hintText: 'Search for products...',
                    showScanIcon: true,
                    readOnly: true,
                    onTap: () => context.pushNamed(LVRoute.searchScreen.route),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: brandsAsync.when(
              data: (brands) {
                if (brands.isEmpty) {
                  return const Center(child: Text("No brands found"));
                }

                final filteredBrands = brands;

                return AppRefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(brandProvider);
                  },
                  child: GridView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.82,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 16.h,
                    ),
                    itemCount: filteredBrands.length,
                    itemBuilder: (context, index) {
                      final brand = filteredBrands[index];
                      return BrandCard(
                        name: brand.name ?? '',
                        imageUrl: brand.images?.isNotEmpty == true
                            ? brand.images!.first.url
                            : null,
                        onTap: () =>
                            navigateToSlug(context, brand.slug, isBrand: true),
                      );
                    },
                  ),
                );
              },
              loading: () => const GridShimmer(),
              error: (_, __) => ErrorStateWidget(
                onRetry: () => ref.invalidate(brandProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
