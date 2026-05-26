import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const String _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;

    return CustomScaffoldWrapper(
      backgroundColor: vc.scaffoldBg,
      appBar: const CustomScreenHeader(title: 'About'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SizedBox(height: 48.h),

            // Logo
            Container(
              width: 120.w,
              height: 120.w,
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: vc.surface,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: vc.divider),
              ),
              child: SvgPicture.asset(
                KImageConstant.vandharIcon,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20.h),

            // App name
            Text(
              'Vhandar',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.primary,
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4.h),

            // Tagline
            Text(
              'Quick & easy way to get groceries delivered',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: vc.onSurfaceMuted,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            SizedBox(height: 12.h),

            // Version pill
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColor.secondary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Version $_appVersion',
                style: TextStyle(
                  color: const Color(0xFF6F4B00),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // Social icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialButton(
                  label: 'Facebook',
                  brandColor: const Color(0xFF1877F2),
                  url: 'https://www.facebook.com/letsvhandar',
                  child: Text(
                    'f',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                _SocialButton(
                  label: 'Instagram',
                  brandColor: const Color(0xFFE1306C),
                  url: 'https://www.instagram.com/letsvhandar',
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 20.sp),
                ),
                SizedBox(width: 14.w),
                _SocialButton(
                  label: 'LinkedIn',
                  brandColor: const Color(0xFF0A66C2),
                  url: 'https://www.linkedin.com/company/letsvhandar',
                  child: Text(
                    'in',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                _SocialButton(
                  label: 'WhatsApp',
                  brandColor: const Color(0xFF25D366),
                  url: 'https://www.whatsapp.com/channel/0029VagJOst11ulRcmoNKm1R',
                  child: Icon(Icons.chat_rounded, color: Colors.white, size: 20.sp),
                ),
              ],
            ),
            SizedBox(height: 48.h),

            // Company info
            Text(
              'Vhandar Merchandise Pvt Ltd',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: vc.onSurface,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Reg.no: 354027/81/82',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: vc.onSurfaceMuted,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Color brandColor;
  final String url;
  final Widget child;

  const _SocialButton({
    required this.label,
    required this.brandColor,
    required this.url,
    required this.child,
  });

  Future<void> _open(BuildContext context) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $label')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $label')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: () => _open(context),
        child: Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: brandColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
