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
    final addressState = ref.watch(addressProvider);
    final selected = addressState.selected;
    final userId = ref.watch(loginProvider).user?.id ?? '';

    // Load addresses on first build if not already loaded
    if (!addressState.isFetched &&
        !addressState.isLoading &&
        userId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(addressProvider.notifier).loadAddresses(userId);
      });
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 52.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColor.primary,
                const Color.fromARGB(255, 6, 89, 58), // Vibrant green highlight
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24.r),
              bottomRight: Radius.circular(24.r),
            ),
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 50.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    SvgPicture.asset(
                      KImageConstant.vandharIcon,
                      height: 48.h,
                    ),
                    // Location Info — tappable
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
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
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
                            Text(
                              selected != null
                                  ? _truncate(
                                      selected.description ?? 'Select Address')
                                  : 'Select Address',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Search Bar (Floating)
        // ... inside HomeHeader build ...
        Positioned(
          bottom: -25.h,
          left: 16.w,
          right: 16.w,
          child: Container(
            // Removed GestureDetector from here
            height: 52.h,
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
                // Wrap only the Search area in a GestureDetector or InkWell
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior
                        .opaque, // Ensures the whole area is clickable
                    onTap: () {
                      context.pushNamed(LVRoute
                          .searchScreen.route); // Use pushNamed for consistency
                    },
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

                // Divider
                Container(
                  height: 24.h,
                  width: 1,
                  color: Colors.grey.shade200,
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                ),

                // Scanner Button (Now it won't be blocked)
                IconButton(
                  icon: Icon(Icons.qr_code_scanner,
                      color: AppColor.primary, size: 24.sp),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 24.r,
                  onPressed: () {
                    context.pushNamed(LVRoute.barcodeScannerScreen.route);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _truncate(String s, {int max = 22}) =>
      s.length > max ? '${s.substring(0, max)}..' : s;
}
