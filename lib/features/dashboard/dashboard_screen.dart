import 'dart:ui';

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
import 'package:lets_vhandar/features/dashboard/presentation/tabs/account_tab.dart';
import 'package:lets_vhandar/features/dashboard/providers/dashboard_provider.dart';
import 'package:lets_vhandar/features/home/home_screen.dart';
import 'package:lets_vhandar/features/home/presentation/category_screen.dart';
import 'package:lets_vhandar/features/order/order_screen.dart';
import 'package:lets_vhandar/features/reorder/reorder_screen.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

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

  Widget _tab(int index) {
    final visited = ref.read(visitedTabsProvider);
    if (!visited.contains(index)) return const SizedBox.shrink();
    return _cache[index] ??= _builders[index]();
  }

  void _goToTab(int index) {
    ref.read(visitedTabsProvider.notifier).update((s) => {...s, index});
    ref.read(dashboardIndexProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(dashboardIndexProvider);
    // Rebuild when visited set changes so newly visited tabs get built
    ref.watch(visitedTabsProvider);

    return CustomScaffoldWrapper(
      isScrollable: false,
      extendBody: true,
      floatingActionButtonLocation: const _AboveNavBarFABLocation(),
      floatingActionButton: CartFloatingBadge(
        onTap: () => context.push(LVRoute.cartScreen.route),
      ),
      body: RepaintBoundary(
        child: IndexedStack(
          index: currentIndex,
          children: List.generate(_builders.length, _tab),
        ),
      ),
      bottomNavigationBar: Material(
        color: Colors.transparent,
        child: _NavBar(
          currentIndex: currentIndex,
          onTap: (index) {
            HapticFeedback.lightImpact();
            _goToTab(index);
          },
        ),
      ),
    );
  }
}

class _NavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<_NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<_NavBar> with TickerProviderStateMixin {
  static const _labels = ['Home', 'Category', 'Orders', 'Reorder', 'Account'];

  // Per-item press scale
  late final List<AnimationController> _press;

  @override
  void initState() {
    super.initState();
    _press = List.generate(
      _labels.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        reverseDuration: const Duration(milliseconds: 220),
        lowerBound: 0.86,
        upperBound: 1.0,
        value: 1.0,
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _press) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _buildIcon(BuildContext context, int i, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor =
        isDark ? const Color(0xFFB8C4C0) : const Color(0xFF6B7B76);
    final inactiveFilter = ColorFilter.mode(inactiveColor, BlendMode.srcIn);

    switch (i) {
      case 0:
        return SvgPicture.asset(
          isSelected
              ? 'assets/icons/vhandar-home-active.svg'
              : 'assets/icons/vhandar-home.svg',
          width: 22.w,
          height: 22.w,
        );
      case 1:
        return SvgPicture.asset(
          isSelected
              ? 'assets/icons/category-active.svg'
              : 'assets/icons/categories.svg',
          width: 22.w,
          height: 22.w,
          colorFilter: isSelected ? null : inactiveFilter,
        );
      case 2:
        return SvgPicture.asset(
          isSelected
              ? 'assets/icons/order-active.svg'
              : 'assets/icons/order.svg',
          width: 22.w,
          height: 22.w,
          colorFilter: isSelected ? null : inactiveFilter,
        );
      case 3:
        return SvgPicture.asset(
          isSelected
              ? 'assets/icons/reorder-icon-active.svg'
              : 'assets/icons/reorder-icon.svg',
          width: 22.w,
          height: 22.w,
          colorFilter: isSelected ? null : inactiveFilter,
        );
      default:
        return SvgPicture.asset(
          isSelected
              ? 'assets/icons/account-active.svg'
              : 'assets/icons/account.svg',
          width: 22.w,
          height: 22.w,
          colorFilter: isSelected ? null : inactiveFilter,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 13.h),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 20,
                spreadRadius: -2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: RepaintBoundary(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32.r),
              child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                height: 68.h,
                decoration: BoxDecoration(
                  color: context.vColors.navBarBg,
                  borderRadius: BorderRadius.circular(32.r),
                  border: Border.all(
                    color: context.vColors.navBarBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: List.generate(_labels.length, (i) {
                    final isSelected = widget.currentIndex == i;
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
                          animation: _press[i],
                          builder: (context, child) => Transform.scale(
                            scale: _press[i].value,
                            child: child,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 7.h,
                              horizontal: 5.w,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              decoration: isSelected
                                  ? BoxDecoration(
                                      color: AppColor.primary
                                          .withValues(alpha: 0.12),
                                      borderRadius:
                                          BorderRadius.circular(22.r),
                                      border: Border.all(
                                        color: AppColor.primary
                                            .withValues(alpha: 0.25),
                                        width: 1,
                                      ),
                                    )
                                  : const BoxDecoration(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildIcon(context, i, isSelected),
                                  SizedBox(height: 3.h),
                                  AnimatedDefaultTextStyle(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? AppColor.primary
                                          : Theme.of(context).brightness == Brightness.dark
                                              ? const Color(0xFFB8C4C0)
                                              : const Color(0xFF3A4A46),
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
                  }),
                ),
              ),
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
