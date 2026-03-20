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

  const OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isPlacingOrder = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
  });

  OrderState copyWith({
    List<OrderData>? orders,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isPlacingOrder,
    String? error,
    bool clearError = false,
    int? currentPage,
    int? totalPages,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

// ─── Order Notifier ───────────────────────────────────────────────────────────

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository _repo;

  OrderNotifier(this._repo) : super(const OrderState());

  Future<void> loadOrders(String userId, {int page = 1}) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, clearError: true, orders: []);
    } else {
      state = state.copyWith(isLoadingMore: true, clearError: true);
    }

    final result = await _repo.getOrders(userId: userId, page: page);

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
      'appliedCouponCode': '',
      'dueAmount': 0,
      'cartId': cartId,
      'products': products,
      'deliveryTime': '',
      'paymentMethod': paymentMethod,
      'totalSavedAmount': 0,
      'couponDiscount': 0,
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
