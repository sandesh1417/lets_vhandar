import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vhandar/core/constants/color_constant.dart';
import 'package:vhandar/features/auth/login/providers/login_provider.dart';
import 'package:vhandar/features/order/providers/order_provider.dart';
import 'package:vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:vhandar/widgets/custom_screen_header.dart';

import 'presentation/widgets/order_card.dart';

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
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: const CustomScreenHeader(title: 'Orders History'),
      body: state.isLoading
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
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    itemCount: state.orders.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < state.orders.length) {
                        return OrderCard(order: state.orders[index]);
                      } else {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 64.sp,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your order history will appear here once you place an order.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

