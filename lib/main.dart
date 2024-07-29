import 'package:flutter/material.dart';
import 'package:lets_vhandar/features/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(10, 117, 78, 1)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
