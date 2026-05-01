import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/local/shared_preferences_services.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Restore session data (token + user) into the login provider
    await ref.read(loginProvider.notifier).restoreSession();

    final token = await SessionPrefences().getToken();
    // Keep splash for at least 2 seconds for branding
    await Future.delayed(const Duration(seconds: 1));

    if (token != null && token.isNotEmpty) {
      if (mounted) context.pushReplacement(LVRoute.dashboardScreen.route);
    } else {
      if (mounted) context.pushReplacement(LVRoute.loginScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.primary,
      child: Image.asset(KImageConstant.splashScreen),
    );
  }
}
