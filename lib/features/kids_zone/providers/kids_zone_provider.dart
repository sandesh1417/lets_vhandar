import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KidsZoneState {
  final int coins;
  final List<String> redeemedCoupons;

  KidsZoneState({required this.coins, required this.redeemedCoupons});

  KidsZoneState copyWith({int? coins, List<String>? redeemedCoupons}) {
    return KidsZoneState(
      coins: coins ?? this.coins,
      redeemedCoupons: redeemedCoupons ?? this.redeemedCoupons,
    );
  }
}

class KidsZoneNotifier extends StateNotifier<KidsZoneState> {
  KidsZoneNotifier() : super(KidsZoneState(coins: 100, redeemedCoupons: [])) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final coins = prefs.getInt('kids_coins') ?? 100;
    final coupons = prefs.getStringList('kids_coupons') ?? [];
    state = KidsZoneState(coins: coins, redeemedCoupons: coupons);
  }

  Future<void> addCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final newCoins = state.coins + amount;
    await prefs.setInt('kids_coins', newCoins);
    state = state.copyWith(coins: newCoins);
  }

  Future<bool> redeemCoupon(String couponCode, int cost) async {
    if (state.coins < cost) return false;
    final prefs = await SharedPreferences.getInstance();
    final newCoins = state.coins - cost;
    final newCoupons = [...state.redeemedCoupons, couponCode];
    await prefs.setInt('kids_coins', newCoins);
    await prefs.setStringList('kids_coupons', newCoupons);
    state = KidsZoneState(coins: newCoins, redeemedCoupons: newCoupons);
    return true;
  }
}

final kidsZoneProvider =
    StateNotifierProvider<KidsZoneNotifier, KidsZoneState>((ref) {
  return KidsZoneNotifier();
});
