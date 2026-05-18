import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/order/providers/order_provider.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:lets_vhandar/widgets/premium_search_bar.dart';

import 'presentation/widgets/order_card.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Search & Filter States
  String? _selectedStatus;
  String? _selectedPaymentStatus;
  DateTimeRange? _selectedDateRange;
  String? _startDateStr;
  String? _endDateStr;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders();
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
                  status: _selectedStatus,
                  paymentStatus: _selectedPaymentStatus,
                  startDate: _startDateStr,
                  endDate: _endDateStr,
                );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _fetchOrders() {
    final userId = ref.read(loginProvider).user?.id;
    if (userId != null) {
      ref.read(orderProvider.notifier).loadOrders(
            userId,
            page: 1,
            status: _selectedStatus,
            paymentStatus: _selectedPaymentStatus,
            startDate: _startDateStr,
            endDate: _endDateStr,
          );
    }
  }

  void _applyFilters() {
    _fetchOrders();
  }

  void _clearAllFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedPaymentStatus = null;
      _selectedDateRange = null;
      _startDateStr = null;
      _endDateStr = null;
      _searchController.clear();
    });
    final userId = ref.read(loginProvider).user?.id;
    if (userId != null) {
      ref.read(orderProvider.notifier).loadOrders(
            userId,
            page: 1,
            clearFilters: true,
          );
    }
  }

  String _formatDateSlash(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }

  String _formatDateApi(DateTime date) {
    const allMonths = [
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
    return "${allMonths[date.month - 1]} ${date.day} ${date.year}";
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColor.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _startDateStr = _formatDateApi(picked.start);
        _endDateStr = _formatDateApi(picked.end);
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderProvider);
    final filteredOrders = state.filteredOrders;
    final isAnyFilterActive = _selectedStatus != null ||
        _selectedPaymentStatus != null ||
        _selectedDateRange != null ||
        _searchController.text.isNotEmpty;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: const CustomScreenHeader(
        title: 'My Orders',
        showBackButton: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),

          // Search Input Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: PremiumSearchBar(
              controller: _searchController,
              hintText: 'Search by order ID or product...',
              showScanIcon: false,
              onChanged: (value) {
                ref.read(orderProvider.notifier).state =
                    state.copyWith(searchQuery: value);
              },
            ),
          ),
          SizedBox(height: 8.h),

          // Filters Horizontal Selector Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                // Clear Filters Button
                if (isAnyFilterActive)
                  Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: InkWell(
                      onTap: _clearAllFilters,
                      borderRadius: BorderRadius.circular(24.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F5),
                          border: Border.all(
                              color: const Color(0xFFFFC1C1), width: 1.2.w),
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close_rounded,
                                size: 14.sp, color: Colors.red.shade700),
                            SizedBox(width: 4.w),
                            Text(
                              'Clear',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // "All" Filter Button
                InkWell(
                  onTap: _clearAllFilters,
                  borderRadius: BorderRadius.circular(24.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color:
                          !isAnyFilterActive ? AppColor.primary : Colors.white,
                      border: Border.all(
                        color: !isAnyFilterActive
                            ? AppColor.primary
                            : AppColor.primary.withOpacity(0.8),
                        width: 1.2.w,
                      ),
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'All',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: !isAnyFilterActive
                            ? Colors.white
                            : AppColor.primary.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // Order Status Dropdown Button (Pending, Processing, Returned, Delivered)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                    _applyFilters();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  offset: const Offset(0, 40),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'Pending', child: Text('Pending')),
                    const PopupMenuItem(
                        value: 'Processing', child: Text('Processing')),
                    const PopupMenuItem(
                        value: 'Returned', child: Text('Returned')),
                    const PopupMenuItem(
                        value: 'Delivered', child: Text('Delivered')),
                  ],
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                     decoration: BoxDecoration(
                      color: _selectedStatus != null
                          ? AppColor.primary
                          : Colors.white,
                      border: Border.all(
                        color: _selectedStatus != null
                            ? AppColor.primary
                            : AppColor.primary.withOpacity(0.8),
                        width: 1.2.w,
                      ),
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          _selectedStatus ?? 'Status',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: _selectedStatus != null
                                ? Colors.white
                                : AppColor.primary.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 14.sp,
                          color: _selectedStatus != null
                              ? Colors.white
                              : AppColor.primary.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // Payment Status Dropdown Button (Paid, Pending, Due)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _selectedPaymentStatus = value;
                    });
                    _applyFilters();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  offset: const Offset(0, 40),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'Paid', child: Text('Paid')),
                    const PopupMenuItem(
                        value: 'Pending', child: Text('Pending')),
                    const PopupMenuItem(value: 'Due', child: Text('Due')),
                  ],
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                     decoration: BoxDecoration(
                      color: _selectedPaymentStatus != null
                          ? AppColor.primary
                          : Colors.white,
                      border: Border.all(
                        color: _selectedPaymentStatus != null
                            ? AppColor.primary
                            : AppColor.primary.withOpacity(0.8),
                        width: 1.2.w,
                      ),
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          _selectedPaymentStatus ?? 'Payment',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: _selectedPaymentStatus != null
                                ? Colors.white
                                : AppColor.primary.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 14.sp,
                          color: _selectedPaymentStatus != null
                              ? Colors.white
                              : AppColor.primary.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // Date Range Button Selector
                InkWell(
                  onTap: _selectDateRange,
                  borderRadius: BorderRadius.circular(24.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: _selectedDateRange != null
                          ? AppColor.primary
                          : Colors.white,
                      border: Border.all(
                        color: AppColor.primary,
                        width: 1.2.w,
                      ),
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          _selectedDateRange != null
                              ? "${_formatDateSlash(_selectedDateRange!.start)} - ${_formatDateSlash(_selectedDateRange!.end)}"
                              : "mm / dd / yyyy - mm / dd / yyyy",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: _selectedDateRange != null
                                ? Colors.white
                                : AppColor.primary,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14.sp,
                          color: _selectedDateRange != null
                              ? Colors.white
                              : AppColor.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          // Main Orders List Area
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () {
                          _fetchOrders();
                          return Future.value();
                        },
                        color: AppColor.primary,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 4.h),
                          itemCount: filteredOrders.length +
                              (state.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < filteredOrders.length) {
                              return OrderCard(order: filteredOrders[index]);
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.assignment_outlined,
                      size: 60.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      'Your orders will appear here once you place them.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
