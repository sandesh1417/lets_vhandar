import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            // User Profile Section
            Container(
              padding: EdgeInsets.all(20.w),
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35.r,
                    backgroundColor: AppColor.primary.withOpacity(0.1),
                    child: Icon(Icons.person,
                        size: 40.sp, color: AppColor.primary),
                  ),
                  SizedBox(width: 20.w),
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
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            // Settings List
            // _buildMenuItem(
            //   icon: Icons.shopping_bag_outlined,
            //   title: 'My Orders',
            //   onTap: () {
            //     ref.read(dashboardIndexProvider.notifier).state = 2;
            //   },
            // ),
            // _buildMenuItem(
            //   icon: Icons.assignment_outlined,
            //   title: 'Your List',
            //   onTap: () {},
            // ),
            _buildMenuItem(
              icon: Icons.history_outlined,
              title: 'Reorder',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.location_on_outlined,
              title: 'Saved Addresses',
              onTap: () {
                context.push(LVRoute.savedAddressesScreen.route);
              },
            ),
            _buildMenuItem(
              icon: Icons.group_outlined,
              title: 'Family Members',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Wallet',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Personal Information',
              onTap: () {
                context.push(LVRoute.personalInformationScreen.route);
              },
            ),
            _buildMenuItem(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                context.push(LVRoute.changePasswordScreen.route);
              },
            ),
            _buildMenuItem(
              icon: Icons.share_outlined,
              title: 'Refer and Earn',
              onTap: () {
                context.push(LVRoute.referAndEarnScreen.route);
              },
            ),
            _buildMenuItem(
              icon: Icons.lightbulb_outline,
              title: 'Suggest Product',
              onTap: () {
                context.push(LVRoute.productSuggestionScreen.route);
              },
            ),
            _buildMenuItem(
              icon: Icons.chat_bubble_outline,
              title: 'Feedback',
              onTap: () {
                context.push(LVRoute.feedbackScreen.route);
              },
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'About Us',
              onTap: () {
                context.push(LVRoute.aboutUsScreen.route);
              },
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'FAQs',
              onTap: () {
                context.push(LVRoute.faqScreen.route);
              },
            ),
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () => _showLogoutDialog(context, ref),
            ),
            _buildMenuItem(
              icon: Icons.delete_forever_outlined,
              title: 'Delete Account',
              titleColor: Colors.red,
              iconColor: Colors.red,
              onTap: () => _showDeleteAccountDialog(context, ref),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading:
          Icon(icon, color: iconColor ?? Colors.grey.shade600, size: 22.sp),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: titleColor ?? Colors.black87,
        ),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(loginProvider.notifier).deleteAccount(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(loginProvider.notifier).logout();
              if (context.mounted) {
                context.go(LVRoute.loginScreen.route);
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
