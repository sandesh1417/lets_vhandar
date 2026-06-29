import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';

class VhandarForBusinessScreen extends StatelessWidget {
  const VhandarForBusinessScreen({super.key});

  static const _features = [
    (
      icon: Icons.inventory_2_outlined,
      title: 'Bulk Ordering',
      desc:
          'Order large quantities at wholesale prices tailored for businesses.',
    ),
    (
      icon: Icons.local_offer_outlined,
      title: 'Business Pricing',
      desc: 'Exclusive pricing and discounts only available to B2B accounts.',
    ),
    (
      icon: Icons.receipt_long_outlined,
      title: 'Invoice & Billing',
      desc:
          'Get itemised invoices and easy billing for your business expenses.',
    ),
    (
      icon: Icons.support_agent_rounded,
      title: 'Dedicated Support',
      desc: 'Priority customer support and a dedicated account manager.',
    ),
    (
      icon: Icons.local_shipping_outlined,
      title: 'Swift Delivery',
      desc: 'Reliable scheduled deliveries to keep your business running.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;
    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: vc.scaffoldBg,
        // No AppBar — the hero banner IS the header, so the title won't be
        // duplicated by both an AppBar and the V4B logo inside the body.
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Immersive hero banner ──────────────────────────────
                    // The V4B SVG already contains "Vhandar for Business" as
                    // its wordmark, so this panel is the single title of the
                    // screen. A floating back-arrow overlays it so there is
                    // no separate AppBar repeating the name.
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(
                              24.w, topPadding + 56.h, 24.w, 32.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF0D4F2E),
                                AppColor.primary,
                                Color(0xFF27AE60),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(28.r),
                              bottomRight: Radius.circular(28.r),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primary.withValues(alpha: 0.30),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // V4B logo — the one and only brand statement
                              SvgPicture.asset(
                                'assets/images/V4B_logo.svg',
                                height: 64.h,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'Grow your business with Vhandar',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: 'Inter',
                                  height: 1.35,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'Join hundreds of businesses sourcing groceries\nat the best wholesale prices.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white.withValues(alpha: 0.80),
                                  fontFamily: 'Inter',
                                  height: 1.55,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Floating back arrow — replaces the AppBar
                        Positioned(
                          top: topPadding + 8.h,
                          left: 8.w,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.pop();
                            },
                            child: Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 22.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Features list
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: List.generate(_features.length, (i) {
                          final f = _features[i];
                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: vc.surface,
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44.w,
                                  height: 44.w,
                                  decoration: BoxDecoration(
                                    color: AppColor.primary.withValues(
                                        alpha: context.isDark ? 0.2 : 0.10),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(f.icon,
                                      color: AppColor.primary, size: 20.sp),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        f.title,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: vc.onSurface,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      SizedBox(height: 3.h),
                                      Text(
                                        f.desc,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: vc.onSurfaceMuted,
                                          fontFamily: 'Inter',
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),

                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),

            // Register button — fixed at bottom
            Container(
              color: vc.surface,
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w,
                  MediaQuery.of(context).padding.bottom + 12.h),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: CustomElevatedButton(
                  onPressed: () =>
                      context.push(LVRoute.v4BRegistrationScreen.route),
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  text: 'Register as Business',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
