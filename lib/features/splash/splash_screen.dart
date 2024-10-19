import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/utils/navigator_services.dart';
import 'package:lets_vhandar/features/auth/login/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      navigateAndPushReplacement(context: context, screen: const LoginScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.primary,
      child: Image.asset(KImageConstant.splashScreen),
    );
  }
}
