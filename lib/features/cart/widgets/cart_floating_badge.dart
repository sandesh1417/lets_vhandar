import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';
import 'package:lets_vhandar/features/cart/providers/cart_provider.dart';

class CartFloatingBadge extends ConsumerWidget {
  final VoidCallback onTap;

  const CartFloatingBadge({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemCount = ref.watch(totalCartItemsProvider);

    if (itemCount == 0) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(right: 8.w),
      width: 60.w,
      height: 60.h,
      child: FloatingActionButton(
        onPressed: onTap,
        backgroundColor: AppColor.primary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Badge(
          label: Text(
            '$itemCount',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
            ),
          ),
          backgroundColor: AppColor.secondary,
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          offset: const Offset(4, -4),
          child: Icon(
            Icons.shopping_cart_outlined,
            color: Colors.white,
            size: 26.sp,
          ),
        ),
      ),
    );
  }
}
