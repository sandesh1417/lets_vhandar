import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/core/constants/image_constant.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/features/address/providers/address_provider.dart';
import 'package:lets_vhandar/features/address/widgets/address_selector_sheet.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    // The extent of the "green" part
    final maxHeaderHeight = 135.h + statusBarHeight;
    final minHeaderHeight = 110.h + statusBarHeight;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _HomeHeaderDelegate(
        maxHeight: maxHeaderHeight,
        minHeight: minHeaderHeight,
        statusBarHeight: statusBarHeight,
      ),
    );
  }
}

class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double maxHeight;
  final double minHeight;
  final double statusBarHeight;

  _HomeHeaderDelegate({
    required this.maxHeight,
    required this.minHeight,
    required this.statusBarHeight,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // We want the animation to be complete before the header fully collapses
    final progress = shrinkOffset / (maxHeight - minHeight);
    final currentProgress = progress.clamp(0.0, 1.0);

    return Consumer(
      builder: (context, ref, _) {
        final addressState = ref.watch(addressProvider);
        final selected = addressState.selected;
        final userId = ref.watch(loginProvider).user?.id ?? '';

        if (!addressState.isFetched &&
            !addressState.isLoading &&
            userId.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(addressProvider.notifier).loadAddresses(userId);
          });
        }

        return Stack(
          clipBehavior: Clip.none, // Essential for the floating effect
          children: [
            // Background with Gradient
            Container(
              height:
                  maxHeight - (shrinkOffset.clamp(0.0, maxHeight - minHeight)),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColor.primary,
                    const Color.fromARGB(255, 6, 89, 58),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.r * (1 - currentProgress)),
                  bottomRight: Radius.circular(24.r * (1 - currentProgress)),
                ),
              ),
            ),

            // Logo and Address Info
            Positioned(
              top: statusBarHeight + (10.h * (1 - currentProgress)),
              left: 20.w,
              right: 20.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Hero(
                    tag: 'logo',
                    child: SvgPicture.asset(
                      KImageConstant.vandharIcon,
                      height: (48.h * (1 - currentProgress * 0.4))
                          .clamp(28.h, 48.h),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (userId.isNotEmpty) {
                        showAddressSelectorSheet(context, userId: userId);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please login to manage addresses'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (currentProgress < 0.5)
                            Opacity(
                              opacity:
                                  (1 - currentProgress * 2).clamp(0.0, 1.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Delivering to',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(Icons.keyboard_arrow_down,
                                      color: Colors.white, size: 14.sp),
                                ],
                              ),
                            ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (currentProgress >= 0.5)
                                Padding(
                                  padding: EdgeInsets.only(right: 4.w),
                                  child: Icon(Icons.location_on,
                                      color: Colors.white, size: 12.sp),
                                ),
                              Text(
                                selected != null
                                    ? _truncate(
                                        selected.description ??
                                            'Select Address',
                                        max: currentProgress > 0.5 ? 18 : 22)
                                    : 'Select Address',
                                style: TextStyle(
                                  fontSize:
                                      currentProgress > 0.5 ? 11.sp : 13.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (currentProgress >= 0.5)
                                Icon(Icons.keyboard_arrow_down,
                                    color: Colors.white, size: 12.sp),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar (Initially floating, then pins)
            Positioned(
              left: 16.w,
              right: 16.w,
              // Animate from -25.h (floating) to 12.h (inside the collapsed header)
              bottom:
                  (-25.h * (1 - currentProgress)) + (12.h * currentProgress),
              child: Container(
                height: 50.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            context.pushNamed(LVRoute.searchScreen.route),
                        child: Row(
                          children: [
                            Icon(Icons.search,
                                color: Colors.grey.shade400, size: 22.sp),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Search for products...',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 24.h,
                      width: 1,
                      color: Colors.grey.shade200,
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                    IconButton(
                      icon: Icon(Icons.qr_code_scanner,
                          color: AppColor.primary, size: 22.sp),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () =>
                          context.pushNamed(LVRoute.barcodeScannerScreen.route),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant _HomeHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight;
  }

  String _truncate(String s, {int max = 22}) =>
      s.length > max ? '${s.substring(0, max)}..' : s;
}
