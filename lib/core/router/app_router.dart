// ignore_for_file: prefer_function_declarations_over_variables

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/features/auth/forget_password/forget_password_screen.dart';
import 'package:lets_vhandar/features/auth/forget_password/reset_password_screen.dart';
import 'package:lets_vhandar/features/auth/login/login_screen.dart';
import 'package:lets_vhandar/features/auth/otp/otp_screen.dart';
import 'package:lets_vhandar/features/auth/register/register_screen.dart';
import 'package:lets_vhandar/features/auth/v4B_register/v4B_register_screen.dart';
import 'package:lets_vhandar/features/dashboard/dashboard_screen.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';
import 'package:lets_vhandar/features/home/presentation/barcode_scanner_screen.dart';
import 'package:lets_vhandar/features/home/presentation/search_screen.dart';
import 'package:lets_vhandar/features/home/presentation/brand_detail_screen.dart';
import 'package:lets_vhandar/features/home/presentation/brand_screen.dart';
import 'package:lets_vhandar/features/home/presentation/category_detail_screen.dart';
import 'package:lets_vhandar/features/order/presentation/order_detail_screen.dart';
import 'package:lets_vhandar/features/address/presentation/address_screen.dart';
import 'package:lets_vhandar/features/product_detail/product_detail_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/about_us_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/change_password_screen.dart';
import 'package:lets_vhandar/widgets/generic_webview_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/faq_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/feedback_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/personal_information_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/product_suggestion_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/referral_screen.dart';
import 'package:lets_vhandar/features/splash/splash_screen.dart';
import 'package:lets_vhandar/features/cart/presentation/select_payment_method_screen.dart';
import 'package:lets_vhandar/features/kids_zone/presentation/kids_zone_screen.dart';

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
  productSuggestionScreen,
  resetPasswordScreen,
  changePasswordScreen,
  referAndEarnScreen,
  aboutUsScreen,
  blogScreen,
  contactUsScreen,
  careersScreen,
  barcodeScannerScreen,
  searchScreen,
  selectPaymentMethodScreen,
  helpSupportScreen,
  kidsZoneScreen;

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
            isResetPassword: extra['isResetPassword'] ?? false,
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
        path: LVRoute.resetPasswordScreen.route,
        name: LVRoute.resetPasswordScreen.route,
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ResetPasswordScreen(
            phoneNumber: extra['phoneNumber'] ?? '',
            phoneCode: extra['phoneCode'],
            otp: extra['otp'] ?? '',
          );
        },
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
      GoRoute(
        path: LVRoute.changePasswordScreen.route,
        name: LVRoute.changePasswordScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const ChangePasswordScreen(),
      ),
      GoRoute(
        path: LVRoute.referAndEarnScreen.route,
        name: LVRoute.referAndEarnScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const ReferAndEarnScreen(),
      ),
      GoRoute(
        path: LVRoute.aboutUsScreen.route,
        name: LVRoute.aboutUsScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const AboutUsScreen(),
      ),
      GoRoute(
        path: LVRoute.blogScreen.route,
        name: LVRoute.blogScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const GenericWebViewScreen(
          title: 'Blog',
          url: 'https://www.vhandar.com/blog',
        ),
      ),
      GoRoute(
        path: LVRoute.contactUsScreen.route,
        name: LVRoute.contactUsScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const GenericWebViewScreen(
          title: 'Contact Us',
          url: 'https://www.vhandar.com/contact',
        ),
      ),
      GoRoute(
        path: LVRoute.careersScreen.route,
        name: LVRoute.careersScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const GenericWebViewScreen(
          title: 'Careers',
          url: 'https://www.vhandar.com/careers',
        ),
      ),
      GoRoute(
        path: LVRoute.helpSupportScreen.route,
        name: LVRoute.helpSupportScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const GenericWebViewScreen(
          title: 'Help & Support',
          url: 'https://www.vhandar.com/help',
        ),
      ),
      GoRoute(
        path: LVRoute.barcodeScannerScreen.route,
        name: LVRoute.barcodeScannerScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const BarcodeScannerScreen(),
      ),
      GoRoute(
        path: LVRoute.searchScreen.route,
        name: LVRoute.searchScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const SearchScreen(),
      ),
      GoRoute(
        path: LVRoute.selectPaymentMethodScreen.route,
        name: LVRoute.selectPaymentMethodScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const SelectPaymentMethodScreen(),
      ),
      GoRoute(
        path: LVRoute.kidsZoneScreen.route,
        name: LVRoute.kidsZoneScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const KidsZoneScreen(),
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
