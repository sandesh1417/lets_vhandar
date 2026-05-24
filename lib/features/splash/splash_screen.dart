import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSession());
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    super.dispose();
  }

  Future<void> _checkSession() async {
    await ref.read(loginProvider.notifier).restoreSession();
    final token = await SessionPrefences().getToken();
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      context.go(LVRoute.dashboardScreen.route);
    } else {
      context.go(LVRoute.loginScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.4),
            radius: 1.3,
            colors: [
              const Color(0xFF14A26F), // Radiant glowing center
              AppColor.primary, // Official brand primary: Color(0xFF0A754E)
            ],
          ),
        ),
        child: Stack(
          children: [
            // Center Logo and Branding Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Clean, non-stretched "V" Logo from assets
                  SvgPicture.asset(
                    KImageConstant.splashScreen,
                    width: 180.w,
                    height: 180.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 10.h),
                 
                  SizedBox(height: 9.h),
                  // Subtitle tagline styled precisely in Volte font and secondary brand color
                  Text(
                    'Fastest Grocery Delivery App',
                    style: TextStyle(
                      fontFamily: 'Volte',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColor
                          .secondary, // Official brand secondary: Color(0xFFF5B237)
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Version & Developer Copyright Info
            Positioned(
              bottom: 32.h,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Vhandar Merchandise Pvt Ltd',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '1.0.0',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
