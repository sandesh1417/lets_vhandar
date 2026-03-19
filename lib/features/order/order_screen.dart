import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/order/domain/models/order_model.dart';
import 'package:lets_vhandar/features/order/providers/order_provider.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

// TODO: Replace with actual logged-in user ID from auth state
const _kOrderUserId = '67baf2ff5d58f3aca9733828';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProvider.notifier).loadOrders(_kOrderUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderProvider);

    return CustomScaffoldWrapper(
      isScrollable: false,
      appBar: const CustomScreenHeader(title: 'Orders History'),
      body: Column(
        children: [
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.orders.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => ref
                            .read(orderProvider.notifier)
                            .loadOrders(_kOrderUserId),
                        color: AppColor.primary,
                        child: ListView.separated(
                          padding: EdgeInsets.all(16.w),
                          itemCount: state.orders.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            return _OrderCard(order: state.orders[index]);
                          },
                        ),
                      ),
          ),
          // Pagination
          if (state.totalPages > 1)
            _PaginationBar(
              currentPage: state.currentPage,
              totalPages: state.totalPages,
              onPrev: state.currentPage > 1
                  ? () => ref.read(orderProvider.notifier).loadOrders(
                        _kOrderUserId,
                        page: state.currentPage - 1,
                      )
                  : null,
              onNext: state.currentPage < state.totalPages
                  ? () => ref.read(orderProvider.notifier).loadOrders(
                        _kOrderUserId,
                        page: state.currentPage + 1,
                      )
                  : null,
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

// ─── Order Card ───────────────────────────────────────────────────────────────

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
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.06),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
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
                    // TODO: navigate to order detail screen
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

          // ── Body ─────────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                SizedBox(height: 10.h),

                // Product thumbnails
                if (order.products != null && order.products!.isNotEmpty)
                  SizedBox(
                    height: 48.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: order.products!.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (context, i) {
                        final product = order.products![i];
                        final count = product.count ?? 1;
                        final imageUrl = product.firstImageUrl;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 48.w,
                              height: 48.h,
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

                SizedBox(height: 10.h),
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

// ─── Status Chip ─────────────────────────────────────────────────────────────

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
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
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

// ─── Pagination Bar ───────────────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PageButton(label: 'Previous', onTap: onPrev),
          SizedBox(width: 16.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '$currentPage / $totalPages',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(width: 16.w),
          _PageButton(label: 'Next', onTap: onNext),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _PageButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: enabled
              ? AppColor.primary.withOpacity(0.12)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: enabled ? AppColor.primary : Colors.grey.shade400),
        ),
      ),
    );
  }
}
