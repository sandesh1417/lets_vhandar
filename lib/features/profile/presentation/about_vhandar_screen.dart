import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/dashboard/presentation/tabs/widgets/account_menu_item.dart';
import 'package:lets_vhandar/features/dashboard/presentation/tabs/widgets/account_section.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutVhandarScreen extends StatelessWidget {
  const AboutVhandarScreen({super.key});

  Future<void> _open(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;

    return Scaffold(
      backgroundColor: vc.scaffoldBg,
      appBar: const CustomScreenHeader(title: 'About Vhandar'),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 32.h),
        child: Column(
          children: [
            SizedBox(height: 8.h),

            // ── Vhandar section ───────────────────────────────────────
            AccountSection(
              title: 'Vhandar',
              children: [
                AccountMenuItem(
                  icon: Icons.info_outline_rounded,
                  title: 'About',
                  onTap: () => _open('https://www.vhandar.com/about'),
                ),
                AccountMenuItem(
                  icon: Icons.help_outline_rounded,
                  title: 'FAQ',
                  onTap: () => _open('https://www.vhandar.com/faq'),
                ),
                AccountMenuItem(
                  icon: Icons.article_outlined,
                  title: 'Blog',
                  onTap: () => _open('https://www.vhandar.com/blog'),
                ),
                AccountMenuItem(
                  icon: Icons.contact_support_outlined,
                  title: 'Contact Us',
                  onTap: () => _open('https://www.vhandar.com/contact'),
                ),
                AccountMenuItem(
                  icon: Icons.work_outline_rounded,
                  title: 'Careers',
                  onTap: () => _open('https://www.vhandar.com/careers'),
                ),
                AccountMenuItem(
                  icon: Icons.storefront_outlined,
                  title: 'Seller',
                  showDivider: false,
                  onTap: () => _open('https://www.vhandar.com/seller'),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // ── Legal & Policies ──────────────────────────────────────
            AccountSection(
              title: 'Legal & Policies',
              children: [
                AccountMenuItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () =>
                      _open('https://www.vhandar.com/privacy-policy'),
                ),
                AccountMenuItem(
                  icon: Icons.gavel_outlined,
                  title: 'Terms of Use',
                  onTap: () => _open('https://www.vhandar.com/terms'),
                ),
                AccountMenuItem(
                  icon: Icons.assignment_return_outlined,
                  title: 'Return Policy',
                  onTap: () =>
                      _open('https://www.vhandar.com/return-policy'),
                ),
                AccountMenuItem(
                  icon: Icons.local_shipping_outlined,
                  title: 'Shipping Policy',
                  showDivider: false,
                  onTap: () =>
                      _open('https://www.vhandar.com/shipping-policy'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
