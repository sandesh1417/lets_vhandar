import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/order/data/order_repository.dart';
import 'package:lets_vhandar/features/order/domain/models/order_model.dart';

final orderDetailProvider = FutureProvider.family<OrderData, String>((ref, id) async {
  final repo = locator<OrderRepository>();
  final result = await repo.getOrderById(id);

  switch (result) {
    case Success(value: final order):
      return order;
    case Error(failure: final failure):
      throw failure.message;
  }
});
