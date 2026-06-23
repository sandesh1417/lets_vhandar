// ignore_for_file: prefer_function_declarations_over_variables

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:lets_vhandar/core/constants/r_session.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:lets_vhandar/features/address/presentation/add_address_screen.dart';
import 'package:lets_vhandar/features/address/domain/models/address_model.dart';
import 'package:lets_vhandar/features/product_detail/product_detail_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/about_us_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/change_password_screen.dart';
import 'package:lets_vhandar/widgets/generic_webview_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/faq_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/feedback_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/edit_profile_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/personal_information_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/product_suggestion_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/referral_screen.dart';
import 'package:lets_vhandar/features/splash/splash_screen.dart';
import 'package:lets_vhandar/features/cart/cart_screen.dart';
import 'package:lets_vhandar/features/cart/presentation/select_payment_method_screen.dart';
import 'package:lets_vhandar/features/kids_zone/presentation/kids_zone_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/vhandar_points_screen.dart';
import 'package:lets_vhandar/features/my_list/presentation/my_lists_screen.dart';
import 'package:lets_vhandar/features/my_list/presentation/list_detail_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/family_members_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/wallet_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/help_support_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/vhandar_for_business_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/about_vhandar_screen.dart';
import 'package:lets_vhandar/features/profile/presentation/coupon_screen.dart';
import 'package:lets_vhandar/features/home/presentation/featured_products_screen.dart';

/// Subtle fade + slide-up transition used for all main navigable routes.
CustomTransitionPage<void> _slideFadePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(fade);
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

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
  kidsZoneScreen,
  cartScreen,
  vhandarPointsScreen,
  myListsScreen,
  listDetailScreen,
  familyMembersScreen,
  walletScreen,
  couponScreen,
  vhandarForBusinessScreen,
  aboutVhandarScreen,
  editProfileScreen,
  privacyPolicyScreen,
  termsScreen,
  featuredProductsScreen,
  addAddressScreen;

  String get route => '/${toString().replaceAll('LVRoute.', '')}';
}

const _publicRoutes = {
  '/splashScreen',
  '/loginScreen',
  '/registerScreen',
  '/oTPScreen',
  '/forgetPasswordScreen',
  '/resetPasswordScreen',
  '/v4BRegistrationScreen',
};

