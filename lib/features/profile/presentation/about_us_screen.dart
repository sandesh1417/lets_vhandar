import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const String _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldWrapper(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: const CustomScreenHeader(title: 'About'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SizedBox(height: 56.h),
            Container(
              width: 152.w,
              height: 152.w,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.r),
              ),
              child: SvgPicture.asset(
                KImageConstant.vandharIcon,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 28.h),
            Text(
              'Vhandar',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.primary,
                fontSize: 30.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Grocery Delivery App',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.greenTxtColor,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'Fresh groceries, daily essentials, and household needs delivered quickly to your doorstep.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.textMuted,
                fontSize: 14.sp,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 18.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColor.secondary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Version $_appVersion',
                style: TextStyle(
                  color: const Color(0xFF6F4B00),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _SocialIcon(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  url: 'https://www.facebook.com/letsvhandar',
                ),
                SizedBox(width: 14.w),
                const _SocialIcon(
                  icon: Icons.camera_alt_outlined,
                  label: 'Instagram',
                  url: 'https://www.instagram.com/letsvhandar',
                ),
                SizedBox(width: 14.w),
                const _SocialIcon(
                  text: 'in',
                  label: 'LinkedIn',
                  url: 'https://www.linkedin.com/company/letsvhandar',
                ),
                SizedBox(width: 14.w),
                const _SocialIcon(
                  icon: Icons.chat_bubble_outline,
                  label: 'WhatsApp',
                  url:
                      'https://www.whatsapp.com/channel/0029VagJOst11ulRcmoNKm1R',
                ),
              ],
            ),
            SizedBox(height: 56.h),
            Padding(
              padding: EdgeInsets.only(bottom: 32.h),
              child: Text(
                'Vhandar Merchandise Pvt Ltd',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColor.textMuted,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData? icon;
  final String? text;
  final String label;
  final String url;

  const _SocialIcon({
    this.icon,
    this.text,
    required this.label,
    required this.url,
  }) : assert(icon != null || text != null);

  Future<void> _openLink(BuildContext context) async {
    final uri = Uri.parse(url);

    try {
      final didLaunch = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!didLaunch && context.mounted) {
        _showLaunchError(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showLaunchError(context);
      }
    }
  }

  void _showLaunchError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open $label')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: Material(
        color: Colors.white,
        shape: CircleBorder(
          side: BorderSide(color: AppColor.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openLink(context),
          child: SizedBox(
            width: 44.w,
            height: 44.w,
            child: Center(
              child: icon != null
                  ? Icon(
                      icon,
                      color: AppColor.primary,
                      size: 22.sp,
                    )
                  : Text(
                      text!,
                      style: TextStyle(
                        color: AppColor.primary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
