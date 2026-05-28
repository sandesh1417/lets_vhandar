import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/home/data/repositories/time_slot_repository.dart';
import 'package:lets_vhandar/features/home/domain/models/time_slot_model.dart';

final timeSlotProvider = FutureProvider<List<TimeSlot>>((ref) async {
  final result = await locator<TimeSlotRepository>().getTimeSlots();
  switch (result) {
    case Success(value: final response):
      return response.data?.data ?? [];
    case Error(failure: final failure):
      throw failure;
  }
});
