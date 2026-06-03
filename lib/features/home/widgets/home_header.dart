import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
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
  final VoidCallback? onLogoTap;

  const HomeHeader({super.key, this.onLogoTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final maxHeaderHeight = 136.h + statusBarHeight;
    final minHeaderHeight = 72.h + statusBarHeight;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _HomeHeaderDelegate(
        maxHeight: maxHeaderHeight,
        minHeight: minHeaderHeight,
        statusBarHeight: statusBarHeight,
        onLogoTap: onLogoTap,
      ),
    );
  }
}

class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double maxHeight;
  final double minHeight;
  final double statusBarHeight;
  final VoidCallback? onLogoTap;

  _HomeHeaderDelegate({
    required this.maxHeight,
    required this.minHeight,
    required this.statusBarHeight,
    this.onLogoTap,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final range = maxHeight - minHeight;
    final progress = (shrinkOffset / range).clamp(0.0, 1.0);
    final eased = Curves.easeInOut.transform(progress);
    final currentHeight = maxHeight - shrinkOffset.clamp(0.0, range);

    // Address pill fades out in first half of scroll
    final addressOpacity = (1.0 - eased * 2).clamp(0.0, 1.0);
    // Inline search bar fades in in second half
    final inlineSearchOpacity = ((eased - 0.5) * 2).clamp(0.0, 1.0);
    // Bottom search bar (inside header) fades out fast
    final bottomSearchOpacity = (1.0 - eased * 2.5).clamp(0.0, 1.0);
    // Logo height: 56.h expanded → 38.h collapsed
    final logoHeight = 56.h - 18.h * eased;

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
            color: AppColor.primary,
            boxShadow: _buildShadow(eased),
          ),
          child: Stack(
            children: [
              // ── Top row: logo + [address pill ↔ inline search] ────
              Positioned(
                top: statusBarHeight + 10.h,
                left: 16.w,
                right: 16.w,
                height: 56.h,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: onLogoTap,
                      child: Hero(
                        tag: 'logo',
                        child: SvgPicture.asset(
                          KImageConstant.vandharIcon,
                          height: logoHeight,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          // Address pill — fades out when scrolling
                          if (addressOpacity > 0)
                            Opacity(
                              opacity: addressOpacity,
                              child: IgnorePointer(
                                ignoring: eased > 0.4,
                                child: _AddressPill(
                                  selected: selected,
                                  userId: userId,
                                ),
                              ),
                            ),

                          // Inline search bar — fades in when collapsed
                          if (inlineSearchOpacity > 0)
                            Opacity(
                              opacity: inlineSearchOpacity,
                              child: IgnorePointer(
                                ignoring: eased < 0.7,
                                child: PremiumSearchBar(
                                  controller: TextEditingController(),
                                  readOnly: true,
                                  onTap: () => context
                                      .pushNamed(LVRoute.searchScreen.route),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Bottom search bar — inside header, visible when expanded ─
              if (bottomSearchOpacity > 0)
                Positioned(
                  left: 16.w,
                  right: 16.w,
                  bottom: 14.h,
                  child: Opacity(
                    opacity: bottomSearchOpacity,
                    child: IgnorePointer(
                      ignoring: eased > 0.3,
                      child: PremiumSearchBar(
                        controller: TextEditingController(),
                        readOnly: true,
                        onTap: () =>
                            context.pushNamed(LVRoute.searchScreen.route),
                      ),
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
        minHeight != oldDelegate.minHeight ||
        onLogoTap != oldDelegate.onLogoTap;
  }
}

class _AddressPill extends ConsumerWidget {
  final dynamic selected;
  final String userId;

  const _AddressPill({
    required this.selected,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loginProvider).user;
    final isBusiness = user?.isBusiness == true;

    if (isBusiness) {
      final bd = user?.businessDetail;
      final address = (bd?['locationAddress'] ?? bd?['addressName'] ?? '') as String;
      final businessName = (bd?['businessName'] ?? '') as String;
      final displayAddress = address.isNotEmpty ? address : (businessName.isNotEmpty ? businessName : 'Business Location');

      return Container(
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.store_outlined, color: Colors.white70, size: 11.sp),
                SizedBox(width: 4.w),
                Text(
                  'Business Location',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              _truncate(displayAddress),
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Personal user — tappable address selector
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Delivering to',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 5.w),
                SvgPicture.asset(
                  'assets/images/box.svg',
                  width: 16.sp,
                  height: 16.sp,
                ),
              ],
            ),
            Text(
              selected != null
                  ? _truncate(selected.description ?? 'Select delivery location')
                  : 'Select delivery location',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _truncate(String s, {int max = 22}) =>
      s.length > max ? '${s.substring(0, max)}..' : s;
}
