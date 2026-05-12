import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhandar/core/utils/result.dart';
import 'package:vhandar/di/service_locator.dart';
import 'package:vhandar/features/home/data/repositories/warehouse_repository.dart';
import 'package:vhandar/features/home/domain/models/warehouse_model.dart';

final warehouseProvider = FutureProvider<List<Warehouse>>((ref) async {
  final repository = locator<WarehouseRepository>();
  final result = await repository.getWarehouses();

  switch (result) {
    case Success(value: final response):
      return response.data?.data ?? [];
    case Error(failure: final failure):
      throw failure;
  }
});
