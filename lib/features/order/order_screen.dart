import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/order/providers/order_provider.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';
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

  // ignore: unused_element
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

  // ignore: unused_element
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

  void _showFilterSheet(BuildContext context) {
    // Local copies so the sheet can preview selections before applying
    String? sheetStatus = _selectedStatus;
    String? sheetPayment = _selectedPaymentStatus;
    DateTimeRange? sheetDateRange = _selectedDateRange;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            Future<void> pickDate() async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDateRange: sheetDateRange,
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColor.primary,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black87,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) setSheet(() => sheetDateRange = picked);
            }

            Widget filterChip(
                String label, bool selected, VoidCallback onTap) {
              return GestureDetector(
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: selected ? AppColor.primary : context.vColors.surface,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: selected
                          ? AppColor.primary
                          : context.vColors.divider,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      color: selected ? Colors.white : context.vColors.onSurface,
                    ),
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: context.vColors.surface,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: context.vColors.divider,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          color: context.vColors.onSurface,
                        ),
                      ),
                      if (sheetStatus != null ||
                          sheetPayment != null ||
                          sheetDateRange != null)
                        GestureDetector(
                          onTap: () {
                            setSheet(() {
                              sheetStatus = null;
                              sheetPayment = null;
                              sheetDateRange = null;
                            });
                          },
                          child: Text(
                            'Clear all',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                              color: Colors.red.shade500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Order Status
                  Text(
                    'Order Status',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      color: context.vColors.onSurfaceMuted,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      for (final s in [
                        'Pending',
                        'Processing',
                        'Delivered',
                        'Returned'
                      ])
                        filterChip(s, sheetStatus == s, () {
                          setSheet(() => sheetStatus =
                              sheetStatus == s ? null : s);
                        }),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Payment Status
                  Text(
                    'Payment Status',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      color: context.vColors.onSurfaceMuted,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      for (final p in ['Paid', 'Pending', 'Due'])
                        filterChip(p, sheetPayment == p, () {
                          setSheet(() => sheetPayment =
                              sheetPayment == p ? null : p);
                        }),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Date Range
                  Text(
                    'Date Range',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      color: context.vColors.onSurfaceMuted,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: pickDate,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: sheetDateRange != null
                            ? AppColor.primary.withValues(alpha: 0.08)
                            : context.vColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: sheetDateRange != null
                              ? AppColor.primary.withValues(alpha: 0.4)
                              : context.vColors.inputBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 16.sp,
                              color: sheetDateRange != null
                                  ? AppColor.primary
                                  : context.vColors.onSurfaceMuted),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              sheetDateRange != null
                                  ? '${_formatDateSlash(sheetDateRange!.start)}  →  ${_formatDateSlash(sheetDateRange!.end)}'
                                  : 'Select date range',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inter',
                                color: sheetDateRange != null
                                    ? AppColor.primary
                                    : context.vColors.onSurfaceMuted,
                              ),
                            ),
                          ),
                          if (sheetDateRange != null)
                            GestureDetector(
                              onTap: () =>
                                  setSheet(() => sheetDateRange = null),
                              child: Icon(Icons.close_rounded,
                                  size: 16.sp, color: AppColor.primary),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedStatus = sheetStatus;
                          _selectedPaymentStatus = sheetPayment;
                          _selectedDateRange = sheetDateRange;
                          _startDateStr = sheetDateRange != null
                              ? _formatDateApi(sheetDateRange!.start)
                              : null;
                          _endDateStr = sheetDateRange != null
                              ? _formatDateApi(sheetDateRange!.end)
                              : null;
                        });
                        Navigator.pop(ctx);
                        _applyFilters();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final state = ref.watch(orderProvider);
    final filteredOrders = state.filteredOrders;
    final isAnyFilterActive = _selectedStatus != null ||
        _selectedPaymentStatus != null ||
        _selectedDateRange != null ||
        _searchController.text.isNotEmpty;

    if (loginState.isGuest || !loginState.isLoggedIn) {
      return Scaffold(
        backgroundColor: context.vColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColor.primary,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          automaticallyImplyLeading: false,
          title: Text(
            'My Orders',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
              fontFamily: 'Inter',
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/empty-cart.svg',
                  width: 160.w,
                  height: 160.w,
                ),
                SizedBox(height: 28.h),
                Text(
                  'To view orders you must login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    color: context.vColors.onSurface,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Login or create an account to track and manage all your orders.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    color: context.vColors.onSurfaceMuted,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 28.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go(LVRoute.loginScreen.route),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.secondary,
                      foregroundColor: const Color(0xFF1A1A1A),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Login / Sign Up',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.vColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        title: Text(
          'My Orders',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            fontFamily: 'Inter',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.h),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
            child: Row(
              children: [
                Expanded(
                  child: PremiumSearchBar(
                    controller: _searchController,
                    hintText: 'Search orders...',
                    showScanIcon: false,
                    onChanged: (value) {
                      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                      ref.read(orderProvider.notifier).state =
                          state.copyWith(searchQuery: value);
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => _showFilterSheet(context),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: EdgeInsets.all(9.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.30)),
                        ),
                        child: Icon(Icons.tune_rounded,
                            color: Colors.white, size: 20.sp),
                      ),
                      if (isAnyFilterActive)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF5B237),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Orders List Area
          Expanded(
            child: state.isLoading
                ? const OrderListShimmer()
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
                          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w,
                              MediaQuery.of(context).padding.bottom + 150.h),
                          itemCount: filteredOrders.length +
                              (state.isLoadingMore || state.loadMoreFailed ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < filteredOrders.length) {
                              return OrderCard(order: filteredOrders[index]);
                            }
                            if (state.loadMoreFailed) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                child: Center(
                                  child: TextButton.icon(
                                    onPressed: () {
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
                                    },
                                    icon: Icon(Icons.refresh_rounded, size: 18.sp),
                                    label: Text('Retry', style: TextStyle(fontSize: 13.sp)),
                                    style: TextButton.styleFrom(foregroundColor: AppColor.primary),
                                  ),
                                ),
                              );
                            }
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.h),
                              child: Center(child: CircularProgressIndicator(color: AppColor.primary)),
                            );
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
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/empty-cart.svg',
                      width: 160.w,
                      height: 160.w,
                    ),
                    SizedBox(height: 28.h),
                    Text(
                      'No orders yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        color: context.vColors.onSurface,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Your orders will appear here once you place them.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        color: context.vColors.onSurfaceMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
