// ignore_for_file: prefer_function_declarations_over_variables

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/config/routing/fade_extension.dart';
import 'package:lets_vhandar/features/auth/forget_password/forget_password_screen.dart';
import 'package:lets_vhandar/features/auth/login/login_screen.dart';
import 'package:lets_vhandar/features/auth/otp/otp_screen.dart';
import 'package:lets_vhandar/features/auth/register/register_screen.dart';
import 'package:lets_vhandar/features/auth/v4B_register/v4B_register_screen.dart';
import 'package:lets_vhandar/features/splash/splash_screen.dart';

enum LVRoute {
  splashScreen,
  loginScreen,
  dashboardScreen,
  oTPScreen,
  forgetPasswordScreen,
  registerScreen,
  v4BRegistrationScreen;

  // String get route => '/${toString().replaceAll('LVRoute.', '')}';
  String get route => '/${toString().replaceAll('LVRoute.', '')}';
  // String get name => toString().replaceAll('LVRoute.', '');
}

class LVGoRouter {
  final GoRouter goRoute = GoRouter(
    initialLocation: LVRoute.loginScreen.route,
    routes: <GoRoute>[
      GoRoute(
        path: LVRoute.splashScreen.route,
        builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
      ).fade(),
      GoRoute(
        path: LVRoute.loginScreen.route,
        builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
      ).fade(),
      GoRoute(
        path: LVRoute.oTPScreen.route,
        name: LVRoute.oTPScreen.route,
        builder: (BuildContext context, GoRouterState state) => const OTPScreen(),
      ).fade(),
      GoRoute(
        path: LVRoute.forgetPasswordScreen.route,
        name: LVRoute.forgetPasswordScreen.route,
        builder: (BuildContext context, GoRouterState state) => const ForgetPasswordScreen(),
      ).fade(),
      GoRoute(
        path: LVRoute.registerScreen.route,
        name: LVRoute.registerScreen.route,
        builder: (BuildContext context, GoRouterState state) => const RegisterScreen(),
      ).fade(),
      GoRoute(
        path: LVRoute.v4BRegistrationScreen.route,
        name: LVRoute.v4BRegistrationScreen.route,
        builder: (BuildContext context, GoRouterState state) => const V4BRegistrationScreen(),
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
