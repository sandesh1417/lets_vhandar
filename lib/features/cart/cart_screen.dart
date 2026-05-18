import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/api/dio_client.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/address/providers/address_provider.dart';
import 'package:lets_vhandar/features/address/widgets/address_selector_sheet.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/cart/providers/coupon_provider.dart';
import 'package:lets_vhandar/features/cart/widgets/bill_details_card.dart';
import 'package:lets_vhandar/features/cart/widgets/cancellation_policy_card.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_checkout_bar.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_item_widget.dart';
import 'package:lets_vhandar/features/cart/widgets/delivery_instructions_card.dart';
import 'package:lets_vhandar/features/cart/widgets/delivery_partner_safety_card.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';

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
        showBackButton: false,
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
                      const _CouponBanner(),

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

class _CouponBanner extends ConsumerStatefulWidget {
  const _CouponBanner();

  @override
  ConsumerState<_CouponBanner> createState() => _CouponBannerState();
}

class _CouponBannerState extends ConsumerState<_CouponBanner> {
  bool _isValidating = false;

  void _showCouponSheet(BuildContext context) {
    final textController = TextEditingController();
    String? sheetError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
                left: 20.w,
                right: 20.w,
                top: 20.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Apply Coupon Code',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.textBlack,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          decoration: InputDecoration(
                            hintText: 'Enter coupon code (e.g. SUBARNABHD)',
                            hintStyle: TextStyle(
                                fontSize: 13.sp, color: Colors.grey.shade400),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: BorderSide(color: AppColor.primary),
                            ),
                          ),
                          textCapitalization: TextCapitalization.characters,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      ElevatedButton(
                        onPressed: _isValidating
                            ? null
                            : () async {
                                final code = textController.text.trim();
                                if (code.isEmpty) return;

                                setSheetState(() {
                                  _isValidating = true;
                                  sheetError = null;
                                });

                                final errorMsg =
                                    await _applyCouponCode(context, code);

                                setSheetState(() {
                                  _isValidating = false;
                                  sheetError = errorMsg;
                                });

                                if (errorMsg == null) {
                                  Navigator.pop(sheetContext);
                                  CustomSnackbar.success(context,
                                      message:
                                          'Coupon "$code" applied successfully! Saved Rs. ${ref.read(appliedCouponProvider)?.discountAmount.toInt() ?? 100} 🎉');
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 12.h),
                          elevation: 0,
                        ),
                        child: _isValidating
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Apply',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ],
                  ),
                  if (sheetError != null) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red, size: 16.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              sheetError!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.red.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  // Text(
                  //   'Available Offers',
                  //   style: TextStyle(
                  //     fontSize: 14.sp,
                  //     fontWeight: FontWeight.bold,
                  //     color: AppColor.textBlack,
                  //   ),
                  // ),
                  // SizedBox(height: 8.h),
                  // _buildOfferTile(
                  //   code: 'SUBARNABHD',
                  //   title: 'Special Coupon',
                  //   desc: 'Save Rs. 100 flat on all orders.',
                  //   onTap: () {
                  //     textController.text = 'SUBARNABHD';
                  //   },
                  // ),
                  // _buildOfferTile(
                  //   code: '123',
                  //   title: 'Invalid Coupon Tester',
                  //   desc: 'Test backend coupon validation errors.',
                  //   onTap: () {
                  //     textController.text = '123';
                  //   },
                  // ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOfferTile({
    required String code,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        code,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textBlack,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: Text(
              'USE CODE',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _applyCouponCode(BuildContext context, String code) async {
    try {
      final dio = locator<DioClient>().dio;
      final response = await dio.get('coupons/$code');

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['status'] == 'ERROR') {
          return data['message'] ??
              'The coupon is invalid and cannot be applied to your purchase';
        }

        // Successfully validated!
        double discount = 100.0; // Fallback default discount
        if (data['couponDiscount'] != null) {
          discount =
              double.tryParse(data['couponDiscount'].toString()) ?? 100.0;
        } else if (data['data'] != null &&
            data['data']['couponDiscount'] != null) {
          discount =
              double.tryParse(data['data']['couponDiscount'].toString()) ??
                  100.0;
        } else if (data['discount'] != null) {
          discount = double.tryParse(data['discount'].toString()) ?? 100.0;
        } else if (data['data'] != null && data['data']['discount'] != null) {
          discount =
              double.tryParse(data['data']['discount'].toString()) ?? 100.0;
        }

        final desc = data['description'] ??
            data['message'] ??
            'Special Coupon Applied Successfully!';

        ref
            .read(appliedCouponProvider.notifier)
            .applyCoupon(code, discount, desc);

        return null; // Return null to indicate success
      }
      return 'Failed to validate coupon';
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        return data['message'];
      } else {
        return 'The coupon is invalid and cannot be applied to your purchase';
      }
    } catch (e) {
      return 'Failed to apply coupon';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appliedCoupon = ref.watch(appliedCouponProvider);

    if (appliedCoupon != null) {
      return Stack(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEBFDF3), Color(0xFFF5FCF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColor.primary.withOpacity(0.25),
                width: 1.2.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
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
                    color: AppColor.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.stars, color: AppColor.primary, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: AppColor.primary,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              appliedCoupon.code ?? '-',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Applied! 🎉',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColor.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Saved Rs. ${appliedCoupon.discountAmount.toInt() ?? '-'} on this order',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(appliedCouponProvider.notifier).removeCoupon();
                    CustomSnackbar.info(context, message: 'Coupon removed');
                  },
                  child: Text(
                    'REMOVE',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Ticket Cut Outs
          Positioned(
            left: 10.w,
            top: 26.h,
            child: Container(
              width: 12.w,
              height: 12.h,
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FB), // Matches scaffold background
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 10.w,
            top: 26.h,
            child: Container(
              width: 12.w,
              height: 12.h,
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FB), // Matches scaffold background
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: InkWell(
        onTap: () => _showCouponSheet(context),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
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
        ),
      ),
    );
  }
}
