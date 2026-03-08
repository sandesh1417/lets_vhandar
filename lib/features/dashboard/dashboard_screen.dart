import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/cart/cart_screen.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/dashboard/providers/dashboard_provider.dart';
import 'package:lets_vhandar/features/home/home_screen.dart';
import 'package:lets_vhandar/features/home/presentation/category_screen.dart';
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
    const Center(child: Text("List")),
    const CartScreen(), // Replaced placeholder with CartScreen
    const Center(child: Text("Account")),
  ];

  @override
  Widget build(BuildContext context) {
    final cartItemCount = ref.watch(totalCartItemsProvider);
    final currentIndex = ref.watch(dashboardIndexProvider);

    return CustomScaffoldWrapper(
      // appBar: const CustomAppBar(
      //   hideBackBtn: true,
      //   title: 'Vhandar',
      // ),
      isScrollable: false,
      floatingActionButton: cartItemCount > 0 && currentIndex != 3
          ? SizedBox(
              width: 60.w,
              height: 60.h,
              child: FloatingActionButton(
                onPressed: () {
                  ref.read(dashboardIndexProvider.notifier).state = 3;
                },
                backgroundColor: AppColor.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Badge(
                  label: Text(
                    '$cartItemCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: AppColor.secondary, // Yellow badge
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  offset: const Offset(4, -4),
                  child: Icon(Icons.shopping_cart,
                      color: Colors.white, size: 28.sp),
                ),
              ),
            )
          : null,
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(dashboardIndexProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColor.primary,
        unselectedItemColor: AppColor.lgrayTxt,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Category',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            activeIcon: Icon(Icons.list_alt_rounded),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: cartItemCount > 0,
              label: Text('$cartItemCount'),
              backgroundColor: Colors.red,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: cartItemCount > 0,
              label: Text('$cartItemCount'),
              backgroundColor: Colors.red,
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
