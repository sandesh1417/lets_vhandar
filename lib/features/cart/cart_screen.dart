import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalItems = ref.watch(totalCartItemsProvider);
    final totalPrice = ref.watch(totalCartPriceProvider);
    final totalMrp = ref.watch(totalCartMrpProvider);

    return Container(
      color: const Color(0xFFF5F6F8), // Light grey background
      child: Column(
        children: [
          CustomScreenHeader(
            title: 'My Cart',
            trailing: cartItems.isNotEmpty
                ? InkWell(
                    onTap: () {
                      ref.read(cartProvider.notifier).clearCart();
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Clear Cart',
                        style: TextStyle(
                          color: AppColor.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  )
                : null,
          ),
          Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 80.sp, color: Colors.grey.shade400),
                        SizedBox(height: 16.h),
                        Text('Your cart is empty',
                            style: TextStyle(
                                fontSize: 18.sp,
                                color: AppColor.textBlack54,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    children: [
                      // Apply Coupons Banner (Mockup)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.green.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.local_offer,
                                color: AppColor.primary, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text('Apply Coupons & Offers',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.textBlack87)),
                            const Spacer(),
                            Icon(Icons.keyboard_arrow_right,
                                color: AppColor.textBlack54),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Cart Items List
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('${cartItems.length} ITEMS IN CART',
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.textBlack54,
                                        letterSpacing: 0.5)),
                                const Spacer(),
                                Text('₹$totalPrice',
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.primary)),
                              ],
                            ),
                            const Divider(height: 24),
                            // List of items (reusing existing item UI logic or similar)
                            // For now, let's keep it simple or use what was there
                          ],
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
