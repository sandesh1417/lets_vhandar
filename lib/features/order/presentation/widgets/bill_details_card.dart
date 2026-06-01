import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/order/domain/models/order_model.dart';

class BillDetailsCard extends StatelessWidget {
  final OrderData order;

  const BillDetailsCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;

    final rows = <_BillRowData>[
      _BillRowData(
        icon: Icons.shopping_bag_outlined,
        label: 'Items total',
        value: 'Rs. ${order.totalAmount?.toInt() ?? 0}',
      ),
      if ((order.totalDiscount ?? 0) > 0)
        _BillRowData(
          icon: Icons.local_offer_outlined,
          label: 'Discount',
          value: '− Rs. ${order.totalDiscount?.toInt()}',
          valueColor: const Color(0xFF2E7D32),
        ),
      if ((order.couponDiscount ?? 0) > 0)
        _BillRowData(
          icon: Icons.confirmation_number_outlined,
          label: 'Coupon (${order.appliedCouponCode ?? ''})',
          value: '− Rs. ${order.couponDiscount?.toInt()}',
          valueColor: const Color(0xFF2E7D32),
        ),
      if ((order.deliveryCharge ?? 0) > 0)
        _BillRowData(
          icon: Icons.delivery_dining_outlined,
          label: 'Delivery charge',
          value: 'Rs. ${order.deliveryCharge?.toInt()}',
        )
      else
        const _BillRowData(
          icon: Icons.delivery_dining_outlined,
          label: 'Delivery charge',
          value: 'FREE',
          valueColor: Color(0xFF2E7D32),
        ),
      if ((order.handlingCharge ?? 0) > 0)
        _BillRowData(
          icon: Icons.inventory_2_outlined,
          label: 'Handling charge',
          value: 'Rs. ${order.handlingCharge?.toInt()}',
        ),
      if ((order.totalVatAmount ?? 0) > 0)
        _BillRowData(
          icon: Icons.receipt_outlined,
          label: 'VAT (13%)',
          value: 'Rs. ${order.totalVatAmount?.toInt()}',
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: vc.divider),
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
              border: Border(bottom: BorderSide(color: vc.divider)),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long_rounded,
                    color: AppColor.primary, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  'Bill Details',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: vc.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // ── Rows ──────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
            child: Column(
              children: [
                ...rows.asMap().entries.map((e) => Column(
                      children: [
                        _BillRow(data: e.value),
                        if (e.key < rows.length - 1)
                          Divider(
                              height: 16.h,
                              thickness: 1,
                              color: vc.divider),
                      ],
                    )),
              ],
            ),
          ),

          // ── Grand Total ───────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(14.r)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grand Total',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Incl. all taxes & charges',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Rs. ${order.totalPayableAmount?.toInt() ?? 0}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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

// ── Data class ────────────────────────────────────────────────────────────

class _BillRowData {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _BillRowData({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
}

// ── Row widget ────────────────────────────────────────────────────────────

class _BillRow extends StatelessWidget {
  final _BillRowData data;
  const _BillRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Row(
      children: [
        Icon(data.icon, size: 15.sp, color: vc.onSurfaceMuted),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            data.label,
            style: TextStyle(
              fontSize: 13.sp,
              color: vc.onSurfaceMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          data.value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: data.valueColor ?? vc.onSurface,
          ),
        ),
      ],
    );
  }
}
