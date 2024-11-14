// ignore_for_file: prefer_function_declarations_over_variables

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/features/auth/login/login_screen.dart';
import 'package:lets_vhandar/features/splash/splash_screen.dart';

import 'fade_extension.dart';

enum LVRoute {
  splash,
  login,
  dashboard;

  String get route => '/${toString().replaceAll('LVRoute.', '')}';
  String get name => toString().replaceAll('LVRoute.', '');
}

class LVGoRouter {
  final GoRouter goRoute = GoRouter(
    initialLocation: LVRoute.splash.route,
    routes: <GoRoute>[
      GoRoute(
        path: LVRoute.splash.route,
        name: LVRoute.splash.route,
        builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
      ).fade(),
      GoRoute(
        path: LVRoute.login.route,
        name: LVRoute.login.route,
        builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
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
