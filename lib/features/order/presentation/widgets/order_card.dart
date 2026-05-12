import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vhandar/core/constants/color_constant.dart';
import 'package:vhandar/features/order/domain/models/order_model.dart';

import 'order_status_badge.dart';

class OrderCard extends StatelessWidget {
  final OrderData order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final createdAt = order.createdAt;
    final formattedDate = createdAt != null ? _formatDate(createdAt) : '—';
    final itemCount =
        order.products?.fold<int>(0, (sum, p) => sum + (p.count ?? 1)) ?? 0;

    return GestureDetector(
      onTap: () => context.push('/order-detail/${order.id}'),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ID and Date
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
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  OrderStatusBadge(status: order.status ?? 'Pending'),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 0.5),

            // Content: Product Icons and Total
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  // Product Mini Icons
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
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.grey.shade200,
                                            width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
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
                                                    const Icon(
                                                        Icons
                                                            .shopping_bag_outlined,
                                                        size: 16),
                                              )
                                            : const Icon(
                                                Icons.shopping_bag_outlined,
                                                size: 16),
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
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Total Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Payable',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade500,
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

            // Footer Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(16.r)),
              ),
              child: Center(
                child: Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primary,
                  ),
                ),
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
