import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/order/domain/models/order_model.dart';
import 'package:lets_vhandar/features/order/providers/order_provider.dart';

import 'order_status_badge.dart';

// Steps: 0=Pending, 1=Processing, 2=On the Way, 3=Delivered
const _stepLabels = ['Pending', 'Processing', 'On the Way', 'Delivered'];
const _stepIcons = [
  Icons.receipt_long_rounded,
  Icons.inventory_2_rounded,
  Icons.local_shipping_rounded,
  Icons.check_circle_rounded,
];

int _statusIndex(String? s) {
  switch (s?.toLowerCase()) {
    case 'processing':
      return 1;
    case 'shipped':
    case 'shipping':
      return 2;
    case 'delivered':
      return 3;
    default:
      return 0;
  }
}

bool _isTerminal(String? s) {
  final v = s?.toLowerCase();
  return v == 'cancelled' || v == 'returned' || v == 'refunded';
}

class OrderCard extends ConsumerWidget {
  final OrderData order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vc = context.vColors;
    final createdAt = order.createdAt;
    final formattedDate = createdAt != null ? _formatDate(createdAt) : '—';
    final itemCount =
        order.products?.fold<int>(0, (sum, p) => sum + (p.count ?? 1)) ?? 0;
    final cancelled = _isTerminal(order.status);
    final activeStep = _statusIndex(order.status);

    return GestureDetector(
      onTap: () async {
        await context.push('/order-detail/${order.id}');
        // Refresh list so status reflects any changes made while in detail
        final userId = ref.read(loginProvider).user?.id;
        if (userId != null) {
          ref.read(orderProvider.notifier).loadOrders(userId, page: 1);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: vc.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: vc.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 6.h, 14.w, 4.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.orderId}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: vc.onSurface,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: vc.onSurfaceMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OrderStatusBadge(status: order.status ?? 'Pending'),
                ],
              ),
            ),

            // ── Products + amount ──────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 4.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (order.products != null &&
                            order.products!.isNotEmpty)
                          SizedBox(
                            height: 32.h,
                            child: Row(
                              children: List.generate(
                                order.products!.length.clamp(0, 5),
                                (i) {
                                  final product = order.products![i];
                                  final imageUrl = product.firstImageUrl;
                                  return Align(
                                    widthFactor: 0.7,
                                    child: Container(
                                      width: 32.h,
                                      height: 32.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: vc.surface,
                                        border: Border.all(
                                            color: vc.divider, width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.05),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: imageUrl != null
                                            ? CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                fit: BoxFit.cover,
                                                errorWidget: (_, __, ___) =>
                                                    Icon(
                                                  Icons.shopping_bag_outlined,
                                                  size: 16,
                                                  color: vc.onSurfaceMuted,
                                                ),
                                              )
                                            : Icon(
                                                Icons.shopping_bag_outlined,
                                                size: 16,
                                                color: vc.onSurfaceMuted,
                                              ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        SizedBox(height: 4.h),
                        Text(
                          '$itemCount item${itemCount != 1 ? 's' : ''}  •  ${order.paymentMethod ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: vc.onSurfaceMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: vc.onSurfaceMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Rs.${order.totalPayableAmount}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColor.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Mini stepper / status banner ────────────────────────
            if (cancelled)
              _CancelledRow(status: order.status)
            else if (activeStep == 3)
              const _DeliveredRow()
            else
              _MiniStepper(activeStep: activeStep, vc: vc),

            // ── View details footer ────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColor.primary.withValues(alpha: 0.04),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(16.r)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'View Order Details',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primary,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 12.sp, color: AppColor.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final min = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$min $ampm';
  }
}

// ── Mini horizontal stepper ───────────────────────────────────────────────────

class _MiniStepper extends StatelessWidget {
  final int activeStep;
  final VhandarColors vc;
  const _MiniStepper({required this.activeStep, required this.vc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 6.h),
      child: Row(
        children: List.generate(_stepLabels.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stepIndex = i ~/ 2;
            final done = stepIndex < activeStep;
            return Expanded(
              child: Container(
                height: 1.5.h,
                color: done
                    ? vc.onSurface.withValues(alpha: 0.2)
                    : vc.onSurface.withValues(alpha: 0.1),
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final done = stepIndex < activeStep;
          final active = stepIndex == activeStep;

          // Completed = small grey filled dot; Active = primary circle; Upcoming = hollow grey
          final dotBg = active
              ? AppColor.primary
              : done
                  ? vc.onSurface.withValues(alpha: 0.18)
                  : Colors.transparent;
          final dotBorder = active
              ? AppColor.primary
              : done
                  ? vc.onSurface.withValues(alpha: 0.25)
                  : vc.onSurface.withValues(alpha: 0.15);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: done ? 20.w : 26.w,
                height: done ? 20.w : 26.w,
                decoration: BoxDecoration(
                  color: dotBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: dotBorder, width: 1.5),
                ),
                child: done
                    ? Icon(Icons.check_rounded,
                        size: 11.sp, color: vc.onSurface.withValues(alpha: 0.5))
                    : Icon(_stepIcons[stepIndex],
                        size: 13.sp,
                        color: active
                            ? Colors.white
                            : vc.onSurface.withValues(alpha: 0.3)),
              ),
              SizedBox(height: 3.h),
              SizedBox(
                width: 64.w,
                child: Text(
                  _stepLabels[stepIndex],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active
                        ? AppColor.primary
                        : done
                            ? vc.onSurface.withValues(alpha: 0.45)
                            : vc.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _DeliveredRow extends StatelessWidget {
  const _DeliveredRow();

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF2E7D32);
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 6.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: color, size: 14.sp),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Order Delivered Successfully',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelledRow extends StatelessWidget {
  final String? status;
  const _CancelledRow({this.status});

  @override
  Widget build(BuildContext context) {
    final s = status?.toLowerCase();
    final (label, color, icon) = switch (s) {
      'returned' => (
          'Order Returned',
          Colors.purple.shade600,
          Icons.assignment_return_rounded
        ),
      'refunded' => (
          'Order Refunded',
          const Color(0xFF00695C),
          Icons.currency_exchange_rounded
        ),
      _ => ('Order Cancelled', Colors.red.shade600, Icons.cancel_rounded),
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 6.h),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
