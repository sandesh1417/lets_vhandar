import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhandar/di/service_locator.dart';
import 'package:vhandar/my_app.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUpDependenciesInjection();
  runApp(const ProviderScope(child: MyApp()));
}
