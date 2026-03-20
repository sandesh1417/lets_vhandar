import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/order/domain/models/order_model.dart';
import 'package:lets_vhandar/features/order/providers/order_provider.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(loginProvider).user?.id;
      if (userId != null) {
        ref.read(orderProvider.notifier).loadOrders(userId);
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final state = ref.read(orderProvider);
        if (!state.isLoading &&
            !state.isLoadingMore &&
            state.currentPage < state.totalPages) {
          final userId = ref.read(loginProvider).user?.id;
          if (userId != null) {
            ref.read(orderProvider.notifier).loadOrders(
                  userId,
                  page: state.currentPage + 1,
                );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderProvider);

    return CustomScaffoldWrapper(
      isScrollable: false,
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: const CustomScreenHeader(title: 'Orders History'),
      body: Column(
        children: [
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.orders.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () {
                          final userId = ref.read(loginProvider).user?.id;
                          if (userId != null) {
                            return ref
                                .read(orderProvider.notifier)
                                .loadOrders(userId);
                          }
                          return Future.value();
                        },
                        color: AppColor.primary,
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: EdgeInsets.all(12.w),
                          itemCount: state.orders.length +
                              (state.isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, __) => SizedBox(height: 6.h),
                          itemBuilder: (context, index) {
                            if (index < state.orders.length) {
                              return _OrderCard(order: state.orders[index]);
                            } else {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 24.h),
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            }
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: 120.h),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 72.sp, color: Colors.grey.shade300),
              SizedBox(height: 16.h),
              Text(
                'No orders yet',
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textBlack54),
              ),
              SizedBox(height: 8.h),
              Text(
                'Your order history will appear here',
                style: TextStyle(fontSize: 13.sp, color: AppColor.textBlack45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderData order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final createdAt = order.createdAt;
    final formattedDate = createdAt != null ? _formatDate(createdAt) : '—';
    final itemCount =
        order.products?.fold<int>(0, (sum, p) => sum + (p.count ?? 1)) ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.05),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$formattedDate  •  ${order.orderId ?? ''}',
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primary),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    context.push('/order-detail/${order.id}');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.primary,
                    side: BorderSide(color: AppColor.primary),
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle:
                        TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ordered at $formattedDate',
                      style: TextStyle(
                          fontSize: 13.sp, color: AppColor.textBlack54),
                    ),
                    Text(
                      'Rs.${order.totalPayableAmount?.toInt() ?? 0}',
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.textBlack87),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  '$itemCount Item${itemCount != 1 ? 's' : ''}',
                  style:
                      TextStyle(fontSize: 13.sp, color: AppColor.textBlack54),
                ),
                SizedBox(height: 6.h),
                if (order.products != null && order.products!.isNotEmpty)
                  SizedBox(
                    height: 34.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: order.products!.length,
                      separatorBuilder: (_, __) => SizedBox(width: 6.w),
                      itemBuilder: (context, i) {
                        final product = order.products![i];
                        final count = product.count ?? 1;
                        final imageUrl = product.firstImageUrl;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 34.w,
                              height: 34.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade100,
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: ClipOval(
                                child: imageUrl != null
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                            Icons.image_not_supported,
                                            size: 20.sp,
                                            color: Colors.grey),
                                      )
                                    : Icon(Icons.shopping_bag_outlined,
                                        size: 20.sp, color: Colors.grey),
                              ),
                            ),
                            if (count > 0)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  padding: EdgeInsets.all(3.w),
                                  decoration: BoxDecoration(
                                    color: AppColor.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                SizedBox(height: 4.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: _StatusChip(
                      status: order.status ?? order.paymentStatus ?? 'pending'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
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
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final ampm = date.hour >= 12 ? 'pm' : 'am';
    final min = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day} ${date.year} ${hour.toString().padLeft(2, '0')}:$min $ampm';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'delivered':
      case 'success':
        bg = Colors.green.shade50;
        textColor = Colors.green.shade700;
        label = 'Delivered';
        break;
      case 'cancelled':
      case 'failed':
        bg = Colors.red.shade50;
        textColor = Colors.red.shade700;
        label = 'Cancelled';
        break;
      case 'processing':
      case 'confirmed':
        bg = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        label = 'Processing';
        break;
      default:
        bg = const Color(0xFFFFF3CD);
        textColor = const Color(0xFF856404);
        label = status[0].toUpperCase() + status.substring(1);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(label,
          style: TextStyle(
              color: textColor, fontSize: 12.sp, fontWeight: FontWeight.w600)),
    );
  }
}
