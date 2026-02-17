import 'package:get_it/get_it.dart';
import 'package:lets_vhandar/core/api/api_client.dart';
import 'package:lets_vhandar/core/api/dio_client.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:lets_vhandar/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lets_vhandar/features/auth/domain/repositories/auth_repository.dart';

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

  // Auth Dependencies
  if (!locator.isRegistered<AuthRemoteDataSource>()) {
    locator.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(locator<ApiClient>()),
    );
  }

  if (!locator.isRegistered<AuthRepository>()) {
    locator.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(locator<AuthRemoteDataSource>()),
    );
  }
}
