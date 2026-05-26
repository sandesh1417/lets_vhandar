import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/providers/theme_provider.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/dashboard/providers/dashboard_provider.dart';
import 'package:lets_vhandar/widgets/custom_dialog.dart';
import 'package:share_plus/share_plus.dart';

import 'widgets/account_menu_item.dart';
import 'widgets/account_section.dart';
import 'widgets/account_support_card.dart';

class AccountTab extends ConsumerWidget {
  const AccountTab({super.key});

  static const String _appVersion = '1.0.0';
  static const String _shareText =
      'Shop fresh groceries and daily essentials with Vhandar: https://www.vhandar.com';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);
    final user = loginState.user;

    final vc = context.vColors;

    if (loginState.isGuest || !loginState.isLoggedIn) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Green cover with guest avatar card overlapping
              Stack(
                children: [
                  Container(
                    height: 140.h,
                    width: double.infinity,
                    color: AppColor.primary,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: 80.h, left: 16.w, right: 16.w),
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
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 32.r,
                          backgroundColor:
                              AppColor.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.person_outline,
                              size: 36.sp, color: AppColor.primary),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          'Login to access your account',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            color: vc.onSurface,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'View orders, manage addresses,\nearn rewards & more',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            color: AppColor.hintText,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 18.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                context.go(LVRoute.loginScreen.route),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.secondary,
                              foregroundColor: const Color(0xFF1A1A1A),
                              padding: EdgeInsets.symmetric(vertical: 13.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Login / Sign Up',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              AccountSection(
                title: 'Appearance',
                children: [
                  AccountMenuItem(
                    icon: Icons.brightness_6_outlined,
                    title: 'Appearance',
                    showDivider: false,
                    onTap: () => _showAppearanceSheet(context, ref),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              AccountSection(
                title: 'Support & Info',
                children: [
                  AccountMenuItem(
                    icon: Icons.help_center_outlined,
                    title: 'Help & Support',
                    onTap: () => context.push(LVRoute.helpSupportScreen.route),
                  ),
                  AccountMenuItem(
                    icon: Icons.info_outline,
                    title: 'About',
                    onTap: () => context.push(LVRoute.aboutUsScreen.route),
                  ),
                  AccountMenuItem(
                    icon: Icons.help_outline,
                    title: 'FAQs',
                    onTap: () => context.push(LVRoute.faqScreen.route),
                  ),
                  AccountMenuItem(
                    icon: Icons.contact_support_outlined,
                    title: 'Contact Us',
                    onTap: () => context.push(LVRoute.contactUsScreen.route),
                  ),
                  AccountMenuItem(
                    icon: Icons.ios_share_outlined,
                    title: 'Share App',
                    onTap: () => Share.share(_shareText),
                  ),
                  AccountMenuItem(
                    icon: Icons.article_outlined,
                    title: 'Blog',
                    showDivider: false,
                    onTap: () => context.push(LVRoute.blogScreen.route),
                  ),
                ],
              ),
              SizedBox(height: 22.h),
              _buildAppVersionFooter(),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 150.h),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Green cover + floating profile+points card
            Stack(
              children: [
                Container(
                  height: 140.h,
                  width: double.infinity,
                  color: AppColor.primary,
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: 80.h, left: 16.w, right: 16.w),
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
                      _buildProfileHeader(context, user),
                      GestureDetector(
                        onTap: () => context.push(LVRoute.vhandarPointsScreen.route),
                        child: _buildVhandarPointCard(context, user?.vandarPoints ?? 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // My Activity
            AccountSection(
              title: 'Manage',
              children: [
                AccountMenuItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Manage Orders',
                  onTap: () {
                    ref.read(dashboardIndexProvider.notifier).state = 2;
                  },
                ),
                AccountMenuItem(
                  icon: Icons.list_alt_rounded,
                  title: 'My Lists',
                  onTap: () {
                    context.push(LVRoute.myListsScreen.route);
                  },
                ),
                AccountMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Manage Address',
                  onTap: () {
                    context.push(LVRoute.savedAddressesScreen.route);
                  },
                ),
                AccountMenuItem(
                  icon: Icons.group_outlined,
                  title: 'Family Members',
                  onTap: () {
                    context.push(LVRoute.familyMembersScreen.route);
                  },
                ),
                AccountMenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Wallet',
                  showDivider: false,
                  onTap: () {
                    context.push(LVRoute.walletScreen.route);
                  },
                ),
              ],
            ),

            // Settings
            AccountSection(
              title: 'Account Settings',
              children: [
                AccountMenuItem(
                  icon: Icons.person_outline,
                  title: 'Personal Information',
                  onTap: () {
                    context.push(LVRoute.personalInformationScreen.route);
                  },
                ),
                AccountMenuItem(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () {
                    context.push(LVRoute.changePasswordScreen.route);
                  },
                ),
                AccountMenuItem(
                  icon: Icons.brightness_6_outlined,
                  title: 'Appearance',
                  showDivider: false,
                  onTap: () => _showAppearanceSheet(context, ref),
                ),
                // AccountMenuItem(
                //   icon: Icons.account_balance_wallet_outlined,
                //   title: 'Wallet',
                //   onTap: () {},
                // ),
                // AccountMenuItem(
                //   icon: Icons.group_outlined,
                //   title: 'Family Members',
                //   showDivider: false,
                //   onTap: () {},
                // ),
              ],
            ),

            // Support & Feedback
            AccountSection(
              title: 'Support & Feedback',
              children: [
                AccountMenuItem(
                  icon: Icons.help_center_outlined,
                  title: 'Help & Support',
                  onTap: () {
                    context.push(LVRoute.helpSupportScreen.route);
                  },
                ),
                AccountMenuItem(
                  icon: Icons.share_outlined,
                  title: 'Refer and Earn',
                  onTap: () {
                    context.push(LVRoute.referAndEarnScreen.route);
                  },
                ),
                AccountMenuItem(
                  icon: Icons.ios_share_outlined,
                  title: 'Share',
                  onTap: () {
                    Share.share(_shareText);
                  },
                ),
                AccountMenuItem(
                  icon: Icons.lightbulb_outline,
                  title: 'Suggest Product',
                  onTap: () {
                    context.push(LVRoute.productSuggestionScreen.route);
                  },
                ),
                AccountMenuItem(
                  icon: Icons.chat_bubble_outline,
                  title: 'Feedback',
                  showDivider: false,
                  onTap: () {
                    context.push(LVRoute.feedbackScreen.route);
                  },
                ),
              ],
            ),

            // More
            AccountSection(
              title: 'More',
              children: [
                AccountMenuItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {
                    context.push(LVRoute.aboutUsScreen.route);
                  },
                ),
                AccountMenuItem(
                  icon: Icons.help_outline,
                  title: 'FAQs',
                  onTap: () {
                    context.push(LVRoute.faqScreen.route);
                  },
                ),
                AccountMenuItem(
                  icon: Icons.article_outlined,
                  title: 'Blog',
                  onTap: () {
                    context.push(LVRoute.blogScreen.route);
                  },
                ),
                AccountMenuItem(
                  icon: Icons.contact_support_outlined,
                  title: 'Contact Us',
                  onTap: () {
                    context.push(LVRoute.contactUsScreen.route);
                  },
                ),
                AccountMenuItem(
                  icon: Icons.work_outline,
                  title: 'Careers',
                  showDivider: false,
                  onTap: () {
                    context.push(LVRoute.careersScreen.route);
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Danger Zone
            AccountSection(
              children: [
                AccountMenuItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  titleColor: Colors.red.shade600,
                  iconColor: Colors.red.shade600,
                  showRightArrow: false,
                  showDivider: false,
                  onTap: () => _showLogoutDialog(context, ref),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            const AccountSupportCard(),

            SizedBox(height: 22.h),
            _buildAppVersionFooter(),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 150.h),
          ],
        ),
      ),
    );
  }

  Widget _buildVhandarPointCard(BuildContext context, int points) {
    final vc = context.vColors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: vc.divider)),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            KImageConstant.pointsBadge,
            width: 44.w,
            height: 44.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  KImageConstant.vhandarPoints,
                  height: 22.h,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                ),
                SizedBox(height: 5.h),
                Text(
                  'Earn rewards on every order',
                  style: TextStyle(
                    color: vc.onSurfaceMuted,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$points pts',
              style: TextStyle(
                color: AppColor.primary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    final vc = context.vColors;
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColor.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 30.r,
              backgroundColor: AppColor.primary.withValues(alpha: 0.1),
              child: Icon(Icons.person, size: 35.sp, color: AppColor.primary),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'User Name',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: vc.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  user?.phoneNumber ?? 'Phone Number',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: vc.onSurfaceMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // IconButton(
          //   onPressed: () {}, // Navigate to edit profile
          //   icon:
          //       Icon(Icons.edit_outlined, color: AppColor.primary, size: 20.sp),
          //   style: IconButton.styleFrom(
          //     backgroundColor: AppColor.primary.withOpacity(0.05),
          //     padding: EdgeInsets.all(8.w),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildAppVersionFooter() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/icons/vhandar-white-logo.svg',
            width: 110.w,
            colorFilter: const ColorFilter.mode(
              Color(0xFFB0B8B4),
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Version $_appVersion',
            style: TextStyle(
              color: AppColor.textMuted,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    CustomDialog.show(
      context: context,
      icon: Icons.delete_forever_outlined,
      iconColor: Colors.red.shade400,
      iconBgColor: Colors.red.shade50,
      title: 'Delete Account',
      message:
          'This action is permanent and cannot be undone. All your data, orders, and addresses will be removed.',
      confirmLabel: 'Yes, Delete Account',
      confirmGradient: [Colors.red.shade600, Colors.red.shade400],
      onConfirm: () async {
        await ref.read(loginProvider.notifier).deleteAccount(context);
      },
    );
  }

  void _showAppearanceSheet(BuildContext context, WidgetRef ref) {
    final current = ref.read(themeModeProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AppearanceSheet(current: current, ref: ref),
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
        await ref.read(loginProvider.notifier).logout();
        if (context.mounted) {
          context.go(LVRoute.loginScreen.route);
        }
      },
    );
  }
}

class _AppearanceSheet extends StatefulWidget {
  final ThemeMode current;
  final WidgetRef ref;
  const _AppearanceSheet({required this.current, required this.ref});

  @override
  State<_AppearanceSheet> createState() => _AppearanceSheetState();
}

class _AppearanceSheetState extends State<_AppearanceSheet> {
  late ThemeMode _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  void _pick(ThemeMode mode) {
    setState(() => _selected = mode);
    widget.ref.read(themeModeProvider.notifier).setMode(mode);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Appearance',
            style: TextStyle(
              fontSize: 17.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Choose how Vhandar looks on this device.',
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Inter',
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 20.h),
          _ThemeOption(
            icon: Icons.light_mode_outlined,
            label: 'Light',
            selected: _selected == ThemeMode.light,
            onTap: () => _pick(ThemeMode.light),
          ),
          SizedBox(height: 10.h),
          _ThemeOption(
            icon: Icons.dark_mode_outlined,
            label: 'Dark',
            selected: _selected == ThemeMode.dark,
            onTap: () => _pick(ThemeMode.dark),
          ),
          SizedBox(height: 10.h),
          _ThemeOption(
            icon: Icons.brightness_auto_outlined,
            label: 'System default',
            selected: _selected == ThemeMode.system,
            onTap: () => _pick(ThemeMode.system),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColor.primary.withValues(alpha: 0.08)
              : context.vColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? AppColor.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: selected ? AppColor.primary : Colors.grey.shade600,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColor.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: AppColor.primary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
