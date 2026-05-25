import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/order/domain/models/order_model.dart';

import 'order_status_badge.dart';

class OrderCard extends StatelessWidget {
  final OrderData order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final createdAt = order.createdAt;
    final formattedDate = createdAt != null ? _formatDate(createdAt) : '—';
    final itemCount =
        order.products?.fold<int>(0, (sum, p) => sum + (p.count ?? 1)) ?? 0;

    return GestureDetector(
      onTap: () => context.push('/order-detail/${order.id}'),
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
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.orderId}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: vc.onSurface,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: vc.onSurfaceMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  OrderStatusBadge(status: order.status ?? 'Pending'),
                ],
              ),
            ),

            Divider(height: 1, thickness: 0.5, color: vc.divider),

            Padding(
              padding: EdgeInsets.all(12.w),
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
                                            ? Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(
                                                        Icons
                                                            .shopping_bag_outlined,
                                                        size: 16,
                                                        color:
                                                            vc.onSurfaceMuted),
                                              )
                                            : Icon(
                                                Icons.shopping_bag_outlined,
                                                size: 16,
                                                color: vc.onSurfaceMuted),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        SizedBox(height: 8.h),
                        Text(
                          '$itemCount Item${itemCount != 1 ? 's' : ''}  •  ${order.paymentMethod ?? 'N/A'}',
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
                        'Total Payable',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: vc.onSurfaceMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rs.${order.totalPayableAmount}',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primary,
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
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final min = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$min $ampm';
  }
}
