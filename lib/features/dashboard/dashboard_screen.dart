import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
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

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  static const List<Widget Function()> _builders = [
    HomeScreen.new,
    CategoryScreen.new,
    OrderScreen.new,
    ReorderScreen.new,
    AccountTab.new,
  ];

  late final List<Widget?> _cache = List.filled(_builders.length, null);
  DateTime? _lastBackPressTime;

  // Drives the navbar: value 0 = full/expanded, 1 = compact. Animated by
  // scroll DIRECTION (Instagram style). Only the navbar listens to it, so
  // scrolling never rebuilds the page.
  late final AnimationController _navCtrl = AnimationController(
    vsync: this,
    duration: _NavTuning.animDuration,
  );
  double _lastScrollOffset = 0;

  @override
  void dispose() {
    _navCtrl.dispose();
    super.dispose();
  }

  // Scroll DIRECTION → expand/collapse. Throttled to ±2px.
  bool _onScroll(ScrollNotification n) {
    // Ignore horizontal carousels and nested inner scrollables.
    if (n.metrics.axis != Axis.vertical || n.depth != 0) return false;
    final px = n.metrics.pixels;

    if (px <= 0) {
      _navCtrl.animateTo(0, curve: _NavTuning.animCurve); // top → expanded
    } else if (px > _lastScrollOffset + _NavTuning.scrollDelta) {
      _navCtrl.animateTo(1, curve: _NavTuning.animCurve); // down → compact
    } else if (px < _lastScrollOffset - _NavTuning.scrollDelta) {
      _navCtrl.animateTo(0, curve: _NavTuning.animCurve); // up → expand
    }
    _lastScrollOffset = px;
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
      _navCtrl.animateTo(0, curve: _NavTuning.animCurve); // expand
      _lastScrollOffset = 0;
      return;
    }
    ref.read(visitedTabsProvider.notifier).update((s) => {...s, index});
    ref.read(dashboardIndexProvider.notifier).state = index;
    _navCtrl.animateTo(0, curve: _NavTuning.animCurve); // new tab starts full
    _lastScrollOffset = 0;
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
          scrollProgress: _navCtrl,
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
/// One place to tune the floating navbar. `*Exp` = full state, `*Cmp` = compact
/// (scrolled-down) state. The bar lerps between them by scroll DIRECTION.
/// ───────────────────────────────────────────────────────────────────────────
class _NavTuning {
  // Scroll → direction detection + animation.
  static const double scrollDelta = 2; // px before a direction change counts
  static const Duration animDuration = Duration(milliseconds: 280);
  static const Curve animCurve = Curves.easeOutCubic;

  // Pill geometry.
  static const double heightExp = 64;
  static const double heightCmp = 52;
  static const double radiusExp = 28; // gets rounder/tighter when shrunk
  static const double radiusCmp = 32;
  static const double sideMarginExp = 20; // from screen edges
  static const double sideMarginCmp = 28;
  static const double bottomMargin = 12; // floating gap above safe area
  static const double innerPadH = 8; // padding inside the pill

  // Icons + labels.
  static const double iconExp = 26;
  static const double iconCmp = 22;
  static const double labelSize = 11;
  static const double labelGap = 3; // icon → label (collapses with the label)

  // ── GLASS APPEARANCE — tune these to taste ───────────────────────────────
  // Base color the translucent fill is made of. Light mode = white; nudge
  // toward a tint (e.g. a brand colour) if you want the bar to read coloured.
  static const Color fillColorLight = Colors.white;
  static const Color fillColorDark = Color(0xFF1C1C1E);

  // Fill opacity. LOWER = more of the page behind shows through (more glassy /
  // background more visible). HIGHER = more solid. Kept low so content reads
  // through; the bar is made DISTINCT via the rim + shadow below, not opacity.
  static const double fillAlphaExp = 0.34; // expanded (at top)
  static const double fillAlphaCmp = 0.42; // compact (scrolled)

  // Backdrop blur. HIGHER = frostier wash; LOWER = colours/text behind sharper
  // and more recognisable.
  static const double blurExp = 22;
  static const double blurCmp = 30;

  // Glossy top "shine": extra opacity at the TOP edge so the bar catches light.
  // HIGHER = brighter, shinier top.
  static const double sheenBoost = 0.28;

  // Bright glass rim (specular edge) — THE main thing that separates the bar
  // from the background. HIGHER alpha + WIDTH = crisper, more distinct edge.
  static const Color rimColor = Colors.white;
  static const double rimAlphaLight = 0.95; // light mode
  static const double rimAlphaDark = 0.28; // dark mode
  static const double rimWidth = 1.6;

  // Drop shadow — adds lift/separation from the background. HIGHER opacity and
  // blur = more obviously "floating" and distinct.
  static const Color shadowColor = Colors.black;
  static const double shadowOpacityExp = 0.24;
  static const double shadowOpacityCmp = 0.32;
  static const double shadowBlur = 30;
  static const Offset shadowOffset = Offset(0, -5);

  // Selected chip (the indicator — no dot).
  static const double chipPadH = 12;
  static const double chipPadV = 4;
  static const double chipRadius = 12;
  static const double selectedScale = 1.1;
  // Unselected icon + label colour — theme-aware so it stays legible on the
  // light bar (dark grey) and the dark bar (light grey).
  static const Color unselectedColorLight = Color(0xFF48484A); // on light bar
  static const Color unselectedColorDark = Color(0xFFAEAEB2); // on dark bar
  static Color unselected(bool isDark) =>
      isDark ? unselectedColorDark : unselectedColorLight;

