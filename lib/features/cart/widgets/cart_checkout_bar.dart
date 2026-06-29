import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/address/providers/address_provider.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/order/providers/order_provider.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/core/utils/app_haptics.dart';
import 'package:lets_vhandar/widgets/animated_counter.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';

class CartCheckoutBar extends ConsumerWidget {
  const CartCheckoutBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(orderProvider).isPlacingOrder;
    // Same total (items + delivery + handling - coupon) shown in the bill
    // breakdown above, so the two never disagree.
    final billSummary = ref.watch(cartBillSummaryProvider);
    final double couponDiscount = billSummary.couponDiscount;
    final double finalPrice = billSummary.grandTotal;
    final double priceBeforeCoupon = finalPrice + couponDiscount;
    final isBusiness = ref.watch(isBusinessUserProvider);

    // Guests can build a cart freely; login is only required to check out.
    final loginState = ref.watch(loginProvider);
    final bool isGuest = loginState.isGuest || !loginState.isLoggedIn;

    void goToPayment() {
      // Require a delivery slot / address before paying.
      if (isBusiness) {
        final slot = ref.read(selectedDeliverySlotProvider);
        if (slot == null) {
          ref.read(cartAddressErrorProvider.notifier).state = true;
          return;
        }
      } else {
        final selectedAddress = ref.read(addressProvider).selected;
        if (selectedAddress == null) {
          ref.read(cartAddressErrorProvider.notifier).state = true;
          return;
        }
      }
      ref.read(cartAddressErrorProvider.notifier).state = false;
      context.push(LVRoute.selectPaymentMethodScreen.route);
    }

    Future<void> onTap() async {
      AppHaptics.light();

      if (isGuest) {
        // Push login and wait for it to resolve. On success the login
        // screen pops back here with `true` so checkout continues without
        // a second tap; on guest/skip or cancel we just stay on the cart.
        final loggedIn = await context.push<bool>(
          LVRoute.loginScreen.route,
          extra: const {'fromCheckout': true},
        );
        if (loggedIn == true && context.mounted) {
          goToPayment();
        }
        return;
      }

      goToPayment();
    }

    final String ctaText = isGuest ? 'Login to Continue' : 'Proceed to Pay';
    final Color mutedColor = context.vColors.onSurfaceMuted;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          16.w, 8.h, 16.w, 16.h + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total amount',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: mutedColor,
                  fontFamily: 'Inter',
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (couponDiscount > 0) ...[
                    Text(
                      'Rs. ${priceBeforeCoupon.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: mutedColor,
                        decoration: TextDecoration.lineThrough,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  AnimatedCounter(
                    value: finalPrice,
                    prefix: 'Rs. ',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColor.primary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: CustomElevatedButton(
              onPressed: isLoading ? null : onTap,
              isLoading: isLoading,
              loaderSize: 20.w,
              text: ctaText,
            ),
          ),
        ],
      ),
    );
  }
}
