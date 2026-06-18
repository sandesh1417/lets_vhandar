import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/api/dio_client.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/address/providers/address_provider.dart';
import 'package:lets_vhandar/features/address/widgets/address_selector_sheet.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/cart/widgets/delivery_slot_selector.dart';
import 'package:lets_vhandar/widgets/app_refresh_indicator.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/dashboard/providers/dashboard_provider.dart';
import 'package:lets_vhandar/features/cart/providers/coupon_provider.dart';
import 'package:lets_vhandar/features/cart/widgets/bill_details_card.dart';
import 'package:lets_vhandar/features/cart/widgets/cancellation_policy_card.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_checkout_bar.dart';
import 'package:lets_vhandar/features/cart/widgets/cart_item_widget.dart';
import 'package:lets_vhandar/features/cart/widgets/delivery_instructions_card.dart';
import 'package:lets_vhandar/features/cart/widgets/delivery_partner_safety_card.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';
import 'package:lets_vhandar/widgets/app_bottom_sheet.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalItems = ref.watch(totalCartItemsProvider);
    final totalPrice = ref.watch(totalCartPriceProvider);
    final totalMrp = ref.watch(totalCartMrpProvider);

    return CustomScaffoldWrapper(
      isScrollable: false,
      bottomSafeArea: false,
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
                context.pop();
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
              'My Cart',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        actions: cartItems.isNotEmpty
            ? [
                Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref.read(cartProvider.notifier).clearCart();
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart(context, ref)
          : Column(
              children: [
                Expanded(
                  child: AppRefreshIndicator(
                    onRefresh: () async => ref.invalidate(addressProvider),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
                      children: [
                        // ── Cart Items Card ──────────────────────────────
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: context.vColors.surface,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                                child: Row(
                                  children: [
                                    Text(
                                      '$totalItems ${totalItems == 1 ? 'item' : 'items'} in cart',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
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
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.w),
                                  child: Divider(
                                      height: 1,
                                      color: context.vColors.divider),
                                ),
                                itemBuilder: (context, index) =>
                                    CartItemWidget(item: cartItems[index]),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 10.h),

                        // ── Coupon Banner ────────────────────────────────
                        const _CouponBanner(),

                        SizedBox(height: 10.h),

                        // ── Bill Details ─────────────────────────────────
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: BillDetailsCard(
                            totalItems: totalItems,
                            totalPrice: totalPrice,
                            totalMrp: totalMrp,
                          ),
                        ),

                        SizedBox(height: 10.h),

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
                      ],
                    ),
                  ),
                ),

                // ── Sticky bottom: Address + Checkout ────────────────
                const _CartStickyBottom()
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/cart-empty.svg',
              width: 100.w,
              height: 100.w,
            ),
            SizedBox(height: 24.h),
            Text(
              "You don't have any items in\nyour cart",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: context.vColors.onSurface,
                fontFamily: 'Inter',
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Your favorite items are just a click away',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColor.hintText,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 20.h),
            CustomElevatedButton(
              onPressed: () {
                context.pop();
                ref.read(dashboardIndexProvider.notifier).state = 0;
              },
              backgroundColor: AppColor.secondary,
              text: 'Start Shopping',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cart Sticky Bottom ────────────────────────────────────────────────────

class _CartStickyBottom extends ConsumerWidget {
  const _CartStickyBottom();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusiness = ref.watch(isBusinessUserProvider);
    final selectedAddress =
        ref.watch(addressProvider.select((s) => s.selected));
    final addressError = ref.watch(cartAddressErrorProvider);
    final totalPrice = ref.watch(totalCartPriceProvider);

    return Container(
      padding: EdgeInsets.only(top: 12.r),
      decoration: BoxDecoration(
        color: context.vColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 4.h),
          if (isBusiness) ...[
            DeliverySlotSelector(isError: addressError),
            SizedBox(height: 8.h),
          ] else ...[
            if (addressError && selectedAddress == null)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade600, size: 15.sp),
                    SizedBox(width: 6.w),
                    Text(
                      'Please select a delivery address to continue',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            _DeliveryAddressBanner(
              selectedAddress: selectedAddress,
              isError: addressError && selectedAddress == null,
              onTap: () {
                ref.read(cartAddressErrorProvider.notifier).state = false;
                final userId = ref.read(loginProvider).user?.id;
                if (userId != null) {
                  showAddressSelectorSheet(context, userId: userId);
                } else {
                  CustomSnackbar.info(context,
                      message: 'Please login to select address');
                }
              },
            ),
          ],
          CartCheckoutBar(totalPrice: totalPrice),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

// ── Delivery Address Banner ────────────────────────────────────────────────

class _DeliveryAddressBanner extends StatelessWidget {
  final dynamic selectedAddress;
  final VoidCallback onTap;
  final bool isError;

  const _DeliveryAddressBanner({
    required this.selectedAddress,
    required this.onTap,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedAddress != null) {
      return _HasAddressBanner(selectedAddress: selectedAddress, onTap: onTap);
    }
    return _NoAddressBanner(onTap: onTap, isError: isError);
  }
}

class _NoAddressBanner extends StatelessWidget {
  final VoidCallback onTap;
  final bool isError;
  const _NoAddressBanner({required this.onTap, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: isError
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              )
            : null,
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: isError ? Colors.red : AppColor.primary,
            radius: 14.r,
            dashWidth: 6,
            dashGap: 4,
            strokeWidth: isError ? 2.0 : 1.5,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: isError ? Colors.red.withValues(alpha: 0.04) : vc.surface,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(9.w),
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Delivery Address',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: vc.onSurface,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Tap to select where to deliver',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: vc.onSurfaceMuted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColor.primary,
                  size: 22.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    this.dashWidth = 6,
    this.dashGap = 4,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final metrics = path.computeMetrics().first;
    double distance = 0;
    while (distance < metrics.length) {
      canvas.drawPath(
        metrics.extractPath(distance, distance + dashWidth),
        paint,
      );
      distance += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.dashWidth != dashWidth ||
      old.dashGap != dashGap ||
      old.strokeWidth != strokeWidth;
}

class _HasAddressBanner extends StatelessWidget {
  final dynamic selectedAddress;
  final VoidCallback onTap;
  const _HasAddressBanner({required this.selectedAddress, required this.onTap});

  String _svgForAddressType(String? type) {
    switch (type?.toLowerCase()) {
      case 'home':
        return 'assets/icons/address_home.svg';
      case 'office':
        return 'assets/icons/address_office.svg';
      default:
        return 'assets/icons/address_other.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColor.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: SvgPicture.asset(
              _svgForAddressType(selectedAddress.addressType),
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivering to',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: vc.onSurfaceMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  selectedAddress.name ??
                      selectedAddress.addressType ??
                      'Address',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: vc.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                Text(
                  selectedAddress.description ?? '',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: vc.onSurfaceMuted,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: vc.surface,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColor.primary,
                  width: 1.5,
                ),
              ),
              child: Text(
                'Change',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.primary,
                ),
              ),
            ),
          ),
        ],
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

    showAppSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final vc = context.vColors;
            return Container(
              decoration: BoxDecoration(
                color: vc.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Padding(
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
                            color: vc.onSurface,
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
                                  fontSize: 13.sp, color: vc.onSurfaceMuted),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 12.h),
                              filled: true,
                              fillColor: vc.surfaceVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: BorderSide(color: vc.inputBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: BorderSide(color: vc.inputBorder),
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
                        CustomElevatedButton(
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
                                    // ignore: use_build_context_synchronously
                                    Navigator.pop(sheetContext);
                                    if (!context.mounted) return;
                                    CustomSnackbar.success(context,
                                        message:
                                            'Coupon "$code" applied successfully! Saved Rs. ${ref.read(appliedCouponProvider)?.discountAmount.toInt() ?? 100} 🎉');
                                  }
                                },
                          isLoading: _isValidating,
                          loaderSize: 18.w,
                          backgroundColor: AppColor.primary,
                          text: 'Apply',
                        ),
                      ],
                    ),
                    if (sheetError != null) ...[
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: context.isDark
                              ? const Color(0xFF4A0000).withValues(alpha: 0.5)
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: context.isDark
                                ? const Color(0xFF8B0000).withValues(alpha: 0.6)
                                : Colors.red.shade100,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red.shade300, size: 16.sp),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                sheetError!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: context.isDark
                                      ? Colors.red.shade300
                                      : Colors.red.shade800,
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
              ),
            );
          },
        );
      },
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
            margin: EdgeInsets.symmetric(horizontal: 0.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: context.isDark
                    ? [const Color(0xFF0D2E1E), const Color(0xFF112818)]
                    : [const Color(0xFFEBFDF3), const Color(0xFFF5FCF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColor.primary.withValues(alpha: 0.25),
                width: 1.2.w,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.1),
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
                              appliedCoupon.code,
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
                        'Saved Rs. ${appliedCoupon.discountAmount.toInt()} on this order',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: context.vColors.onSurfaceMuted,
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
              decoration: BoxDecoration(
                color: context.vColors.scaffoldBg,
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
              decoration: BoxDecoration(
                color: context.vColors.scaffoldBg,
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
            color: context.vColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: context.vColors.divider),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/vhandar_discount.svg',
                width: 28.w,
                height: 28.w,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Apply Coupons & Offers',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: context.vColors.onSurface,
                  ),
                ),
              ),
              Icon(Icons.keyboard_arrow_right,
                  color: context.vColors.onSurfaceMuted, size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }
}
