import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/home/providers/general_settings_provider.dart';
import 'package:lets_vhandar/features/cart/providers/coupon_provider.dart';

class BillDetailsCard extends ConsumerWidget {
  final int totalItems;
  final double totalPrice;
  final double totalMrp;

  const BillDetailsCard({
    super.key,
    required this.totalItems,
    required this.totalPrice,
    required this.totalMrp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(generalSettingsProvider);
    final userState = ref.watch(loginProvider);
    final isBusiness = userState.user?.isBusiness ?? false;
    final appliedCoupon = ref.watch(appliedCouponProvider);
    final double couponDiscount = appliedCoupon?.discountAmount ?? 0;

    final double savings = totalMrp - totalPrice;
    final bool hasSavings = savings > 0;

    return settingsAsync.when(
      data: (settings) {
        final double standardDeliveryCharge =
            settings?.deliveryCharge?.toDouble() ?? 0;
        final double businessDeliveryCharge =
            settings?.businessDeliveryCharge?.toDouble() ?? 0;
        final double deliveryCharge =
            isBusiness ? businessDeliveryCharge : standardDeliveryCharge;

        final double deliveryThreshold =
            settings?.deliveryThreshold?.toDouble() ?? 0;
        final double handlingCharge = settings?.handlingCharge?.toDouble() ?? 0;

        final bool isFreeDelivery = totalPrice >= deliveryThreshold;
        final double finalDeliveryCharge = isFreeDelivery ? 0 : deliveryCharge;
        final double grandTotal =
            totalPrice + finalDeliveryCharge + handlingCharge - couponDiscount;

        return _buildCard(
          context,
          savings: savings,
          hasSavings: hasSavings,
          deliveryCharge: deliveryCharge,
          finalDeliveryCharge: finalDeliveryCharge,
          isFreeDelivery: isFreeDelivery,
          handlingCharge: handlingCharge,
          grandTotal: grandTotal,
          deliveryThreshold: deliveryThreshold,
          couponDiscount: couponDiscount,
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _buildCard(
        context,
        savings: savings,
        hasSavings: hasSavings,
        deliveryCharge: 100,
        finalDeliveryCharge: totalPrice >= 1000 ? 0 : 100,
        isFreeDelivery: totalPrice >= 1000,
        handlingCharge: 0,
        grandTotal: totalPrice + (totalPrice >= 1000 ? 0 : 100) - couponDiscount,
        deliveryThreshold: 1000,
        couponDiscount: couponDiscount,
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required double savings,
    required bool hasSavings,
    required double deliveryCharge,
    required double finalDeliveryCharge,
    required bool isFreeDelivery,
    required double handlingCharge,
    required double grandTotal,
    required double deliveryThreshold,
    required double couponDiscount,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    Text(
                      'Bill Details',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textBlack,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.receipt_long,
                            size: 16.sp,
                            color: AppColor.primary.withValues(alpha: 0.8)),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Items total',
                                style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.textBlack)),
                            if (hasSavings) ...[
                              SizedBox(height: 4.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBE4B9),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text('Saved Rs.${savings.toInt()}',
                                    style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF8D5B18))),
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (hasSavings)
                          Text('Rs. ${totalMrp.toInt()}',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade400,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.grey.shade400)),
                        Text('Rs. ${totalPrice.toInt()}',
                            style: TextStyle(
                                fontSize: 13.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.delivery_dining,
                            size: 16.sp,
                            color: AppColor.primary.withValues(alpha: 0.8)),
                        SizedBox(width: 8.w),
                        Text('Delivery charge',
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColor.textBlack)),
                        SizedBox(width: 4.w),
                        Icon(Icons.info_outline,
                            size: 14.sp, color: Colors.grey.shade400),
                      ],
                    ),
                    Row(
                      children: [
                        if (isFreeDelivery && deliveryCharge > 0) ...[
                          Text('Rs.${deliveryCharge.toInt()}',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade400,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.grey.shade400)),
                          SizedBox(width: 6.w),
                          Text('FREE',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColor.secondary,
                                  fontWeight: FontWeight.bold)),
                        ] else
                          Text(
                              finalDeliveryCharge == 0
                                  ? 'FREE'
                                  : 'Rs.${finalDeliveryCharge.toInt()}',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: finalDeliveryCharge == 0
                                      ? AppColor.secondary
                                      : AppColor.textBlack)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shopping_bag_outlined,
                            size: 16.sp,
                            color: AppColor.primary.withValues(alpha: 0.8)),
                        SizedBox(width: 8.w),
                        Text('Handling Charge',
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColor.textBlack)),
                        SizedBox(width: 4.w),
                        Icon(Icons.info_outline,
                            size: 14.sp, color: Colors.grey.shade400),
                      ],
                    ),
                    Text('Rs.${handlingCharge.toInt()}',
                        style: TextStyle(
                            fontSize: 13.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (couponDiscount > 0) ...[
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_offer_outlined,
                              size: 16.sp,
                              color: AppColor.primary.withValues(alpha: 0.8)),
                          SizedBox(width: 8.w),
                          Text('Coupon Discount',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.textBlack)),
                        ],
                      ),
                      Text('- Rs.${couponDiscount.toInt()}',
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColor.primary)),
                    ],
                  ),
                ],
                SizedBox(height: 16.h),
                Divider(color: Colors.grey.shade200, height: 1),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Grand total',
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1B4332))),
                        SizedBox(height: 2.h),
                        Text('Incl. all taxes and charges',
                            style: TextStyle(
                                fontSize: 11.sp, color: Colors.grey.shade600)),
                      ],
                    ),
                    Text('Rs.${grandTotal.toInt()}',
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F5A29))),
                  ],
                ),
              ],
            ),
          ),
          if (!isFreeDelivery || hasSavings)
            ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
              child: ClipPath(
                clipper: ScallopedClipper(),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                  color: const Color(0xFFFDF0D5),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_offer,
                            size: 14.sp,
                            color: const Color(0xFF7F4F1D),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: const Color(0xFF7F4F1D),
                                  fontSize: 12.sp,
                                ),
                                children: [
                                  if (hasSavings)
                                    TextSpan(
                                      text: 'Rs. ${savings.toInt()} saved  ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  if (!isFreeDelivery) ...[
                                    const TextSpan(text: 'Add '),
                                    TextSpan(
                                      text:
                                          'Rs. ${(deliveryThreshold - totalPrice).toInt()} ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(text: 'more for '),
                                    const TextSpan(
                                      text: 'free delivery',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ] else ...[
                                    const TextSpan(
                                      text: 'You have unlocked free delivery!',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value:
                              (totalPrice / deliveryThreshold).clamp(0.0, 1.0),
                          backgroundColor: const Color(0xFFF5E3C4),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFD48D21),
                          ),
                          minHeight: 4.h,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ScallopedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 6.h);
    double x = 0;
    double y = 6.h;
    double waveLength = 14.w;
    double waveHeight = 4.h;

    while (x < size.width) {
      path.quadraticBezierTo(
        x + waveLength / 4,
        y - waveHeight,
        x + waveLength / 2,
        y,
      );
      path.quadraticBezierTo(
        x + 3 * waveLength / 4,
        y + waveHeight,
        x + waveLength,
        y,
      );
      x += waveLength;
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
