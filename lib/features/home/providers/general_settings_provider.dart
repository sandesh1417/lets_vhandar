import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/home/data/repositories/general_settings_repository.dart';
import 'package:lets_vhandar/features/home/domain/models/general_settings_model.dart';

final generalSettingsProvider = FutureProvider<GeneralSettings?>((ref) async {
  final repository = locator<GeneralSettingsRepository>();
  final result = await repository.getGeneralSettings();

  switch (result) {
    case Success(value: final response):
      return response.data?.isNotEmpty == true ? response.data!.first : null;
    case Error(failure: final failure):
      throw failure;
  }
});
