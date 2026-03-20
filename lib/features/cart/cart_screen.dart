import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/address/providers/address_provider.dart';
import 'package:lets_vhandar/features/address/widgets/address_selector_sheet.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/cart/widgets/bill_details_card.dart';
import 'package:lets_vhandar/features/cart/widgets/cancellation_policy_card.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_checkout_bar.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_item_widget.dart';
import 'package:lets_vhandar/features/cart/widgets/delivery_instructions_card.dart';
import 'package:lets_vhandar/features/cart/widgets/delivery_partner_safety_card.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalItems = ref.watch(totalCartItemsProvider);
    final totalPrice = ref.watch(totalCartPriceProvider);
    final totalMrp = ref.watch(totalCartMrpProvider);
    final selectedAddress = ref.watch(addressProvider).selected;

    return CustomScaffoldWrapper(
      isScrollable: false,
      appBar: CustomScreenHeader(
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
      body: cartItems.isEmpty
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
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    children: [
                      // Cart Items List
                      Container(
                        color: Colors.white,
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: cartItems.length,
                          separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: Colors.grey.shade200,
                              indent: 16.w,
                              endIndent: 16.w),
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            return CartItemWidget(item: item);
                          },
                        ),
                      ),

                      SizedBox(height: 16.h),
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
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.textBlack87)),
                            const Spacer(),
                            Icon(Icons.keyboard_arrow_right,
                                color: AppColor.textBlack54),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Bill Details
                      BillDetailsCard(
                        totalItems: totalItems,
                        totalPrice: totalPrice,
                        totalMrp: totalMrp,
                      ),
                      SizedBox(height: 16.h),

                      // Expandable Delivery Instructions
                      const DeliveryInstructionsCard(),
                      SizedBox(height: 8.h),

                      // Expandable Partner Safety
                      const DeliveryPartnerSafetyCard(),
                      SizedBox(height: 8.h),

                      // Cancellation Policy
                      const CancellationPolicyCard(),
                      SizedBox(height: 8.h),

                      // Delivery To (tappable with address info)
                      GestureDetector(
                        onTap: () {
                          final userId = ref.read(loginProvider).user?.id;
                          if (userId != null) {
                            showAddressSelectorSheet(context, userId: userId);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Please login to select address')),
                            );
                          }
                        },
                        child: _buildInfoRow(
                          Icons.location_on_outlined,
                          'Delivery To',
                          selectedAddress?.description,
                          actionText: selectedAddress == null ? 'Choose' : null,
                        ),
                      ),

                      SizedBox(height: 32.h), // Some bottom padding
                    ],
                  ),
                ),
                // Bottom Fixed Checkout Bar
                CartCheckoutBar(totalPrice: totalPrice),
              ],
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String? subtitle,
      {String? actionText}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColor.primary, size: 28.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textBlack87)),
                if (subtitle != null) ...[
                  SizedBox(height: 2.h),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12.sp, color: AppColor.textMuted)),
                ]
              ],
            ),
          ),
          if (actionText != null) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(actionText,
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primary)),
            )
          ] else ...[
            Icon(Icons.keyboard_arrow_right, color: Colors.grey.shade400),
          ]
        ],
      ),
    );
  }
}
