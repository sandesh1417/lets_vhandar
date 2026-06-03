import 'dart:convert';

class SavedList {
  final String id;
  final String name;
  final List<SavedProduct> products;
  final DateTime createdAt;

  SavedList({
    required this.id,
    required this.name,
    this.products = const [],
    required this.createdAt,
  });

  SavedList copyWith({
    String? name,
    List<SavedProduct>? products,
  }) =>
      SavedList(
        id: id,
        name: name ?? this.name,
        products: products ?? this.products,
        createdAt: createdAt,
      );

  factory SavedList.fromApi(Map<String, dynamic> map) => SavedList(
        id: (map['_id'] ?? map['id']) as String,
        name: map['name'] as String,
        products: (map['products'] as List<dynamic>? ?? [])
            .map((p) => SavedProduct.fromApi(Map<String, dynamic>.from(p)))
            .toList(),
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'products': products.map((p) => p.toMap()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory SavedList.fromMap(Map<String, dynamic> map) => SavedList(
        id: (map['_id'] ?? map['id']) as String,
        name: map['name'] as String,
        products: (map['products'] as List<dynamic>? ?? [])
            .map((p) => SavedProduct.fromMap(Map<String, dynamic>.from(p)))
            .toList(),
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : DateTime.now(),
      );

  String toJson() => jsonEncode(toMap());
  factory SavedList.fromJson(String source) =>
      SavedList.fromMap(jsonDecode(source));
}

class SavedProduct {
  final String id;
  final String? name;
  final String? unit;
  final double? price;
  final String? imageUrl;

  const SavedProduct({
    required this.id,
    this.name,
    this.unit,
    this.price,
    this.imageUrl,
  });

  factory SavedProduct.fromApi(Map<String, dynamic> map) {
    final images = map['images'] as List<dynamic>?;
    String? imageUrl;
    if (images != null && images.isNotEmpty) {
      final first = images.first;
      if (first is Map) {
        imageUrl = first['url'] as String?;
      } else if (first is String) {
        imageUrl = first;
      }
    }
    return SavedProduct(
      id: (map['_id'] ?? map['id']) as String,
      name: map['name'] as String?,
      unit: map['unit'] as String?,
      price: (map['pricePerUnit'] ?? map['price'] as num?)?.toDouble(),
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'unit': unit,
        'price': price,
        'imageUrl': imageUrl,
      };

  factory SavedProduct.fromMap(Map<String, dynamic> map) => SavedProduct(
        id: (map['_id'] ?? map['id']) as String,
        name: map['name'] as String?,
        unit: map['unit'] as String?,
        price: (map['price'] as num?)?.toDouble(),
        imageUrl: map['imageUrl'] as String?,
      );
}
