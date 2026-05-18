import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    // Keep splash for 200 seconds for branding inspection
    await Future.delayed(const Duration(seconds: 5));

    if (token != null && token.isNotEmpty) {
      if (mounted) context.pushReplacement(LVRoute.dashboardScreen.route);
    } else {
      if (mounted) context.pushReplacement(LVRoute.loginScreen.route);
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
                  Image.asset(
                    KImageConstant.vandharLogo,
                    width: 130.w,
                    height: 130.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 10.h),
                  // Thick white custom brand header text matching Volte font & styling exactly
                  Text(
                    'Vhandar', // Spelled all-lowercase to match the photo exactly!
                    style: TextStyle(
                      fontFamily: 'Volte',
                      fontSize: 52.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing:
                          -1.8, // Tight letter spacing to replicate logo styling
                      height: 1.0,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.18),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Subtitle tagline styled precisely in Volte font and secondary brand color
                  Text(
                    'Fastest Grocery Delivery',
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
                    'Version 1.0.0',
                    style: TextStyle(
                      fontFamily: 'Volte',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Volte',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                      children: [
                        const TextSpan(text: 'Developed by '),
                        TextSpan(
                          text: 'Vhandar Pvt. Ltd.',
                          style: TextStyle(
                            fontFamily: 'Volte',
                            color: AppColor
                                .secondary, // Matches brand secondary color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
