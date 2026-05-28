import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/features/cart/domain/models/cart_item_model.dart';
import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(ProductData product, {int quantity = 1}) {
    final stateList = state.toList();
    final index = stateList.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      final existingItem = stateList[index];
      stateList[index] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      stateList.add(CartItem(product: product, quantity: quantity));
    }
    state = stateList;
  }

  void removeFromCart(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final stateList = state.toList();
    final index = stateList.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      stateList[index] = stateList[index].copyWith(quantity: quantity);
      state = stateList;
    }
  }

  int getCartItemCount(String productId) {
    final index = state.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      return state[index].quantity;
    }
    return 0;
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final isBusinessUserProvider = Provider<bool>((ref) {
  return ref.watch(loginProvider).user?.isBusiness == true;
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
      // For business: MRP is businessPricePerUnit (no discount concept)
      return sum + ((item.product.businessPricePerUnit ?? item.product.actualPrice) * item.quantity);
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

// True when user taps Checkout without required delivery info selected
final cartAddressErrorProvider = StateProvider<bool>((ref) => false);

final selectedDeliverySlotProvider = StateProvider<String?>((ref) => null);
