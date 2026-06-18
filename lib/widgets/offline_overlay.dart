import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/providers/connectivity_provider.dart';
import 'package:lets_vhandar/core/theme/vhandar_colors.dart';

/// Drop this into any page's widget tree to show an offline screen
/// only when there is no internet connection.
class HomeOfflineOverlay extends ConsumerWidget {
  final Widget child;
  const HomeOfflineOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(connectivityProvider).maybeWhen(
          data: (online) => !online,
          orElse: () => false,
        );

    return Stack(
      children: [
        child,
        if (isOffline) const _OfflineScreen(),
      ],
    );
  }
}

class _OfflineScreen extends StatelessWidget {
  const _OfflineScreen();

  @override
  Widget build(BuildContext context) {
    final vc = context.vColors;

    return Container(
      color: vc.scaffoldBg,
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        top: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 36.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                SvgPicture.asset(
                  'assets/icons/offline.svg',
                  width: 100.w,
                  height: 100.w,
                ),
                SizedBox(height: 16.h),

                // Title
                Text(
                  'Oops!',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColor.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 10.h),

                // Subtitle
                Text(
                  'No Internet Connection',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                    color: vc.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),

                // Description
                Text(
                  'Please check your Wi-Fi or mobile data\nand pull down to refresh.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: vc.onSurfaceMuted,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 32.h),

                // Retry hint pill
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(50.r),
                    border: Border.all(
                        color: AppColor.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded,
                          size: 16.sp, color: AppColor.primary),
                      SizedBox(width: 6.w),
                      Text(
                        'Pull down to refresh',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
