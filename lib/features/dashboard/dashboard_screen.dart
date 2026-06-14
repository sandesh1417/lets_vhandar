import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/services/update_service.dart';
import 'package:lets_vhandar/core/widgets/update_sheet.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/providers/connectivity_provider.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_floating_badge.dart';
import 'package:lets_vhandar/features/dashboard/presentation/tabs/account_tab.dart';
import 'package:lets_vhandar/features/dashboard/providers/dashboard_provider.dart';
import 'package:lets_vhandar/features/home/home_screen.dart';
import 'package:lets_vhandar/features/home/presentation/category_screen.dart';
import 'package:lets_vhandar/features/home/providers/banner_provider.dart';
import 'package:lets_vhandar/features/home/providers/category_provider.dart';
import 'package:lets_vhandar/features/home/providers/product_provider.dart';
import 'package:lets_vhandar/features/order/order_screen.dart';
import 'package:lets_vhandar/features/reorder/reorder_screen.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  static const List<Widget Function()> _builders = [
    HomeScreen.new,
    CategoryScreen.new,
    OrderScreen.new,
    ReorderScreen.new,
    AccountTab.new,
  ];

  late final List<Widget?> _cache = List.filled(_builders.length, null);
  DateTime? _lastBackPressTime;

  // Drives the scroll-reactive navbar: 0 = expanded (at top), 1 = compact.
  // Only the navbar listens to this, so scrolling never rebuilds the page.
  final ValueNotifier<double> _scrollProgress = ValueNotifier<double>(0);

  @override
  void dispose() {
    _scrollProgress.dispose();
    super.dispose();
  }

  // Feeds the active tab's primary vertical scroll into [_scrollProgress].
  bool _onScroll(ScrollNotification n) {
    // Ignore horizontal carousels and nested inner scrollables.
    if (n.metrics.axis != Axis.vertical || n.depth != 0) return false;
    final p = (n.metrics.pixels / _NavTuning.scrollThreshold).clamp(0.0, 1.0);
    if ((p - _scrollProgress.value).abs() > 0.002) {
      _scrollProgress.value = p;
    }
    return false;
  }

  Widget _tab(int index) {
    final visited = ref.read(visitedTabsProvider);
    if (!visited.contains(index)) return const SizedBox.shrink();
    return _cache[index] ??= _builders[index]();
  }

  void _goToTab(int index) {
    final current = ref.read(dashboardIndexProvider);
    if (index == current) {
      // Same tab tapped again — signal it to scroll-to-top / refresh
      ref.read(tabReactivateProvider(index).notifier).state++;
      _scrollProgress.value = 0; // bar expands as content returns to top
      return;
    }
    ref.read(visitedTabsProvider.notifier).update((s) => {...s, index});
    ref.read(dashboardIndexProvider.notifier).state = index;
    _scrollProgress.value = 0; // new tab starts expanded
  }

  void _refreshAllProviders() {
    ref.invalidate(bannerProvider);
    ref.invalidate(featuredProductsProvider);
    ref.invalidate(homeCategoryProvider);
    ref.invalidate(allCategoryProvider);
  }

  Future<bool> _onBackPressed() {
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      CustomSnackbar.info(context, message: 'Press again to exit');
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(dashboardIndexProvider);
    ref.watch(visitedTabsProvider);

    // Ensure the active tab is always in visitedTabsProvider, regardless of
    // who set dashboardIndexProvider (bottom nav, Account tab button, etc.)
    ref.listen<int>(dashboardIndexProvider, (_, idx) {
      ref.read(visitedTabsProvider.notifier).update((s) => {...s, idx});
    });

    // Auto-refresh providers when coming back online
    ref.listen<AsyncValue<bool>>(connectivityProvider, (prev, next) {
      final wasOnline = prev?.valueOrNull ?? true;
      final isOnline = next.valueOrNull ?? true;
      if (isOnline && !wasOnline) {
        _refreshAllProviders();
        CustomSnackbar.success(context, message: 'Back online');
      }
    });

    final dashboard = UpdateService.instance.updateType == UpdateType.optional
        ? OptionalUpdateListener(child: _buildDashboard(context, currentIndex))
        : _buildDashboard(context, currentIndex);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final should = await _onBackPressed();
          if (should && mounted) SystemNavigator.pop();
        }
      },
      child: dashboard,
    );
  }

  Widget _buildDashboard(BuildContext context, int currentIndex) {
    return CustomScaffoldWrapper(
      isScrollable: false,
      extendBody: true,
      bottomSafeArea: false,
      floatingActionButtonLocation: const _AboveNavBarFABLocation(),
      floatingActionButton: CartFloatingBadge(
        onTap: () => context.push(LVRoute.cartScreen.route),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: RepaintBoundary(
          child: IndexedStack(
            index: currentIndex,
            children: List.generate(_builders.length, _tab),
          ),
        ),
      ),
      bottomNavigationBar: Material(
        color: Colors.transparent,
        child: _NavBar(
          currentIndex: currentIndex,
          scrollProgress: _scrollProgress,
          onTap: (index) {
            HapticFeedback.lightImpact();
            _goToTab(index);
          },
        ),
      ),
    );
  }
}

