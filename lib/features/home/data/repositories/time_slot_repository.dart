import 'package:lets_vhandar/core/api/api_client.dart';
import 'package:lets_vhandar/core/config/api_endpoints.dart';
import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/features/home/domain/models/time_slot_model.dart';

class TimeSlotRepository {
  final ApiClient _apiClient;

  TimeSlotRepository(this._apiClient);

  Future<Result<TimeSlotResponse, Failure>> getTimeSlots() async {
    final result = await _apiClient.get(ApiUrl.timeSlots);

    switch (result) {
      case Success(value: final data):
        return Success(TimeSlotResponse.fromMap(data));
      case Error(failure: final failure):
        return Error(failure);
    }
  }
}
