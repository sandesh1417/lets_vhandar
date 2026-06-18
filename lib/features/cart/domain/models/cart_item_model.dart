import 'package:lets_vhandar/features/home/domain/models/product_modal.dart';

class CartItem {
  final ProductData product;
  final int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  CartItem copyWith({
    ProductData? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice => product.actualPrice * quantity;

  double get businessTotalPrice => product.businessActualPrice * quantity;

  double priceFor(bool isBusiness) =>
      isBusiness ? businessTotalPrice : totalPrice;
}
