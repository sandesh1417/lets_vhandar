import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:lets_vhandar/widgets/custom_shimmer.dart';
import 'package:lets_vhandar/widgets/error_state.dart';

import 'widgets/bill_details_card.dart';
import 'widgets/order_product_item.dart';
import 'widgets/order_status_badge.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    ref.watch(generalSettingsProvider);

    return CustomScaffoldWrapper(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Order Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => context.push(LVRoute.helpSupportScreen.route),
            child: Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.headset_mic_outlined,
                      size: 20.sp, color: Colors.white),
                  SizedBox(width: 4.w),
                  Text(
                    'Help',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: orderAsync.when(
        data: (order) => _OrderDetailBody(order: order),
        loading: () => const OrderDetailShimmer(),
        error: (_, __) => const ErrorStateWidget(),
      ),
    );
  }
}

String _monthName(int month) {
  const m = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];
  return m[month - 1];
}

class _OrderDetailBody extends StatelessWidget {
  final OrderData order;
  const _OrderDetailBody({required this.order});

  String get _dateStr {
    if (order.createdAt == null) return '';
    final d = order.createdAt!;
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final min = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day} ${_monthName(d.month)} ${d.year}  •  $h:$min $ampm';
  }

  String _svgForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'home':   return 'assets/icons/address_home.svg';
      case 'office': return 'assets/icons/address_office.svg';
      default:       return 'assets/icons/address_other.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Order hero card ────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: vc.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: vc.divider),
            ),
            child: Column(
              children: [
                // Green strip with order ID + date
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16.r)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${order.orderId ?? '—'}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              _dateStr,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.white.withValues(alpha: 0.80),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Share button
                      GestureDetector(
                        onTap: () => _shareReceipt(),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(Icons.download_rounded,
                              color: Colors.white, size: 18.sp),
                        ),
                      ),
                    ],
                  ),
                ),

                // Status + payment row
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 14.h),
                  child: Row(
                    children: [
                      _InfoChip(
                        label: 'Order',
                        child: OrderStatusBadge(
                            status: order.status ?? 'Pending'),
                      ),
                      SizedBox(width: 12.w),
                      _InfoChip(
                        label: 'Payment',
                        child: OrderStatusBadge(
                            status: order.paymentStatus ?? 'Pending'),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rs. ${order.totalPayableAmount ?? 0}',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColor.primary,
                            ),
                          ),
                          Text(
                            'Total paid',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: vc.onSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // ── Products ────────────────────────────────────────────────
          const _SectionLabel(label: 'Items Ordered'),
          Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: vc.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: vc.divider),
            ),
            child: Column(
              children: [
                for (int i = 0; i < (order.products?.length ?? 0); i++) ...[
                  OrderProductItem(product: order.products![i]),
                  if (i < (order.products!.length - 1))
                    Divider(height: 20.h, color: vc.divider),
                ],
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // ── Delivery Info ────────────────────────────────────────────
          if (_hasDeliveryInfo(order)) ...[
            const _SectionLabel(label: 'Delivery Info'),
            SizedBox(height: 10.h),
            _DeliveryInfoCard(order: order),
            SizedBox(height: 20.h),
          ],

          // ── Bill ────────────────────────────────────────────────────
          const _SectionLabel(label: 'Bill Details'),
          SizedBox(height: 10.h),
          BillDetailsCard(order: order),

          SizedBox(height: 20.h),

          // ── Delivery Address ────────────────────────────────────────
          const _SectionLabel(label: 'Delivery Address'),
          SizedBox(height: 10.h),
          if (order.location != null)
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: vc.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: vc.divider),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    padding: EdgeInsets.all(9.w),
                    decoration: BoxDecoration(
                      color: AppColor.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: SvgPicture.asset(
                      _svgForType(order.location?.addressType),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.location?.name?.isNotEmpty == true
                              ? order.location!.name!
                              : _labelForType(order.location?.addressType),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: vc.onSurface,
                          ),
                        ),
                        if (order.location?.description?.isNotEmpty == true) ...[
                          SizedBox(height: 4.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 13.sp, color: AppColor.primary),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  order.location!.description!,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: vc.onSurfaceMuted,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (order.location?.phoneNumber?.isNotEmpty == true) ...[
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(Icons.phone_outlined,
                                  size: 13.sp, color: AppColor.primary),
                              SizedBox(width: 4.w),
                              Text(
                                order.location!.phoneNumber!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: vc.onSurfaceMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 20.h),

          // ── Payment Method ──────────────────────────────────────────
          const _SectionLabel(label: 'Payment Method'),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: vc.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: vc.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.account_balance_wallet_outlined,
                      color: Colors.orange.shade700, size: 22.sp),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.paymentMethod ?? 'Cash on Delivery',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: vc.onSurface,
                        ),
                      ),
                      Text(
                        'Payment method used',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: vc.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                OrderStatusBadge(status: order.paymentStatus ?? 'Pending'),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // ── Share Receipt ───────────────────────────────────────────
          GestureDetector(
            onTap: _shareReceipt,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColor.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                    color: AppColor.primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_rounded,
                      size: 18.sp, color: AppColor.primary),
                  SizedBox(width: 8.w),
                  Text(
                    'Share Receipt',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColor.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasDeliveryInfo(OrderData o) {
    final s = o.status?.toLowerCase();
    return (o.deliveryTime?.isNotEmpty == true) ||
        (o.deliveryTimeSlot != null) ||
        (s == 'delivered' && o.updatedAt != null);
  }

  String _labelForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'home':   return 'Home';
      case 'office': return 'Office';
      default:
        if (type != null && type.isNotEmpty) {
          return type[0].toUpperCase() + type.substring(1);
        }
        return 'Others';
    }
  }

  void _shareReceipt() {
    final date = order.createdAt != null
        ? '${order.createdAt!.day} ${_monthName(order.createdAt!.month)} ${order.createdAt!.year}'
        : '-';
    final items = (order.products ?? [])
        .map((p) =>
            '  • ${p.name ?? 'Item'} x${p.count ?? 1}  Rs.${p.netPrice?.toInt() ?? 0}')
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
TOTAL    : Rs.${order.totalPayableAmount ?? 0}
============================
Thank you for shopping with Vhandar!
''';
    SharePlus.instance.share(ShareParams(
        text: receipt,
        subject: 'Vhandar Order Receipt – ${order.orderId ?? ''}'));
  }
}

// ── Section label ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

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

// ── Info chip (label + child) ──────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final String label;
  final Widget child;
  const _InfoChip({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: context.vColors.onSurfaceMuted,
          ),
        ),
        SizedBox(height: 4.h),
        child,
      ],
    );
  }
}

// ── Delivery Info Card ─────────────────────────────────────────────────────

class _DeliveryInfoCard extends StatelessWidget {
  final OrderData order;
  const _DeliveryInfoCard({required this.order});

  String _fmt(DateTime d) => '${d.day} ${_monthName(d.month)} ${d.year}';

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final isDelivered = order.status?.toLowerCase() == 'delivered';
    final slot = order.deliveryTimeSlot;
    final slotLabel = slot is Map
        ? ('${slot['slotName'] ?? ''} ${slot['displayTime'] ?? ''}'.trim())
        : (slot is String ? slot : null);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: vc.divider),
      ),
      child: Column(
        children: [
          // Delivered on
          if (isDelivered && order.updatedAt != null)
            _InfoRow(
              icon: Icons.check_circle_outline_rounded,
              iconColor: const Color(0xFF2E7D32),
              label: 'Delivered on',
              value: _fmt(order.updatedAt!),
            ),

          // Delivery time (field)
          if (order.deliveryTime?.isNotEmpty == true) ...[
            if (isDelivered && order.updatedAt != null)
              Divider(height: 20.h, color: vc.divider),
            _InfoRow(
              icon: Icons.schedule_rounded,
              iconColor: AppColor.primary,
              label: 'Delivery time',
              value: order.deliveryTime!,
            ),
          ],

          // Time slot
          if (slotLabel != null && slotLabel.isNotEmpty) ...[
            if ((isDelivered && order.updatedAt != null) ||
                order.deliveryTime?.isNotEmpty == true)
              Divider(height: 20.h, color: vc.divider),
            _InfoRow(
              icon: Icons.access_time_rounded,
              iconColor: AppColor.primary,
              label: 'Time slot',
              value: slotLabel,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: iconColor, size: 18.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: vc.onSurfaceMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: vc.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
