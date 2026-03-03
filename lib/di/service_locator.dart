import 'package:get_it/get_it.dart';
import 'package:lets_vhandar/core/api/api_client.dart';
import 'package:lets_vhandar/core/api/dio_client.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/auth/data/repositories/auth_repository_impl.dart';

GetIt locator = GetIt.I;
void setUpDependenciesInjection() {
  if (!locator.isRegistered<LVGoRouter>()) {
    locator.registerLazySingleton<LVGoRouter>(() => LVGoRouter());
  }

  if (!locator.isRegistered<DioClient>()) {
    locator.registerLazySingleton<DioClient>(() => DioClient());
  }

  if (!locator.isRegistered<ApiClient>()) {
    locator.registerLazySingleton<ApiClient>(
        () => ApiClient(locator<DioClient>()));
  }

  if (!locator.isRegistered<AuthRepositoryImpl>()) {
    locator.registerLazySingleton<AuthRepositoryImpl>(
      () => AuthRepositoryImpl(locator<ApiClient>()),
    );
  }
}
