import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:lets_vhandar/features/home/providers/time_slot_provider.dart';
import 'package:lets_vhandar/features/order/presentation/order_success_screen.dart';
import 'package:lets_vhandar/features/order/providers/order_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
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
        child: CachedNetworkImage(
          imageUrl: fullUrl,
          fit: BoxFit.cover,
          errorWidget: (context, _, __) => Icon(Icons.broken_image,
              color: Colors.grey.shade400, size: 24.sp),
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
  void initState() {
    super.initState();
    // Auto-select COD since it is the only available payment method
    _selectedMethod = 'cod';
  }

  String _svgForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'home':
        return 'assets/icons/address_home.svg';
      case 'office':
        return 'assets/icons/address_office.svg';
      default:
        return 'assets/icons/address_other.svg';
    }
  }

  String _labelForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'home':
        return 'Home';
      case 'office':
        return 'Office';
      default:
        if (type != null && type.isNotEmpty) {
          return type[0].toUpperCase() + type.substring(1);
        }
        return 'Others';
    }
  }

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
    final isBusiness = ref.watch(isBusinessUserProvider);
    final selectedSlotId = ref.watch(selectedDeliverySlotProvider);
    final slots = ref.watch(timeSlotProvider).valueOrNull ?? [];
    final selectedSlotObj =
        slots.where((s) => s.id == selectedSlotId).firstOrNull;
    final selectedSlotLabel = selectedSlotObj != null
        ? '${selectedSlotObj.slotName}  ${selectedSlotObj.displayTime}'.trim()
        : selectedSlotId;

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
                  SizedBox(height: 70.h),
                  Icon(Icons.shopping_bag_outlined,
                      size: 64.sp, color: vc.onSurfaceMuted),
                  SizedBox(height: 16.h),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: vc.onSurfaceMuted,
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
                    // ─── Delivery Info Section ─────────────────────────────────────
                    if (isBusiness && selectedSlotId != null) ...[
                      const _DeliveryCardHeader(
                        label: 'Delivery Time Slot',
                        icon: Icons.schedule_rounded,
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: vc.surface,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                              color: AppColor.primary.withValues(alpha: 0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 14.h),
                              decoration: BoxDecoration(
                                color: AppColor.primary.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(14.r)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: AppColor.primary,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Icon(Icons.schedule_rounded,
                                        color: Colors.white, size: 18.sp),
                                  ),
                                  SizedBox(width: 12.w),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Scheduled Delivery',
                                          style: TextStyle(
                                              fontSize: 11.sp,
                                              color: vc.onSurfaceMuted,
                                              fontWeight: FontWeight.w500)),
                                      SizedBox(height: 2.h),
                                      Text(selectedSlotLabel ?? '',
                                          style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                              color: AppColor.primary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ] else if (!isBusiness && selectedAddress != null) ...[
                      const _DeliveryCardHeader(
                        label: 'Delivery Address',
                        icon: Icons.local_shipping_outlined,
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: vc.surface,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: vc.divider),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(14.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Top: icon + type + name + Change ──────
                              Row(
                                children: [
                                  Container(
                                    width: 46.w,
                                    height: 46.w,
                                    padding: EdgeInsets.all(9.w),
                                    decoration: BoxDecoration(
                                      color: AppColor.secondary
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: SvgPicture.asset(
                                      _svgForType(selectedAddress.addressType),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _labelForType(
                                              selectedAddress.addressType),
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w700,
                                            color: vc.onSurface,
                                          ),
                                        ),
                                        if (selectedAddress.name != null &&
                                            selectedAddress.name!.isNotEmpty)
                                          Text(
                                            selectedAddress.name!,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: vc.onSurfaceMuted,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Divider(height: 1, color: vc.divider),
                              SizedBox(height: 12.h),
                              // ── Address row ───────────────────────────
                              _AddressRow(
                                icon: Icons.location_on_outlined,
                                text: [
                                  if (selectedAddress.floor != null &&
                                      selectedAddress.floor!.isNotEmpty)
                                    'Floor ${selectedAddress.floor}',
                                  if (selectedAddress.houseNumber != null &&
                                      selectedAddress.houseNumber!.isNotEmpty)
                                    'House ${selectedAddress.houseNumber}',
                                  if (selectedAddress.landMark != null &&
                                      selectedAddress.landMark!.isNotEmpty)
                                    selectedAddress.landMark,
                                  selectedAddress.description,
                                ]
                                    .where((e) => e != null && e.isNotEmpty)
                                    .join(', '),
                              ),
                              // ── Phone row ─────────────────────────────
                              if (selectedAddress.phoneNumber != null &&
                                  selectedAddress.phoneNumber!.isNotEmpty) ...[
                                SizedBox(height: 8.h),
                                _AddressRow(
                                  icon: Icons.phone_outlined,
                                  text: selectedAddress.phoneNumber!,
                                ),
                              ],
                            ],
                          ),
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
                          color: vc.divider,
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
                                      'Rs. ${item.priceFor(isBusiness).toInt()}',
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
                              SvgPicture.asset(
                                'assets/images/cash on delivery.svg',
                                width: 56.w,
                                height: 56.w,
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
                                size: 14.sp, color: Colors.orange.shade600),
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
                      child: CustomElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_selectedMethod == null) {
                                  setState(() => _showPaymentHint = true);
                                  return;
                                }
                                _placeOrder(context);
                              },
                        isLoading: isLoading,
                        loaderSize: 20.w,
                        backgroundColor: _selectedMethod == null
                            ? Colors.grey.shade300
                            : AppColor.primary,
                        text: 'Place Order',
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
    final loginState = ref.read(loginProvider);
    final isBusiness = loginState.user?.isBusiness ?? false;
    final selectedSlot = ref.read(selectedDeliverySlotProvider);
    final selectedAddress = ref.read(addressProvider).selected;

    if (isBusiness) {
      if (selectedSlot == null) {
        CustomSnackbar.error(context,
            message: 'Please select a delivery time slot');
        return;
      }
    } else {
      if (selectedAddress == null) {
        CustomSnackbar.error(context,
            message: 'Please select a delivery address first');
        return;
      }
    }

    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) return;

    final userId = loginState.user?.id;
    if (userId == null) {
      CustomSnackbar.error(context, message: 'Please login to place order');
      return;
    }

    final products = cartItems.map((item) {
      final productMap = item.product.toMap();
      final imagesList = item.product.images?.map((e) => e.path).toList() ?? [];
      final featuredImagesList =
          item.product.featuredImages?.map((e) => e.path).toList() ?? [];
      productMap['images'] = imagesList;
      productMap['featuredImages'] = featuredImagesList;
      productMap.remove('hasVariant');
      final linePrice = item.priceFor(isBusiness);
      return {
        ...productMap,
        'count': item.quantity,
        'totalPrice': linePrice,
        'netPrice': linePrice,
      };
    }).toList();

    // Business orders use business location from profile; personal orders use selected address
    final bd = loginState.user?.businessDetail;
    final location = isBusiness
        ? {
            'lat': (bd?['lat'] ?? bd?['latitude']) as num?,
            'long': (bd?['long'] ?? bd?['longitude']) as num?,
            'userId': userId,
            'name': bd?['businessName'] ?? '',
            'description':
                (bd?['locationAddress'] ?? bd?['addressName']) as String? ?? '',
            'addressType': 'others',
          }
        : {
            'lat': selectedAddress!.lat,
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
          cartId: userId,
          location: location,
          appliedCouponCode: appliedCoupon?.code ?? '',
          couponDiscount: couponDiscount,
          deliveryTimeSlot: isBusiness ? selectedSlot : null,
        );

    if (!context.mounted) return;

    if (success) {
      ref.read(cartProvider.notifier).clearCart();
      ref.read(appliedCouponProvider.notifier).removeCoupon();

      // Switch the underlying screen straight to the dashboard's orders tab
      // FIRST, then cover it with the celebration as an overlay. This way the
      // emptied cart / payment screens are never revealed — dismissing the
      // celebration drops you directly onto the dashboard.
      final overlay = Navigator.of(context, rootNavigator: true).overlay;
      ref.read(visitedTabsProvider.notifier).update((s) => {...s, 2});
      ref.read(dashboardIndexProvider.notifier).state = 2;
      context.go(LVRoute.dashboardScreen.route);

      if (overlay != null) {
        late OverlayEntry entry;
        entry = OverlayEntry(
          // Branded celebration: checkmark + confetti + status stepper.
          builder: (_) => OrderSuccessScreen(
            onContinue: () => entry.remove(),
          ),
        );
        overlay.insert(entry);
      }
    } else {
      final error = ref.read(orderProvider).error;
      CustomSnackbar.error(context, message: error ?? 'Failed to place order');
    }
  }
}

class _DeliveryCardHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const _DeliveryCardHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: AppColor.primary,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Icon(icon, size: 16.sp, color: AppColor.primary),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: context.vColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _AddressRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _AddressRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14.sp, color: AppColor.primary.withValues(alpha: 0.7)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color: context.vColors.onSurfaceMuted,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
