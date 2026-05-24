import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/cart/cart_screen.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_floating_badge.dart';
import 'package:lets_vhandar/features/dashboard/presentation/tabs/account_tab.dart';
import 'package:lets_vhandar/features/dashboard/providers/dashboard_provider.dart';
import 'package:lets_vhandar/features/home/home_screen.dart';
import 'package:lets_vhandar/features/home/presentation/category_screen.dart';
import 'package:lets_vhandar/features/order/order_screen.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoryScreen(),
    const OrderScreen(),
    const CartScreen(),
    const AccountTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartItemCount = ref.watch(totalCartItemsProvider);
    final currentIndex = ref.watch(dashboardIndexProvider);

    return CustomScaffoldWrapper(
      isScrollable: false,
      extendBody: true,
      floatingActionButtonLocation: const _AboveNavBarFABLocation(),
      floatingActionButton: currentIndex != 3
          ? CartFloatingBadge(
              onTap: () {
                ref.read(dashboardIndexProvider.notifier).state = 3;
              },
            )
          : null,
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: currentIndex == 3
          ? null
          : Material(
              color: Colors.transparent,
              child: _NavBar(
                currentIndex: currentIndex,
                cartItemCount: cartItemCount,
                onTap: (index) {
                  HapticFeedback.lightImpact();
                  ref.read(dashboardIndexProvider.notifier).state = index;
                },
              ),
            ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int currentIndex;
  final int cartItemCount;
  final ValueChanged<int> onTap;

  const _NavBar({
    required this.currentIndex,
    required this.cartItemCount,
    required this.onTap,
  });

  static const _labels = ['Home', 'Category', 'Orders', 'Cart', 'Account'];

  Widget _buildIcon(int i, bool isSelected) {
    const inactiveFilter = ColorFilter.mode(Color(0xFFADB5B2), BlendMode.srcIn);

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
        return Icon(
          isSelected ? Icons.receipt_long_rounded : Icons.receipt_long_outlined,
          size: 22.w,
          color: isSelected ? AppColor.primary : const Color(0xFFADB5B2),
        );
      case 3:
        return Badge(
          isLabelVisible: cartItemCount > 0,
          label: Text(
            '$cartItemCount',
            style: TextStyle(
              fontSize: 8.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: AppColor.secondary,
          textColor: const Color(0xFF1A1A1A),
          child: SvgPicture.asset(
            'assets/icons/vhandar_cart.svg',
            width: 22.w,
            height: 22.w,
            colorFilter: isSelected
                ? ColorFilter.mode(AppColor.primary, BlendMode.srcIn)
                : inactiveFilter,
          ),
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
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 64.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(_labels.length, (i) {
                  final isSelected = currentIndex == i;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildIcon(i, isSelected),
                          SizedBox(height: 3.h),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontFamily: 'Inter',
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColor.primary
                                  : const Color(0xFFADB5B2),
                            ),
                            child: Text(_labels[i]),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
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
