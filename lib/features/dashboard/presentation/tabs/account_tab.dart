import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/dashboard/providers/dashboard_provider.dart';
import 'package:lets_vhandar/widgets/custom_dialog.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
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

    return CustomScaffoldWrapper(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomScreenHeader(
        title: 'Account',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16.h),
            // User Profile Section
            _buildProfileHeader(user),

            _buildVhandarPointCard(user?.vandarPoints ?? 0),

            SizedBox(height: 8.h),

            // My Activity
            AccountSection(
              title: 'My Activity',
              children: [
                AccountMenuItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'My Orders',
                  onTap: () {
                    ref.read(dashboardIndexProvider.notifier).state = 2;
                  },
                ),
                AccountMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Manage Address',
                  showDivider: false,
                  onTap: () {
                    context.push(LVRoute.savedAddressesScreen.route);
                  },
                ),
              ],
            ),

            // Kids Fun Zone Premium Banner
            SizedBox(height: 16.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFA726), Color(0xFFFF9800)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.push(LVRoute.kidsZoneScreen.route);
                  },
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    child: Row(
                      children: [
                        // Left: Playful controller / game icon bubble
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.sports_esports,
                            color: Colors.white,
                            size: 32.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // Middle: Text details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'KIDS FUN ZONE 🎮',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.shade400,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      'NEW',
                                      style: TextStyle(
                                        fontSize: 8.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Play fun games, learn & earn discount coupons!',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Right: Small arrow
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
                  title: 'About Us',
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
            SizedBox(height: 70.h),
          ],
        ),
      ),
    );
  }

  Widget _buildVhandarPointCard(int points) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16.r),
        ),
        border: Border(
          left: BorderSide(color: AppColor.border.withValues(alpha: 0.55)),
          right: BorderSide(color: AppColor.border.withValues(alpha: 0.55)),
          bottom: BorderSide(color: AppColor.border.withValues(alpha: 0.55)),
        ),
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
                    color: AppColor.textMuted,
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

  Widget _buildProfileHeader(user) {
    return Container(
      padding: EdgeInsets.all(20.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.r),
        ),
        border: Border(
          left: BorderSide(color: AppColor.border.withValues(alpha: 0.55)),
          top: BorderSide(color: AppColor.border.withValues(alpha: 0.55)),
          right: BorderSide(color: AppColor.border.withValues(alpha: 0.55)),
          bottom: BorderSide(color: AppColor.border.withValues(alpha: 0.55)),
        ),
      ),
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
                    color: AppColor.textBlack,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  user?.phoneNumber ?? 'Phone Number',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
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
          Text(
            'Vhandar',
            style: TextStyle(
              color: AppColor.primary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4.h),
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
