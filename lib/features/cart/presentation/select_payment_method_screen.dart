import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/address/providers/address_provider.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/cart/providers/coupon_provider.dart';
import 'package:lets_vhandar/features/cart/widgets/bill_details_card.dart';
import 'package:lets_vhandar/features/dashboard/providers/dashboard_provider.dart';
import 'package:lets_vhandar/features/home/providers/general_settings_provider.dart';
import 'package:lets_vhandar/features/order/providers/order_provider.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';

class SelectPaymentMethodScreen extends ConsumerStatefulWidget {
  const SelectPaymentMethodScreen({super.key});

  @override
  ConsumerState<SelectPaymentMethodScreen> createState() =>
      _SelectPaymentMethodScreenState();
}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: 52.w,
        height: 52.w,
        decoration: BoxDecoration(
          color: context.vColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(Icons.image, color: Colors.grey.shade400, size: 24.sp),
      );
    }

    final String fullUrl = imageUrl!.startsWith('http')
        ? imageUrl!
        : imageUrl!.startsWith('/')
            ? 'https://vhandar.sgp1.digitaloceanspaces.com/$imageUrl'
            : 'https://vhandar.sgp1.digitaloceanspaces.com//$imageUrl';

    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        color: context.vColors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: context.vColors.divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.network(
          fullUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.broken_image,
                color: Colors.grey.shade400, size: 24.sp);
          },
        ),
      ),
    );
  }
}

