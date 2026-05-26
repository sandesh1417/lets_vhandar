import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';
import 'package:lets_vhandar/widgets/custom_screen_header.dart';

class VhandarPointsScreen extends ConsumerWidget {
  const VhandarPointsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loginProvider).user;
    final points = user?.vandarPoints ?? 0;

    return CustomScaffoldWrapper(
      isScrollable: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomScreenHeader(title: 'Vhandar Points'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PointsCard(points: points, userName: user?.name),
          SizedBox(height: 24.h),
          _HowToEarnSection(),
          SizedBox(height: 24.h),
          _HowToUseSection(),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}

class _PointsCard extends StatelessWidget {
  final int points;
  final String? userName;

  const _PointsCard({required this.points, this.userName});

  static const _dark = Color(0xFF1A3D2E);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 8.h),
      child: AspectRatio(
        aspectRatio: 1.586,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD000), Color(0xFFFFA800)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: const [
              BoxShadow(
                color: Color(0x73FFD000),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 140.w,
                  height: 140.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              ),
              Positioned(
                right: 40,
                top: -60,
                child: Container(
                  width: 140.w,
                  height: 140.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),

              // Card content
              Padding(
                padding: EdgeInsets.all(22.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: logo + badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SvgPicture.asset(
                          KImageConstant.vhandarPoints,
                          height: 20.h,
                          colorFilter: const ColorFilter.mode(
                              _dark, BlendMode.srcIn),
                        ),
                        SvgPicture.asset(
                          KImageConstant.pointsBadge,
                          width: 38.w,
                          height: 38.w,
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Points number
                    Text(
                      '$points',
                      style: TextStyle(
                        fontSize: 44.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w900,
                        color: _dark,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'POINTS',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        color: _dark.withValues(alpha: 0.55),
                        letterSpacing: 2,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Bottom row: name + worth
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CARD HOLDER',
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                color: _dark.withValues(alpha: 0.5),
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              (userName ?? 'Vhandar User').toUpperCase(),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                color: _dark,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'WORTH',
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                color: _dark.withValues(alpha: 0.5),
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Rs. ${(points * 0.1).toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                color: _dark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _HowToEarnSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to Earn Points',
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              color: context.vColors.onSurface,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: context.vColors.surface,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Column(
              children: [
                _EarnItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Place an Order',
                  subtitle: 'Earn 1 point per Rs. 10 spent',
                  showDivider: true,
                ),
                _EarnItem(
                  icon: Icons.person_add_outlined,
                  title: 'Refer a Friend',
                  subtitle: 'Earn 100 points per successful referral',
                  showDivider: true,
                ),
                _EarnItem(
                  icon: Icons.star_outline_rounded,
                  title: 'First Order Bonus',
                  subtitle: 'Get 50 bonus points on your first order',
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HowToUseSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to Use Points',
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              color: context.vColors.onSurface,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: context.vColors.surface,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Column(
              children: [
                _EarnItem(
                  icon: Icons.redeem_outlined,
                  title: 'Redeem at Checkout',
                  subtitle: 'Apply points to reduce your order total',
                  showDivider: true,
                ),
                _EarnItem(
                  icon: Icons.timer_outlined,
                  title: 'Points Validity',
                  subtitle: 'Points are valid for 12 months from earning date',
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EarnItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showDivider;

  const _EarnItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColor.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: AppColor.primary, size: 20.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: context.vColors.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        color: context.vColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 70.w,
            endIndent: 16.w,
            color: context.vColors.divider,
          ),
      ],
    );
  }
}