/// ───────────────────────────────────────────────────────────────────────────
/// One place to tune the floating navbar's look & motion.
/// `*Expanded` = value at scroll top; `*Scrolled` = value once fully compact.
/// ───────────────────────────────────────────────────────────────────────────
class _NavTuning {
  // Scroll → progress.
  static const double scrollThreshold = 80; // px of scroll to go fully compact
  static const Curve resizeCurve = Curves.easeOutCubic;

  // Outer side padding (bigger ⇒ narrower bar) — ~10% width shrink.
  static const double sidePadExpanded = 12;
  static const double sidePadScrolled = 26;
  // Gap beneath the bar.
  static const double bottomPadExpanded = 10;
  static const double bottomPadScrolled = 8;
  // Bar height — ~19% shrink.
  static const double heightExpanded = 72;
  static const double heightScrolled = 58;
  // Corner radius — tighter pill when scrolled.
  static const double radiusExpanded = 30;
  static const double radiusScrolled = 34;

  // Frosted-glass blur sigma.
  static const double blurExpanded = 9;
  static const double blurScrolled = 22;
  // Translucent fill over the blur (content stays faintly visible).
  static const double fillAlphaExpanded = 0.55;
  static const double fillAlphaScrolled = 0.72;
  // Specular top-edge highlight (white).
  static const double borderAlphaExpanded = 0.22;
  static const double borderAlphaScrolled = 0.30;

  // Soft drop shadow (deepens as the bar lifts off content).
  static const double shadowBlurExpanded = 18;
  static const double shadowBlurScrolled = 28;
  static const double shadowAlphaExpanded = 0.08;
  static const double shadowAlphaScrolled = 0.13;
  static const double shadowDyExpanded = 4;
  static const double shadowDyScrolled = 10;

  // Icon sizes.
  static const double iconSelected = 24;
  static const double iconUnselected = 21;

  // Motion.
  static const Duration selectBounce = Duration(milliseconds: 420);
  static const double selectPop = 1.18; // overshoot scale on selection
  static const Duration indicatorMorph = Duration(milliseconds: 250);
  static const Duration pressIn = Duration(milliseconds: 100);
  static const Duration pressOut = Duration(milliseconds: 220);
  static const double pressScale = 0.86;
}

