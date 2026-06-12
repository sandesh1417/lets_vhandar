import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launch(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        CustomSnackbar.error(context, message: 'Could not open link');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomScreenHeader(title: 'Help & Support'),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 76.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero banner ───────────────────────────────────────────────
            _HeroBanner(onChatTap: () => _launch(context, 'https://wa.me/9779851357358')),

            SizedBox(height: 24.h),

            // ── Reach Us row ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'Reach Us',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: vc.onSurface,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  _QuickContactButton(
                    icon: _kWhatsappSvg,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () => _launch(context, 'https://wa.me/9779851357358'),
                  ),
                  SizedBox(width: 10.w),
                  _QuickContactButton(
                    icon: _kMessengerSvg,
                    label: 'Messenger',
                    color: const Color(0xFF006AFF),
                    onTap: () => _launch(context, 'https://m.me/letsvhandar'),
                  ),
                  SizedBox(width: 10.w),
                  _QuickContactButton(
                    icon: _kCallSvg,
                    label: 'Call Us',
                    color: AppColor.primary,
                    onTap: () => _launch(context, 'tel:+9779851357358'),
                  ),
                  SizedBox(width: 10.w),
                  _QuickContactButton(
                    icon: _kEmailSvg,
                    label: 'Email',
                    color: const Color(0xFFE34234),
                    onTap: () =>
                        _launch(context, 'mailto:support@vhandar.com'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // ── Info cards ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'How Can We Help?',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: vc.onSurface,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            SizedBox(height: 12.h),

            _InfoCard(
              icon: Icons.inventory_2_outlined,
              iconColor: const Color(0xFF7B5EA7),
              title: 'Order Related Queries',
              body: 'Connect with our customer support team on the app, or reach us via ',
              links: const [
                _LinkItem('WhatsApp', 'https://wa.me/9779851357358'),
                _LinkItem('Messenger', 'https://m.me/letsvhandar'),
              ],
              onLaunch: _launch,
            ),

            SizedBox(height: 12.h),

            _InfoCard(
              icon: Icons.mail_outline_rounded,
              iconColor: const Color(0xFFE34234),
              title: 'Email Support',
              body: 'Send us an email at ',
              links: const [
                _LinkItem('support@vhandar.com', 'mailto:support@vhandar.com'),
              ],
              extraPrefix: 'For general inquiries: ',
              extra: 'info@vhandar.com',
              extraUrl: 'mailto:info@vhandar.com',
              onLaunch: _launch,
            ),

            SizedBox(height: 12.h),

            _PhoneCard(onLaunch: _launch),

            SizedBox(height: 12.h),

            _AddressCard(vc: vc),

            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Banner
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final VoidCallback onChatTap;
  const _HeroBanner({required this.onChatTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      height: 180.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064D34), Color(0xFF0A8C59)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            left: -30.w,
            bottom: -30.h,
            child: Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // ── Agent photo — bottom right, full image visible ───────────
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.asset(
              KImageConstant.supportAgent,
              height: 160.h,
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
            ),
          ),

          // ── Left: text + button ──────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 160.w, 16.h),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(
                        text: 'Chat ',
                        style: TextStyle(color: AppColor.secondary),
                      ),
                      const TextSpan(
                          text: "with us if\nYou've Any\nQuestions."),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded,
                        size: 11.sp, color: Colors.white60),
                    SizedBox(width: 5.w),
                    Text(
                      '24/7 Free Support',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white70,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onChatTap();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 18.w, vertical: 9.h),
                    decoration: BoxDecoration(
                      color: AppColor.secondary,
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    child: Text(
                      'Chat Now',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Contact Button
// ─────────────────────────────────────────────────────────────────────────────

class _QuickContactButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.string(
                icon,
                width: 24.w,
                height: 24.w,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Card
// ─────────────────────────────────────────────────────────────────────────────

class _LinkItem {
  final String label;
  final String url;
  const _LinkItem(this.label, this.url);
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final List<_LinkItem> links;
  final String? extraPrefix;
  final String? extra;
  final String? extraUrl;
  final Future<void> Function(BuildContext, String) onLaunch;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.links,
    this.extraPrefix,
    this.extra,
    this.extraUrl,
    required this.onLaunch,
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: context.isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: vc.onSurface,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 6.h),
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: vc.onSurfaceMuted,
                      fontFamily: 'Inter',
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(text: body),
                      for (int i = 0; i < links.length; i++) ...[
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => onLaunch(context, links[i].url),
                            child: Text(
                              links[i].label,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColor.primary,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                        if (i < links.length - 1)
                          const TextSpan(text: ', '),
                      ],
                    ],
                  ),
                ),
                if (extra != null) ...[
                  SizedBox(height: 6.h),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: vc.onSurfaceMuted,
                        fontFamily: 'Inter',
                        height: 1.5,
                      ),
                      children: [
                        if (extraPrefix != null)
                          TextSpan(text: extraPrefix),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: extraUrl != null
                                ? () => onLaunch(context, extraUrl!)
                                : null,
                            child: Text(
                              extra!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColor.primary,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phone Card
// ─────────────────────────────────────────────────────────────────────────────

class _PhoneCard extends StatelessWidget {
  final Future<void> Function(BuildContext, String) onLaunch;
  const _PhoneCard({required this.onLaunch});

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    const numbers = ['+977 9851357358', '+977 9802340360'];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: context.isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.phone_outlined,
                color: AppColor.primary, size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone Support',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: vc.onSurface,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 8.h),
                ...numbers.map((n) => GestureDetector(
                      onTap: () => onLaunch(
                          context, 'tel:${n.replaceAll(' ', '')}'),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Row(
                          children: [
                            Icon(Icons.call_rounded,
                                size: 14.sp, color: AppColor.primary),
                            SizedBox(width: 8.w),
                            Text(
                              n,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColor.primary,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Address Card
// ─────────────────────────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final VhandarColors vc;
  const _AddressCard({required this.vc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: vc.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE87040).withValues(alpha: context.isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.location_on_outlined,
                color: const Color(0xFFE87040), size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our Office',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: vc.onSurface,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Operational address:',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: vc.onSurfaceMuted,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Shankhamul, Kathmandu, Nepal',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: vc.onSurface,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Inline SVG icons
// ─────────────────────────────────────────────────────────────────────────────

const _kWhatsappSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
</svg>''';

const _kMessengerSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 0C5.373 0 0 4.975 0 11.111c0 3.497 1.745 6.616 4.472 8.652V24l4.086-2.242c1.09.301 2.246.464 3.442.464 6.627 0 12-4.975 12-11.111S18.627 0 12 0zm1.193 14.963l-3.056-3.259-5.963 3.259L10.732 8.1l3.13 3.259 5.89-3.259-6.559 6.863z"/>
</svg>''';

const _kCallSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M6.62 10.79c1.44 2.83 3.76 5.14 6.59 6.59l2.2-2.2c.27-.27.67-.36 1.02-.24 1.12.37 2.33.57 3.57.57.55 0 1 .45 1 1V20c0 .55-.45 1-1 1-9.39 0-17-7.61-17-17 0-.55.45-1 1-1h3.5c.55 0 1 .45 1 1 0 1.25.2 2.45.57 3.57.11.35.03.74-.25 1.02l-2.2 2.2z"/>
</svg>''';

const _kEmailSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/>
</svg>''';