class LVGoRouter {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter goRoute = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: LVRoute.splashScreen.route,
    debugLogDiagnostics: kDebugMode,
    errorBuilder: (context, state) => _RouterErrorPage(error: state.error),
    redirect: (context, state) {
      final isAuthenticated = Rsession.token != null || Rsession.isGuest;
      final isPublic = _publicRoutes.contains(state.matchedLocation);
      if (!isAuthenticated && !isPublic) {
        return LVRoute.loginScreen.route;
      }
      return null;
    },
    routes: <GoRoute>[
      GoRoute(
        path: LVRoute.splashScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: LVRoute.loginScreen.route,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>?;
          return _slideFadePage(
            state: state,
            child: LoginScreen(fromCheckout: extra?['fromCheckout'] == true),
          );
        },
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
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _slideFadePage(state: state, child: const DashboardScreen()),
      ),
      GoRoute(
        path: LVRoute.productDetailScreen.route,
        name: LVRoute.productDetailScreen.route,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final product = state.extra as ProductData;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProductDetailScreen(product: product),
            transitionDuration: const Duration(milliseconds: 350),
            reverseTransitionDuration: const Duration(milliseconds: 280),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/category-detail/:slug',
        name: 'categoryDetailScreen',
        pageBuilder: (BuildContext context, GoRouterState state) {
          final slug = state.pathParameters['slug']!;
          final extra = state.extra as Map<String, dynamic>?;
          final initialSubSlug = extra?['initialSubSlug'] as String?;
          return _slideFadePage(
            state: state,
            child: CategoryDetailScreen(
                categorySlug: slug, initialSubCategorySlug: initialSubSlug),
          );
        },
      ),
      GoRoute(
        path: '/brands',
        name: 'brandScreen',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _slideFadePage(state: state, child: const BrandScreen()),
      ),
      GoRoute(
        path: '/brand-detail/:slug',
        name: 'brandDetailScreen',
        pageBuilder: (BuildContext context, GoRouterState state) {
          final slug = state.pathParameters['slug']!;
          return _slideFadePage(
              state: state, child: BrandDetailScreen(brandSlug: slug));
        },
      ),
      GoRoute(
        path: '/order-detail/:id',
        name: 'orderDetailScreen',
        pageBuilder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id']!;
          return _slideFadePage(
              state: state, child: OrderDetailScreen(orderId: id));
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
        path: LVRoute.addAddressScreen.route,
        name: LVRoute.addAddressScreen.route,
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return AddAddressScreen(
            userId: extra['userId'] as String? ?? '',
            existingAddress: extra['existingAddress'] as AddressModel?,
          );
        },
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
            const HelpSupportScreen(),
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
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _slideFadePage(state: state, child: const SearchScreen()),
      ),
      GoRoute(
        path: LVRoute.selectPaymentMethodScreen.route,
        name: LVRoute.selectPaymentMethodScreen.route,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _slideFadePage(
          state: state,
          child: const SelectPaymentMethodScreen(),
        ),
      ),
      GoRoute(
        path: LVRoute.kidsZoneScreen.route,
        name: LVRoute.kidsZoneScreen.route,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _slideFadePage(state: state, child: const KidsZoneScreen()),
      ),
      GoRoute(
        path: LVRoute.cartScreen.route,
        name: LVRoute.cartScreen.route,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _slideFadePage(state: state, child: const CartScreen()),
      ),
      GoRoute(
        path: LVRoute.vhandarPointsScreen.route,
        name: LVRoute.vhandarPointsScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const VhandarPointsScreen(),
      ),
      GoRoute(
        path: LVRoute.myListsScreen.route,
        name: LVRoute.myListsScreen.route,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _slideFadePage(state: state, child: const MyListsScreen()),
      ),
      GoRoute(
        path: LVRoute.listDetailScreen.route,
        name: LVRoute.listDetailScreen.route,
        builder: (BuildContext context, GoRouterState state) {
          final listId = state.extra as String;
          return ListDetailScreen(listId: listId);
        },
      ),
      GoRoute(
        path: LVRoute.familyMembersScreen.route,
        name: LVRoute.familyMembersScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const FamilyMembersScreen(),
      ),
      GoRoute(
        path: LVRoute.walletScreen.route,
        name: LVRoute.walletScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const WalletScreen(),
      ),
      GoRoute(
        path: LVRoute.couponScreen.route,
        name: LVRoute.couponScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const CouponScreen(),
      ),
      GoRoute(
        path: LVRoute.vhandarForBusinessScreen.route,
        name: LVRoute.vhandarForBusinessScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const VhandarForBusinessScreen(),
      ),
      GoRoute(
        path: LVRoute.aboutVhandarScreen.route,
        name: LVRoute.aboutVhandarScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const AboutVhandarScreen(),
      ),
      GoRoute(
        path: LVRoute.editProfileScreen.route,
        name: LVRoute.editProfileScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const EditProfileScreen(),
      ),
      GoRoute(
        path: LVRoute.privacyPolicyScreen.route,
        name: LVRoute.privacyPolicyScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const GenericWebViewScreen(
          title: 'Privacy Policy',
          url: 'https://www.vhandar.com/privacy-policy',
        ),
      ),
      GoRoute(
        path: LVRoute.termsScreen.route,
        name: LVRoute.termsScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const GenericWebViewScreen(
          title: 'Terms & Conditions',
          url: 'https://www.vhandar.com/terms-and-conditions',
        ),
      ),
      GoRoute(
        path: LVRoute.featuredProductsScreen.route,
        name: LVRoute.featuredProductsScreen.route,
        builder: (BuildContext context, GoRouterState state) =>
            const FeaturedProductsScreen(),
      ),
      // Add other routes as they are implemented
    ],
  );
  GoRouter get getGoRouter => goRoute;
}

class _RouterErrorPage extends StatelessWidget {
  final Exception? error;
  const _RouterErrorPage({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 64.sp, color: Colors.red.shade300),
              SizedBox(height: 16.h),
              Text(
                'Page not found',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                kDebugMode
                    ? (error?.toString() ?? '')
                    : 'Something went wrong.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey),
              ),
              SizedBox(height: 24.h),
              CustomElevatedButton(
                onPressed: () => context.go(LVRoute.dashboardScreen.route),
                icon: Icons.home_rounded,
                text: 'Go Home',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
