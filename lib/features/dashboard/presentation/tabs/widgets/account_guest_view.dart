import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/dashboard/providers/dashboard_provider.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

import 'account_appearance_sheet.dart';
import 'account_feature_tile.dart';
import 'account_menu_item.dart';
import 'account_section.dart';
import 'account_support_card.dart';
import 'account_v4b_card.dart';
import 'account_version_footer.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

class AccountGuestView extends ConsumerWidget {
  final String appVersion;

  const AccountGuestView({super.key, required this.appVersion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vc = context.vColors;

    return CustomScaffoldWrapper(
      isScrollable: false,
      bottomSafeArea: false,
      backgroundColor: vc.scaffoldBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero area
            Container(
              width: double.infinity,
              color: AppColor.primary,
              padding: EdgeInsets.fromLTRB(
                24.w,
                MediaQuery.of(context).padding.top + 32.h,
                24.w,
                40.h,
              ),
              child: Column(
                children: [
                  Container(
                    width: 80.w,
                    height: 80.w,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      'assets/images/icon_logo.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Welcome to Vhandar',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Login to unlock your full experience',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: 'Inter',
                      color: Colors.white.withValues(alpha: 0.80),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  SizedBox(
                    width: double.infinity,
                    child: CustomElevatedButton(
                      onPressed: () {
                        ref.read(dashboardIndexProvider.notifier).state = 0;
                        context.go(LVRoute.loginScreen.route);
                      },
                      backgroundColor: Colors.white,
                      foregroundColor: AppColor.primary,
                      text: 'Login',
                    ),
                  ),
                ],
              ),
            ),

            // Feature highlights
            Container(
              margin: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
              decoration: BoxDecoration(
                color: vc.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: vc.divider),
              ),
              child: Column(
                children: [
                  AccountFeatureTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Track your orders',
                    subtitle: 'Real-time updates on every delivery',
                    showDivider: true,
                    onTap: () => CustomSnackbar.info(context,
                        message: 'Login to track your orders'),
                  ),
                  AccountFeatureTile(
                    icon: Icons.location_on_outlined,
                    title: 'Manage addresses',
                    subtitle: 'Save multiple delivery locations',
                    showDivider: true,
                    onTap: () => CustomSnackbar.info(context,
                        message: 'Login to manage your addresses'),
                  ),
                  AccountFeatureTile(
                    icon: Icons.card_giftcard_outlined,
                    title: 'Earn rewards',
                    subtitle: 'Get referral bonuses and exclusive deals',
                    showDivider: true,
                    onTap: () => CustomSnackbar.info(context,
                        message: 'Login to earn rewards'),
                  ),
                  AccountFeatureTile(
                    icon: Icons.replay_outlined,
                    title: 'Reorder with one tap',
                    subtitle: 'Instantly reorder your favourites',
                    showDivider: false,
                    onTap: () => CustomSnackbar.info(context,
                        message: 'Login to reorder your favourites'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),
            AccountSection(
              title: 'Appearance',
              children: [
                AccountMenuItem(
                  icon: Icons.brightness_6_outlined,
                  title: 'Appearance',
                  showDivider: false,
                  onTap: () => showAppearanceSheet(context, ref),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            AccountSection(
              title: 'Support & Info',
              children: [
                AccountMenuItem(
                  icon: Icons.support_agent_outlined,
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
                  onTap: () => launchUrl(
                      Uri.parse('https://www.vhandar.com/faq'),
                      mode: LaunchMode.externalApplication),
                ),
                AccountMenuItem(
                  icon: Icons.contact_support_outlined,
                  title: 'Contact Us',
                  onTap: () => launchUrl(
                      Uri.parse('https://www.vhandar.com/contact'),
                      mode: LaunchMode.externalApplication),
                ),
                AccountMenuItem(
                  icon: Icons.article_outlined,
                  title: 'Blog',
                  showDivider: false,
                  onTap: () => launchUrl(
                      Uri.parse('https://www.vhandar.com/blog'),
                      mode: LaunchMode.externalApplication),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            AccountSection(
              title: 'More',
              children: [
                AccountMenuItem(
                  icon: Icons.public_rounded,
                  title: 'More about Vhandar',
                  subtitle: 'Explore Vhandar policies and more',
                  showDivider: false,
                  onTap: () => context.push(LVRoute.aboutVhandarScreen.route),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () => context.push(LVRoute.vhandarForBusinessScreen.route),
              child: const AccountV4BCard(),
            ),
            SizedBox(height: 12.h),
            const AccountSupportCard(),
            SizedBox(height: 22.h),
            AccountVersionFooter(version: appVersion),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 80.h),
          ],
        ),
      ),
    );
  }
}
