// ignore_for_file: prefer_function_declarations_over_variables

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/config/routing/fade_extension.dart';
import 'package:lets_vhandar/features/auth/login/login_screen.dart';
import 'package:lets_vhandar/features/auth/otp/otp_screen.dart';
import 'package:lets_vhandar/features/splash/splash_screen.dart';

enum LVRoute {
  splash,
  login,
  dashboard,
  otp;

  // String get route => '/${toString().replaceAll('LVRoute.', '')}';
  String get route => '/${toString().replaceAll('LVRoute.', '')}';
  // String get name => toString().replaceAll('LVRoute.', '');
}

class LVGoRouter {
  final GoRouter goRoute = GoRouter(
    initialLocation: LVRoute.login.route,
    routes: <GoRoute>[
      GoRoute(
        path: LVRoute.splash.route,
        // name: LVRoute.splash.name,
        builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
      ).fade(),
      GoRoute(
        path: LVRoute.login.route,
        // name: LVRoute.login.name,
        builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
      ).fade(),
      GoRoute(
        path: LVRoute.otp.route, // This will be '/otp'
        name: LVRoute.otp.route, // This will be '/otp'
        // name: '/otp', // This will be 'otp'
        builder: (BuildContext context, GoRouterState state) => const OTPScreen(),
      ).fade(),
    ],
  );
  GoRouter get getGoRouter => goRoute;
}


// final String? Function(BuildContext context, GoRouterState state) _authGuard = (BuildContext context, GoRouterState state) {
//   if (!(getStoreHelper.getToken() != null)) {
//     return LVRoute.login.route;
//   }
//   return null;
// };
