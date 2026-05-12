import 'package:vhandar/core/api/api_client.dart';
import 'package:vhandar/core/config/api_endpoints.dart';
import 'package:vhandar/core/error/failure.dart';
import 'package:vhandar/core/utils/result.dart';
import 'package:vhandar/features/order/domain/models/order_model.dart';

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
  }) async {
    final result = await _apiClient.get(
      ApiUrl.ordersSearch,
      queryParameters: {'page': page, 'limit': limit, 'userId': userId},
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
