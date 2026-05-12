import 'package:get_it/get_it.dart';
import 'package:lets_vhandar/core/api/api_client.dart';
import 'package:lets_vhandar/core/api/dio_client.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/address/data/address_repository.dart';
import 'package:lets_vhandar/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lets_vhandar/features/home/data/repositories/banner_repository.dart';
import 'package:lets_vhandar/features/home/data/repositories/brand_repository.dart';
import 'package:lets_vhandar/features/home/data/repositories/category_repository.dart';
import 'package:lets_vhandar/features/home/data/repositories/general_settings_repository.dart';
import 'package:lets_vhandar/features/home/data/repositories/product_repository.dart';
import 'package:lets_vhandar/features/home/data/repositories/warehouse_repository.dart';
import 'package:lets_vhandar/features/order/data/order_repository.dart';
import 'package:vhandar/core/router/app_router.dart';

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

  if (!locator.isRegistered<BannerRepository>()) {
    locator.registerLazySingleton<BannerRepository>(
      () => BannerRepository(locator<ApiClient>()),
    );
  }

  if (!locator.isRegistered<CategoryRepository>()) {
    locator.registerLazySingleton<CategoryRepository>(
      () => CategoryRepository(locator<ApiClient>()),
    );
  }

  if (!locator.isRegistered<ProductRepository>()) {
    locator.registerLazySingleton<ProductRepository>(
      () => ProductRepository(locator<ApiClient>()),
    );
  }

  if (!locator.isRegistered<BrandRepository>()) {
    locator.registerLazySingleton<BrandRepository>(
      () => BrandRepository(locator<ApiClient>()),
    );
  }

  if (!locator.isRegistered<AddressRepository>()) {
    locator.registerLazySingleton<AddressRepository>(
      () => AddressRepository(locator<ApiClient>()),
    );
  }

  if (!locator.isRegistered<GeneralSettingsRepository>()) {
    locator.registerLazySingleton<GeneralSettingsRepository>(
      () => GeneralSettingsRepository(locator<ApiClient>()),
    );
  }

  if (!locator.isRegistered<WarehouseRepository>()) {
    locator.registerLazySingleton<WarehouseRepository>(
      () => WarehouseRepository(locator<ApiClient>()),
    );
  }

  if (!locator.isRegistered<OrderRepository>()) {
    locator.registerLazySingleton<OrderRepository>(
      () => OrderRepository(locator<ApiClient>()),
    );
  }
}
