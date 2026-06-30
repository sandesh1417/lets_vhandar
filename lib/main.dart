import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/services/notification_service.dart';
import 'package:lets_vhandar/core/services/update_service.dart';
import 'package:lets_vhandar/core/utils/age_verification.dart';
import 'package:lets_vhandar/core/utils/app_info.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/firebase_options.dart';
import 'package:lets_vhandar/my_app.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (Google Maps/Places API key, etc.)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env missing — Places search will fall back to empty key handling.
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  setUpDependenciesInjection();

  await AppInfo.initialize();
  // Age-gate for alcohol/tobacco is asked at most once per session — clear the
  // flag on every cold start so a fresh launch re-asks before the first
  // restricted item is added to the cart.
  await AgeVerification.resetForColdStart();
  await NotificationService.instance.initialize();
  await UpdateService.instance.initialize();

  runApp(const ProviderScope(child: MyApp()));
}