  // Selection spring + press feedback.
  static const double springStiffness = 300;
  static const double springDamping = 28;
  static const Duration pressIn = Duration(milliseconds: 100);
  static const Duration pressOut = Duration(milliseconds: 220);
  static const double pressScale = 0.9;
}

class _NavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Animation<double> scrollProgress; // 0 = full, 1 = compact

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

  // Spring pop played on the selected icon (SpringSimulation).
  late final AnimationController _selectCtrl;

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

    // Unbounded so the spring can overshoot past 1.0 then settle.
    _selectCtrl = AnimationController.unbounded(vsync: this, value: 1.0);
  }

  void _popSelected() {
    _selectCtrl.animateWith(SpringSimulation(
      const SpringDescription(
        mass: 1,
        stiffness: _NavTuning.springStiffness,
        damping: _NavTuning.springDamping,
      ),
      0.0, // from
      1.0, // to (rest)
      0.0, // initial velocity
    ));
  }

  @override
  void didUpdateWidget(covariant _NavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _popSelected(); // spring-pop the newly selected tab
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
    final inactiveColor = _NavTuning.unselected(context.isDark);
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
    final isDark = context.isDark;
    // Translucent base so the page color bleeds through the frosted glass.
    final baseFill =
        isDark ? _NavTuning.fillColorDark : _NavTuning.fillColorLight;
    // Bright specular rim — what makes it read as shiny glass / distinct edge.
    final rimColor = _NavTuning.rimColor.withValues(
        alpha: isDark ? _NavTuning.rimAlphaDark : _NavTuning.rimAlphaLight);

    // Only the bar repaints on scroll — the page never rebuilds.
    return SafeArea(
      top: false,
      child: AnimatedBuilder(
        animation: widget.scrollProgress,
        builder: (context, _) {
          final p = widget.scrollProgress.value.clamp(0.0, 1.0);
          double lp(double a, double b) => lerpDouble(a, b, p)!;

          final sideMargin =
              lp(_NavTuning.sideMarginExp, _NavTuning.sideMarginCmp).w;
          final height = lp(_NavTuning.heightExp, _NavTuning.heightCmp).h;
          final radius = lp(_NavTuning.radiusExp, _NavTuning.radiusCmp).r;
          final blur = lp(_NavTuning.blurExp, _NavTuning.blurCmp);
          final fillAlpha =
              lp(_NavTuning.fillAlphaExp, _NavTuning.fillAlphaCmp);
          final topAlpha = (fillAlpha + _NavTuning.sheenBoost).clamp(0.0, 1.0);
          final shadowAlpha =
              lp(_NavTuning.shadowOpacityExp, _NavTuning.shadowOpacityCmp);

          return Padding(
            padding: EdgeInsets.fromLTRB(
                sideMargin, 0, sideMargin, _NavTuning.bottomMargin.h),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                boxShadow: [
                  BoxShadow(
                    color:
                        _NavTuning.shadowColor.withValues(alpha: shadowAlpha),
                    blurRadius: _NavTuning.shadowBlur,
                    offset: _NavTuning.shadowOffset,
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
                      padding: EdgeInsets.symmetric(
                          horizontal: _NavTuning.innerPadH.w),
                      decoration: BoxDecoration(
                        // Glossy top→bottom sheen over the translucent base.
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            baseFill.withValues(alpha: topAlpha),
                            baseFill.withValues(alpha: fillAlpha),
                          ],
                          stops: const [0.0, 0.7],
                        ),
                        borderRadius: BorderRadius.circular(radius),
                        border: Border.all(
                            color: rimColor, width: _NavTuning.rimWidth),
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
    final iconSize = lerpDouble(_NavTuning.iconExp, _NavTuning.iconCmp, p)!.w;
    // Labels fade + collapse as the bar shrinks.
    final labelFactor = (1 - p).clamp(0.0, 1.0);

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
          animation: Listenable.merge([_press[i], _selectCtrl]),
          builder: (context, _) {
            // Selected icon springs to ~1.1× (overshoots, then settles).
            final selScale = isSelected
                ? lerpDouble(0.9, _NavTuning.selectedScale, _selectCtrl.value)!
                : 1.0;
            return Transform.scale(
              scale: _press[i].value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon + green chip indicator (the chip IS the indicator).
                  Transform.scale(
                    scale: selScale,
                    child: AnimatedContainer(
                      duration: _NavTuning.animDuration,
                      curve: _NavTuning.animCurve,
                      padding: isSelected
                          ? EdgeInsets.symmetric(
                              horizontal: _NavTuning.chipPadH.w,
                              vertical: _NavTuning.chipPadV.h)
                          : EdgeInsets.zero,
                      decoration: isSelected
                          ? BoxDecoration(
                              color: AppColor.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(
                                  _NavTuning.chipRadius.r),
                            )
                          : const BoxDecoration(),
                      child: _buildIcon(context, i, isSelected, iconSize),
                    ),
                  ),
                  // Collapsing + fading label.
                  ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: labelFactor,
                      child: Opacity(
                        opacity: labelFactor,
                        child: Padding(
                          padding: EdgeInsets.only(top: _NavTuning.labelGap.h),
                          child: Text(
                            _labels[i],
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: _NavTuning.labelSize.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? AppColor.primary
                                  : _NavTuning.unselected(context.isDark),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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
