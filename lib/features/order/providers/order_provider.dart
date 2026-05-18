import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/order/data/order_repository.dart';
import 'package:lets_vhandar/features/order/domain/models/order_model.dart';

// ─── Order List State ─────────────────────────────────────────────────────────

class OrderState {
  final List<OrderData> orders;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isPlacingOrder;
  final String? error;
  final int currentPage;
  final int totalPages;

  // Filter States
  final String? paymentStatus;
  final String? status;
  final String? startDate;
  final String? endDate;
  final String? searchQuery;

  const OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isPlacingOrder = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.paymentStatus,
    this.status,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  // Client-side search helper over order ID and product names
  List<OrderData> get filteredOrders {
    if (searchQuery == null || searchQuery!.trim().isEmpty) {
      return orders;
    }
    final query = searchQuery!.trim().toLowerCase();
    return orders.where((order) {
      final matchesOrderId = order.orderId?.toLowerCase().contains(query) ?? false;
      final matchesProduct = order.products?.any((prod) => prod.name?.toLowerCase().contains(query) ?? false) ?? false;
      return matchesOrderId || matchesProduct;
    }).toList();
  }

  OrderState copyWith({
    List<OrderData>? orders,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isPlacingOrder,
    String? error,
    bool clearError = false,
    int? currentPage,
    int? totalPages,
    String? paymentStatus,
    String? status,
    String? startDate,
    String? endDate,
    String? searchQuery,
    bool clearFilters = false,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      paymentStatus: clearFilters ? null : (paymentStatus ?? this.paymentStatus),
      status: clearFilters ? null : (status ?? this.status),
      startDate: clearFilters ? null : (startDate ?? this.startDate),
      endDate: clearFilters ? null : (endDate ?? this.endDate),
      searchQuery: clearFilters ? null : (searchQuery ?? this.searchQuery),
    );
  }
}

// ─── Order Notifier ───────────────────────────────────────────────────────────

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository _repo;

  OrderNotifier(this._repo) : super(const OrderState());

  Future<void> loadOrders(
    String userId, {
    int page = 1,
    String? paymentStatus,
    String? status,
    String? startDate,
    String? endDate,
    String? searchQuery,
    bool clearFilters = false,
  }) async {
    if (page == 1) {
      state = state.copyWith(
        isLoading: true,
        clearError: true,
        orders: [],
        paymentStatus: paymentStatus,
        status: status,
        startDate: startDate,
        endDate: endDate,
        searchQuery: searchQuery,
        clearFilters: clearFilters,
      );
    } else {
      state = state.copyWith(isLoadingMore: true, clearError: true);
    }

    final activePaymentStatus = page == 1 ? paymentStatus : state.paymentStatus;
    final activeStatus = page == 1 ? status : state.status;
    final activeStartDate = page == 1 ? startDate : state.startDate;
    final activeEndDate = page == 1 ? endDate : state.endDate;

    final result = await _repo.getOrders(
      userId: userId,
      page: page,
      paymentStatus: activePaymentStatus,
      status: activeStatus,
      startDate: activeStartDate,
      endDate: activeEndDate,
    );

    switch (result) {
      case Success(value: final response):
        final newOrders = response.data?.data ?? [];
        final total = response.data?.pagination?.total?.toInt() ?? 0;
        const limit = 5;
        final totalPages = (total / limit).ceil().clamp(1, 9999);
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          orders: page == 1 ? newOrders : [...state.orders, ...newOrders],
          currentPage: page,
          totalPages: totalPages,
        );
      case Error(failure: final failure):
        state = state.copyWith(
            isLoading: false, isLoadingMore: false, error: failure.message);
    }
  }

  Future<bool> placeOrder({
    required String userId,
    required List<Map<String, dynamic>> products,
    required double totalAmount,
    required double totalDiscount,
    required double totalVatAmount,
    required double totalPayableAmount,
    required double handlingCharge,
    required double deliveryCharge,
    required String cartId,
    required Map<String, dynamic> location,
    String paymentMethod = 'cashOnDelivery',
    String appliedCouponCode = '',
    double couponDiscount = 0,
  }) async {
    state = state.copyWith(isPlacingOrder: true, clearError: true);

    final body = {
      'totalAmount': totalAmount,
      'totalDiscount': totalDiscount,
      'totalVatAmount': totalVatAmount,
      'totalPayableAmount': totalPayableAmount,
      'handlingCharge': handlingCharge,
      'deliveryCharge': deliveryCharge,
      'paymentStatus': 'pending',
      'userId': userId,
      'appliedCouponCode': appliedCouponCode,
      'dueAmount': 0,
      'cartId': cartId,
      'products': products,
      'deliveryTime': '',
      'paymentMethod': paymentMethod,
      'totalSavedAmount': 0,
      'couponDiscount': couponDiscount,
      'deliveryTimeSlot': null,
      'location': location,
    };

    final result = await _repo.placeOrder(body);

    switch (result) {
      case Success():
        state = state.copyWith(isPlacingOrder: false);
        // Refetch orders after placing
        await loadOrders(userId);
        return true;
      case Error(failure: final failure):
        state = state.copyWith(isPlacingOrder: false, error: failure.message);
        return false;
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier(locator<OrderRepository>());
});
