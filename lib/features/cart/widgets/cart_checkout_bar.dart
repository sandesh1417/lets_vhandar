import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/address/providers/address_provider.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/dashboard/providers/dashboard_provider.dart';
import 'package:lets_vhandar/features/order/providers/order_provider.dart';

class CartCheckoutBar extends ConsumerWidget {
  final double totalPrice;

  const CartCheckoutBar({super.key, required this.totalPrice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(orderProvider).isPlacingOrder;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Container(
        child: InkWell(
          onTap: isLoading ? null : () => _placeOrder(context, ref),
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
                      'Rs. ${totalPrice.toInt()}',
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
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context, WidgetRef ref) async {
    final selectedAddress = ref.read(addressProvider).selected;
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address first')),
      );
      return;
    }

    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) return;

    final loginState = ref.read(loginProvider);
    final userId = loginState.user?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to place order')),
      );
      return;
    }

    final products = cartItems.map((item) {
      final productMap = item.product.toMap();

      // The Order API expects images as a list of Strings (paths), not objects
      final imagesList = item.product.images?.map((e) => e.path).toList() ?? [];
      final featuredImagesList =
          item.product.featuredImages?.map((e) => e.path).toList() ?? [];

      // Clean up the map: replace image objects with paths, remove unrecognized keys
      productMap['images'] = imagesList;
      productMap['featuredImages'] = featuredImagesList;
      productMap.remove(
          'hasVariant'); // Per server error: "Unrecognized key(s) in object: 'hasVariant'"

      return {
        ...productMap,
        'count': item.quantity,
        'totalPrice': item.totalPrice,
        'netPrice': item.totalPrice,
      };
    }).toList();

    final location = {
      'lat': selectedAddress.lat,
      'long': selectedAddress.long,
      'userId': selectedAddress.userId ?? userId,
      'name': selectedAddress.name,
      'description': selectedAddress.description,
      'addressType': selectedAddress.addressType,
      'landMark': selectedAddress.landMark,
      'locality': selectedAddress.locality,
      'phoneNumber': selectedAddress.phoneNumber,
      'houseNumber': selectedAddress.houseNumber,
      'floor': selectedAddress.floor,
    };

    final vatAmount = double.parse((totalPrice * 0.13).toStringAsFixed(2));
    final payableAmount = double.parse((totalPrice + 100).toStringAsFixed(2));

    final success = await ref.read(orderProvider.notifier).placeOrder(
          userId: userId,
          products: products,
          totalAmount: totalPrice,
          totalDiscount: 0,
          totalVatAmount: vatAmount,
          totalPayableAmount: payableAmount,
          handlingCharge: 0,
          deliveryCharge: 100,
          cartId:
              userId, // Using userId as cartId for now since it's a valid ObjectId
          location: location,
        );

    if (!context.mounted) return;

    if (success) {
      // Clear cart and navigate to Order tab (index 2)
      ref.read(cartProvider.notifier).clearCart();
      ref.read(dashboardIndexProvider.notifier).state = 2;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Order placed successfully! 🎉'),
          backgroundColor: AppColor.primary,
        ),
      );
    } else {
      final error = ref.read(orderProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to place order'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
