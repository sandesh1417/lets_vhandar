import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/order/domain/models/order_model.dart';

class BillDetailsCard extends StatelessWidget {
  final OrderData order;

  const BillDetailsCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.vColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: context.vColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill details',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: context.vColors.onSurface,
            ),
          ),
          SizedBox(height: 16.h),
          _BillRow(label: 'Items total', value: 'Rs. ${order.totalAmount}'),
          if ((order.deliveryCharge ?? 0) > 0)
            _BillRow(label: 'Delivery charge', value: 'Rs. ${order.deliveryCharge}'),
          if ((order.handlingCharge ?? 0) > 0)
            _BillRow(label: 'Handling Charge', value: 'Rs. ${order.handlingCharge}'),
          if ((order.totalVatAmount ?? 0) > 0)
            _BillRow(
              label: 'VAT (13%)',
              value: 'Rs. ${order.totalVatAmount}',
              isVat: true,
            ),
          SizedBox(height: 8.h),
          const Divider(height: 24, thickness: 0.8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand total',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: context.vColors.onSurface,
                ),
              ),
              Text(
                'Rs.${order.totalPayableAmount}',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32), // Premium Green
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Incl. all taxes and charges',
            style: TextStyle(
              fontSize: 11.sp,
              color: context.vColors.onSurfaceMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isVat;

  const _BillRow({
    required this.label,
    required this.value,
    this.isVat = false,
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: vc.onSurfaceMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: vc.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
