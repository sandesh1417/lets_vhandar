import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/providers/connectivity_provider.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/dashboard/providers/dashboard_provider.dart';
import 'package:lets_vhandar/features/home/providers/banner_provider.dart';
import 'package:lets_vhandar/features/home/providers/category_provider.dart';
import 'package:lets_vhandar/features/home/providers/product_provider.dart';
import 'package:lets_vhandar/features/home/widgets/home_back_to_top_button.dart';
import 'package:lets_vhandar/features/home/widgets/home_banner_slider.dart';
import 'package:lets_vhandar/features/home/widgets/home_categories_grid.dart';
import 'package:lets_vhandar/features/home/widgets/home_category_product_list.dart';
import 'package:lets_vhandar/features/home/widgets/home_featured_brands_list.dart';
import 'package:lets_vhandar/features/home/widgets/home_header.dart';
import 'package:lets_vhandar/features/home/widgets/home_offline_body.dart';
import 'package:lets_vhandar/features/home/widgets/home_section_title.dart';
import 'package:lets_vhandar/features/home/widgets/home_suggest_card.dart';
import 'package:lets_vhandar/features/home/widgets/home_top_selling_list.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';

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
                    CustomSnackbar.error(context,
                        message: 'Refresh failed. Check your connection.');
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
                      child: HomeOfflineBody(),
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
                            onSeeAll: () => context
                                .push(LVRoute.featuredProductsScreen.route),
                          ),
                          const HomeFeaturedProductsList(),
                          SizedBox(height: 16.h),
                          HomeSectionTitle(
                            title: 'Shop by Category',
                            subtitle: 'Find exactly what you need',
                            onSeeAll: () {
                              ref
                                  .read(categoryScreenTabProvider.notifier)
                                  .state = 0;
                              ref
                                  .read(visitedTabsProvider.notifier)
                                  .update((s) => {...s, 1});
                              ref.read(dashboardIndexProvider.notifier).state =
                                  1;
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
                          const HomeSuggestCard(),
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
                          SizedBox(
                              height:
                                  MediaQuery.of(context).padding.bottom + 110.h),
                        ],
                      ),
                    ),
                ],
              ),
            ),
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
                child: Center(
                  child: HomeBackToTopButton(onTap: _scrollToTop),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
