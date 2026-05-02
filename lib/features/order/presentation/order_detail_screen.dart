import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/home/providers/general_settings_provider.dart';
import 'package:lets_vhandar/features/order/domain/models/order_model.dart';
import 'package:lets_vhandar/features/order/providers/order_detail_provider.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

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
      appBar: CustomScreenHeader(
        title: 'Order Details',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.help_outline, size: 20.sp, color: AppColor.primary),
            SizedBox(width: 4.w),
            Text('Help',
                style: TextStyle(
                    color: AppColor.primary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: orderAsync.when(
        data: (order) => _buildBody(context, order, settingsAsync.value),
        loading: () => const Center(child: CircularProgressIndicator()),
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
          _buildInfoBar(order),
          SizedBox(height: 16.h),
          _buildStatusSummary(order),
          SizedBox(height: 24.h),
          _buildSectionHeader('Products'),
          SizedBox(height: 8.h),
          _buildProductList(order),
          SizedBox(height: 24.h),
          BillDetailsCard(order: order),
          SizedBox(height: 24.h),
          _buildSectionHeader('Delivery Address'),
          SizedBox(height: 12.h),
          _buildAddressSection(order),
          SizedBox(height: 24.h),
          _buildSectionHeader('Payment Method'),
          SizedBox(height: 12.h),
          _buildPaymentSection(order),
          if (settings != null) ...[
            SizedBox(height: 32.h),
            _buildFreeDeliveryBanner(order, settings),
          ],
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildInfoBar(OrderData order) {
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
                  color: Colors.black54,
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

  Widget _buildStatusSummary(OrderData order) {
    final orderedAt = order.createdAt != null
        ? '${_getMonth(order.createdAt!.month).toUpperCase()} ${order.createdAt!.day} ${order.createdAt!.year}'
        : 'N/A';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade100),
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

  Widget _buildAddressSection(OrderData order) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade100),
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
                      color: Colors.black87),
                ),
                SizedBox(height: 4.h),
                Text(
                  order.location?.description ?? 'N/A',
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade700,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(OrderData order) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade100),
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
                color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeDeliveryBanner(OrderData order, dynamic settings) {
    final threshold = settings.deliveryThreshold ?? 0;
    final itemsTotal = order.totalAmount ?? 0;

    if (itemsTotal >= threshold) return const SizedBox.shrink();

    final remaining = threshold - itemsTotal;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E7),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFFECB3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping_outlined,
              size: 18.sp, color: Colors.amber.shade900),
          SizedBox(width: 10.w),
          Text(
            'Add Rs.$remaining more for Free Delivery',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.amber.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600, // Fixed dim text
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
                  color: Colors.black87),
            ),
        ],
      ),
    );
  }
}
