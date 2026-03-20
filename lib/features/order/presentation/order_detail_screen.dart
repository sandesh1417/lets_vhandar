import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/home/providers/general_settings_provider.dart';
import 'package:lets_vhandar/features/order/domain/models/order_model.dart';
import 'package:lets_vhandar/features/order/providers/order_detail_provider.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

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
                style: TextStyle(color: AppColor.primary, fontSize: 13.sp)),
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
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBar(order),
          SizedBox(height: 16.h),
          _buildStatusCards(order),
          SizedBox(height: 24.h),
          _buildProductList(order),
          SizedBox(height: 24.h),
          _buildBillDetails(order),
          SizedBox(height: 24.h),
          _buildAddressSection(order),
          SizedBox(height: 16.h),
          _buildPaymentSection(order),
          if (settings != null) ...[
            SizedBox(height: 32.h),
            _buildFreeDeliveryBanner(order, settings),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoBar(OrderData order) {
    final date = order.createdAt != null
        ? '${order.createdAt!.day} ${_getMonth(order.createdAt!.month)} ${order.createdAt!.year}'
        : '';
    final time = order.createdAt != null
        ? '${order.createdAt!.hour}:${order.createdAt!.minute.toString().padLeft(2, '0')}'
        : '';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$date $time PM',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.h),
              Text(
                '${order.orderId}',
                style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.green,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCards(OrderData order) {
    return Row(
      children: [
        const _StatusItem(
            label: 'Ordered at',
            value: 'MAR 20 2026 09:50 PM'), // Dummy for now
        SizedBox(width: 8.w),
        _StatusItem(
          label: 'Order Status',
          value: order.status ?? 'Pending',
          isBadge: true,
          badgeColor: const Color(0xFFFFF9C4),
          textColor: const Color(0xFFFBC02D),
        ),
        SizedBox(width: 8.w),
        _StatusItem(
          label: 'Payment Status',
          value: order.paymentStatus ?? 'Pending',
          isBadge: true,
          badgeColor: const Color(0xFFFFF9C4),
          textColor: const Color(0xFFFBC02D),
        ),
      ],
    );
  }

  Widget _buildProductList(OrderData order) {
    if (order.products == null || order.products!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: order.products!.map((p) => _ProductItem(product: p)).toList(),
    );
  }

  Widget _buildBillDetails(OrderData order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bill details',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          _BillRow(label: 'Items total', value: 'Rs. ${order.totalAmount}'),
          _BillRow(
              label: 'Delivery charge', value: 'Rs. ${order.deliveryCharge}'),
          _BillRow(
              label: 'Handling Charge', value: 'Rs. ${order.handlingCharge}'),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grand total',
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              Text('Rs.${order.totalPayableAmount}',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
            ],
          ),
          Text('Incl. all taxes and charges',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAddressSection(OrderData order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Address',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.h),
        Text(order.location?.description ?? 'N/A',
            style: TextStyle(fontSize: 14.sp, color: Colors.black87)),
      ],
    );
  }

  Widget _buildPaymentSection(OrderData order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment method',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.h),
        Text(order.paymentMethod ?? 'N/A',
            style: TextStyle(fontSize: 14.sp, color: Colors.black87)),
      ],
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
        color: const Color(0xFFFDE6B1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sell, size: 16, color: Colors.brown),
          SizedBox(width: 8.w),
          Text(
            'Add Items Worth Rs.$remaining More For Free Delivery',
            style: TextStyle(
                fontSize: 12.sp,
                color: Colors.brown.shade800,
                fontWeight: FontWeight.bold),
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

class _StatusItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isBadge;
  final Color? badgeColor;
  final Color? textColor;

  const _StatusItem({
    required this.label,
    required this.value,
    this.isBadge = false,
    this.badgeColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            SizedBox(height: 8.h),
            if (isBadge)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(value,
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: textColor,
                        fontWeight: FontWeight.bold)),
              )
            else
              Text(value,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ProductItem extends StatelessWidget {
  final OrderProduct product;

  const _ProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade50),
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: product.firstImageUrl != null
                ? Image.network(product.firstImageUrl!, fit: BoxFit.contain)
                : const Icon(Icons.shopping_bag_outlined),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name ?? '',
                    style: TextStyle(
                        fontSize: 13.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 4.h),
                Text('${product.unit} • Qty: ${product.count}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              ],
            ),
          ),
          Text('Rs.${product.totalPrice}',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label;
  final String value;

  const _BillRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
          Text(value,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
