import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/features/home/widgets/home_banner_slider.dart';
import 'package:lets_vhandar/features/home/widgets/home_categories_grid.dart';
import 'package:lets_vhandar/features/home/widgets/home_category_product_list.dart';
import 'package:lets_vhandar/features/home/widgets/home_header.dart';
import 'package:lets_vhandar/features/home/widgets/home_section_title.dart';
import 'package:lets_vhandar/features/home/widgets/home_featured_brands_list.dart';
import 'package:lets_vhandar/features/home/widgets/home_top_selling_list.dart';
import 'package:lets_vhandar/features/home/providers/banner_provider.dart';
import 'package:lets_vhandar/features/home/providers/product_provider.dart';
import 'package:lets_vhandar/features/home/providers/category_provider.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/dashboard/providers/dashboard_provider.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/features/profile/presentation/product_suggestion_screen.dart';
import 'package:lets_vhandar/core/providers/connectivity_provider.dart';
// import 'package:lets_vhandar/features/home/widgets/home_featured_products_list.dart';

class _SuggestProductCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF1A2E25) : const Color(0xFFE8F5EF),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "Didn't find ",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          color: context.isDark ? const Color(0xFFB2DFCB) : const Color(0xFF1A3D2E),
                          height: 1.3,
                        ),
                      ),
                    ),
                    Image.asset(
                      KImageConstant.sadFaceGif,
                      width: 28.w,
                      height: 28.w,
                    ),
                  ],
                ),
                Text(
                  'what you were looking for?',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    color: context.isDark ? const Color(0xFFB2DFCB) : const Color(0xFF1A3D2E),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Suggest something & we'll look into it",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    color: vc.onSurfaceMuted,
                  ),
                ),
                SizedBox(height: 20.h),
                OutlinedButton(
                  onPressed: () =>
                      showProductSuggestionSheet(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.secondary,
                    side: BorderSide(color: AppColor.secondary, width: 1.5),
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Suggest a Product',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          SvgPicture.asset(
            'assets/images/suggest_product.svg',
            width: 110.w,
            height: 110.w,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _BackToTopButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackToTopButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.18)
                    : Colors.black.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 18.sp,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Back to Top',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  final _showBackToTop = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.listenManual(tabReactivateProvider(0), (prev, next) {
      if (!_scrollController.hasClients) return;
      if (_scrollController.offset > 0) {
        _scrollToTop();
      } else {
        ref.invalidate(bannerProvider);
        ref.invalidate(featuredProductsProvider);
        ref.invalidate(homeCategoryProvider);
        ref.invalidate(allCategoryProvider);
      }
    });
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    if (max <= 0) return;
    final show = _scrollController.offset / max >= 0.4;
    if (show != _showBackToTop.value) {
      _showBackToTop.value = show;
    }
  }

  void _scrollToTop() {
    HapticFeedback.mediumImpact();
    if (_scrollController.hasClients && _scrollController.offset > 0) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      ref.invalidate(bannerProvider);
      ref.invalidate(featuredProductsProvider);
      ref.invalidate(homeCategoryProvider);
      ref.invalidate(allCategoryProvider);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _showBackToTop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isOffline = ref.watch(connectivityProvider).maybeWhen(
          data: (online) => !online,
          orElse: () => false,
        );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColor.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Container(
        color: context.vColors.scaffoldBg,
        child: Stack(
          children: [
            RefreshIndicator(
              color: AppColor.primary,
              onRefresh: () async {
                ref.invalidate(bannerProvider);
                ref.invalidate(featuredProductsProvider);
                ref.invalidate(homeCategoryProvider);
                ref.invalidate(allCategoryProvider);
                try {
                  await Future.wait([
                    ref.read(bannerProvider.future),
                    ref.read(featuredProductsProvider.future),
                    ref.read(homeCategoryProvider.future),
                  ]);
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Refresh failed. Check your connection.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(
                    decelerationRate: ScrollDecelerationRate.fast,
                  ),
                ),
                slivers: [
                  HomeHeader(onLogoTap: _scrollToTop),
                  if (isOffline)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _HomeOfflineBody(),
                    )
                  else
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),
                        const HomeBannerSlider(),
                        SizedBox(height: 16.h),
                        HomeSectionTitle(
                          title: 'Featured Products',
                          subtitle: 'Hand-picked for you today',
                          onSeeAll: () => context.push(LVRoute.featuredProductsScreen.route),
                        ),
                        const HomeFeaturedProductsList(),
                        SizedBox(height: 16.h),
                        HomeSectionTitle(
                          title: 'Shop by Category',
                          subtitle: 'Find exactly what you need',
                          onSeeAll: () {
                            ref.read(categoryScreenTabProvider.notifier).state = 0;
                            ref.read(visitedTabsProvider.notifier).update((s) => {...s, 1});
                            ref.read(dashboardIndexProvider.notifier).state = 1;
                          },
                        ),
                        // ignore: prefer_const_constructors
                        HomeCategoriesGrid(),
                        SizedBox(height: 16.h),
                        // ignore: prefer_const_constructors
                        HomeCategoryProductList(),
                        SizedBox(height: 16.h),
                        HomeSectionTitle(
                          title: 'Featured Brands',
                          subtitle: 'Top brands we carry',
                          onSeeAll: () => context.push('/brands'),
                        ),
                        const HomeFeaturedBrandsList(),
                        SizedBox(height: 24.h),
                        _SuggestProductCard(),
                        SizedBox(height: 16.h),
                        Opacity(
                          opacity: 0.5,
                          child: SizedBox(
                            width: double.infinity,
                            height: 200.h,
                            child: SvgPicture.asset(
                              'assets/images/delivering_happiness.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).padding.bottom + 80.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Frosted glass back-to-top button
            Positioned(
              top: topPadding + 80.h,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<bool>(
                valueListenable: _showBackToTop,
                builder: (context, show, child) => AnimatedOpacity(
                  opacity: show ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: IgnorePointer(
                    ignoring: !show,
                    child: child,
                  ),
                ),
                child: Center(child: _BackToTopButton(onTap: _scrollToTop)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeOfflineBody extends StatelessWidget {
  const _HomeOfflineBody();

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 36.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
            'Please check your Wi-Fi or mobile data\nand pull down to refresh.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: vc.onSurfaceMuted,
              height: 1.6,
            ),
          ),
          SizedBox(height: 28.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(50.r),
              border: Border.all(
                  color: AppColor.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded,
                    size: 16.sp, color: AppColor.primary),
                SizedBox(width: 6.w),
                Text(
                  'Pull down to refresh',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primary,
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
