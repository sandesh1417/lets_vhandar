import 'package:lets_vhandar/core/api/api_client.dart';
import 'package:lets_vhandar/core/config/api_endpoints.dart';
import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/features/order/domain/models/order_model.dart';

class OrderRepository {
  final ApiClient _apiClient;

  OrderRepository(this._apiClient);

  Future<Result<OrderData, Failure>> placeOrder(
      Map<String, dynamic> body) async {
    final result = await _apiClient.post(ApiUrl.orders, data: body);

    switch (result) {
      case Success(value: final data):
        final response = PlaceOrderResponse.fromMap(data);
        if (response.data == null) {
          return Error(
              ServerFailure("Order placed but server response data is empty"));
        }
        return Success(response.data!);
      case Error(failure: final failure):
        return Error(failure);
    }
  }

  Future<Result<OrderListResponse, Failure>> getOrders({
    required String userId,
    int page = 1,
    int limit = 5,
    String? paymentStatus,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
      'userId': userId,
    };
    if (paymentStatus != null && paymentStatus.isNotEmpty) {
      params['paymentStatus'] = paymentStatus.toLowerCase();
    }
    if (status != null && status.isNotEmpty) {
      params['status'] = status.toLowerCase();
    }
    if (startDate != null && startDate.isNotEmpty) {
      params['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      params['endDate'] = endDate;
    }

    final result = await _apiClient.get(
      ApiUrl.ordersSearch,
      queryParameters: params,
    );

    switch (result) {
      case Success(value: final data):
        return Success(OrderListResponse.fromMap(data));
      case Error(failure: final failure):
        return Error(failure);
    }
  }

  Future<Result<OrderData, Failure>> getOrderById(String id) async {
    final result = await _apiClient.get(ApiUrl.orderDetail(id));

    switch (result) {
      case Success(value: final data):
        final response = PlaceOrderResponse.fromMap(data);
        if (response.data == null) {
          return Error(ServerFailure("Order detail data is empty"));
        }
        return Success(response.data!);
      case Error(failure: final failure):
        return Error(failure);
    }
  }
}
