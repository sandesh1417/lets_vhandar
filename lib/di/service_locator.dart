import 'package:get_it/get_it.dart';
import 'package:lets_vhandar/config/routing/app_router.dart';

GetIt locator = GetIt.I;
void setUpDependenciesInjection() {
  if (!locator.isRegistered<LVGoRouter>()) {
    locator.registerLazySingleton<LVGoRouter>(() => LVGoRouter());
  }
}
