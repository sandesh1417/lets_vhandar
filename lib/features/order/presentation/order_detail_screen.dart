import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/home/providers/general_settings_provider.dart';
import 'package:lets_vhandar/features/order/domain/models/order_model.dart';
import 'package:lets_vhandar/features/order/providers/order_detail_provider.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

import 'widgets/bill_details_card.dart';
import 'widgets/order_product_item.dart';
import 'widgets/order_status_badge.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final settingsAsync = ref.watch(generalSettingsProvider);

    return CustomScaffoldWrapper(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        scrolledUnderElevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Order Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => context.push(LVRoute.helpSupportScreen.route),
            child: Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.help_outline_rounded, size: 20.sp, color: Colors.white),
                  SizedBox(width: 4.w),
                  Text(
                    'Help',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: orderAsync.when(
        data: (order) => _buildBody(context, order, settingsAsync.value),
        loading: () => Center(child: CircularProgressIndicator(color: AppColor.primary)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrderData order, dynamic settings) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBar(context, order),
          SizedBox(height: 16.h),
          _buildStatusSummary(context, order),
          SizedBox(height: 24.h),
          _buildSectionHeader(context, 'Products'),
          SizedBox(height: 8.h),
          _buildProductList(order),
          SizedBox(height: 24.h),
          BillDetailsCard(order: order),
          SizedBox(height: 24.h),
          _buildSectionHeader(context, 'Delivery Address'),
          SizedBox(height: 12.h),
          _buildAddressSection(context, order),
          SizedBox(height: 24.h),
          _buildSectionHeader(context, 'Payment Method'),
          SizedBox(height: 12.h),
          _buildPaymentSection(context, order),
          SizedBox(height: 24.h),
          _buildDownloadReceiptButton(context, order),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        color: context.vColors.onSurface,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildInfoBar(BuildContext context, OrderData order) {
    final date = order.createdAt != null
        ? '${order.createdAt!.day} ${_getMonth(order.createdAt!.month)} ${order.createdAt!.year}'
        : '';
    final time = order.createdAt != null
        ? '${order.createdAt!.hour % 12 == 0 ? 12 : order.createdAt!.hour % 12}:${order.createdAt!.minute.toString().padLeft(2, '0')} ${order.createdAt!.hour >= 12 ? 'PM' : 'AM'}'
        : '';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$date • $time',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: context.vColors.onSurfaceMuted,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Order #${order.orderId}',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColor.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSummary(BuildContext context, OrderData order) {
    final vc = context.vColors;
    final orderedAt = order.createdAt != null
        ? '${_getMonth(order.createdAt!.month).toUpperCase()} ${order.createdAt!.day} ${order.createdAt!.year}'
        : 'N/A';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: vc.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: vc.divider),
      ),
      child: Row(
        children: [
          _StatusColumn(label: 'ORDERED ON', value: orderedAt),
          _StatusColumn(
            label: 'ORDER STATUS',
            child: OrderStatusBadge(status: order.status ?? 'Pending'),
          ),
          _StatusColumn(
            label: 'PAYMENT',
            child: OrderStatusBadge(status: order.paymentStatus ?? 'Pending'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(OrderData order) {
    if (order.products == null || order.products!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children:
          order.products!.map((p) => OrderProductItem(product: p)).toList(),
    );
  }

  Widget _buildAddressSection(BuildContext context, OrderData order) {
    final vc = context.vColors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: vc.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on_outlined,
              color: AppColor.primary, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.location?.name ?? 'Delivery Address',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: vc.onSurface),
                ),
                SizedBox(height: 4.h),
                Text(
                  order.location?.description ?? 'N/A',
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: vc.onSurfaceMuted,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(BuildContext context, OrderData order) {
    final vc = context.vColors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: vc.divider),
      ),
      child: Row(
        children: [
          Icon(Icons.payment_outlined, color: Colors.orange, size: 20.sp),
          SizedBox(width: 12.w),
          Text(
            order.paymentMethod ?? 'N/A',
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: vc.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadReceiptButton(BuildContext context, OrderData order) {
    final vc = context.vColors;
    return GestureDetector(
      onTap: () {
        final date = order.createdAt != null
            ? '${order.createdAt!.day} ${_getMonth(order.createdAt!.month)} ${order.createdAt!.year}'
            : '-';
        final items = (order.products ?? [])
            .map((p) => '  • ${p.name ?? 'Item'} x${p.count ?? 1}  Rs.${p.netPrice?.toInt() ?? 0}')
            .join('\n');
        final receipt = '''
============================
        VHANDAR RECEIPT
============================
Order ID : ${order.orderId ?? '-'}
Date     : $date
Status   : ${order.status ?? '-'}
Payment  : ${order.paymentMethod ?? '-'}
----------------------------
ITEMS:
$items
----------------------------
TOTAL    : Rs.${order.totalAmount?.toInt() ?? 0}
============================
Thank you for shopping with Vhandar!
''';
        Share.share(receipt, subject: 'Vhandar Order Receipt – ${order.orderId ?? ''}');
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: vc.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColor.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download_rounded,
                size: 20.sp, color: AppColor.primary),
            SizedBox(width: 10.w),
            Text(
              'Download Receipt',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

class _StatusColumn extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? child;

  const _StatusColumn({required this.label, this.value, this.child});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: vc.onSurfaceMuted,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8.h),
          if (child != null)
            child!
          else
            Text(
              value ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: vc.onSurface),
            ),
        ],
      ),
    );
  }
}
