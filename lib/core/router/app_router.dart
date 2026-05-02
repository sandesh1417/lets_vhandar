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
import 'package:lets_vhandar/features/home/presentation/brand_detail_screen.dart';
import 'package:lets_vhandar/features/home/presentation/brand_screen.dart';
import 'package:lets_vhandar/features/home/presentation/category_detail_screen.dart';
import 'package:lets_vhandar/features/order/presentation/order_detail_screen.dart';
import 'package:lets_vhandar/features/address/presentation/address_screen.dart';
import 'package:lets_vhandar/features/product_detail/product_detail_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/faq_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/feedback_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/personal_information_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/product_suggestion_screen.dart';
import 'package:lets_vhandar/features/splash/splash_screen.dart';

enum LVRoute {
  splashScreen,
  loginScreen,
  dashboardScreen,
  oTPScreen,
  forgetPasswordScreen,
  registerScreen,
  v4BRegistrationScreen,
  productDetailScreen,
  categoryDetailScreen,
  orderDetailScreen,
  feedbackScreen,
  faqScreen,
  savedAddressesScreen,
  personalInformationScreen,
  productSuggestionScreen;

  String get route => '/${toString().replaceAll('LVRoute.', '')}';
}

class LVGoRouter {
  final GoRouter goRoute = GoRouter(
    initialLocation: LVRoute.splashScreen.route,
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
      GoRoute(
        path: '/category-detail/:slug',
        name: 'categoryDetailScreen',
        builder: (BuildContext context, GoRouterState state) {
          final slug = state.pathParameters['slug']!;
          return CategoryDetailScreen(categorySlug: slug);
        },
      ),
      GoRoute(
        path: '/brands',
        name: 'brandScreen',
        builder: (BuildContext context, GoRouterState state) =>
            const BrandScreen(),
      ),
      GoRoute(
        path: '/brand-detail/:slug',
        name: 'brandDetailScreen',
        builder: (BuildContext context, GoRouterState state) {
          final slug = state.pathParameters['slug']!;
          return BrandDetailScreen(brandSlug: slug);
        },
      ),
      GoRoute(
        path: '/order-detail/:id',
        name: 'orderDetailScreen',
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id']!;
          return OrderDetailScreen(orderId: id);
        },
      ),
      GoRoute(
        path: LVRoute.feedbackScreen.route,
        name: LVRoute.feedbackScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const FeedbackScreen(),
      ),
      GoRoute(
        path: LVRoute.faqScreen.route,
        name: LVRoute.faqScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const FAQScreen(),
      ),
      GoRoute(
        path: LVRoute.savedAddressesScreen.route,
        name: LVRoute.savedAddressesScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const AddressScreen(),
      ),
      GoRoute(
        path: LVRoute.personalInformationScreen.route,
        name: LVRoute.personalInformationScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const PersonalInformationScreen(),
      ),
      GoRoute(
        path: LVRoute.productSuggestionScreen.route,
        name: LVRoute.productSuggestionScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const ProductSuggestionScreen(),
      ),
      // Add other routes as they are implemented
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
