import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

class VhandarForBusinessScreen extends StatelessWidget {
  const VhandarForBusinessScreen({super.key});

  static const _features = [
    (
      icon: Icons.inventory_2_outlined,
      title: 'Bulk Ordering',
      desc: 'Order large quantities at wholesale prices tailored for businesses.',
    ),
    (
      icon: Icons.local_offer_outlined,
      title: 'Business Pricing',
      desc: 'Exclusive pricing and discounts only available to B2B accounts.',
    ),
    (
      icon: Icons.receipt_long_outlined,
      title: 'Invoice & Billing',
      desc: 'Get itemised invoices and easy billing for your business expenses.',
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

    return Scaffold(
      backgroundColor: vc.scaffoldBg,
      appBar: const CustomScreenHeader(title: 'Vhandar For Business'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 32.h),

                  // V4B Logo
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/V4B_logo.svg',
                        height: 48.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  Text(
                    'Grow your business with Vhandar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: vc.onSurface,
                      fontFamily: 'Inter',
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Join hundreds of businesses using Vhandar to source groceries and essentials at the best prices.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: vc.onSurfaceMuted,
                      fontFamily: 'Inter',
                      height: 1.6,
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Features list
                  ...List.generate(_features.length, (i) {
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                ],
              ),
            ),
          ),

          // Register button — fixed at bottom
          Container(
            color: vc.surface,
            padding: EdgeInsets.fromLTRB(
                20.w, 12.h, 20.w, MediaQuery.of(context).padding.bottom + 12.h),
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
    );
  }
}
