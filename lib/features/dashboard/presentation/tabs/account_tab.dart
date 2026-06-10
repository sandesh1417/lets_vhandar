import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/auth/providers/user_provider.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';
import 'package:lets_vhandar/features/dashboard/providers/dashboard_provider.dart';
import 'package:lets_vhandar/widgets/custom_dialog.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lets_vhandar/features/profile/presentation/product_suggestion_screen.dart';

import 'widgets/account_appearance_sheet.dart';
import 'widgets/account_guest_view.dart';
import 'widgets/account_menu_item.dart';
import 'widgets/account_orders_card.dart';
import 'widgets/account_point_card.dart';
import 'widgets/account_profile_header.dart';
import 'widgets/account_section.dart';
import 'widgets/account_support_card.dart';
import 'widgets/account_v4b_card.dart';
import 'widgets/account_version_footer.dart';

class AccountTab extends ConsumerStatefulWidget {
  const AccountTab({super.key});

  @override
  ConsumerState<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends ConsumerState<AccountTab> {
  static const String _appVersion = '1.0.0';
  static const String _shareText =
      'Shop fresh groceries and daily essentials with Vhandar: https://www.vhandar.com';
  static const int _accountTabIndex = 4;

  @override
  void initState() {
    super.initState();
    // Fetch fresh profile (incl. Vhandar points) on first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loginProvider.notifier).refreshProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final user = loginState.user;
    final isBusiness = user?.isBusiness == true;
    final vc = context.vColors;

    // Refresh profile whenever the user switches to the Account tab.
    ref.listen<int>(dashboardIndexProvider, (prev, next) {
      if (next == _accountTabIndex && prev != _accountTabIndex) {
        ref.read(loginProvider.notifier).refreshProfile();
      }
    });

    // Refresh when the Account tab is re-tapped while already active.
    ref.listen<int>(tabReactivateProvider(_accountTabIndex), (_, __) {
      ref.read(loginProvider.notifier).refreshProfile();
    });

    if (loginState.isGuest || !loginState.isLoggedIn) {
      return const AccountGuestView(appVersion: _appVersion);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Green cover + floating profile card
            Stack(
              children: [
                Container(
                  height: 140.h,
                  width: double.infinity,
                  color: AppColor.primary,
                ),
                GestureDetector(
                  onTap: () =>
                      context.push(LVRoute.personalInformationScreen.route),
                  child: Container(
                    margin: EdgeInsets.only(top: 80.h, left: 16.w, right: 16.w),
                    decoration: BoxDecoration(
                      color: vc.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        AccountProfileHeader(user: user),
                        if (!isBusiness)
                          GestureDetector(
                            onTap: () =>
                                context.push(LVRoute.vhandarPointsScreen.route),
                            child: AccountPointCard(
                                points: user?.vandarPoints ?? 0),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            GestureDetector(
              onTap: () {
                ref.read(visitedTabsProvider.notifier).update((s) => {...s, 2});
                ref.read(dashboardIndexProvider.notifier).state = 2;
              },
              child: const AccountOrdersCard(),
            ),

            SizedBox(height: 12.h),

            if (!isBusiness) ...[
              GestureDetector(
                onTap: () =>
                    context.push(LVRoute.vhandarForBusinessScreen.route),
                child: const AccountV4BCard(),
              ),
              SizedBox(height: 12.h),
            ],

            AccountSection(
              title: 'Manage',
              children: [
                AccountMenuItem(
                  icon: Icons.list_alt_rounded,
                  title: 'My Lists',
                  subtitle: 'View and manage your saved product lists',
                  onTap: () => context.push(LVRoute.myListsScreen.route),
                ),
                if (!isBusiness)
                  AccountMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Manage Address',
                    subtitle: 'Add or update your delivery addresses',
                    onTap: () =>
                        context.push(LVRoute.savedAddressesScreen.route),
                  ),
                if (!isBusiness)
                  AccountMenuItem(
                    icon: Icons.group_outlined,
                    title: 'Family Members',
                    subtitle: 'Manage family members on your account',
                    onTap: () =>
                        context.push(LVRoute.familyMembersScreen.route),
                  ),
                AccountMenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Wallet',
                  subtitle: 'Check your wallet balance and transactions',
                  onTap: () => context.push(LVRoute.walletScreen.route),
                ),
                AccountMenuItem(
                  icon: Icons.local_offer_outlined,
                  title: 'Coupon Code & Discount',
                  subtitle: 'View your available coupons and offers',
                  showDivider: false,
                  onTap: () => context.push(LVRoute.couponScreen.route),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            AccountSection(
              title: 'Account Settings',
              children: [
                AccountMenuItem(
                  icon: isBusiness
                      ? Icons.business_outlined
                      : Icons.person_outline,
                  title: isBusiness
                      ? 'Business Information'
                      : 'Personal Information',
                  subtitle: isBusiness
                      ? 'Update your business details'
                      : 'Update your personal details',
                  onTap: () =>
                      context.push(LVRoute.personalInformationScreen.route),
                ),
                AccountMenuItem(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: () => context.push(LVRoute.changePasswordScreen.route),
                ),
                AccountMenuItem(
                  icon: Icons.brightness_6_outlined,
                  title: 'Appearance',
                  subtitle: 'Switch between light and dark mode',
                  showDivider: false,
                  onTap: () => showAppearanceSheet(context, ref),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            AccountSection(
              title: 'Support & Feedback',
              children: [
                AccountMenuItem(
                  icon: Icons.help_center_outlined,
                  title: 'Help & Support',
                  subtitle: 'Get help with orders and queries',
                  onTap: () => context.push(LVRoute.helpSupportScreen.route),
                ),
                if (!isBusiness)
                  AccountMenuItem(
                    icon: Icons.share_outlined,
                    title: 'Refer and Earn',
                    subtitle: 'Invite friends and earn Vhandar Points',
                    onTap: () => context.push(LVRoute.referAndEarnScreen.route),
                  ),
                AccountMenuItem(
                  icon: Icons.lightbulb_outline,
                  title: 'Suggest Product',
                  subtitle: 'Tell us what products you\'d like to see',
                  onTap: () => showProductSuggestionSheet(context),
                ),
                AccountMenuItem(
                  icon: Icons.chat_bubble_outline,
                  title: 'Feedback',
                  subtitle: 'Share your experience with us',
                  showDivider: false,
                  onTap: () => context.push(LVRoute.feedbackScreen.route),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            AccountSection(
              title: 'More',
              children: [
                AccountMenuItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'Know more about us',
                  onTap: () => context.push(LVRoute.aboutUsScreen.route),
                ),
                AccountMenuItem(
                  icon: Icons.public_rounded,
                  title: 'More about Vhandar',
                  subtitle: 'Explore Vhandar policies and more',
                  onTap: () => context.push(LVRoute.aboutVhandarScreen.route),
                ),
                AccountMenuItem(
                  icon: Icons.system_update_outlined,
                  title: 'Check For Update',
                  subtitle: 'App version $_appVersion',
                  onTap: () => launchUrl(
                    Uri.parse(
                        'https://play.google.com/store/apps/details?id=com.vhandar.app'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                AccountMenuItem(
                  icon: Icons.ios_share_rounded,
                  title: 'Share this App',
                  subtitle: 'Share Vhandar with friends and family',
                  onTap: () =>
                      SharePlus.instance.share(ShareParams(text: _shareText)),
                ),
                AccountMenuItem(
                  icon: Icons.star_outline_rounded,
                  title: 'Rate this App',
                  subtitle: 'Love Vhandar? Give us a rating!',
                  showDivider: false,
                  onTap: () => launchUrl(
                    Uri.parse(
                        'https://play.google.com/store/apps/details?id=com.vhandar.app'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            AccountSection(
              children: [
                AccountMenuItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  subtitle: 'Logout from your Vhandar account',
                  titleColor: context.isDark
                      ? Colors.red.shade300
                      : Colors.red.shade600,
                  iconColor: context.isDark
                      ? Colors.red.shade300
                      : Colors.red.shade600,
                  showRightArrow: false,
                  showDivider: false,
                  onTap: () => _showLogoutDialog(context, ref),
                ),
              ],
            ),

            SizedBox(height: 16.h),
            const AccountSupportCard(),
            SizedBox(height: 22.h),
            const AccountVersionFooter(version: _appVersion),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    CustomDialog.show(
      context: context,
      icon: Icons.logout_outlined,
      iconColor: AppColor.primary,
      title: 'Logging Out',
      message: 'Are you sure you want to log out of your account?',
      confirmLabel: 'Yes, Logout',
      onConfirm: () async {
        ref.read(cartProvider.notifier).clearCart();
        ref.invalidate(userProfileProvider);
        await ref.read(loginProvider.notifier).logout();
        if (context.mounted) {
          context.go(LVRoute.loginScreen.route);
        }
      },
    );
  }
}
