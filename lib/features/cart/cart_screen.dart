import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/address/providers/address_provider.dart';
import 'package:lets_vhandar/features/address/widgets/address_selector_sheet.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/cart/widgets/bill_details_card.dart';
import 'package:lets_vhandar/features/cart/widgets/cancellation_policy_card.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_checkout_bar.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_item_widget.dart';
import 'package:lets_vhandar/features/cart/widgets/delivery_instructions_card.dart';
import 'package:lets_vhandar/features/cart/widgets/delivery_partner_safety_card.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

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
      backgroundColor: const Color(0xFFF8F9FB),
      isScrollable: false,
      appBar: CustomScreenHeader(
        title: 'My Cart',
        trailing: cartItems.isNotEmpty
            ? GestureDetector(
                onTap: () => ref.read(cartProvider.notifier).clearCart(),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 12.h),
                    children: [
                      // ── Delivery Address Banner ──────────────────────
                      _DeliveryAddressBanner(
                        selectedAddress: selectedAddress,
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
                      ),

                      SizedBox(height: 12.h),

                      // ── Cart Items Card ──────────────────────────────
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
                              child: Row(
                                children: [
                                  Text(
                                    '$totalItems ${totalItems == 1 ? 'item' : 'items'} in cart',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: cartItems.length,
                              separatorBuilder: (_, __) => Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Divider(
                                    height: 1, color: Colors.grey.shade100),
                              ),
                              itemBuilder: (context, index) =>
                                  CartItemWidget(item: cartItems[index]),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // ── Coupon Banner ────────────────────────────────
                      _CouponBanner(),

                      SizedBox(height: 12.h),

                      // ── Bill Details ─────────────────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: BillDetailsCard(
                          totalItems: totalItems,
                          totalPrice: totalPrice,
                          totalMrp: totalMrp,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // ── Additional Info Cards ────────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          children: [
                            const DeliveryInstructionsCard(),
                            SizedBox(height: 8.h),
                            const DeliveryPartnerSafetyCard(),
                            SizedBox(height: 8.h),
                            const CancellationPolicyCard(),
                          ],
                        ),
                      ),

                      SizedBox(height: 12.h),
                    ],
                  ),
                ),

                // ── Checkout Bar ─────────────────────────────────────
                CartCheckoutBar(totalPrice: totalPrice),
                SizedBox(height: 8.h)
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(28.w),
            decoration: const BoxDecoration(
              color: Color(0xFFF0FAF5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 56.sp,
              color: AppColor.primary,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.textBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add items to your cart to get started.',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Delivery Address Banner ────────────────────────────────────────────────

class _DeliveryAddressBanner extends StatelessWidget {
  final dynamic selectedAddress;
  final VoidCallback onTap;

  const _DeliveryAddressBanner(
      {required this.selectedAddress, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool hasAddress = selectedAddress != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: hasAddress
                ? AppColor.primary.withOpacity(0.2)
                : Colors.orange.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: hasAddress
                    ? AppColor.primary.withOpacity(0.08)
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: hasAddress ? AppColor.primary : Colors.orange.shade600,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasAddress ? 'Delivering to' : 'No address selected',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    hasAddress
                        ? selectedAddress.description ?? 'Address'
                        : 'Tap to select a delivery address',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: hasAddress
                          ? AppColor.textBlack
                          : Colors.orange.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: hasAddress
                    ? AppColor.primary.withOpacity(0.08)
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                hasAddress ? 'Change' : 'Choose',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: hasAddress ? AppColor.primary : Colors.orange.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Coupon Banner ──────────────────────────────────────────────────────────

class _CouponBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(7.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.local_offer_outlined,
                color: Colors.orange.shade600, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Apply Coupons & Offers',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textBlack,
              ),
            ),
          ),
          Icon(Icons.keyboard_arrow_right,
              color: Colors.grey.shade400, size: 20.sp),
        ],
      ),
    );
  }
}
