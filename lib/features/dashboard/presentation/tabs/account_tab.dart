import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/widgets/custom_dialog.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

import 'widgets/account_menu_item.dart';
import 'widgets/account_section.dart';
import 'widgets/account_support_card.dart';

class AccountTab extends ConsumerWidget {
  const AccountTab({super.key});

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

            SizedBox(height: 8.h),

            // My Activity
            AccountSection(
              title: 'My Activity',
              children: [
                // AccountMenuItem(
                //   icon: Icons.history_outlined,
                //   title: 'Reorder',
                //   onTap: () {},
                // ),
                AccountMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Saved Addresses',
                  showDivider: false,
                  onTap: () {
                    context.push(LVRoute.savedAddressesScreen.route);
                  },
                ),
              ],
            ),

            // Kids Fun Zone
            AccountSection(
              title: 'Kids Fun Zone 🎮',
              children: [
                AccountMenuItem(
                  icon: Icons.sports_esports_outlined,
                  title: 'Kids Play & Learn Zone',
                  showDivider: false,
                  onTap: () {
                    context.push(LVRoute.kidsZoneScreen.route);
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

            SizedBox(height: 70.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      padding: EdgeInsets.all(20.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColor.primary.withOpacity(0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 30.r,
              backgroundColor: AppColor.primary.withOpacity(0.1),
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
