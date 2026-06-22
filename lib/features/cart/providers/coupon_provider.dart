import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/utils/app_haptics.dart';

class AppliedCoupon {
  final String code;
  final double discountAmount;
  final String description;

  AppliedCoupon({
    required this.code,
    required this.discountAmount,
    required this.description,
  });
}

class CouponNotifier extends StateNotifier<AppliedCoupon?> {
  CouponNotifier() : super(null);

  void applyCoupon(String code, double discount, String description) {
    AppHaptics.medium(); // rewarding confirmation a coupon was applied
    state = AppliedCoupon(
      code: code,
      discountAmount: discount,
      description: description,
    );
  }

  void removeCoupon() {
    state = null;
  }
}

final appliedCouponProvider =
    StateNotifierProvider<CouponNotifier, AppliedCoupon?>((ref) {
  return CouponNotifier();
});
