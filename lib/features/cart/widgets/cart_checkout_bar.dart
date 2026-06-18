import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/address/providers/address_provider.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/cart/providers/coupon_provider.dart';
import 'package:lets_vhandar/features/order/providers/order_provider.dart';

class CartCheckoutBar extends ConsumerWidget {
  final double totalPrice;

  const CartCheckoutBar({super.key, required this.totalPrice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(orderProvider).isPlacingOrder;
    final appliedCoupon = ref.watch(appliedCouponProvider);
    final double couponDiscount = appliedCoupon?.discountAmount ?? 0;
    final double finalPrice = totalPrice - couponDiscount;
    final isBusiness = ref.watch(isBusinessUserProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          16.w, 8.h, 16.w, 20.h + MediaQuery.of(context).padding.bottom),
      child: InkWell(
        onTap: () {
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
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColor.primary,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rs. ${finalPrice.toInt()}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 18.w,
                      height: 18.h,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  else
                    Text(
                      'Proceed to Pay',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  SizedBox(width: 8.w),
                  if (!isLoading)
                    Icon(Icons.arrow_forward_ios,
                        size: 14.sp, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
