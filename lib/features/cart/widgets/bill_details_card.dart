import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/home/providers/general_settings_provider.dart';

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
            totalPrice + finalDeliveryCharge + handlingCharge;

        return _buildCard(
          context,
          savings: savings,
          hasSavings: hasSavings,
          deliveryCharge: deliveryCharge,
          finalDeliveryCharge: finalDeliveryCharge,
          isFreeDelivery: isFreeDelivery,
          handlingCharge: handlingCharge,
          grandTotal: grandTotal,
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
        grandTotal: totalPrice + (totalPrice >= 1000 ? 0 : 100),
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
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bill details',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.greenTxtColor,
                  ),
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
                            size: 16.sp, color: AppColor.textMuted),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Items total',
                                style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColor.textBlack87)),
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
                                  fontSize: 13.sp,
                                  color: AppColor.textStrikeThrough,
                                  decoration: TextDecoration.lineThrough)),
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
                            size: 16.sp, color: AppColor.textMuted),
                        SizedBox(width: 8.w),
                        Text('Delivery charge',
                            style: TextStyle(
                                fontSize: 13.sp, color: AppColor.textBlack87)),
                        SizedBox(width: 4.w),
                        Icon(Icons.info_outline,
                            size: 14.sp, color: AppColor.textMuted),
                      ],
                    ),
                    Row(
                      children: [
                        if (isFreeDelivery && deliveryCharge > 0) ...[
                          Text('Rs.${deliveryCharge.toInt()}',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColor.textStrikeThrough,
                                  decoration: TextDecoration.lineThrough)),
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
                                      : AppColor.textBlack87)),
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
                            size: 16.sp, color: AppColor.textMuted),
                        SizedBox(width: 8.w),
                        Text('Handling Charge',
                            style: TextStyle(
                                fontSize: 13.sp, color: AppColor.textBlack87)),
                        SizedBox(width: 4.w),
                        Icon(Icons.info_outline,
                            size: 14.sp, color: AppColor.textMuted),
                      ],
                    ),
                    Text('Rs.${handlingCharge.toInt()}',
                        style: TextStyle(
                            fontSize: 13.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
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
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColor.greenTxtColor)),
                        SizedBox(height: 2.h),
                        Text('Incl. all taxes and charges',
                            style: TextStyle(
                                fontSize: 11.sp, color: AppColor.textMuted)),
                      ],
                    ),
                    Text('Rs. ${grandTotal.toInt()}',
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primary)),
                  ],
                ),
              ],
            ),
          ),
          if (hasSavings)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFBE4B9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer,
                      size: 14.sp, color: const Color(0xFF8D5B18)),
                  SizedBox(width: 6.w),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                          fontSize: 11.sp, color: const Color(0xFF8D5B18)),
                      children: [
                        TextSpan(
                            text: 'Rs. ${savings.toInt()} ',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: 'Saved!'),
                        if (isFreeDelivery)
                          const TextSpan(
                              text: ' Free Delivery!',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
