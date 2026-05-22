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
import 'package:lets_vhandar/widgets/premium_search_bar.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final maxHeaderHeight = 130.h + statusBarHeight;
    final minHeaderHeight = 100.h + statusBarHeight;

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
    final rawProgress = shrinkOffset / (maxHeight - minHeight);
    final progress = rawProgress.clamp(0.0, 1.0);
    final eased = Curves.easeInOut.transform(progress);
    final currentHeight =
        maxHeight - shrinkOffset.clamp(0.0, maxHeight - minHeight);

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

        return Container(
          height: currentHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColor.primary,
                ColorTween(
                  begin: const Color.fromARGB(255, 6, 89, 58),
                  end: const Color.fromARGB(255, 4, 65, 42),
                ).lerp(eased)!,
              ],
              stops: [0.0, 1.0 - (eased * 0.15)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24.r * (1 - eased)),
              bottomRight: Radius.circular(24.r * (1 - eased)),
            ),
            boxShadow: _buildShadow(eased),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: statusBarHeight + (10.h * (1 - eased)),
                left: 20.w,
                right: 20.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'logo',
                      child: SvgPicture.asset(
                        KImageConstant.vandharIcon,
                        height: (48.h * (1 - eased * 0.4)).clamp(28.h, 48.h),
                      ),
                    ),
                    _AddressPill(
                      progress: eased,
                      selected: selected,
                      userId: userId,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 16.w,
                right: 16.w,
                bottom: (-25.h * (1 - eased)) + (12.h * eased),
                child: Transform.scale(
                  scale: 1.0 - (0.015 * (1 - eased)),
                  child: PremiumSearchBar(
                    controller: TextEditingController(),
                    readOnly: true,
                    onTap: () => context.pushNamed(LVRoute.searchScreen.route),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<BoxShadow> _buildShadow(double eased) {
    if (eased <= 0) return [];
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: eased * 0.12),
        blurRadius: 12.r * eased,
        offset: Offset(0, 3.h * eased),
      ),
    ];
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
}

class _AddressPill extends ConsumerWidget {
  final double progress;
  final dynamic selected;
  final String userId;

  const _AddressPill({
    required this.progress,
    required this.selected,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCollapsed = progress > 0.5;

    return GestureDetector(
      onTap: () {
        if (userId.isNotEmpty) {
          showAddressSelectorSheet(context, userId: userId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please login to manage addresses'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCollapsed)
              Opacity(
                opacity: (1 - progress * 2).clamp(0.0, 1.0),
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
                if (isCollapsed)
                  Padding(
                    padding: EdgeInsets.only(right: 4.w),
                    child: Icon(Icons.location_on,
                        color: Colors.white, size: 12.sp),
                  ),
                Text(
                  selected != null
                      ? _truncate(selected.description ?? 'Select Address',
                          max: isCollapsed ? 18 : 22)
                      : 'Select Address',
                  style: TextStyle(
                    fontSize: isCollapsed ? 11.sp : 13.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isCollapsed)
                  Icon(Icons.keyboard_arrow_down,
                      color: Colors.white, size: 12.sp),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _truncate(String s, {int max = 22}) =>
      s.length > max ? '${s.substring(0, max)}..' : s;
}
