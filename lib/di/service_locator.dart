import 'package:get_it/get_it.dart';
import 'package:lets_vhandar/config/routing/app_router.dart';

GetIt locator = GetIt.I;
Future<void> setUpDependenciesInjection() async {
  locator.registerSingleton<LVGoRouter>(LVGoRouter());
}
