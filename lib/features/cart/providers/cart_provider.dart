import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lets_vhandar/core/constants/app_constants.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/cart/domain/models/cart_item_model.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]) {
    _load();
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(AppConstants.cartStorageKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        state = list
            .map((e) => _cartItemFromMap(Map<String, dynamic>.from(e)))
            .whereType<CartItem>()
            .toList();
      }
    } catch (e, st) {
      dev.log('Cart load failed — resetting', error: e, stackTrace: st, name: 'CartNotifier');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.cartStorageKey);
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.cartStorageKey,
        jsonEncode(state.map(_cartItemToMap).toList()),
      );
    } catch (e, st) {
      dev.log('Cart save failed', error: e, stackTrace: st, name: 'CartNotifier');
    }
  }

  Map<String, dynamic> _cartItemToMap(CartItem item) => {
        'quantity': item.quantity,
        'product': item.product.toMap(),
      };

  CartItem? _cartItemFromMap(Map<String, dynamic> map) {
    try {
      final productMap = map['product'] as Map<String, dynamic>?;
      if (productMap == null) return null;
      return CartItem(
        product: ProductData.fromMap(productMap),
        quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      );
    } catch (_) {
      return null;
    }
  }

  // ── Cart operations ───────────────────────────────────────────────────────

  void addToCart(ProductData product, {int quantity = 1}) {
    final stateList = state.toList();
    final index = stateList.indexWhere((item) => item.product.id == product.id);
    final maxQty = _maxQty(product);

    if (index >= 0) {
      final existing = stateList[index];
      final newQty = (existing.quantity + quantity).clamp(1, maxQty);
      stateList[index] = existing.copyWith(quantity: newQty);
    } else {
      stateList.add(CartItem(product: product, quantity: quantity.clamp(1, maxQty)));
    }
    state = stateList;
    _save();
  }

  void removeFromCart(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
    _save();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final stateList = state.toList();
    final index = stateList.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      final product = stateList[index].product;
      final clamped = quantity.clamp(1, _maxQty(product));
      stateList[index] = stateList[index].copyWith(quantity: clamped);
      state = stateList;
      _save();
    }
  }

  int getCartItemCount(String productId) {
    final index = state.indexWhere((item) => item.product.id == productId);
    return index >= 0 ? state[index].quantity : 0;
  }

  void clearCart() {
    state = [];
    _save();
  }

  int _maxQty(ProductData product) {
    final raw = product.maximumQuantityOrder;
    if (raw == null) return 99;
    final val = (raw as num?)?.toInt() ?? 99;
    return val > 0 ? val : 99;
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final isBusinessUserProvider = Provider<bool>((ref) {
  return ref.watch(loginProvider.select((s) => s.user?.isBusiness == true));
});

final totalCartItemsProvider = Provider<int>((ref) {
  final cartItems = ref.watch(cartProvider);
  return cartItems.fold(0, (sum, item) => sum + item.quantity);
});

final totalCartMrpProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartProvider);
  final isBusiness = ref.watch(isBusinessUserProvider);
  return cartItems.fold(0, (sum, item) {
    if (isBusiness) {
      // B2B MRP = businessPricePerUnit (before B2B discount)
      final mrp = (item.product.businessPricePerUnit ?? 0) > 0
          ? item.product.businessPricePerUnit!
          : (item.product.pricePerUnit ?? item.product.actualPrice);
      return sum + (mrp * item.quantity);
    }
    final hasDiscount = item.product.discount != null &&
        (item.product.discount?.value ?? 0) > 0;
    final mrpPrice = (hasDiscount && item.product.pricePerUnit != null)
        ? item.product.pricePerUnit!
        : item.product.actualPrice;
    return sum + (mrpPrice * item.quantity);
  });
});

final totalCartPriceProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartProvider);
  final isBusiness = ref.watch(isBusinessUserProvider);
  return cartItems.fold(0, (sum, item) => sum + item.priceFor(isBusiness));
});

final cartAddressErrorProvider = StateProvider<bool>((ref) => false);
final selectedDeliverySlotProvider = StateProvider<String?>((ref) => null);