class _NavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final ValueNotifier<double> scrollProgress;

  const _NavBar({
    required this.currentIndex,
    required this.onTap,
    required this.scrollProgress,
  });

  @override
  State<_NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<_NavBar> with TickerProviderStateMixin {
  static const _labels = ['Home', 'Category', 'Orders', 'Reorder', 'Account'];

  // Per-item press scale.
  late final List<AnimationController> _press;

  // Gentle spring bounce played on the newly selected item.
  late final AnimationController _selectCtrl;
  late final Animation<double> _selectScale;

  @override
  void initState() {
    super.initState();
    _press = List.generate(
      _labels.length,
      (_) => AnimationController(
        vsync: this,
        duration: _NavTuning.pressIn,
        reverseDuration: _NavTuning.pressOut,
        lowerBound: _NavTuning.pressScale,
        upperBound: 1.0,
        value: 1.0,
      ),
    );

    _selectCtrl = AnimationController(
      vsync: this,
      duration: _NavTuning.selectBounce,
      value: 1.0,
    );
    _selectScale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: _NavTuning.selectPop), weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: _NavTuning.selectPop, end: 0.96), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _selectCtrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant _NavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _selectCtrl.forward(from: 0); // pop the newly selected tab
    }
  }

  @override
  void dispose() {
    for (final c in _press) {
      c.dispose();
    }
    _selectCtrl.dispose();
    super.dispose();
  }

  Widget _buildIcon(BuildContext context, int i, bool isSelected, double size) {
    final inactiveColor = context.vColors.onSurfaceMuted;
    final inactiveFilter = ColorFilter.mode(inactiveColor, BlendMode.srcIn);

    switch (i) {
      case 0:
        return SvgPicture.asset(
          isSelected
              ? 'assets/icons/vhandar-home-active.svg'
              : 'assets/icons/vhandar-home.svg',
          width: size,
          height: size,
        );
      case 1:
        return SvgPicture.asset(
          isSelected
              ? 'assets/icons/category-active.svg'
              : 'assets/icons/categories.svg',
          width: size,
          height: size,
          colorFilter: isSelected ? null : inactiveFilter,
        );
      case 2:
        return SvgPicture.asset(
          isSelected
              ? 'assets/icons/order-active.svg'
              : 'assets/icons/order.svg',
          width: size,
          height: size,
          colorFilter: isSelected ? null : inactiveFilter,
        );
      case 3:
        return SvgPicture.asset(
          isSelected
              ? 'assets/icons/reorder-icon-active.svg'
              : 'assets/icons/reorder-icon.svg',
          width: size,
          height: size,
          colorFilter: isSelected ? null : inactiveFilter,
        );
      default:
        return SvgPicture.asset(
          isSelected
              ? 'assets/icons/account-active.svg'
              : 'assets/icons/account.svg',
          width: size,
          height: size,
          colorFilter: isSelected ? null : inactiveFilter,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    // Only the bar repaints on scroll — the page never rebuilds.
    return SafeArea(
      top: false,
      child: ValueListenableBuilder<double>(
        valueListenable: widget.scrollProgress,
        builder: (context, raw, _) {
          final p = _NavTuning.resizeCurve.transform(raw.clamp(0.0, 1.0));
          double lp(double a, double b) => lerpDouble(a, b, p)!;

          final sidePad =
              lp(_NavTuning.sidePadExpanded, _NavTuning.sidePadScrolled).w;
          final bottomPad =
              lp(_NavTuning.bottomPadExpanded, _NavTuning.bottomPadScrolled).h;
          final height =
              lp(_NavTuning.heightExpanded, _NavTuning.heightScrolled).h;
          final radius =
              lp(_NavTuning.radiusExpanded, _NavTuning.radiusScrolled).r;
          final blur = lp(_NavTuning.blurExpanded, _NavTuning.blurScrolled);
          final fillAlpha =
              lp(_NavTuning.fillAlphaExpanded, _NavTuning.fillAlphaScrolled);
          final borderAlpha = lp(
              _NavTuning.borderAlphaExpanded, _NavTuning.borderAlphaScrolled);
          final shadowBlur =
              lp(_NavTuning.shadowBlurExpanded, _NavTuning.shadowBlurScrolled);
          final shadowAlpha = lp(
              _NavTuning.shadowAlphaExpanded, _NavTuning.shadowAlphaScrolled);
          final shadowDy =
              lp(_NavTuning.shadowDyExpanded, _NavTuning.shadowDyScrolled);

          return Padding(
            padding: EdgeInsets.fromLTRB(sidePad, 0, sidePad, bottomPad),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: shadowAlpha),
                    blurRadius: shadowBlur,
                    spreadRadius: -2,
                    offset: Offset(0, shadowDy),
                  ),
                ],
              ),
              child: RepaintBoundary(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        color: vc.navBarBg.withValues(alpha: fillAlpha),
                        borderRadius: BorderRadius.circular(radius),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: borderAlpha),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: List.generate(
                            _labels.length, (i) => _item(context, i, p)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _item(BuildContext context, int i, double p) {
    final isSelected = widget.currentIndex == i;
    final iconSize =
        (isSelected ? _NavTuning.iconSelected : _NavTuning.iconUnselected).w;
    // Inner content tightens as the bar compacts.
    final vPad = lerpDouble(6, 3, p)!.h;
    final labelGap = lerpDouble(3, 1.5, p)!.h;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _press[i].reverse(),
        onTapUp: (_) {
          _press[i].forward();
          widget.onTap(i);
        },
        onTapCancel: () => _press[i].forward(),
        child: AnimatedBuilder(
          // Press scale + selection spring-bounce drive the same transform.
          animation: Listenable.merge([_press[i], _selectCtrl]),
          builder: (context, child) {
            final sel = isSelected ? _selectScale.value : 1.0;
            return Transform.scale(scale: _press[i].value * sel, child: child);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: vPad, horizontal: 5.w),
            child: AnimatedContainer(
              duration: _NavTuning.indicatorMorph,
              curve: Curves.easeOutCubic,
              decoration: isSelected
                  ? BoxDecoration(
                      color: AppColor.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(
                        color: AppColor.primary.withValues(alpha: 0.45),
                        width: 1.5,
                      ),
                    )
                  : const BoxDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIcon(context, i, isSelected, iconSize),
                  SizedBox(height: labelGap),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: isSelected ? 10.5.sp : 9.5.sp,
                      fontFamily: 'Inter',
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected
                          ? AppColor.primary
                          : context.vColors.onSurfaceMuted,
                    ),
                    child: Text(_labels[i]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AboveNavBarFABLocation extends FloatingActionButtonLocation {
  const _AboveNavBarFABLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double x = (scaffoldGeometry.scaffoldSize.width -
            scaffoldGeometry.floatingActionButtonSize.width) /
        2.0;
    final double y = scaffoldGeometry.contentBottom -
        scaffoldGeometry.floatingActionButtonSize.height -
        6.0;
    return Offset(x, y);
  }
}
