import 'package:vhandar/core/api/api_client.dart';
import 'package:vhandar/core/config/api_endpoints.dart';
import 'package:vhandar/core/error/failure.dart';
import 'package:vhandar/core/utils/result.dart';
import 'package:vhandar/features/home/domain/models/general_settings_model.dart';

class GeneralSettingsRepository {
  final ApiClient _apiClient;

  GeneralSettingsRepository(this._apiClient);

  Future<Result<GeneralSettingsResponse, Failure>> getGeneralSettings() async {
    final result = await _apiClient.get(
      ApiUrl.generalSettings,
      queryParameters: {'page': 1, 'limit': 1000},
    );

    switch (result) {
      case Success(value: final data):
        return Success(GeneralSettingsResponse.fromMap(data));
      case Error(failure: final failure):
        return Error(failure);
    }
  }
}
