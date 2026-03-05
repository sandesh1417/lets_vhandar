// ignore_for_file: prefer_function_declarations_over_variables

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/features/auth/forget_password/forget_password_screen.dart';
import 'package:lets_vhandar/features/auth/login/login_screen.dart';
import 'package:lets_vhandar/features/auth/otp/otp_screen.dart';
import 'package:lets_vhandar/features/auth/register/register_screen.dart';
import 'package:lets_vhandar/features/auth/v4B_register/v4B_register_screen.dart';
import 'package:lets_vhandar/features/dashboard/dashboard_screen.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/product_detail/product_detail_screen.dart';
import 'package:lets_vhandar/features/splash/splash_screen.dart';

enum LVRoute {
  splashScreen,
  loginScreen,
  dashboardScreen,
  oTPScreen,
  forgetPasswordScreen,
  registerScreen,
  v4BRegistrationScreen,
  productDetailScreen;

  String get route => '/${toString().replaceAll('LVRoute.', '')}';
}

class LVGoRouter {
  final GoRouter goRoute = GoRouter(
    initialLocation: LVRoute.dashboardScreen.route,
    debugLogDiagnostics: true, // Enable debugging
    routes: <GoRoute>[
      GoRoute(
        path: LVRoute.splashScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: LVRoute.loginScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      // GoRoute(
      //   path: LVRoute.oTPScreen.route,
      //   name: LVRoute.oTPScreen.route,
      //   builder: (BuildContext context, GoRouterState state) => const OTPScreen(phoneNumber: '',),
      // ),
      GoRoute(
        path: LVRoute.oTPScreen.route,
        name: LVRoute.oTPScreen.route,
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};

          return OTPScreen(
            phoneNumber: extra['phoneNumber'] ?? '',
            phoneCode: extra['phoneCode'],
            name: extra['name'] ?? '',
            referalCode: extra['referalCode'] ?? '',
            password: extra['password'] ?? '',
            confirmPassword: extra['confirmPassword'] ?? '',
          );
        },
      ),
      GoRoute(
        path: LVRoute.forgetPasswordScreen.route,
        name: LVRoute.forgetPasswordScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const ForgetPasswordScreen(),
      ),
      GoRoute(
        path: LVRoute.registerScreen.route,
        name: LVRoute.registerScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const RegisterScreen(),
      ),
      GoRoute(
        path: LVRoute.v4BRegistrationScreen.route,
        name: LVRoute.v4BRegistrationScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const V4BRegistrationScreen(),
      ),
      GoRoute(
        path: LVRoute.dashboardScreen.route,
        name: LVRoute.dashboardScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const DashboardScreen(),
      ),
      GoRoute(
        path: LVRoute.productDetailScreen.route,
        name: LVRoute.productDetailScreen.route,
        builder: (BuildContext context, GoRouterState state) {
          final product = state.extra as ProductData;
          return ProductDetailScreen(product: product);
        },
      ),
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
