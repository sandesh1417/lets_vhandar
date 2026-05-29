import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';
import 'package:share_plus/share_plus.dart';

class ReferAndEarnScreen extends ConsumerWidget {
  const ReferAndEarnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loginProvider).user;
    final referralCode = user?.referalCode ?? 'NOTFOUND';
    final vc = context.vColors;

    return CustomScaffoldWrapper(
      isScrollable: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomScreenHeader(title: 'Refer and Earn'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero banner ──────────────────────────────────────────────
          _HeroBanner(referralCode: referralCode),

          // ── How it works ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How Refer and Earn works:',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: vc.onSurface,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 20.h),
                const _Step(
                  number: '1',
                  icon: Icons.share_outlined,
                  text: 'Share your referral code with a friend and ask them to enter it during Vhandar signup.',
                ),
                const _Step(
                  number: '2',
                  icon: Icons.workspace_premium_outlined,
                  text: 'You earn 100 Vhandar Points for every friend upon completion of their first order.',
                ),
                const _Step(
                  number: '3',
                  icon: Icons.local_offer_outlined,
                  text: 'They get attractive discounts off their first purchase.',
                ),
                const _Step(
                  number: '4',
                  icon: Icons.redeem_outlined,
                  text: 'Vhandar Points can be redeemed on your next purchase — Rs.1 for every 10 points.',
                  showLine: false,
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // ── Your Referrals ───────────────────────────────────────────
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: vc.surface,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Referrals',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: vc.onSurface,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 32.h),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.people_outline_rounded,
                          size: 36.sp,
                          color: Colors.orange.shade600,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'No referrals yet',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: vc.onSurface,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Share your code to start earning points!',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: vc.onSurfaceMuted,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),

          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Banner
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final String referralCode;
  const _HeroBanner({required this.referralCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 220.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8651A), Color(0xFFF5A623)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative circles
          Positioned(
            top: -40.h,
            right: 80.w,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -20.h,
            left: -20.w,
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Person image — right side
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.asset(
              KImageConstant.referralPerson,
              height: 220.h,
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
            ),
          ),

          // Content — left side
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 28.h, 160.w, 28.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Refer a friend and earn',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    fontFamily: 'Inter',
                    height: 1.4,
                  ),
                ),
                Text(
                  '100 Vhandar Points',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'Inter',
                    height: 1.3,
                  ),
                ),
                Text(
                  'upon their first order.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    fontFamily: 'Inter',
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 24.h),

                Text(
                  'Referral Code',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 8.h),

                // Dashed code box
                CustomPaint(
                  painter: const _DashedBorderPainter(
                    color: Color(0xFFD4A574),
                    strokeWidth: 1.5,
                    gap: 5,
                    dashWidth: 6,
                    radius: 8,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5DEB3),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          referralCode,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2D1A00),
                            fontFamily: 'Inter',
                            letterSpacing: 1.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Clipboard.setData(
                                ClipboardData(text: referralCode));
                            CustomSnackbar.success(context,
                                message: 'Referral code copied!');
                          },
                          child: Row(
                            children: [
                              Icon(Icons.copy_rounded,
                                  size: 15.sp,
                                  color: const Color(0xFF8B4500)),
                              SizedBox(width: 5.w),
                              Text(
                                'Copy',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF8B4500),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Share button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Share.share(
                      'Use my referral code $referralCode on Vhandar and get discounts on your first order! Download: https://play.google.com/store/apps/details?id=com.vhandar.app',
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.share_rounded,
                            size: 15.sp, color: const Color(0xFFE8651A)),
                        SizedBox(width: 6.w),
                        Text(
                          'Share Code',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE8651A),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
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
// Step widget
// ─────────────────────────────────────────────────────────────────────────────

class _Step extends StatelessWidget {
  final String number;
  final IconData icon;
  final String text;
  final bool showLine;

  const _Step({
    required this.number,
    required this.icon,
    required this.text,
    this.showLine = true,
  });

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.orange.shade700, size: 18.sp),
            ),
            if (showLine)
              Container(
                width: 2.w,
                height: 28.h,
                color: Colors.orange.withValues(alpha: 0.2),
              ),
          ],
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 10.h, bottom: showLine ? 0 : 0),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                color: vc.onSurface,
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashed border painter
// ─────────────────────────────────────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashWidth;
  final double radius;

  const _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.dashWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final remaining = metric.length - distance;
        final dLen = math.min(dashWidth, remaining);
        canvas.drawPath(metric.extractPath(distance, distance + dLen), paint);
        distance += dashWidth + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
