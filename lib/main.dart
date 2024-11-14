import 'package:flutter/material.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/my_app.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUpDependenciesInjection();
  runApp(const MyApp());
}