class _SelectPaymentMethodScreenState
    extends ConsumerState<SelectPaymentMethodScreen> {
  String? _selectedMethod;
  bool _showPaymentHint = false;

  @override
  Widget build(BuildContext context) {
    final selectedAddress = ref.watch(addressProvider).selected;
    final cartItems = ref.watch(cartProvider);
    final totalItems = ref.watch(totalCartItemsProvider);
    final totalPrice = ref.watch(totalCartPriceProvider);
    final totalMrp = ref.watch(totalCartMrpProvider);
    final orderState = ref.watch(orderProvider);
    final isLoading = orderState.isPlacingOrder;
    final vc = context.vColors;

    return CustomScaffoldWrapper(
      backgroundColor: context.vColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        scrolledUnderElevation: 2,
        automaticallyImplyLeading: false,
        titleSpacing: 16.w,
        title: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              child: Container(
                width: 44.w,
                height: 44.h,
                alignment: Alignment.centerLeft,
                child: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Checkout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 64.sp, color: Colors.grey.shade400),
                  SizedBox(height: 16.h),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Delivery To Home Section ──────────────────────────────────
                    if (selectedAddress != null) ...[
                      Text(
                        'Delivery To Home',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: vc.onSurface,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: vc.surface,
                          borderRadius: BorderRadius.circular(12.r),
                          ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    color: AppColor.primary, size: 20.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  selectedAddress.name ?? '-',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: vc.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              [
                                if (selectedAddress.floor != null)
                                  'Floor ${selectedAddress.floor}',
                                if (selectedAddress.houseNumber != null)
                                  'House ${selectedAddress.houseNumber}',
                                if (selectedAddress.landMark != null)
                                  selectedAddress.landMark,
                                selectedAddress.description,
                              ].join(', '),
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColor.textMuted,
                                height: 1.4,
                              ),
                            ),
                            if (selectedAddress.phoneNumber != null &&
                                selectedAddress.phoneNumber!.isNotEmpty) ...[
                              SizedBox(height: 8.h),
                              Text(
                                'Phone: ${selectedAddress.phoneNumber}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.textBlack,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],

                    // ─── My Cart (Items Summary) ───────────────────────────────────
                    Text(
                      'My Cart (${cartItems.length} Items)',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: vc.onSurface,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      decoration: BoxDecoration(
                        color: vc.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.all(16.w),
                        itemCount: cartItems.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.grey.shade100,
                          height: 24.h,
                          thickness: 1,
                        ),
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          final product = item.product;
                          final String? firstImg =
                              product.images?.isNotEmpty == true
                                  ? product.images!.first.url
                                  : null;

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ProductImage(imageUrl: firstImg),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name ?? 'Product',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: vc.onSurface,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '${product.unitValue?.toInt() ?? 1} ${product.unit ?? ''} • Qty: ${item.quantity}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColor.textMuted,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Rs. ${item.totalPrice.toInt()}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // ─── Bill Details ──────────────────────────────────────────────
                    BillDetailsCard(
                      totalItems: totalItems,
                      totalPrice: totalPrice,
                      totalMrp: totalMrp,
                    ),
                    SizedBox(height: 20.h),

                    // ─── Select Payment Method ─────────────────────────────────────
                    Text(
                      'Select Payment Method',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: vc.onSurface,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      decoration: BoxDecoration(
                        color: vc.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        ),
                      child: InkWell(
                        onTap: () => setState(() {
                          _selectedMethod =
                              _selectedMethod == 'cod' ? null : 'cod';
                          _showPaymentHint = false;
                        }),
                        borderRadius: BorderRadius.circular(12.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 16.h),
                          child: Row(
                            children: [
                              Container(
                                width: 20.w,
                                height: 20.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selectedMethod == 'cod'
                                        ? AppColor.primary
                                        : Colors.grey.shade400,
                                    width: 2.w,
                                  ),
                                ),
                                child: _selectedMethod == 'cod'
                                    ? Center(
                                        child: Container(
                                          width: 10.w,
                                          height: 10.w,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColor.primary,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Cash On Delivery',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: vc.onSurface,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'Pay with cash/card/QR code upon delivery',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColor.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
              decoration: BoxDecoration(
                color: vc.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_showPaymentHint && _selectedMethod == null)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline,
                                size: 14.sp,
                                color: Colors.orange.shade600),
                            SizedBox(width: 6.w),
                            Text(
                              'Please select a payment method to continue',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_selectedMethod == null) {
                                  setState(() => _showPaymentHint = true);
                                  return;
                                }
                                _placeOrder(context);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedMethod == null
                              ? Colors.grey.shade300
                              : AppColor.primary,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Place Order',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedMethod == null
                                      ? Colors.grey.shade500
                                      : Colors.white,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    final selectedAddress = ref.read(addressProvider).selected;
    if (selectedAddress == null) {
      CustomSnackbar.error(context,
          message: 'Please select a delivery address first');
      return;
    }

    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) return;

    final loginState = ref.read(loginProvider);
    final userId = loginState.user?.id;

    if (userId == null) {
      CustomSnackbar.error(context, message: 'Please login to place order');
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

    final totalPrice = ref.read(totalCartPriceProvider);
    final settingsAsync = ref.read(generalSettingsProvider);
    final isBusiness = loginState.user?.isBusiness ?? false;
    final appliedCoupon = ref.read(appliedCouponProvider);
    final double couponDiscount = appliedCoupon?.discountAmount ?? 0;

    double standardDeliveryCharge = 0;
    double businessDeliveryCharge = 0;
    double deliveryThreshold = 0;
    double handlingCharge = 0;

    settingsAsync.whenData((settings) {
      standardDeliveryCharge = settings?.deliveryCharge?.toDouble() ?? 0;
      businessDeliveryCharge =
          settings?.businessDeliveryCharge?.toDouble() ?? 0;
      deliveryThreshold = settings?.deliveryThreshold?.toDouble() ?? 0;
      handlingCharge = settings?.handlingCharge?.toDouble() ?? 0;
    });

    final double deliveryCharge =
        isBusiness ? businessDeliveryCharge : standardDeliveryCharge;
    final bool isFreeDelivery = totalPrice >= deliveryThreshold;
    final double finalDeliveryCharge = isFreeDelivery ? 0 : deliveryCharge;
    final double grandTotal =
        totalPrice + finalDeliveryCharge + handlingCharge - couponDiscount;

    final vatAmount = double.parse((totalPrice * 0.13).toStringAsFixed(2));

    final success = await ref.read(orderProvider.notifier).placeOrder(
          userId: userId,
          products: products,
          totalAmount: totalPrice,
          totalDiscount: 0,
          totalVatAmount: vatAmount,
          totalPayableAmount: grandTotal,
          handlingCharge: handlingCharge,
          deliveryCharge: finalDeliveryCharge,
          cartId:
              userId, // Using userId as cartId for now since it's a valid ObjectId
          location: location,
          appliedCouponCode: appliedCoupon?.code ?? '',
          couponDiscount: couponDiscount,
        );

    if (!context.mounted) return;

    if (success) {
      // Clear cart and navigate to Order tab (index 2)
      ref.read(cartProvider.notifier).clearCart();
      ref.read(appliedCouponProvider.notifier).removeCoupon();
      ref.read(dashboardIndexProvider.notifier).state = 2;

      // Go back to the dashboard tab list
      context.go(LVRoute.dashboardScreen.route);

      CustomSnackbar.success(context, message: 'Order placed successfully! 🎉');
    } else {
      final error = ref.read(orderProvider).error;
      CustomSnackbar.error(context, message: error ?? 'Failed to place order');
    }
  }
}
