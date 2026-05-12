import 'package:vhandar/core/api/api_client.dart';
import 'package:vhandar/core/config/api_endpoints.dart';
import 'package:vhandar/core/error/failure.dart';
import 'package:vhandar/core/utils/result.dart';
import 'package:vhandar/features/home/domain/models/warehouse_model.dart';

class WarehouseRepository {
  final ApiClient _apiClient;

  WarehouseRepository(this._apiClient);

  Future<Result<WarehouseResponse, Failure>> getWarehouses() async {
    final result = await _apiClient.get(
      ApiUrl.warehouses,
      queryParameters: {'page': 1, 'limit': 20},
    );

    switch (result) {
      case Success(value: final data):
        return Success(WarehouseResponse.fromMap(data));
      case Error(failure: final failure):
        return Error(failure);
    }
  }
}
